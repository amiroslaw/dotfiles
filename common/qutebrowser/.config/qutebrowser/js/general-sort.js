// click the sort button

var url = document.location.hostname;

if (url.includes("youtube")) {
  let sortButton = getHtmlElement(
    '[aria-label="Sort by"]',
    '[aria-label="Sortuj według"]'
  );
  sortButton.click();
  setTimeout(() => {
    document.querySelector('a[href*="&sort=p"]').click();
    // watchLaterList.click();
  }, 1000);
} else if (url.includes("duckduckgo")) {
  // open dropdown with date
  let dropdownDate = document.querySelector(".dropdown--date .dropdown__button").click();
} else if (url.includes("deezer")) {
} else {
  alert("url pattern not found");
}

// let playlistButton = getHtmlElement( "[aria-label=\'\']","[aria-label=\'\']");
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
