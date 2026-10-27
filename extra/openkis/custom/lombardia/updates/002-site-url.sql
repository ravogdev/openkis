-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Site URL: the old value is https://www.speleolombardia.it/catasto/ (the live site; every
--    link and asset would point there). Decided 2026-10-24: the new site uses its own subdomain,
--    served from /, so the value stays empty and is taken from the request (test host and
--    production alike). Redirect /catasto/* on the old server to the subdomain.
UPDATE `fn_settings` SET `varvalue` = '' WHERE `varname` = 'siteurl';
