// click the delete button
var url = document.location.hostname;

if(url.includes("mail.google")) {
	console.log('gmail');
	// do not show notification popup
	let button = document.querySelector('[aria-label=Usuń]');
	button.click();
} else {
	alert('None action for this page');
}



