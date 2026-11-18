#!/bin/sh
# new_project.sh - create a new ArcGIS Maps SDK for Qt app from the installed SDK's own
# Qt Creator project template (the same files the "ArcGIS" wizard in Qt Creator generates).
#
# The template is read from the installed SDK, so the generated project always matches that
# SDK version. Only CMake projects are generated. The access token is never written into the
# source: the generated main.cpp reads it from an environment variable at runtime.
#
# Requires: POSIX sh, awk, sed, find, mkdir, cp. No Python.

set -eu

API_KEY_ENV="ARCGIS_RUNTIME_API_KEY"
PROG="new_project.sh"

usage() {
  cat <<'EOF'
Usage: new_project.sh --name <Name> [options]

Creates <dir>/<Name>/ from the installed ArcGIS Maps SDK for Qt template.

Options:
  --name <Name>        Project name: letters, digits, underscore; starts with a letter. Required.
  --dir <path>         Parent directory for the project (default: current directory).
  --ui quick|widgets   Qt Quick (QML) UI or Qt Widgets UI (default: quick).
  --view <type>        map | globalScene | localScene (default: map). Valid values depend
                       on the SDK version; run --list to see them.
  --basemap <style>    BasemapStyle enum value, e.g. ArcGISTopographic (default), ArcGISImagery,
                       ArcGISStreets. Run --list for the full set.
  --elevation <src>    Elevation source for 3D views, e.g. Terrain3D (default), TopoBathy3D.
  --sdk <ver|path>     SDK version (e.g. 300.2.0) or SDK install directory. Default: newest found.
  --list               Show the SDK installs found and the options their templates accept, then exit.
  --force              Allow writing into an existing, non-empty project directory.
  -h, --help           Show this help.

The SDK is found from the registry file its configure step writes
(EsriRuntimeQt/ArcGIS Runtime SDK for Qt <ver>.ini), or the ArcGISRuntimeInstall env var.
EOF
}

die() { printf '%s: error: %s\n' "$PROG" "$*" >&2; exit 1; }
note() { printf '%s\n' "$*"; }

# ---------------------------------------------------------------- arguments
NAME=""; PARENT="."; UI="quick"; VIEW="map"; BASEMAP="ArcGISTopographic"; ELEVATION=""
SDK_SEL=""; LIST=0; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name) [ $# -ge 2 ] || die "--name needs a value"; NAME=$2; shift 2 ;;
    --dir) [ $# -ge 2 ] || die "--dir needs a value"; PARENT=$2; shift 2 ;;
    --ui) [ $# -ge 2 ] || die "--ui needs a value"; UI=$2; shift 2 ;;
    --view) [ $# -ge 2 ] || die "--view needs a value"; VIEW=$2; shift 2 ;;
    --basemap) [ $# -ge 2 ] || die "--basemap needs a value"; BASEMAP=$2; shift 2 ;;
    --elevation) [ $# -ge 2 ] || die "--elevation needs a value"; ELEVATION=$2; shift 2 ;;
    --sdk) [ $# -ge 2 ] || die "--sdk needs a value"; SDK_SEL=$2; shift 2 ;;
    --list) LIST=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown argument: $1" ;;
  esac
done

case "$UI" in
  quick) TPL_GLOB="ArcGISRuntimeQmlCppTemplate*" ;;
  widgets) TPL_GLOB="ArcGISRuntimeQtTemplate*" ;;
  *) die "--ui must be 'quick' or 'widgets' (got '$UI')" ;;
esac

# Normalise Windows-style paths (C:\x) to forward slashes; Git Bash/MSYS accept C:/x.
fwd() { printf '%s' "$1" | sed 's|\\|/|g'; }

# ---------------------------------------------------------------- locate SDK installs
# Prints "<version><TAB><install dir>" for every registered install whose template folder exists.
find_installs() {
  for reg in "${ALLUSERSPROFILE:+$(fwd "$ALLUSERSPROFILE")/EsriRuntimeQt}" \
             "${HOME:+$HOME/.config/EsriRuntimeQt}"; do
    [ -n "$reg" ] && [ -d "$reg" ] || continue
    for ini in "$reg"/*.ini; do
      [ -f "$ini" ] || continue
      ver=$(basename "$ini" .ini | sed 's/.* //')
      dir=$(tr -d '\r' < "$ini" | sed -n 's/^.*InstallDir="\(.*\)".*$/\1/p' | head -n 1)
      [ -n "$dir" ] || continue
      dir=$(fwd "$dir")
      [ -d "$dir/sdk/ideintegration" ] && printf '%s\t%s\n' "$ver" "$dir"
    done
  done
  if [ -n "${ArcGISRuntimeInstall:-}" ]; then
    dir=$(fwd "$ArcGISRuntimeInstall")
    [ -d "$dir/sdk/ideintegration" ] && printf '%s\t%s\n' "$(version_of_dir "$dir")" "$dir"
  fi
  return 0
}

# Version from the template folder name, e.g. ArcGISRuntimeQmlCppTemplate300_2_0 -> 300.2.0
version_of_dir() {
  for t in "$1"/sdk/ideintegration/ArcGISRuntimeQmlCppTemplate*; do
    [ -d "$t" ] && { basename "$t" | sed 's/^[A-Za-z]*//; s/_/./g'; return 0; }
  done
  printf 'unknown'
}

# Sort "<version><TAB><dir>" lines newest first, dropping duplicate dirs.
sort_installs() {
  awk -F '\t' '!seen[$2]++ { n = split($1, p, "."); key = sprintf("%06d%06d%06d", p[1], p[2], p[3]); print key "\t" $0 }' |
    sort -r | cut -f 2-
}

INSTALLS=$(find_installs | sort_installs)

if [ -n "$SDK_SEL" ] && [ -d "$(fwd "$SDK_SEL")/sdk/ideintegration" ]; then
  SDK_DIR=$(fwd "$SDK_SEL"); SDK_VER=$(version_of_dir "$SDK_DIR")
elif [ -n "$SDK_SEL" ]; then
  line=$(printf '%s\n' "$INSTALLS" | awk -F '\t' -v v="$SDK_SEL" '$1 == v { print; exit }')
  [ -n "$line" ] || die "SDK '$SDK_SEL' not found. Installs found:
${INSTALLS:-  (none)}"
  SDK_VER=$(printf '%s' "$line" | cut -f 1); SDK_DIR=$(printf '%s' "$line" | cut -f 2)
else
  [ -n "$INSTALLS" ] || die "no ArcGIS Maps SDK for Qt install found. Install the SDK and run its
configure script (it registers the install), or pass --sdk <install dir>.
See https://developers.arcgis.com/qt/install-and-set-up/"
  line=$(printf '%s\n' "$INSTALLS" | head -n 1)
  SDK_VER=$(printf '%s' "$line" | cut -f 1); SDK_DIR=$(printf '%s' "$line" | cut -f 2)
fi

TPL_DIR=""
for t in "$SDK_DIR"/sdk/ideintegration/$TPL_GLOB; do [ -d "$t" ] && TPL_DIR=$t; done
[ -n "$TPL_DIR" ] && [ -f "$TPL_DIR/wizard.json" ] ||
  die "no '$UI' project template in $SDK_DIR/sdk/ideintegration (SDK $SDK_VER)."

# ---------------------------------------------------------------- read wizard.json
# Emits: opt<TAB>key<TAB>value | field<TAB>name<TAB>value | gen<TAB>source<TAB>target<TAB>condition<TAB>binary
WIZARD=$(tr -d '\r' < "$TPL_DIR/wizard.json" | awk '
  function val(s, k,   r) {
    if (!match(s, "\"" k "\"[ \t]*:[ \t]*\"")) return ""
    r = substr(s, RSTART + RLENGTH); sub(/".*$/, "", r); return r
  }
  function flush() {
    if (src != "") print "gen\t" src "\t" (tgt == "" ? src : tgt) "\t" cond "\t" bin
    src = ""; tgt = ""; cond = ""; bin = 0
  }
  /"generators"/ { gen = 1 }
  !gen && /"key"[ \t]*:/ { print "opt\t" val($0, "key") "\t" val($0, "value"); next }
  !gen && /"name"[ \t]*:/ { field = val($0, "name") }
  !gen && /"value"[ \t]*:/ && field != "" { print "field\t" field "\t" val($0, "value") }
  gen && /"source"[ \t]*:/ { flush(); src = val($0, "source") }
  gen && /"target"[ \t]*:/ { tgt = val($0, "target") }
  gen && /"condition"[ \t]*:/ { cond = val($0, "condition") }
  gen && /"isBinary"[ \t]*:[ \t]*true/ { bin = 1 }
  END { flush() }')

opt() { printf '%s\n' "$WIZARD" | awk -F '\t' -v k="$1" '$1 == "opt" && $2 == k { print $3; exit }'; }
field_values() { printf '%s\n' "$WIZARD" | awk -F '\t' -v f="$1" '$1 == "field" && $2 == f { print $3 }'; }

VIEWS=$(field_values GeoViewType)
[ -n "$VIEWS" ] || VIEWS=$(printf 'map\nglobalScene')   # older templates: 2D map or global 3D scene only
BASEMAPS=$(field_values BaseMapOption)
ELEVATIONS=$(field_values ElevationOption)

if [ "$LIST" = 1 ]; then
  note "SDK installs found (newest first):"
  printf '%s\n' "${INSTALLS:-  (none)}" | sed 's/^/  /'
  note ""
  note "Using SDK $SDK_VER: $SDK_DIR"
  note "Template ($UI): $TPL_DIR"
  note "  --view:      $(printf '%s ' $VIEWS)"
  note "  --basemap:   $(printf '%s ' $BASEMAPS)"
  note "  --elevation: $(printf '%s ' $ELEVATIONS)"
  exit 0
fi

# ---------------------------------------------------------------- validate options
[ -n "$NAME" ] || { usage >&2; die "--name is required"; }
printf '%s' "$NAME" | grep -Eq '^[A-Za-z][A-Za-z0-9_]*$' ||
  die "--name '$NAME' must start with a letter and contain only letters, digits and '_'"

in_list() { printf '%s\n' "$2" | grep -Fqx -- "$1"; }
in_list "$VIEW" "$VIEWS" || die "--view '$VIEW' is not supported by SDK $SDK_VER. Valid: $(printf '%s ' $VIEWS)"
[ -z "$BASEMAPS" ] || in_list "$BASEMAP" "$BASEMAPS" ||
  die "--basemap '$BASEMAP' is not offered by the SDK $SDK_VER template. Valid: $(printf '%s ' $BASEMAPS)"
[ -n "$ELEVATION" ] || ELEVATION=$(printf '%s\n' "$ELEVATIONS" | head -n 1)
[ -z "$ELEVATIONS" ] || in_list "$ELEVATION" "$ELEVATIONS" ||
  die "--elevation '$ELEVATION' is not valid. Valid: $(printf '%s ' $ELEVATIONS)"

THREE_D=""; [ "$VIEW" = map ] || THREE_D="yes"

PARENT=$(fwd "$PARENT")
[ -d "$PARENT" ] || die "--dir '$PARENT' does not exist"
DEST="$PARENT/$NAME"
if [ -d "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ] && [ "$FORCE" != 1 ]; then
  die "$DEST already exists and is not empty (use --force to write into it)"
fi

# ---------------------------------------------------------------- template variables
CN=$(printf '%s' "$NAME" | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }')
GUARD=$(printf '%s_H' "$CN" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9_]/_/g')
DESCR="ArcGIS Maps SDK for Qt app"

WORK=$(mktemp -d 2>/dev/null || mktemp -d -t arcgisnp)
trap 'rm -rf "$WORK"' EXIT INT TERM
VARS="$WORK/vars"
{
  printf 'ProjectName\t%s\n' "$NAME"
  printf 'CN\t%s\n' "$CN"
  printf 'IncludeGuard\t%s\n' "$GUARD"
  printf 'MainCppFileName\tmain.cpp\n'
  printf 'ProFileName\t%s.pro\n' "$NAME"
  printf 'ProjectDirectory\t%s\n' "$DEST"
  printf 'BuildSystem\tcmake\n'
  printf 'CurrentYear\t%s\n' "$(date +%Y)"
  printf 'AppDescr\t%s\nAppDescription\t%s\n' "$DESCR" "$DESCR"
  printf 'GeoViewType\t%s\n' "$VIEW"
  printf 'ThreeDSample\t%s\n' "$THREE_D"
  printf 'BaseMapOption\t%s\n' "$BASEMAP"
  printf 'ElevationOption\t%s\n' "$ELEVATION"
  printf 'AccessToken\t\n'
  # Literal option values from wizard.json (ArcGISVersion, MinQtMajor, ...); computed ones are set above.
  printf '%s\n' "$WIZARD" | awk -F '\t' '$1 == "opt" && $3 !~ /%\{/ { print $2 "\t" $3 }'
} > "$VARS"

# ---------------------------------------------------------------- renderer
# Implements the subset of Qt Creator's template language the ArcGIS templates use:
#   %{Var}, %{JS: ( 'a' === 'b' ? 'x' : 'y' )} (also !==), @if <expr> / @else / @endif (not nested),
#   backslash escapes ("\x" -> "x") and leading tabs -> 4 spaces, matching Qt Creator's output.
#   Anything else is an error, so a changed template fails loudly.
render() { # $1 = source file, $2 = destination file
  awk -v varsfile="$VARS" -v src="$1" -v keyenv="$API_KEY_ENV" -v Q="'" '
    BEGIN {
      FS = "\n"
      while ((getline l < varsfile) > 0) { i = index(l, "\t"); V[substr(l, 1, i - 1)] = substr(l, i + 1) }
      active = 1; depth = 0
    }
    function fail(msg) { printf "%s:%d: %s\n", src, NR, msg > "/dev/stderr"; err = 1; exit 1 }
    function unesc(s,   out, i) {      # Qt Creator: a backslash escapes the next character
      out = ""
      while ((i = index(s, "\\")) > 0 && i < length(s)) { out = out substr(s, 1, i - 1) substr(s, i + 1, 1); s = substr(s, i + 2) }
      return out s
    }
    function detab(s,   lead) {        # Qt Creator re-indents generated files: leading tab = 4 spaces
      lead = ""
      while (substr(s, 1, 1) == "\t" || substr(s, 1, 1) == " ") { lead = lead (substr(s, 1, 1) == "\t" ? "    " : " "); s = substr(s, 2) }
      return lead s
    }
    function vars(s,   out, name) {
      out = ""
      while (match(s, /%[{][A-Za-z][A-Za-z0-9]*[}]/)) {
        name = substr(s, RSTART + 2, RLENGTH - 3)
        if (!(name in V)) fail("unknown template variable %{" name "}")
        out = out substr(s, 1, RSTART - 1) V[name]; s = substr(s, RSTART + RLENGTH)
      }
      return out s
    }
    function quoted(s, n,   k, q) {       # n-th single-quoted string in s
      for (k = 1; k <= n; k++) { if (!match(s, SQ)) return ""; q = substr(s, RSTART + 1, RLENGTH - 2); s = substr(s, RSTART + RLENGTH) }
      return q
    }
    function js(s,   expr, a, b, x, y, eq) {
      if (JSRE == "") {                    # built at runtime: portable across gawk, mawk and BSD awk
        SQ = Q "[^" Q "]*" Q; W = "[ \t]*"
        JSRE = "%[{]JS:" W "[(]" W SQ W "[!=]==" W SQ W "[?]" W SQ W ":" W SQ W "[)]" W "[}]"
      }
      while (match(s, JSRE)) {
        st = RSTART; ln = RLENGTH          # quoted() calls match() and overwrites RSTART/RLENGTH
        expr = substr(s, st, ln)
        a = quoted(expr, 1); b = quoted(expr, 2); x = quoted(expr, 3); y = quoted(expr, 4)
        eq = (index(expr, "!==") == 0)
        s = substr(s, 1, st - 1) (((a == b) == eq) ? x : y) substr(s, st + ln)
      }
      return s
    }
    function expand(s) { return js(vars(unesc(s))) }
    {
      line = $0
      sub(/\r$/, "", line)
      if (line ~ /^[ \t]*@/) {
        d = line; sub(/^[ \t]*/, "", d)
        if (d ~ /^@if[ \t]/) {
          if (depth > 0) fail("nested @if is not supported")
          c = expand(substr(d, 4)); gsub(/^[ \t]+|[ \t]+$/, "", c)
          depth = 1; active = (c != "" && c != "false" && c != "0"); next
        }
        if (d ~ /^@else[ \t]*$/) { if (depth == 0) fail("@else without @if"); active = !active; next }
        if (d ~ /^@endif[ \t]*$/) { if (depth == 0) fail("@endif without @if"); depth = 0; active = 1; next }
        fail("unsupported template directive: " d)
      }
      if (!active) next
      # Read the access token from the environment instead of writing it into the source.
      tok = "QString(\"%{AccessToken}\")"
      if ((i = index(line, tok)) > 0) {
        line = substr(line, 1, i - 1) "qEnvironmentVariable(\"" keyenv "\")" substr(line, i + length(tok)); tokenfix = 1
      }
      out = detab(expand(line))
      if (index(out, "%{") > 0) fail("unrendered template expression: " out)
      print out
    }
    END {
      if (err) exit 1
      if (depth != 0) fail("@if without @endif")
      if (tokenfix) print "TOKENFIX" > (varsfile ".tokenfix")
    }' "$1" > "$2"
}

expand_name() { # expand %{Var} in a generator target path
  printf '%s' "$1" | awk -v varsfile="$VARS" '
    BEGIN { while ((getline l < varsfile) > 0) { i = index(l, "\t"); V[substr(l, 1, i - 1)] = substr(l, i + 1) } }
    { s = $0; out = ""
      while (match(s, /%[{][A-Za-z][A-Za-z0-9]*[}]/)) {
        n = substr(s, RSTART + 2, RLENGTH - 3)
        if (!(n in V)) { print "unknown variable %{" n "} in target " $0 > "/dev/stderr"; exit 1 }
        out = out substr(s, 1, RSTART - 1) V[n]; s = substr(s, RSTART + RLENGTH) }
      print out s }'
}

# Generator condition: empty = always; otherwise only "%{JS: '%{BuildSystem}' === '<x>' }" is understood.
wanted() {
  [ -z "$1" ] && return 0
  sys=$(printf '%s' "$1" | sed -n "s/^%{JS:[ ]*'%{BuildSystem}'[ ]*===[ ]*'\([a-z]*\)'[ ]*}\$/\1/p")
  [ -n "$sys" ] || die "unsupported generator condition in $TPL_DIR/wizard.json: $1"
  [ "$sys" = cmake ]
}

# ---------------------------------------------------------------- generate
STAGE="$WORK/out"
mkdir -p "$STAGE"
COUNT=0
GENS=$(printf '%s\n' "$WIZARD" | awk -F '\t' '$1 == "gen" { print $2 "\t" $3 "\t" $4 "\t" $5 }')
[ -n "$GENS" ] || die "no files listed in $TPL_DIR/wizard.json"

OLDIFS=$IFS
IFS='
'
for g in $GENS; do
  IFS=$OLDIFS
  src=$(printf '%s' "$g" | cut -f 1); tgt=$(printf '%s' "$g" | cut -f 2)
  cond=$(printf '%s' "$g" | cut -f 3); bin=$(printf '%s' "$g" | cut -f 4)
  if wanted "$cond"; then
    [ -f "$TPL_DIR/$src" ] || die "template file missing: $TPL_DIR/$src"
    out="$STAGE/$(expand_name "$tgt")"
    mkdir -p "$(dirname "$out")"
    if [ "$bin" = 1 ]; then cp "$TPL_DIR/$src" "$out"; else render "$TPL_DIR/$src" "$out" || die "failed to render $src"; fi
    COUNT=$((COUNT + 1))
  fi
  IFS='
'
done
IFS=$OLDIFS

[ -f "$STAGE/CMakeLists.txt" ] || die "template produced no CMakeLists.txt"
[ -f "$VARS.tokenfix" ] || note "warning: could not find the access-token line in main.cpp; check that no token is hard-coded."

mkdir -p "$DEST"
cp -R "$STAGE"/. "$DEST"/

# ---------------------------------------------------------------- summary
QT_LINE=$(grep -E 'find_package\(Qt6' "$DEST/CMakeLists.txt" | head -n 1 | sed 's/^[ \t]*//')
MINQT="$(opt MinQtMajor).$(opt MinQtMinor).$(opt MinQtPatch)"
note "Created $DEST ($COUNT files) from ArcGIS Maps SDK for Qt $SDK_VER"
note "  SDK:      $SDK_DIR"
note "  UI/view:  $UI / $VIEW, basemap $BASEMAP$( [ -n "$THREE_D" ] && printf ', elevation %s' "$ELEVATION")"
note "  Requires: Qt >= $MINQT with the modules in: $QT_LINE"
note "  Token:    set the $API_KEY_ENV environment variable before running the app."
note "Build (any platform): cmake -S \"$DEST\" -B \"$DEST/build\" -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=<Qt kit dir>"
note "                      cmake --build \"$DEST/build\""
