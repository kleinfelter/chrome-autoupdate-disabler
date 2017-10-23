#!/usr/bin/env python
from shutil   import move
from tempfile import NamedTemporaryFile
from glob import glob
from os.path import expanduser
from time import sleep
import os
import platform
import time
import sys
import struct
import json
import re

debug_enabled = False

#   "update_url": "http://clients2.google.com/service/update2/crx",

# Need to ensure that the replacement label does not contain the original label, or else
# there's a risk of accidentally recursively modifying.  e.g. prefix_prefix_prefix_update_url
ALT_URL_LABEL = "\"no_update_xxx\""
UPDATE_URL_LABEL = "\"update_url\""
MY_LOCALHOST = '"https://127.0.0.1/bogus"'


DARWIN_MANIFESTS  = "~/Library/Application Support/Google/Chrome/Default/Extensions/*/*/manifest.json"
WIN7_MANIFESTS    = os.environ.get('LOCALAPPDATA', "C:\\Temp")                                     + "\\Google\\Chrome\\User Data\\Default\\Extensions\\*\\*\\manifest.json"
WINXP_MANIFESTS   = os.environ.get('USERPROFILE', "C:\\Temp")    + "\\Local Settings\\Application Data\\Google\\Chrome\\User Data\\Default\\Extensions\\*\\*\\manifest.json"
LINUX_MANIFESTS   = "~/config/google-chrome/Default/Extensions/*/*/manifest.json"


def debug_print(s):
    if (debug_enabled):
        sys.stderr.write("KPKDEBUG " + s + "\n")
        sys.stderr.flush()


# Google doc says
#    Every few hours, the browser checks whether any installed extensions or apps have an update URL. For each one, it makes a request to that URL
# Taken at their word, this means that if there is no update_url, it won't update.
# If it turns out that they supply a default in the absence of update_url, I'll need to:
#   1. change update_url to no_update_xxx
#   2. AND supply an update_url for localhost
# and of course I'll have to un-do all that when in ENABLE autoupdate

def able_update (filename, oldval, newval):
    need_to_insert = False

    # First check to see if the key is in the file.  If not, we'll need to supply one.
    # Otherwise, we'll always get mixed plugin update status.
    with open(filename, 'r') as myfile:
        s = myfile.read()  # Slurps the whole file.
        need_to_insert = not ((oldval in s) or (newval in s))  # Checks all lines in the file because it is read as one big string.

    with NamedTemporaryFile(mode='w+t',delete=False) as tmp_out:
        with open(filename) as source_file:
            for line in source_file:
                if (need_to_insert) and ('"version":' in line):
                    tmp_out.write(oldval + ': "https://clients2.google.com/service/update2/crx",\n')
                if oldval in line:
                    line = line.replace(oldval, newval)
                tmp_out.write(line)

    move(tmp_out.name, source_file.name)

# Add a line to the manifest to point the update server to localhost.
def add_localhost (filename):
    need_to_insert = True

    # First check to see if the key is in the file.  If not, we'll need to supply one.
    # Otherwise, we'll always get mixed plugin update status.
    with open(filename, 'r') as myfile:
        for line in myfile:
            if ('"update_url":' in line) and (MY_LOCALHOST in line):
                need_to_insert = False

    with NamedTemporaryFile(mode='w+t',delete=False) as tmp_out:
        with open(filename) as source_file:
            for line in source_file:
                if (need_to_insert) and ('"version":' in line):
                    tmp_out.write('   "update_url": ' + MY_LOCALHOST + ',\n')
                tmp_out.write(line)

    move(tmp_out.name, source_file.name)



# If there is a line in the manifest pointing the update server to localhost, remove it.
def del_localhost (filename):
    with NamedTemporaryFile(mode='w+t',delete=False) as tmp_out:
        with open(filename) as source_file:
            for line in source_file:
                if ('"update_url":' in line) and (MY_LOCALHOST in line):
                    pass # write nothing
                else:
                    tmp_out.write(line)

    move(tmp_out.name, source_file.name)



def disable_update (filename):
    disabled = False
    with open(filename, 'r') as myfile:
        s = myfile.read()  # Slurps the whole file.
        if (ALT_URL_LABEL in s):
            disabled = True

    debug_print("Got to disable_update_1")
    if not disabled:
        debug_print("Got here2")
        able_update(filename, UPDATE_URL_LABEL, ALT_URL_LABEL)
        debug_print("Got here3")
        add_localhost(filename)
        debug_print("Got here4")

def enable_update (filename):
    del_localhost(filename)
    able_update(filename, ALT_URL_LABEL, UPDATE_URL_LABEL)


def get_manifest_path (sysname):
    if sysname == "Darwin":
        return DARWIN_MANIFESTS
    elif sysname == "Linux":
        return LINUX_MANIFESTS
    elif sysname == "Windows":
        if platform.release() == "XP":
            return WINXP_MANIFESTS
        else:
            return WIN7_MANIFESTS
    else:
        raise Exception('Unknown operating system:' + sysname)


def update_all_manifests(f):
    manifests = get_manifest_path (platform.system())
    for p in glob(expanduser(manifests)):
        f(p)


def check_all_manifests(label):
    all_match = True

    manifests = get_manifest_path (platform.system())
    for p in glob(expanduser(manifests)):
        with open(p, 'r') as myfile:
            s = myfile.read()
            if label in s:
                pass # nothing
            else:
                all_match = False
    return all_match


def read_request():
    text_length_bytes = sys.stdin.read(4)

    if len(text_length_bytes) == 0:
        debug_print("Got zero bytes on a read.  This means that the client got interrupted before the message was sent")
        sys.exit(0)

    text_length = struct.unpack('i', text_length_bytes)[0]
    text = sys.stdin.read(text_length).decode('utf-8')
    json_data = json.loads(text)

    # assumes that all requests look like: {cmd : arg}
    cmd = next(iter(json_data))
    arg = json_data[cmd]
    debug_print("raw data read:" + text)
    return [cmd, arg]


def send_response (resp, arg):
    message = '{"' + resp + '":' +  '"' + str(arg) + '"}'
    debug_print("RESPONSE:" + message)
    sys.stdout.write(struct.pack('I', len(message)))
    sys.stdout.write(message)
    sys.stdout.flush()

def send_response_json (resp, arg):
    message = '{"' + resp + '":'  + str(arg) + '}'
    debug_print("RESPONSE:" + message)
    sys.stdout.write(struct.pack('I', len(message)))
    sys.stdout.write(message)
    sys.stdout.flush()


def all_are_enabled():
    tmp = check_all_manifests (UPDATE_URL_LABEL)
    return tmp


def all_are_disabled():
    tmp = check_all_manifests (ALT_URL_LABEL)
    return tmp


def send_status_all():
    if all_are_disabled():
        send_response("status_all", "disabled")
    elif all_are_enabled():
        send_response("status_all", "enabled")
    else:
        send_response("status_all", "mixed")

def localized_name(a_name, p):

    msgs_path = ''

    if (os.path.isfile(p + "_locales/en/messages.json")):
        msgs_path = p + "_locales/en/messages.json"
    elif (os.path.isfile(p + "_locales/en_US/messages.json")):
        msgs_path = p + "_locales/en_US/messages.json"
    elif (os.path.isfile(p + "_locales/en_GB/messages.json")):
        msgs_path = p + "_locales/en_GB/messages.json"
    else:
        return "Unknown Extension"

    a_name2 = re.sub('^__MSG_', '', a_name)
    a_name3 = re.sub('__$', '', a_name2)

    with open(msgs_path, 'r') as myfile:
        s = myfile.read()
        x = json.loads(s)
        try:
            a = x[a_name3]['message']
        except:
            # Chrome Web Store Payments has this problem.  I think it can get away with it because it is
            # hidden from the user, so no one tries to get the localized name.
            try:
                a = x[a_name3.lower()]['message']
            except:
                a = "Extension With Localization Problem"
    return a

def send_list_all():
    manifests = get_manifest_path (platform.system())
    app_name = []
    app_version = []

    for p in glob(expanduser(manifests)):
        debug_print("check path:" + p)
        with open(p, 'r') as myfile:
            s = myfile.read()
            x = json.loads(s)
            a_name = x['name']
            a_version = x['version']

            if (a_name.startswith("__MSG_")):
                a_name = localized_name(a_name, re.sub('manifest\.json$', '', p))
            debug_print("name is:" + a_name)
            debug_print("version:" + a_version)
            app_name.append(a_name)
            app_version.append(a_version)
    s = []
    for i in range(len(app_name)):
        #s.append({app_name[i]: app_version[i]})
        s.append([app_name[i], app_version[i]])
    js = json.dumps(s)
    debug_print("RAW\n" + str(s))
    debug_print("SENDING\n" + js)
    send_response_json ("list_all", js)



if sys.platform == "win32":
    import msvcrt
    msvcrt.setmode(sys.stdin.fileno(), os.O_BINARY)
    msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)

    # The Google Chrome Native Messaging doc says that stderr will get sent to the Chrome log,
    # and to run chrome with "chrome --enable-logging --v=1".  I did that.  It did send the Chrome log
    # there, but it didn't send the Python stderr to there.  So I'm taking control.

    # >>> Anything printed to stderr before this point in the code is LOST.
    if (debug_enabled):
        sys.stderr = open('C:\\chrome-debug.txt', 'a')

debug_print("helper loaded")

#disable_update("testfile.txt")
#enable_update("testfile.txt")
#update_all_manifests(disable_update)
cmd, arg = read_request()

debug_print("read command: " + cmd)

if cmd == "disable":
    if arg == "ALL":
        update_all_manifests(disable_update)
        send_response ("ok", "ALL")
    else:
        sys.stderr.write("unexpected arg to disable:" + arg)
        send_response ("error", "unexpected arg to disable")
elif cmd == "enable":
    if arg == "ALL":
        update_all_manifests(enable_update)
        send_response ("ok", "ALL")
    else:
        sys.stderr.write("unexpected arg to enable:" + arg)
        send_response ("error", "unexpected arg to enable")
elif cmd == "status":
    if arg == "ALL":
        send_status_all()
    else:
        sys.stderr.write("unexpected arg to status:" + arg)
        send_response ("error", "unexpected arg to status")
elif cmd == "list":
    if arg == "ALL":
        send_list_all()
    else:
        sys.stderr.write("unexpected arg to list:" + arg)
        send_response ("error", "unexpected arg to list")
else:
    sys.stderr.write("unexpected command:" + cmd)
    send_response ("error", "unexpected cmd" + cmd)
