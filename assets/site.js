/* EMBERWOLD — shared page behaviour: expandable house cards and the optional chart plate. */
(function () {
  "use strict";

  // Expandable house cards (houses.html).
  document.querySelectorAll(".house-card").forEach((card) => {
    const toggle = card.querySelector(".house-toggle");
    if (!toggle) return;
    toggle.addEventListener("click", () => {
      const open = card.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
    });
  });

  // Deep link: houses.html#<house-id> opens that card.
  if (location.hash) {
    const card = document.querySelector(`.house-card${location.hash}`);
    if (card) {
      card.classList.add("open");
      const toggle = card.querySelector(".house-toggle");
      if (toggle) toggle.setAttribute("aria-expanded", "true");
      card.scrollIntoView({ block: "center" });
    }
  }

  // Show Plate I on the front page only if the chart image exists.
  const plateImg = document.getElementById("chart-plate-img");
  if (plateImg) {
    const plate = document.getElementById("chart-plate");
    if (plateImg.complete && plateImg.naturalWidth > 0) plate.hidden = false;
    else plateImg.addEventListener("load", () => { plate.hidden = false; });
  }
})();
