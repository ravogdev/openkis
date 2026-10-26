-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Artificial cavities, temporary set-up "as the natural caves" (#78).
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
