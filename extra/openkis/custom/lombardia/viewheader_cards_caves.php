<?php
/**
 * Lombardia cave sheet: fields of each card, in display order.
 *
 * Included by sections/caves/viewheader.php, which then shows the cards.
 * Fields not listed here and not in $openkis_cards_exclude end up in a final
 * "other data" card. Empty fields are hidden, and a card with no filled field
 * is not shown.
 */
$openkis_cards = array(
    "identification" => array("code_fslo", "synonyms", "caveslinks", "firstreference"),
    "location" => array("regione", "provincia", "comune", "localita", "mount", "velley", "areas",
        "latitude_txt", "longitude_txt", "coordinates_type", "elevation", "elevation_map", "elevation_gps",
        "map_denomination", "map_edition", "location_evaluation_options", "location_evaluation",
        "check", "check_date"),
    "dimensions" => array("lenght_total", "lenght_planimetric", "lenght_extension", "lenght_scope",
        "depth_positive", "depth_negative", "depth_total"),
    "characteristics" => array("geologicalformation", "age", "hydrology", "trend",
        "practicability", "practicability_text", "meteorology", "meteorology_text",
        "archeological", "marine", "lake", "environmentalrisk", "tourist",
        "closed", "closed_notes", "destroyed"),
    "description" => array("description", "authordescription", "itinerary", "authoritinerary", "wells"),
    "fauna" => array("fauna", "authorfauna"),
    "geology" => array("geology"),
    "history" => array("history", "authorhistory"),
    "groups and chronology" => array("associations", "DATAGG", "chronology", "notes", "changelog"),
    "sheet data" => array("public_map", "recordinsert", "username", "recordupdate", "userupdate",
        "import_rawdata"),
);
// long free texts shown as a block (title above the text)
$openkis_cards_longtext = array_merge($openkis_cards_longtext,
    array("practicability_text", "meteorology_text", "location_evaluation"));
