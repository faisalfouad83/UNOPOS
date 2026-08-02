-- =============================================================================
-- UNOPOS — Phase H5: Notification inbox read access
-- =============================================================================
-- 0001 made platform_notifications fully developer-only (select/insert/
-- update/delete all gated on is_developer_admin()). That's correct for
-- insert/update/delete, but it also blocked a store from ever reading the
-- title/body of a notification addressed to it — notification_recipients
-- already lets a store see that *a* notification exists for it, but the
-- join to platform_notifications for the actual content would return
-- nothing under RLS. Adds one additional select policy: a store may read a
-- platform_notifications row if (and only if) it's listed as a recipient
-- of it.
-- =============================================================================

create policy "store reads notifications addressed to it" on platform_notifications
  for select using (
    id in (select notification_id from notification_recipients where store_id = current_store_id())
  );
