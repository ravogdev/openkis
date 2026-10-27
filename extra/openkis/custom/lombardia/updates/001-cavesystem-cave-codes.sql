-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Cave systems list their caves as bare numbers (12,34.2); the new definition links by
--      code (LO12). On the dump every value is both a cave id and LO+number of a code.
UPDATE `ctl_cavesystems` SET `caves` = REGEXP_REPLACE(`caves`, '(^|,) *([0-9]+(\\.[0-9]+)?)', '\\1LO\\2')
  WHERE `caves` REGEXP '(^|,) *[0-9]';
