This directory contains code that uses native
messaging API that allows to communicate with a native application.

In order for this example to work you must first install the native messaging
host from the host directory.

To run:
  One way is to open the apps page (chrome://apps) and launch it from there.
  Another way, since it has ID knldjmfmopnpolahpmmgbagdohdnhkik  is to launch chrome-extension://knldjmfmopnpolahpmmgbagdohdnhkik/main.html


See hints at https://stackoverflow.com/questions/33041396/chrome-native-messaging-api-chrome-runtime-connectnative-is-not-a-function

To DEBUG:
* When the helper writes to stderr, output is written to the error log of Chrome. On Linux and OS X, this log can easily be accessed by starting Chrome from the command line and watching its output in the terminal.
  * /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
* For Windows, use --enable-logging per https://www.chromium.org/for-testers/enable-logging

================================

For delivering *my* extension:

* For Mac:
    * User installs extension from Chrome Web Store
    * Using http://makeself.io/ 
        * Install manifest.json to ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.kleinfelter.something-or-other (matching hostname used in extension)
        * Install helper.py to ~/bin matching location specified in manifest
    * To rebuild the installer:
        * Run build-installer.sh
        * This creates installer.sh, and that's what you distribute for Mac.
    * To ship/deliver the installer:
        * Copy it to ~/Sync/Sites/kleinfelter.github.io/_downloads/chrome-extension-autoupdate-disabler
	* cd to kleinfelter.github.io
	* git add _downloads/chrome-extension-autoupdate-disabler/installer.sh
	* git commit -m updated
	* git push

* For Windows [I build in my Win XP VM]:
    * User installs extension from Chrome Web Store
    * I need to build the helper.exe
    * Using http://www.innosetup.com/isinfo.php
        * Install manifest.json to anywhere
        * Install helper.exe to location referenced by manifest
        * Update registry to point to manifest.json
    * To rebuild the helper .exe:
	* see readme-to-build-exe.txt
    * To rebuild the setup.exe:
        * Open the .iss file with InnoSetup (Right-click, open with Inno Setup)
        * Ensure "LicenseFile" entry is up to date.  Ditto for the "Source:" lines.
        * Menu: Build >> Compile
        * Builds autoupdate_disabler_0.0.x/Output/setup.exe


* To publish the extension:
    * Choose a limited distribution model.
        * This might be better: https://stackoverflow.com/questions/25949544/get-link-to-published-chrome-extension-page-before-publish
        * See https://developer.chrome.com/webstore/publish#testaccounts
    * Zip the folder containing it.
    * https://chrome.google.com/webstore/developer/dashboard
    * Add new item
    * Upload the zip file
    * Enter details
    * Press Publish
    * Test with your limited distribution.
        * final webstore link will be https://chrome.google.com/webstore/detail/[yourExtensionIdHere]
    * Update the distribution to support everyone.  (May have to unpublish/republish.)


=========

Installing makeself:
brew install makeself
makeself --version


=========

Uploading to Chrome Web Store:

* Copy manifest.json to manifest.json-original
* in manifest.json:
    * Remove all comments
    * Remove the "key" line
* Ensure that key.pem is contained the same folder which contains your extension *folder*.
* Right-click on the extension folder and select "Compress", to create extension.zip.
* Rename archive.zip to extension.zip
* Browse to https://chrome.google.com/webstore/developer/dashboard and login as kevin@kleinfelter.com.
* Press "Add New Item" (unless you're updating an old item)
* Press "choose file"
* CHoose extension.zip
* Press "Upload"