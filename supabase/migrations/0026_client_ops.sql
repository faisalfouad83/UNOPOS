-- Exactly-once replay for work done on a till while it was offline.
--
-- The till keeps every change it couldn't send in a local queue and sends
-- it when the connection is back. A request can reach the server and still
-- look failed to the till (the reply was lost), so the same operation may
-- arrive twice. Each operation carries an id made on the till; run_client_op
-- records it and runs the operation in the same transaction, so a repeat is
-- recognised and skipped (returning the first result), and a failed run
-- leaves no record (it can be tried again).
--
-- Only the functions listed below can be run this way. run_client_op runs
-- as the caller (security invoker), so each function keeps its own checks.

create table if not exists client_ops (
  id          text primary key,
  store_id    text not null references stores (id) on delete cascade,
  rpc         text not null,
  result      jsonb,
  created_at  timestamptz not null default now()
);

create index if not exists idx_client_ops_store_created on client_ops (store_id, created_at desc);

alter table client_ops enable row level security;

create policy "tenant select" on client_ops
  for select using (store_id = current_store_id());
create policy "tenant insert" on client_ops
  for insert with check (store_id = current_store_id());
create policy "tenant update" on client_ops
  for update using (store_id = current_store_id());

create or replace function run_client_op(p_op_id text, p_rpc text, p_params jsonb default '{}'::jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_store text := current_store_id();
  v_oid oid;
  v_ret regtype;
  v_set boolean;
  v_args text := '';
  v_name text;
  v_type text;
  v_result jsonb;
begin
  if v_store is null then
    raise exception 'must be signed in as a store';
  end if;
  if coalesce(p_op_id, '') = '' then
    raise exception 'operation id required';
  end if;
  if not (p_rpc = any (array[
    'post_journal_entry', 'post_reversing_entry', 'process_sale_return',
    'receive_purchase_order', 'receive_stock_transfer', 'record_debt_payment',
    'record_stock_movement', 'reduce_debt_original_amount', 'start_break',
    'end_break', 'rehold_sale'
  ])) then
    raise exception 'operation not allowed: %', p_rpc;
  end if;

  insert into client_ops (id, store_id, rpc) values (p_op_id, v_store, p_rpc)
  on conflict (id) do nothing;
  if not found then
    -- Already done (the first reply was lost): hand back its result.
    return jsonb_build_object(
      'duplicate', true,
      'result', (select result from client_ops where id = p_op_id and store_id = v_store)
    );
  end if;

  select p.oid, p.prorettype::regtype, p.proretset into v_oid, v_ret, v_set
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = p_rpc;

  -- Named arguments from the JSON parameters, each cast to its declared type.
  for v_name, v_type in
    select a.name, format_type(a.typ, null)
    from pg_proc p, unnest(p.proargnames, p.proargtypes::oid[]) as a(name, typ)
    where p.oid = v_oid
  loop
    if p_params ? v_name then
      v_args := v_args || case when v_args = '' then '' else ', ' end
        || format('%I => ', v_name)
        || case
             when v_type = 'jsonb' then format('($1 -> %L)', v_name)
             when v_type = 'json' then format('($1 -> %L)::json', v_name)
             else format('($1 ->> %L)::%s', v_name, v_type)
           end;
    end if;
  end loop;

  if v_ret = 'void'::regtype then
    execute format('select %I(%s)', p_rpc, v_args) using p_params;
  elsif v_set then
    execute format('select coalesce(jsonb_agg(to_jsonb(r)), ''[]''::jsonb) from %I(%s) r', p_rpc, v_args)
      into v_result using p_params;
  else
    execute format('select to_jsonb(%I(%s))', p_rpc, v_args) into v_result using p_params;
  end if;

  update client_ops set result = v_result where id = p_op_id;
  return jsonb_build_object('result', v_result);
end;
$$;

grant execute on function run_client_op(text, text, jsonb) to authenticated;
