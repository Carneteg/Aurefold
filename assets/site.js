/* AUREFOLD — shared page behaviour: expandable house cards and the optional chart plate. */
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

  // Character portraits (characters.html): try the named file, then the
  // optional data-fallback source, else hide the slot.
  document.querySelectorAll(".face-portrait").forEach((img) => {
    const fail = () => {
      const fb = img.dataset.fallback;
      if (fb && !img.src.endsWith(fb)) img.src = fb;
      else img.hidden = true;
    };
    img.addEventListener("error", fail);
    if (img.complete && img.naturalWidth === 0) fail();
  });

  // Front-page Patreon call-to-action (config-driven; stays hidden if unset).
  var patreonUrl = ((window.AUREFOLD_COMMUNITY || {}).support || {}).patreon;
  var frontPatreon = document.getElementById("front-patreon");
  if (frontPatreon && patreonUrl && patreonUrl.trim()) {
    frontPatreon.href = patreonUrl.trim();
    frontPatreon.hidden = false;
  }

  // Reading-list signup (MailerLite). The form stays hidden and posts nowhere
  // until BOTH ids are configured in data/community.js; then it points at the
  // MailerLite subscribe endpoint. No list, sending, or automation is implied
  // by this markup alone.
  var ml = (window.AUREFOLD_COMMUNITY || {}).mailerlite || {};
  var signupForm = document.getElementById("signup-form");
  var signupSoon = document.getElementById("signup-soon");
  if (signupForm && ml.account && ml.form && String(ml.account).trim() && String(ml.form).trim()) {
    signupForm.action =
      "https://assets.mailerlite.com/jsonp/" + String(ml.account).trim() +
      "/forms/" + String(ml.form).trim() + "/subscribe";
    signupForm.hidden = false;
    if (signupSoon) signupSoon.hidden = true;
  }

  // Show Plate I on the front page only if the chart image exists.
  const plateImg = document.getElementById("chart-plate-img");
  if (plateImg) {
    const plate = document.getElementById("chart-plate");
    if (plateImg.complete && plateImg.naturalWidth > 0) plate.hidden = false;
    else plateImg.addEventListener("load", () => { plate.hidden = false; });
  }
})();
