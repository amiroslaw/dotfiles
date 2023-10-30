// click the filter button
var url = document.location.hostname;

if(url.includes("duckduckgo")) {
	// toggle local region 
	document.querySelector('.dropdown__switch').click()
} else {
	alert('filter - url pattern not found');
}



