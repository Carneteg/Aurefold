/* AUREFOLD — author-only Community Manager dashboard.
   Aggregated operations view. Never reads raw community_funnel_events rows.
   Patreon clicks are intent signals only; membership/revenue require Patreon data. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var URL = cfg.supabaseUrl, KEY = cfg.supabaseKey;
  var root = document.getElementById("cm-root");
  if (!root || !URL || !KEY) return;

  var token = null;
  var activeDays = 30;

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function jwtPayload(tok) {
    try { return JSON.parse(atob(tok.split(".")[1].replace(/-/g, "+").replace(/_/g, "/"))); }
    catch (e) { return {}; }
  }

  function isStaff(tok) {
    var role = (jwtPayload(tok).app_metadata || {}).aurefold_role;
    return role === "author" || role === "admin";
  }

  function pct(n, d) {
    n = Number(n || 0); d = Number(d || 0);
    return d > 0 ? Math.round((n * 1000) / d) / 10 : 0;
  }

  function number(n) { return Number(n || 0).toLocaleString("en-US"); }

  function rpc(days) {
    return fetch(URL + "/rest/v1/rpc/author_community_dashboard", {
      method: "POST",
      headers: {
        apikey: KEY,
        Authorization: "Bearer " + token,
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

  function renderLogin(msg) {
    root.innerHTML = "";
    var box = el("section", "auth-gate cm-login");
    box.appendChild(el("p", "cm-kicker", "AUREFOLD · AUTHOR ONLY"));
    box.appendChild(el("h1", "auth-gate-title", "Community Manager"));
    box.appendChild(el("p", "auth-gate-body", "Private community operations. Sign in with an Aurefold author/admin account; Supabase checks the role on every dashboard request."));
    if (msg) box.appendChild(el("p", "auth-gate-status", msg));

    var form = el("form", "auth-gate-form");
    var email = el("input", "auth-input");
    email.type = "email"; email.required = true; email.placeholder = "Email"; email.autocomplete = "username";
    var pass = el("input", "auth-input");
    pass.type = "password"; pass.required = true; pass.placeholder = "Password"; pass.autocomplete = "current-password";
    var btn = el("button", "btn btn-primary", "Sign in");
    btn.type = "submit";
    form.appendChild(email); form.appendChild(pass); form.appendChild(btn);
    box.appendChild(form);
    root.appendChild(box);

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      btn.disabled = true;
      fetch(URL + "/auth/v1/token?grant_type=password", {
        method: "POST",
        headers: { apikey: KEY, "Content-Type": "application/json" },
        body: JSON.stringify({ email: email.value.trim(), password: pass.value })
      }).then(function (r) { return r.json().then(function (b) { return { ok: r.ok, b: b }; }); })
        .then(function (res) {
          if (!res.ok || !res.b.access_token) { renderLogin("Sign-in failed — check email and password."); return; }
          if (!isStaff(res.b.access_token)) { renderLogin("This account is not marked author/admin."); return; }
          token = res.b.access_token;
          sessionStorage.setItem("aurefold_mod_token", token);
          loadDashboard(activeDays);
        })
        .catch(function () { renderLogin("The dashboard could not reach Supabase."); });
    });
  }

  function header() {
    var head = el("div", "cm-head");
    var left = el("div");
    left.appendChild(el("p", "cm-kicker", "AUREFOLD · COMMUNITY OPERATIONS"));
    left.appendChild(el("h1", "", "Community Manager"));
    left.appendChild(el("p", "cm-muted", "Identity → participation → return → belonging → support."));
    head.appendChild(left);

    var actions = el("div", "cm-actions");
    var moderation = el("a", "btn btn-ghost", "Moderation");
    moderation.href = "/admin/community.html";
    actions.appendChild(moderation);
    var site = el("a", "btn btn-ghost", "Open The Banner");
    site.href = "/community.html"; site.target = "_blank"; site.rel = "noopener";
    actions.appendChild(site);
    var out = el("button", "btn btn-ghost", "Sign out");
    out.type = "button";
    out.addEventListener("click", function () {
      sessionStorage.removeItem("aurefold_mod_token");
      token = null;
      renderLogin();
    });
    actions.appendChild(out);
    head.appendChild(actions);
    return head;
  }

  function metric(label, value, note) {
    var c = el("article", "cm-card");
    c.appendChild(el("span", "", label));
    c.appendChild(el("strong", "", number(value)));
    if (note) c.appendChild(el("p", "cm-note", note));
    return c;
  }

  function windowPicker() {
    var row = el("div", "cm-actions cm-window");
    row.appendChild(el("span", "cm-note", "Recent window"));
    [7, 30, 90].forEach(function (days) {
      var b = el("button", "btn btn-ghost", days + "d");
      b.type = "button";
      b.setAttribute("aria-pressed", days === activeDays ? "true" : "false");
      b.addEventListener("click", function () {
        if (days === activeDays) return;
        activeDays = days;
        loadDashboard(days);
      });
      row.appendChild(b);
    });
    return row;
  }

  function barRow(label, n, total) {
    var row = el("div", "cm-row");
    row.appendChild(el("span", "", label));
    var track = el("div", "cm-bar");
    var fill = el("span");
    fill.style.width = pct(n, total) + "%";
    track.appendChild(fill);
    row.appendChild(track);
    row.appendChild(el("strong", "", number(n) + (total ? " · " + pct(n, total) + "%" : "")));
    return row;
  }

  function overlapRow(label, numerator, denominator) {
    var row = el("div", "cm-funnel-row");
    row.appendChild(el("span", "", label));
    var track = el("div", "cm-bar");
    var fill = el("span");
    fill.style.width = pct(numerator, denominator) + "%";
    track.appendChild(fill);
    row.appendChild(track);
    row.appendChild(el("strong", "", denominator ? pct(numerator, denominator) + "%" : "—"));
    var detail = el("p", "cm-note", number(numerator) + " of " + number(denominator) + " same-browser records");
    detail.style.gridColumn = "1 / -1";
    row.appendChild(detail);
    return row;
  }

  function renderOverview(data) {
    var f = data.funnel || {};
    var w = data.window || {};

    var controls = el("div", "cm-head");
    controls.appendChild(el("div", "cm-note", "Generated " + new Date(data.generated_at || Date.now()).toLocaleString()));
    controls.appendChild(windowPicker());
    root.appendChild(controls);

    var grid = el("section", "cm-grid");
    grid.appendChild(metric("Engaged browsers", f.engaged_visitors, "At least one tracked community milestone."));
    grid.appendChild(metric("House Tests", f.house_test_completed, pct(f.house_test_completed, f.engaged_visitors) + "% of engaged browsers"));
    grid.appendChild(metric("Ledger participants", f.ledger_participants, pct(f.ledger_participants, f.engaged_visitors) + "% of engaged browsers"));
    grid.appendChild(metric("Returned to Ledger", f.returning_participants, pct(f.returning_participants, f.ledger_participants) + "% of Ledger participants"));
    grid.appendChild(metric("Sworn readers", f.sworn_readers, pct(f.sworn_readers, f.engaged_visitors) + "% of engaged browsers"));
    grid.appendChild(metric("Patreon intent", f.patreon_intent, "CTA clicks only — not membership."));
    root.appendChild(grid);

    var recent = el("section", "cm-panel");
    recent.appendChild(el("h2", "", "Recent pulse — last " + activeDays + " days"));
    var rg = el("div", "cm-grid");
    rg.appendChild(metric("Active engaged", w.engaged_visitors));
    rg.appendChild(metric("House Test", w.house_test_completed));
    rg.appendChild(metric("Ledger", w.ledger_participants));
    rg.appendChild(metric("Sworn", w.sworn_readers));
    rg.appendChild(metric("Patreon intent", w.patreon_intent));
    recent.appendChild(rg);
    root.appendChild(recent);
  }

  function renderPath(data) {
    var f = data.funnel || {}, o = data.path_overlap || {};
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "Community path overlap"));
    panel.appendChild(el("p", "cm-note", "These are same-browser overlaps, not guaranteed chronological conversions. They show whether the behaviors we want are occurring in the same reader journey."));
    panel.appendChild(overlapRow("House Test → also Ledger", o.house_test_and_ledger, f.house_test_completed));
    panel.appendChild(overlapRow("Ledger → returns to another question", o.ledger_and_returning, f.ledger_participants));
    panel.appendChild(overlapRow("Returning Ledger → also sworn reader", o.returning_and_sworn, f.returning_participants));
    panel.appendChild(overlapRow("Sworn reader → also Patreon intent", o.sworn_and_patreon, f.sworn_readers));
    root.appendChild(panel);
  }

  function renderInsights(data) {
    var f = data.funnel || {}, o = data.path_overlap || {};
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "What deserves attention"));

    var paths = [
      { label: "House Test readers who also reach Ledger", n: o.house_test_and_ledger, d: f.house_test_completed, action: "Strengthen the result-page bridge into the Ledger Question." },
      { label: "Ledger readers who return for another question", n: o.ledger_and_returning, d: f.ledger_participants, action: "Improve the cadence and reason to return for the next Ledger Question." },
      { label: "Returning participants who also swear into The Banner", n: o.returning_and_sworn, d: f.returning_participants, action: "Make community identity feel valuable after repeated participation." },
      { label: "Sworn readers who also show Patreon intent", n: o.sworn_and_patreon, d: f.sworn_readers, action: "Improve the support proposition without putting canon behind payment." }
    ].filter(function (x) { return Number(x.d || 0) > 0; });

    if (!paths.length) {
      panel.appendChild(el("p", "cm-empty", "Not enough community milestone data yet. The dashboard will surface gaps once real readers begin moving through the funnel."));
      root.appendChild(panel);
      return;
    }

    paths.sort(function (a, b) { return pct(a.n,a.d) - pct(b.n,b.d); });
    paths.forEach(function (x, idx) {
      var item = el("div", "cm-insight");
      item.appendChild(el("strong", "", (idx === 0 ? "Current largest measured gap: " : "Measured path: ") + x.label));
      item.appendChild(el("p", "cm-note", pct(x.n,x.d) + "% overlap · " + number(x.n) + " of " + number(x.d) + ". " + x.action + (x.d < 20 ? " Sample is still small; treat this as an early signal." : "")));
      panel.appendChild(item);
    });
    root.appendChild(panel);
  }

  function renderHouseDistribution(data) {
    var rows = data.house_distribution || [];
    var total = rows.reduce(function (s, r) { return s + Number(r.votes || 0); }, 0);
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "House Test distribution"));
    if (!total) {
      panel.appendChild(el("p", "cm-empty", "No recorded House Test results yet."));
    } else {
      panel.appendChild(el("p", "cm-note", number(total) + " anonymous House Test completions in the aggregate tally."));
      rows.forEach(function (r) { panel.appendChild(barRow(r.label || r.house, r.votes, total)); });
    }

    var sworn = data.sworn_house_distribution || [];
    var swornTotal = sworn.reduce(function (s, r) { return s + Number(r.readers || 0); }, 0);
    panel.appendChild(el("div", "cm-spacer"));
    panel.appendChild(el("h3", "", "Sworn reader allegiances"));
    if (!swornTotal) panel.appendChild(el("p", "cm-empty", "No saved Banner profiles yet."));
    else sworn.forEach(function (r) { panel.appendChild(barRow(r.house, r.readers, swornTotal)); });
    root.appendChild(panel);
  }

  function renderLedger(data) {
    var questions = data.ledger_questions || [];
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "Ledger Questions"));
    if (!questions.length) {
      panel.appendChild(el("p", "cm-empty", "No Ledger Questions found."));
      root.appendChild(panel);
      return;
    }
    questions.forEach(function (q) {
      var card = el("article", "cm-insight");
      var top = el("div", "cm-actions");
      top.appendChild(el("span", "cm-badge " + (q.open ? "cm-badge-open" : "cm-badge-closed"), q.open ? "open" : "closed"));
      top.appendChild(el("strong", "", q.question || q.id));
      top.appendChild(el("span", "cm-note", number(q.votes) + " votes"));
      card.appendChild(top);
      (q.options || []).forEach(function (opt) { card.appendChild(barRow(opt.label || opt.id, opt.votes, q.votes)); });
      panel.appendChild(card);
    });
    root.appendChild(panel);
  }

  function renderPatreon(data) {
    var rows = data.patreon_intent || [];
    var total = rows.reduce(function (s, r) { return s + Number(r.visitors || 0); }, 0);
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "Patreon intent"));
    panel.appendChild(el("p", "cm-note", "This measures CTA click intent only. It does not prove Patreon membership, tier selection, payment or revenue."));
    if (!total) panel.appendChild(el("p", "cm-empty", "No Patreon intent events yet."));
    else rows.forEach(function (r) { panel.appendChild(barRow(r.intent, r.visitors, total)); });
    root.appendChild(panel);
  }

  function renderTrend(data) {
    var rows = (data.daily || []).slice(-14);
    var panel = el("section", "cm-panel");
    panel.appendChild(el("h2", "", "Daily milestone activity"));
    panel.appendChild(el("p", "cm-note", "Last 14 days within the selected window. Values are unique browsers per milestone per day."));
    var grid = el("div", "cm-trend");
    ["Date", "House", "Ledger", "Sworn", "Patreon"].forEach(function (h, i) { grid.appendChild(el("div", i ? "cm-trend-head" : "cm-trend-day", h)); });
    rows.forEach(function (r) {
      grid.appendChild(el("div", "cm-trend-day", String(r.date).slice(5)));
      grid.appendChild(el("div", "cm-trend-cell", number(r.house_test)));
      grid.appendChild(el("div", "cm-trend-cell", number(r.ledger)));
      grid.appendChild(el("div", "cm-trend-cell", number(r.sworn)));
      grid.appendChild(el("div", "cm-trend-cell", number(r.patreon)));
    });
    panel.appendChild(grid);
    root.appendChild(panel);
  }

  function renderDashboard(data) {
    root.innerHTML = "";
    root.appendChild(header());
    renderOverview(data || {});
    renderPath(data || {});
    renderInsights(data || {});
    renderHouseDistribution(data || {});
    renderLedger(data || {});
    renderPatreon(data || {});
    renderTrend(data || {});
    var note = el("p", "cm-note", "Community data is NON-CANON. The dashboard never determines House truth, story outcomes, protected mysteries, or reader moral worth.");
    note.style.marginTop = "1.2rem";
    root.appendChild(note);
  }

  function loadDashboard(days) {
    root.innerHTML = "";
    root.appendChild(header());
    root.appendChild(el("p", "cm-status", "Loading aggregated community data…"));
    rpc(days).then(renderDashboard).catch(function (e) {
      root.innerHTML = "";
      root.appendChild(header());
      var panel = el("section", "cm-panel");
      panel.appendChild(el("h2", "", "Dashboard unavailable"));
      panel.appendChild(el("p", "cm-empty", "The aggregated RPC could not be loaded. Your session may have expired, or Supabase refused the staff-only request."));
      var retry = el("button", "btn btn-primary", "Sign in again");
      retry.type = "button"; retry.addEventListener("click", function () { sessionStorage.removeItem("aurefold_mod_token"); token = null; renderLogin(); });
      panel.appendChild(retry);
      root.appendChild(panel);
    });
  }

  var saved = sessionStorage.getItem("aurefold_mod_token");
  if (saved && isStaff(saved)) { token = saved; loadDashboard(activeDays); }
  else renderLogin();
})();
