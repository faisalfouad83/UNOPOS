-- Stores default to Iraqi dinar (the app's home market) instead of USD.
-- Stores still on the untouched old default are moved over too; any store
-- that had deliberately set its own currency keeps it.
alter table app_settings alter column currency_code set default 'IQD';
alter table app_settings alter column currency_symbol set default 'د.ع';

update app_settings
set currency_code = 'IQD', currency_symbol = 'د.ع'
where currency_code = 'USD' and currency_symbol = '$';
