// The pages that should be home page.
var url = document.location.hostname;
if(url.includes("pepper")) {
	location.href = "https://www.pepper.pl/profile/hulio/keyword-alarms"
} else if(url.includes("youtube")) {
	location.href = "https://www.youtube.com/feed/subscriptions"
} else if(url.includes("4programmers")) {
	location.href = "https://4programmers.net/User/Notifications"
} else {
	alert('url pattern not found');
}

// location.href =
