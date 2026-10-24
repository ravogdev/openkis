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
 *    public_map field: only the records with public_map = "Y" are served
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
 * Keeps only the records marked public_map = "Y" when $access is "public".
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
    $rows = FN_XMETADBQuery("SELECT $pk FROM {$config['tables']} WHERE public_map LIKE 'Y'");
    if (is_array($rows))
    {
        foreach ($rows as $row)
            $public[strval($row[$pk])] = true;
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
 * Drops every cached map export, recalculates the coordinates and re-syncs
 * the record id counters, e.g. after the data were changed directly in the
 * database.
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
    if (!empty($itemvalues['meteorology']) || $itemvalues['meteorology'] == "blow_during_heat")
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
