<?php

/*
 * Funzioni specifiche per il catasto speleologico piemontese
 */
global $_FN; //variabile globale condivisa da tutto il programma Flatnux
//questa riga di codiceassegna la funzione da richiamare dopo 
//l'inserimento di una grotta, la funzione riceve come parametro un array con i 
//dati appena inseriti:
$_FN['modparams']["caves"]['editorparams']['table']['function_on_insert']="GeneraNumero";
$_FN['modparams']["artificials"]['editorparams']['table']['function_on_insert']="GeneraNumeroArtificials";
// map centred on the region (unless changed in the admin section "configopenkis")
openkis_SetRegionMapCenter(45.62, 9.75, 8);


/**
 * Assigns the first free number to a new artificial cavity: CALO1, CALO2, ...
 * The "CA" prefix (as in Piemonte and Umbria) keeps the codes apart from the
 * natural caves, which use LO1, LO2, ...
 *
 * @param array $values
 * @return array
 */
function GeneraNumeroArtificials($values)
{
    if (!empty($values['code']))
    {
        return $values;
    }
    $prefix = "CALO";
    $table = FN_XMDBTable("ctl_artificials");
    $used = array();
    foreach ($table->GetRecords(false, false, false, false, false, "id|code") as $item)
    {
        // CALO12.2 -> 12; codes in another format are ignored
        $code = explode(".", strtoupper(trim($item['code'])));
        if (preg_match('/^' . $prefix . '([0-9]+)$/', $code[0], $m))
        {
            $used[intval($m[1])] = true;
        }
    }
    for ($i = 1; isset($used[$i]); $i++)
        ;
    $values['code'] = $prefix . $i;
    return $table->UpdateRecord($values);
}

/**
 * 
 * @param string $values
 * @return string
 */
function GeneraNumero($values)
{
//se il numero non è già impostato non faccio nulla
    if ($values['code']!= "")
    {
        return $values;
    }
//inizializza la variabile oggetto che punta alla tabella
    $table=FN_XMDBTable("ctl_caves");
//recupera i campi "id" e "code" di tutte le grotte (code corrisponde al numero di catasto) 
    $grotte=$table->GetRecords(false,false,false,false,false,"id|code");
    $max=0; //variabile che conterrà il primo numero libero
    $grotte_by_code=array(); //array che contiene le grotte per codice
    foreach($grotte as $k=> $grotta)
    {
        $grotte_by_code[$k]=$grotta;
//elimino a destra del "." esempio PI1210.2
        $tmp=explode(".",$grotta['code']);
        $tmp=$tmp[0];
//prendo solo il numero
        $numero=intval(str_replace("LO","",str_replace("AO","",$grotta['code'])));
        $grotte_by_code[$numero]['num']=$numero;
        if ($numero > $max)
        {
            $max=$numero;
        }
    }
    $max++;

    $regione="LO";

//cerca il primo numero libero
    ksort($grotte_by_code);
    for($i=1;
    ; $i++)
    {
        if (empty($grotte_by_code[$i]))
        {
            $max=$i;
            break;
        }
    }
    $values['code']=$regione.$max;
    return $table->UpdateRecord($values);
}

/**
 * Installs the Lombardia table definitions (custom/lombardia/<table>.php) in
 * the data directory: caves, springs and artificial cavities.
 *
 * Runs on every request, so the fast path is one stat of each custom file and
 * one read of a small sentinel that records which version of it was last
 * installed. A definition is copied only when the custom file changed since
 * then and differs from the installed one, so it is applied on a fresh install
 * too (where the generic definition was just copied with a newer mtime) and a
 * definition already in place is left alone.
 */
function InizializzaDB()
{
    foreach (array("ctl_caves", "ctl_springs", "ctl_artificials") as $tablename)
    {
        cglombardia_InstallTableDefinition($tablename);
    }
}

/**
 * @param string $tablename
 */
function cglombardia_InstallTableDefinition($tablename)
{
    global $_FN;
    $datadir = empty($_FN['datadir']) ? "misc" : $_FN['datadir'];
    $database = empty($_FN['database']) ? "fndatabase" : $_FN['database'];
    $src = __DIR__ . "/$tablename.php";
    $dest = "$datadir/$database/$tablename.php";
    $sentinel = "$datadir/openkis_lombardia_$tablename.installed";
    $signature = @filesize($src) . "-" . @filemtime($src);
    if (file_exists($sentinel) && trim(@file_get_contents($sentinel)) === $signature)
    {
        return;
    }
    if (!is_dir("$datadir/$database") || !is_writable("$datadir/$database"))
    {
        return;
    }
    $content = @file_get_contents($src);
    if ($content === false || $content === "")
    {
        return;
    }
    if (!file_exists($dest) || md5_file($dest) !== md5($content))
    {
        if (@file_put_contents($dest, $content) === false)
        {
            return;
        }
    }
    @file_put_contents($sentinel, $signature);
}



/**
 * Validator of the "provincia" field of caves, springs and artificial
 * cavities: a user may save a record only in a province of their RW_ groups.
 *
 * @global array $_FN
 * @param string $prov
 * @return boolean|string true, or the error message
 */
function cglombardia_checkprovincia($prov)
{
    global $_FN;
    //echo "<script>console.log('".$_FN."');</script>";
    if (FN_IsAdmin())
    {
        return true;
    }
    $group="RW_CO_LC_SO_MI_PV";
    if (false!== stripos($_FN['uservalues']['group'],"RW_$prov"))
    {
        return true;
    }
    if (false!== stripos("CO_LC_SO_MI_PV","$prov") && FN_UserInGroup($_FN['user'],"RW_CO_LC_SO_MI_PV"))
    { 
        return true;
    }

    // users enabled on the record ("Gestisci gli utenti abilitati alla
    // modifica") can keep editing it; the record is looked up in the table of
    // the section being edited (caves, springs or artificial cavities)
    $section = "caves";
    if (!empty($_FN['mod']) && in_array($_FN['mod'], array("caves", "springs", "artificials")))
    {
        $section = $_FN['mod'];
    }
    require_once "{$_FN['src_finis']}/modules/dbview/FNDBVIEW.php";
    $config = FN_LoadConfig("modules/dbview/config.php", $section);
    $id = FN_GetParam("id", $_GET);
    if ($id && !empty($config['tables']))
    {
        $table = FN_XMDBTable($config['tables']);
        $oldvalues = $table->GetRecordByPk($id);
        $view = new FNDBVIEW($config);
        if (is_array($oldvalues) && $view->UserCanEditField($_FN['user'], $oldvalues))
        {
            return true;
        }
    }

    return "Non puoi inserire dati nella provincia di $prov";
}


/**
 * funzione che genera i codici FSLO, legge tutte le grotte e aggiorna il campo "code_fslo"
 * 
 * @global array $_FN
 */
function GeneraCodiciFSLO($silent=false)
{
    global $_FN;
    $table =FN_XMDBTable("ctl_caves");
    $all=$table->GetRecords();
    if (FN_IsAdmin())
    {
        echo "Aggiornamento codici FSLO:<br />";
        foreach($all as $item)
        {
            $newitem=array();
            $newitem['id']=$item['id'];
            $codenum = str_replace("LO","",($item['code']));
            $codice="LO{$item['provincia']}{$codenum}";
            if ($item['code']!= $codice)
            {
                $newitem['code_fslo']=$codice;
                $table->UpdateRecord($newitem);
                if (!$silent)
                    echo "<span style=\"color:red\">Aggiorno $codice</span><br />";
                //die();
            }
            else
            {
                if (!$silent)
                    echo "OK $codice<br />";
            }
        }
    }
    else
    {
        if (!$silent)
            echo "funzione riservata agli amministratori";
    }
}


InizializzaDB();
