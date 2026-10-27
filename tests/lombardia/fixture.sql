-- Lombardia migration test fixture, made by tests/lombardia/make-fixture.sh:
-- the old site's tables without their rows, and its settings with the secrets blanked.
-- No data of the site. Used by tests/lombardia/migration-test.sh.

DROP TABLE IF EXISTS `SPELEOPALEO`;
CREATE TABLE `SPELEOPALEO` (
  `NUM` varchar(255) NOT NULL DEFAULT '',
  `formazione_geologica` varchar(255) NOT NULL DEFAULT '',
  `presenza_fossili` varchar(255) NOT NULL DEFAULT '',
  `matrice` varchar(255) NOT NULL DEFAULT '',
  `varietà_fossili_in_roccia` varchar(255) NOT NULL DEFAULT '',
  `quantità_fossili_in_roccia` varchar(255) NOT NULL DEFAULT '',
  `distribuzione_fossili_in_roccia` varchar(255) NOT NULL DEFAULT '',
  `varietà_fossili_in_sedimenti` varchar(255) NOT NULL DEFAULT '',
  `quantità_fossili_in_sedimenti` varchar(255) NOT NULL DEFAULT '',
  `distribuzione_fossili_in_sedimenti` varchar(255) NOT NULL DEFAULT '',
  `interesse_antropologico` varchar(255) NOT NULL DEFAULT '',
  `fotografie` varchar(255) NOT NULL DEFAULT '',
  `bibliografia` varchar(255) NOT NULL DEFAULT '',
  `nome_segnalatore` varchar(255) NOT NULL DEFAULT '',
  `osservazioni` varchar(255) NOT NULL DEFAULT '',
  `crinoidi` varchar(255) NOT NULL DEFAULT '',
  `ammoniti` varchar(255) NOT NULL DEFAULT '',
  `gasteropodi` varchar(255) NOT NULL DEFAULT '',
  `conchiglie` varchar(255) NOT NULL DEFAULT '',
  `ossa` varchar(255) NOT NULL DEFAULT '',
  `belemniti` varchar(255) NOT NULL DEFAULT '',
  `tracce_di_organismi` varchar(255) NOT NULL DEFAULT '',
  `altro` varchar(255) NOT NULL DEFAULT '',
  `ossa_lunghe` varchar(255) NOT NULL DEFAULT '',
  `ossa_piatte` varchar(255) NOT NULL DEFAULT '',
  `tipo_fossili__in_sedimenti_descriz` varchar(255) NOT NULL DEFAULT '',
  `tipo_fossili_in_roccia_descriz` varchar(255) NOT NULL DEFAULT '',
  `denti` varchar(255) NOT NULL DEFAULT '',
  `coralli` varchar(255) NOT NULL DEFAULT '',
  `schede_info` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `PREIMPORT` text NOT NULL,
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`NUM`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `SPELEOPALEO` DISABLE KEYS */;
/*!40000 ALTER TABLE `SPELEOPALEO` ENABLE KEYS */;
DROP TABLE IF EXISTS `VECCHIO_CART`;
CREATE TABLE `VECCHIO_CART` (
  `ID` bigint(20) NOT NULL,
  `NUMCAVE` varchar(255) NOT NULL,
  `NAME` varchar(255) NOT NULL,
  `CART` varchar(255) NOT NULL,
  `DATE` varchar(255) NOT NULL,
  `recordinsert` varchar(255) NOT NULL,
  `AUTHOR` varchar(255) NOT NULL,
  `LICENSE` varchar(255) NOT NULL,
  `DESC` text NOT NULL,
  `FILE` varchar(255) NOT NULL,
  `FILEDWG` varchar(255) NOT NULL,
  `FILEKML` varchar(255) NOT NULL,
  `PRECISIONE` varchar(255) NOT NULL,
  `MAKERS` text NOT NULL,
  `PDF` varchar(255) NOT NULL,
  `groupview` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `userupdate` varchar(255) NOT NULL,
  `recordupdate` varchar(255) NOT NULL,
  `NUMSYSTEM` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `NUMCAVE` (`NUMCAVE`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

/*!40000 ALTER TABLE `VECCHIO_CART` DISABLE KEYS */;
/*!40000 ALTER TABLE `VECCHIO_CART` ENABLE KEYS */;
DROP TABLE IF EXISTS `____empty_____`;
CREATE TABLE `____empty_____` (
  `name` varchar(255) NOT NULL,
  `primarykey` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(255) NOT NULL DEFAULT '',
  `extra` varchar(255) NOT NULL DEFAULT '',
  `size` varchar(255) NOT NULL DEFAULT '',
  `frm_type` varchar(255) NOT NULL DEFAULT '',
  `frm_options` text NOT NULL,
  `frm_retype` varchar(255) NOT NULL DEFAULT '',
  `frm_show` varchar(255) NOT NULL DEFAULT '',
  `frm_default` text NOT NULL,
  `frm_validator` varchar(255) NOT NULL DEFAULT '',
  `frm_allowupdate` varchar(255) NOT NULL DEFAULT '',
  `frm_multilanguage` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `____empty_____` DISABLE KEYS */;
/*!40000 ALTER TABLE `____empty_____` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_age`;
CREATE TABLE `ctl_age` (
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

/*!40000 ALTER TABLE `ctl_age` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_age` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_areas`;
CREATE TABLE `ctl_areas` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(255) NOT NULL DEFAULT '',
  `provincia` varchar(255) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `associations` text NOT NULL,
  `surface` varchar(255) NOT NULL DEFAULT '',
  `cities` varchar(255) NOT NULL DEFAULT '',
  `mountaincommunity` varchar(255) NOT NULL DEFAULT '',
  `watershed` varchar(255) NOT NULL DEFAULT '',
  `activequarries` varchar(255) NOT NULL DEFAULT '',
  `inactivequarries` varchar(255) NOT NULL DEFAULT '',
  `activelandfills` varchar(255) NOT NULL DEFAULT '',
  `inactivelandfills` varchar(255) NOT NULL DEFAULT '',
  `lithological` text NOT NULL,
  `geomorphology` text NOT NULL,
  `hydrogeological` text NOT NULL,
  `caving` text NOT NULL,
  `landcover` text NOT NULL,
  `othercharacteristics` text NOT NULL,
  `aquifers` text NOT NULL,
  `notes` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `authors` varchar(255) NOT NULL DEFAULT '',
  `bibliography` text NOT NULL,
  `geographical_framework` text NOT NULL,
  `geological_framework` text NOT NULL,
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `code` (`code`),
  KEY `provincia` (`provincia`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_areas` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_areas` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_art_categories`;
CREATE TABLE `ctl_art_categories` (
  `code` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_art_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_art_categories` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_art_types`;
CREATE TABLE `ctl_art_types` (
  `code` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_art_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_art_types` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_artificials`;
CREATE TABLE `ctl_artificials` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `synonyms` varchar(255) NOT NULL DEFAULT '',
  `caveslinks` varchar(255) NOT NULL DEFAULT '',
  `firstreference` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(255) NOT NULL DEFAULT '',
  `provincia` varchar(255) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `localita` varchar(255) NOT NULL DEFAULT '',
  `address` text NOT NULL,
  `year` varchar(255) NOT NULL DEFAULT '',
  `epoch` varchar(255) NOT NULL DEFAULT '',
  `typology` varchar(255) NOT NULL DEFAULT '',
  `category` varchar(255) NOT NULL DEFAULT '',
  `geologicalformation` varchar(255) NOT NULL DEFAULT '',
  `lenght_total` varchar(255) NOT NULL DEFAULT '',
  `lenght_planimetric` varchar(255) NOT NULL DEFAULT '',
  `lenght_extension` varchar(255) NOT NULL DEFAULT '',
  `depth_positive` varchar(255) NOT NULL DEFAULT '',
  `depth_negative` varchar(255) NOT NULL DEFAULT '',
  `depth_total` varchar(255) NOT NULL DEFAULT '',
  `latitude_txt` varchar(255) NOT NULL DEFAULT '',
  `longitude_txt` varchar(255) NOT NULL DEFAULT '',
  `coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `original_coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `elevation` varchar(255) NOT NULL DEFAULT '',
  `elevation_map` varchar(255) NOT NULL DEFAULT '',
  `elevation_gps` varchar(255) NOT NULL DEFAULT '',
  `map_denomination` varchar(255) NOT NULL DEFAULT '',
  `map_edition` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation` varchar(255) NOT NULL DEFAULT '',
  `archeological` varchar(255) NOT NULL DEFAULT '',
  `marine` varchar(255) NOT NULL DEFAULT '',
  `lake` varchar(255) NOT NULL DEFAULT '',
  `environmentalrisk` varchar(255) NOT NULL DEFAULT '',
  `closed` varchar(255) NOT NULL DEFAULT '',
  `closed_notes` text NOT NULL,
  `destroyed` varchar(255) NOT NULL DEFAULT '',
  `check` varchar(255) NOT NULL DEFAULT '',
  `check_date` varchar(255) NOT NULL DEFAULT '',
  `hydrology` varchar(255) NOT NULL DEFAULT '',
  `trend` varchar(255) NOT NULL DEFAULT '',
  `practicability` varchar(255) NOT NULL DEFAULT '',
  `associations` text NOT NULL,
  `chronology` text NOT NULL,
  `notes` text NOT NULL,
  `description` text NOT NULL,
  `itinerary` text NOT NULL,
  `wells` text NOT NULL,
  `history` text NOT NULL,
  `fauna` text NOT NULL,
  `meteorology` varchar(255) NOT NULL DEFAULT '',
  `hidden` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `noteversione` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `latitude` varchar(255) NOT NULL DEFAULT '',
  `longitude` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  `coordnatesupdated` varchar(255) NOT NULL DEFAULT '',
  `recorddeleted` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_artificials` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_artificials` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_associations`;
CREATE TABLE `ctl_associations` (
  `name` varchar(255) NOT NULL,
  `acronym` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `provincia` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

/*!40000 ALTER TABLE `ctl_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_associations` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_attachments`;
CREATE TABLE `ctl_attachments` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `codecave` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `file` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_attachments` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_attachments_download_stat`;
CREATE TABLE `ctl_attachments_download_stat` (
  `filename` varchar(255) NOT NULL,
  `numdownload` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_attachments_download_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_attachments_download_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_attachments_stat`;
CREATE TABLE `ctl_attachments_stat` (
  `unirecid` varchar(255) NOT NULL,
  `view` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`unirecid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_attachments_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_attachments_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_bibliograpy`;
CREATE TABLE `ctl_bibliograpy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `magazine` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `photo1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `authors` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `Editore` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `year` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `number` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `pages` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `zone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `codecaves` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `codeartificials` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `abstract` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `surveys` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `photos` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `drawings` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `fossils` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `topic` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `modified_caves` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `fauna` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `modified_surveys` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `doi` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `groupview` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `file1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `license` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `file2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `file3` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `userupdate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `recordinsert` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `recordupdate` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

/*!40000 ALTER TABLE `ctl_bibliograpy` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_bibliograpy` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_bibliograpy_download_stat`;
CREATE TABLE `ctl_bibliograpy_download_stat` (
  `filename` varchar(255) NOT NULL,
  `numdownload` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_bibliograpy_download_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_bibliograpy_download_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_caves`;
CREATE TABLE `ctl_caves` (
  `id` float NOT NULL DEFAULT 0,
  `code` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `synonyms` varchar(255) NOT NULL DEFAULT '',
  `caveslinks` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(255) NOT NULL DEFAULT '',
  `firstreference` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(10) NOT NULL DEFAULT '',
  `provincia` varchar(10) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `localita` varchar(255) NOT NULL DEFAULT '',
  `mount` varchar(255) NOT NULL DEFAULT '',
  `velley` varchar(255) NOT NULL DEFAULT '',
  `areas` varchar(255) NOT NULL DEFAULT '',
  `geologicalformation` varchar(255) NOT NULL DEFAULT '',
  `lithology` varchar(255) NOT NULL DEFAULT '',
  `lenght_total` varchar(255) NOT NULL DEFAULT '',
  `lenght_planimetric` varchar(255) NOT NULL DEFAULT '',
  `lenght_extension` varchar(255) NOT NULL DEFAULT '',
  `depth_positive` varchar(255) NOT NULL DEFAULT '',
  `depth_negative` varchar(255) NOT NULL DEFAULT '',
  `depth_total` varchar(255) NOT NULL DEFAULT '',
  `latitude_txt` varchar(255) NOT NULL DEFAULT '',
  `longitude_txt` varchar(255) NOT NULL DEFAULT '',
  `coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `original_coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `elevation` varchar(255) NOT NULL DEFAULT '',
  `elevation_map` varchar(255) NOT NULL DEFAULT '',
  `elevation_gps` varchar(255) NOT NULL DEFAULT '',
  `map_denomination` varchar(255) NOT NULL DEFAULT '',
  `map_edition` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation` varchar(255) NOT NULL DEFAULT '',
  `archeological` varchar(3) NOT NULL DEFAULT '',
  `marine` varchar(3) NOT NULL DEFAULT '',
  `lake` varchar(255) NOT NULL DEFAULT '',
  `environmentalrisk` varchar(255) NOT NULL DEFAULT '',
  `tourist` varchar(255) NOT NULL DEFAULT '',
  `closed` varchar(255) NOT NULL DEFAULT '',
  `closed_notes` text NOT NULL,
  `destroyed` varchar(3) NOT NULL DEFAULT '',
  `check` varchar(255) NOT NULL DEFAULT '',
  `check_date` varchar(255) NOT NULL DEFAULT '',
  `hydrology` varchar(255) NOT NULL DEFAULT '',
  `trend` varchar(255) NOT NULL DEFAULT '',
  `practicability` varchar(255) NOT NULL DEFAULT '',
  `associations` text NOT NULL,
  `chronology` text NOT NULL,
  `notes` text NOT NULL,
  `description` text NOT NULL,
  `itinerary` text NOT NULL,
  `wells` text NOT NULL,
  `fauna` text NOT NULL,
  `meteorology` varchar(255) NOT NULL DEFAULT '',
  `geology` text NOT NULL,
  `history` text NOT NULL,
  `changelog` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `authordescription` varchar(255) NOT NULL DEFAULT '',
  `authoritinerary` varchar(255) NOT NULL DEFAULT '',
  `authorfauna` varchar(255) NOT NULL DEFAULT '',
  `authorhistory` varchar(255) NOT NULL DEFAULT '',
  `import_rawdata` text NOT NULL,
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  `latitude` varchar(255) NOT NULL DEFAULT '',
  `longitude` varchar(255) NOT NULL DEFAULT '',
  `coordnatesupdated` varchar(255) NOT NULL DEFAULT '',
  `recorddeleted` varchar(255) NOT NULL DEFAULT '',
  `code_fslo` varchar(255) NOT NULL DEFAULT '',
  `age` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation_options` varchar(255) NOT NULL DEFAULT '',
  `DATAGG` varchar(255) NOT NULL DEFAULT '',
  `COD` varchar(255) DEFAULT NULL,
  `practicability_text` text DEFAULT NULL,
  `meteorology_text` text DEFAULT NULL,
  `to_check` varchar(255) DEFAULT NULL,
  `groupview_bk` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `areas` (`areas`),
  KEY `comune` (`comune`),
  KEY `code` (`code`),
  KEY `provincia` (`provincia`),
  KEY `to_check` (`to_check`),
  KEY `groupview` (`groupview`),
  KEY `recorddeleted` (`recorddeleted`),
  KEY `recordupdate` (`recordupdate`),
  KEY `country` (`country`),
  KEY `regione` (`regione`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_caves` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_caves` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_caves_bk_2024_05_01`;
CREATE TABLE `ctl_caves_bk_2024_05_01` (
  `id` float NOT NULL DEFAULT 0,
  `code` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `synonyms` varchar(255) NOT NULL DEFAULT '',
  `caveslinks` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(255) NOT NULL DEFAULT '',
  `firstreference` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(10) NOT NULL DEFAULT '',
  `provincia` varchar(10) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `localita` varchar(255) NOT NULL DEFAULT '',
  `mount` varchar(255) NOT NULL DEFAULT '',
  `velley` varchar(255) NOT NULL DEFAULT '',
  `areas` varchar(255) NOT NULL DEFAULT '',
  `geologicalformation` varchar(255) NOT NULL DEFAULT '',
  `lithology` varchar(255) NOT NULL DEFAULT '',
  `lenght_total` varchar(255) NOT NULL DEFAULT '',
  `lenght_planimetric` varchar(255) NOT NULL DEFAULT '',
  `lenght_extension` varchar(255) NOT NULL DEFAULT '',
  `depth_positive` varchar(255) NOT NULL DEFAULT '',
  `depth_negative` varchar(255) NOT NULL DEFAULT '',
  `depth_total` varchar(255) NOT NULL DEFAULT '',
  `latitude_txt` varchar(255) NOT NULL DEFAULT '',
  `longitude_txt` varchar(255) NOT NULL DEFAULT '',
  `coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `original_coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `elevation` varchar(255) NOT NULL DEFAULT '',
  `elevation_map` varchar(255) NOT NULL DEFAULT '',
  `elevation_gps` varchar(255) NOT NULL DEFAULT '',
  `map_denomination` varchar(255) NOT NULL DEFAULT '',
  `map_edition` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation` varchar(255) NOT NULL DEFAULT '',
  `archeological` varchar(3) NOT NULL DEFAULT '',
  `marine` varchar(3) NOT NULL DEFAULT '',
  `lake` varchar(255) NOT NULL DEFAULT '',
  `environmentalrisk` varchar(255) NOT NULL DEFAULT '',
  `tourist` varchar(255) NOT NULL DEFAULT '',
  `closed` varchar(255) NOT NULL DEFAULT '',
  `closed_notes` text NOT NULL,
  `destroyed` varchar(3) NOT NULL DEFAULT '',
  `check` varchar(255) NOT NULL DEFAULT '',
  `check_date` varchar(255) NOT NULL DEFAULT '',
  `hydrology` varchar(255) NOT NULL DEFAULT '',
  `trend` varchar(255) NOT NULL DEFAULT '',
  `practicability` varchar(255) NOT NULL DEFAULT '',
  `associations` text NOT NULL,
  `chronology` text NOT NULL,
  `notes` text NOT NULL,
  `description` text NOT NULL,
  `itinerary` text NOT NULL,
  `wells` text NOT NULL,
  `fauna` text NOT NULL,
  `meteorology` varchar(255) NOT NULL DEFAULT '',
  `geology` text NOT NULL,
  `history` text NOT NULL,
  `changelog` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `authordescription` varchar(255) NOT NULL DEFAULT '',
  `authoritinerary` varchar(255) NOT NULL DEFAULT '',
  `authorfauna` varchar(255) NOT NULL DEFAULT '',
  `authorhistory` varchar(255) NOT NULL DEFAULT '',
  `import_rawdata` text NOT NULL,
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  `latitude` varchar(255) NOT NULL DEFAULT '',
  `longitude` varchar(255) NOT NULL DEFAULT '',
  `coordnatesupdated` varchar(255) NOT NULL DEFAULT '',
  `recorddeleted` varchar(255) NOT NULL DEFAULT '',
  `code_fslo` varchar(255) NOT NULL DEFAULT '',
  `age` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation_options` varchar(255) NOT NULL DEFAULT '',
  `DATAGG` varchar(255) NOT NULL DEFAULT '',
  `COD` varchar(255) DEFAULT NULL,
  `practicability_text` text DEFAULT NULL,
  `meteorology_text` text DEFAULT NULL,
  `to_check` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `areas` (`areas`),
  KEY `comune` (`comune`),
  KEY `code` (`code`),
  KEY `provincia` (`provincia`),
  KEY `to_check` (`to_check`),
  KEY `groupview` (`groupview`),
  KEY `recorddeleted` (`recorddeleted`),
  KEY `recordupdate` (`recordupdate`),
  KEY `country` (`country`),
  KEY `regione` (`regione`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_caves_bk_2024_05_01` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_caves_bk_2024_05_01` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_caves_rules`;
CREATE TABLE `ctl_caves_rules` (
  `rule` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `query` varchar(255) NOT NULL DEFAULT '',
  `function` varchar(255) NOT NULL DEFAULT '',
  `title_it` varchar(255) NOT NULL DEFAULT '',
  `title_en` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`rule`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_caves_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_caves_rules` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_caves_stat`;
CREATE TABLE `ctl_caves_stat` (
  `unirecid` varchar(255) NOT NULL,
  `view` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`unirecid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_caves_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_caves_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_caves_versions`;
CREATE TABLE `ctl_caves_versions` (
  `idversions` varchar(255) NOT NULL DEFAULT '',
  `id` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `synonyms` varchar(255) NOT NULL DEFAULT '',
  `caveslinks` varchar(255) NOT NULL DEFAULT '',
  `firstreference` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(255) NOT NULL DEFAULT '',
  `provincia` varchar(255) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `localita` varchar(255) NOT NULL DEFAULT '',
  `mount` varchar(255) NOT NULL DEFAULT '',
  `velley` varchar(255) NOT NULL DEFAULT '',
  `areas` varchar(255) NOT NULL DEFAULT '',
  `geologicalformation` varchar(255) NOT NULL DEFAULT '',
  `lenght_total` varchar(255) NOT NULL DEFAULT '',
  `lenght_planimetric` varchar(255) NOT NULL DEFAULT '',
  `lenght_extension` varchar(255) NOT NULL DEFAULT '',
  `depth_positive` varchar(255) NOT NULL DEFAULT '',
  `depth_negative` varchar(255) NOT NULL DEFAULT '',
  `depth_total` varchar(255) NOT NULL DEFAULT '',
  `coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `latitude_txt` varchar(255) NOT NULL DEFAULT '',
  `longitude_txt` varchar(255) NOT NULL DEFAULT '',
  `original_coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `elevation` varchar(255) NOT NULL DEFAULT '',
  `elevation_map` varchar(255) NOT NULL DEFAULT '',
  `elevation_gps` varchar(255) NOT NULL DEFAULT '',
  `map_denomination` varchar(255) NOT NULL DEFAULT '',
  `map_edition` varchar(255) NOT NULL DEFAULT '',
  `location_evaluation` varchar(255) NOT NULL DEFAULT '',
  `archeological` varchar(255) NOT NULL DEFAULT '',
  `marine` varchar(255) NOT NULL DEFAULT '',
  `lake` varchar(255) NOT NULL DEFAULT '',
  `environmentalrisk` varchar(255) NOT NULL DEFAULT '',
  `closed` varchar(255) NOT NULL DEFAULT '',
  `closed_notes` text NOT NULL,
  `destroyed` varchar(255) NOT NULL DEFAULT '',
  `check` varchar(255) NOT NULL DEFAULT '',
  `check_date` varchar(255) NOT NULL DEFAULT '',
  `hydrology` varchar(255) NOT NULL DEFAULT '',
  `trend` varchar(255) NOT NULL DEFAULT '',
  `practicability` varchar(255) NOT NULL DEFAULT '',
  `associations` text NOT NULL,
  `chronology` text NOT NULL,
  `notes` text NOT NULL,
  `description` text NOT NULL,
  `itinerary` text NOT NULL,
  `wells` text NOT NULL,
  `fauna` text NOT NULL,
  `meteorology` varchar(255) NOT NULL DEFAULT '',
  `geology` text NOT NULL,
  `history` text NOT NULL,
  `hidden` varchar(255) NOT NULL DEFAULT '',
  `changelog` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `authordescription` varchar(255) NOT NULL DEFAULT '',
  `authoritinerary` varchar(255) NOT NULL DEFAULT '',
  `authorfauna` varchar(255) NOT NULL DEFAULT '',
  `authorhistory` varchar(255) NOT NULL DEFAULT '',
  `import_rawdata` text NOT NULL,
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  `latitude` varchar(255) NOT NULL DEFAULT '',
  `longitude` varchar(255) NOT NULL DEFAULT '',
  `coordnatesupdated` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`idversions`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_caves_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_caves_versions` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_cavesystems`;
CREATE TABLE `ctl_cavesystems` (
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `COLL` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `recordinsert` varchar(255) NOT NULL,
  `recordupdate` varchar(255) NOT NULL,
  `view` varchar(255) NOT NULL,
  `groupview` varchar(255) NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `NUM` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `photo1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `authorphoto1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `PROV` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `ACARCOD` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `SVILRE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `DTOT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `areas` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `lenght_total` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `depth_total` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `caves` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`NUM`),
  UNIQUE KEY `NUM` (`NUM`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

/*!40000 ALTER TABLE `ctl_cavesystems` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_cavesystems` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_coordinatestypes`;
CREATE TABLE `ctl_coordinatestypes` (
  `coordinates_type` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `proj4` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`coordinates_type`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

/*!40000 ALTER TABLE `ctl_coordinatestypes` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_coordinatestypes` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_fauna`;
CREATE TABLE `ctl_fauna` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `scientific_name` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `sinon` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(255) NOT NULL DEFAULT '',
  `phylum` varchar(255) NOT NULL DEFAULT '',
  `class` varchar(255) NOT NULL DEFAULT '',
  `order` varchar(255) NOT NULL DEFAULT '',
  `family` varchar(255) NOT NULL DEFAULT '',
  `genus` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `photo2` varchar(255) NOT NULL DEFAULT '',
  `authorphoto2` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `groupinsert` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_fauna` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_fauna` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_faunacave`;
CREATE TABLE `ctl_faunacave` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `codecave` varchar(255) NOT NULL DEFAULT '',
  `codeartificial` varchar(255) NOT NULL DEFAULT '',
  `ammount` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authorphoto1` varchar(255) NOT NULL DEFAULT '',
  `photo2` varchar(255) NOT NULL DEFAULT '',
  `authorphoto2` varchar(255) NOT NULL DEFAULT '',
  `date` varchar(255) NOT NULL DEFAULT '',
  `caver` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_faunacave` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_faunacave` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_geologicalformations`;
CREATE TABLE `ctl_geologicalformations` (
  `code` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_geologicalformations` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_geologicalformations` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_licenses`;
CREATE TABLE `ctl_licenses` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `license` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_licenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_licenses` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_photos`;
CREATE TABLE `ctl_photos` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `codecave` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `photo` varchar(255) NOT NULL DEFAULT '',
  `date` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(255) NOT NULL DEFAULT '',
  `license` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `priority` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `codecave` (`codecave`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_photos` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_photos` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_photos_stat`;
CREATE TABLE `ctl_photos_stat` (
  `unirecid` varchar(255) NOT NULL,
  `view` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`unirecid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_photos_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_photos_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_springs`;
CREATE TABLE `ctl_springs` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `codecave` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `synonyms` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(255) NOT NULL DEFAULT '',
  `regione` varchar(255) NOT NULL DEFAULT '',
  `provincia` varchar(255) NOT NULL DEFAULT '',
  `comune` varchar(255) NOT NULL DEFAULT '',
  `localita` varchar(255) NOT NULL DEFAULT '',
  `areas` varchar(255) NOT NULL DEFAULT '',
  `latitude_txt` varchar(255) NOT NULL DEFAULT '',
  `longitude_txt` varchar(255) NOT NULL DEFAULT '',
  `coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `original_coordinates_type` varchar(255) NOT NULL DEFAULT '',
  `elevation` varchar(255) NOT NULL DEFAULT '',
  `elevation_map` varchar(255) NOT NULL DEFAULT '',
  `elevation_gps` varchar(255) NOT NULL DEFAULT '',
  `map_denomination` varchar(255) NOT NULL DEFAULT '',
  `map_edition` varchar(255) NOT NULL DEFAULT '',
  `flow_max` varchar(255) NOT NULL DEFAULT '',
  `flow_min` varchar(255) NOT NULL DEFAULT '',
  `flow_average` varchar(255) NOT NULL DEFAULT '',
  `use` varchar(255) NOT NULL DEFAULT '',
  `utilization` varchar(255) NOT NULL DEFAULT '',
  `hydrology` varchar(255) NOT NULL DEFAULT '',
  `hydrogeology` varchar(255) NOT NULL DEFAULT '',
  `morphology` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `itinerary` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `authordescription` varchar(255) NOT NULL DEFAULT '',
  `authoritinerary` varchar(255) NOT NULL DEFAULT '',
  `latitude` varchar(255) NOT NULL DEFAULT '',
  `longitude` varchar(255) NOT NULL DEFAULT '',
  `coordnatesupdated` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `import_rawdata` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_springs` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_springs` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_surveys`;
CREATE TABLE `ctl_surveys` (
  `id` int(11) NOT NULL,
  `codecave` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `file` varchar(255) NOT NULL DEFAULT '',
  `filekml` varchar(255) NOT NULL DEFAULT '',
  `filepdf` varchar(255) NOT NULL DEFAULT '',
  `date` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(255) NOT NULL DEFAULT '',
  `makers` text NOT NULL,
  `license` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `accuracy` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `priority` int(11) NOT NULL DEFAULT 0,
  `codesystem` varchar(255) DEFAULT NULL,
  `filelox` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `codecave` (`codecave`),
  KEY `groupview` (`groupview`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_surveys` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_surveys` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_surveys_artificials`;
CREATE TABLE `ctl_surveys_artificials` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `codeartificial` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `file` varchar(255) NOT NULL DEFAULT '',
  `filedwg` varchar(255) NOT NULL DEFAULT '',
  `filekml` varchar(255) NOT NULL DEFAULT '',
  `pdf` varchar(255) NOT NULL DEFAULT '',
  `date` varchar(255) NOT NULL DEFAULT '',
  `author` varchar(255) NOT NULL DEFAULT '',
  `makers` text NOT NULL,
  `license` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `priority` int(11) NOT NULL DEFAULT 0,
  `accuracy` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `userupdate` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_surveys_artificials` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_surveys_artificials` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_surveys_download_stat`;
CREATE TABLE `ctl_surveys_download_stat` (
  `filename` varchar(255) NOT NULL,
  `numdownload` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_surveys_download_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_surveys_download_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_surveys_stat`;
CREATE TABLE `ctl_surveys_stat` (
  `unirecid` varchar(255) NOT NULL,
  `view` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`unirecid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_surveys_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_surveys_stat` ENABLE KEYS */;
DROP TABLE IF EXISTS `ctl_walls`;
CREATE TABLE `ctl_walls` (
  `id` varchar(255) NOT NULL,
  `walls` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `ctl_walls` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctl_walls` ENABLE KEYS */;
DROP TABLE IF EXISTS `extra_s_openkis`;
CREATE TABLE `extra_s_openkis` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `extra_s_openkis` DISABLE KEYS */;
INSERT INTO `extra_s_openkis` VALUES ('default_latitude','45,8','44');
INSERT INTO `extra_s_openkis` VALUES ('default_longitude','9.5','8');
INSERT INTO `extra_s_openkis` VALUES ('default_zoom','8','8');
/*!40000 ALTER TABLE `extra_s_openkis` ENABLE KEYS */;
DROP TABLE IF EXISTS `fieldusers`;
CREATE TABLE `fieldusers` (
  `unirecid` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL DEFAULT '',
  `tablename` varchar(255) NOT NULL DEFAULT '',
  `table_unirecid` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`unirecid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fieldusers` DISABLE KEYS */;
/*!40000 ALTER TABLE `fieldusers` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_avatars`;
CREATE TABLE `fn_avatars` (
  `filename` varchar(255) NOT NULL,
  PRIMARY KEY (`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_avatars` DISABLE KEYS */;
/*!40000 ALTER TABLE `fn_avatars` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_blocks`;
CREATE TABLE `fn_blocks` (
  `id` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `position` varchar(255) NOT NULL DEFAULT '',
  `where` varchar(255) NOT NULL DEFAULT '',
  `hidetitle` varchar(255) NOT NULL DEFAULT '',
  `startdate` varchar(255) NOT NULL DEFAULT '',
  `enddate` varchar(255) NOT NULL DEFAULT '',
  `status` varchar(255) NOT NULL DEFAULT '',
  `level` varchar(255) NOT NULL DEFAULT '',
  `group_view` varchar(255) NOT NULL DEFAULT '',
  `group_edit` varchar(255) NOT NULL DEFAULT '',
  `blocksmode` varchar(255) NOT NULL DEFAULT '',
  `sections` varchar(255) NOT NULL DEFAULT '',
  `title_it` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_blocks` DISABLE KEYS */;
INSERT INTO `fn_blocks` VALUES ('accesskey','block_accesskey','AccessibilitÃ ','40','right','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('calendar','block_calendar','Calendario','20','right','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('languages','block_languages','Lingua','10','right','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('last_news','block_last_news','Last news','20','bottom','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('search','block_search','Cerca','20','left','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('theme','block_theme','Tema','30','left','','','','1','','','','','','');
INSERT INTO `fn_blocks` VALUES ('user','block_user','Login','5','left','','','','1','','','','','','');
/*!40000 ALTER TABLE `fn_blocks` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_cc_users`;
CREATE TABLE `fn_cc_users` (
  `username` varchar(255) NOT NULL,
  `ccsections` varchar(255) NOT NULL DEFAULT '',
  `default` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_cc_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `fn_cc_users` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_conditions`;
CREATE TABLE `fn_conditions` (
  `id` varchar(255) NOT NULL,
  `enabled` varchar(255) NOT NULL DEFAULT '',
  `optional` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `text` text NOT NULL,
  `text_it` text NOT NULL,
  `text_en` text NOT NULL,
  `text_fr` text NOT NULL,
  `position` varchar(255) NOT NULL DEFAULT '',
  `title_en` varchar(255) NOT NULL DEFAULT '',
  `title_it` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_conditions` DISABLE KEYS */;
/*!40000 ALTER TABLE `fn_conditions` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_files`;
CREATE TABLE `fn_files` (
  `id` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `photo1` varchar(255) NOT NULL DEFAULT '',
  `file` varchar(255) NOT NULL DEFAULT '',
  `recordinsert` varchar(255) NOT NULL DEFAULT '',
  `recordupdate` varchar(255) NOT NULL DEFAULT '',
  `view` varchar(255) NOT NULL DEFAULT '',
  `groupview` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `description_it` text NOT NULL,
  `description_en` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `fn_files` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_groups`;
CREATE TABLE `fn_groups` (
  `groupname` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`groupname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_groups` DISABLE KEYS */;
INSERT INTO `fn_groups` VALUES ('RW_BS','CURATORI BRESCIA');
INSERT INTO `fn_groups` VALUES ('grotte_nascoste','');
INSERT INTO `fn_groups` VALUES ('users','');
INSERT INTO `fn_groups` VALUES ('RW_CO_LC_SO_MI_PV','CURATORI LECCO,COMO,SONDRIO,MILANO,PAVIA');
INSERT INTO `fn_groups` VALUES ('w_artificials','');
INSERT INTO `fn_groups` VALUES ('RW_BG','CURATORI BERGAMO');
INSERT INTO `fn_groups` VALUES ('grotte_sicure','CURATORI GROTTE SICURE');
INSERT INTO `fn_groups` VALUES ('r_fauna','');
INSERT INTO `fn_groups` VALUES ('RW_VA','CURATORI VARESE');
INSERT INTO `fn_groups` VALUES ('w_fauna','');
INSERT INTO `fn_groups` VALUES ('READ_SPELEOPALEO','Utente sola lettura Speleopaleo');
INSERT INTO `fn_groups` VALUES ('r_caves','');
INSERT INTO `fn_groups` VALUES ('r_artificials','');
INSERT INTO `fn_groups` VALUES ('w_caves','');
INSERT INTO `fn_groups` VALUES ('archeologi','');
INSERT INTO `fn_groups` VALUES ('catasto_lettura','');
INSERT INTO `fn_groups` VALUES ('catasto_inserimento','Gruppo per l\'inserimento di grotte nuove');
INSERT INTO `fn_groups` VALUES ('catasto_amministratori','Gruppo per gli Amministratori del gestionale catasto');
/*!40000 ALTER TABLE `fn_groups` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_sections`;
CREATE TABLE `fn_sections` (
  `id` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT '',
  `parent` varchar(255) NOT NULL DEFAULT '',
  `position` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `startdate` varchar(255) NOT NULL DEFAULT '',
  `enddate` varchar(255) NOT NULL DEFAULT '',
  `status` varchar(255) NOT NULL DEFAULT '',
  `hidden` varchar(255) NOT NULL DEFAULT '',
  `accesskey` varchar(255) NOT NULL DEFAULT '',
  `keywords` varchar(255) NOT NULL DEFAULT '',
  `sectionpath` varchar(255) NOT NULL DEFAULT '',
  `level` varchar(255) NOT NULL DEFAULT '',
  `group_view` varchar(255) NOT NULL DEFAULT '',
  `group_edit` varchar(255) NOT NULL DEFAULT '',
  `blocksmode` varchar(255) NOT NULL DEFAULT '',
  `blocks` varchar(255) NOT NULL DEFAULT '',
  `title_it` varchar(255) NOT NULL DEFAULT '',
  `description_it` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `parent` (`parent`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_sections` DISABLE KEYS */;
INSERT INTO `fn_sections` VALUES ('art_categorie','table_editor','menu_artificials','23','Configurazione categorie','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('art_tipologie','table_editor','art_categorie','24','Configurazione tipologie','','','','1','0','','','sections','','artificiali_scrittura','artificiali_scrittura','','','','');
INSERT INTO `fn_sections` VALUES ('artificials','dbview','menu_artificials','21','Database cavit&agrave; artificiali','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('bibliography','dbview','menu_natural','7','Bibliografia','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('caves','dbview','menu_natural','3','Catasto Grotte Riservato','','','','1','','','','sections','0','RW_BS,users,RW_CO_LC_SO_MI_PV,RW_BG,r_fauna,RW_VA,READ_SPELEOPALEO,r_caves,r_artificials','','','','Catasto Grotte Riservato','');
INSERT INTO `fn_sections` VALUES ('cavesystem','dbview','menu_natural','5','Complessi carsici','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('configopenkis','','menu_settings','19','Configurazione','','','','1','0','','','sections','10','','','','','','');
INSERT INTO `fn_sections` VALUES ('coordinate_types','','menu_settings','17','Tipi di coordinate','','','','1','','','','sections','','catasto_amministratori','catasto_amministratori','','','Tipi di coordinate','');
INSERT INTO `fn_sections` VALUES ('fauna','dbview','menu_fauna','28','Fauna cavernicola','contiene l\'elenco degli animali cavernicoli','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('fauna_surveys','dbview','menu_fauna','29','Rilevamenti faunistici','','','','1','0','','','sections','','fauna,catasto_scrittura,archeologi,curatori','','','','','');
INSERT INTO `fn_sections` VALUES ('geological_formations','','menu_settings','16','Formazioni geologiche','','','','1','','','','sections','','catasto_amministratori','catasto_amministratori','','','Formazioni geologiche','');
INSERT INTO `fn_sections` VALUES ('login','login','','30','Accesso','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('map_artificials','','menu_artificials','22','Mappa cavitÃ  artificiali','','','','1','0','','','sections','','','','','','Mappa cavitÃ  artificiali','');
INSERT INTO `fn_sections` VALUES ('map_caves','','menu_natural','2','Mappa Grotte Pubblica','Mappa Pubblica delle cavitÃ  naturali','','','1','','','','sections','','','','','','Mappa Grotte Pubblica','Mappa Pubblica delle cavitÃ  naturali');
INSERT INTO `fn_sections` VALUES ('menu_artificials','block_menu','','20','Cavit&agrave; artificiali','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('menu_fauna','block_menu','','27','Fauna','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('menu_natural','block_menu','','1','Cavit&agrave; naturali','','','','1','0','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('menu_settings','block_menu','','8','Configurazione','','','','1','0','','','sections','','catasto_scrittura','','','','','');
INSERT INTO `fn_sections` VALUES ('search','search','','10','search','','','','1','1','','','sections','','','','hide','search','','');
INSERT INTO `fn_sections` VALUES ('springs','table_editor','art_categorie','25','Configurazione tipologie','','','','1','0','','','sections','','artificiali_scrittura','artificiali_scrittura','','','','');
INSERT INTO `fn_sections` VALUES ('survey','dbview','menu_natural','4','Rilievi','Rilievi delle grotte','','','1','','','','sections','0','RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA,r_caves','RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA','','','Rilievi','Rilievi delle grotte');
INSERT INTO `fn_sections` VALUES ('home','','','240','Home','','','','1','1','','','sections','','','','','','Home','');
INSERT INTO `fn_sections` VALUES ('survey_artificials','dbview','menu_artificials','26','Rilievi','Rilievi delle cavit&agrave; artificiali','','','1','0','','','sections','0','w_artificials,r_artificials','w_artificials','','','Rilievi','Rilievi delle cavit&agrave; artificiali');
INSERT INTO `fn_sections` VALUES ('areas','dbview','menu_natural','6','Aree speleologiche','','','','1','0','','','sections','','','','','','Aree speleologiche','');
INSERT INTO `fn_sections` VALUES ('infocookie','','','241','infocookie','','','','1','1','','','sections','','','','','','','');
INSERT INTO `fn_sections` VALUES ('openai','','','31','Ricerca con IA','','','','1','','','','sections','10','','','','','Ricerca con IA','');
INSERT INTO `fn_sections` VALUES ('aggiorna_codice_fslo','','Strumenti','15','Aggiorna codice FSLo','Aggiorna codice FSLo','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Aggiorna codice FSLo','Aggiorna codice FSLo');
INSERT INTO `fn_sections` VALUES ('reports','block_menu','Strumenti','10','Reports','Reports','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Reports','Reports');
INSERT INTO `fn_sections` VALUES ('situazione_catasto','','reports','13','Situazione catasto','','','','1','','','','sections','','catasto_amministratori','catasto_amministratori','','','Situazione catasto','');
INSERT INTO `fn_sections` VALUES ('numeri_bianchi_e_avvisi','','reports','14','Numeri bianchi e avvisi','Numeri bianchi e avvisi','','','1','','','','sections','','catasto_amministratori','catasto_amministratori','','','Numeri bianchi e avvisi','Numeri bianchi e avvisi');
INSERT INTO `fn_sections` VALUES ('esportazioni','block_menu','Strumenti','11','Esportazioni','Esportazioni','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Esportazioni','Esportazioni');
INSERT INTO `fn_sections` VALUES ('esportazione_excel','','esportazioni','32','Esportazione Excel','','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Esportazione Excel','');
INSERT INTO `fn_sections` VALUES ('Strumenti','block_menu','','9','Strumenti','Strumenti','','','1','','','','sections','10','catasto_inserimento','catasto_amministratori','','','Strumenti','Strumenti');
INSERT INTO `fn_sections` VALUES ('query','','Strumenti','12','Query','Query','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Query','Query');
INSERT INTO `fn_sections` VALUES ('gruppi_speleologici','','menu_settings','18','Gruppi Speleologici','Gruppi Speleologici','','','1','','','','sections','10','catasto_amministratori','catasto_amministratori','','','Gruppi Speleologici','Gruppi Speleologici');
/*!40000 ALTER TABLE `fn_sections` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_sectionstypes`;
CREATE TABLE `fn_sectionstypes` (
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_sectionstypes` DISABLE KEYS */;
INSERT INTO `fn_sectionstypes` VALUES ('Download','Download');
INSERT INTO `fn_sectionstypes` VALUES ('block_accesskey','block accesskey');
INSERT INTO `fn_sectionstypes` VALUES ('block_calendar','Block calendar');
INSERT INTO `fn_sectionstypes` VALUES ('block_languages','block languages');
INSERT INTO `fn_sectionstypes` VALUES ('block_last_news','block last news');
INSERT INTO `fn_sectionstypes` VALUES ('block_mediafiles','block mediafiles');
INSERT INTO `fn_sectionstypes` VALUES ('block_menu','block menu');
INSERT INTO `fn_sectionstypes` VALUES ('block_search','block search');
INSERT INTO `fn_sectionstypes` VALUES ('block_slideshow','block slideshow');
INSERT INTO `fn_sectionstypes` VALUES ('block_theme','block theme');
INSERT INTO `fn_sectionstypes` VALUES ('block_user','block user');
INSERT INTO `fn_sectionstypes` VALUES ('calendar','calendar');
INSERT INTO `fn_sectionstypes` VALUES ('contacts','contacts');
INSERT INTO `fn_sectionstypes` VALUES ('dbview','database viewer');
INSERT INTO `fn_sectionstypes` VALUES ('filemanager','filemanager');
INSERT INTO `fn_sectionstypes` VALUES ('html','html');
INSERT INTO `fn_sectionstypes` VALUES ('html_template','html template');
INSERT INTO `fn_sectionstypes` VALUES ('login','login');
INSERT INTO `fn_sectionstypes` VALUES ('navigator','files and database');
INSERT INTO `fn_sectionstypes` VALUES ('news','News');
INSERT INTO `fn_sectionstypes` VALUES ('php','php');
INSERT INTO `fn_sectionstypes` VALUES ('redirect','redirect');
INSERT INTO `fn_sectionstypes` VALUES ('rssviewer','rssviewer');
INSERT INTO `fn_sectionstypes` VALUES ('search','Search');
INSERT INTO `fn_sectionstypes` VALUES ('sitemap_tree','Site map tree');
INSERT INTO `fn_sectionstypes` VALUES ('table_editor','table editor');
INSERT INTO `fn_sectionstypes` VALUES ('youtube_channel_API v3','youtube channel API v3');
INSERT INTO `fn_sectionstypes` VALUES ('openai','openai');
/*!40000 ALTER TABLE `fn_sectionstypes` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_settings`;
CREATE TABLE `fn_settings` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_settings` DISABLE KEYS */;
INSERT INTO `fn_settings` VALUES ('use_urlserverpath','0','0');
INSERT INTO `fn_settings` VALUES ('sitename','Catasto Speleologico Lombardo','Flatnux');
INSERT INTO `fn_settings` VALUES ('site_title','Catasto Speleologico Lombardo - Progetto Tu.Pa.Ca.','Flatnux CMS');
INSERT INTO `fn_settings` VALUES ('site_subtitle','Quest\'opera Ã¨ distribuita con Licenza Creative Commons Attribuzione - Non commerciale - Non opere derivate 3.0 Italia','www.flatnux.org');
INSERT INTO `fn_settings` VALUES ('keywords','','');
INSERT INTO `fn_settings` VALUES ('languages','it','en');
INSERT INTO `fn_settings` VALUES ('theme','openkis_lombardia','default');
INSERT INTO `fn_settings` VALUES ('controlcenter_theme','adminkit','classic');
INSERT INTO `fn_settings` VALUES ('switchtheme','0','1');
INSERT INTO `fn_settings` VALUES ('siteurl','','');
INSERT INTO `fn_settings` VALUES ('site_email_address','noreply@example.invalid','nobody@site_email_address.set');
INSERT INTO `fn_settings` VALUES ('log_email_address','','');
INSERT INTO `fn_settings` VALUES ('enable_compress_gzip','0','0');
INSERT INTO `fn_settings` VALUES ('home_section','map_caves','home');
INSERT INTO `fn_settings` VALUES ('jet_lag','0','0');
INSERT INTO `fn_settings` VALUES ('showaccesskey','0','0');
INSERT INTO `fn_settings` VALUES ('enable_log_email','0','0');
INSERT INTO `fn_settings` VALUES ('enable_mod_rewrite','2','1');
INSERT INTO `fn_settings` VALUES ('links_mode','folders','html');
INSERT INTO `fn_settings` VALUES ('enable_registration','0','1');
INSERT INTO `fn_settings` VALUES ('username_is_email','0','0');
INSERT INTO `fn_settings` VALUES ('registration_by_email','1','1');
INSERT INTO `fn_settings` VALUES ('remember_login','1','1');
INSERT INTO `fn_settings` VALUES ('enable_captcha','0','0');
INSERT INTO `fn_settings` VALUES ('htmleditor','ckeditor4','ckeditor4');
INSERT INTO `fn_settings` VALUES ('enable_online_administration','1','1');
INSERT INTO `fn_settings` VALUES ('credits','Powered by <a href=\'http://www.flatnux.org\'>Flatnux</a>','Powered by <a href=\'http://www.flatnux.org\'>Flatnux</a>');
INSERT INTO `fn_settings` VALUES ('maintenance','0','0');
INSERT INTO `fn_settings` VALUES ('url_update','http://www.flatnux.altervista.org/updates/FLATNUXSTABLE','http://www.flatnux.altervista.org/updates/FLATNUXSTABLE');
INSERT INTO `fn_settings` VALUES ('use_cache','0','0');
INSERT INTO `fn_settings` VALUES ('timezone','Europe/Rome','');
/*!40000 ALTER TABLE `fn_settings` ENABLE KEYS */;
DROP TABLE IF EXISTS `fn_users`;
CREATE TABLE `fn_users` (
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `passwd` varchar(255) NOT NULL DEFAULT '',
  `emailhidden` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `surname` varchar(255) NOT NULL DEFAULT '',
  `link` varchar(255) NOT NULL DEFAULT '',
  `avatarimage` varchar(255) NOT NULL DEFAULT '',
  `avatar` varchar(255) NOT NULL DEFAULT '',
  `signature` text NOT NULL,
  `level` varchar(255) NOT NULL DEFAULT '',
  `group` varchar(255) NOT NULL DEFAULT '',
  `ip` varchar(255) NOT NULL DEFAULT '',
  `rnd` varchar(255) NOT NULL DEFAULT '',
  `active` varchar(255) NOT NULL DEFAULT '',
  `registrationdate` varchar(255) NOT NULL DEFAULT '',
  `speleo_groups` tinytext DEFAULT NULL,
  PRIMARY KEY (`username`),
  KEY `group` (`group`),
  KEY `email` (`email`),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fn_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `fn_users` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_Strumenti`;
CREATE TABLE `fncf_Strumenti` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_Strumenti` DISABLE KEYS */;
INSERT INTO `fncf_Strumenti` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_Strumenti` VALUES ('method','','ul');
INSERT INTO `fncf_Strumenti` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_Strumenti` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_areas`;
CREATE TABLE `fncf_areas` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_areas` DISABLE KEYS */;
INSERT INTO `fncf_areas` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_areas` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_areas` VALUES ('groupinsert','catasto_amministratori','catasto_amministratori');
INSERT INTO `fncf_areas` VALUES ('groupadmin','catasto_amministratori','catasto_amministratori');
INSERT INTO `fncf_areas` VALUES ('groupview','r_caves','r_caves');
INSERT INTO `fncf_areas` VALUES ('mailalert','','');
INSERT INTO `fncf_areas` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_areas` VALUES ('generate_googlesitemap','0','0');
INSERT INTO `fncf_areas` VALUES ('tables','ctl_areas','ctl_areas');
INSERT INTO `fncf_areas` VALUES ('search_orders','name,recordupdate,recordinsert','name,recordupdate,recordinsert');
INSERT INTO `fncf_areas` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_areas` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_areas` VALUES ('search_min','','');
INSERT INTO `fncf_areas` VALUES ('titlefield','name,code','name,code');
INSERT INTO `fncf_areas` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_areas` VALUES ('search_options','','');
INSERT INTO `fncf_areas` VALUES ('navigate_groups','provincia','provincia');
INSERT INTO `fncf_areas` VALUES ('search_partfields','name','name');
INSERT INTO `fncf_areas` VALUES ('search_fields','code','code');
INSERT INTO `fncf_areas` VALUES ('appendquery','','');
INSERT INTO `fncf_areas` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_areas` VALUES ('image_size','100','100');
INSERT INTO `fncf_areas` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_areas` VALUES ('table_rules','','');
INSERT INTO `fncf_areas` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_areas` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_areas` VALUES ('permissions_records_groups','r_caves','r_caves');
INSERT INTO `fncf_areas` VALUES ('permissions_records_edit_groups','w_caves','w_caves');
INSERT INTO `fncf_areas` VALUES ('enable_history','0','0');
INSERT INTO `fncf_areas` VALUES ('enable_export','0','0');
INSERT INTO `fncf_areas` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_areas` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_areas` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_areas` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_areas` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_areas` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_areas` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_areas` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_art_categorie`;
CREATE TABLE `fncf_art_categorie` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_art_categorie` DISABLE KEYS */;
INSERT INTO `fncf_art_categorie` VALUES ('tablename','','');
/*!40000 ALTER TABLE `fncf_art_categorie` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_art_tipologie`;
CREATE TABLE `fncf_art_tipologie` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_art_tipologie` DISABLE KEYS */;
INSERT INTO `fncf_art_tipologie` VALUES ('tablename','ctl_art_types','ctl_art_types');
/*!40000 ALTER TABLE `fncf_art_tipologie` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_artificials`;
CREATE TABLE `fncf_artificials` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_artificials` DISABLE KEYS */;
INSERT INTO `fncf_artificials` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_artificials` VALUES ('recordsperpage','16','16');
INSERT INTO `fncf_artificials` VALUES ('groupinsert','w_artificials','w_artificials');
INSERT INTO `fncf_artificials` VALUES ('groupadmin','w_artificials','w_artificials');
INSERT INTO `fncf_artificials` VALUES ('groupview','','');
INSERT INTO `fncf_artificials` VALUES ('mailalert','','');
INSERT INTO `fncf_artificials` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_artificials` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_artificials` VALUES ('tables','ctl_artificials','ctl_artificials');
INSERT INTO `fncf_artificials` VALUES ('search_orders','name,recordupdate','name,recordupdate');
INSERT INTO `fncf_artificials` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_artificials` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_artificials` VALUES ('search_min','','');
INSERT INTO `fncf_artificials` VALUES ('titlefield','code,name','code,name');
INSERT INTO `fncf_artificials` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_artificials` VALUES ('search_options','archeological,closed','archeological,closed');
INSERT INTO `fncf_artificials` VALUES ('navigate_groups','regione,provincia,comune','regione,provincia,comune');
INSERT INTO `fncf_artificials` VALUES ('search_partfields','name','name');
INSERT INTO `fncf_artificials` VALUES ('search_fields','code','code');
INSERT INTO `fncf_artificials` VALUES ('appendquery','','');
INSERT INTO `fncf_artificials` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_artificials` VALUES ('image_size','100','100');
INSERT INTO `fncf_artificials` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_artificials` VALUES ('table_rules','','');
INSERT INTO `fncf_artificials` VALUES ('enable_permissions_each_records','1','1');
INSERT INTO `fncf_artificials` VALUES ('enable_permissions_edit_each_records','1','1');
INSERT INTO `fncf_artificials` VALUES ('permissions_records_groups','r_artificials,w_artificials','r_artificials,w_artificials');
INSERT INTO `fncf_artificials` VALUES ('permissions_records_edit_groups','r_artificials,w_artificials','r_artificials,w_artificials');
INSERT INTO `fncf_artificials` VALUES ('enable_history','1','1');
INSERT INTO `fncf_artificials` VALUES ('enable_export','1','1');
INSERT INTO `fncf_artificials` VALUES ('enable_delete','1','1');
INSERT INTO `fncf_artificials` VALUES ('hide_on_delete','0','0');
INSERT INTO `fncf_artificials` VALUES ('default_show_groups','1','1');
INSERT INTO `fncf_artificials` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_artificials` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_artificials` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_artificials` VALUES ('enablecomments','0','0');
INSERT INTO `fncf_artificials` VALUES ('enableranks','0','0');
INSERT INTO `fncf_artificials` VALUES ('default_view_mode','icon','icon');
INSERT INTO `fncf_artificials` VALUES ('enable_rss','1','1');
INSERT INTO `fncf_artificials` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_artificials` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_bibliography`;
CREATE TABLE `fncf_bibliography` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_bibliography` DISABLE KEYS */;
INSERT INTO `fncf_bibliography` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_bibliography` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_bibliography` VALUES ('groupinsert','','');
INSERT INTO `fncf_bibliography` VALUES ('groupadmin','','');
INSERT INTO `fncf_bibliography` VALUES ('groupview','','');
INSERT INTO `fncf_bibliography` VALUES ('mailalert','','');
INSERT INTO `fncf_bibliography` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_bibliography` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_bibliography` VALUES ('tables','ctl_bibliograpy','ctl_bibliograpy');
INSERT INTO `fncf_bibliography` VALUES ('search_orders','recordupdate,year,province,title','recordupdate,year,province,title');
INSERT INTO `fncf_bibliography` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_bibliography` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_bibliography` VALUES ('search_min','year','year');
INSERT INTO `fncf_bibliography` VALUES ('titlefield','title','title');
INSERT INTO `fncf_bibliography` VALUES ('descriptionfield','abstract','abstract');
INSERT INTO `fncf_bibliography` VALUES ('search_options','','');
INSERT INTO `fncf_bibliography` VALUES ('navigate_groups','year,province,zone','year,province,zone');
INSERT INTO `fncf_bibliography` VALUES ('search_partfields','authors,title','authors,title');
INSERT INTO `fncf_bibliography` VALUES ('search_fields','username','username');
INSERT INTO `fncf_bibliography` VALUES ('appendquery','','');
INSERT INTO `fncf_bibliography` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_bibliography` VALUES ('image_size','100','100');
INSERT INTO `fncf_bibliography` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_bibliography` VALUES ('table_rules','','');
INSERT INTO `fncf_bibliography` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_bibliography` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_bibliography` VALUES ('permissions_records_groups','bibliography_w,bibliography_r','bibliography_w,bibliography_r');
INSERT INTO `fncf_bibliography` VALUES ('permissions_records_edit_groups','bibliography_w,bibliography_r','bibliography_w,bibliography_r');
INSERT INTO `fncf_bibliography` VALUES ('enable_history','0','0');
INSERT INTO `fncf_bibliography` VALUES ('enable_export','0','0');
INSERT INTO `fncf_bibliography` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_bibliography` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_bibliography` VALUES ('default_show_groups','1','1');
INSERT INTO `fncf_bibliography` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_bibliography` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_bibliography` VALUES ('enable_offlineform','0','0');
INSERT INTO `fncf_bibliography` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_bibliography` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_block_calendar`;
CREATE TABLE `fncf_block_calendar` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_block_calendar` DISABLE KEYS */;
INSERT INTO `fncf_block_calendar` VALUES ('page_target','news_archive','news_archive');
/*!40000 ALTER TABLE `fncf_block_calendar` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_block_last_news`;
CREATE TABLE `fncf_block_last_news` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_block_last_news` DISABLE KEYS */;
INSERT INTO `fncf_block_last_news` VALUES ('tablename','news','news');
INSERT INTO `fncf_block_last_news` VALUES ('section','news','news');
INSERT INTO `fncf_block_last_news` VALUES ('max_items','5','5');
INSERT INTO `fncf_block_last_news` VALUES ('show_in_section','','');
/*!40000 ALTER TABLE `fncf_block_last_news` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_caves`;
CREATE TABLE `fncf_caves` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_caves` DISABLE KEYS */;
INSERT INTO `fncf_caves` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_caves` VALUES ('recordsperpage','15','10');
INSERT INTO `fncf_caves` VALUES ('groupinsert','catasto_inserimento','catasto_inserimento');
INSERT INTO `fncf_caves` VALUES ('groupadmin','catasto_amministratori','catasto_amministratori');
INSERT INTO `fncf_caves` VALUES ('groupview','','');
INSERT INTO `fncf_caves` VALUES ('mailalert','','');
INSERT INTO `fncf_caves` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_caves` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_caves` VALUES ('tables','ctl_caves','ctl_caves');
INSERT INTO `fncf_caves` VALUES ('search_orders','name,recordupdate','name,recordupdate');
INSERT INTO `fncf_caves` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_caves` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_caves` VALUES ('search_min','lenght_total,lenght_planimetric,lenght_extension,depth_total','');
INSERT INTO `fncf_caves` VALUES ('titlefield','code,name','code,name');
INSERT INTO `fncf_caves` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_caves` VALUES ('search_options','archeological,closed','archeological,closed');
INSERT INTO `fncf_caves` VALUES ('navigate_groups','regione,provincia,comune,areas','regione,provincia,comune,areas');
INSERT INTO `fncf_caves` VALUES ('search_partfields','name,code,synonyms,comune,provincia','name');
INSERT INTO `fncf_caves` VALUES ('search_fields','code','code');
INSERT INTO `fncf_caves` VALUES ('appendquery','name <> \'%NUMERO BIANCO%\' AND  name <> \'\'','');
INSERT INTO `fncf_caves` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_caves` VALUES ('image_size','100','100');
INSERT INTO `fncf_caves` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_caves` VALUES ('table_rules','ctl_caves_rules','ctl_caves_rules');
INSERT INTO `fncf_caves` VALUES ('enable_permissions_each_records','1','1');
INSERT INTO `fncf_caves` VALUES ('enable_permissions_edit_each_records','1','1');
INSERT INTO `fncf_caves` VALUES ('permissions_records_groups','RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV','RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV');
INSERT INTO `fncf_caves` VALUES ('permissions_records_edit_groups','RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV','RW_BG,RW_BS,RW_VA,RW_CO_LC_SO_MI_PV');
INSERT INTO `fncf_caves` VALUES ('enable_history','0','0');
INSERT INTO `fncf_caves` VALUES ('enable_export','0','0');
INSERT INTO `fncf_caves` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_caves` VALUES ('hide_on_delete','0','0');
INSERT INTO `fncf_caves` VALUES ('default_show_groups','1','1');
INSERT INTO `fncf_caves` VALUES ('enable_statistics','1','1');
INSERT INTO `fncf_caves` VALUES ('search_query_native_mysql','1','1');
INSERT INTO `fncf_caves` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_caves` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_caves` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_cavesystem`;
CREATE TABLE `fncf_cavesystem` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_cavesystem` DISABLE KEYS */;
INSERT INTO `fncf_cavesystem` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_cavesystem` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_cavesystem` VALUES ('groupinsert','catasto_amministratori','catasto_amministratori');
INSERT INTO `fncf_cavesystem` VALUES ('groupadmin','catasto_amministratori','catasto_amministratori');
INSERT INTO `fncf_cavesystem` VALUES ('groupview','','');
INSERT INTO `fncf_cavesystem` VALUES ('mailalert','','');
INSERT INTO `fncf_cavesystem` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_cavesystem` VALUES ('tables','ctl_cavesystems','ctl_cavesystems');
INSERT INTO `fncf_cavesystem` VALUES ('search_orders','name,lenght_total,depth_total','name,lenght_total,depth_total');
INSERT INTO `fncf_cavesystem` VALUES ('defaultorder','lenght_total,depth_total','lenght_total,depth_total');
INSERT INTO `fncf_cavesystem` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('search_min','lenght_total,depth_total','lenght_total,depth_total');
INSERT INTO `fncf_cavesystem` VALUES ('titlefield','name','name');
INSERT INTO `fncf_cavesystem` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_cavesystem` VALUES ('search_options','','');
INSERT INTO `fncf_cavesystem` VALUES ('navigate_groups','','');
INSERT INTO `fncf_cavesystem` VALUES ('search_partfields','','');
INSERT INTO `fncf_cavesystem` VALUES ('search_fields','','');
INSERT INTO `fncf_cavesystem` VALUES ('appendquery','','');
INSERT INTO `fncf_cavesystem` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_cavesystem` VALUES ('image_size','400','400');
INSERT INTO `fncf_cavesystem` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_cavesystem` VALUES ('table_rules','','');
INSERT INTO `fncf_cavesystem` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('permissions_records_groups','','');
INSERT INTO `fncf_cavesystem` VALUES ('permissions_records_edit_groups','','');
INSERT INTO `fncf_cavesystem` VALUES ('enable_history','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enable_export','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_cavesystem` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_cavesystem` VALUES ('enablecomments','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('enableranks','0','0');
INSERT INTO `fncf_cavesystem` VALUES ('default_view_mode','icon','icon');
INSERT INTO `fncf_cavesystem` VALUES ('enable_rss','1','1');
INSERT INTO `fncf_cavesystem` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_cavesystem` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_esportazioni`;
CREATE TABLE `fncf_esportazioni` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_esportazioni` DISABLE KEYS */;
INSERT INTO `fncf_esportazioni` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_esportazioni` VALUES ('method','ul','');
INSERT INTO `fncf_esportazioni` VALUES ('recursive','0','1');
/*!40000 ALTER TABLE `fncf_esportazioni` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_fauna`;
CREATE TABLE `fncf_fauna` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_fauna` DISABLE KEYS */;
INSERT INTO `fncf_fauna` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_fauna` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_fauna` VALUES ('groupinsert','','');
INSERT INTO `fncf_fauna` VALUES ('groupadmin','','');
INSERT INTO `fncf_fauna` VALUES ('groupview','','');
INSERT INTO `fncf_fauna` VALUES ('mailalert','','');
INSERT INTO `fncf_fauna` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_fauna` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_fauna` VALUES ('tables','fn_files','fn_files');
INSERT INTO `fncf_fauna` VALUES ('search_orders','title,recordinsert,recordupdate','title,recordinsert,recordupdate');
INSERT INTO `fncf_fauna` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_fauna` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_fauna` VALUES ('search_min','','');
INSERT INTO `fncf_fauna` VALUES ('titlefield','title','title');
INSERT INTO `fncf_fauna` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_fauna` VALUES ('search_options','','');
INSERT INTO `fncf_fauna` VALUES ('navigate_groups','username','username');
INSERT INTO `fncf_fauna` VALUES ('search_partfields','','');
INSERT INTO `fncf_fauna` VALUES ('search_fields','username','username');
INSERT INTO `fncf_fauna` VALUES ('appendquery','','');
INSERT INTO `fncf_fauna` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_fauna` VALUES ('image_size','400','400');
INSERT INTO `fncf_fauna` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_fauna` VALUES ('table_rules','','');
INSERT INTO `fncf_fauna` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_fauna` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_fauna` VALUES ('permissions_records_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_fauna` VALUES ('permissions_records_edit_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_fauna` VALUES ('enable_history','0','0');
INSERT INTO `fncf_fauna` VALUES ('enable_export','0','0');
INSERT INTO `fncf_fauna` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_fauna` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_fauna` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_fauna` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_fauna` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_fauna` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_fauna` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_fauna` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_fauna_surveys`;
CREATE TABLE `fncf_fauna_surveys` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_fauna_surveys` DISABLE KEYS */;
INSERT INTO `fncf_fauna_surveys` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_fauna_surveys` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_fauna_surveys` VALUES ('groupinsert','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('groupadmin','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('groupview','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('mailalert','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_fauna_surveys` VALUES ('tables','fn_files','fn_files');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_orders','title,recordinsert,recordupdate','title,recordinsert,recordupdate');
INSERT INTO `fncf_fauna_surveys` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_min','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('titlefield','title','title');
INSERT INTO `fncf_fauna_surveys` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_options','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('navigate_groups','username','username');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_partfields','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_fields','username','username');
INSERT INTO `fncf_fauna_surveys` VALUES ('appendquery','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_fauna_surveys` VALUES ('image_size','400','400');
INSERT INTO `fncf_fauna_surveys` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_fauna_surveys` VALUES ('table_rules','','');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('permissions_records_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_fauna_surveys` VALUES ('permissions_records_edit_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_history','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_export','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_fauna_surveys` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_fauna_surveys` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_fauna_surveys` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_fauna_surveys` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_login`;
CREATE TABLE `fncf_login` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_login` DISABLE KEYS */;
INSERT INTO `fncf_login` VALUES ('enable_captcha','0','0');
INSERT INTO `fncf_login` VALUES ('change_password_online','0','0');
INSERT INTO `fncf_login` VALUES ('send_welcome_message','1','1');
/*!40000 ALTER TABLE `fncf_login` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_map_caves`;
CREATE TABLE `fncf_map_caves` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_map_caves` DISABLE KEYS */;
INSERT INTO `fncf_map_caves` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_map_caves` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_map_caves` VALUES ('groupinsert','','');
INSERT INTO `fncf_map_caves` VALUES ('groupadmin','','');
INSERT INTO `fncf_map_caves` VALUES ('groupview','','');
INSERT INTO `fncf_map_caves` VALUES ('mailalert','','');
INSERT INTO `fncf_map_caves` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_map_caves` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_map_caves` VALUES ('tables','fn_files','fn_files');
INSERT INTO `fncf_map_caves` VALUES ('search_orders','title,recordinsert,recordupdate','title,recordinsert,recordupdate');
INSERT INTO `fncf_map_caves` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_map_caves` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_map_caves` VALUES ('search_min','','');
INSERT INTO `fncf_map_caves` VALUES ('titlefield','title','title');
INSERT INTO `fncf_map_caves` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_map_caves` VALUES ('search_options','','');
INSERT INTO `fncf_map_caves` VALUES ('navigate_groups','username','username');
INSERT INTO `fncf_map_caves` VALUES ('search_partfields','','');
INSERT INTO `fncf_map_caves` VALUES ('search_fields','username','username');
INSERT INTO `fncf_map_caves` VALUES ('appendquery','','');
INSERT INTO `fncf_map_caves` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_map_caves` VALUES ('image_size','400','400');
INSERT INTO `fncf_map_caves` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_map_caves` VALUES ('table_rules','','');
INSERT INTO `fncf_map_caves` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_map_caves` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_map_caves` VALUES ('permissions_records_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_map_caves` VALUES ('permissions_records_edit_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_map_caves` VALUES ('enable_history','0','0');
INSERT INTO `fncf_map_caves` VALUES ('enable_export','0','0');
INSERT INTO `fncf_map_caves` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_map_caves` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_map_caves` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_map_caves` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_map_caves` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_map_caves` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_map_caves` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_map_caves` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_menu_artificials`;
CREATE TABLE `fncf_menu_artificials` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_menu_artificials` DISABLE KEYS */;
INSERT INTO `fncf_menu_artificials` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_menu_artificials` VALUES ('method','ul','ul');
INSERT INTO `fncf_menu_artificials` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_menu_artificials` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_menu_fauna`;
CREATE TABLE `fncf_menu_fauna` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_menu_fauna` DISABLE KEYS */;
INSERT INTO `fncf_menu_fauna` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_menu_fauna` VALUES ('method','ul','ul');
INSERT INTO `fncf_menu_fauna` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_menu_fauna` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_menu_natural`;
CREATE TABLE `fncf_menu_natural` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_menu_natural` DISABLE KEYS */;
INSERT INTO `fncf_menu_natural` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_menu_natural` VALUES ('method','ul','ul');
INSERT INTO `fncf_menu_natural` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_menu_natural` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_menu_settings`;
CREATE TABLE `fncf_menu_settings` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_menu_settings` DISABLE KEYS */;
INSERT INTO `fncf_menu_settings` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_menu_settings` VALUES ('method','ul','ul');
INSERT INTO `fncf_menu_settings` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_menu_settings` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_openai`;
CREATE TABLE `fncf_openai` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_openai` DISABLE KEYS */;
INSERT INTO `fncf_openai` VALUES ('apikey','','1234567');
/*!40000 ALTER TABLE `fncf_openai` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_reports`;
CREATE TABLE `fncf_reports` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_reports` DISABLE KEYS */;
INSERT INTO `fncf_reports` VALUES ('parent','__submenu__','__submenu__');
INSERT INTO `fncf_reports` VALUES ('method','ul','ul');
INSERT INTO `fncf_reports` VALUES ('recursive','1','1');
/*!40000 ALTER TABLE `fncf_reports` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_springs`;
CREATE TABLE `fncf_springs` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_springs` DISABLE KEYS */;
INSERT INTO `fncf_springs` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_springs` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_springs` VALUES ('table_rules','','');
INSERT INTO `fncf_springs` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_springs` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_springs` VALUES ('image_size','400','400');
INSERT INTO `fncf_springs` VALUES ('appendquery','','');
INSERT INTO `fncf_springs` VALUES ('search_fields','username','username');
INSERT INTO `fncf_springs` VALUES ('search_partfields','','');
INSERT INTO `fncf_springs` VALUES ('navigate_groups','username','username');
INSERT INTO `fncf_springs` VALUES ('search_options','','');
INSERT INTO `fncf_springs` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_springs` VALUES ('titlefield','title','title');
INSERT INTO `fncf_springs` VALUES ('search_min','','');
INSERT INTO `fncf_springs` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_springs` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_springs` VALUES ('search_orders','title,recordinsert,recordupdate','title,recordinsert,recordupdate');
INSERT INTO `fncf_springs` VALUES ('tables','fn_files','fn_files');
INSERT INTO `fncf_springs` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_springs` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_springs` VALUES ('mailalert','','');
INSERT INTO `fncf_springs` VALUES ('groupview','','');
INSERT INTO `fncf_springs` VALUES ('groupadmin','','');
INSERT INTO `fncf_springs` VALUES ('groupinsert','','');
INSERT INTO `fncf_springs` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_springs` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_springs` VALUES ('permissions_records_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_springs` VALUES ('permissions_records_edit_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_springs` VALUES ('enable_history','0','0');
INSERT INTO `fncf_springs` VALUES ('enable_export','0','0');
INSERT INTO `fncf_springs` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_springs` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_springs` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_springs` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_springs` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_springs` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_springs` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_springs` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_survey`;
CREATE TABLE `fncf_survey` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_survey` DISABLE KEYS */;
INSERT INTO `fncf_survey` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_survey` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_survey` VALUES ('groupinsert','','');
INSERT INTO `fncf_survey` VALUES ('groupadmin','','');
INSERT INTO `fncf_survey` VALUES ('groupview','','');
INSERT INTO `fncf_survey` VALUES ('mailalert','','');
INSERT INTO `fncf_survey` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_survey` VALUES ('generate_googlesitemap','0','0');
INSERT INTO `fncf_survey` VALUES ('tables','ctl_surveys','ctl_surveys');
INSERT INTO `fncf_survey` VALUES ('search_orders','recordupdate,recordinsert','recordupdate,recordinsert');
INSERT INTO `fncf_survey` VALUES ('defaultorder','id','id');
INSERT INTO `fncf_survey` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_survey` VALUES ('search_min','','');
INSERT INTO `fncf_survey` VALUES ('titlefield','codecave,name','codecave,name');
INSERT INTO `fncf_survey` VALUES ('descriptionfield','makers','makers');
INSERT INTO `fncf_survey` VALUES ('search_options','author,makers','author,makers');
INSERT INTO `fncf_survey` VALUES ('navigate_groups','license,codecave','license,codecave');
INSERT INTO `fncf_survey` VALUES ('search_partfields','','');
INSERT INTO `fncf_survey` VALUES ('search_fields','codecave','codecave');
INSERT INTO `fncf_survey` VALUES ('appendquery','','');
INSERT INTO `fncf_survey` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_survey` VALUES ('image_size','200','200');
INSERT INTO `fncf_survey` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_survey` VALUES ('table_rules','','');
INSERT INTO `fncf_survey` VALUES ('enable_permissions_each_records','1','1');
INSERT INTO `fncf_survey` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_survey` VALUES ('permissions_records_groups','r_caves,RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA','r_caves,RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA');
INSERT INTO `fncf_survey` VALUES ('permissions_records_edit_groups','RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA','RW_BS,RW_CO_LC_SO_MI_PV,RW_BG,RW_VA');
INSERT INTO `fncf_survey` VALUES ('enable_history','0','0');
INSERT INTO `fncf_survey` VALUES ('enable_export','0','0');
INSERT INTO `fncf_survey` VALUES ('enable_delete','1','1');
INSERT INTO `fncf_survey` VALUES ('hide_on_delete','0','0');
INSERT INTO `fncf_survey` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_survey` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_survey` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_survey` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_survey` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_survey` ENABLE KEYS */;
DROP TABLE IF EXISTS `fncf_survey_artificials`;
CREATE TABLE `fncf_survey_artificials` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `fncf_survey_artificials` DISABLE KEYS */;
INSERT INTO `fncf_survey_artificials` VALUES ('databasename','fndatabase','fndatabase');
INSERT INTO `fncf_survey_artificials` VALUES ('recordsperpage','12','12');
INSERT INTO `fncf_survey_artificials` VALUES ('groupinsert','','');
INSERT INTO `fncf_survey_artificials` VALUES ('groupadmin','','');
INSERT INTO `fncf_survey_artificials` VALUES ('groupview','','');
INSERT INTO `fncf_survey_artificials` VALUES ('mailalert','','');
INSERT INTO `fncf_survey_artificials` VALUES ('viewonlycreator','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('generate_googlesitemap','1','1');
INSERT INTO `fncf_survey_artificials` VALUES ('tables','fn_files','fn_files');
INSERT INTO `fncf_survey_artificials` VALUES ('search_orders','title,recordinsert,recordupdate','title,recordinsert,recordupdate');
INSERT INTO `fncf_survey_artificials` VALUES ('defaultorder','recordupdate','recordupdate');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_comments_notify','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('search_min','','');
INSERT INTO `fncf_survey_artificials` VALUES ('titlefield','title','title');
INSERT INTO `fncf_survey_artificials` VALUES ('descriptionfield','description','description');
INSERT INTO `fncf_survey_artificials` VALUES ('search_options','','');
INSERT INTO `fncf_survey_artificials` VALUES ('navigate_groups','username','username');
INSERT INTO `fncf_survey_artificials` VALUES ('search_partfields','','');
INSERT INTO `fncf_survey_artificials` VALUES ('search_fields','username','username');
INSERT INTO `fncf_survey_artificials` VALUES ('appendquery','','');
INSERT INTO `fncf_survey_artificials` VALUES ('image_titlefield','photo1','photo1');
INSERT INTO `fncf_survey_artificials` VALUES ('image_size','400','400');
INSERT INTO `fncf_survey_artificials` VALUES ('image_size_h','300','300');
INSERT INTO `fncf_survey_artificials` VALUES ('table_rules','','');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_permissions_each_records','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_permissions_edit_each_records','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('permissions_records_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_survey_artificials` VALUES ('permissions_records_edit_groups','dbview_rw,dbview_ro','dbview_rw,dbview_ro');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_history','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_export','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_delete','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('hide_on_delete','1','1');
INSERT INTO `fncf_survey_artificials` VALUES ('default_show_groups','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_statistics','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('search_query_native_mysql','0','0');
INSERT INTO `fncf_survey_artificials` VALUES ('enable_offlineform','1','1');
INSERT INTO `fncf_survey_artificials` VALUES ('documents_folder','','');
/*!40000 ALTER TABLE `fncf_survey_artificials` ENABLE KEYS */;
DROP TABLE IF EXISTS `plugins_s_statistics`;
CREATE TABLE `plugins_s_statistics` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `plugins_s_statistics` DISABLE KEYS */;
INSERT INTO `plugins_s_statistics` VALUES ('track_ip','0','0');
INSERT INTO `plugins_s_statistics` VALUES ('track_refer','0','0');
INSERT INTO `plugins_s_statistics` VALUES ('track_total','0','1');
INSERT INTO `plugins_s_statistics` VALUES ('track_pages','0','1');
INSERT INTO `plugins_s_statistics` VALUES ('track_data','0','1');
INSERT INTO `plugins_s_statistics` VALUES ('track_agents','0','1');
INSERT INTO `plugins_s_statistics` VALUES ('max_rows','20','20');
INSERT INTO `plugins_s_statistics` VALUES ('antispam','1','1');
INSERT INTO `plugins_s_statistics` VALUES ('track_usersonline','0','0');
/*!40000 ALTER TABLE `plugins_s_statistics` ENABLE KEYS */;
DROP TABLE IF EXISTS `stats_browsers`;
CREATE TABLE `stats_browsers` (
  `browser` varchar(255) NOT NULL,
  `counter_unique` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`browser`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `stats_browsers` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats_browsers` ENABLE KEYS */;
DROP TABLE IF EXISTS `stats_date`;
CREATE TABLE `stats_date` (
  `day` varchar(255) NOT NULL,
  `counter` varchar(255) NOT NULL DEFAULT '',
  `counter_unique` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`day`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `stats_date` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats_date` ENABLE KEYS */;
DROP TABLE IF EXISTS `stats_pages`;
CREATE TABLE `stats_pages` (
  `url` varchar(255) NOT NULL,
  `counter` varchar(255) NOT NULL DEFAULT '',
  `counter_unique` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `stats_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats_pages` ENABLE KEYS */;
DROP TABLE IF EXISTS `stats_total`;
CREATE TABLE `stats_total` (
  `id` varchar(255) NOT NULL,
  `counter` varchar(255) NOT NULL DEFAULT '',
  `counter_unique` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `stats_total` DISABLE KEYS */;
/*!40000 ALTER TABLE `stats_total` ENABLE KEYS */;
DROP TABLE IF EXISTS `themes_s_base`;
CREATE TABLE `themes_s_base` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `themes_s_base` DISABLE KEYS */;
/*!40000 ALTER TABLE `themes_s_base` ENABLE KEYS */;
DROP TABLE IF EXISTS `themes_s_liguria`;
CREATE TABLE `themes_s_liguria` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `themes_s_liguria` DISABLE KEYS */;
INSERT INTO `themes_s_liguria` VALUES ('show_search_form','1','1');
/*!40000 ALTER TABLE `themes_s_liguria` ENABLE KEYS */;
DROP TABLE IF EXISTS `themes_s_openkis_liguria`;
CREATE TABLE `themes_s_openkis_liguria` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `themes_s_openkis_liguria` DISABLE KEYS */;
INSERT INTO `themes_s_openkis_liguria` VALUES ('show_search_form','1','1');
/*!40000 ALTER TABLE `themes_s_openkis_liguria` ENABLE KEYS */;
DROP TABLE IF EXISTS `themes_s_openkis_lombardia`;
CREATE TABLE `themes_s_openkis_lombardia` (
  `varname` varchar(255) NOT NULL,
  `varvalue` varchar(255) NOT NULL DEFAULT '',
  `defaultvalue` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`varname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*!40000 ALTER TABLE `themes_s_openkis_lombardia` DISABLE KEYS */;
INSERT INTO `themes_s_openkis_lombardia` VALUES ('show_search_form','0','1');
/*!40000 ALTER TABLE `themes_s_openkis_lombardia` ENABLE KEYS */;


