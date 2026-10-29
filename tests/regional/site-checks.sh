#!/usr/bin/env bash
# Role and regional checks against a running OpenKIS site with a disposable
# database (a smoke-test stack, a local copy of a regional site). Never run it
# against production: it creates test accounts and inserts test records.
#
#   SITE_SQL="mariadb -N openkis" tests/regional/site-checks.sh http://localhost:8099 lombardia
#
# What it does:
#   1. creates one account per role (test_ro, test_rw, test_cur, test_admin)
#      and the groups they belong to; the password is $TEST_PASS
#   2. for a desktop and an Android browser (user agents) and for anonymous
#      and each role: logs in, opens the main pages and checks the HTTP status,
#      PHP errors, the logged-in state and the "no permission" page against
#      the permissions stored in the database (fn_sections, fncf_<section>)
#   3. inserts a cave as each role: saved only for the roles that may insert
#   4. lombardia: the Lombardia table definitions are in use, new caves get the
#      next LO<n> code, the province check (an RW_BG user may save in BG, not
#      in BS), new artificial cavities get CALO<n>
#   5. the cave systems list orders lengths and depths by value (numbers
#      stored as text; depths by absolute value)
#   6. removes the test records it inserted (the accounts stay)
#
# Settings (environment variables):
#   SITE_SQL   command that reads SQL on stdin for the site's database
#              (required), e.g. "docker compose exec -T db mariadb -N -u... db"
#   SITE_PHP   php command used to hash the test password [php]
#   TEST_PASS  password of the test accounts [Regional-Test-2026]
#   VERBOSE=1  print every passed check too
set -uo pipefail

BASE=${1:?usage: site-checks.sh <base-url> <region>}
BASE=${BASE%/}
REGION=${2:-}
: "${SITE_SQL:?SITE_SQL must be set: a command reading SQL for the site database on stdin}"
: "${SITE_PHP:=php}"
: "${TEST_PASS:=Regional-Test-2026}"
: "${VERBOSE:=0}"

case "$BASE" in
    *speleolombardia.it*|*speleolombardia*)
        echo "refusing to run against production ($BASE)" >&2; exit 2 ;;
esac

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); [ "$VERBOSE" = 1 ] && echo "ok - $*"; return 0; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL - $*"; return 0; }
check() { # check <description> <condition...>
    local d=$1; shift
    if "$@"; then pass "$d"; else fail "$d"; fi
}
sql() { $SITE_SQL; }
sqlv() { printf '%s\n' "$1" | sql 2>/dev/null | tr -d '\r'; }

UA_DESKTOP="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
UA_ANDROID="Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36"

# --- 1. test accounts --------------------------------------------------------
HASH=$($SITE_PHP -r 'echo password_hash($argv[1], PASSWORD_BCRYPT);' "$TEST_PASS" 2>/dev/null) \
    || { echo "php is needed to hash the test password" >&2; exit 2; }
ROLES="anonymous read-only read-write curator admin"
declare -A ACCOUNT=([read-only]=test_ro [read-write]=test_rw [curator]=test_cur [admin]=test_admin)
declare -A ROLE_GROUPS=([read-only]="r_caves" [read-write]="RW_BG,r_caves" [curator]="RW_BG,r_caves,catasto_inserimento" [admin]="")
declare -A LEVEL=([read-only]=0 [read-write]=0 [curator]=0 [admin]=10)
{
    for g in r_caves RW_BG catasto_inserimento; do
        echo "INSERT IGNORE INTO fn_groups (groupname) VALUES ('$g');"
    done
    for r in read-only read-write curator admin; do
        echo "DELETE FROM fn_users WHERE username = '${ACCOUNT[$r]}';"
        echo "INSERT INTO fn_users (username, email, passwd, level, \`group\`, active, registrationdate)
              VALUES ('${ACCOUNT[$r]}', '${ACCOUNT[$r]}@example.invalid', '$HASH', '${LEVEL[$r]}', '${ROLE_GROUPS[$r]}', '1', '2026-01-01');"
    done
} | sql >/dev/null || { echo "cannot create the test accounts" >&2; exit 2; }
pass "test accounts created"

# --- expected permissions, from the database ---------------------------------
in_groups() { # in_groups <user groups csv> <allowed groups csv>: any in common
    local g
    IFS=, read -ra allowed <<< "$2"
    for g in "${allowed[@]}"; do
        [ -n "$g" ] && [[ ",$1," == *",$g,"* ]] && return 0
    done
    return 1
}
# FN_UserCanViewSection, plus the record view groups of a dbview section
can_view() { # can_view <role> <section>
    local role=$1 sec=$2 row level gview level_user groups cfg
    [ "$role" = admin ] && return 0
    row=$(sqlv "SELECT CONCAT(IFNULL(level,''), '|', IFNULL(group_view,'')) FROM fn_sections WHERE id = '$sec'")
    [ -n "$row" ] || return 1
    level=${row%%|*}; gview=${row#*|}
    level_user=-1; groups=""
    if [ "$role" != anonymous ]; then level_user=${LEVEL[$role]}; groups=${ROLE_GROUPS[$role]}; fi
    if [ -n "$level" ] && [ "$level" -ge 0 ] 2>/dev/null && [ "$level" -gt "$level_user" ]; then return 1; fi
    if [ -n "$gview" ] && ! in_groups "$groups" "$gview"; then return 1; fi
    cfg=$(sqlv "SELECT varvalue FROM fncf_$sec WHERE varname = 'groupview'")
    if [ -n "$cfg" ] && ! in_groups "$groups" "$cfg"; then return 1; fi
    return 0
}
# FNDBVIEW::CanAddRecord
can_add() { # can_add <role> <section>
    local role=$1 sec=$2 gins gadm
    [ "$role" = admin ] && return 0
    [ "$role" = anonymous ] && return 1
    can_view "$role" "$sec" || return 1
    gins=$(sqlv "SELECT varvalue FROM fncf_$sec WHERE varname = 'groupinsert'")
    gadm=$(sqlv "SELECT varvalue FROM fncf_$sec WHERE varname = 'groupadmin'")
    [ -n "$gadm" ] && in_groups "${ROLE_GROUPS[$role]}" "$gadm" && return 0
    [ -z "$gins" ] && return 0
    in_groups "${ROLE_GROUPS[$role]}" "$gins"
}
# can_add, plus the Lombardia province check (cglombardia_checkprovincia):
# a non-admin needs RW_<province>, or RW_CO_LC_SO_MI_PV for those provinces
can_add_in() { # can_add_in <role> <section> <province>
    can_add "$1" "$2" || return 1
    [ "$REGION" != lombardia ] || [ "$1" = admin ] && return 0
    in_groups "${ROLE_GROUPS[$1]}" "RW_$3" && return 0
    [[ CO_LC_SO_MI_PV == *"$3"* ]] && in_groups "${ROLE_GROUPS[$1]}" RW_CO_LC_SO_MI_PV
}

# --- http helpers --------------------------------------------------------------
JAR=$WORK/jar
UA=$UA_DESKTOP
get() { # get <path> [curl args] -> body in $WORK/page, prints the status
    local p=$1; shift
    curl -sS -L -o "$WORK/page" -w '%{http_code}' -A "$UA" -c "$JAR" -b "$JAR" "$@" "$BASE$p"
}
php_errors() { grep -ciE '(fatal error|parse error|warning|deprecated|notice)</b>:|(fatal error|parse error|warning|uncaught exception)[^<]{0,40}:' "$WORK/page" || true; }
logged_in() { grep -q 'fnlogin=logout' "$WORK/page"; }
no_permission() { grep -qiE "you don't have permission|non hai i permessi" "$WORK/page"; }
login() { # login <role>
    rm -f "$JAR"
    get / >/dev/null
    [ "$1" = anonymous ] && return 0
    get '/index.php?mod=login&fnlogin=login' --data-urlencode "username=${ACCOUNT[$1]}" --data-urlencode "password=$TEST_PASS" >/dev/null
}

FIRST_CAVE=$(sqlv "SELECT id FROM ctl_caves ORDER BY id LIMIT 1")
# a cave with no view restriction, for the card sheet checks
PUBLIC_CAVE=$(sqlv "SELECT id FROM ctl_caves WHERE COALESCE(groupview, '') = '' AND COALESCE(recorddeleted, 0) = 0 ORDER BY id LIMIT 1")
# and a closed one and a tourist one (S, Y or X means yes), for the header badges
CLOSED_CAVE=$(sqlv "SELECT id FROM ctl_caves WHERE COALESCE(groupview, '') = '' AND COALESCE(recorddeleted, 0) = 0 AND closed IN ('S', 'Y', 'X') ORDER BY id LIMIT 1")
TOURIST_CAVE=$(sqlv "SELECT id FROM ctl_caves WHERE COALESCE(groupview, '') = '' AND COALESCE(recorddeleted, 0) = 0 AND tourist IN ('S', 'Y', 'X') ORDER BY id LIMIT 1")

# --- 2. pages per device and role ----------------------------------------------
for device in desktop android; do
    [ $device = desktop ] && UA=$UA_DESKTOP || UA=$UA_ANDROID
    for role in $ROLES; do
        tag="$device $role"
        login "$role"
        code=$(get /)
        check "$tag: home 200" [ "$code" = 200 ]
        if [ "$role" = anonymous ]; then
            check "$tag: not logged in" bash -c "! grep -q 'fnlogin=logout' '$WORK/page'"
        else
            check "$tag: logged in" logged_in
        fi
        pages="caves survey cavesystem map_caves"
        for sec in $pages; do
            [ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = '$sec'")" ] || continue
            code=$(get "/index.php?mod=$sec")
            check "$tag: $sec 200" [ "$code" = 200 ]
            check "$tag: $sec no PHP errors" [ "$(php_errors)" = 0 ]
            if can_view "$role" "$sec"; then
                check "$tag: $sec visible" bash -c "! grep -qiE \"you don't have permission|non hai i permessi\" '$WORK/page'"
                # caves list and map page layout (search bar, open/closed badges, map height)
                if [ "$sec" = caves ]; then
                    check "$tag: caves search bar" grep -q 'id="searchtext"' "$WORK/page"
                    check "$tag: caves cards carry the closed value" grep -q 'data-closed="' "$WORK/page"
                    check "$tag: caves closed badge rule" grep -qF '.card[data-closed="S"] .openkis-badge-closed' "$WORK/page"
                elif [ "$sec" = map_caves ]; then
                    check "$tag: map_caves map fills the screen" grep -q 'height:calc(100vh - 190px);min-height:400px' "$WORK/page"
                fi
            else
                check "$tag: $sec denied" no_permission
            fi
            [ "$role" = anonymous ] || check "$tag: $sec still logged in" logged_in
        done
        if [ -n "$FIRST_CAVE" ]; then
            code=$(get "/index.php?mod=caves&op=view&id=$FIRST_CAVE")
            check "$tag: cave view 200" [ "$code" = 200 ]
            check "$tag: cave view no PHP errors" [ "$(php_errors)" = 0 ]
            if ! can_view "$role" caves; then
                check "$tag: cave view denied" no_permission
            fi
        fi
        # cave sheet in thematic cards with a side column (f1fc559); on Lombardia
        # every field has a card (extra/openkis/custom/lombardia/viewheader_cards_caves.php)
        if [ -n "$PUBLIC_CAVE" ] && can_view "$role" caves; then
            get "/index.php?mod=caves&op=view&id=$PUBLIC_CAVE" >/dev/null
            check "$tag: cave sheet in cards" grep -q 'class="card openkis-card mb-3" id="card_location"' "$WORK/page"
            check "$tag: cave sheet side column" grep -q 'class="col-lg-4 openkis-sheet-side"' "$WORK/page"
            check "$tag: cave sheet no PHP errors" [ "$(php_errors)" = 0 ]
            if [ -n "$CLOSED_CAVE" ]; then
                get "/index.php?mod=caves&op=view&id=$CLOSED_CAVE" >/dev/null
                check "$tag: closed cave sheet shows the closed badge" grep -q 'openkis-sheet-badges.*openkis-badge-closed' "$WORK/page"
            fi
            if [ -n "$TOURIST_CAVE" ]; then
                get "/index.php?mod=caves&op=view&id=$TOURIST_CAVE" >/dev/null
                check "$tag: tourist cave sheet shows the tourist badge" grep -q 'openkis-sheet-badges.*badge badge-info' "$WORK/page"
            fi
            get "/index.php?mod=caves&op=view&id=$PUBLIC_CAVE" >/dev/null
            if [ "$REGION" = lombardia ]; then
                check "$tag: cave sheet has no other data card" bash -c "! grep -q 'id=\"card_other_data\"' '$WORK/page'"
            fi
        fi
        code=$(get '/index.php?fnapp=controlcenter')
        check "$tag: control center 200" [ "$code" = 200 ]
        check "$tag: control center no PHP errors" [ "$(php_errors)" = 0 ]
        if [ "$role" = admin ]; then
            check "$tag: control center open for the admin" grep -q 'opt=users_and_groups' "$WORK/page"
        else
            check "$tag: control center closed" bash -c "! grep -q 'opt=users_and_groups' '$WORK/page'"
        fi
        for p in /openkis_json.php /openkis_kml.php; do
            code=$(get "$p")
            check "$tag: $p 200" [ "$code" = 200 ]
            check "$tag: $p no PHP errors" [ "$(php_errors)" = 0 ]
        done
        # the map asks openkis_map_access.js.php which layers it may load
        # (#99): a section it lists as allowed must answer 200, one it lists
        # as not allowed is skipped by the map and answers 403
        code=$(get /bs_map.htm)
        check "$tag: bs_map.htm 200" [ "$code" = 200 ]
        check "$tag: bs_map.htm loads the current map stylesheet" grep -q 'bs_map/css/custom.css?v=20261029' "$WORK/page"
        code=$(get /openkis_map_access.js.php)
        check "$tag: map access script 200" [ "$code" = 200 ]
        check "$tag: map access script no PHP errors" [ "$(php_errors)" = 0 ]
        check "$tag: map access script defines OPENKIS_MAP_ACCESS" grep -q '^var OPENKIS_MAP_ACCESS = {' "$WORK/page"
        cp "$WORK/page" "$WORK/access"
        for m in caves springs artificials; do
            [ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = '$m'")" ] || continue
            level=$(grep -o "\"$m\":\"[a-z]*\"" "$WORK/access" | cut -d'"' -f4)
            if can_view "$role" "$m"; then
                check "$tag: map access $m = all (got '$level')" [ "$level" = all ]
            fi
            code=$(get "/openkis_kml.php?mod=$m")
            if [ -n "$level" ]; then
                check "$tag: map loads $m, openkis_kml.php 200 (got $code)" [ "$code" = 200 ]
            else
                check "$tag: map skips $m, openkis_kml.php 403 (got $code)" [ "$code" = 403 ]
            fi
        done
    done
done

# --- 3./4. inserting caves -----------------------------------------------------
STAMP=$(date +%s)
insert_cave() { # insert_cave <name> <province> -> saved code, or empty
    get '/index.php?mod=caves&op=new' --data-urlencode "name=$1" \
        --data "provincia=$2&regione=LOMBARDIA&latitude_txt=45.8&longitude_txt=9.8&coordinates_type=WGS84&xmetadbsave=Save" >/dev/null
    sqlv "SELECT code FROM ctl_caves WHERE name = '$1' LIMIT 1"
}
UA=$UA_DESKTOP
if [ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = 'caves'")" ]; then
    for role in $ROLES; do
        login "$role"
        name="regional-test-$STAMP-$role-BG"
        saved=$(sqlv "SELECT 1") # warm up the connection
        saved=$(insert_cave "$name" BG)
        if can_add_in "$role" caves BG; then
            check "$role: may insert a cave (got '$saved')" [ -n "$(sqlv "SELECT id FROM ctl_caves WHERE name = '$name'")" ]
            if [ "$REGION" = lombardia ]; then
                check "$role: new cave numbered LO<n> (got '$saved')" bash -c "[[ '$saved' =~ ^LO[0-9]+$ ]]"
            fi
        else
            check "$role: may not insert a cave" [ -z "$(sqlv "SELECT id FROM ctl_caves WHERE name = '$name'")" ]
            if [ "$REGION" = lombardia ] && can_add "$role" caves; then
                check "$role (no RW_BG): province refusal shown" grep -q 'Non puoi inserire dati nella provincia di BG' "$WORK/page"
            fi
        fi
        if [ "$REGION" = lombardia ] && [ "$role" != anonymous ] && [ "$role" != admin ] && can_add_in "$role" caves BG; then
            name="regional-test-$STAMP-$role-BS"
            insert_cave "$name" BS >/dev/null
            check "$role (RW_BG): province BS refused" [ -z "$(sqlv "SELECT id FROM ctl_caves WHERE name = '$name'")" ]
            check "$role (RW_BG): refusal message shown" grep -q 'Non puoi inserire dati nella provincia di BS' "$WORK/page"
        fi
    done
    if [ "$REGION" = lombardia ]; then
        login admin
        name="regional-test-$STAMP-admin-BS"
        insert_cave "$name" BS >/dev/null
        check "admin: any province (BS) accepted" [ -n "$(sqlv "SELECT id FROM ctl_caves WHERE name = '$name'")" ]
        get '/index.php?mod=caves&op=new' >/dev/null
        check "lombardia: Lombardia cave definition in use (DATAGG field)" grep -q 'name="DATAGG"' "$WORK/page"
        check "lombardia: generic-only field absent (alias)" bash -c "! grep -q 'name=\"alias\"' '$WORK/page'"
        if [ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = 'artificials'")" ]; then
            name="regional-test-$STAMP-artificial"
            get '/index.php?mod=artificials&op=new' --data-urlencode "name=$name" \
                --data "provincia=BG&regione=LOMBARDIA&latitude_txt=45.8&longitude_txt=9.8&coordinates_type=WGS84&xmetadbsave=Save" >/dev/null
            acode=$(sqlv "SELECT code FROM ctl_artificials WHERE name = '$name' LIMIT 1")
            check "lombardia: new artificial cavity numbered CALO<n> (got '$acode')" bash -c "[[ '$acode' =~ ^CALO[0-9]+$ ]]"
        fi
    fi
fi

# --- numeric sort of measures (os_lenght, upstream 9a0f590) -----------------------
# lengths and depths are stored as text: the list orders them by value, depths
# by absolute value (954 after 97 and 12,5; -150 before -40 and 12)
if [ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = 'cavesystem'")" ]; then
    sqlv "DELETE FROM ctl_cavesystems WHERE name LIKE 'regional-test-sort-%';
          INSERT INTO ctl_cavesystems (id, name, lenght_total, depth_total) VALUES
          ('990201', 'regional-test-sort-a', '97', '-40'),
          ('990202', 'regional-test-sort-b', '954', '12'),
          ('990203', 'regional-test-sort-c', '12,5', '-150');" >/dev/null
    orders=$(sqlv "SELECT varvalue FROM fncf_cavesystem WHERE varname = 'search_orders'")
    sorted() { # sorted <field> <desc> -> the test systems in list order
        get "/index.php?mod=cavesystem&order=$1&desc=$2&filter_name=regional-test-sort-a,regional-test-sort-b,regional-test-sort-c" >/dev/null
        grep -v 'filter_name=' "$WORK/page" | grep -o 'regional-test-sort-[abc]' | awk '!seen[$0]++' | sed 's/regional-test-sort-//' | tr -d '\n'
    }
    login admin
    for device in desktop android; do
        [ $device = desktop ] && UA=$UA_DESKTOP || UA=$UA_ANDROID
        for want in "lenght_total|1|bac" "lenght_total||cab" "depth_total|1|cab" "depth_total||bac"; do
            IFS='|' read -r f d w <<< "$want"
            [[ ",$orders," == *",$f,"* ]] || continue
            got=$(sorted "$f" "$d")
            check "$device: cave systems by $f${d:+ descending}: $w (got '$got')" [ "$got" = "$w" ]
        done
    done
    UA=$UA_DESKTOP
    sqlv "DELETE FROM ctl_cavesystems WHERE name LIKE 'regional-test-sort-%'" >/dev/null
fi

# --- 5. clean up -----------------------------------------------------------------
sqlv "DELETE FROM ctl_caves WHERE name LIKE 'regional-test-$STAMP-%'" >/dev/null
sqlv "DELETE FROM ctl_artificials WHERE name LIKE 'regional-test-$STAMP-%'" >/dev/null 2>&1

echo "site checks ($REGION): $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
