#!/usr/bin/env bash
# Per-record edit permissions of the caves section (finis dbview, #80; upstream
# c1d7ba5 tests the same scenario on its local install) against a running
# OpenKIS site with a disposable database. Never run it against production: it
# creates a test account, inserts a test cave and changes the section's
# enable_permissions_edit_each_records setting (restored at the end).
# Run tests/regional/site-checks.sh first: it creates the other test accounts.
#
#   SITE_SQL="mariadb -N openkis" tests/regional/record-permissions.sh http://localhost:8099 lombardia
#
# With per-record edit groups on (enable_permissions_edit_each_records = 1, the
# Lombardia setting), for a desktop and an Android browser (user agents):
#   1. an editor (in the section's insert groups, RW_BG, r_caves) who is not in
#      the record's edit groups (groupinsert) can't open the edit form, save
#      the record or change its enabled users; they can still view it;
#   2. the administrator can edit it and open the enabled-users page;
#   3. once the administrator enables the editor on the record, the editor can
#      save it; after the removal, the editor is refused again;
#   4. a record without edit groups can be edited by the editor;
#   5. with the setting off, the editor may edit any record (old behaviour);
#   6. anonymous, read-only and read-write users get no edit form, can't save
#      and can't add enabled users;
#   lombardia: 7. on a BS cave the editor (RW_BG only) gets the province
#      refusal on save; 8. enabled on that cave by the administrator, the
#      editor can save it (the province check accepts enabled users).
# The test cave and the editor's enabled-user rows are removed at the end.
#
# Settings (environment variables):
#   SITE_SQL   command that reads SQL on stdin for the site's database (required)
#   SITE_PHP   php command used to hash the test password [php]
#   TEST_PASS  password of the test accounts [Regional-Test-2026]
#   VERBOSE=1  print every passed check too
set -uo pipefail

BASE=${1:?usage: record-permissions.sh <base-url> <region>}
BASE=${BASE%/}
REGION=${2:-}
: "${SITE_SQL:?SITE_SQL must be set: a command reading SQL for the site database on stdin}"
: "${SITE_PHP:=php}"
: "${TEST_PASS:=Regional-Test-2026}"
: "${VERBOSE:=0}"

case "$BASE" in
    *speleolombardia*) echo "refusing to run against production ($BASE)" >&2; exit 2 ;;
esac

WORK=$(mktemp -d)
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
UA=$UA_DESKTOP

[ -n "$(sqlv "SELECT id FROM fn_sections WHERE id = 'caves'")" ] || { echo "no caves section, nothing to test"; exit 0; }

# --- setup ---------------------------------------------------------------------
# the editor: in the section's first insert group, RW_BG (Lombardia province
# BG) and r_caves; on Lombardia these are the curator's groups
GINS=$(sqlv "SELECT varvalue FROM fncf_caves WHERE varname = 'groupinsert'")
GINS=${GINS%%,*}
EDITOR=test_editor
EDITOR_GROUPS=$(echo "$GINS,RW_BG,r_caves" | sed 's/^,//')
ORIG_FLAG=$(sqlv "SELECT varvalue FROM fncf_caves WHERE varname = 'enable_permissions_edit_each_records'")
HASH=$($SITE_PHP -r 'echo password_hash($argv[1], PASSWORD_BCRYPT);' "$TEST_PASS" 2>/dev/null) \
    || { echo "php is needed to hash the test password" >&2; exit 2; }
ID=990101
ID_BS=990102
NAME="permtest-$(date +%s)"
cleanup() {
    sqlv "UPDATE fncf_caves SET varvalue = '$ORIG_FLAG' WHERE varname = 'enable_permissions_edit_each_records'" >/dev/null
    sqlv "DELETE FROM ctl_caves WHERE id IN ('$ID', '$ID_BS')" >/dev/null
    sqlv "DELETE FROM fieldusers WHERE username = '$EDITOR'" >/dev/null
    rm -rf "$WORK"
}
trap cleanup EXIT
COLUMNS_CAVES=$(sqlv "SELECT GROUP_CONCAT(COLUMN_NAME) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'ctl_caves'")
{
    for g in r_caves RW_BG RW_BS ${GINS:+$GINS}; do
        echo "INSERT IGNORE INTO fn_groups (groupname) VALUES ('$g');"
    done
    echo "DELETE FROM fn_users WHERE username = '$EDITOR';"
    echo "INSERT INTO fn_users (username, email, passwd, level, \`group\`, active, registrationdate)
          VALUES ('$EDITOR', '$EDITOR@example.invalid', '$HASH', '0', '$EDITOR_GROUPS', '1', '2026-01-01');"
    echo "DELETE FROM ctl_caves WHERE id IN ('$ID', '$ID_BS');"
    echo "DELETE FROM fieldusers WHERE username = '$EDITOR';"
    for r in "$ID|BG|LOT9911" "$ID_BS|BS|LOT9912"; do
        IFS='|' read -r id prov code <<< "$r"
        cols="id, code, name" vals="'$id', '$code', '$NAME-$prov'"
        # only the columns this site's cave table has (provincia and regione
        # are regional)
        for cv in "provincia|$prov" "regione|LOMBARDIA" "latitude_txt|45.8" "longitude_txt|9.8" \
                  "coordinates_type|WGS84" "latitude|45.8" "longitude|9.8"; do
            c=${cv%%|*}
            [[ ",$COLUMNS_CAVES," == *",$c,"* ]] || continue
            cols="$cols, $c" vals="$vals, '${cv#*|}'"
        done
        echo "INSERT INTO ctl_caves ($cols) VALUES ($vals);"
    done
} | sql >/dev/null || { echo "cannot create the test account and caves" >&2; exit 2; }
check "test cave and editor ($EDITOR_GROUPS) created" [ -n "$(sqlv "SELECT id FROM ctl_caves WHERE id = '$ID'")" ]

# --- http helpers --------------------------------------------------------------
declare -A USER=([editor]=$EDITOR [admin]=test_admin [read-only]=test_ro [read-write]=test_rw)
fetch() { # fetch <jar> <path> [curl args] -> body in $WORK/page, prints the status
    local jar=$WORK/$1.jar p=$2; shift 2
    curl -sS -L -o "$WORK/page" -w '%{http_code}' -A "$UA" -c "$jar" -b "$jar" "$@" "$BASE$p"
}
login() { # login <who>
    rm -f "$WORK/$1.jar"
    fetch "$1" / >/dev/null
    [ "$1" = anonymous ] && return 0
    fetch "$1" '/index.php?mod=login&fnlogin=login' --data-urlencode "username=${USER[$1]}" --data-urlencode "password=$TEST_PASS" >/dev/null
    fetch "$1" '/index.php?mod=caves' >/dev/null
    grep -q 'fnlogin=logout' "$WORK/page"
}
edit_form() { grep -q 'name="xmetadbsave"' "$WORK/page"; }
refused() { grep -qiE "non puoi|you may not do that|you don't have permission|non hai i permessi" "$WORK/page"; }
name_of() { sqlv "SELECT name FROM ctl_caves WHERE id = '$1'"; }
enabled_rows() { sqlv "SELECT COUNT(*) FROM fieldusers WHERE username = '$EDITOR' AND table_unirecid = '$1'"; }
set_flag() { sqlv "UPDATE fncf_caves SET varvalue = '$1' WHERE varname = 'enable_permissions_edit_each_records'" >/dev/null; }
set_groups() { sqlv "UPDATE ctl_caves SET groupinsert = '$2' WHERE id = '$1'" >/dev/null; }
# re-posts every field of the edit form of cave <id> as <who>, with a new name
save_record() { # save_record <who> <id> <new name>
    fetch "$1" "/index.php?mod=caves&op=edit&id=$2" >/dev/null
    cp "$WORK/page" "$WORK/form.html"
    python3 - "$WORK/form.html" "$3" > "$WORK/post.txt" <<'PY'
# the edit form's fields as the browser would send them (the search box "q" left out)
import sys, html
from html.parser import HTMLParser
from urllib.parse import urlencode
src = open(sys.argv[1], encoding="utf-8", errors="replace").read()
newname = sys.argv[2]
class P(HTMLParser):
    def __init__(self):
        super().__init__(); self.fields = []; self.sel = None; self.ta = None
    def handle_starttag(self, t, a):
        a = dict(a)
        if t == "input":
            ty = (a.get("type") or "text").lower(); n = a.get("name")
            if not n or n == "q": return
            if ty in ("checkbox", "radio"):
                if "checked" in a: self.fields.append((n, a.get("value", "on")))
            elif ty == "submit":
                if n == "xmetadbsave": self.fields.append((n, a.get("value", "1")))
            elif ty not in ("button", "file", "reset", "image"):
                self.fields.append((n, a.get("value") or ""))
        elif t == "select": self.sel = a.get("name"); self.selected = False; self.first = None
        elif t == "option" and self.sel:
            v = a.get("value", "")
            if self.first is None: self.first = v
            if "selected" in a: self.fields.append((self.sel, v)); self.selected = True
        elif t == "textarea": self.ta = a.get("name"); self.tabuf = ""
    def handle_endtag(self, t):
        if t == "select" and self.sel:
            if not self.selected and self.first is not None and not self.sel.endswith("[]"): self.fields.append((self.sel, self.first))
            self.sel = None
        elif t == "textarea" and self.ta:
            self.fields.append((self.ta, html.unescape(self.tabuf))); self.ta = None
    def handle_data(self, d):
        if self.ta is not None: self.tabuf += d
p = P(); p.feed(src)
fields = [(k, v) for k, v in p.fields if k != "name"] + [("name", newname)]
print(urlencode(fields), end="")
PY
    fetch "$1" "/index.php?mod=caves&op=updaterecord&id=$2" -X POST --data-binary "@$WORK/post.txt"
}
# a save posted without the form (the record's fields only)
post_save() { # post_save <who> <id> <new name>
    fetch "$1" "/index.php?mod=caves&op=updaterecord&id=$2" -X POST \
        --data "xmetadbsave=Save&_xmetadbform_pk_id=$2&id=$2" --data-urlencode "name=$3"
}

for device in desktop android; do
    [ $device = desktop ] && UA=$UA_DESKTOP || UA=$UA_ANDROID
    t=$device
    for who in editor admin read-only read-write; do
        check "$t: $who logs in" login "$who"
    done
    login anonymous

    # 1. flag on, record reserved to a group the editor is not in
    set_flag 1
    set_groups "$ID" RW_BS
    fetch editor "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 1: editor outside the record's edit groups: no edit form" bash -c "! grep -q 'name=\"xmetadbsave\"' '$WORK/page'"
    post_save editor "$ID" "$NAME-hacked" >/dev/null
    check "$t 1: editor's save refused, record unchanged" [ "$(name_of "$ID")" = "$NAME-BG" ]
    fetch editor "/index.php?mod=caves&op=users&id=$ID" -X POST --data "usertoadd=$EDITOR" >/dev/null
    check "$t 1: editor can't enable themselves on the record" [ "$(enabled_rows "$ID")" = 0 ]
    code=$(fetch editor "/index.php?mod=caves&op=view&id=$ID")
    check "$t 1: editor can still view the record" bash -c "[ '$code' = 200 ] && grep -q '$NAME-BG' '$WORK/page'"

    # 2. the administrator
    fetch admin "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 2: admin gets the edit form" edit_form
    code=$(fetch admin "/index.php?mod=caves&op=users&id=$ID")
    check "$t 2: admin opens the enabled-users page" bash -c "[ '$code' = 200 ] && ! grep -qiE 'non puoi|you may not do that' '$WORK/page'"

    # 3. enabled by the administrator, the editor may save; removed, refused again
    fetch admin "/index.php?mod=caves&op=users&id=$ID" -X POST --data "usertoadd=$EDITOR" >/dev/null
    check "$t 3: admin enables the editor on the record" [ "$(enabled_rows "$ID")" = 1 ]
    fetch editor "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 3: enabled editor gets the edit form" edit_form
    save_record editor "$ID" "$NAME-BG-enabled" >/dev/null
    check "$t 3: enabled editor saves the record (name '$(name_of "$ID")')" [ "$(name_of "$ID")" = "$NAME-BG-enabled" ]
    fetch admin "/index.php?mod=caves&op=users&id=$ID&usertodel=$EDITOR" >/dev/null
    check "$t 3: admin removes the editor" [ "$(enabled_rows "$ID")" = 0 ]
    fetch editor "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 3: editor refused again after the removal" bash -c "! grep -q 'name=\"xmetadbsave\"' '$WORK/page'"

    # 4. record without edit groups
    set_groups "$ID" ""
    fetch editor "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 4: record without edit groups: editor gets the edit form" edit_form
    save_record editor "$ID" "$NAME-BG-open" >/dev/null
    check "$t 4: editor saves it (name '$(name_of "$ID")')" [ "$(name_of "$ID")" = "$NAME-BG-open" ]

    # 5. flag off: anyone who may add may edit (old behaviour)
    set_flag 0
    set_groups "$ID" RW_BS
    fetch editor "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
    check "$t 5: setting off: editor gets the edit form of a reserved record" edit_form
    save_record editor "$ID" "$NAME-BG" >/dev/null
    check "$t 5: setting off: editor saves it (name '$(name_of "$ID")')" [ "$(name_of "$ID")" = "$NAME-BG" ]
    set_flag 1

    # 6. users without write access, on a record without edit groups
    set_groups "$ID" ""
    for who in anonymous read-only read-write; do
        fetch "$who" "/index.php?mod=caves&op=edit&id=$ID" >/dev/null
        check "$t 6: $who gets no edit form" bash -c "! grep -q 'name=\"xmetadbsave\"' '$WORK/page'"
        post_save "$who" "$ID" "$NAME-hacked" >/dev/null
        check "$t 6: $who can't save" [ "$(name_of "$ID")" = "$NAME-BG" ]
        fetch "$who" "/index.php?mod=caves&op=users&id=$ID" -X POST --data "usertoadd=$EDITOR" >/dev/null
        check "$t 6: $who can't add enabled users" [ "$(enabled_rows "$ID")" = 0 ]
    done

    if [ "$REGION" = lombardia ]; then
        # 7. province rule on an existing BS cave, for an RW_BG editor
        set_groups "$ID_BS" ""
        save_record editor "$ID_BS" "$NAME-BS-changed" >/dev/null
        check "$t 7: BS cave: editor (RW_BG) refused on save" [ "$(name_of "$ID_BS")" = "$NAME-BS" ]
        check "$t 7: BS cave: province refusal shown" grep -q 'Non puoi inserire dati nella provincia di BS' "$WORK/page"
        # 8. enabled on the BS cave, the editor may save it
        fetch admin "/index.php?mod=caves&op=users&id=$ID_BS" -X POST --data "usertoadd=$EDITOR" >/dev/null
        save_record editor "$ID_BS" "$NAME-BS-enabled" >/dev/null
        check "$t 8: BS cave, editor enabled on it: saved (name '$(name_of "$ID_BS")')" [ "$(name_of "$ID_BS")" = "$NAME-BS-enabled" ]
        fetch admin "/index.php?mod=caves&op=users&id=$ID_BS&usertodel=$EDITOR" >/dev/null
        sqlv "UPDATE ctl_caves SET name = '$NAME-BS' WHERE id = '$ID_BS'" >/dev/null
    fi
done

echo "record permission checks ($REGION): $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
