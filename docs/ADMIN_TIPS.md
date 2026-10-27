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
- **Table structure is cached for up to 10 minutes.** After adding or changing a column by hand, use "Clear cache" or restart the web container, so the change is seen at once.

## Regional sites

- **Country and region pre-filled in the insert forms.** On the italia, marche, liguria and umbria sites the "new cave" form (and, except on liguria, the "new artificial cavity" and "new spring" forms) starts with country ITALIA and the site's region. The italia site, being national, pre-fills no region: the curator picks it (it used to pre-fill MARCHE by mistake). The values are only a starting point in the form; records saved from the API or an import get no default.

## Database schema changes

- **Missing columns are added automatically.** When a table definition gains a field, OpenKIS adds the column on the first page that opens that table. On large tables, that page is slow once. For big imports, run the migration SQL first, before the web container starts.

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
