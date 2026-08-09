/* AUREFOLD — Book One page: free-download links, an honest click counter, and
   moderated ratings & reviews. Presentation only; the Supabase row-level
   security decides what the anon key may do (submit a review, read only
   APPROVED reviews, read the click count, bump the counter via one function). */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var book = cfg.book || {};
  var API = cfg.supabaseUrl ? cfg.supabaseUrl + "/rest/v1" : null;
  var HEAD = API ? {
    apikey: cfg.supabaseKey,
    Authorization: "Bearer " + cfg.supabaseKey,
    "Content-Type": "application/json"
  } : null;

  function getJson(url) {
    return fetch(url, { headers: HEAD }).then(function (r) { return r.ok ? r.json() : null; });
  }
  function esc(s) { var d = document.createElement("div"); d.textContent = s == null ? "" : s; return d.innerHTML; }
  function stars(n) { var f = Math.max(0, Math.min(5, Math.round(n))); return "★★★★★".slice(0, f) + "☆☆☆☆☆".slice(0, 5 - f); }

  // ---- Download buttons -----------------------------------------------------
  var amazon = document.getElementById("book-amazon");
  if (amazon && book.amazonUrl && String(book.amazonUrl).trim()) {
    amazon.href = String(book.amazonUrl).trim();   // config is the source of truth
  }
  // Direct file download stays hidden until a file is configured.
  var dl = document.getElementById("book-download");
  if (dl && book.downloadFile && String(book.downloadFile).trim()) {
    dl.href = String(book.downloadFile).trim();
    dl.hidden = false;
  }

  // ---- GA4 tracking (in ADDITION to the Supabase counter — it does not replace it)
  // We emit the download event MANUALLY for every button below, which is the only
  // way GA4 sees the .epub download (GA4's automatic file tracking ignores .epub).
  //
  // DOUBLE-COUNT WARNING: because we send "file_download" ourselves, keep GA4
  // Enhanced Measurement -> "File downloads" turned OFF. If it is ON, a .pdf click
  // is counted twice (once here, once by GA4's auto-tracking; .epub is unaffected).
  // Alternative: rename DL_EVENT to a custom name like "book_download" (GA4 never
  // auto-emits that), which lets Enhanced Measurement stay ON with no duplication —
  // but then your GA4 report must filter on "book_download" instead of "file_download".
  var DL_EVENT = "file_download";

  function ga(name, params) {
    // Fire only if the gtag snippet actually loaded (no-op if GA is blocked/absent).
    if (typeof window.gtag === "function") window.gtag("event", name, params || {});
  }
  function fileMeta(href) {
    var clean = String(href || "").split("?")[0].split("#")[0];
    var base = clean.substring(clean.lastIndexOf("/") + 1);
    var dot = base.lastIndexOf(".");
    return { name: base, ext: dot >= 0 ? base.substring(dot + 1).toLowerCase() : "" };
  }
  function trackClick(el) {
    var href = el.getAttribute("href") || "";
    // Amazon (or any external http(s) link) is an OUTBOUND CLICK, not a file
    // download — track it separately so it does not pollute file_download.
    if (el.id === "book-amazon" || /^https?:\/\//i.test(href)) {
      ga("select_content", { content_type: "amazon_outbound", link_url: href });
      return;
    }
    // Local file (PDF / EPUB) = a real download.
    var m = fileMeta(href);
    ga(DL_EVENT, { file_name: m.name, file_extension: m.ext, link_url: href });
  }

  // ---- Honest download counter (counts clicks on this page, not Amazon) ------
  var countEl = document.getElementById("download-count");
  var threshold = Number(book.downloadCountThreshold);
  if (!(threshold > 0)) threshold = 0;

  function bump() {
    if (!API) return;
    fetch(API + "/rpc/bump_download", {
      method: "POST", headers: HEAD, body: JSON.stringify({ p_id: "book" })
    }).catch(function () {});
  }
  function showCount() {
    if (!countEl || !API) return;
    getJson(API + "/download_stats?select=clicks&id=eq.book").then(function (rows) {
      var n = rows && rows[0] ? Number(rows[0].clicks) : 0;
      if (n > 0 && n >= threshold) {
        countEl.textContent = n.toLocaleString() + " downloads started from this page";
        countEl.hidden = false;
      }
    }).catch(function () {});
  }
  Array.prototype.forEach.call(document.querySelectorAll(".book-dl"), function (b) {
    b.addEventListener("click", function () {
      bump();          // existing Supabase counter — unchanged
      trackClick(b);   // new: GA4 file_download / outbound event
    });
  });
  showCount();

  // ---- Ratings & reviews (moderated) ----------------------------------------
  var listEl = document.getElementById("reviews-list");
  if (listEl && API) {
    var summary = document.getElementById("reviews-summary");
    var avgEl = document.getElementById("reviews-avg");
    var starsEl = document.getElementById("reviews-stars");
    var countRvEl = document.getElementById("reviews-count");
    var emptyEl = document.getElementById("reviews-empty");

    function render(rows) {
      listEl.innerHTML = "";
      if (!rows || !rows.length) { if (emptyEl) emptyEl.hidden = false; return; }
      var sum = 0;
      rows.forEach(function (r) { sum += Number(r.rating) || 0; });
      var avg = sum / rows.length;
      if (summary) {
        avgEl.textContent = avg.toFixed(1);
        starsEl.textContent = stars(avg);
        countRvEl.textContent = " · " + rows.length + (rows.length === 1 ? " review" : " reviews");
        summary.hidden = false;
      }
      rows.forEach(function (r) {
        var li = document.createElement("li");
        li.className = "review";
        var head = document.createElement("p");
        head.className = "review-head";
        head.innerHTML =
          '<span class="review-stars" aria-label="' + (Number(r.rating) || 0) + ' out of 5">' + stars(r.rating) + '</span>' +
          '<span class="review-name">' + (esc(r.name) || "A reader") + '</span>';
        li.appendChild(head);
        if (r.body && String(r.body).trim()) {
          var p = document.createElement("p");
          p.className = "review-body";
          p.textContent = r.body;              // textContent = no HTML injection
          li.appendChild(p);
        }
        listEl.appendChild(li);
      });
    }

    getJson(API + "/reviews?select=name,rating,body,created_at&order=created_at.desc").then(render).catch(function () {});

    // Star selector
    var starInput = document.getElementById("star-input");
    var chosen = 0;
    function paint(v) {
      if (!starInput) return;
      Array.prototype.forEach.call(starInput.querySelectorAll(".star"), function (s, i) {
        s.textContent = (i < v) ? "★" : "☆";
        s.setAttribute("aria-pressed", String(i < v));
      });
    }
    if (starInput) {
      for (var i = 1; i <= 5; i++) {
        (function (val) {
          var s = document.createElement("button");
          s.type = "button";
          s.className = "star";
          s.textContent = "☆";
          s.setAttribute("aria-label", val + (val === 1 ? " star" : " stars"));
          s.addEventListener("click", function () { chosen = val; paint(val); });
          s.addEventListener("mouseenter", function () { paint(val); });
          starInput.appendChild(s);
        })(i);
      }
      starInput.addEventListener("mouseleave", function () { paint(chosen); });
    }

    var form = document.getElementById("review-form");
    var note = document.getElementById("review-note");
    if (form) {
      form.addEventListener("submit", function (e) {
        e.preventDefault();
        if (!chosen) { note.textContent = "Please pick a star rating first."; return; }
        var name = (document.getElementById("review-name").value || "").trim().slice(0, 60);
        var body = (document.getElementById("review-body").value || "").trim().slice(0, 2000);
        var btn = form.querySelector("button[type=submit]");
        if (btn) btn.disabled = true;
        fetch(API + "/reviews", {
          method: "POST",
          headers: {
            apikey: cfg.supabaseKey,
            Authorization: "Bearer " + cfg.supabaseKey,
            "Content-Type": "application/json",
            Prefer: "return=minimal"
          },
          body: JSON.stringify({ name: name || null, rating: chosen, body: body || null })
        }).then(function (r) {
          if (!r.ok && r.status !== 201) throw new Error("HTTP " + r.status);
          form.reset(); chosen = 0; paint(0);
          note.textContent = "Thank you — your review will appear here once it's approved.";
        }).catch(function () {
          note.textContent = "Something went wrong. Please try again in a moment.";
        }).then(function () { if (btn) btn.disabled = false; });
      });
    }
  }
})();
