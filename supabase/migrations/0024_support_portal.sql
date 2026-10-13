-- Technical support: support employees with their own sign-in accounts,
-- one persistent conversation per store shared by the whole support team,
-- and the developer's administration of support staff (salary
-- adjustments, status, audit).

create table if not exists support_agents (
  id                  text primary key default gen_random_uuid()::text,
  auth_user_id        uuid unique,
  full_name           text not null,
  email               text not null unique,
  phone               text not null default '',
  address             text not null default '',
  job_title           text not null default '',
  salary_minor_units  bigint not null default 0,
  employment_status   text not null default 'active' check (employment_status in ('active', 'suspended', 'terminated')),
  presence            text not null default 'signed_out' check (presence in ('online', 'break', 'signed_out')),
  last_seen_at        timestamptz,
  created_at          timestamptz not null default now(),
  notes               text not null default ''
);

create table if not exists support_salary_adjustments (
  id                  text primary key default gen_random_uuid()::text,
  agent_id            text not null references support_agents (id) on delete cascade,
  kind                text not null check (kind in ('deduction', 'bonus')),
  amount_minor_units  bigint not null check (amount_minor_units > 0),
  reason              text not null,
  effective_date      date not null default current_date,
  created_by_admin_id text references developer_admins (id) on delete set null,
  created_at          timestamptz not null default now()
);

create table if not exists support_conversations (
  id                   text primary key default gen_random_uuid()::text,
  store_id             text not null unique references stores (id) on delete cascade,
  status               text not null default 'open' check (status in ('open', 'pending', 'closed')),
  assigned_agent_id    text references support_agents (id) on delete set null,
  created_at           timestamptz not null default now(),
  last_message_at      timestamptz not null default now(),
  last_message_preview text not null default '',
  unread_for_store     integer not null default 0,
  unread_for_support   integer not null default 0
);

create table if not exists support_messages (
  id                text primary key default gen_random_uuid()::text,
  conversation_id   text not null references support_conversations (id) on delete cascade,
  store_id          text not null references stores (id) on delete cascade,
  sender_type       text not null check (sender_type in ('store', 'agent')),
  sender_agent_id   text references support_agents (id) on delete set null,
  sender_name       text not null default '',
  body              text not null check (length(body) between 1 and 4000),
  is_internal_note  boolean not null default false,
  client_message_id text not null,
  created_at        timestamptz not null default now(),
  unique (conversation_id, client_message_id)
);

create index if not exists idx_support_messages_conv on support_messages (conversation_id, created_at);
create index if not exists idx_support_conversations_last on support_conversations (last_message_at desc);

alter table support_agents enable row level security;
alter table support_salary_adjustments enable row level security;
alter table support_conversations enable row level security;
alter table support_messages enable row level security;

-- The signed-in support employee (active accounts only).
create or replace function current_support_agent()
returns support_agents
language sql
stable
security definer
set search_path = public
as $$
  select * from support_agents where auth_user_id = auth.uid() and employment_status = 'active';
$$;

create or replace function is_support_agent()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from support_agents where auth_user_id = auth.uid() and employment_status = 'active');
$$;

grant execute on function is_support_agent() to authenticated;

-- Support staff records: developers manage them; an agent can read their
-- own record. Salary and personal details are never visible to stores or
-- to other agents.
create policy "support agents: developers" on support_agents
  for all using (is_developer_admin()) with check (is_developer_admin());
create policy "support agents: own record" on support_agents
  for select using (auth_user_id = auth.uid());

create policy "salary adjustments: developers" on support_salary_adjustments
  for select using (is_developer_admin());
create policy "salary adjustments: developers add" on support_salary_adjustments
  for insert with check (is_developer_admin());

-- Conversations / messages: a store sees only its own conversation and
-- never internal notes; support staff and developers see all. Writes go
-- through the functions below.
create policy "support conversations: store" on support_conversations
  for select using (store_id = current_store_id());
create policy "support conversations: support team" on support_conversations
  for select using (is_support_agent() or is_developer_admin());

create policy "support messages: store" on support_messages
  for select using (store_id = current_store_id() and not is_internal_note);
create policy "support messages: support team" on support_messages
  for select using (is_support_agent() or is_developer_admin());

-- The store's conversation, created the first time it's needed and kept
-- forever after (reopened if it was closed).
create or replace function store_support_conversation()
returns support_conversations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_conv support_conversations;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  insert into support_conversations (store_id) values (v_store_id)
    on conflict (store_id) do nothing;
  select * into v_conv from support_conversations where store_id = v_store_id;
  return v_conv;
end;
$$;

grant execute on function store_support_conversation() to authenticated;

-- A message from the store. Retrying with the same client id never
-- creates a second copy.
create or replace function store_send_support_message(p_body text, p_client_message_id text)
returns support_messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_conv support_conversations := store_support_conversation();
  v_msg support_messages;
  v_name text;
begin
  select display_name into v_name from stores where id = v_conv.store_id;
  insert into support_messages (conversation_id, store_id, sender_type, sender_name, body, client_message_id)
  values (v_conv.id, v_conv.store_id, 'store', coalesce(v_name, ''), trim(p_body), p_client_message_id)
  on conflict (conversation_id, client_message_id) do nothing;
  select * into v_msg from support_messages where conversation_id = v_conv.id and client_message_id = p_client_message_id;
  update support_conversations set
    last_message_at = v_msg.created_at,
    last_message_preview = left(v_msg.body, 140),
    unread_for_support = unread_for_support + 1,
    status = case when status = 'closed' then 'open' else status end
  where id = v_conv.id;
  return v_msg;
end;
$$;

grant execute on function store_send_support_message(text, text) to authenticated;

create or replace function store_mark_support_read()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update support_conversations set unread_for_store = 0 where store_id = current_store_id();
end;
$$;

grant execute on function store_mark_support_read() to authenticated;

-- A reply (or internal note) from a support employee, signed with their
-- name as it is now so the history keeps who wrote it.
create or replace function agent_send_support_message(
  p_conversation_id text,
  p_body text,
  p_client_message_id text,
  p_internal boolean default false
)
returns support_messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_agent support_agents := current_support_agent();
  v_conv support_conversations;
  v_msg support_messages;
begin
  if v_agent.id is null then
    raise exception 'support staff only';
  end if;
  select * into v_conv from support_conversations where id = p_conversation_id for update;
  if v_conv.id is null then
    raise exception 'conversation not found';
  end if;
  insert into support_messages (conversation_id, store_id, sender_type, sender_agent_id, sender_name, body,
                                is_internal_note, client_message_id)
  values (v_conv.id, v_conv.store_id, 'agent', v_agent.id, v_agent.full_name, trim(p_body), p_internal,
          p_client_message_id)
  on conflict (conversation_id, client_message_id) do nothing;
  select * into v_msg from support_messages where conversation_id = v_conv.id and client_message_id = p_client_message_id;
  if not p_internal then
    update support_conversations set
      last_message_at = v_msg.created_at,
      last_message_preview = left(v_msg.body, 140),
      unread_for_store = unread_for_store + 1,
      unread_for_support = 0,
      assigned_agent_id = coalesce(assigned_agent_id, v_agent.id),
      status = case when status = 'closed' then 'open' else status end
    where id = v_conv.id;
  end if;
  return v_msg;
end;
$$;

grant execute on function agent_send_support_message(text, text, text, boolean) to authenticated;

-- Take over a conversation (any agent may; the history stays whole), or
-- change its status.
create or replace function agent_update_conversation(p_conversation_id text, p_take_over boolean, p_status text default null)
returns support_conversations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_agent support_agents := current_support_agent();
  v_conv support_conversations;
begin
  if v_agent.id is null then
    raise exception 'support staff only';
  end if;
  if p_status is not null and p_status not in ('open', 'pending', 'closed') then
    raise exception 'invalid status';
  end if;
  update support_conversations set
    assigned_agent_id = case when p_take_over then v_agent.id else assigned_agent_id end,
    status = coalesce(p_status, status),
    unread_for_support = 0
  where id = p_conversation_id
  returning * into v_conv;
  return v_conv;
end;
$$;

grant execute on function agent_update_conversation(text, boolean, text) to authenticated;

-- The inbox: every conversation with its store's details, for support
-- staff (stores' own rows are otherwise private).
create or replace function support_inbox(p_search text default null, p_status text default null)
returns table (
  conversation_id text,
  store_id text,
  store_login_id text,
  store_name text,
  owner_name text,
  phone text,
  address text,
  activation_status text,
  expires_at timestamptz,
  status text,
  assigned_agent_id text,
  assigned_agent_name text,
  created_at timestamptz,
  last_message_at timestamptz,
  last_message_preview text,
  unread_for_support integer
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not (is_support_agent() or is_developer_admin()) then
    raise exception 'support staff only';
  end if;
  return query
    select c.id, s.id, s.store_login_id, s.display_name, s.owner_name, s.phone, s.address, s.activation_status,
           s.expires_at, c.status, c.assigned_agent_id, a.full_name, c.created_at, c.last_message_at,
           c.last_message_preview, c.unread_for_support
    from support_conversations c
    join stores s on s.id = c.store_id
    left join support_agents a on a.id = c.assigned_agent_id
    where (p_status is null or c.status = p_status)
      and (p_search is null or p_search = ''
           or s.display_name ilike '%' || p_search || '%'
           or s.store_login_id ilike '%' || p_search || '%'
           or s.id = p_search
           or s.phone ilike '%' || p_search || '%')
    order by c.last_message_at desc
    limit 300;
end;
$$;

grant execute on function support_inbox(text, text) to authenticated;

-- Presence: the support app reports in every minute; a status older than
-- two minutes is shown as disconnected rather than trusted.
create or replace function support_heartbeat(p_presence text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_presence not in ('online', 'break', 'signed_out') then
    raise exception 'invalid presence';
  end if;
  update support_agents set presence = p_presence, last_seen_at = now()
  where auth_user_id = auth.uid();
end;
$$;

grant execute on function support_heartbeat(text) to authenticated;

-- Audit trail for support staff administration.
create or replace function audit_support_agent_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Presence heartbeats aren't administrative changes.
  if tg_op = 'UPDATE'
     and new.full_name = old.full_name and new.salary_minor_units = old.salary_minor_units
     and new.employment_status = old.employment_status and new.email = old.email
     and new.phone = old.phone and new.address = old.address and new.job_title = old.job_title
     and new.notes = old.notes then
    return new;
  end if;
  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (
    current_developer_admin_id(),
    'support_agent.' || lower(tg_op),
    null,
    jsonb_build_object(
      'agent_id', new.id,
      'before', case when tg_op = 'INSERT' then null else jsonb_build_object(
        'full_name', old.full_name, 'job_title', old.job_title, 'salary', old.salary_minor_units,
        'employment_status', old.employment_status) end,
      'after', jsonb_build_object(
        'full_name', new.full_name, 'job_title', new.job_title, 'salary', new.salary_minor_units,
        'employment_status', new.employment_status)
    )::text
  );
  return new;
end;
$$;

create trigger trg_audit_support_agent
  after insert or update on support_agents
  for each row execute function audit_support_agent_change();

create or replace function audit_salary_adjustment()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.created_by_admin_id := coalesce(new.created_by_admin_id, current_developer_admin_id());
  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (new.created_by_admin_id, 'support_agent.salary_' || new.kind, null,
          jsonb_build_object('agent_id', new.agent_id, 'amount', new.amount_minor_units,
                             'reason', new.reason, 'effective_date', new.effective_date)::text);
  return new;
end;
$$;

create trigger trg_audit_salary_adjustment
  before insert on support_salary_adjustments
  for each row execute function audit_salary_adjustment();

alter publication supabase_realtime add table support_messages, support_conversations, support_agents;
