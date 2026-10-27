-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Column types the code expects, where nothing can be lost (decided with the admin, option C
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
