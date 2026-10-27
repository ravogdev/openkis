<?php
ob_start();
global $is_gzip;
global $_FN;
require_once "loadfinis.php";
$REQUEST_URI=$_SERVER['REQUEST_URI'];
//$_FN['enable_compress_gzip']=0;
$url=explode("openkis_proxy.php/",$REQUEST_URI);
if (!isset($url[1]))
{
    die();
}
$url=$url[1];


if (strpos($url,"http://")!== false || strpos($url,"https://")!== false)
{
    $contents=getWebPage($url);
}
else
{
    $url=$_FN['siteurl'].$url;
    $contents=getWebPage($url);
}
while(false!== @ob_end_clean()
);
if ($contents['errno'] || empty($contents['http_code']))
{
    // no answer (timeout, DNS, refused): an error, not an empty "200" page
    http_response_code(502);
    header("Access-Control-Allow-Origin: *");
    die();
}
// the upstream status, so a map server's 503 isn't passed on as 200
http_response_code($contents['http_code']);
if (!empty($contents['content_type']))
{
    // the upstream type (image/png for map tiles), not PHP's default text/html
    header("Content-Type: {$contents['content_type']}");
}
if ($is_gzip)
{
    header("Content-Encoding: gzip");
}
header("Access-Control-Allow-Origin: *");
die($contents['content']);

/**
 *
 * @global type $_FN
 * @param type $url
 * @return type 
 */
function getWebPage($url)
{
    global $is_gzip;
    global $_FN;
    $is_gzip=0;
    $options=array(
        CURLOPT_RETURNTRANSFER=>true,// ritorna la pagina
        CURLOPT_HEADER=>true,// non ritornare l'header
        // CURLOPT_REFERER => $url,      // settiamo il referer
        CURLOPT_FOLLOWLOCATION=>true,// seguiamo i redirects
        // CURLOPT_ENCODING => FN_i18n("_CHARSET"), // tutti gli encodings
        CURLOPT_USERAGENT=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1",// L'identit� del browser
        CURLOPT_AUTOREFERER=>true,// setta il referer nel redirect
        CURLOPT_CONNECTTIMEOUT=>120,// timeout sulla connessione
        CURLOPT_TIMEOUT=>120,// timeout sulla risposta
        CURLOPT_MAXREDIRS=>10,// fermati dopo il decimo redirect
    );

    // curl reads the port from the URL itself. The old code split the URL on ":" and took any
    // number after the second one as the port, so a WMS query with "CRS=EPSG:3857" went to port 3857.
    $ch=curl_init($url);     // impostiamo l'url per il download

    curl_setopt_array($ch,$options);   //settiamo le opzioni
    $ret=curl_exec($ch);    //facciamo richiesta della pagina
    $sections=explode("\x0d\x0a\x0d\x0a",(string)$ret,2);
    if (!isset($sections[1]))
    {
        $sections[1]="";
    }
    while(!strncmp($sections[1],'HTTP/',5))
    {
        $sections=explode("\x0d\x0a\x0d\x0a",$sections[1],2);
        if (!isset($sections[1]))
        {
            $sections[1]="";
        }
    }
    $headers=$sections[0];
    $data=$sections[1];
    if (preg_match('/^Content-Encoding: gzip/mi',$headers))
    {
        $is_gzip=1;
    }
    else
    {
        if ($_FN['enable_compress_gzip'])
        {
            $data=gzencode($data);
            $is_gzip=1;
        }
    }
    $err=curl_errno($ch);
    $errmsg=curl_error($ch);
    $header=curl_getinfo($ch);
    curl_close($ch);
    $header['errno']=$err;   //eventuali errori
    $header['errmsg']=$errmsg;  //header
    $header['content']=$data;   //il contenuto della pagina quello che ci interessa
    return $header;
}

?>