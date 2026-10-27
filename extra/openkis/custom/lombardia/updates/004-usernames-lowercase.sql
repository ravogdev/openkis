-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Usernames in lowercase. The login lowercases what the user types, and fn_users.username is
--    case sensitive (utf8mb3_bin), so an account saved with capitals can't log in. Each such
--    account is renamed in lowercase, with the author fields of its records, unless a
--    lowercase account with the same name already exists (then it is the same person's
--    newer account, and the old one is left as it is; decided with the admin).
--    Safe to run twice.
CREATE TEMPORARY TABLE `okx_lowercase_users` AS
  SELECT u.`username` AS `old` FROM `fn_users` u
   WHERE BINARY u.`username` <> BINARY LOWER(u.`username`)
     AND NOT EXISTS (SELECT 1 FROM `fn_users` l WHERE BINARY l.`username` = BINARY LOWER(u.`username`));
UPDATE `fn_users`    SET `username`   = LOWER(`username`)   WHERE BINARY `username`   IN (SELECT BINARY `old` FROM `okx_lowercase_users`);
UPDATE `ctl_caves`   SET `username`   = LOWER(`username`)   WHERE BINARY `username`   IN (SELECT BINARY `old` FROM `okx_lowercase_users`);
UPDATE `ctl_caves`   SET `userupdate` = LOWER(`userupdate`) WHERE BINARY `userupdate` IN (SELECT BINARY `old` FROM `okx_lowercase_users`);
UPDATE `SPELEOPALEO` SET `username`   = LOWER(`username`)   WHERE BINARY `username`   IN (SELECT BINARY `old` FROM `okx_lowercase_users`);
UPDATE `SPELEOPALEO` SET `userupdate` = LOWER(`userupdate`) WHERE BINARY `userupdate` IN (SELECT BINARY `old` FROM `okx_lowercase_users`);
DROP TEMPORARY TABLE `okx_lowercase_users`;
