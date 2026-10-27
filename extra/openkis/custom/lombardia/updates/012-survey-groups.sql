-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Survey records of a restricted item (a cave, artificial cavity or glacial cave with its own
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
