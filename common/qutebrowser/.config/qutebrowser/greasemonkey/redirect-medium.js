// ==UserScript==
// @name        Freedium
// @description	redirect Medium to Freedium
// @version		1.0
// @match       *://*.medium.com/*
// @run-at      document-start
// @grant       none
// ==/UserScript==

var freedium  = window.location.protocol + "//freedium.cfd/" + window.location.href
window.location.replace (freedium);
