-- 0028: a shift's expected cash is worked out by the server when the shift
-- closes, from everything recorded for it (a till that closed offline
-- only knew what it had itself). The cashier still sees the till's own
-- figure while closing; the stored one is the server's.

create or replace function shift_cash_figures(p_shift_id text, p_to timestamptz)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_shift shifts;
  v_to timestamptz;
  v_cash_account text;
  v_sales bigint;
  v_foreign_change bigint;
  v_foreign jsonb;
  v_debts bigint;
  v_refunds bigint;
  v_expenses bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_shift from shifts where id = p_shift_id and store_id = v_store_id;
  if v_shift.id is null then
    raise exception 'shift not found';
  end if;
  v_to := least(coalesce(p_to, v_shift.closed_at, now()), now());
  select id into v_cash_account from chart_of_accounts where store_id = v_store_id and code = '1000';

  select
    coalesce(sum(case when coalesce(foreign_tendered_minor_units, 0) > 0 then 0
                      when amount_tendered_minor_units is null then grand_total_minor_units
                      else amount_tendered_minor_units - coalesce(change_given_minor_units, 0) end), 0),
    coalesce(sum(case when coalesce(foreign_tendered_minor_units, 0) > 0 then coalesce(change_given_minor_units, 0) else 0 end), 0)
  into v_sales, v_foreign_change
  from sales
  where store_id = v_store_id and shift_id = v_shift.id and payment_method = 'cash'
    and status in ('completed', 'partiallyRefunded', 'refunded');

  select coalesce(jsonb_agg(jsonb_build_object('currency', currency, 'amount_minor_units', amount)), '[]'::jsonb)
  into v_foreign
  from (
    select coalesce(paid_currency, 'USD') as currency, sum(foreign_tendered_minor_units) as amount
    from sales
    where store_id = v_store_id and shift_id = v_shift.id and payment_method = 'cash'
      and status in ('completed', 'partiallyRefunded', 'refunded') and coalesce(foreign_tendered_minor_units, 0) > 0
    group by 1
  ) f;

  select coalesce(sum(amount_minor_units), 0) into v_debts
  from debt_payments
  where store_id = v_store_id and payment_method = 'cash' and received_by_user_id = v_shift.cashier_id
    and paid_at >= v_shift.opened_at and paid_at <= v_to;

  select coalesce(sum(l.credit_minor_units - l.debit_minor_units), 0) into v_refunds
  from sale_returns r
  join journal_lines l on l.journal_entry_id = r.journal_entry_id and l.account_id = v_cash_account
  where r.store_id = v_store_id and r.processed_by_user_id = v_shift.cashier_id and r.branch_id = v_shift.branch_id
    and r.created_at >= v_shift.opened_at and r.created_at <= v_to;

  -- Expenses taken back (reversed) don't count.
  select coalesce(sum(l.credit_minor_units - l.debit_minor_units), 0) into v_expenses
  from journal_entries e
  join journal_lines l on l.journal_entry_id = e.id and l.account_id = v_cash_account
  where e.store_id = v_store_id and e.reference_type = 'EXPENSE' and not e.is_reversal
    and e.created_by_user_id = v_shift.cashier_id and e.branch_id = v_shift.branch_id
    and e.entry_date >= v_shift.opened_at and e.entry_date <= v_to
    and not exists (select 1 from journal_entries rv where rv.reversal_of_entry_id = e.id);

  return jsonb_build_object(
    'shift_id', v_shift.id,
    'opening_minor_units', v_shift.opening_cash_float_minor_units,
    'cash_sales_minor_units', v_sales - v_foreign_change,
    'debt_payments_minor_units', v_debts,
    'refunds_minor_units', v_refunds,
    'expenses_minor_units', v_expenses,
    'expected_minor_units', v_shift.opening_cash_float_minor_units + v_sales - v_foreign_change + v_debts - v_refunds - v_expenses,
    'foreign', v_foreign,
    'as_of', v_to
  );
end;
$$;

revoke execute on function shift_cash_figures(text, timestamptz) from public, anon, authenticated;

create or replace function shift_cash_summary(p_shift_id text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select shift_cash_figures(p_shift_id, null);
$$;

create or replace function shift_close_figures()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_figures jsonb;
begin
  if new.status = 'closed' and old.status is distinct from 'closed' then
    v_figures := shift_cash_figures(new.id, coalesce(new.closed_at, now()));
    new.expected_cash_at_close_minor_units := (v_figures ->> 'expected_minor_units')::bigint;
    if new.counted_cash_at_close_minor_units is not null then
      new.discrepancy_minor_units := new.counted_cash_at_close_minor_units - new.expected_cash_at_close_minor_units;
    end if;
  end if;
  return new;
end;
$$;

create or replace trigger shifts_close_figures
  before update on shifts
  for each row execute function shift_close_figures();
