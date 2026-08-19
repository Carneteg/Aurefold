/* AUREFOLD — House Test community layer
   NON-CANON product/community functionality.
   Records one anonymous House Test v2 outcome per browser and renders only
   aggregate House distribution once the sample is large enough to be useful. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  if (!cfg.supabaseUrl || !cfg.supabaseKey) return;

  var API = cfg.supabaseUrl + "/rest/v1";
  var HEADERS = {
    apikey: cfg.supabaseKey,
    Authorization: "Bearer " + cfg.supabaseKey,
    "Content-Type": "application/json"
  };
  var THRESHOLD = Number(cfg.HOUSE_DISTRIBUTION_REVEAL_THRESHOLD || 25);
  var ORDER = ["blackthorn", "ashbourne", "whitehart", "stormrider", "ravenshade", "ironvale", "blackcrest", "stonebear", "tidebreaker", "phoenix"];
  var NAMES = {
    blackthorn: "Blackthorn", ashbourne: "Ashbourne", whitehart: "Whitehart",
    stormrider: "Stormrider", ravenshade: "Ravenshade", ironvale: "Ironvale",
    blackcrest: "Blackcrest", stonebear: "Stonebear", tidebreaker: "Tidebreaker",
    phoenix: "Phoenix"
  };

  function voterId() {
    var id = localStorage.getItem("ew-voter");
    if (!id) {
      id = (crypto.randomUUID && crypto.randomUUID()) ||
        "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, function () {
          return Math.floor(Math.random() * 16).toString(16);
        });
      localStorage.setItem("ew-voter", id);
    }
    return id;
  }

  function request(url, opts) {
    return fetch(url, opts).then(function (r) {
      if (r.ok || r.status === 409) return { ok: r.ok, conflict: r.status === 409 };
      throw new Error("HTTP " + r.status);
    });
  }

  function loadTallies() {
    return fetch(API + "/house_test_tallies?select=house_key,votes", { headers: HEADERS })
      .then(function (r) { if (!r.ok) throw new Error("HTTP " + r.status); return r.json(); });
  }

  function ensureDistributionBox() {
    var existing = document.getElementById("reader-house-distribution");
    if (existing) return existing;

    var box = document.createElement("section");
    box.id = "reader-house-distribution";
    box.className = "read-module";
    box.setAttribute("aria-live", "polite");

    var quiz = document.getElementById("quiz");
    if (quiz && quiz.parentNode) {
      quiz.parentNode.insertBefore(box, quiz.nextSibling);
      return box;
    }

    var stats = document.getElementById("banner-stats");
    if (stats && stats.parentNode) {
      stats.parentNode.insertBefore(box, stats.nextSibling);
      return box;
    }
    return null;
  }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function renderDistribution(rows) {
    var box = ensureDistributionBox();
    if (!box) return;

    var counts = {};
    var total = 0;
    ORDER.forEach(function (h) { counts[h] = 0; });
    (rows || []).forEach(function (r) {
      if (Object.prototype.hasOwnProperty.call(counts, r.house_key)) {
        var n = Number(r.votes) || 0;
        counts[r.house_key] = n;
        total += n;
      }
    });

    box.innerHTML = "";
    box.appendChild(el("p", "moot-kind", "THE HOUSES OF THE READERS"));
    box.appendChild(el("h2", "section-title", "Where the readership is gathering"));

    if (total < THRESHOLD) {
      box.appendChild(el("p", "world-note", "The reader hall is still forming. The House distribution opens after " + THRESHOLD + " completed tests so a handful of early answers never masquerades as a fandom-wide verdict."));
      if (!document.getElementById("quiz")) {
        var row = el("div", "cta-row");
        var take = el("a", "btn btn-primary", "Take the House Test");
        take.href = "quiz.html";
        row.appendChild(take);
        box.appendChild(row);
      }
      return;
    }

    box.appendChild(el("p", "world-note", total + " completed House Tests. This is reader affinity, not canon and not a claim that any House is morally correct."));

    ORDER.slice().sort(function (a, b) {
      var d = counts[b] - counts[a];
      return d !== 0 ? d : ORDER.indexOf(a) - ORDER.indexOf(b);
    }).forEach(function (h) {
      var n = counts[h];
      var pct = total ? Math.round((n * 100) / total) : 0;
      var row = el("div", "moot-result");
      var head = el("div", "moot-result-head");
      head.appendChild(el("span", "moot-result-label", "House " + NAMES[h]));
      head.appendChild(el("span", "moot-result-count", pct + "%"));
      var bar = el("div", "moot-bar");
      var fill = el("div", "moot-bar-fill");
      fill.style.width = pct + "%";
      bar.appendChild(fill);
      row.appendChild(head);
      row.appendChild(bar);
      box.appendChild(row);
    });
  }

  function refreshDistribution() {
    loadTallies().then(renderDistribution).catch(function () {
      var box = ensureDistributionBox();
      if (box) box.hidden = true;
    });
  }

  function currentQuizResult() {
    if (new URLSearchParams(location.search).get("result")) return null;
    try {
      var raw = localStorage.getItem("aurefold-house-test-v2");
      if (!raw) return null;
      var result = JSON.parse(raw);
      if (!result || ORDER.indexOf(result.house) === -1) return null;
      return result;
    } catch (e) { return null; }
  }

  var recordedThisPage = false;
  function maybeRecordQuizResult() {
    if (recordedThisPage || !document.getElementById("quiz")) return;
    if (!document.querySelector("#quiz .quiz-result")) return;
    var result = currentQuizResult();
    if (!result) return;
    recordedThisPage = true;

    var postHeaders = {
      apikey: HEADERS.apikey,
      Authorization: HEADERS.Authorization,
      "Content-Type": "application/json",
      Prefer: "return=minimal"
    };
    request(API + "/house_test_results", {
      method: "POST",
      headers: postHeaders,
      body: JSON.stringify({ voter: voterId(), house_key: result.house })
    }).then(function () {
      refreshDistribution();
    }).catch(function () {
      /* Community metrics must never interrupt the quiz result experience. */
    });
  }

  refreshDistribution();

  var quiz = document.getElementById("quiz");
  if (quiz) {
    var observer = new MutationObserver(maybeRecordQuizResult);
    observer.observe(quiz, { childList: true, subtree: true });
    maybeRecordQuizResult();
  }
})();
