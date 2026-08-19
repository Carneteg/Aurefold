/* AUREFOLD — community growth integration
   NON-CANON product layer.

   This file deliberately sits beside the House Test and Banner modules instead
   of replacing them. It connects the existing experiences into the approved
   funnel:

     House Test -> share / Moot -> Banner -> free Patreon

   Privacy model:
   - no name, email, account id or IP-derived identifier is collected here;
   - one random browser UUID is used only to prevent duplicate quiz tallies;
   - raw quiz rows are INSERT-only from the public site and not publicly readable;
   - only aggregate House tallies are public;
   - aggregate distribution stays hidden until >= 20 real results.
*/
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
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

  function browserId() {
    var storageKey = "aurefold-house-quiz-browser-v1";
    var id;
    try { id = localStorage.getItem(storageKey); } catch (e) {}
    if (id) return id;

    if (window.crypto && typeof window.crypto.randomUUID === "function") {
      id = window.crypto.randomUUID();
    } else {
      id = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0;
        var v = c === "x" ? r : (r & 3 | 8);
        return v.toString(16);
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
    var countedKey = "aurefold-house-quiz-counted-v1";
    try {
      if (localStorage.getItem(countedKey)) return Promise.resolve(true);
    } catch (e) {}

    return fetch(cfg.supabaseUrl + "/rest/v1/house_quiz_results", {
      method: "POST",
      headers: headers({ Prefer: "return=minimal" }),
      body: JSON.stringify({
        browser_id: browserId(),
        house_key: result.house,
        locale: (document.documentElement.lang || "en").slice(0, 12),
        source: "house-test-v2",
        scores: { counterweight: validHouse(result.counterweight) ? result.counterweight : null }
      })
    }).then(function (response) {
      // 409 means this browser UUID was already counted. That is success for
      // the one-result-per-browser rule, not a reason to retry or overwrite.
      if (!response.ok && response.status !== 409) throw new Error("quiz tally failed");
      try { localStorage.setItem(countedKey, result.house); } catch (e) {}
      return true;
    }).catch(function () { return false; });
  }

  function loadDistribution() {
    if (!cfg.supabaseUrl || !cfg.supabaseKey) return Promise.resolve(null);
    return fetch(cfg.supabaseUrl + "/rest/v1/house_quiz_tallies?select=house_key,result_count&order=result_count.desc", {
      headers: headers()
    }).then(function (response) {
      if (!response.ok) throw new Error("distribution unavailable");
      return response.json();
    }).then(function (rows) {
      var total = rows.reduce(function (sum, row) { return sum + Number(row.result_count || 0); }, 0);
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
      if (!validHouse(row.house_key)) return;
      var pct = data.total ? Math.round((Number(row.result_count || 0) * 100) / data.total) : 0;
      var line = document.createElement("div");
      line.className = "house-distribution-row";
      line.style.display = "grid";
      line.style.gridTemplateColumns = "minmax(90px, 1fr) 3fr 44px";
      line.style.gap = "10px";
      line.style.alignItems = "center";
      line.style.margin = "8px 0";

      var name = document.createElement("span");
      name.textContent = labelFor(row.house_key);
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
      // Shared result pages intentionally do not create a local result, so they
      // are never counted as completions and never mutate the visitor funnel.
      if (!card || !result) return false;
      if (card.dataset.growthIntegrated === "1") return true;
      card.dataset.growthIntegrated = "1";

      // Existing Moot code consumes #house=<key>. Correct the older query-form
      // CTA without touching the House Test core script.
      Array.prototype.forEach.call(card.querySelectorAll('a[href^="vote.html?house="]'), function (a) {
        a.href = "vote.html#house=" + encodeURIComponent(result.house);
      });

      // Add the missing identity -> community step. The Banner receives the
      // result only as a suggestion; it must never auto-save allegiance.
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
      // Never overwrite an allegiance already saved in the member profile.
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
