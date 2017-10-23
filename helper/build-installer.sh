#!/bin/bash
# Build the Mac setup.  (Not *run* the setup.  *Build* the setup.)
# Run this from the main 'helper' development directory.

SETUPDIR="/tmp/helper-mac-installer/"

rm -rf "$SETUPDIR"
mkdir "$SETUPDIR"
cp helper.py uninstaller.sh com.kleinfelter.autoupdate_disabler.json install-manifest-and-helper.sh "$SETUPDIR"
echo "calling makeself"
makeself --complevel 9 --license license "$SETUPDIR" installer.sh "Chrome Extension Auto-update Disabler Helper App" ./install-manifest-and-helper.sh
