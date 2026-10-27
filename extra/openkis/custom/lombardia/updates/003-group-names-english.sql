-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Group names in English (upstream 8f47438): grotte_nascoste -> hidden_caves and
--    archeologi -> archaeologists, in the groups, the users, the section and block access and
--    the per-record restrictions (comma separated lists: only whole names are replaced).
--    On the dump: 2 users (admin, testspeleo2) and the fauna_surveys section; no record.
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
