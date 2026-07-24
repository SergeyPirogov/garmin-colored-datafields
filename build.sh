#!/usr/bin/env bash
# Builds all Connect IQ data field projects and writes the .iq packages to dist/.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
PROJECTS=(colored-hr colored-power)

CIQ_HOME="${CIQ_HOME:-$HOME/Library/Application Support/Garmin/ConnectIQ}"
SDK_CFG="$CIQ_HOME/current-sdk.cfg"
if [[ -z "${MONKEYC:-}" ]]; then
    if [[ -f "$SDK_CFG" ]]; then
        SDK_PATH="$(cat "$SDK_CFG")"
    else
        echo "error: could not find current-sdk.cfg at $SDK_CFG (set MONKEYC to the monkeyc binary path)" >&2
        exit 1
    fi
    MONKEYC="$SDK_PATH/bin/monkeyc"
fi

if [[ ! -x "$MONKEYC" ]]; then
    echo "error: monkeyc not found or not executable at $MONKEYC" >&2
    exit 1
fi

DEVELOPER_KEY="${DEVELOPER_KEY:-$ROOT_DIR/../garmin-colored-hr/developer_key.der}"
if [[ ! -f "$DEVELOPER_KEY" ]]; then
    echo "error: developer key not found at $DEVELOPER_KEY (set DEVELOPER_KEY to your .der key path)" >&2
    exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

for project in "${PROJECTS[@]}"; do
    project_dir="$ROOT_DIR/$project"
    jungle="$project_dir/monkey.jungle"
    out="$DIST_DIR/$project.iq"

    echo "==> Building $project"
    rm -rf "$project_dir/bin" "$project_dir/gen" "$project_dir/mir" "$project_dir/internal-mir" "$project_dir/external-mir"
    rm -f "$project_dir"/*.iq "$project_dir"/*.prg "$project_dir"/*.prg.debug.xml

    "$MONKEYC" -f "$jungle" -o "$out" -y "$DEVELOPER_KEY" -e -w

    echo "==> $project built: $out"
done

echo "All builds complete. Output in $DIST_DIR"
