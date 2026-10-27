# Database image with a site's data

`build.sh` makes a local MariaDB image that fills an empty database volume with
the original dump of a regional site and then brings it up to the code of the
checkout it was built from. Every build gives the same database for the same
commit, so a deleted or recreated volume comes back in sync with the code.

```sh
deploy/db-image/build.sh lombardia /path/to/old-site-dump.sql deploy/db-image/lombardia-migrate.sql
# -> openkis-db-lombardia:<commit>
```

`lombardia-migrate.sql` (in this folder) changes only the schema and the
settings, never the data. CI runs it on the old schema without data
(`tests/lombardia/migration-test.sh`), so a step that fails on the Lombardia
database shows up in the pull request.

On the first start of an empty volume the image runs, in order:

| File | What |
|---|---|
| `10-dump.sql` | the original dump of the old site, unchanged |
| `20-migrate.sql` | the one-time migration of the old schema (optional) |
| `30-updates.sql` | every file of `extra/openkis/custom/<region>/updates/` in this checkout, each recorded in `openkis_db_updates` |

Then point the stack at it in `.env` and start it on an empty database volume:

```sh
OPENKIS_DB_IMAGE=openkis-db-lombardia:<commit>
```

The web container sees that the database already has its users and skips the
setup wizard. Updates added to the code later are applied by the web container
at its next start, as on any site (see "Regional database updates" in
`deploy/README.md`). If the initialisation fails, the log of the `db` service
says which file; delete the volume and start again after the fix.

## The data stays private

The image holds the site's data: accounts, reserved caves, everything in the
dump. So:

- the dump and the image are never committed, pushed to a registry, or put in
  the published `openkis-web` image (its build excludes every `.sql` file
  except the update files, and the smoke test checks it);
- `build.sh` copies the dump into a temporary build folder that it deletes at
  the end, and pushes nothing;
- the image is built and kept only on the machines of the people allowed to
  see the data; to share it, share the dump through the same private channel
  and build it again.

What is in git is only the structure: the update files change schema and
settings and contain no data.
