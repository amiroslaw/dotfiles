var i, elements = document.querySelectorAll("body *");
for (i = 0; i < elements.length; i++) {
  var pos = getComputedStyle(elements[i]).position;
  if (pos === "fixed" || pos == "sticky") {
    elements[i].parentNode.removeChild(elements[i]);
  }
}
