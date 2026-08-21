/* AUREFOLD — Community Manager social attribution add-on.
   Staff-only presentation. Reads only the aggregate author_community_dashboard RPC.
   Never requests raw visitor UUIDs or raw event rows. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var root = document.getElementById("cm-root");
  if (!root || !cfg.supabaseUrl || !cfg.supabaseKey) return;

  var currentDays = 30;
  var inFlight = false;
  var lastSignature = "";

  function number(n) { return Number(n || 0).toLocaleString("en-US"); }
  function pct(n, d) { return Number(d || 0) > 0 ? Math.round((Number(n || 0) * 1000) / Number(d || 0)) / 10 : 0; }

  function token() {
    try { return sessionStorage.getItem("aurefold_mod_token"); }
    catch (e) { return null; }
  }

  function selectedDays() {
    var pressed = root.querySelector('.cm-window button[aria-pressed="true"]');
    if (!pressed) return currentDays;
    var n = parseInt(pressed.textContent, 10);
    return n > 0 ? n : currentDays;
  }

  function rpc(days) {
    var tok = token();
    if (!tok) return Promise.reject(new Error("signed out"));
    return fetch(cfg.supabaseUrl + "/rest/v1/rpc/author_community_dashboard", {
      method: "POST",
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: "Bearer " + tok,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ p_days: days })
    }).then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    }).then(function (data) {
      if (Array.isArray(data) && data.length === 1) return data[0];
      return data;
    });
  }

  function cell(text) {
    var td = document.createElement("td");
    td.textContent = text;
    return td;
  }

  function render(data, days) {
    var old = document.getElementById("cm-social-attribution");
    if (old) old.remove();

    var panel = document.createElement("section");
    panel.id = "cm-social-attribution";
    panel.className = "cm-panel";

    var title = document.createElement("h2");
    title.textContent = "Social campaign attribution";
    panel.appendChild(title);

    var note = document.createElement("p");
    note.className = "cm-note";
    note.textContent = "Only explicit Aurefold links carrying ?src= are counted here. Ordinary pageviews are not written to the community funnel. Source-to-vote is same-browser overlap, not proof of causation.";
    panel.appendChild(note);

    var rows = data && data.acquisition_sources || [];
    if (!rows.length) {
      var empty = document.createElement("p");
      empty.className = "cm-empty";
      empty.textContent = "No attributed campaign entries in the last " + days + " days yet.";
      panel.appendChild(empty);
      root.appendChild(panel);
      return;
    }

    var wrap = document.createElement("div");
    wrap.className = "table-wrap";
    var table = document.createElement("table");
    table.className = "cm-table";
    var thead = document.createElement("thead");
    var hr = document.createElement("tr");
    ["Source", "Entries", "Ledger voters", "Entry → vote", "Returned", "Patreon intent"].forEach(function (h) {
      var th = document.createElement("th");
      th.textContent = h;
      hr.appendChild(th);
    });
    thead.appendChild(hr);
    table.appendChild(thead);

    var tbody = document.createElement("tbody");
    rows.forEach(function (r) {
      var tr = document.createElement("tr");
      tr.appendChild(cell(r.source || "unknown"));
      tr.appendChild(cell(number(r.entries)));
      tr.appendChild(cell(number(r.ledger_voters)));
      tr.appendChild(cell((Number(r.entries || 0) ? pct(r.ledger_voters, r.entries) + "%" : "—")));
      tr.appendChild(cell(number(r.returning_participants)));
      tr.appendChild(cell(number(r.patreon_intent)));
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    wrap.appendChild(table);
    panel.appendChild(wrap);
    root.appendChild(panel);
  }

  function refresh(force) {
    var tok = token();
    if (!tok || inFlight) return;
    var days = selectedDays();
    var signature = tok.slice(-12) + ":" + days + ":" + (root.querySelector(".cm-window") ? "dashboard" : "waiting");
    if (!force && signature === lastSignature) return;
    if (!root.querySelector(".cm-window")) return;
    inFlight = true;
    currentDays = days;
    rpc(days).then(function (data) {
      render(data, days);
      lastSignature = signature;
    }).catch(function () {
      var old = document.getElementById("cm-social-attribution");
      if (old) old.remove();
    }).finally(function () { inFlight = false; });
  }

  root.addEventListener("click", function (e) {
    var b = e.target && e.target.closest ? e.target.closest(".cm-window button") : null;
    if (!b) return;
    window.setTimeout(function () { lastSignature = ""; refresh(true); }, 700);
  });

  var observer = new MutationObserver(function () { refresh(false); });
  observer.observe(root, { childList: true, subtree: true });
  window.setInterval(function () { refresh(false); }, 2500);
})();
