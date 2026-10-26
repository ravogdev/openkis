#!/usr/bin/env bash
# Writes the database schema of this checkout, built from scratch: a throwaway
# stack (own compose project, port and volumes) is installed on an empty
# database, create-schema.php creates every table of the code, and the
# structure is dumped without data. Optionally compares it with the schema of
# a running database, to check that it is in sync with the code.
#
#   deploy/schema.sh [region] > schema.sql        # region = OPENKIS_CUSTOM, e.g. lombardia
#   SCHEMA_COMPARE=<db container> SCHEMA_COMPARE_DB=<name> SCHEMA_COMPARE_PASS=<root pw> \
#       deploy/schema.sh lombardia > schema.sql   # also prints the differences to stderr
#
# Only the structure is written, never data. The stack and its volumes are
# removed at the end.
set -euo pipefail
cd "$(dirname "$0")"
region=${1:-}
case "$region" in *[!a-z0-9_-]*) echo "bad region name: $region" >&2; exit 1 ;; esac
PORT=${SCHEMA_PORT:-8096}
BASE="http://localhost:$PORT"
WORK=$(mktemp -d)
ENVF="$WORK/env"
JAR="$WORK/cookies"
cat > "$ENVF" <<EOV
OPENKIS_DB_PASSWORD=schema-db-pass
MARIADB_ROOT_PASSWORD=schema-root-pass
OPENKIS_HTTP_PORT=$PORT
OPENKIS_CUSTOM=$region
EOV
dc() { docker compose -p openkis-schema --env-file "$ENVF" -f docker-compose.yml -f docker-compose.build.yml "$@"; }
cleanup() { dc down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$WORK"; }
trap cleanup EXIT
fail() { echo "SCHEMA FAIL: $*" >&2; dc logs --tail 40 web >&2 || true; exit 1; }
get() { curl -sS -L -o "$WORK/page" -w '%{http_code}' -c "$JAR" -b "$JAR" "$@"; }

# structure only, stable between runs: no AUTO_INCREMENT counters, no dates
structure() {
    "$@" --no-data --skip-comments --skip-dump-date --compact \
        | sed -E 's/ AUTO_INCREMENT=[0-9]+//; /^\/\*!40101 SET /d'
}

dc build web >&2
dc up -d db web >&2
for _ in $(seq 1 60); do
    status=$(docker inspect -f '{{.State.Health.Status}}' "$(dc ps -q web)" 2>/dev/null || echo starting)
    [ "$status" = healthy ] && break
    sleep 3
done
[ "$status" = healthy ] || fail "web container not healthy ($status)"
get "$BASE/" >/dev/null
get "$BASE/index.php?fnapp=install&step=1" --data lang=en >/dev/null
get "$BASE/index.php?fnapp=install&step=2" --data 'conf_sitename=OpenKIS&conf_site_title=OpenKIS&conf_site_subtitle=schema&conf_languages=en&conf_theme=openkis&conf_site_email_address=schema@example.com&savefileconfig=1' >/dev/null
get "$BASE/index.php?fnapp=install&step=3" -X POST >/dev/null
get "$BASE/index.php?fnapp=install&step=3" --data 'username=admin&email=admin@example.com&passwd=Schema-Test-123&passwd_retype=Schema-Test-123&reg=reg' >/dev/null
grep -q "window.location='index.php'" "$WORK/page" || fail "setup wizard did not finish"
get "$BASE/" >/dev/null
dc exec -T -u www-data web php /var/www/html/create-schema.php >&2 || fail "create-schema.php failed"

structure dc exec -T db mariadb-dump -uroot -pschema-root-pass openkis > "$WORK/schema.sql"
echo "-- OpenKIS schema from scratch: $(git rev-parse --short HEAD 2>/dev/null || echo local)${region:+, OPENKIS_CUSTOM=$region}"
cat "$WORK/schema.sql"

if [ -n "${SCHEMA_COMPARE:-}" ]; then
    # tables and columns with their types; the column order and the table
    # options (engine, charset) are left out
    q="SELECT table_name, column_name, column_type FROM information_schema.columns
       WHERE table_schema = DATABASE() ORDER BY 1, 2"
    dc exec -T db mariadb -N -uroot -pschema-root-pass openkis -e "$q" > "$WORK/a"
    docker exec "$SCHEMA_COMPARE" mariadb -N -uroot -p"${SCHEMA_COMPARE_PASS:?}" "${SCHEMA_COMPARE_DB:?}" -e "$q" > "$WORK/b"
    echo "== columns only from scratch (<) / only in $SCHEMA_COMPARE/$SCHEMA_COMPARE_DB (>)" >&2
    diff "$WORK/a" "$WORK/b" >&2 && echo "same tables and columns" >&2 || true
fi
