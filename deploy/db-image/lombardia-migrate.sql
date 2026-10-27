-- OpenKIS Lombardia: schema migration of the old database (dump of 2026-10-24) for the
-- Docker deployment (openkis develop + finis develop, MariaDB 11.4).
-- Run once on the imported database, BEFORE the web container starts for the first time.
-- Generated from the dump's own schema; review before use. Idempotent where possible.
-- Steps 3b2 and 5-17 are also shipped in the image (extra/openkis/custom/lombardia/updates/,
-- files 001-014): the container applies the ones a database doesn't have yet, once, at start.
-- A new step goes in both places: here, and as the next numbered file in updates/.
-- deploy/db-image/build.sh builds a local database image from the original dump, this script
-- and the update files (never pushed: it holds the data).
SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION';

-- 1. Backup / scratch tables that nothing uses (uncomment to drop)
-- DROP TABLE IF EXISTS `ctl_caves_bk_2024_05_01`;
-- DROP TABLE IF EXISTS `____empty_____`;

-- 2. Statistics tables: the old primary key `unirecid` is called `id` in the new code
ALTER TABLE `ctl_caves_stat` CHANGE `unirecid` `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL;
ALTER TABLE `ctl_photos_stat` CHANGE `unirecid` `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL;
ALTER TABLE `ctl_surveys_stat` CHANGE `unirecid` `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL;
ALTER TABLE `ctl_attachments_stat` CHANGE `unirecid` `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL;

-- 3. Cave ids are FLOAT in the old schema (1003.2 for second entrances): `id = '1003.2'` never
--    matches a FLOAT. VARCHAR like the new schema; every id keeps the same text (verified).
ALTER TABLE `ctl_caves` MODIFY `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL;

-- 3b. Cave systems: the old primary key is the legacy column NUM (same values as id).
--     The new code reads and writes by id, and NUM has no default, so new systems fail.
ALTER TABLE `ctl_cavesystems` DROP INDEX `NUM`, DROP PRIMARY KEY,
  MODIFY `id` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL, ADD PRIMARY KEY (`id`),
  MODIFY `NUM` VARCHAR(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;

-- 3b2. Cave systems list their caves as bare numbers (12,34.2); the new definition links by
--      code (LO12). On the dump every value is both a cave id and LO+number of a code.
UPDATE `ctl_cavesystems` SET `caves` = REGEXP_REPLACE(`caves`, '(^|,) *([0-9]+(\\.[0-9]+)?)', '\\1LO\\2')
  WHERE `caves` REGEXP '(^|,) *[0-9]';

-- 3c. Bibliography: the old site uses the misspelt table ctl_bibliograpy; the new definition
--     (ctl_bibliography.php, <sqltable>ctl_bibliography</sqltable>) has the same fields (incl.
--     Editore). Rename, and point the section at it. Also move the upload folder:
--     misc/fndatabase/ctl_bibliograpy/ -> misc/fndatabase/ctl_bibliography/ and delete the old
--     misc/fndatabase/ctl_bibliograpy.php definition.
RENAME TABLE `ctl_bibliograpy` TO `ctl_bibliography`,
  `ctl_bibliograpy_download_stat` TO `ctl_bibliography_download_stat`;
UPDATE `fncf_bibliography` SET `varvalue` = 'ctl_bibliography' WHERE `varname` = 'tables' AND `varvalue` = 'ctl_bibliograpy';

-- 3d. The springs section points at fn_files (unused default); the map refresh then queries
--     coordinates from fn_files and logs a warning. Lombardia has no springs.
UPDATE `fncf_springs` SET `varvalue` = 'ctl_springs' WHERE `varname` = 'tables' AND `varvalue` = 'fn_files';

-- 4. MyISAM -> InnoDB (crash safety; the okx_ indexes exceed MyISAM's 1000-byte key limit),
--    latin1 tables -> utf8, and NOT NULL columns without a default -> NULL: MariaDB 11.4 runs
--    in strict mode, where an INSERT that leaves out such a column fails.
ALTER TABLE `ctl_age`
  ENGINE=InnoDB;
ALTER TABLE `ctl_areas`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `associations` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `lithological` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `geomorphology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `hydrogeological` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `caving` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `landcover` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `othercharacteristics` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `aquifers` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `bibliography` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `geographical_framework` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `geological_framework` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_artificials`
  ENGINE=InnoDB,
  MODIFY `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `closed_notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `associations` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `chronology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `itinerary` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `wells` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `history` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `fauna` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_art_categories`
  ENGINE=InnoDB;
ALTER TABLE `ctl_art_types`
  ENGINE=InnoDB;
ALTER TABLE `ctl_associations`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb3 COLLATE utf8mb3_bin;
ALTER TABLE `ctl_attachments`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_attachments_download_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_attachments_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_bibliography`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb3 COLLATE utf8mb3_bin;
ALTER TABLE `ctl_bibliography_download_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_caves`
  ENGINE=InnoDB,
  MODIFY `closed_notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `associations` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `chronology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `itinerary` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `wells` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `fauna` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `geology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `history` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `import_rawdata` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `groupview_bk` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_cavesystems`
  ENGINE=InnoDB,
  CONVERT TO CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
  MODIFY `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `COLL` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `recordinsert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `recordupdate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `view` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `groupview` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `photo1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `authorphoto1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `PROV` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `ACARCOD` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `SVILRE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `DTOT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_caves_rules`
  ENGINE=InnoDB;
ALTER TABLE `ctl_caves_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_caves_versions`
  ENGINE=InnoDB,
  MODIFY `closed_notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `associations` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `chronology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `itinerary` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `wells` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `fauna` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `geology` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `history` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `import_rawdata` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_coordinatestypes`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `proj4` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_fauna`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_faunacave`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_geologicalformations`
  ENGINE=InnoDB;
ALTER TABLE `ctl_licenses`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `license` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_photos`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_photos_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_springs`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `itinerary` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `import_rawdata` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_surveys`
  ENGINE=InnoDB,
  MODIFY `makers` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_surveys_artificials`
  ENGINE=InnoDB,
  MODIFY `makers` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `ctl_surveys_download_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_surveys_stat`
  ENGINE=InnoDB;
ALTER TABLE `ctl_walls`
  ENGINE=InnoDB;
ALTER TABLE `extra_s_openkis`
  ENGINE=InnoDB;
ALTER TABLE `fieldusers`
  ENGINE=InnoDB;
ALTER TABLE `fncf_areas`
  ENGINE=InnoDB;
ALTER TABLE `fncf_artificials`
  ENGINE=InnoDB;
ALTER TABLE `fncf_art_categorie`
  ENGINE=InnoDB;
ALTER TABLE `fncf_art_tipologie`
  ENGINE=InnoDB;
ALTER TABLE `fncf_bibliography`
  ENGINE=InnoDB;
ALTER TABLE `fncf_block_calendar`
  ENGINE=InnoDB;
ALTER TABLE `fncf_block_last_news`
  ENGINE=InnoDB;
ALTER TABLE `fncf_caves`
  ENGINE=InnoDB;
ALTER TABLE `fncf_cavesystem`
  ENGINE=InnoDB;
ALTER TABLE `fncf_esportazioni`
  ENGINE=InnoDB;
ALTER TABLE `fncf_fauna`
  ENGINE=InnoDB;
ALTER TABLE `fncf_fauna_surveys`
  ENGINE=InnoDB;
ALTER TABLE `fncf_login`
  ENGINE=InnoDB;
ALTER TABLE `fncf_map_caves`
  ENGINE=InnoDB;
ALTER TABLE `fncf_menu_artificials`
  ENGINE=InnoDB;
ALTER TABLE `fncf_menu_fauna`
  ENGINE=InnoDB;
ALTER TABLE `fncf_menu_natural`
  ENGINE=InnoDB;
ALTER TABLE `fncf_menu_settings`
  ENGINE=InnoDB;
ALTER TABLE `fncf_openai`
  ENGINE=InnoDB;
ALTER TABLE `fncf_reports`
  ENGINE=InnoDB;
ALTER TABLE `fncf_springs`
  ENGINE=InnoDB;
ALTER TABLE `fncf_Strumenti`
  ENGINE=InnoDB;
ALTER TABLE `fncf_survey`
  ENGINE=InnoDB;
ALTER TABLE `fncf_survey_artificials`
  ENGINE=InnoDB;
ALTER TABLE `fn_avatars`
  ENGINE=InnoDB;
ALTER TABLE `fn_blocks`
  ENGINE=InnoDB;
ALTER TABLE `fn_cc_users`
  ENGINE=InnoDB;
ALTER TABLE `fn_conditions`
  ENGINE=InnoDB,
  MODIFY `text` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `text_it` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `text_en` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `text_fr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `fn_files`
  ENGINE=InnoDB,
  MODIFY `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description_it` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `description_en` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `fn_groups`
  ENGINE=InnoDB;
ALTER TABLE `fn_sections`
  ENGINE=InnoDB;
ALTER TABLE `fn_sectionstypes`
  ENGINE=InnoDB;
ALTER TABLE `fn_settings`
  ENGINE=InnoDB;
ALTER TABLE `fn_users`
  ENGINE=InnoDB,
  MODIFY `signature` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `plugins_s_statistics`
  ENGINE=InnoDB;
ALTER TABLE `SPELEOPALEO`
  ENGINE=InnoDB,
  MODIFY `schede_info` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  MODIFY `PREIMPORT` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;
ALTER TABLE `stats_browsers`
  ENGINE=InnoDB;
ALTER TABLE `stats_date`
  ENGINE=InnoDB;
ALTER TABLE `stats_pages`
  ENGINE=InnoDB;
ALTER TABLE `stats_total`
  ENGINE=InnoDB;
ALTER TABLE `themes_s_base`
  ENGINE=InnoDB;
ALTER TABLE `themes_s_liguria`
  ENGINE=InnoDB;
ALTER TABLE `themes_s_openkis_liguria`
  ENGINE=InnoDB;
ALTER TABLE `themes_s_openkis_lombardia`
  ENGINE=InnoDB;
ALTER TABLE `VECCHIO_CART`
  ENGINE=InnoDB,
  MODIFY `NUMCAVE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `CART` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `DATE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `recordinsert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `AUTHOR` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `LICENSE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `DESC` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `FILE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `FILEDWG` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `FILEKML` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `PRECISIONE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `MAKERS` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `PDF` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `groupview` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `userupdate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `recordupdate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  MODIFY `NUMSYSTEM` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL;

-- 5. Site URL: the old value is https://www.speleolombardia.it/catasto/ (the live site; every
--    link and asset would point there). Decided 2026-10-24: the new site uses its own subdomain,
--    served from /, so the value stays empty and is taken from the request (test host and
--    production alike). Redirect /catasto/* on the old server to the subdomain.
UPDATE `fn_settings` SET `varvalue` = '' WHERE `varname` = 'siteurl';

-- 6. Group names in English (upstream 8f47438): grotte_nascoste -> hidden_caves and
--    archeologi -> archaeologists, in the groups, the users, the section and block access and
--    the per-record restrictions (comma separated lists: only whole names are replaced).
--    On the dump: a few users and the fauna_surveys section; no record.
--    catasto_scrittura, fauna and curatori stay as they are: Lombardia's section access is in
--    the database, and no user is in fauna or curatori.
UPDATE `fn_groups` SET `groupname` = 'hidden_caves' WHERE `groupname` = 'grotte_nascoste';
UPDATE `fn_groups` SET `groupname` = 'archaeologists' WHERE `groupname` = 'archeologi';
UPDATE `fn_users` SET `group` = REGEXP_REPLACE(REGEXP_REPLACE(`group`, '(?<=^|,)grotte_nascoste(?=,|$)', 'hidden_caves'), '(?<=^|,)archeologi(?=,|$)', 'archaeologists')
  WHERE `group` REGEXP '(^|,)(grotte_nascoste|archeologi)(,|$)';
UPDATE `fn_sections` SET `group_view` = REGEXP_REPLACE(REGEXP_REPLACE(`group_view`, '(?<=^|,)grotte_nascoste(?=,|$)', 'hidden_caves'), '(?<=^|,)archeologi(?=,|$)', 'archaeologists')
  WHERE `group_view` REGEXP '(^|,)(grotte_nascoste|archeologi)(,|$)';
UPDATE `fn_sections` SET `group_edit` = REGEXP_REPLACE(REGEXP_REPLACE(`group_edit`, '(?<=^|,)grotte_nascoste(?=,|$)', 'hidden_caves'), '(?<=^|,)archeologi(?=,|$)', 'archaeologists')
  WHERE `group_edit` REGEXP '(^|,)(grotte_nascoste|archeologi)(,|$)';
UPDATE `fn_blocks` SET `group_view` = REGEXP_REPLACE(REGEXP_REPLACE(`group_view`, '(?<=^|,)grotte_nascoste(?=,|$)', 'hidden_caves'), '(?<=^|,)archeologi(?=,|$)', 'archaeologists')
  WHERE `group_view` REGEXP '(^|,)(grotte_nascoste|archeologi)(,|$)';
UPDATE `fn_blocks` SET `group_edit` = REGEXP_REPLACE(REGEXP_REPLACE(`group_edit`, '(?<=^|,)grotte_nascoste(?=,|$)', 'hidden_caves'), '(?<=^|,)archeologi(?=,|$)', 'archaeologists')
  WHERE `group_edit` REGEXP '(^|,)(grotte_nascoste|archeologi)(,|$)';
-- records: no Lombardia record is restricted to these groups; for a newer dump, the same
-- UPDATE on `groupview` of ctl_caves, ctl_artificials and the other ctl_ tables.

-- 7. Usernames in lowercase. The login lowercases what the user types, and fn_users.username is
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

-- 8. Public map. The public map and its exports (KML, GPX, JSON, API, WISH) show to users
--    without access to the caves section only the caves with public_map = Y. On Lombardia the
--    data on the public map is public, so every cave without a per-cave group restriction
--    (groupview empty) is set to Y. The caves restricted to a regional group stay hidden.
--    New caves get Y from the form, and an empty value also counts as Y (decided 2026-10-25):
--    a curator sets N only to hide a single cave from the public. This step makes the value
--    explicit. Only unset values are changed, so a later explicit N is kept. Safe to run twice;
--    the column is created here when the web container has not added it yet.
ALTER TABLE `ctl_caves` ADD COLUMN IF NOT EXISTS `public_map` varchar(255) NOT NULL DEFAULT '';
UPDATE `ctl_caves` SET `public_map` = 'Y'
  WHERE (`groupview` = '' OR `groupview` IS NULL) AND (`public_map` = '' OR `public_map` IS NULL);

-- 9. Stock avatars. 21 accounts chose one of the 31 stock avatars (fn_users.avatarimage =
--    avtrNN.png). Upstream finis dropped the stock avatars and their picker in 2024, and the
--    image files are not shipped, so those accounts would show a broken image. Following
--    upstream (decided 2026-10-25), the choice is cleared: they get the default user icon and
--    can upload their own picture. Uploaded avatars (fn_users.avatar) are not touched.
--    Safe to run twice.
UPDATE `fn_users` SET `avatarimage` = '' WHERE `avatarimage` <> '';

-- 10. Karst springs (#77). The section `springs` was created from a stale upstream file (a copy
--     of the artificial cavities' "Configurazione tipologie": table editor under art_categorie,
--     group artificiali_scrittura that does not exist, settings of a file list on fn_files).
--     It becomes the "Sorgenti carsiche" register of the natural caves: records list on
--     ctl_springs, in the "Cavita' naturali" menu after Bibliografia (position 8), run by the
--     natural cave curators with the same groups as the caves (insert: catasto_inserimento,
--     manage: catasto_amministratori, edit per record: the province groups).
--     During development it is open to the natural cave curators only (catasto_amministratori,
--     catasto_inserimento and the province groups), so they can review it; readers and visitors
--     don't see it. An admin changes this later from the section settings ("group_view",
--     empty = everyone).
--     The leftover settings are dropped only while the section is still the old copy, so the
--     step is safe to run twice and keeps later choices of the admins; finis fills in the
--     other settings (search, filters, ordering) from sections/springs/default.xml.php on the
--     first visit.
DELETE FROM `fncf_springs`
 WHERE EXISTS (SELECT 1 FROM `fn_sections` WHERE `id` = 'springs' AND `type` = 'table_editor');
UPDATE `fn_sections`
   SET `type` = 'dbview', `parent` = 'menu_natural', `position` = 8,
       `title` = 'Sorgenti carsiche', `title_it` = 'Sorgenti carsiche',
       `group_view` = 'catasto_amministratori,catasto_inserimento,RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV',
       `group_edit` = 'catasto_amministratori',
       `status` = 1, `hidden` = 0
 WHERE `id` = 'springs' AND `type` = 'table_editor';
INSERT IGNORE INTO `fncf_springs` (`varname`, `varvalue`, `defaultvalue`) VALUES
  ('tables', 'ctl_springs', 'ctl_springs'),
  ('groupinsert', 'catasto_inserimento', ''),
  ('groupadmin', 'catasto_amministratori', ''),
  ('enable_permissions_edit_each_records', '1', '0'),
  ('permissions_records_edit_groups', 'RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV', 'w_caves');

-- 11. Artificial cavities, temporary set-up "as the natural caves" (#78).
--     Until the curators decide otherwise, the
--     section follows the rules of "Database grotte":
--     - readers: the same groups as the caves, plus the artificial-cavity
--       writers; records are no longer public by default;
--     - catasto_inserimento adds records, catasto_amministratori manages them,
--       the province groups RW_* edit the records of their province (the
--       province check is in the Lombardia definition, as for the caves);
--     - "Rilievi" saves into the artificial-cavity survey table, with the
--       rules of the cave surveys;
--     - the two list pages (types, categories) point to their tables and are
--       open to catasto_amministratori, under "Cavità artificiali".
--     The two field names with a space are renamed; their columns were always
--     empty, because those fields were never saved. finis adds the new
--     columns by itself when the new definition is installed, so the step
--     only copies any value left and drops the old columns.
--     Safe to run again.

UPDATE `fn_sections`
   SET `group_view` = 'RW_BS,users,RW_CO_LC_SO_MI_PV,RW_BG,r_fauna,RW_VA,READ_SPELEOPALEO,r_caves,r_artificials,w_artificials',
       `group_edit` = ''
 WHERE `id` = 'artificials';

UPDATE `fncf_artificials` SET `varvalue` = 'catasto_inserimento'    WHERE `varname` = 'groupinsert';
UPDATE `fncf_artificials` SET `varvalue` = 'catasto_amministratori' WHERE `varname` = 'groupadmin';
UPDATE `fncf_artificials` SET `varvalue` = '1' WHERE `varname` IN ('enable_permissions_each_records', 'enable_permissions_edit_each_records', 'default_show_groups');
UPDATE `fncf_artificials` SET `varvalue` = 'RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV' WHERE `varname` IN ('permissions_records_groups', 'permissions_records_edit_groups');
UPDATE `fncf_artificials` SET `varvalue` = 'name,code,synonyms,comune,provincia' WHERE `varname` = 'search_partfields';

UPDATE `fn_sections`
   SET `group_view` = 'RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA,r_caves,r_artificials,w_artificials',
       `group_edit` = 'RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA'
 WHERE `id` = 'survey_artificials';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'ctl_surveys_artificials' WHERE `varname` = 'tables';
UPDATE `fncf_survey_artificials` SET `varvalue` = '' WHERE `varname` IN ('groupinsert', 'groupadmin', 'groupview');
UPDATE `fncf_survey_artificials` SET `varvalue` = '1' WHERE `varname` IN ('enable_permissions_each_records', 'enable_delete');
UPDATE `fncf_survey_artificials` SET `varvalue` = '0' WHERE `varname` IN ('hide_on_delete', 'generate_googlesitemap');
UPDATE `fncf_survey_artificials` SET `varvalue` = 'r_caves,r_artificials,w_artificials,RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA' WHERE `varname` = 'permissions_records_groups';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA' WHERE `varname` = 'permissions_records_edit_groups';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'codeartificial,name' WHERE `varname` = 'titlefield';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'makers' WHERE `varname` = 'descriptionfield';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'author,makers' WHERE `varname` = 'search_options';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'license,codeartificial' WHERE `varname` = 'navigate_groups';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'codeartificial' WHERE `varname` = 'search_fields';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'recordupdate,recordinsert' WHERE `varname` = 'search_orders';
UPDATE `fncf_survey_artificials` SET `varvalue` = 'id' WHERE `varname` = 'defaultorder';

UPDATE `fn_sections`
   SET `parent` = 'menu_artificials', `position` = 24,
       `group_view` = 'catasto_amministratori', `group_edit` = 'catasto_amministratori'
 WHERE `id` = 'art_tipologie';
UPDATE `fn_sections`
   SET `group_view` = 'catasto_amministratori', `group_edit` = 'catasto_amministratori'
 WHERE `id` = 'art_categorie';
INSERT INTO `fncf_art_tipologie` (`varname`, `varvalue`, `defaultvalue`) VALUES ('tablename', 'ctl_art_types', 'ctl_art_types')
  ON DUPLICATE KEY UPDATE `varvalue` = 'ctl_art_types';
INSERT INTO `fncf_art_categorie` (`varname`, `varvalue`, `defaultvalue`) VALUES ('tablename', 'ctl_art_categories', 'ctl_art_categories')
  ON DUPLICATE KEY UPDATE `varvalue` = 'ctl_art_categories';

ALTER TABLE `ctl_artificials` ADD COLUMN IF NOT EXISTS `current_use` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_artificials` ADD COLUMN IF NOT EXISTS `internal_walls` varchar(255) NOT NULL DEFAULT '';
SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'ctl_artificials' AND COLUMN_NAME = 'current use');
SET @q := IF(@c > 0, 'UPDATE `ctl_artificials` SET `current_use` = `current use` WHERE `current_use` = '''' AND `current use` <> ''''', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'ctl_artificials' AND COLUMN_NAME = 'internal walls');
SET @q := IF(@c > 0, 'UPDATE `ctl_artificials` SET `internal_walls` = `internal walls` WHERE `internal_walls` = '''' AND `internal walls` <> ''''', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
ALTER TABLE `ctl_artificials` DROP COLUMN IF EXISTS `current use`;
ALTER TABLE `ctl_artificials` DROP COLUMN IF EXISTS `internal walls`;

-- 12. Users enabled on a single record ("Gestisci gli utenti abilitati alla modifica",
--     table fieldusers). The old table has its key in `unirecid`; the new code keys it on
--     `id` and leaves `unirecid` empty, so every new grant failed with a duplicate key (and
--     so did the grant written for the author of each new record). The existing grants
--     are kept: their number moves from `unirecid` to `id`, which becomes the key.
--     Deploy it together with finis PR #18 (who may enable users on a record).
--     Runs only while `unirecid` exists, so it is safe to run again.
-- the column `id` is added by the new code on its first use; a database fresh from the old
-- dump doesn't have it yet
ALTER TABLE `fieldusers` ADD COLUMN IF NOT EXISTS `id` varchar(255) NOT NULL DEFAULT '';
SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fieldusers' AND COLUMN_NAME = 'unirecid');
SET @m := (SELECT COALESCE(MAX(CAST(`id` AS UNSIGNED)), 0) FROM `fieldusers`);
SET @q := IF(@c > 0, 'SELECT GREATEST(@m, COALESCE(MAX(CAST(`unirecid` AS UNSIGNED)), 0)) INTO @m FROM `fieldusers`', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
-- rows written by the new code (empty unirecid) get a new number after the old ones
SET @q := IF(@c > 0, 'UPDATE `fieldusers` SET `id` = (@m := @m + 1) WHERE `unirecid` = ''''', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
SET @q := IF(@c > 0, 'UPDATE `fieldusers` SET `id` = `unirecid` WHERE `unirecid` <> ''''', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
SET @q := IF(@c > 0, 'ALTER TABLE `fieldusers` DROP PRIMARY KEY, DROP COLUMN `unirecid`, ADD PRIMARY KEY (`id`)', 'DO 0');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

-- Not needed: extra/openkis/update.md (S->Y). The data already uses S/N/X/P, which is what
-- the current definitions expect.

-- 13. Survey dates in the storage format. The date fields now refuse a date that doesn't follow
--    their format (finis#19), and a few old surveys have a date written differently: a year
--    alone becomes the 1st of January of that year, and a date with slashes (YYYY/MM/DD) gets
--    dashes (decided with the admin). Dates already in the YYYY-MM-DD format are not touched.
UPDATE `ctl_surveys` SET `date` = CONCAT(`date`, '-01-01')
 WHERE `date` REGEXP '^[0-9]{4}$';
UPDATE `ctl_surveys` SET `date` = REPLACE(`date`, '/', '-')
 WHERE `date` REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';

-- 14. Column types the code expects, where nothing can be lost (decided with the admin, option C
--    of the column-type review):
--    - latitude/longitude become DOUBLE, as in the table definitions. The old database keeps
--      them as text, the tables created by the code had FLOAT, which rounds the 7 decimals of
--      the cave coordinates (up to about 0.4 m); DOUBLE keeps them. Empty values become NULL.
--      A value that isn't a number stops the update (strict mode) instead of being changed.
--    - the narrow text columns of ctl_caves (code, provincia, regione and three flags) are
--      widened to varchar(255) like the others, ctl_bibliography.modified_surveys to text.
--    Dates stay as text for now; the integer ids and the wider columns are left as they are.
DROP PROCEDURE IF EXISTS `okx_column_types`;
DELIMITER //
CREATE PROCEDURE `okx_column_types`()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE t, c, dt VARCHAR(64);
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME IN ('latitude', 'longitude')
           AND TABLE_NAME IN ('ctl_caves', 'ctl_caves_versions', 'ctl_springs', 'ctl_artificials',
                              'ctl_glacial', 'ctl_glacial_versions')
           AND DATA_TYPE <> 'double';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;
    coords: LOOP
        FETCH cur INTO t, c, dt;
        IF done THEN LEAVE coords; END IF;
        IF dt IN ('varchar', 'char', 'text') THEN
            SET @q := CONCAT('ALTER TABLE `', t, '` MODIFY `', c, '` varchar(255) NULL DEFAULT NULL');
            PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
            SET @q := CONCAT('UPDATE `', t, '` SET `', c, '` = NULL WHERE TRIM(`', c, '`) = ''''');
            PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
        END IF;
        SET @q := CONCAT('ALTER TABLE `', t, '` MODIFY `', c, '` double NULL DEFAULT NULL');
        PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;
SET @okx_sql_mode := @@SESSION.sql_mode;
SET SESSION sql_mode = 'STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION';
CALL `okx_column_types`();
SET SESSION sql_mode = @okx_sql_mode;
DROP PROCEDURE `okx_column_types`;

ALTER TABLE `ctl_caves`
    MODIFY `code` varchar(255) NOT NULL DEFAULT '',
    MODIFY `provincia` varchar(255) NOT NULL DEFAULT '',
    MODIFY `regione` varchar(255) NOT NULL DEFAULT '',
    MODIFY `archeological` varchar(255) NOT NULL DEFAULT '',
    MODIFY `destroyed` varchar(255) NOT NULL DEFAULT '',
    MODIFY `marine` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_bibliography` MODIFY `modified_surveys` text NULL;

-- 15. Survey records of a restricted item (a cave, artificial cavity or glacial cave with its own
--    groupview) get the groupview of that item, so they reach only the item's groups and the
--    administrators. The application keeps them in step from then on (openkis_SyncSurveyGroups).
--    Surveys of items without a restriction are not touched.
UPDATE `ctl_surveys` s JOIN `ctl_caves` c ON c.`code` = s.`codecave`
   SET s.`groupview` = c.`groupview`
 WHERE c.`groupview` <> '' AND NOT (s.`groupview` <=> c.`groupview`);
UPDATE `ctl_surveys_artificials` s JOIN `ctl_artificials` a ON a.`code` = s.`codeartificial`
   SET s.`groupview` = a.`groupview`
 WHERE a.`groupview` <> '' AND NOT (s.`groupview` <=> a.`groupview`);
-- Glacial caves only where the database has them (the Lombardia schema has no glacial tables;
--    an UPDATE of a missing table would fail and stop the later updates).
SET @okx_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()
                     AND table_name IN ('ctl_surveys_glacial', 'ctl_glacial')) = 2,
  'UPDATE `ctl_surveys_glacial` s JOIN `ctl_glacial` g ON g.`code` = s.`codeglacial`
      SET s.`groupview` = g.`groupview`
    WHERE g.`groupview` <> \'\' AND NOT (s.`groupview` <=> g.`groupview`)',
  'DO 0');
PREPARE okx_stmt FROM @okx_sql;
EXECUTE okx_stmt;
DEALLOCATE PREPARE okx_stmt;

-- 16. Bibliography link table (#20, openkis update 013): the cave pages find the bibliography
--    items of a cave in ctl_bibliography_links instead of scanning codecaves. Created empty; the
--    application fills it on the first cave page view and rebuilds it when the bibliography changes.
CREATE TABLE IF NOT EXISTS `ctl_bibliography_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bibliography_id` varchar(255) NOT NULL DEFAULT '',
  `linkfield` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_bin;
CREATE INDEX IF NOT EXISTS `okx_linkfield_code` ON `ctl_bibliography_links` (`linkfield`, `code`);

-- 17. Cave-system development (#75, #76; openkis update 014): lenght_scope on the caves and their
--     history, lenght_auto on the systems, and the old SVILRE/DTOT figures copied into the empty
--     lenght_total/depth_total of the systems. Values already set are not touched.
ALTER TABLE `ctl_caves` ADD COLUMN IF NOT EXISTS `lenght_scope` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_caves_versions` ADD COLUMN IF NOT EXISTS `lenght_scope` varchar(255) NOT NULL DEFAULT '';
ALTER TABLE `ctl_cavesystems` ADD COLUMN IF NOT EXISTS `lenght_auto` varchar(255) NOT NULL DEFAULT '';
UPDATE `ctl_cavesystems` SET `lenght_total` = TRIM(`SVILRE`)
 WHERE (`lenght_total` IS NULL OR TRIM(`lenght_total`) = '') AND TRIM(`SVILRE`) REGEXP '^[0-9]+$';
UPDATE `ctl_cavesystems` SET `depth_total` = TRIM(`DTOT`)
 WHERE (`depth_total` IS NULL OR TRIM(`depth_total`) = '') AND TRIM(`DTOT`) REGEXP '^[0-9]+$';
