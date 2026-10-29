# Lombardia tests

Lombardia is the regional site that matters most, so it has its own tests on
top of the generic ones. None of them uses the site's data in CI.

| What | Where it runs |
|---|---|
| `deploy/smoke-test.sh` with `SMOKE_CUSTOM=lombardia`: fresh install with the Lombardia customisation, then `tests/regional/site-checks.sh` | CI (pull requests into `develop`, pushes to `develop`, image publishing) |
| `migration-test.sh`: the old Lombardia schema and settings → `deploy/db-image/lombardia-migrate.sql` → regional updates → checks | CI, same workflows |
| `migration-test.sh` with `MIGRATION_DUMP=<real dump>` | locally only |
| `browser-matrix.js`: real browser, desktop and Pixel 7, every role | CI (inside `migration-test.sh`), and locally when Playwright is installed |
| `map-icons.js`: the caves map icons grow with the zoom, desktop and Pixel 7, every role | CI (inside `migration-test.sh`, on three made-up caves), and locally when Playwright is installed |

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
  the JSON and KML exports; the map access script (`openkis_map_access.js.php`)
  agrees with the KML export for caves, springs and artificial cavities: a
  section the map loads answers 200, one it skips answers 403 (#99). HTTP status, PHP errors, still logged in, and the
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

`map-icons.js` checks that the KML point icons grow with the zoom
(`OPS_Map.scaleIconsWithZoom`, upstream c6fbe01). For a desktop browser and
Pixel 7 (touch), anonymous and each test account, on the caves map section
with the base layers hidden (no tile server can change the result):

- from zoom 11 to 19, the drawn size of every cave icon in view: the KML size
  up to zoom 13, then 0.3 times that size more per level, up to 3 times and at
  most 40 px (a bigger KML icon stays as it is);
- on screenshots with only one cave drawn, the icon is as wide on the screen
  at zoom 15 and 18, compared with zoom 12, as its size says (within 15%);
- at zoom 18 a click (a tap on the phone) on the cave opens its popup;
- on the map of selected caves (`filter_code`, the cave sheet map), which
  shows the names, the name starts beside the icon at zoom 13, 16 and 19;
- no JavaScript errors. A role whose map leaves out the caves layer (#99) is
  reported as skipped, after checking that the map access says so.

In CI it runs on three made-up caves (`icon-test-1` to `3`, inserted and
removed by `migration-test.sh`), because the fixture has no caves.

## The fixture

`fixture.sql` is the old Lombardia database without its data:

- the structure of all its 78 tables, with no rows, and no `AUTO_INCREMENT`
  counters (they tell how many rows a table had);
- the rows of the settings tables only (581 rows): `fn_sections`, `fn_groups`
  (group names only), `fn_settings`, `fn_blocks`,
  `fn_sectionstypes`, `extra_s_openkis`, `plugins_s_statistics`, the module
  settings `fncf_*` and the theme settings `themes_s_*`;
- blanked: the OpenAI API key (`fncf_openai`), the site address (`siteurl`),
  the site e-mail address (`noreply@example.invalid`) and the group
  descriptions.

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
`browser-matrix.js` and `map-icons.js` (`BROWSER=0` skips them). The browser pass can also run on
its own against any disposable copy, after `site-checks.sh` has created the
test accounts:

```sh
BASE=http://localhost:8098 OUT=/tmp/shots node tests/lombardia/browser-matrix.js
BASE=http://localhost:8098 OUT=/tmp/icons node tests/lombardia/map-icons.js
```

`map-icons.js` saves the map at zoom 12, 15 and 18, with the popup at zoom 18
and the selected caves map at zoom 19, for each device and role, to look at.
