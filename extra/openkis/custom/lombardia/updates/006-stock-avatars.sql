-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Stock avatars. 21 accounts chose one of the 31 stock avatars (fn_users.avatarimage =
--    avtrNN.png). Upstream finis dropped the stock avatars and their picker in 2024, and the
--    image files are not shipped, so those accounts would show a broken image. Following
--    upstream (decided 2026-10-25), the choice is cleared: they get the default user icon and
--    can upload their own picture. Uploaded avatars (fn_users.avatar) are not touched.
--    Safe to run twice.
UPDATE `fn_users` SET `avatarimage` = '' WHERE `avatarimage` <> '';
