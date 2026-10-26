-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Karst springs (#77). The section `springs` was created from a stale upstream file (a copy
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
