var url = document.location.hostname;

if(url.includes("pepper")) {
	document.getElementById("popover2").click();
} else if(url.includes("youtube")) {
	document.querySelector('ytd-notification-topbar-button-renderer button').click();
} else {
	alert('url pattern not found');
}

