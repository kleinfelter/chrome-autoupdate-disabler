/**
 * (c) 2017 Kevin Kleinfelter <chrome-extensions@kleinfelter.com>
 */
'use strict';
//var HELPER_NAME = "com.google.chrome.example.echo";
var HELPER_NAME = "com.kleinfelter.autoupdate_disabler";

var status_span;
var plugin_found_span;

// There are two ways to send messages to a helper app
// - one is to open a connection and send and receive multiple messages
// - one is to open/send/close for each message.
// I'm using the latter because I don't need an extended dialog.

function response_from_helper (response) {
  if (response) {
    plugin_found_span.innerHTML = "installed";
    document.getElementById("helper-instructions").style.color="black";
  } else {
    plugin_found_span.innerHTML = ("<b>missing or failing<b>");
    document.getElementById("helper-instructions").style.color="blue";
    return;
  }

  if(response.hasOwnProperty('ok')){
    // I used to have the reload in the code for enableAutoUpdate or disableAutoUpdate.
    // But that intermittently caused the request to fail, because the reload refreshed
    // the javascript before the response came back.  It actually started the helper,
    // but it closed the connection before the helper could read any bytes.
    // Be sure NOT to call reload on the response to 'status', because when the main
    // JavaScript body loads, *it* issues a 'status', and that creates an infinite loop.
    location.reload();
  } else if (response.hasOwnProperty('list_all')) {
    var t = response.list_all;
    populate_extension_list(t)
  } else if (response.hasOwnProperty('status_all')) {
    var t = response.status_all;
    if (t == "disabled") {
      status_span.textContent = "disabled for all";
    } else if (t == "enabled") {
      status_span.textContent = "enabled for all";
    } else {
      status_span.textContent = "some enabled and some disabled";
    }
  } else {
    alert ("request failed")
  }

  if (chrome.runtime.lastError) {
    alert ("There was an error, it was:" + chrome.runtime.lastError.message);
  }

 }


 function populate_extension_list(js) {
     var ul;
     var li;


     js.forEach(function(item, index, array) {
       console.log(item[0], item[1], index);
     });

     ul = document.getElementById("extensionList");

     while (ul.firstChild) {
       ul.removeChild(ul.firstChild);
     }

     js.forEach(function(item, index, array) {
       li = document.createElement("li");
       li.appendChild(document.createTextNode(item[0] + " (" + item[1] + ")"));
       ul.appendChild(li);
     });
}


function send_to_helper (cmd, arg) {
  chrome.extension.sendNativeMessage(
    HELPER_NAME,
    {[cmd] : arg},
    response_from_helper);
}

function enableAutoUpdate() {
  send_to_helper ("enable", "ALL");
  // Cannot call location.reload here.  If you reload the page before the response is received, it messes things up.
}

function disableAutoUpdate() {
  send_to_helper ("disable", "ALL");
  // Cannot call location.reload here.  If you reload the page before the response is received, it messes things up.
}

function getExtensionList() {
  send_to_helper ("list", "ALL");
}

document.getElementById("pbDisableAutoUpdate").addEventListener("click", disableAutoUpdate);
document.getElementById("pbEnableAutoUpdate").addEventListener("click", enableAutoUpdate);
document.getElementById("pbListExtensions").addEventListener("click", getExtensionList);

status_span = document.getElementById("update-status");
status_span.textContent = "awaiting helper";

plugin_found_span = document.getElementById("plugin-found");
plugin_found_span.textContent = "awaiting helper";

send_to_helper ("status", "ALL");
