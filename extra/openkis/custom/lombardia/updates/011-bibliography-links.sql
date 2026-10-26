-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Bibliography link table (#20): the cave pages find the bibliography items of a cave in
--    ctl_bibliography_links (one row per item and code) instead of scanning the comma separated
--    codecaves of every item. Same structure as the code creates from
--    misc/fndatabase/ctl_bibliography_links.php, plus its index (also in sql/openkis_indexes.sql).
--    The table is filled by the application on the first cave page view and rebuilt whenever
--    the bibliography changes, so this step creates it empty.
CREATE TABLE IF NOT EXISTS `ctl_bibliography_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bibliography_id` varchar(255) NOT NULL DEFAULT '',
  `linkfield` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_bin;
CREATE INDEX IF NOT EXISTS `okx_linkfield_code` ON `ctl_bibliography_links` (`linkfield`, `code`);
