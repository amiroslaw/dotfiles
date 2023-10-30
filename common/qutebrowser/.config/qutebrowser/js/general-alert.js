// click the alert, annotation, comment button

var url = document.location.hostname;

if(url.includes("pepper")) {
	document.getElementById("popover2").click();
} else if(url.includes("youtube")) {
	document.querySelector('ytd-notification-topbar-button-renderer button').click();
} else if(url.includes("4programmers")) {
	document.querySelector('#nav-auth a:first-child').click();
} else {
	alert('url pattern not found');
}

