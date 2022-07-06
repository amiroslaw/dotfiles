var url = document.location.hostname;

if(url.includes("youtube")) {
	let playlistButton = getHtmlElement('[aria-label="Zapisz na playliście"]','[aria-label="Save to playlist"]');
	playlistButton.click();
	setTimeout(() => {  
		// let checkedCheckbox = document.querySelector("#playlist #checkboxContainer #checkbox.checked");
		let checkedCheckbox = document.querySelector("#checkbox.checked").click();
		checkedCheckbox.click();
		let copyButton = document.querySelector('[icon="close"]');
		copyButton.click();
	}, 1000);
	
} else {
	alert('url pattern not found');
}

function getHtmlElement(englishQuery, otherQuery){
	let element = document.querySelector(englishQuery);
	if(element == null) {
		element = document.querySelector(otherQuery);
	}
	if(element == null) {
		console.log('html element not found')
	}
	 
	return element;
}
