<?php
/**
 * Creates every table of the code that doesn't exist yet in the database, with
 * the structure of this revision: the framework and OpenKIS tables of
 * misc/fndatabase/ (regional definitions included, OPENKIS_CUSTOM) and the
 * settings table of every section. The framework otherwise creates a table on
 * its first use, so a new site has only part of its schema until each page has
 * been opened. Data are not touched. Run it on an installed site (after the
 * setup wizard); deploy/schema.sh uses it to write the schema of a revision.
 *
 *   php create-schema.php
 *   docker compose exec -u www-data web php /var/www/html/create-schema.php
 */
if (php_sapi_name() !== 'cli')
{
    die();
}
chdir(__DIR__);
global $_FN;
require_once "loadfinis.php";
$n = 0;
foreach (glob("{$_FN['datadir']}/{$_FN['database']}/*.php") as $file)
{
    $tablename = basename($file, ".php");
    if (!preg_match('/^[A-Za-z0-9_]+$/', $tablename))
        continue;
    $table = FN_XMDBTable($tablename);
    if (is_object($table))
        $n++;
}
echo "tables of misc/{$_FN['database']}: $n\n";
$m = 0;
$sections = FN_XMDBTable("fn_sections");
foreach ($sections->GetRecords() as $section)
{
    $config = "modules/{$section['type']}/config.php";
    if (empty($section['type']) || (!file_exists($config) && !file_exists("{$_FN['src_finis']}/$config")))
        continue;
    FN_LoadConfig("modules/{$section['type']}/config.php", $section['id']);
    $m++;
}
echo "section settings: $m\n";
