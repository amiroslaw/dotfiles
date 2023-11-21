// ==UserScript==
// @name        Good o'l Reddit
// @description	Makes sure you're using Good o'l Reddit. (C) TheNH813 2018. License WTFPLV2
// @version		1.0
// @match       *://*.reddit.com/*
// @run-at      document-start
// @grant       none
// ==/UserScript==

if ( window.location.host != "old.reddit.com" ) {
    var oldReddit  = window.location.protocol + "//" + "old.reddit.com" + window.location.pathname + window.location.search + window.location.hash;
    window.location.replace (oldReddit);
}
