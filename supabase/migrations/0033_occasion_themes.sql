-- =============================================================================
-- UNOPOS — Five occasion themes: Muharram, Iraqi Army Day, Iraqi Police Day,
-- Iraqi Sovereignty Day and Mawlid al-Nabi
-- =============================================================================
-- Widens the two theme-key check constraints from 0030 to accept the new
-- keys (lib/core/theming/store_themes.dart). Only the allowed values change:
-- no rows are touched and every existing value stays valid.
-- Idempotent: safe to run more than once.
-- =============================================================================

alter table app_settings drop constraint if exists app_settings_theme_key_check;
alter table app_settings add constraint app_settings_theme_key_check check (
  theme_key is null or theme_key in (
    'system',
    'light', 'dark', 'christmas', 'halloween', 'eid_al_fitr', 'eid_al_adha',
    'nowruz', 'ramadan', 'summer', 'autumn', 'spring', 'winter',
    'muharram', 'iraqi_army_day', 'iraqi_police_day', 'iraqi_sovereignty_day', 'mawlid'
  )
);

alter table theme_assignments drop constraint if exists theme_assignments_theme_key_check;
alter table theme_assignments add constraint theme_assignments_theme_key_check check (theme_key in (
  'light', 'dark', 'christmas', 'halloween', 'eid_al_fitr', 'eid_al_adha',
  'nowruz', 'ramadan', 'summer', 'autumn', 'spring', 'winter',
  'muharram', 'iraqi_army_day', 'iraqi_police_day', 'iraqi_sovereignty_day', 'mawlid'
));
