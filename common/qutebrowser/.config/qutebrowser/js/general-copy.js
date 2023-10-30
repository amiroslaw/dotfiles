// click copy text, url button
var url = document.location.hostname;

if (url.includes("youtube")) {
  // twice to close list
  let playlistButton = getHtmlElement( '#info [aria-label="Share"]', '#info [aria-label="Udostępnij"]');
  playlistButton.click();
  setTimeout(() => {
    getHtmlElement('[aria-label="Copy"]', '[aria-label="Kopiuj"]').click();
    let copyButton = document.querySelector('[icon="close"]');
    copyButton.click();
  }, 1000);
} else {
  alert("url pattern not found");
}

function getHtmlElement(englishQuery, otherQuery) {
  let element = document.querySelector(englishQuery);
  if (element == null) {
    element = document.querySelector(otherQuery);
  }
  if (element == null) {
    console.log("html element not found");
  }

  return element;
}
