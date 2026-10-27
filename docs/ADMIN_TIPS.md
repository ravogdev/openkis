# Tips for administrators and curators

Things the application does on its own, limits that can surprise you, and the right way to do a few routine jobs. These notes apply to the current `develop` and are updated in the same PR as any change that affects them.

*Versione italiana: [ADMIN_TIPS_IT.md](ADMIN_TIPS_IT.md).*

## Logins and passwords

- **Old passwords are upgraded silently.** Accounts imported from the old site may still have an MD5 password hash. Those users log in with their usual password, and at that login the hash is replaced with a modern one. Nobody needs a reset. An MD5 hash stays in the database until its owner logs in again, so inactive accounts keep it.
- **Lockout after wrong passwords.** After 5 failed logins for the same username from the same IP address within 15 minutes, the login is refused, even with the right password, until the 15 minutes have passed. A successful login clears the count, and each lockout is written once to the system log. To unlock someone straight away, delete the files in `misc/_login_attempts/`. "Clear cache" doesn't reset the counters. The limits are `$_FN['login_max_attempts']` and `$_FN['login_lockout_minutes']`.
- **Behind a reverse proxy (Caddy, nginx), the proxy must be trusted.** Otherwise every visitor appears with the proxy's IP address, and five wrong passwords from anyone lock that username for everyone, including the admin. With Docker, `OPENKIS_TRUSTED_PROXIES=docker` (the default) covers the bundled Caddy. A proxy installed directly on the server, or on another machine, must be added to it by address (see the deploy README). Outside Docker, set `$_FN['trusted_proxies']` to the proxy's address.
- **Everyone is logged out once after the security update**, because session cookies are now signed with `misc/secret.key.php`. Include that file in backups. If it is lost, everyone is logged out again.
- **Password reset links** work once and expire after 60 minutes. Links sent before the update no longer work.
- **A deactivated user** is logged out at their next click, not only at their next login.
- **Usernames are saved in lowercase.** "Remember me" lasts 30 days.

## Groups and permissions

- **Section access** (who can see or edit a section) comes from the section settings stored in the database (`fn_sections`). Updating the code doesn't change it.
- **Record visibility.** A record restricted to a group (for example hidden caves) is visible only to members of that group and to admins. Renaming or removing a group hides those records from its former members, without any warning.
- **Public map.** Users who can't open a restricted section see on the public map every cave except those marked **Shown on the public map** = No. The default is Yes, also for caves saved before the field existed, so a curator sets No only to hide a single cave from the public. Group restrictions (`groupview`) still apply, and hide a cave whatever this value. After changing it directly in the database, run **Control center > Utilities > Refresh map data**.
- **Group names are in English.** Hidden caves are restricted to `hidden_caves`, archaeological ones to `archaeologists`; writers of the register are `w_caves`, of fauna `w_fauna`. The old Italian names (`grotte_nascoste`, `archeologi`) are renamed by the Lombardia migration; a group created by hand with an old name is no longer offered when restricting a cave.
- **Admins** (level 10) bypass group checks, including the API key check below.

## MCP server and API keys

- **Who can use an API key:** only admins and members of `mcp_users` (or the groups in `OPENKIS_APIKEY_GROUPS` in `.env`). Other users' keys are refused, and their key isn't shown on their profile.
- **Read-only by default.** Non-admin keys are read only. The write tools (insert, update, upload, delete) need membership of `mcp_write`, or the group in `OPENKIS_MCP_WRITE_GROUP`.
- Admins enable users in **Configuration > MCP server**. That page creates the `mcp_users` and `mcp_write` groups if they are missing.
- **The legacy shared key** (`OPENKIS_MCP_APIKEY`) gives full access as the user in `OPENKIS_MCP_USER`. Keep it empty unless you need it.

## Maps and caches

- **Map exports are cached** (KML, GPX, JSON, markers). The cache is dropped automatically when a record is saved through OpenKIS, and after an hour at the latest.
- **After editing data directly in the database** (an SQL import or a manual `UPDATE`), run **Control center > Utilities > Refresh map data**, or `php refresh-cache.php` inside the container. That refreshes the maps, recalculates coordinates and re-syncs the record id counters. Without it, maps can show old data, and new records can get an id that is already used.
- **Map clicks.** A click on a single point opens its record in another browser window; the point's popup stays on the map, and its link works if the browser blocked the window. When several points are within the click area (6 px around the mouse pointer, 16 px around a finger on a touch screen), a popup lists them, closest first: at most 20 names, then "... (N)" for the rest. On a dense register such as Lombardia a click at regional zoom often hits 60 or more caves, so zoom in to open one. Hovering with the mouse shows up to 5 names. A popup opened near an edge moves the map so that it is fully visible. The map of a record with a point (coordinates mode) is unchanged: a click shows the coordinates with the copy button. The map uses OpenLayers 6.15.1.
- **The map page `bs_map.htm` is generated, don't edit it.** It is `bs_map.tp.html` with the layers file of the region, `bs_map/conf/layers_<OPENKIS_CUSTOM>.js` (`layers_default.js` when the region has none). The Docker container writes it at every start. Outside Docker, `bs_map.php` writes it again whenever it differs (the survey pages call it). Hand edits to `bs_map.htm` are overwritten: change the template or the layers file instead. Before this, a new site kept the copy shipped with the code, without the region's layers.
- **Survey layers on the map** load only for users who can view the Surveys section. Other visitors get an empty layer list, with no error in the browser console; no survey data reaches them.
- **The bibliography box of the cave pages comes from a lookup table.** OpenKIS copies the codes listed in each bibliography item ("Grotte", `codecaves`, and `codeartificials` for artificial cavities) into the table `ctl_bibliography_links`, one row per code, and the cave and artificial cavity pages read it from there. The table is rebuilt from the bibliography on the first cave page opened after a bibliography item is saved through OpenKIS, and on the first one opened when the last rebuild is more than an hour old. After changing the bibliography directly in the database, run **Refresh map data** (it marks the bibliography as changed) or wait up to an hour. Don't edit `ctl_bibliography_links` by hand: it is emptied and refilled at every rebuild.
- **Codes in the bibliography lists are matched exactly**, ignoring spaces around the commas: `LO1172, LO1170` links both caves. A space or a typo inside a code (`LO 2797`) does not match the cave `LO2797`, so that item doesn't appear on its page; fix the list in the bibliography item.
- **The Lombardia cave map opens on CTR_DBT**, Regione Lombardia's technical map, because it is the first base layer in `bs_map/conf/layers_lombardia.js`. It covers only Lombardia: outside the region, and when zoomed out below about zoom 8 (the service stops at 1:3,000,000), the background is white. To open the map on another base layer, add it to the link, for example `bs_map.htm?mod=caves&basemap=Topo`. Browsers can keep the old layer file for a while after an update; a hard refresh (Ctrl+F5) loads the new one.
- **The IGM 1:25000 and geological layers go through `openkis_proxy.php`**, so they need `OPENKIS_ENABLE_PROXY=1`. They are slow (20 to 40 seconds to fill the screen), and ISPRA's server refuses some tiles with an error 503 when it is busy (3 in 100 in our test, up to 1 in 8 in bursts): those squares stay empty and appear as errors in the browser console. Moving or zooming the map asks for them again. The proxy passes ISPRA's answer on as it is (503), and answers 502 when ISPRA doesn't reply within 120 seconds.
- **Satellite and OSM Landscape need API keys** (`MAPTILER_API_KEY`, `THUNDERFOREST_API_KEY` in `.env`, then restart the web container). Without them those two layers stay blank.
- **Table structure is cached for up to 10 minutes.** After adding or changing a column by hand, use "Clear cache" or restart the web container, so the change is seen at once.

## Cave systems

- **"Development refers to" on the cave form.** Each cave record can say whether its development (and depth) refers to the whole cave ("whole cave") or only to the branch of this entrance ("this entrance only"). On Lombardia the field starts empty, on new records too: curators set it when a cave belongs to a cave system. Other regions start new records at "whole cave". Existing records stay empty until someone sets the value.
- **The development of a cave system is recalculated when a cave or a cave system is saved** through OpenKIS (web forms or the MCP server). The value becomes the largest development among the member caves set to "whole cave". If no member is set to "whole cave", it is the sum of the members set to "this entrance only", where an empty development counts as 0. Members with an empty value are ignored. A system whose members are all still empty keeps its stored value. The members are the codes in the system's cave list, matched exactly (spaces around the commas are ignored).
- **The depth of a cave system is never recalculated.** It is always the value entered on the system.
- **Switching it off for one system.** Set **Automatic development recalculation** = No on the cave system, for example after a junction that the member records don't show yet. The development entered by hand is then kept. An empty value counts as Yes.
- **Opening a cave-system page no longer overwrites its length and depth.** Before this change, every view, including an anonymous one, replaced them with the sum of the members' developments, which counted the same passages several times. The page now shows the stored values. When they differ, it also shows in grey the sum of the members' developments and the depth worked out from the entrance elevations.
- **The recalculation is silent.** It doesn't change the system's "last update" or its history. It runs only when the caves or the cave systems have changed since the last run (a time stamp in `misc/_cache/openkis_UpdateCaveSystems.time`). After editing caves or systems directly in the database, run **Control center > Utilities > Refresh map data**, which also recalculates the systems.
- **Lombardia: the old figures are kept.** The old site kept the development and depth of the 10 cave systems only in the legacy columns `SVILRE` and `DTOT`. The database update copies them into the fields the pages use, where those are empty. A curator who sets a member cave to "whole cave" replaces the stored development with that cave's development. Set the system to No first when the stored figure must stay.
- **Once chosen, "Development refers to" can't be emptied in the form**, only changed to the other value. An empty value is possible only through the database.
- **Saving a cave system needs a Code.** The migrated Lombardia systems have none, so the edit form refuses to save until one is entered.

## Regional sites

- **Country and region pre-filled in the insert forms.** On the italia, marche, liguria and umbria sites the "new cave" form (and, except on liguria, the "new artificial cavity" and "new spring" forms) starts with country ITALIA and the site's region. The italia site, being national, pre-fills no region: the curator picks it (it used to pre-fill MARCHE by mistake). The values are only a starting point in the form; records saved from the API or an import get no default.

## Database schema changes

- **Missing columns are added automatically.** When a table definition gains a field, OpenKIS adds the column on the first page that opens that table. On large tables, that page is slow once. For big imports, run the migration SQL first, before the web container starts.
- **Fields added to the shipped definitions reach existing sites.** OpenKIS never replaces a table definition already in `misc/fndatabase`, but it adds to it the few fields that were added to the code later (now `lenght_scope` in `ctl_caves` and `ctl_caves_versions`, and `lenght_auto` in `ctl_cavesystems`), once, at the first request after the update. Fields edited by hand in those files are kept.

## Updates and the Docker image

- **`latest` follows develop.** Every change merged into `develop` publishes a new `robydoc/openkis-web:latest` on Docker Hub, plus a dated tag such as `2026-10-25.1` (UTC date, then 1, 2, ... for each image of that day). It happens only after the automatic test passes; a failing build leaves `latest` on the previous image. So `docker compose pull` on a server can bring new code at any time.
- **Pin a dated tag on the production server.** Set `OPENKIS_IMAGE=robydoc/openkis-web:2026-10-25.1` (for example) in `.env`, try the next one on a test copy, then change the tag and run `docker compose pull && docker compose up -d`. Going back is the same with the older tag, as long as the database has not been changed by the newer version.
- **The image never contains database data.** Data stays in the database volume and in `misc/`; the publishing job fails if any SQL dump ends up in the image. The first start of a new image writes its tag to the web container log ("installing code version ...").

## Record validator

- **The banner at the top of the edit form is a checklist, not an error.** When a cave or an artificial cavity is opened for editing, OpenKIS lists the data that is missing (name, description, entrance coordinates, elevation, survey measurements) or to complete (comune, provincia, reference system, a total depth that doesn't match positive + negative). It never blocks a save. A record with nothing to report shows a green "complete" banner.
- **Expect it on many old records.** On the Lombardia register about one cave in four shows a warning, mostly for a missing description. Tell the curators before the update, so they don't take it for a fault.
- **The rules can be changed per region** in `extra/openkis/custom/<region>/validator_<mod>.php` (Liguria has its own). Lombardia uses the default rules.
- **Switching rules off from `.env`.** `OPENKIS_VALIDATOR_RULES_OFF` lists rules to switch off, overriding the region's choice, for example `OPENKIS_VALIDATOR_RULES_OFF=description` to stop the missing-description warning, or `all` to hide the banner. The keys are `name`, `description`, `coordinates`, `reference_system`, `elevation`, `comune`, `provincia`, `speleometric` and `depth_total`; a regional rule is named by its label. Restart the web container after changing it. Outside Docker, set `$_FN['openkis_validator_rules_off']`.

## Liguria only

- **AI survey analysis.** In the cave and artificial cavity edit forms, a box analyses the survey drawing with OpenAI. It works only when `$_FN['openai_apikey']` is set in `openkis_config.local.php`; without it the box reports that the key is missing. The survey image is sent to OpenAI, and any logged-in user can start an analysis, so each one costs money on the key. The last analysis is kept in `misc/_cache/openkis_ai_survey/` and shown again while the image is unchanged.
