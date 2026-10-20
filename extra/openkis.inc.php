<?php
if (file_exists("openkis_config.local.php"))
{

    include "openkis_config.local.php";
}

//da gauss a wgs84 1000030 15
require_once(dirname(__FILE__) . "/openkis_geoconverter/openkis_geoconverter.class.php");

FN_AddLanguagePath("extra/openkis/");
// install missing table definitions (misc/fndatabase/ctl_*.php) on first run
require_once(__DIR__ . "/openkis/install/openkis_install.php");
// map defaults used by templates ({default_latitude} ...) when no regional
// customisation (extra/openkis/custom/<region>) sets them; queued because
// FN_LoadConfig is not available yet at this point of the bootstrap
FN_IncludeScript("extra/openkis/openkis_defaults.php");
// survey records of a restricted cave get the cave's groups, before the
// section or endpoint of this request reads them
FN_IncludeScript("extra/openkis/openkis_survey_groups.php");

// Uploaded files of the cave register (survey drawings, photos, attachments,
// PDFs...) are served through openkis_file.php after a per-record permission
// check, behind an opaque address that does not reveal where the file is
// stored. The two hooks below tell finis to build file links with
// openkis_FileUrl() and to let the thumbnail endpoint ask openkis_FileAccess()
// who may read a file. Set $_FN['openkis_protected_files'] = false (in
// openkis_config.local.php) to keep the old direct-path behaviour.
if (!isset($_FN['openkis_protected_files']) || $_FN['openkis_protected_files'])
{
    $_FN['xmetadb_file_url'] = "openkis_FileUrl";
    $_FN['xmetadb_file_access'] = "openkis_FileAccess";
}

/**
 * Map position for a regional customisation: the region's own centre, unless
 * the administrator changed the map defaults (admin section "configopenkis",
 * extra/openkis/config.php). Called from extra/openkis/custom/<region>/<region>.php.
 */
function openkis_SetRegionMapCenter($latitude, $longitude, $zoom)
{
    global $_FN;
    $config = array();
    include __DIR__ . "/openkis/config.php"; // shipped defaults
    $current = FN_LoadConfig("extra/openkis/config.php");
    $changed = false;
    foreach (array("default_latitude", "default_longitude", "default_zoom") as $k)
    {
        if ((string) $current[$k] !== (string) $config[$k])
            $changed = true;
    }
    if ($changed)
    {
        $_FN['default_latitude'] = $current['default_latitude'];
        $_FN['default_longitude'] = $current['default_longitude'];
        $_FN['default_zoom'] = $current['default_zoom'];
    }
    else
    {
        $_FN['default_latitude'] = $latitude;
        $_FN['default_longitude'] = $longitude;
        $_FN['default_zoom'] = $zoom;
    }
}
/**
 * Values pre-filled in the insert form of a table, e.g. the country and the
 * region of a regional register. Called from
 * extra/openkis/custom/<region>/<region>.php with the sections that show the
 * table (section id => table). Building a form reads every table its
 * foreign keys point to (for caves, artificial cavities and springs the whole
 * caves table), so the form is set up only on the pages of those sections,
 * which build it anyway, instead of on every page (#30). frm_default is used
 * only when the insert form is shown, never when a record is saved from the
 * API or an import.
 *
 * @param array $tables section id => table name, e.g. array("caves" => "ctl_caves")
 * @param array $defaults field => value
 */
function openkis_SetInsertDefaults($tables, $defaults)
{
    global $_FN;
    if (empty($_FN['mod']) || empty($tables[$_FN['mod']]))
    {
        return;
    }
    $form = FN_XMDBForm($tables[$_FN['mod']]);
    if (!is_object($form))
    {
        return;
    }
    foreach ($defaults as $field => $value)
    {
        if (isset($form->formvals[$field]))
        {
            $form->formvals[$field]['frm_default'] = $value;
        }
    }
}

$files = glob(__DIR__ . "/openkis/fields/*.class.php");

if (is_array($files))
{
    foreach ($files as $file)
    {
        require_once $file;
    }
}


/**
 * 
 * @param type $table
 */
function openkis_UpdateCoords($mod, $forceall = false)
{
    global $_FN;
    $started = time();
    //dprint_r(" openkis_UpdateCoords($mod, $forceall = false)");
    $config = FN_LoadConfig("modules/dbview/config.php", $mod);
    $file_lastUpdate = "{$_FN['datadir']}/_cache/openkis_UpdateCoords{$mod}.time";
    if (!file_exists($file_lastUpdate))
    {
        if (!is_dir("{$_FN['datadir']}/_cache"))
            @mkdir("{$_FN['datadir']}/_cache", 0777, true);
        touch($file_lastUpdate);
        $forceall = true;
    }
    $table = FN_XMDBTable($config['tables']);
    if (!$forceall && ($table->GetLastUpdateTime() <= filectime($file_lastUpdate)))
    {
        if (isset($_GET['debug']))
            dprint_r("$mod:Cache openkis_UpdateCoords: " . $table->GetLastUpdateTime(), "", "magenta");
        return;
    }
    else
    {
        if (isset($_GET['debug']))
            dprint_r("$mod:NO cache openkis_UpdateCoords: " . $table->GetLastUpdateTime() . "<" . filectime("$file_lastUpdate"));
    }

    $params['fields'] = "id,code,latitude,longitude,latitude_txt,longitude_txt,coordinates_type,elevation,elevation_map,elevation_gps";
    if ($forceall)
        $results = FN_XMETADBQuery("select {$params['fields']} FROM {$config['tables']}");
    else
        $results = FN_XMETADBQuery("select {$params['fields']} FROM {$config['tables']} WHERE recordupdate > coordnatesupdated OR latitude LIKE '0' OR latitude LIKE ''");

    foreach ($results as $result)
    {
        $position = openkis_GetItemPosition($result);
        if ($position['lat'] != $result["latitude"] || $position['lon'] != $result["longitude"])
        {
            $result["latitude"] = $position['lat'];
            $result["longitude"] = $position['lon'];
            $result["coordnatesupdated"] = FN_Now();
            $table->UpdateRecord($result);
        }
    }
    @touch($file_lastUpdate);
    if ($forceall)
    {
        // a full recalculation started at $started (openkis_UpdateCoordsIfChanged)
        @touch(openkis_UpdateCoordsAllFile($mod), $started);
    }
}

/**
 * @param string $mod
 * @return string the file whose mtime is the start of the last full
 * recalculation of $mod's coordinates
 */
function openkis_UpdateCoordsAllFile($mod)
{
    global $_FN;
    return "{$_FN['datadir']}/_cache/openkis_UpdateCoordsAll{$mod}.time";
}

/**
 * Full coordinate recalculation, like openkis_UpdateCoords($mod, true), but
 * only when something it depends on changed since the last full one: the
 * section's table, ctl_coordinatestypes or the conversion code. Edits made
 * directly in the database are not seen: use Control center -> Utilities ->
 * Refresh map data, or "php refresh-cache.php".
 *
 * @param string $mod
 */
function openkis_UpdateCoordsIfChanged($mod)
{
    $config = FN_LoadConfig("modules/dbview/config.php", $mod);
    $file = openkis_UpdateCoordsAllFile($mod);
    if (file_exists($file))
    {
        $changed = max(openkis_MapCacheStamp($config['tables']),
            openkis_MapCacheStamp("ctl_coordinatestypes"),
            filectime(__FILE__),
            filectime(__DIR__ . "/openkis_geoconverter/openkis_geoconverter.class.php"));
        clearstatcache(true, $file);
        // recalculate when a stamp is >= the start of the last one: stamps
        // have a one second resolution, and a change made during the last
        // recalculation (or by it) is not older than its start
        if ($changed < filemtime($file))
        {
            if (isset($_GET['debug']))
                dprint_r("$mod:Cache openkis_UpdateCoordsIfChanged: $changed", "", "magenta");
            return;
        }
    }
    openkis_UpdateCoords($mod, true);
}

/**
 * Stops the request unless the current user may view the section that a data
 * endpoint reads. The data of a restricted section, such as a reserved cave
 * register, then reaches only its authorized groups and the administrators,
 * as in the web interface.
 *
 * @param string $mod section name
 * @return void
 */
function openkis_RequireSectionView($mod)
{
    if (FN_UserCanViewSection($mod))
        return;
    http_response_code(403);
    header("Cache-Control: no-store");
    die();
}

/**
 * Access of the current user to the records of a section in the data
 * endpoints (map exports, API, WISH feed):
 *  - "all": the user may view the section (its records still follow the
 *    per-record groupview);
 *  - "public": the user may not view the section, but its table has the
 *    public_map field: the records with public_map = "N" are left out
 *    (see openkis_FilterPublicRecords());
 *  - otherwise the request ends with 403.
 *
 * @param string $mod section name
 * @return string "all" or "public"
 */
function openkis_SectionAccess($mod)
{
    if (FN_UserCanViewSection($mod))
        return "all";
    $config = FN_LoadConfig("modules/dbview/config.php", $mod);
    $table = !empty($config['tables']) ? FN_XMDBTable($config['tables']) : false;
    if ($table && isset($table->fields['public_map']))
        return "public";
    openkis_RequireSectionView($mod);
    return "";
}

/**
 * Leaves out the records marked public_map = "N" when $access is "public".
 * An empty value counts as "Y" (the default), so records saved before the
 * field existed, or inserted without it, stay on the public map.
 *
 * @param string $access result of openkis_SectionAccess()
 * @param array $config section config (its first table is the one read)
 * @param array $results rows with the primary key of that table
 * @return array
 */
function openkis_FilterPublicRecords($access, $config, $results)
{
    if ($access !== "public" || !is_array($results))
        return $results;
    $table = FN_XMDBTable($config['tables']);
    $pk = $table->primarykey;
    $public = array();
    $rows = FN_XMETADBQuery("SELECT $pk,public_map FROM {$config['tables']}");
    if (is_array($rows))
    {
        foreach ($rows as $row)
        {
            if (strtoupper(trim(strval($row['public_map']))) !== "N")
                $public[strval($row[$pk])] = true;
        }
    }
    $ret = array();
    foreach ($results as $key => $row)
    {
        if (isset($row[$pk]) && isset($public[strval($row[$pk])]))
            $ret[$key] = $row;
    }
    return $ret;
}

/**
 * Recomputes the development (lenght_total) of the cave systems from the
 * member records, following the per-record scope (ctl_caves.lenght_scope)
 * and the per-system switch (ctl_cavesystems.lenght_auto):
 *
 *  - lenght_auto = "N": the stored value is kept (entered by hand, e.g. a
 *    fresh junction not yet reported on the member records);
 *  - members with lenght_scope = "total" and a non-empty development: the
 *    system development is the maximum of those values (each one describes
 *    the whole cave, summing them would count the same passages many times);
 *  - otherwise, members with lenght_scope = "partial": the system development
 *    is the sum of their values (an empty value counts as zero: an entrance
 *    that adds no development of its own);
 *  - no classified member: the record is left untouched (legacy systems whose
 *    member records have not been classified yet).
 *
 * depth_total is never recalculated: the depth of a system cannot be derived
 * from the member records alone.
 *
 * Cheap to call on every request: a time stamp file makes it a no-op until
 * ctl_caves or ctl_cavesystems changes (same pattern as openkis_UpdateCoords).
 * Does nothing when the instance does not have the lenght_scope/lenght_auto
 * fields installed.
 *
 * @param bool $forceall recompute even when the tables did not change
 * @return void
 */
function openkis_UpdateCaveSystems($forceall = false)
{
    global $_FN;
    $systems_table = FN_XMDBTable("ctl_cavesystems");
    $caves_table = FN_XMDBTable("ctl_caves");
    if (!is_object($systems_table) || !is_object($caves_table))
        return;
    // both sides of the feature must be installed on this instance
    if (!isset($caves_table->fields['lenght_scope']) || !isset($systems_table->fields['lenght_auto']))
        return;
    $file_lastUpdate = "{$_FN['datadir']}/_cache/openkis_UpdateCaveSystems.time";
    if (!file_exists($file_lastUpdate))
    {
        // when the cache dir is not writable (e.g. CLI run as another user)
        // just recompute every time instead of failing
        $fp = @fopen($file_lastUpdate, "a");
        if (is_resource($fp))
            fclose($fp);
        $forceall = true;
    }
    if (!$forceall && $caves_table->GetLastUpdateTime() <= filectime($file_lastUpdate) && $systems_table->GetLastUpdateTime() <= filectime($file_lastUpdate))
    {
        return;
    }
    // member data in one query: code => lenght_total, lenght_scope
    $caves = array();
    $rows = FN_XMETADBQuery("SELECT code,lenght_total,lenght_scope FROM ctl_caves");
    $systems = FN_XMETADBQuery("SELECT id,caves,lenght_total,lenght_auto FROM ctl_cavesystems");
    if (!is_array($rows) || !is_array($systems))
        return;
    foreach ($rows as $cave)
    {
        $caves[trim(strval($cave['code']))] = $cave;
    }
    foreach ($systems as $system)
    {
        if (strtoupper(trim(strval($system['lenght_auto']))) == "N")
            continue;
        $totals = array();
        $partials = array();
        foreach (explode(",", strval($system['caves'])) as $code)
        {
            $code = trim($code);
            if ($code === "" || !isset($caves[$code]))
                continue;
            $scope = trim(strval($caves[$code]['lenght_scope']));
            $lenght = trim(strval($caves[$code]['lenght_total']));
            if ($scope == "total" && $lenght !== "")
                $totals[] = intval($lenght);
            elseif ($scope == "partial")
                $partials[] = intval($lenght);
        }
        if (count($totals) > 0)
            $value = max($totals);
        elseif (count($partials) > 0)
            $value = array_sum($partials);
        else
            continue;
        if (intval($system['lenght_total']) == $value)
            continue;
        $systems_table->UpdateRecordBypk(array("lenght_total" => strval($value)), "id", $system['id']);
    }
    @touch($file_lastUpdate);
}

/**
 * dbview callback (function_on_update / function_on_insert of the sections
 * "caves" and "cavesystem"): refreshes the systems after every save, from the
 * web UI and from the MCP server. The time stamp inside
 * openkis_UpdateCaveSystems() keeps it cheap.
 *
 * @param array $record the saved record (not used)
 * @return void
 */
function openkis_OnSaveUpdateCaveSystems($record)
{
    openkis_UpdateCaveSystems();
}

// Register the save callbacks. Nothing else writes these entries: the dbview
// section initialises $_FN['modparams'][mod]['editorparams'] only when unset.
$_FN['modparams']['caves']['editorparams']['table']['function_on_update'] = "openkis_OnSaveUpdateCaveSystems";
$_FN['modparams']['caves']['editorparams']['table']['function_on_insert'] = "openkis_OnSaveUpdateCaveSystems";
$_FN['modparams']['cavesystem']['editorparams']['table']['function_on_update'] = "openkis_OnSaveUpdateCaveSystems";
$_FN['modparams']['cavesystem']['editorparams']['table']['function_on_insert'] = "openkis_OnSaveUpdateCaveSystems";

/**
 * Map exports cache (openkis_kml.php, openkis_gpx.php, openkis_json.php,
 * openkis_markers.js.php).
 *
 * The cache is looked up before the query and is valid until the table
 * changes (XMETATable touches misc/fndatabase/<table>/updated on every insert,
 * update and delete), the endpoint file changes, or it is older than
 * $_FN['openkis_map_cache_maxage'] seconds (default 3600, 0 = no cache).
 * Edits made directly in the database are not seen: use Control center ->
 * Utilities -> Refresh map data, or "php refresh-cache.php".
 *
 * @param string $endpoint __FILE__ of the endpoint
 * @param array $config the section configuration
 * @return string
 */
function openkis_MapCacheKey($endpoint, $config)
{
    global $_FN;
    $request = array_merge($_GET, $_POST);
    unset($request['debug'], $request['nocache']);
    ksort($request);
    $context = array($request, $config, $_FN['mod'], $_FN['lang'], $_FN['siteurl'], $_FN['user']);
    return "openkis_map_" . basename($endpoint) . "_" . filemtime($endpoint) . "_" . md5(serialize($context));
}

/**
 * Last change time of a table. The marker folder is created when missing
 * (MySQL tables), otherwise XMETATable cannot record the changes and the
 * time would never move.
 *
 * @param string $tablename
 * @return int
 */
function openkis_MapCacheStamp($tablename)
{
    $table = FN_XMDBTable($tablename);
    if (!$table)
    {
        return time();
    }
    $dir = "{$table->path}/{$table->databasename}/{$table->tablename}";
    if (!file_exists("$dir/updated"))
    {
        if (!is_dir($dir))
        {
            @mkdir($dir, 0755, true);
        }
        @touch("$dir/updated");
    }
    clearstatcache(true, "$dir/updated");
    return $table->GetLastUpdateTime();
}

/**
 * @param string $key from openkis_MapCacheKey()
 * @param string $tablename
 * @return string|null the cached output, null when missing or out of date
 */
function openkis_MapCacheGet($key, $tablename)
{
    global $_FN;
    $maxage = isset($_FN['openkis_map_cache_maxage']) ? intval($_FN['openkis_map_cache_maxage']) : 3600;
    if ($maxage <= 0)
    {
        return null;
    }
    $cache = FN_GetGlobalVarValue($key);
    if (!is_array($cache) || !isset($cache['stamp'], $cache['time'], $cache['data']))
    {
        return null;
    }
    if ($cache['stamp'] < openkis_MapCacheStamp($tablename) || time() - $cache['time'] > $maxage)
    {
        return null;
    }
    return $cache['data'];
}

/**
 * @param string $key from openkis_MapCacheKey()
 * @param int $stamp openkis_MapCacheStamp() read before the query
 * @param string $data
 */
function openkis_MapCacheSet($key, $stamp, $data)
{
    global $_FN;
    // with APCu, entries past maxage are dropped from memory instead of
    // waiting for the store to fill up (the file cache ignores the ttl)
    $maxage = isset($_FN['openkis_map_cache_maxage']) ? intval($_FN['openkis_map_cache_maxage']) : 3600;
    FN_SetGlobalVarValue($key, array('stamp' => $stamp, 'time' => time(), 'data' => $data), max(0, $maxage));
}

/**
 * Drops every cached map export, recalculates the coordinates, marks the
 * bibliography as changed (its link table is rebuilt) and re-syncs the record
 * id counters, e.g. after the data were changed directly in the database.
 *
 * @return array what was done, one line per step
 */
function openkis_RefreshMapData()
{
    global $_FN;
    $done = array();
    foreach (array("caves", "artificials", "springs", "glacial") as $mod)
    {
        if (!file_exists("sections/$mod"))
        {
            continue;
        }
        $config = FN_LoadConfig("modules/dbview/config.php", $mod);
        if (empty($config['tables']) || !FN_XMDBTable($config['tables']))
        {
            continue;
        }
        openkis_MapCacheStamp($config['tables']);
        FN_XMDBTable($config['tables'])->SetLastUpdateTime();
        $done[] = "{$config['tables']}: " . FN_Translate("marked as changed");
    }
    // the bibliography link table of the cave pages is rebuilt at the next view (#20)
    if (FN_XMDBTable("ctl_bibliography"))
    {
        openkis_MapCacheStamp("ctl_bibliography");
        FN_XMDBTable("ctl_bibliography")->SetLastUpdateTime();
        $done[] = "ctl_bibliography: " . FN_Translate("marked as changed");
    }
    FN_ClearCache();
    if (function_exists('apcu_clear_cache'))
    {
        apcu_clear_cache();
    }
    $done[] = FN_Translate("cache cleared");
    // the map endpoints recalculate these three
    foreach (array("caves", "artificials", "springs") as $mod)
    {
        if (file_exists("sections/$mod"))
        {
            openkis_UpdateCoords($mod, true);
            $done[] = "$mod: " . FN_Translate("coordinates recalculated");
        }
    }
    $done = array_merge($done, openkis_SyncRecordIds());
    $done = array_merge($done, openkis_SyncSurveyGroups(true));
    return $done;
}

/**
 * Register tables whose files are protected, mapped to the item that owns the
 * access rule:
 *   table => array(item table, code field linking to it or null if the table
 *                  is the item itself, public photo field or null).
 *
 * The item tables (a cave, an artificial cavity, a glacial cave, a spring)
 * carry the groupview that decides who may read the item and its files. Child
 * tables (surveys, photos, attachments, fauna of a cave) point at their item
 * through a code field. "_versions" tables hold historical copies and are
 * never public. The public photo field is the entrance photo that stays
 * visible to everyone when the item is not restricted.
 *
 * A table that is not listed here is not part of the cave register, so
 * openkis_FileAccess() leaves it to the default behaviour.
 *
 * @return array
 */
function openkis_FileItems()
{
    return array(
        "ctl_caves" => array("ctl_caves", null, "photo1"),
        "ctl_artificials" => array("ctl_artificials", null, "photo1"),
        "ctl_glacial" => array("ctl_glacial", null, "photo1"),
        "ctl_springs" => array("ctl_springs", null, "photo1"),
        "ctl_caves_versions" => array("ctl_caves", "code", null),
        "ctl_artificials_versions" => array("ctl_artificials", "code", null),
        "ctl_glacial_versions" => array("ctl_glacial", "code", null),
        "ctl_surveys" => array("ctl_caves", "codecave", null),
        "ctl_photos" => array("ctl_caves", "codecave", null),
        "ctl_attachments" => array("ctl_caves", "codecave", null),
        "ctl_faunacave" => array("ctl_caves", "codecave", null),
        "ctl_surveys_artificials" => array("ctl_artificials", "codeartificial", null),
        "ctl_photos_artificials" => array("ctl_artificials", "codeartificial", null),
        "ctl_attachments_artificials" => array("ctl_artificials", "codeartificial", null),
        "ctl_surveys_glacial" => array("ctl_glacial", "codeglacial", null),
    );
}

/**
 * Secret key for the opaque file tokens, derived from the site secret so it
 * never appears in the code or the data folder. A separate key per purpose
 * ("enc" to encrypt, "nonce" to derive the nonce) keeps the two uses apart.
 *
 * @param string $purpose
 * @return string 32 raw bytes
 */
function openkis_FileKey($purpose)
{
    return hash_hmac("sha256", "openkis-file-$purpose", FN_GetSiteSecret(), true);
}

/**
 * Opaque token that stands for one protected file. It carries, encrypted, the
 * table, record id, field, stored file name and the thumbnail flag, so the
 * endpoint can find the file again and check that the name still matches the
 * record. The address reveals none of this and cannot be edited to point at
 * another file: a changed byte fails the authenticated decryption.
 *
 * The nonce is derived from the plaintext, so the same file always gives the
 * same token (the browser and the map caches can reuse it).
 *
 * @param string $table
 * @param string $id
 * @param string $field
 * @param string $filename stored value of the field
 * @param bool $thumb
 * @return string|false base64url(nonce . box), or false if sodium is missing
 */
function openkis_FileToken($table, $id, $field, $filename, $thumb = false)
{
    if (!function_exists("sodium_crypto_secretbox"))
        return false;
    $plain = json_encode(array((string) $table, (string) $id, (string) $field, (string) $filename, $thumb ? 1 : 0));
    $nonce = substr(hash_hmac("sha256", $plain, openkis_FileKey("nonce"), true), 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $box = sodium_crypto_secretbox($plain, $nonce, openkis_FileKey("enc"));
    return rtrim(strtr(base64_encode($nonce . $box), "+/", "-_"), "=");
}

/**
 * Reverses openkis_FileToken(). Returns array(table, id, field, filename,
 * thumb) or false when the token is missing, malformed or tampered with.
 *
 * @param string $token
 * @return array|false
 */
function openkis_FileTokenDecode($token)
{
    if (!function_exists("sodium_crypto_secretbox_open") || $token == "")
        return false;
    $raw = base64_decode(strtr($token, "-_", "+/"), true);
    if ($raw === false || strlen($raw) <= SODIUM_CRYPTO_SECRETBOX_NONCEBYTES)
        return false;
    $nonce = substr($raw, 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $box = substr($raw, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $plain = sodium_crypto_secretbox_open($box, $nonce, openkis_FileKey("enc"));
    if ($plain === false)
        return false;
    $data = json_decode($plain, true);
    if (!is_array($data) || count($data) < 5)
        return false;
    return array(
        "table" => (string) $data[0],
        "id" => (string) $data[1],
        "field" => (string) $data[2],
        "filename" => (string) $data[3],
        "thumb" => !empty($data[4]),
    );
}

/**
 * Hook for XMETATable::getFileUrl(): the web address of a record's file (or
 * its thumbnail) in the cave register. Instead of the file's own path in the
 * data folder it returns an opaque link to openkis_file.php, which checks who
 * may read the file before serving it. Returns false when the field is empty
 * or the file is missing, so callers fall back as before.
 *
 * Registered in $_FN['xmetadb_file_url'] (see the top of this file).
 *
 * @param XMETATable $xmltable the record's table
 * @param array $recordvalues the record (or enough of it to find the file)
 * @param string $recordkey the file field
 * @param bool $thumb
 * @return string|false
 */
function openkis_FileUrl($xmltable, $recordvalues, $recordkey, $thumb = false)
{
    global $_FN;
    if (!is_array($recordvalues) || !isset($recordvalues[$recordkey]) || !isset($recordvalues[$xmltable->primarykey]))
        $recordvalues = $xmltable->GetRecord($recordvalues);
    $value = isset($recordvalues[$recordkey]) ? $recordvalues[$recordkey] : "";
    $id = isset($recordvalues[$xmltable->primarykey]) ? $recordvalues[$xmltable->primarykey] : "";
    if ($value === "" || $value === null || $id === "")
        return false;
    // the physical file must exist (and be a real file on disk, not inline
    // base64 data, which is not used for register uploads)
    $path = $thumb ? $xmltable->getThumbPath($recordvalues, $recordkey) : $xmltable->getFilePath($recordvalues, $recordkey);
    if (!$path || $path[0] == "?" || !file_exists($path))
        return false;
    $token = openkis_FileToken($xmltable->tablename, $id, $recordkey, $value, $thumb);
    if ($token === false)
    {
        // sodium missing: keep the file reachable the old way rather than
        // breaking the page
        return (!empty($_FN['siteurl']) ? $_FN['siteurl'] : "") . $path;
    }
    // the loader of the 3d viewer picks the format from the extension, so the
    // address keeps a dummy name with the real extension; it is decorative
    $name = "file";
    $ext = strtolower(pathinfo($value, PATHINFO_EXTENSION));
    if ($ext !== "")
        $name .= "." . $ext;
    return (!empty($_FN['siteurl']) ? $_FN['siteurl'] : "") . "openkis_file.php?f=" . $token . "&n=" . rawurlencode($name);
}

/**
 * Whether the current user may read a register file. Used by openkis_file.php
 * and by the thumbnail endpoint ($_FN['xmetadb_file_access']).
 *
 * The rule follows the register pages:
 *  - administrators read everything;
 *  - a table that is not part of the register keeps the default behaviour;
 *  - the entrance photo of a cave that is not restricted stays public;
 *  - otherwise the file follows the groups of the record, or of the item it
 *    belongs to when the record itself carries none; with no restriction a
 *    logged-in user is enough.
 *
 * @param string $table
 * @param string $id
 * @param string $field
 * @return bool
 */
function openkis_FileAccess($table, $id, $field)
{
    global $_FN;
    if (FN_IsAdmin())
        return true;
    $items = openkis_FileItems();
    if (!isset($items[$table]))
        return true; // not a register table: unchanged behaviour
    list($itemtable, $codefield, $publicfield) = $items[$table];
    $t = FN_XMDBTable($table);
    if (!$t)
        return false;
    $record = $t->GetRecordByPrimaryKey($id);
    if (!is_array($record) || !isset($record[$t->primarykey]))
        return false;
    // the item that owns the access rule: the record itself for item tables,
    // or the item found through the code field for a child record
    $item = false;
    if ($codefield === null)
        $item = $record;
    elseif (!empty($record[$codefield]))
    {
        $it = FN_XMDBTable($itemtable);
        $rows = $it ? $it->GetRecords(array("code" => $record[$codefield])) : false;
        if (is_array($rows) && count($rows))
            $item = reset($rows);
    }
    $itemgroups = ($item && isset($item['groupview'])) ? trim(strval($item['groupview'])) : "";
    // public entrance photo of a non-restricted item
    if ($publicfield !== null && $field === $publicfield && $item && $itemgroups === "")
    {
        $publicmap = isset($item['public_map']) ? strtoupper(trim(strval($item['public_map']))) : "";
        if ($publicmap !== "N")
            return true;
    }
    // the record's own groups win; otherwise the item's groups apply
    $groups = trim(strval(isset($record['groupview']) ? $record['groupview'] : ""));
    if ($groups === "")
        $groups = $itemgroups;
    if ($groups === "")
        return $_FN['user'] != ""; // no restriction: any logged-in user
    if ($_FN['user'] == "")
        return false;
    $uservalues = FN_GetUser($_FN['user']);
    $usergroups = explode(",", isset($uservalues['group']) ? $uservalues['group'] : "");
    foreach (explode(",", $groups) as $g)
    {
        if ($g !== "" && in_array($g, $usergroups))
            return true;
    }
    return false;
}

/**
 * Relative address of a file for the 3d cave viewer (cave_viewer.php). The
 * viewer's loader prepends the site URL and reads the format from the
 * extension, so this returns the opaque endpoint path with a dummy name that
 * keeps the real extension. Falls back to the old data-folder path only when
 * the opaque token cannot be built (sodium missing).
 *
 * @param string $table
 * @param string $id
 * @param string $field
 * @param string $filename stored value of the field
 * @return string
 */
function openkis_CaveViewerFile($table, $id, $field, $filename)
{
    global $_FN;
    $token = openkis_FileToken($table, $id, $field, $filename, false);
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    if ($token === false)
    {
        $database = empty($_FN['database']) ? "fndatabase" : $_FN['database'];
        return "misc/$database/$table/$id/$field/$filename";
    }
    return "openkis_file.php?f=$token&n=file" . ($ext !== "" ? ".$ext" : "");
}

/**
 * Survey tables and the table of the item each survey belongs to:
 * survey table => array(field with the item code, item table).
 */
function openkis_SurveyLinks()
{
    return array(
        "ctl_surveys" => array("codecave", "ctl_caves"),
        "ctl_surveys_artificials" => array("codeartificial", "ctl_artificials"),
        "ctl_surveys_glacial" => array("codeglacial", "ctl_glacial"),
    );
}

/**
 * Gives the survey records of a restricted item (a cave, artificial cavity or
 * glacial cave with its own groupview) the groupview of that item, so they
 * reach only the item's groups and the administrators everywhere a survey is
 * read (section pages, search, API, MCP). Surveys of items without a
 * restriction keep their own groups. An item that loses its restriction
 * leaves its surveys as they are, for the curators to open again.
 *
 * Runs only when a survey or item table changed since the last run, as
 * recorded in the data folder, unless $force is true.
 *
 * @param bool $force
 * @return array what was done, one line per changed table
 */
function openkis_SyncSurveyGroups($force = false)
{
    global $_FN;
    $done = array();
    $statefile = "{$_FN['datadir']}/openkis_survey_groups.synced";
    $state = array();
    if (!$force && file_exists($statefile))
    {
        $state = @json_decode(@file_get_contents($statefile), true);
        if (!is_array($state))
            $state = array();
    }
    $newstate = array();
    $changed = false;
    foreach (openkis_SurveyLinks() as $surveytable => $link)
    {
        list($codefield, $itemtable) = $link;
        if (!file_exists("{$_FN['datadir']}/{$_FN['database']}/$surveytable.php") || !file_exists("{$_FN['datadir']}/{$_FN['database']}/$itemtable.php"))
            continue;
        $surveys = FN_XMDBTable($surveytable);
        $items = FN_XMDBTable($itemtable);
        if (!$surveys || !$items || !isset($surveys->fields['groupview'], $surveys->fields[$codefield], $items->fields['groupview'], $items->fields['code']))
            continue;
        // the update time has a one second resolution: a change made in the
        // same second as this run must not be taken as already seen
        $stamp = min(time() - 1, max($surveys->GetLastUpdateTime(), $items->GetLastUpdateTime()));
        $newstate[$surveytable] = isset($state[$surveytable]) ? $state[$surveytable] : 0;
        if (isset($state[$surveytable]) && $state[$surveytable] >= $stamp && $stamp < time() - 1)
            continue;
        $restricted = array();
        foreach ((array) $items->GetRecords(false, false, false, false, false, array("code", "groupview")) as $item)
        {
            if (trim(strval($item['groupview'])) !== "")
                $restricted[strval($item['code'])] = strval($item['groupview']);
        }
        $count = 0;
        if (count($restricted) > 0)
        {
            $pk = $surveys->primarykey;
            foreach ((array) $surveys->GetRecords(false, false, false, false, false, array($pk, $codefield, "groupview")) as $survey)
            {
                $code = strval($survey[$codefield]);
                if (isset($restricted[$code]) && strval($survey['groupview']) !== $restricted[$code])
                {
                    $surveys->UpdateRecord(array($pk => $survey[$pk], "groupview" => $restricted[$code]));
                    $count++;
                }
            }
        }
        if ($count > 0)
            $done[] = "$surveytable: " . FN_Translate("survey records given their item's groups") . " $count";
        $newstate[$surveytable] = $stamp;
        $changed = true;
    }
    if ($changed && is_writable($_FN['datadir']))
        @file_put_contents($statefile, json_encode($newstate));
    return $done;
}

/**
 * Moves the counters that give the ids of new records past the highest id in
 * each MySQL table, e.g. after records were inserted directly in the
 * database. Without it finis notices a taken id on the next insert and
 * re-syncs that counter by itself.
 *
 * @return array what was done, one line per counter
 */
function openkis_SyncRecordIds()
{
    global $_FN;
    $done = array();
    foreach (glob("{$_FN['datadir']}/{$_FN['database']}/*.php") as $file)
    {
        $table = FN_XMDBTable(basename($file, ".php"));
        if (!$table || !method_exists($table, "SyncAutoincrement"))
        {
            continue;
        }
        foreach ($table->SyncAutoincrement() as $field => $next)
        {
            $done[] = "{$table->tablename}: " . FN_Translate("next record id") . " $next";
        }
    }
    if (empty($done))
    {
        $done[] = FN_Translate("record id counters: nothing to re-sync");
    }
    return $done;
}

/**
 * 
 * @param type $row
 */
function openkis_GetItemPosition($row)
{
    //dprint_r($row,"splx","red");
    $table_coordinatestypes = FN_XMDBTable("ctl_coordinatestypes");
    $lat_ori = $row['latitude_txt'];
    $lon_ori = $row['longitude_txt'];
    $lat_wgs84 = $row['latitude'];
    $lon_wgs84 = $row['longitude'];
    
    if ($lat_wgs84 == "" && $lat_ori == "" && $lon_ori == "")
    {
        $ret['lat'] = 0;
        $ret['lon'] = 0;
        $ret['elevation'] = 0;
        return $ret;
    }
    if ($lat_ori == "" && $lon_ori == "")
    {
        $lat_ori = $lat_wgs84;
        $lon_ori = $lon_wgs84;
        
    }
    $coordinatestypes = isset($row['coordinates_type']) ? $row['coordinates_type'] : "";
    if ($coordinatestypes == "")
    {
        if (false !== stristr($lon_ori, "mario"))
        {
            $coordinatestypes = "GEOMONTEMARIO";
        }
        if (false !== stristr($lon_ori, "mario"))
        {
            $coordinatestypes = "GEOMONTEMARIO";
        }
        if (strstr($lat_ori, ".") || strstr($lat_ori, ",") || strstr($lat_ori, "°"))
            $coordinatestypes = "GEOWGS84";
        else
            $coordinatestypes = "UTMWGS8432";
        // the type is guessed: log it for the admins (container logs), and
        // print it in the page only for an admin asking for ?debug
        $msg = "$lat_ori,$lon_ori, coordinatestypes vuoto per {$row['code']} - force $coordinatestypes";
        error_log("openkis: $msg");
        if (isset($_GET['debug']) && FN_IsAdmin())
            dprint_r($msg, "", "red");
    }

    $items_ct = XMETAFKLookup::GetRecord($table_coordinatestypes, "coordinates_type", $coordinatestypes, "proj4");

    $proj = (!empty($items_ct['proj4'])) ? $items_ct['proj4'] : "";
    //dprint_r($items_ct);
    //dprint_r($proj);

    $CONVERTER = new openkis_geoconverter($lat_ori, $lon_ori, $coordinatestypes, $proj);
    $coords_wgs84 = $CONVERTER->getWGS84Geo();
    $coords_wgs84dms = $CONVERTER->getGEO_DMS("WGS84");
    $coords_utm = $CONVERTER->getWGS84UTM();

    $wgs84_lat = $coords_wgs84['latitude'];
    $wgs84_lon = $coords_wgs84['longitude'];
    $ret['lat'] = str_replace(",", ".", round($wgs84_lat, 7));
    $ret['lon'] = str_replace(",", ".", round($wgs84_lon, 7));
    $ret['lat_dms'] = $coords_wgs84dms['lat'];
    $ret['lon_dms'] = $coords_wgs84dms['lon'];

    $ret['y'] = str_replace(",", ".", round($coords_utm['northing'], 7));
    $ret['x'] = str_replace(",", ".", round($coords_utm['easting'], 7));
    $ret['zone'] = $coords_utm['zone'];

    $elevation = $row['elevation'];
    if (empty($elevation) && !empty($row['elevation_map']))
    {
        $elevation = $row['elevation_map'];
    }
    if (empty($elevation) && !empty($row['elevation_gps']))
    {
        $elevation = $row['elevation_gps'];
    }
    $ret['elevation'] = str_replace(",", ".", round(floatval($elevation), 7));
    return $ret;
}

/**
 * 
 * @param type $str
 * @return type
 */
function openkis_floatfrmt($str)
{

    return str_replace(",", ".", $str);
}

/**
 * 
 * @staticvar array $images
 * @param type $itemvalues
 * @param type $mod
 * @return type
 */
function openkis_GetIcon($itemvalues, $mod)
{
    
    
    
    
    
    
    global $_FN;
    $trend = "";
    $air = "";
    $iconparams = array();
    $iconparams['mod'] = $mod;
    //discendente
    if (isset($itemvalues['depth_negative']) && $itemvalues['depth_negative'] !== "" && abs(intval($itemvalues['depth_negative'])) >= intval($itemvalues['depth_positive']))
    {
        $iconparams['trend'] = "desc";
    }
    //ascendente
    elseif (isset($itemvalues['depth_positive']) && $itemvalues['depth_positive'] !== "" && abs(intval($itemvalues['depth_positive'])) >= intval($itemvalues['depth_negative']))
    {
        $iconparams['trend'] = "asc";
    }
    //orizzontale
    elseif (isset($itemvalues['depth_negative']) && $itemvalues['depth_negative'] !== "" && abs($itemvalues['depth_negative']) == 0 && $itemvalues['depth_positive'] == 0)
    {
        $iconparams['trend'] = "hori";
    }
    elseif (isset($itemvalues['depth_total']) && $itemvalues['depth_total'] == 0)
    {
        $iconparams['trend'] = "hori";
    }


    if (!empty($itemvalues['hydrology']) &&
            (
            stristr($itemvalues['hydrology'], "torrents") !== false ||
            stristr($itemvalues['hydrology'], "siphons") !== false ||
            stristr($itemvalues['hydrology'], "lakes") !== false
            )
    )
    {
        $iconparams['type'] = "water";
    }
    if (!empty($itemvalues['hydrology']) && (false !== stristr($itemvalues['hydrology'], "emitting")))
    {
        $iconparams['type'] = "emitting";
    }
    if (!empty($itemvalues['hydrology']) && (false !== stristr($itemvalues['hydrology'], "issuing")))
    {
        $iconparams['type'] = "emitting";
    }




    //by name------->
    if (empty($iconparams['type']))
    {
        if (!empty($itemvalues['name']) && (stristr($itemvalues['name'], "risorgenza") !== false || stristr($itemvalues['name'], "sorgente") !== false))
        {
            $iconparams['type'] = "emitting";
        }
        if (!empty($itemvalues['synonyms']) && (stristr($itemvalues['synonyms'], "risorgenza") !== false || stristr($itemvalues['synonyms'], "sorgente") !== false))
        {
            $iconparams['type'] = "emitting";
        }
        if (!empty($itemvalues['name']) && (stristr($itemvalues['name'], "inghiottitoio") !== false ))
        {
            $iconparams['type'] = "absorbent";
        }
        if (!empty($itemvalues['synonyms']) && (stristr($itemvalues['synonyms'], "inghiottitoio") !== false ))
        {
            $iconparams['type'] = "absorbent";
        }
    }
    //by name-------<

    if (!empty($itemvalues['meteorology']) && ($itemvalues['meteorology'] == "suck_during_cold" ))
    {
        $iconparams['meteorology'] = "suck_during_cold";
    }
    if (!empty($itemvalues['meteorology']) && ($itemvalues['meteorology'] == "blow_during_heat"))
    {
        $iconparams['meteorology'] = "blow_during_heat";
    }

    if (!empty($itemvalues['meteorology']) && ($itemvalues['meteorology'] == "blow_during_cold"))
    {
        $iconparams['meteorology'] = "blow_during_cold";
    }
    if (!empty($itemvalues['meteorology']) && ($itemvalues['meteorology'] == "suck_during_heat"))
    {
        $iconparams['meteorology'] = "suck_during_heat";
    }
    if (!empty($itemvalues['meteorology']) && $itemvalues['meteorology'] == "none")
    {
        unset($iconparams['meteorology']);
    }


    if (!empty($itemvalues['fauna']) && stristr($itemvalues['fauna'], "chirotteri") !== false)
    {
        $iconparams['fauna'] = "bats";
    }
    if (!empty($itemvalues['closed']) && $itemvalues['closed'] != "N")
    {
        $iconparams['closed'] = "closed";
    }
    if (function_exists("openkis_GetIcon_custom"))
    {
        return openkis_GetIcon_custom($iconparams,$itemvalues, $mod);
    }    
    $name = implode("_", $iconparams);
    $image = "{$_FN['datadir']}/openkis_icons/{$name}.png";
    //dprint_r($image);
    if (!file_exists($image) || !empty($_GET['nocache']))
    {
        openkis_MakeIcon($iconparams);
    }
    return $image;
}

/**
 * 
 * @param type $type
 */
function openkis_MakeIcon($iconparams)
{
    global $_FN;
    $x = 128;
    $y = 128;
    $maxx = 64;
    $maxy = 64;
    if (!file_exists("{$_FN['datadir']}/openkis_icons"))
    {
        mkdir("{$_FN['datadir']}/openkis_icons");
    }
    $final_img = imagecreatetruecolor($x, $y); // where x and y are the dimensions of the final image
    imagesavealpha($final_img, true);
    $trans_background = imagecolorallocatealpha($final_img, 0, 0, 0, 127);
    imagefill($final_img, 0, 0, $trans_background);
    if (!is_array($iconparams))
    {
        $iconparams=array();
    }
    foreach ($iconparams as $val)
    {
        if (file_exists("extra/openkis/icons/{$iconparams['mod']}/$val.png"))
        {
            $image = imagecreatefrompng("extra/openkis/icons/{$iconparams['mod']}/$val.png");
            //imagecopymerge($final_img,$image,0,0,0,0,$x,$y,100);
            //imagecopymerge_alpha($final_img,$image,0,0,0,0,$x,$y,100);
            imagecopy($final_img, $image, 0, 0, 0, 0, $x, $y);
        }
    }
    $name = implode("_",$iconparams);
    $thumb = imagecreatetruecolor($maxx, $maxy);
    $white = imagecolorallocate($thumb, 255, 255, 200);
    imagecolortransparent($thumb, $white);
    imagefilledrectangle($thumb, 0, 0, $maxx, $maxy, $white);
    imagecopyresampled($thumb, $final_img, 0, 0, 0, 0, $maxx, $maxy, $x, $y);
    imagepng($thumb, "misc/openkis_icons/$name.png");
}

/**
 * 
 * @param type $dst_im
 * @param type $src_im
 * @param type $dst_x
 * @param type $dst_y
 * @param type $src_x
 * @param type $src_y
 * @param type $src_w
 * @param type $src_h
 * @param type $pct
 */
function imagecopymerge_alpha($dst_im, $src_im, $dst_x, $dst_y, $src_x, $src_y, $src_w, $src_h, $pct)
{
    // creating a cut resource 
    $cut = imagecreatetruecolor($src_w, $src_h);

    // copying relevant section from background to the cut resource 
    imagecopy($cut, $dst_im, 0, 0, $dst_x, $dst_y, $src_w, $src_h);

    // copying relevant section from watermark to the cut resource 
    imagecopy($cut, $src_im, 0, 0, $src_x, $src_y, $src_w, $src_h);

    // insert cut resource to destination image 
    imagecopymerge($dst_im, $cut, $dst_x, $dst_y, 0, 0, $src_w, $src_h, $pct);
}

/**
 * 
 * @param type $string
 * @return type
 */
function add_db_sl($string)
{
    return str_replace('"', '\\"', $string);
}

function get_iconcoord($lon, $lat, $error = "")
{
    static $icons = array();
    static $idcolore = 1;
//	if ($error!="")
//		$error=1;
    if (!isset($icons[$lon . $lat . md5($error)]))
    {
        $num = $idcolore;
        if ($error != "")
            $error = 1;
        $icon = "icon.php?t=$num&n=$idcolore&e=$error";
        $icons[$lon . $lat . md5($error)] = $icon;
        $idcolore++;
    }
    return $icons[$lon . $lat . md5($error)];
}

//---------latitude---------------------------------------<
//---------file--------------------------------------->
//---------file---------------------------------------<

/**
 * 
 * @param string $field
 * @param string $title
 * @param string $value
 * @param string $st
 * @param string $et
 */
function xmldb_viewfilecatasto($row, $path, $databasename, $tablename, $field, $title, $value, $st, $et)
{
    global $_FN;
    if (file_exists("extra/openkis/custom/{$_FN['openkis_custom']}/form_offline.html"))
    {
        $str = file_get_contents("extra/openkis/custom/{$_FN['openkis_custom']}/form_offline.html");
    }
    else
    {
        $str = file_get_contents("extra/openkis/form_offline.html");
    }

    $htmlout = "";
    $t = xmldb_table($databasename, $tablename, $path);
    $pk = $t->primarykey;
    $fileimage = isset($row[$pk]) ? "$path/$databasename/$tablename/" . $row[$pk] . "/" . $field['name'] . "/" . $row[$field['name']] : "";
    $fileimage2 = isset($row[$pk]) ? "" . $row[$pk] . "/" . $field['name'] . "/" . $row[$field['name']] : "";
    $htmlout .= " \n$st$title ";
    $icon = fn_GetIconByFilename($row[$field['name']]);
    $htmlout .= "<img src=\"$icon\" alt =\"\"/>&nbsp;";
    $htmlout .= "\n<a title=\"Download $value\" href=\"?mod={$_FN['vmod']}&amp;mode=go&amp;downloadfile=$fileimage2\"  >$value</a>&nbsp;&nbsp;";
    $fsize = 0;
    if (file_exists($fileimage))
        $fsize = filesize($fileimage);
    $suff = "bytes";
    if ($fsize > 1024)
    {
        $fsize = round($fsize / 1024, 2);
        $suff = "Kb";
    }
    if ($fsize > 1024)
    {
        $fsize = round($fsize / 1024, 2);
        $suff = "Mb";
    }
    $paramsTable = array("databasename"=>$databasename);
    $stat = new XMDBTable( $tablename . "_download_stat", $paramsTable);
    $val = $stat->GetRecordByPrimaryKey($fileimage2);
    //dprint_r($stat);
    $count = isset($val['numdownload']) ? $val['numdownload'] : 0;
    $st = " | $count Download";
    $htmlout .= "&nbsp;($fsize $suff$st)$et";
    return $htmlout;
}

function openkis_TextToAscii($text)
{
    $text = strtolower(str_replace(" ", "_", $text));
    $text = preg_replace("/à/s", "a", $text);
    $text = preg_replace("/á/s", "a", $text);
    $text = preg_replace("/è/s", "e", $text);
    $text = preg_replace("/é/s", "e", $text);
    $text = preg_replace("/ì/s", "i", $text);
    $text = preg_replace("/í/s", "i", $text);
    $text = preg_replace("/ò/s", "o", $text);
    $text = preg_replace("/ó/s", "o", $text);
    $text = preg_replace("/ù/s", "u", $text);
    $text = preg_replace("/ú/s", "u", $text);
    $text = preg_replace("/[^A-Z^a-z_0-9]/s", "_", $text);
    $text = str_replace("-", "_", $text);
    $text = str_replace(".", "_", $text);
    return $text;
}

?>
