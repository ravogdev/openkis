#!/usr/bin/env bash
# Lombardia migration test: the path a copy of the old Lombardia site takes to
# the Docker deployment, on a throwaway stack (its own compose project, port
# and volumes), without any of the site's data:
#   tests/lombardia/fixture.sql (the old database's tables, empty, and its
#   settings with the secrets blanked: see tests/lombardia/README.md)
#   -> deploy/db-image/lombardia-migrate.sql
#   -> the web container starts with OPENKIS_CUSTOM=lombardia and applies the
#      regional updates (extra/openkis/custom/lombardia/updates/*.sql)
#   -> every update recorded as applied, none failed, pages, and the role and
#      Lombardia checks of tests/regional/site-checks.sh, no PHP errors.
# The stack and its volumes are removed at the end, pass or fail.
#
#   git submodule update --init --recursive
#   tests/lombardia/migration-test.sh      # MIGRATION_PORT=8098 by default
#
# Locally, with the real dump of the old site instead of the fixture (the dump
# stays on this computer: it is only read into the throwaway database):
#   MIGRATION_DUMP=/path/to/old-site-dump.sql[.gz] tests/lombardia/migration-test.sh
#   MIGRATION_KEEP=1 ...     # leave the stack running at the end, to look at it
# When node and Playwright are installed (require('playwright') works), it also
# runs tests/lombardia/browser-matrix.js: real browser, desktop and Pixel 7,
# every role (BROWSER=0 skips it).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/deploy"

PORT=${MIGRATION_PORT:-8098}
BASE="http://localhost:$PORT"
WORK=$(mktemp -d)
ENVF="$WORK/env"
JAR="$WORK/cookies"
cat > "$ENVF" <<EOF
OPENKIS_DB_PASSWORD=migration-db-pass
MARIADB_ROOT_PASSWORD=migration-root-pass
OPENKIS_HTTP_PORT=$PORT
OPENKIS_CUSTOM=lombardia
OPENKIS_ENABLE_PROXY=1
EOF
DC="docker compose -p openkis-migration --env-file $ENVF -f docker-compose.yml -f docker-compose.build.yml"
dc() { $DC "$@"; }
db() { dc exec -T db mariadb -N -uopenkis -pmigration-db-pass openkis "$@"; }
cleanup() { dc down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$WORK"; }
[ "${MIGRATION_KEEP:-0}" = 1 ] && cleanup() { echo "stack left running: $DC down -v   # to remove it"; }
trap cleanup EXIT
DUMP=${MIGRATION_DUMP:-}
[ -z "$DUMP" ] || [ -f "$DUMP" ] || { echo "dump not found: $DUMP" >&2; exit 2; }

fail() { echo "MIGRATION FAIL: $*" >&2; dc logs --tail 80 web >&2 || true; exit 1; }
ok() { echo "ok - $*"; }
php_errors() { grep -ciE '(fatal error|parse error|warning):' "$1" || true; }
get() { # get <path> [curl args...] -> body in $WORK/page, prints status
    local path=$1; shift
    curl -sS -L -o "$WORK/page" -w '%{http_code}' -c "$JAR" -b "$JAR" "$@" "$BASE$path"
}
wait_healthy() { # wait_healthy <service>
    local status=starting
    for _ in $(seq 1 60); do
        status=$(docker inspect -f '{{.State.Health.Status}}' "$(dc ps -q "$1")" 2>/dev/null || echo starting)
        [ "$status" = healthy ] && return 0
        sleep 3
    done
    fail "$1 container not healthy ($status)"
}

echo "== build"
./base-images.sh   # Docker Hub at most once a day
dc build web

echo "== old database: ${DUMP:-fixture} + lombardia-migrate.sql"
dc up -d db
wait_healthy db
if [ -n "$DUMP" ]; then
    case "$DUMP" in *.gz) gzip -dc "$DUMP" ;; *) cat "$DUMP" ;; esac | db || fail "dump import failed"
else
    db < "$ROOT/tests/lombardia/fixture.sql" || fail "fixture import failed"
fi
ok "old database imported: $(db -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()") tables"
db < "$ROOT/deploy/db-image/lombardia-migrate.sql" > "$WORK/migrate" 2>&1 || { cat "$WORK/migrate"; fail "lombardia-migrate.sql failed"; }
ok "lombardia-migrate.sql"
# the old site's users are not in the fixture: one administrator, so the web
# container treats the database as an existing site (no setup wizard)
if [ "$(db -e "SELECT COUNT(*) FROM fn_users")" = 0 ]; then
    hash=$(dc run --rm --no-deps -T --entrypoint php web -r 'echo password_hash(bin2hex(random_bytes(16)), PASSWORD_BCRYPT);')
    db -e "INSERT INTO fn_users (username, email, passwd, level, \`group\`, active, registrationdate)
           VALUES ('migration_admin', 'migration_admin@example.invalid', '$hash', '10', '', '1', '2026-01-01')" \
        || fail "cannot create the administrator"
fi

echo "== web container on the migrated database"
dc up -d web
wait_healthy web
ok "web container healthy"
dc logs web > "$WORK/log" 2>&1
grep -q 'no setup wizard' "$WORK/log" || fail "the web container did not take the database as an existing site"
if grep -q 'WARNING: database update' "$WORK/log"; then
    grep 'WARNING: database update' "$WORK/log" >&2
    fail "a regional database update failed"
fi
nfiles=$(dc exec -T web sh -c 'ls /usr/src/openkis/extra/openkis/custom/lombardia/updates/*.sql | wc -l')
napplied=$(db -e "SELECT COUNT(*) FROM openkis_db_updates WHERE how = 'applied'")
[ "$napplied" = "$nfiles" ] || fail "$napplied of $nfiles regional updates recorded as applied"
ok "regional updates: $napplied of $nfiles applied"

echo "== pages"
for path in / '/index.php?mod=caves' '/index.php?mod=map_caves' /openkis_json.php /openkis_kml.php; do
    code=$(get "$path")
    [ "$code" = 200 ] || fail "$path returned $code"
    [ "$(php_errors "$WORK/page")" = 0 ] || fail "$path shows PHP errors"
    grep -q 'fnapp=install' "$WORK/page" && fail "$path redirects to the installer"
    ok "$path 200"
done

echo "== roles and region (lombardia)"
SITE_SQL="$DC exec -T db mariadb -N -uopenkis -pmigration-db-pass openkis" SITE_PHP="$DC exec -T web php" \
    "$ROOT/tests/regional/site-checks.sh" "$BASE" lombardia || fail "role and regional checks"
ok "role and regional checks"

if [ "${BROWSER:-1}" = 1 ] && command -v node >/dev/null && node -e "require('playwright')" 2>/dev/null; then
    echo "== browser (desktop, Pixel 7; every role)"
    BASE="$BASE" node "$ROOT/tests/lombardia/browser-matrix.js" || fail "browser checks"
    ok "browser checks"
fi

echo "== runtime"
n=$(dc logs web 2>&1 | grep -ciE 'PHP (fatal|parse|warning)' || true)
[ "$n" = 0 ] || { dc logs web 2>&1 | grep -iE 'PHP (fatal|parse|warning)' | head -20 >&2; fail "$n PHP errors/warnings in the container log"; }
ok "no PHP errors in the container log"

echo "MIGRATION PASS"
