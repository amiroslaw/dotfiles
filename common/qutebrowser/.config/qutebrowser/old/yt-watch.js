// ==UserScript==
// @name         YT tweaks 
// @namespace    http://tampermonkey.net/
// @version      1.0
// @author       Hulio
// @match        *://*.youtube.com/watch?*
// @grant        none
// ==/UserScript==

// expand description
setTimeout(() => {  
	// click on this element doesn't work 
	if(document.querySelector('tp-yt-paper-button#more')!== undefined) {
		document.querySelector('tp-yt-paper-button#more').click();
	}
}, 3000);

