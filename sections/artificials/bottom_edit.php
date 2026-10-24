<?php
$id = FN_GetParam("id", $_GET, "html");
if ($id === "")
{
    $id = FN_GetParam("id", $_POST, "html");
}

// Region hook: a region can add its own additions to the edit form with
// extra/openkis/custom/<region>/bottom_edit_<mod>.php (Liguria: the AI survey
// analysis box). The record validator banner of upstream e908de8 is not taken
// yet; when it is, it goes after this hook.
if (!empty($_FN['openkis_custom']))
{
    $region_bottom_edit = "extra/openkis/custom/{$_FN['openkis_custom']}/bottom_edit_{$_FN['mod']}.php";
    if (file_exists($region_bottom_edit))
    {
        include $region_bottom_edit;
    }
}

$html .= "<hr /><a class=\"btn btn-primary\" href=\"{$_FN['siteurl']}openkis_photos.php?id={$id}&t=ctl_{$_FN['mod']}\">Inserimento rapido foto</a><hr />";
?>
