#!/bin/zsh
# Copies the apps published here from MXcodeIDE: what's committed there (not work in progress), as real folders —
# git keeps a symbolic link as just its target's path, so a link to MXcodeIDE would show up on GitHub as one line.
#
#   ./sync-from-MXcodeIDE.sh            then commit and push as usual
#   MXCODEIDE=/path/to/MXcodeIDE ./sync-from-MXcodeIDE.sh
set -euo pipefail

SRC=${MXCODEIDE:-$HOME/MyCodeGIT/MXcodeIDE}
DEST=${0:A:h}/MxAppsIDE
FOLDERS=(MxNoteONE MxDataSQL Shared)

git -C "$SRC" rev-parse --git-dir >/dev/null
if [[ -n $(git -C "$SRC" status --porcelain -- $FOLDERS) ]]; then
  echo "note: MXcodeIDE has uncommitted changes in these folders; they're left out" >&2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$SRC" archive --format=tar HEAD -- $FOLDERS | tar -x -C "$tmp"

mkdir -p "$DEST"
for folder in $FOLDERS; do
  # A link left from before is replaced by the folder.
  [[ -L $DEST/$folder ]] && rm "$DEST/$folder"
  rsync -a --delete --delete-excluded \
    --exclude .DS_Store --exclude xcuserdata/ --exclude '*.xcuserstate' --exclude build/ --exclude DerivedData/ \
    "$tmp/$folder/" "$DEST/$folder/"
done

echo "MxAppsIDE now matches MXcodeIDE $(git -C "$SRC" rev-parse --short HEAD) ($FOLDERS)"
