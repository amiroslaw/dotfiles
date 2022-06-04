// ==UserScript==
// @name         YT tweaks 
// @namespace    http://tampermonkey.net/
// @version      1.0
// @author       Hulio
// @match        *://*.youtube.com/*
// @grant        none
// ==/UserScript==

// expand playlist
setTimeout(() => {  
	document.getElementById('expander-item').click();
}, 3000);

// MutationObserver maybe change to it
// let mList = document.getElementById('items'),
// options = {
//   childList: true
// },
// observer = new MutationObserver(mCallback);
//
// function mCallback(mutations) {
//   for (let mutation of mutations) {
//     if (mutation.type === 'childList') {
//       alert('Mutation Detected: A child node has been added or removed.');
//     }
//   }
// }
//
// observer.observe(mList, options);
