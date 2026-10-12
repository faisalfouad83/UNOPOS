-- A new store needs an activation code to start: it is created already
-- expired (so it opens on the "enter a code" screen) and redeeming any code
-- — including a two-week trial code — sets its real end date.
create or replace function set_store_trial_expiry()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.expires_at is null and new.activation_status = 'pending' then
    new.expires_at := now();
  end if;
  return new;
end;
$$;

-- Lets the sign-up screen check a code before the store is created, so a
-- used or unknown code is caught up front. Reveals only the code's state.
create or replace function activation_code_status(p_code text)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_code activation_codes;
begin
  select * into v_code from activation_codes where code = upper(trim(p_code));
  if v_code.id is null then
    return 'invalid';
  end if;
  if v_code.status <> 'unused' then
    return 'used';
  end if;
  if v_code.expires_at is not null and v_code.expires_at <= now() then
    return 'expired';
  end if;
  return 'unused';
end;
$$;

revoke all on function activation_code_status(text) from public;
grant execute on function activation_code_status(text) to anon, authenticated;
