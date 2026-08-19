/* AUREFOLD — community growth integration
   NON-CANON product layer.

   This file connects the existing House Test and Banner modules into the
   approved community funnel without replacing either experience:

     House Test -> share / Moot -> Banner -> free Patreon

   House distribution deliberately reuses the site's existing anonymous
   votes/poll_tallies infrastructure. Raw vote rows remain private; only
   aggregate tallies are public. Distribution is hidden until >=20 real
   completions so tiny samples never masquerade as fandom consensus.
*/
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var SYSTEM_POLL = "system-house-test-v2";
  var HOUSES = [
    "blackthorn", "ashbourne", "whitehart", "stormrider", "ravenshade",
    "ironvale", "blackcrest", "stonebear", "tidebreaker", "phoenix"
  ];

  function validHouse(key) {
    return HOUSES.indexOf(String(key || "").toLowerCase()) !== -1;
  }

  function labelFor(key) {
    return String(key || "").charAt(0).toUpperCase() + String(key || "").slice(1);
  }

  function voterId() {
    // Reuse the same anonymous browser id as The Moot rather than creating a
    // parallel tracker. It has no meaning outside anonymous one-vote limits.
    var storageKey = "ew-voter";
    var id;
    try { id = localStorage.getItem(storageKey); } catch (e) {}
    if (id) return id;

    if (window.crypto && typeof window.crypto.randomUUID === "function") {
      id = window.crypto.randomUUID();
    } else {
      id = "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, function () {
        return Math.floor(Math.random() * 16).toString(16);
      });
    }
    try { localStorage.setItem(storageKey, id); } catch (e2) {}
    return id;
  }

  function headers(extra) {
    var h = {
      apikey: cfg.supabaseKey,
      Authorization: "Bearer " + cfg.supabaseKey,
      "Content-Type": "application/json"
    };
    Object.keys(extra || {}).forEach(function (k) { h[k] = extra[k]; });
    return h;
  }

  function track(name, params) {
    if (typeof window.gtag === "function") window.gtag("event", name, params || {});
  }

  function readQuizResult() {
    try {
      var raw = localStorage.getItem("aurefold-house-test-v2");
      if (!raw) return null;
      var parsed = JSON.parse(raw);
      if (!validHouse(parsed.house)) return null;
      return parsed;
    } catch (e) {
      return null;
    }
  }

  function recordQuizResult(result) {
    if (!result || !cfg.supabaseUrl || !cfg.supabaseKey) return Promise.resolve(false);
    var countedKey = "aurefold-house-test-counted-v2";
    try {
      if (localStorage.getItem(countedKey)) return Promise.resolve(true);
    } catch (e) {}

    return fetch(cfg.supabaseUrl + "/rest/v1/votes", {
      method: "POST",
      headers: headers({ Prefer: "return=minimal" }),
      body: JSON.stringify({
        poll_id: SYSTEM_POLL,
        option_id: result.house,
        voter: voterId()
      })
    }).then(function (response) {
      // The votes table has primary key (poll_id, voter). A 409 therefore means
      // this browser was already counted and must not overwrite its first House.
      if (!response.ok && response.status !== 409) throw new Error("house distribution vote failed");
      try { localStorage.setItem(countedKey, result.house); } catch (e) {}
      return true;
    }).catch(function () { return false; });
  }

  function loadDistribution() {
    if (!cfg.supabaseUrl || !cfg.supabaseKey) return Promise.resolve(null);
    return fetch(cfg.supabaseUrl + "/rest/v1/poll_tallies?select=poll_id,option_id,votes&poll_id=eq." + encodeURIComponent(SYSTEM_POLL) + "&order=votes.desc", {
      headers: headers()
    }).then(function (response) {
      if (!response.ok) throw new Error("distribution unavailable");
      return response.json();
    }).then(function (rows) {
      var total = rows.reduce(function (sum, row) { return sum + Number(row.votes || 0); }, 0);
      if (total < 20) return null;
      return { rows: rows, total: total };
    }).catch(function () { return null; });
  }

  function appendDistribution(card, data) {
    if (!card || !data || card.querySelector(".house-community-distribution")) return;

    var section = document.createElement("section");
    section.className = "house-community-distribution read-module";
    section.style.marginTop = "28px";

    var title = document.createElement("h3");
    title.textContent = "Where readers are landing";
    section.appendChild(title);

    var note = document.createElement("p");
    note.className = "world-note";
    note.textContent = data.total + " anonymous completed House Test results. This is community data, not a verdict on the Houses.";
    section.appendChild(note);

    var list = document.createElement("div");
    list.className = "house-distribution-list";

    data.rows.forEach(function (row) {
      if (!validHouse(row.option_id)) return;
      var pct = data.total ? Math.round((Number(row.votes || 0) * 100) / data.total) : 0;
      var line = document.createElement("div");
      line.className = "house-distribution-row";
      line.style.display = "grid";
      line.style.gridTemplateColumns = "minmax(90px, 1fr) 3fr 44px";
      line.style.gap = "10px";
      line.style.alignItems = "center";
      line.style.margin = "8px 0";

      var name = document.createElement("span");
      name.textContent = labelFor(row.option_id);
      line.appendChild(name);

      var trackEl = document.createElement("div");
      trackEl.style.height = "7px";
      trackEl.style.background = "rgba(58,51,42,.12)";
      trackEl.style.overflow = "hidden";
      var fill = document.createElement("div");
      fill.style.height = "100%";
      fill.style.width = pct + "%";
      fill.style.background = "#8a4a2a";
      trackEl.appendChild(fill);
      line.appendChild(trackEl);

      var value = document.createElement("strong");
      value.textContent = pct + "%";
      line.appendChild(value);
      list.appendChild(line);
    });

    section.appendChild(list);
    card.appendChild(section);
  }

  function integrateQuizResult() {
    var root = document.getElementById("quiz");
    if (!root) return;

    function apply() {
      var card = root.querySelector(".quiz-result");
      var result = readQuizResult();
      if (!card || !result) return false;
      if (card.dataset.growthIntegrated === "1") return true;
      card.dataset.growthIntegrated = "1";

      // Existing Moot code consumes #house=<key>; it highlights the matching
      // House but never auto-casts a vote.
      Array.prototype.forEach.call(card.querySelectorAll('a[href^="vote.html?house="]'), function (a) {
        a.href = "vote.html#house=" + encodeURIComponent(result.house);
      });

      // Add the identity -> community step. The Banner receives the result as
      // a suggestion only; the reader must explicitly press “Swear it”.
      var primaryRow = card.querySelector(".cta-row");
      if (primaryRow && !card.querySelector(".house-banner-cta")) {
        var banner = document.createElement("a");
        banner.className = "btn btn-ghost house-banner-cta";
        banner.href = "community.html?house=" + encodeURIComponent(result.house);
        banner.textContent = "Take my place under the Banner";
        banner.addEventListener("click", function () { track("house_test_banner_click", { house: result.house }); });
        primaryRow.appendChild(banner);
      }

      recordQuizResult(result).then(function () {
        return loadDistribution();
      }).then(function (distribution) {
        appendDistribution(card, distribution);
      });
      return true;
    }

    if (apply()) return;
    var observer = new MutationObserver(function () {
      if (apply()) observer.disconnect();
    });
    observer.observe(root, { childList: true, subtree: true });
  }

  function integrateBannerPrefill() {
    var root = document.getElementById("banner-profile");
    if (!root) return;

    var params = new URLSearchParams(location.search);
    var requested = params.get("house");
    var saved = readQuizResult();
    if (!validHouse(requested) && saved) requested = saved.house;
    if (!validHouse(requested)) return;

    function apply() {
      var select = root.querySelector("select");
      if (!select) return false;
      // Never overwrite an allegiance already stored on the member profile.
      if (select.value) return true;
      var exists = Array.prototype.some.call(select.options, function (o) { return o.value === requested; });
      if (!exists) return true;

      select.value = requested;
      if (!root.querySelector(".house-test-prefill-note")) {
        var note = document.createElement("p");
        note.className = "auth-gate-status house-test-prefill-note";
        note.textContent = "Your House Test result is waiting here. Nothing changes until you choose “Swear it”.";
        var form = root.querySelector("form");
        if (form) form.insertBefore(note, form.lastElementChild || null);
      }
      track("house_test_banner_prefill", { house: requested });
      return true;
    }

    if (apply()) return;
    var observer = new MutationObserver(function () {
      if (apply()) observer.disconnect();
    });
    observer.observe(root, { childList: true, subtree: true });
    window.setTimeout(function () { observer.disconnect(); }, 10000);
  }

  integrateQuizResult();
  integrateBannerPrefill();
})();
