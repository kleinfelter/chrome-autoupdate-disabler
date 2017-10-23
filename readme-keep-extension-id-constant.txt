Because I'm using a helper app with native messaging, I have to specifically authorize
an extension to use the helper.  To specify the extension, I have to use the 32-character
extension ID.  But... during development, each time I load an unpacked extension, a new
ID is generated.  (After you upload an extension to the chrome store, it acquires a
fixed ID which never changes.)

In order to prepare the manifest for the helper, and specify the extension ID, I
need a fixed ID for my extension.  You need a .pem file to make that happen.

This has the details on getting a fixed ID: https://stackoverflow.com/questions/23873623/obtaining-chrome-extension-id-for-development
This has more background: https://stackoverflow.com/questions/21497781/how-to-change-chrome-packaged-app-id-or-why-do-we-need-key-field-in-the-manifest

Here is how I generated my fixed ID.

* Enable developer mode on the Chrome extensions page.
* Load your extension an an unpacked extension, once.
* Press "Pack Extension"
* Pack your extension
* It will create a .crx and a .pem.
* I renamed that .pem as extension.pem

Your .pem is not the same as your key, although it appears that your key is based on your .pem.  To view your key and your ID:
Load your generated .crx with either:
* The "Chrome extension source viewer" extension (the one by Rob W).
* or https://robwu.nl/crxviewer/
* In either case, you must open the Chrome Developer Tools Console, to view the key and the ID.

Fixing your key+ID:
* Copy the key entry (which you got by following the instructions above to view them).
* Paste it into your manifest.json.  I pasted it after the homepage_url entry.
* After you've done this, go back to Chrome and delete the old edition of your extension.  The ID has changed.
* You should now be able to load-unpacked the extenion multiple times (with the key in the manifest), without the ID changing.


When ready to submit your app/extension to the Chrome Web Store:

* Create a zip file containing your extension (manifest.json must be at the root, i.e. "directory/manifest.json" is bad, "manifest.json" is good).
* Include the .pem file in the zip file as key.pem (this preserves the extension ID)
* Upload the extension to the Chrome Web Store (without the "key" field in manifest.json. The upload will reject any manifest which contains a "key" field).
