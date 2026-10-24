# Tips for administrators and curators

Things the application does on its own, limits that can surprise you, and the right way to do a few routine jobs. These notes apply to the current `develop` and are updated in the same PR as any change that affects them.

*Versione italiana: [ADMIN_TIPS_IT.md](ADMIN_TIPS_IT.md).*

## Logins and passwords

- **Old passwords are upgraded silently.** Accounts imported from the old site may still have an MD5 password hash. Those users log in with their usual password, and at that login the hash is replaced with a modern one. Nobody needs a reset. An MD5 hash stays in the database until its owner logs in again, so inactive accounts keep it.
- **Lockout after wrong passwords.** After 5 failed logins for the same username from the same IP address within 15 minutes, the login is refused, even with the right password, until the 15 minutes have passed. A successful login clears the count, and each lockout is written once to the system log. To unlock someone straight away, delete the files in `misc/_login_attempts/`. "Clear cache" doesn't reset the counters. The limits are `$_FN['login_max_attempts']` and `$_FN['login_lockout_minutes']`.
- **Behind a reverse proxy (Caddy, nginx), set `trusted_proxies`.** If it isn't set, every visitor appears with the proxy's IP address. Five wrong passwords from anyone then lock that username for everyone, including the admin.
- **Everyone is logged out once after the security update**, because session cookies are now signed with `misc/secret.key.php`. Include that file in backups. If it is lost, everyone is logged out again.
- **Password reset links** work once and expire after 60 minutes. Links sent before the update no longer work.
- **A deactivated user** is logged out at their next click, not only at their next login.
- **Usernames are saved in lowercase.** "Remember me" lasts 30 days.

## Groups and permissions

- **Section access** (who can see or edit a section) comes from the section settings stored in the database (`fn_sections`). Updating the code doesn't change it.
- **Record visibility.** A record restricted to a group (for example hidden caves) is visible only to members of that group and to admins. Renaming or removing a group hides those records from its former members, without any warning.
- **Public map.** Users who can't open a restricted section see on the public map only the caves marked **Shown on the public map** = Yes. New and existing caves start as No, so curators decide which caves are public. Group restrictions (`groupview`) still apply.
- **Admins** (level 10) bypass group checks, including the API key check below.

## MCP server and API keys

- **Who can use an API key:** only admins and members of `mcp_users` (or the groups in `OPENKIS_APIKEY_GROUPS` in `.env`). Other users' keys are refused, and their key isn't shown on their profile.
- **Read-only by default.** Non-admin keys are read only. The write tools (insert, update, upload, delete) need membership of `mcp_write`, or the group in `OPENKIS_MCP_WRITE_GROUP`.
- Admins enable users in **Configuration > MCP server**. That page creates the `mcp_users` and `mcp_write` groups if they are missing.
- **The legacy shared key** (`OPENKIS_MCP_APIKEY`) gives full access as the user in `OPENKIS_MCP_USER`. Keep it empty unless you need it.

## Maps and caches

- **Map exports are cached** (KML, GPX, JSON, markers). The cache is dropped automatically when a record is saved through OpenKIS, and after an hour at the latest.
- **After editing data directly in the database** (an SQL import or a manual `UPDATE`), run **Control center > Utilities > Refresh map data**, or `php refresh-cache.php` inside the container. That refreshes the maps, recalculates coordinates and re-syncs the record id counters. Without it, maps can show old data, and new records can get an id that is already used.
- **Table structure is cached for up to 10 minutes.** After adding or changing a column by hand, use "Clear cache" or restart the web container, so the change is seen at once.

## Database schema changes

- **Missing columns are added automatically.** When a table definition gains a field, OpenKIS adds the column on the first page that opens that table. On large tables, that page is slow once. For big imports, run the migration SQL first, before the web container starts.
