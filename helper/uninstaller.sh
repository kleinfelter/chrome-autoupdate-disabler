#!/bin/bash
MANIFEST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"
HOST_NAME=com.kleinfelter.autoupdate_disabler
BIN_DIR="$HOME/.$HOST_NAME"

rm -r "$BIN_DIR"
rm "$MANIFEST_DIR/$HOST_NAME.json"

echo "Uninstalled."
