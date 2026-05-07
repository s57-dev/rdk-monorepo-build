#!/bin/sh
set -eu

CONF="/etc/rdk-ota.conf"
if [ -f "$CONF" ]; then
    # shellcheck disable=SC1090
    . "$CONF"
fi

: "${SWU_ASSET:=rpi-package-swupdate}"
: "${SWUPDATE_HW:=raspberrypi4-64-rdke:1.0}"
: "${TMPFILE:=/tmp/update.swu}"

trap 'rm -f "$TMPFILE"' EXIT

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  (none)        Auto-check latest GitHub release (requires GITHUB_REPO in $CONF)
  -u <url>      Download .swu or .zip (containing .swu) from the given URL
  -f <file>     Install .swu or .zip (containing .swu) from a local file path
  -h            Show this help

Configuration: $CONF
  GITHUB_REPO   GitHub repository in the form owner/repo
  SWU_ASSET     Substring to match the release asset filename (default: rpi-package-swupdate)
  SWUPDATE_HW   Hardware compatibility string (default: raspberrypi4-64-rdke:1.0)
EOF
    exit 1
}

extract_zip() {
    unzip -p "$1" > "$TMPFILE"
    rm -f "$1"
}

fetch_url() {
    echo "Downloading $1 ..."
    case "$1" in
        *.zip)
            tmpzip=$(mktemp /tmp/update_XXXXXX)
            curl -fL "$1" -o "$tmpzip"
            extract_zip "$tmpzip"
            ;;
        *) curl -fL "$1" -o "$TMPFILE" ;;
    esac
}

use_local() {
    [ -f "$1" ] || { echo "File not found: $1" >&2; exit 1; }
    echo "Using local file: $1"
    case "$1" in
        *.zip) unzip -p "$1" > "$TMPFILE" ;;
        *)     cp "$1" "$TMPFILE" ;;
    esac
}

fetch_github() {
    : "${GITHUB_REPO:?GITHUB_REPO must be set in $CONF}"
    echo "Fetching latest release info from github.com/$GITHUB_REPO ..."
    download_url=$(curl -sf \
        "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
        | grep -o '"browser_download_url": *"[^"]*'"$SWU_ASSET"'[^"]*"' \
        | head -n1 | cut -d'"' -f4)
    [ -n "$download_url" ] || { echo "No asset matching '$SWU_ASSET' found in latest release" >&2; exit 1; }
    fetch_url "$download_url"
}

install_update() {
    slot=$(fw_printenv -n slot 2>/dev/null)
    case "$slot" in
        a) target="stable,copy2"; copy="copy2" ;;
        b) target="stable,copy1"; copy="copy1" ;;
        *) echo "Unknown active slot: '$slot'" >&2; exit 1 ;;
    esac
    echo "Active slot: $slot | writing to $copy ..."
    swupdate -e "$target" -H "$SWUPDATE_HW" -i "$TMPFILE" -v
    echo "Update installed successfully. Rebooting ..."
    reboot
}

mode="auto"
src=""

while getopts "u:f:h" opt; do
    case "$opt" in
        u) mode="url";  src="$OPTARG" ;;
        f) mode="file"; src="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

case "$mode" in
    auto) fetch_github ;;
    url)  fetch_url  "$src" ;;
    file) use_local  "$src" ;;
esac

install_update
