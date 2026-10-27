<?php
/**
 * OpenKIS first-run installer.
 *
 * Copies the OpenKIS table definitions (misc/fndatabase/ctl_*.php) into the
 * data directory when they are missing. Existing definitions are never
 * overwritten, so local customisations are preserved.
 *
 * The MySQL driver creates missing tables and adds missing columns
 * automatically from these definitions, so no SQL dump is needed.
 */
defined('_FNEXEC') or die('Restricted access');

/**
 * Install missing table definitions. Safe to call on every request:
 * a sentinel file in the data directory records the list of definitions
 * already processed and the function returns immediately when nothing changed.
 *
 * @return array names of the definitions copied in this call
 */
function openkis_InstallDefinitions()
{
    global $_FN;
    $datadir = empty($_FN['datadir']) ? "misc" : $_FN['datadir'];
    $database = empty($_FN['database']) ? "fndatabase" : $_FN['database'];
    $src = __DIR__ . "/misc/fndatabase";
    $copied = array();
    if (!is_dir($datadir) || !is_writable($datadir))
    {
        return $copied;
    }
    $files = glob("$src/ctl_*.php");
    if (!is_array($files) || count($files) == 0)
    {
        return $copied;
    }
    sort($files);
    $names = array_map('basename', $files);
    $signature = md5(implode("\n", $names));
    $sentinel = "$datadir/openkis_definitions.installed";
    if (file_exists($sentinel) && trim(@file_get_contents($sentinel)) === $signature)
    {
        return $copied;
    }
    $dest = "$datadir/$database";
    if (!is_dir($dest))
    {
        @mkdir($dest, 0777, true);
    }
    if (!is_dir($dest) || !is_writable($dest))
    {
        return $copied;
    }
    foreach ($files as $file)
    {
        $name = basename($file);
        if (!file_exists("$dest/$name"))
        {
            if (@copy($file, "$dest/$name"))
            {
                $copied[] = $name;
            }
        }
    }
    @file_put_contents($sentinel, $signature);
    return $copied;
}

/**
 * Drops a deny-all .htaccess in the data folder so that, on an Apache install
 * without the container's site config, the uploaded files are not reachable by
 * their storage path: they are served only through openkis_file.php, which
 * checks who may read each one (issue #88). PHP is turned off there too. Other
 * web servers (nginx, Caddy) ignore .htaccess and must block the folder in
 * their own config; the shipped Docker image already does.
 *
 * @param string $dest the data folder (datadir/database)
 * @return void
 */
function openkis_InstallDataGuard($dest)
{
    $htaccess = "$dest/.htaccess";
    if (file_exists($htaccess))
        return;
    // Deny every direct request to the folder. That alone stops the uploaded
    // files being served or any .php in the folder running, so PHP does not
    // need turning off here (and php_admin_flag is not allowed in .htaccess).
    $rules = "# OpenKIS: uploaded files are served through openkis_file.php after a\n"
        . "# permission check; their storage path must never work as a URL.\n"
        . "<IfModule mod_authz_core.c>\n"
        . "    Require all denied\n"
        . "</IfModule>\n"
        . "<IfModule !mod_authz_core.c>\n"
        . "    Order allow,deny\n"
        . "    Deny from all\n"
        . "</IfModule>\n";
    @file_put_contents($htaccess, $rules);
}

/**
 * Ensures the data folder carries the deny-all .htaccess, whatever the state
 * of the definitions sentinel (so existing installs are protected too).
 *
 * @return void
 */
function openkis_InstallEnsureDataGuard()
{
    global $_FN;
    $datadir = empty($_FN['datadir']) ? "misc" : $_FN['datadir'];
    $database = empty($_FN['database']) ? "fndatabase" : $_FN['database'];
    $dest = "$datadir/$database";
    if (is_dir($dest) && is_writable($dest))
        openkis_InstallDataGuard($dest);
}

/**
 * Adds to the definitions already in the data directory the fields that were
 * added to the shipped ones after the site was installed (openkis_InstallDefinitions
 * never overwrites a definition). Only the listed fields are copied, each one
 * from its <field> block in install/misc/fndatabase, and only when the
 * installed definition does not have a field with that name; the MySQL driver
 * then adds the column. A sentinel makes it a no-op once done.
 *
 * @return array "table.field" of the fields added in this call
 */
function openkis_InstallMissingFields()
{
    global $_FN;
    // table => fields added to the shipped definitions after the first release
    $fields = array(
        "ctl_caves" => array("lenght_scope"),
        "ctl_caves_versions" => array("lenght_scope"),
        "ctl_cavesystems" => array("lenght_auto"),
    );
    $datadir = empty($_FN['datadir']) ? "misc" : $_FN['datadir'];
    $database = empty($_FN['database']) ? "fndatabase" : $_FN['database'];
    $src = __DIR__ . "/misc/fndatabase";
    $dest = "$datadir/$database";
    $added = array();
    $sentinel = "$datadir/openkis_fields.installed";
    $signature = md5(serialize($fields));
    if (file_exists($sentinel) && trim(@file_get_contents($sentinel)) === $signature)
    {
        return $added;
    }
    if (!is_dir($dest) || !is_writable($dest))
    {
        return $added;
    }
    $done = true;
    foreach ($fields as $table => $names)
    {
        $installed = "$dest/$table.php";
        if (!file_exists($installed))
        {
            // created later from the shipped definition, which has the fields
            continue;
        }
        $content = @file_get_contents($installed);
        $shipped = @file_get_contents("$src/$table.php");
        if ($content === false || $shipped === false || strpos($content, "</tables>") === false)
        {
            $done = false;
            continue;
        }
        $changed = false;
        foreach ($names as $name)
        {
            if (preg_match('/<name>\s*' . preg_quote($name, '/') . '\s*<\/name>/', $content))
            {
                continue;
            }
            if (!preg_match('/[ \t]*<field>\s*<name>\s*' . preg_quote($name, '/') . '\s*<\/name>.*?<\/field>\s*?\n/s', $shipped, $m))
            {
                continue;
            }
            $pos = strrpos($content, "</tables>");
            $content = substr($content, 0, $pos) . $m[0] . substr($content, $pos);
            $changed = true;
            $added[] = "$table.$name";
        }
        if ($changed && @file_put_contents($installed, $content) === false)
        {
            $done = false;
        }
    }
    if ($done)
    {
        @file_put_contents($sentinel, $signature);
    }
    return $added;
}

openkis_InstallDefinitions();
openkis_InstallMissingFields();
openkis_InstallEnsureDataGuard();
