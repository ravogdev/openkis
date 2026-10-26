-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Survey dates in the storage format. The date fields now refuse a date that doesn't follow
--    their format (finis#19), and a few old surveys have a date written differently: a year
--    alone becomes the 1st of January of that year, and a date with slashes (YYYY/MM/DD) gets
--    dashes (decided with the admin). Dates already in the YYYY-MM-DD format are not touched.
UPDATE `ctl_surveys` SET `date` = CONCAT(`date`, '-01-01')
 WHERE `date` REGEXP '^[0-9]{4}$';
UPDATE `ctl_surveys` SET `date` = REPLACE(`date`, '/', '-')
 WHERE `date` REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';
