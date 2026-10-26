-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Public map. The public map and its exports (KML, GPX, JSON, API, WISH) show to users
--    without access to the caves section only the caves with public_map = Y. On Lombardia the
--    data on the public map is public, so every cave without a per-cave group restriction
--    (groupview empty) is set to Y. The 5 caves restricted to a regional group stay hidden.
--    New caves get Y from the form, and an empty value also counts as Y (decided 2026-10-25):
--    a curator sets N only to hide a single cave from the public. This step makes the value
--    explicit. Only unset values are changed, so a later explicit N is kept. Safe to run twice;
--    the column is created here when the web container has not added it yet.
ALTER TABLE `ctl_caves` ADD COLUMN IF NOT EXISTS `public_map` varchar(255) NOT NULL DEFAULT '';
UPDATE `ctl_caves` SET `public_map` = 'Y'
  WHERE (`groupview` = '' OR `groupview` IS NULL) AND (`public_map` = '' OR `public_map` IS NULL);
