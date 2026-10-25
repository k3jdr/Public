#!/bin/zsh
# Copies the apps published here from MxAppsIOS: what's committed there (not work in progress), as real folders —
# git keeps a symbolic link as just its target's path, so a link to MxAppsIOS would show up on GitHub as one line.
#
#   MxAppsIDE/sync-from-MxAppsIOS.sh    then commit and push as usual
#   MXAPPSIOS=/path/to/MxAppsIOS MxAppsIDE/sync-from-MxAppsIOS.sh
set -euo pipefail

SRC=${MXAPPSIOS:-$HOME/MyCodeGIT/MxAppsIOS}
# This folder: the apps' Xcode projects find Shared beside them, as in MxAppsIOS.
DEST=${0:A:h}
FOLDERS=(MxNoteONE MxDataSQL MxDataHUB MxFileMGR MxJobsMGR MxAcctMGR Shared)

git -C "$SRC" rev-parse --git-dir >/dev/null
if [[ -n $(git -C "$SRC" status --porcelain -- $FOLDERS) ]]; then
  echo "note: MxAppsIOS has uncommitted changes in these folders; they're left out" >&2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$SRC" archive --format=tar HEAD -- $FOLDERS | tar -x -C "$tmp"

for folder in $FOLDERS; do
  # A link left from before is replaced by the folder.
  [[ -L $DEST/$folder ]] && rm "$DEST/$folder"
  rsync -a --delete --delete-excluded \
    --exclude .DS_Store --exclude xcuserdata/ --exclude '*.xcuserstate' --exclude build/ --exclude DerivedData/ \
    "$tmp/$folder/" "$DEST/$folder/"
done

echo "MxAppsIDE now matches MxAppsIOS $(git -C "$SRC" rev-parse --short HEAD) ($FOLDERS)"
