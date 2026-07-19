/* AUREFOLD — shared page behaviour: expandable house cards and the optional chart plate. */
(function () {
  "use strict";

  // Mobile navigation toggle (hamburger).
  var nav = document.querySelector(".site-nav");
  var navToggle = nav && nav.querySelector(".nav-toggle");
  if (nav && navToggle) {
    navToggle.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      navToggle.setAttribute("aria-expanded", String(open));
      navToggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    });
    // Close when a menu link is tapped.
    nav.querySelectorAll("#nav-menu a").forEach(function (a) {
      a.addEventListener("click", function () { nav.classList.remove("open"); navToggle.setAttribute("aria-expanded", "false"); });
    });
  }

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

  // Copy-link share buttons (any [data-copy] element).
  document.querySelectorAll("[data-copy]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var url = btn.getAttribute("data-copy");
      var label = btn.textContent;
      var done = function () { btn.textContent = "Copied!"; setTimeout(function () { btn.textContent = label; }, 1800); };
      if (navigator.clipboard) navigator.clipboard.writeText(url).then(done, done); else done();
    });
  });

  // Read page: reveal the sticky "keep reading" bar once past the intro.
  var sticky = document.getElementById("read-sticky");
  if (sticky) {
    var onScroll = function () {
      var y = window.pageYOffset || document.documentElement.scrollTop;
      var nearBottom = (y + window.innerHeight) > (document.body.scrollHeight - 260);
      if (y > 500 && !nearBottom) sticky.classList.add("show");
      else sticky.classList.remove("show");
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  }

  // Privacy-friendly analytics (Plausible). Loads ONLY when a domain is
  // configured in data/community.js; otherwise nothing external is requested.
  // No cookies, no personal data. Also tracks a few key conversion events
  // without any per-element markup.
  var an = (window.AUREFOLD_COMMUNITY || {}).analytics || {};
  if (an.plausibleDomain && String(an.plausibleDomain).trim()) {
    var ps = document.createElement("script");
    ps.defer = true;
    ps.setAttribute("data-domain", String(an.plausibleDomain).trim());
    ps.src = "https://plausible.io/js/script.outbound-links.js";
    document.head.appendChild(ps);
    window.plausible = window.plausible || function () {
      (window.plausible.q = window.plausible.q || []).push(arguments);
    };
    document.addEventListener("click", function (e) {
      var a = e.target.closest && e.target.closest("a");
      if (!a) return;
      var href = a.getAttribute("href") || "";
      if (/patreon\.com/i.test(href)) window.plausible("Patreon click");
      else if (/support\.html/i.test(href)) window.plausible("Support click");
      else if (/read\.html/i.test(href)) window.plausible("Read click");
    });
  }

  // Show Plate I on the front page only if the chart image exists.
  const plateImg = document.getElementById("chart-plate-img");
  if (plateImg) {
    const plate = document.getElementById("chart-plate");
    if (plateImg.complete && plateImg.naturalWidth > 0) plate.hidden = false;
    else plateImg.addEventListener("load", () => { plate.hidden = false; });
  }
})();
