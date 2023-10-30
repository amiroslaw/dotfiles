 // save or add to a list or favorites, if it is possible it will toggle element in the list
var url = document.location.hostname;

if(url.includes("youtube")) {
	let playlistButton = getHtmlElement('[aria-label="Zapisz na playliście"]','[aria-label="Save to playlist"]');
	playlistButton.click();
	setTimeout(() => {  
		let watchLaterList = getHtmlElement( "ytd-playlist-add-to-option-renderer [title=\'Watch later\']","ytd-playlist-add-to-option-renderer [title=\'Do obejrzenia\']");
		watchLaterList.click();
		document.querySelector('[icon="close"]').click();
	}, 1000);
	
} else if(url.includes("piped")) {
	let favoriteButton = document.querySelector('.modal-container > button');
	console.log(favoriteButton)
	favoriteButton.click();
} else if(url.includes("pepper")) {
	let bookmark = document.querySelector('[data-t=addBookmark]');
	if(bookmark == null) {
		bookmark = document.querySelector('[data-t=removeBookmark]');
	}
	bookmark.click();
} else if(url.includes("mail.google")) {
	let archive = document.querySelector('[aria-label=Archiwizuj]');
	archive.click();
} else if(url.includes("deezer")) {
	let favoriteButton = getHtmlElement("#page_player [aria-label=\'Add to Favorite tracks\']", "#page_player [aria-label=\'Dodaj do ♡\']");
	if(favoriteButton == null) {
		favoriteButton = getHtmlElement("#page_player [aria-label=\'Remove from Favorite tracks\']", "#page_player [aria-label=\'Usuń z Ulubionych utworów\']");
	}
	favoriteButton.click();

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
