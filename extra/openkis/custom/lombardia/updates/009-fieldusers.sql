-- Lombardia database update, applied once by the container entrypoint.
-- Same as the step of lombardia-migrate.sql; safe on a database where it already ran.
-- Users enabled on a single record ("Gestisci gli utenti abilitati alla modifica",
--     table fieldusers). The old table has its key in `unirecid`; the new code keys it on
--     `id` and leaves `unirecid` empty, so every new grant failed with a duplicate key (and
--     so did the grant written for the author of each new record). The existing grants
--     are kept: their number moves from `unirecid` to `id`, which becomes the key.
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
