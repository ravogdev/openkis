#!/usr/bin/env bash
# Downloads from Docker Hub the images the test stacks are built and run from
# (the Ubuntu base of the web image, from the Dockerfile, and MariaDB, from
# docker-compose.yml) at most once a day. Docker Hub limits how many requests
# an address may make, and every `docker build` otherwise asks it whether the
# base image changed. When an image is already on this computer and was
# downloaded today, nothing is asked: the build uses the local copy.
#
#   deploy/base-images.sh          # download what was not downloaded today
#   deploy/base-images.sh --list   # print the images
#   deploy/base-images.sh --mark   # count the local copies as downloaded today
#                                  # (CI, after `docker load` of the day's cache)
#
# The date of the last download of each image is kept in $OPENKIS_IMAGE_STAMPS
# (default ~/.cache/openkis); a refused download counts too, so Docker Hub is
# asked at most once a day per image. If Docker Hub refuses (for example "429
# Too Many Requests"), the local copy is used when there is one, else the same
# official image is taken from Google's Docker Hub mirror (mirror.gcr.io).
# deploy/smoke-test.sh and tests/lombardia/migration-test.sh run it before
# building.
set -euo pipefail
cd "$(dirname "$0")"

IMAGES="$(sed -nE 's/^ARG BASE_IMAGE=(.+)$/\1/p' Dockerfile) ${OPENKIS_DB_IMAGE:-mariadb:11.4}"
STAMPS=${OPENKIS_IMAGE_STAMPS:-${XDG_CACHE_HOME:-$HOME/.cache}/openkis}
TODAY=$(date -u +%Y-%m-%d)

stamp() { echo "$STAMPS/$(printf '%s' "$1" | tr '/:@' '___').pulled"; }
present() { docker image inspect "$1" >/dev/null 2>&1; }

case "${1:-}" in
    --list) echo $IMAGES; exit 0 ;;
    --mark)
        mkdir -p "$STAMPS"
        for img in $IMAGES; do
            present "$img" && echo "$TODAY" > "$(stamp "$img")"
        done
        exit 0 ;;
    "") ;;
    *) echo "usage: $0 [--list|--mark]" >&2; exit 2 ;;
esac

mkdir -p "$STAMPS"
for img in $IMAGES; do
    if present "$img" && [ "$(cat "$(stamp "$img")" 2>/dev/null)" = "$TODAY" ]; then
        echo "base image $img: already downloaded today, using the local copy"
        continue
    fi
    if docker pull -q "$img" >/dev/null 2>"$STAMPS/pull.err"; then
        echo "$TODAY" > "$(stamp "$img")"
        echo "base image $img: downloaded"
    elif present "$img"; then
        # tried today: the next try is tomorrow
        echo "$TODAY" > "$(stamp "$img")"
        echo "base image $img: Docker Hub refused ($(tail -n 1 "$STAMPS/pull.err" | sed 's/.*: //')), using the local copy" >&2
    elif [[ "$img" != */* ]] && docker pull -q "mirror.gcr.io/library/$img" >/dev/null; then
        docker tag "mirror.gcr.io/library/$img" "$img"
        echo "$TODAY" > "$(stamp "$img")"
        echo "base image $img: Docker Hub refused, downloaded from mirror.gcr.io" >&2
    else
        echo "base image $img: cannot download it and there is no local copy" >&2
        exit 1
    fi
done
