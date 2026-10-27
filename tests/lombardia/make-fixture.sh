#!/usr/bin/env bash
# Rebuilds tests/lombardia/fixture.sql from a dump of the old Lombardia site:
# every table's structure without its rows, plus the rows of the settings
# tables only (the list below), with the secrets blanked. No cave, survey,
# photo, bibliography, user, log or statistics row is copied.
#
#   tests/lombardia/make-fixture.sh /path/to/old-site-dump.sql[.gz]
#
# Needs a local MariaDB server the current user can create databases on; it
# uses two scratch databases (okx_fixture_dump, okx_fixture) and drops them at
# the end. The dump itself is only read. Review the diff before committing:
# the scan at the end lists anything that still looks like an address or a key.
set -euo pipefail
DUMP=${1:?usage: make-fixture.sh <old-site-dump.sql[.gz]>}
OUT="$(cd "$(dirname "$0")" && pwd)/fixture.sql"
SRC=okx_fixture_dump
FIX=okx_fixture
trap 'mariadb -e "DROP DATABASE IF EXISTS $SRC; DROP DATABASE IF EXISTS $FIX"' EXIT

mariadb -e "DROP DATABASE IF EXISTS $SRC; CREATE DATABASE $SRC CHARACTER SET utf8mb4;
            DROP DATABASE IF EXISTS $FIX; CREATE DATABASE $FIX CHARACTER SET utf8mb4"
case "$DUMP" in *.gz) gzip -dc "$DUMP" ;; *) cat "$DUMP" ;; esac | mariadb "$SRC"

# settings tables: sections, groups (names only), site settings, blocks,
# section types, module settings (fncf_*), theme and extension settings
CFG="fn_sections fn_groups fn_settings fn_blocks fn_sectionstypes extra_s_openkis plugins_s_statistics
     $(mariadb -N "$SRC" -e "SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE()
                             AND (table_name LIKE 'fncf\\_%' OR table_name LIKE 'themes\\_s\\_%') ORDER BY table_name")"

mariadb-dump --no-data --skip-comments --skip-dump-date "$SRC" | mariadb "$FIX"
for t in $CFG; do
    mariadb -e "INSERT INTO $FIX.\`$t\` SELECT * FROM $SRC.\`$t\`"
done
# secrets, addresses, and the group descriptions (names of curators' areas)
mariadb "$FIX" -e "UPDATE fncf_openai SET varvalue = '' WHERE varname = 'apikey';
                   UPDATE fn_settings SET varvalue = '' WHERE varname = 'siteurl';
                   UPDATE fn_settings SET varvalue = 'noreply@example.invalid' WHERE varname = 'site_email_address';
                   UPDATE fn_groups SET description = '';"

{
    echo "-- Lombardia migration test fixture, made by tests/lombardia/make-fixture.sh:"
    echo "-- the old site's tables without their rows, and its settings with the secrets blanked."
    echo "-- No data of the site. Used by tests/lombardia/migration-test.sh."
    # no AUTO_INCREMENT counters (they tell how many rows a table had)
    mariadb-dump --skip-comments --skip-dump-date --skip-extended-insert --skip-add-locks --no-tablespaces "$FIX" \
        | sed -E 's/ AUTO_INCREMENT=[0-9]+//; /^\/\*!40[0-9]{3} SET/d; /enable the sandbox mode/d'
} > "$OUT"

echo "written $OUT: $(grep -c '^CREATE TABLE' "$OUT") tables, $(grep -c '^INSERT' "$OUT") settings rows"
echo "values that look like an address or a key (check each one):"
grep '^INSERT' "$OUT" | grep -oiE "[^' ]*@[^' ]*|sk-[A-Za-z0-9_-]+|[A-Za-z0-9_-]{30,}|https?://[^' ]*" | sort -u || true
