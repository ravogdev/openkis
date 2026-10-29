#!/usr/bin/env bash
# Builds the web image from this checkout and smoke-tests it on a throwaway
# stack (its own compose project, port and volumes; a running installation
# and its .env are not touched):
#   no SQL dump anywhere in the image, fresh install via the setup wizard,
#   home page, caves list, caves map, every table of the code (create-schema.php),
#   control center, demo cave import, Refresh map data, map exports, map proxy
#   (blocked, or with Lombardia: refuses every host but the map layer hosts), APCu,
#   role and regional checks (tests/regional/site-checks.sh: one account per
#   role, desktop and Android, inserts; extra checks for Lombardia), per-record
#   edit permissions (tests/regional/record-permissions.sh),
#   no PHP errors in the pages or the container log.
# The stack and its volumes are removed at the end, pass or fail
# (SMOKE_KEEP=1 leaves it running, to look at it). Nothing is pushed.
#
#   git submodule update --init --recursive
#   deploy/smoke-test.sh            # SMOKE_PORT=8099 by default
#   SMOKE_CUSTOM=lombardia deploy/smoke-test.sh   # with a regional customisation
#
# CI runs it before docker-deploy is moved to a new develop commit, and
# before an image is published to Docker Hub (publish-image workflow).
set -euo pipefail
cd "$(dirname "$0")"

PORT=${SMOKE_PORT:-8099}
CUSTOM=${SMOKE_CUSTOM:-}
BASE="http://localhost:$PORT"
WORK=$(mktemp -d)
ENVF="$WORK/env"
JAR="$WORK/cookies"
cat > "$ENVF" <<EOF
OPENKIS_DB_PASSWORD=smoke-db-pass
MARIADB_ROOT_PASSWORD=smoke-root-pass
OPENKIS_HTTP_PORT=$PORT
OPENKIS_CUSTOM=$CUSTOM
OPENKIS_ENABLE_PROXY=$([ "$CUSTOM" = lombardia ] && echo 1 || echo 0)
EOF
dc() { docker compose -p openkis-smoke --env-file "$ENVF" -f docker-compose.yml -f docker-compose.build.yml "$@"; }
cleanup() { dc down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$WORK"; }
[ "${SMOKE_KEEP:-0}" = 1 ] && cleanup() { echo "stack left running: docker compose -p openkis-smoke --env-file $ENVF -f docker-compose.yml -f docker-compose.build.yml down -v   # to remove it"; }
trap cleanup EXIT

fail() { echo "SMOKE FAIL: $*" >&2; dc logs --tail 80 web >&2 || true; exit 1; }
ok() { echo "ok - $*"; }
php_errors() { grep -ciE '(fatal error|parse error|warning):' "$1" || true; }
get() { # get <path> [curl args...] -> body in $WORK/page, prints status
    local path=$1; shift
    curl -sS -L -o "$WORK/page" -w '%{http_code}' -c "$JAR" -b "$JAR" "$@" "$BASE$path"
}

echo "== build"
./base-images.sh   # Docker Hub at most once a day
dc build web

echo "== no SQL dump in the image"
# Only the SQL files the image needs are allowed (indexes, demo cave, regional
# updates); anything else named like
# a dump, or that reads like one (mysqldump, mariadb-dump, phpMyAdmin), fails
dumps=$(docker run --rm --entrypoint sh openkis-web:local -c '
    find / -xdev -type f \( -iname "*.sql" -o -iname "*.sql.*" -o -iname "*.dump" -o -iname "*.dump.*" \) 2>/dev/null \
        | grep -vxE "/usr/src/openkis/(sql/openkis_indexes|extra/openkis/install/demo_cave|extra/openkis/custom/[a-z]+/updates/[0-9]{3}-[a-z0-9-]+)\.sql"
    grep -rlIE -m1 "^(-- (MySQL|MariaDB) dump|-- phpMyAdmin SQL Dump|/\*!40(014|101|103) SET )" / \
        --exclude-dir=proc --exclude-dir=sys --exclude-dir=dev 2>/dev/null
    true')
[ -z "$dumps" ] || fail "the image contains SQL dumps: $(echo "$dumps" | sort -u | tr '\n' ' ')"
ok "no SQL dump in the image"

echo "== start"
dc up -d
for _ in $(seq 1 60); do
    status=$(docker inspect -f '{{.State.Health.Status}}' "$(dc ps -q web)" 2>/dev/null || echo starting)
    [ "$status" = healthy ] && break
    sleep 3
done
[ "$status" = healthy ] || fail "web container not healthy ($status)"
ok "web container healthy"

echo "== setup wizard"
code=$(get /); [ "$code" = 200 ] || fail "/ returned $code"
grep -q 'fnapp=install' "$WORK/page" || fail "fresh install did not open the setup wizard"
get '/index.php?fnapp=install&step=1' --data lang=en >/dev/null
grep -q 'permissions are correct' "$WORK/page" || fail "installer permission check not green"
get '/index.php?fnapp=install&step=2' --data 'conf_sitename=OpenKIS&conf_site_title=OpenKIS&conf_site_subtitle=smoke&conf_languages=en&conf_theme=openkis&conf_site_email_address=smoke@example.com&conf_home_section=map_caves&savefileconfig=1' >/dev/null
get '/index.php?fnapp=install&step=3' -X POST >/dev/null
grep -q 'name="username"' "$WORK/page" || fail "installer did not ask for the administrator"
get '/index.php?fnapp=install&step=3' --data 'username=admin&email=admin@example.com&passwd=Smoke-Test-123&passwd_retype=Smoke-Test-123&reg=reg' >/dev/null
grep -q "window.location='index.php'" "$WORK/page" || fail "administrator registration did not finish the install"
ok "setup wizard completed"

echo "== pages"
for path in / '/index.php?mod=caves' '/index.php?mod=map_caves' '/index.php?fnapp=controlcenter'; do
    code=$(get "$path")
    [ "$code" = 200 ] || fail "$path returned $code"
    [ "$(php_errors "$WORK/page")" = 0 ] || fail "$path shows PHP errors"
    grep -q 'fnapp=install' "$WORK/page" && [ "$path" != '/index.php?fnapp=controlcenter' ] && fail "$path still redirects to the installer"
    ok "$path 200"
done

echo "== schema from scratch"
dc exec -T -u www-data web php /var/www/html/create-schema.php > "$WORK/schema" 2>&1 || { cat "$WORK/schema"; fail "create-schema.php failed"; }
[ "$(php_errors "$WORK/schema")" = 0 ] || { cat "$WORK/schema"; fail "create-schema.php shows PHP errors"; }
ntables=$(dc exec -T db mariadb -N -uopenkis -psmoke-db-pass openkis -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()")
[ "$ntables" -ge 40 ] || fail "create-schema.php left only $ntables tables"
ok "create-schema.php: $ntables tables"

echo "== demo cave + Refresh map data"
dc exec -T web cat /usr/src/openkis/extra/openkis/install/demo_cave.sql \
    | dc exec -T db mariadb -uopenkis -psmoke-db-pass openkis \
    || fail "demo cave import failed"
dc exec -T -u www-data web php /var/www/html/refresh-cache.php | tee "$WORK/refresh"
grep -q 'Coordinates recalculated' "$WORK/refresh" || fail "Refresh map data did not recalculate coordinates"
ok "Refresh map data"
code=$(get /openkis_json.php)
[ "$code" = 200 ] || fail "/openkis_json.php returned $code"
grep -q '"code":"DEMO1"' "$WORK/page" || fail "/openkis_json.php does not list the demo cave"
ok "/openkis_json.php lists the demo cave"
for path in /openkis_kml.php /openkis_markers.js.php; do
    code=$(get "$path")
    [ "$code" = 200 ] || fail "$path returned $code"
    [ "$(php_errors "$WORK/page")" = 0 ] || fail "$path shows PHP errors"
    ok "$path 200"
done

echo "== map proxy"
# no outside requests here: only the refusals (the layer hosts are tested by hand)
if [ "$CUSTOM" = lombardia ]; then
    for url in https://example.com/ http://169.254.169.254/latest/meta-data/ http://db:3306/ \
        http://sgi2.isprambiente.it:22/ http://user:pass@sgi2.isprambiente.it/ \
        http://sgi2.isprambiente.it.example.com/ file:///etc/passwd; do
        code=$(get "/openkis_proxy.php/$url" --path-as-is)
        [ "$code" = 403 ] || fail "openkis_proxy.php fetched $url ($code)"
    done
    ok "openkis_proxy.php refuses hosts that are not map layer hosts"
    code=$(get "/openkis_proxy.php/" --path-as-is)
    [ "$code" = 400 ] || fail "openkis_proxy.php without an address returned $code"
    ok "openkis_proxy.php without an address 400"
else
    code=$(get "/openkis_proxy.php/https://example.com/" --path-as-is)
    [ "$code" = 403 ] || fail "openkis_proxy.php not blocked with OPENKIS_ENABLE_PROXY=0 ($code)"
    ok "openkis_proxy.php blocked (OPENKIS_ENABLE_PROXY=0)"
fi

echo "== roles and region (${CUSTOM:-generic})"
DC="docker compose -p openkis-smoke --env-file $ENVF -f docker-compose.yml -f docker-compose.build.yml"
SITE_SQL="$DC exec -T db mariadb -N -uopenkis -psmoke-db-pass openkis" SITE_PHP="$DC exec -T web php" \
    ../tests/regional/site-checks.sh "$BASE" "$CUSTOM" || fail "role and regional checks"
ok "role and regional checks"

echo "== per-record edit permissions (${CUSTOM:-generic})"
SITE_SQL="$DC exec -T db mariadb -N -uopenkis -psmoke-db-pass openkis" SITE_PHP="$DC exec -T web php" \
    ../tests/regional/record-permissions.sh "$BASE" "$CUSTOM" || fail "record permission checks"
ok "record permission checks"

echo "== runtime"
dc exec -T web php -r 'exit(extension_loaded("apcu") ? 0 : 1);' || fail "APCu not loaded"
ok "APCu loaded"
n=$(dc logs web 2>&1 | grep -ciE 'PHP (fatal|parse|warning)' || true)
[ "$n" = 0 ] || { dc logs web 2>&1 | grep -iE 'PHP (fatal|parse|warning)' | head -20 >&2; fail "$n PHP errors/warnings in the container log"; }
ok "no PHP errors in the container log"

echo "SMOKE PASS: $(dc exec -T web cat /usr/src/openkis/.openkis-image-version)"
