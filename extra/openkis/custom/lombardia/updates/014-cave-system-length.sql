-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Cave-system development (#75, #76). ctl_caves.lenght_scope says whether the development of
--    a record refers to the whole cave ("total") or to this entrance only ("partial"); the
--    history table keeps it too. ctl_cavesystems.lenght_auto = N keeps a system development
--    entered by hand. Existing records stay empty: an unclassified cave does not change its
--    system, and on Lombardia new caves start empty as well (curators choose). The columns are
--    created here when the web container has not added them yet.
--    The development and depth of the systems were kept by the old site only in the legacy
--    columns SVILRE and DTOT (lenght_total and depth_total are empty on all 10 systems), and the
--    cave-system page no longer fills them with the sum of its caves: they are copied where
--    empty. A value already set is not touched.
ALTER TABLE `ctl_caves` ADD COLUMN IF NOT EXISTS `lenght_scope` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_caves_versions` ADD COLUMN IF NOT EXISTS `lenght_scope` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_cavesystems` ADD COLUMN IF NOT EXISTS `lenght_auto` varchar(255) NOT NULL DEFAULT '';
UPDATE `ctl_cavesystems` SET `lenght_total` = TRIM(`SVILRE`)
 WHERE (`lenght_total` IS NULL OR TRIM(`lenght_total`) = '') AND TRIM(`SVILRE`) REGEXP '^[0-9]+$';
UPDATE `ctl_cavesystems` SET `depth_total` = TRIM(`DTOT`)
 WHERE (`depth_total` IS NULL OR TRIM(`depth_total`) = '') AND TRIM(`DTOT`) REGEXP '^[0-9]+$';
