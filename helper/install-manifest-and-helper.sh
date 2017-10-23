#!/bin/bash
echo "beginning install-manifest-and-helper.sh..."
MANIFEST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/"
HOST_NAME=com.kleinfelter.autoupdate_disabler
BIN_DIR="$HOME/.$HOST_NAME"

if [ ! -d "$MANIFEST_DIR" ] ; then
    echo "Unable to find Chrome directory."
    echo "On Mac OS X, this is expected to be: $MANIFEST_DIR"
    echo "Quitting."
    exit -1
fi

mkdir -p "$BIN_DIR"
cp "$HOST_NAME.json" "$MANIFEST_DIR"
chmod o+r "$MANIFEST_DIR/$HOST_NAME.json"
cp helper.py "$BIN_DIR/"

# Update host path in the manifest
HOST_PATH="$BIN_DIR/helper.py"
ESCAPED_HOST_PATH=${HOST_PATH////\\/}
sed -i '' -e "s/PATH_TOKEN/$ESCAPED_HOST_PATH/" "$MANIFEST_DIR/$HOST_NAME.json"

chmod ugo+x "$HOST_PATH"

echo " "
echo "$HOST_NAME.json has been installed to $MANIFEST_DIR"
echo "$HOST_NAME has been installed to $BIN_DIR"
