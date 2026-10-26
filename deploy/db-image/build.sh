#!/usr/bin/env bash
# Builds the database image of a regional site from the original dump of its
# old database. On the first start of an empty volume the image loads, in order:
#   10-dump.sql      the original dump, as it is
#   20-migrate.sql   the one-time migration of the old schema (optional)
#   30-updates.sql   every file of extra/openkis/custom/<region>/updates/ of this
#                    checkout, each recorded in openkis_db_updates
# so a database created from it matches the code of this checkout, and the web
# container applies only the updates added later.
#
#   deploy/db-image/build.sh <region> <dump.sql[.gz]> [migrate.sql] [tag]
#   e.g. deploy/db-image/build.sh lombardia old-site.sql lombardia-migrate.sql
#
# The dump stays outside git and the build context is a temporary folder that
# is deleted at the end. Nothing is pushed: the image holds the site's data.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
region=${1:?usage: build.sh <region> <dump.sql[.gz]> [migrate.sql] [tag]}
dump=${2:?usage: build.sh <region> <dump.sql[.gz]> [migrate.sql] [tag]}
migrate=${3:-}
rev=$(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo local)
tag=${4:-openkis-db-$region:$rev}
updates="$repo/extra/openkis/custom/$region/updates"

case "$region" in *[!a-z0-9_-]*) echo "bad region name: $region" >&2; exit 1 ;; esac
[ -f "$dump" ] || { echo "dump not found: $dump" >&2; exit 1; }
[ -z "$migrate" ] || [ -f "$migrate" ] || { echo "migration script not found: $migrate" >&2; exit 1; }

ctx=$(mktemp -d)
trap 'rm -rf "$ctx"' EXIT
mkdir "$ctx/initdb"
cp "$here/Dockerfile" "$ctx/"
case "$dump" in
    *.gz) cp "$dump" "$ctx/initdb/10-dump.sql.gz" ;;
    *)    cp "$dump" "$ctx/initdb/10-dump.sql" ;;
esac
[ -z "$migrate" ] || cp "$migrate" "$ctx/initdb/20-migrate.sql"
{
    echo "-- updates of extra/openkis/custom/$region/updates/ at $rev"
    echo "CREATE TABLE IF NOT EXISTS openkis_db_updates (name VARCHAR(190) NOT NULL PRIMARY KEY,"
    echo "  applied DATETIME NOT NULL, how VARCHAR(16) NOT NULL DEFAULT 'applied') ENGINE=InnoDB;"
    if [ -d "$updates" ]; then
        for f in "$updates"/*.sql; do
            [ -f "$f" ] || continue
            n=$(basename "$f")
            case "$n" in *[!A-Za-z0-9._-]*) echo "bad update file name: $n" >&2; exit 1 ;; esac
            echo "-- ===== $n"
            cat "$f"
            echo
            echo "INSERT IGNORE INTO openkis_db_updates (name, applied, how) VALUES ('$n', NOW(), 'image');"
        done
    fi
} > "$ctx/initdb/30-updates.sql"
chmod a+r "$ctx"/initdb/*

docker build -t "$tag" \
    --label "org.opencontainers.image.revision=$rev" \
    --label "org.openkis.region=$region" "$ctx"
echo "built $tag (local only: it holds the site's data, do not push it to a public registry)"
