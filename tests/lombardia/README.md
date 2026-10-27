# Lombardia tests

Lombardia is the regional site that matters most, so it has its own tests on
top of the generic ones. None of them uses the site's data in CI.

| What | Where it runs |
|---|---|
| `deploy/smoke-test.sh` with `SMOKE_CUSTOM=lombardia`: fresh install with the Lombardia customisation, then `tests/regional/site-checks.sh` | CI (pull requests into `develop`, pushes to `develop`, image publishing) |
| `migration-test.sh`: the old Lombardia schema and settings → `deploy/db-image/lombardia-migrate.sql` → regional updates → checks | CI, same workflows |
| `migration-test.sh` with `MIGRATION_DUMP=<real dump>` | locally only |
| `browser-matrix.js`: real browser, desktop and Pixel 7, every role | locally, when Playwright is installed |

Never run any of them against the production site: they create test accounts
and insert test records. The scripts refuse a `speleolombardia` address.

## What the checks cover

`tests/regional/site-checks.sh <base-url> <region>` (any region; the
Lombardia checks run with `lombardia`):

- one account per role: read-only (`r_caves`), read-write (`RW_BG`,
  `r_caves`), curator (`RW_BG`, `r_caves`, `catasto_inserimento`),
  administrator (level 10); password `$TEST_PASS`, default
  `Regional-Test-2026`;
- for a desktop and an Android browser and for anonymous and each role: home,
  caves, surveys, cave systems, caves map, a cave sheet, the control center,
  the JSON and KML exports. HTTP status, PHP errors, still logged in, and the
  "no permission" page exactly where the database says so (`fn_sections`,
  `fncf_<section>`: the same rules as the code);
- a cave inserted by each role is saved only for the roles that may insert;
- Lombardia: new caves get the next free `LO<n>` code; an `RW_BG` user may
  save in BG, not in BS ("Non puoi inserire dati nella provincia di BS"), and a
  user without `RW_BG` may not save in BG; the administrator may save in any
  province; the new cave form is the Lombardia one (`DATAGG`, no `alias`);
  new artificial cavities get `CALO<n>`;
- the test records are removed at the end (the accounts stay).

`migration-test.sh` also checks that every regional update was applied, that
none failed (a failed update stops the later ones), and that the site opens
without the setup wizard and without PHP errors in the container log.

## The fixture

`fixture.sql` is the old Lombardia database without its data:

- the structure of all its 78 tables, with no rows, and no `AUTO_INCREMENT`
  counters (they tell how many rows a table had);
- the rows of the settings tables only (581 rows): `fn_sections`, `fn_groups`
  (group names and descriptions), `fn_settings`, `fn_blocks`,
  `fn_sectionstypes`, `extra_s_openkis`, `plugins_s_statistics`, the module
  settings `fncf_*` and the theme settings `themes_s_*`;
- blanked: the OpenAI API key (`fncf_openai`), the site address (`siteurl`)
  and the site e-mail address (`noreply@example.invalid`).

No user, cave, survey, photo, bibliography, attachment, log or statistics row
is in it. The test adds its own accounts and fake caves.

To rebuild it from a newer dump, with the same rules:

```sh
tests/lombardia/make-fixture.sh /path/to/old-site-dump.sql
git diff tests/lombardia/fixture.sql   # review before committing
```

The script lists every value that still looks like an address or a key.

## Running on the real dump (locally)

The dump never goes into git, an image or a report. It is only read into the
throwaway database of the test stack:

```sh
git submodule update --init --recursive
MIGRATION_DUMP=/path/to/old-site-dump.sql tests/lombardia/migration-test.sh
MIGRATION_KEEP=1 MIGRATION_DUMP=... tests/lombardia/migration-test.sh   # keep the stack to look at it
```

With the real dump the site's own users are kept and the test accounts are
added to them. When `node` and Playwright are installed it also runs
`browser-matrix.js` (`BROWSER=0` skips it). The browser pass can also run on
its own against any disposable copy, after `site-checks.sh` has created the
test accounts:

```sh
BASE=http://localhost:8098 OUT=/tmp/shots node tests/lombardia/browser-matrix.js
```
