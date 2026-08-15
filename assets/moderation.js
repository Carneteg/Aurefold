/* AUREFOLD — community moderation (author only). Same sign-in pattern as the
   Loremaster: email + password against Supabase Auth; the JWT must carry
   app_metadata.aurefold_role = author|admin (RLS enforces it server-side too).
   Queues: pending comments, fan characters, submissions. Actions: approve,
   reject, feature, adopt (with an optional note shown on the piece). */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var URL = cfg.supabaseUrl, KEY = cfg.supabaseKey;
  var root = document.getElementById("mod-root");
  if (!root || !URL) return;

  var token = null;

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

  function api(path, opts) {
    opts = opts || {};
    var headers = { apikey: KEY, Authorization: "Bearer " + token };
    if (opts.body !== undefined) headers["Content-Type"] = "application/json";
    if (opts.prefer) headers["Prefer"] = opts.prefer;
    return fetch(URL + "/rest/v1" + path, {
      method: opts.method || "GET",
      headers: headers,
      body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined
    }).then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.status === 204 || r.status === 201 ? {} : r.json();
    });
  }

  /* ---------- sign-in ---------- */
  function renderLogin(msg) {
    root.innerHTML = "";
    var box = el("section", "auth-gate mod-login");
    box.appendChild(el("h1", "auth-gate-title", "Community moderation"));
    box.appendChild(el("p", "auth-gate-body",
      "Author only. Sign in with the same Supabase account you use for the Loremaster — the database checks your role on every call."));
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
          if (!res.ok || !res.b.access_token) { btn.disabled = false; renderLogin("Sign-in failed — check email and password."); return; }
          if (!isStaff(res.b.access_token)) { renderLogin("This account is not marked as staff (app_metadata.aurefold_role)."); return; }
          token = res.b.access_token;
          sessionStorage.setItem("aurefold_mod_token", token);
          renderDashboard();
        })
        .catch(function () { btn.disabled = false; renderLogin("The archive could not be reached."); });
    });
  }

  /* ---------- queues ---------- */
  function badge(s) { return el("span", "mod-badge mod-badge-" + s, s); }

  function actions(row, table, id, allowed) {
    var box = el("div", "mod-actions");
    allowed.forEach(function (a) {
      var b = el("button", "btn mod-btn mod-" + a.status, a.label);
      b.type = "button";
      b.addEventListener("click", function () {
        b.disabled = true;
        var patch = { status: a.status };
        if (a.askNote) {
          var note = prompt("Author note (shown on the piece — optional):");
          if (note === null) { b.disabled = false; return; }
          if (note.trim()) patch.author_note = note.trim();
        }
        api("/" + table + "?id=eq." + id, { method: "PATCH", body: patch, prefer: "return=minimal" })
          .then(loadAll)
          .catch(function () { b.disabled = false; alert("Failed — the database refused the change."); });
      });
      box.appendChild(b);
    });
    return box;
  }

  var STATUS_FLOW = {
    pending: [
      { status: "approved", label: "Approve" },
      { status: "rejected", label: "Reject" }
    ],
    approved: [
      { status: "featured", label: "Feature" },
      { status: "adopted", label: "Adopt into material", askNote: true },
      { status: "rejected", label: "Reject" }
    ],
    featured: [
      { status: "adopted", label: "Adopt into material", askNote: true },
      { status: "approved", label: "Unfeature" }
    ],
    adopted: [
      { status: "featured", label: "Back to featured" }
    ],
    rejected: [
      { status: "approved", label: "Approve after all" }
    ]
  };

  function section(titleText, rows, table, renderBody) {
    var sec = el("section", "mod-section");
    sec.appendChild(el("h2", "mod-title", titleText + " (" + rows.length + ")"));
    if (!rows.length) { sec.appendChild(el("p", "mod-empty", "Nothing waiting.")); return sec; }
    rows.forEach(function (r) {
      var card = el("article", "mod-card");
      var head = el("div", "mod-card-head");
      head.appendChild(badge(r.status));
      head.appendChild(el("span", "mod-meta",
        (r.profiles && r.profiles.username ? "by " + r.profiles.username : "") +
        " · " + new Date(r.created_at).toLocaleString()));
      card.appendChild(head);
      renderBody(card, r);
      card.appendChild(actions(r, table, r.id, STATUS_FLOW[r.status] || []));
      sec.appendChild(card);
    });
    return sec;
  }

  function loadAll() {
    root.innerHTML = "";
    var bar = el("div", "mod-bar");
    var out = el("button", "btn btn-ghost", "Sign out");
    out.type = "button";
    out.addEventListener("click", function () {
      sessionStorage.removeItem("aurefold_mod_token");
      token = null;
      renderLogin();
    });
    bar.appendChild(el("h1", "mod-heading", "Community moderation"));
    bar.appendChild(out);
    root.appendChild(bar);
    root.appendChild(el("p", "mod-hint",
      "Everything member-written starts as pending and is invisible to the public until approved. Featured pieces are highlighted; adopted pieces become part of the material around the book."));

    var sel = ",profiles(username)";
    Promise.all([
      api("/comments?status=in.(pending,approved)&select=id,context,body,status,created_at" + sel + "&order=created_at.asc&limit=200"),
      api("/fan_characters?select=id,name,house_key,concept,appearance,personality,status,author_note,created_at" + sel + "&order=created_at.desc&limit=200"),
      api("/fan_submissions?select=id,kind,title,body,link,status,author_note,created_at" + sel + "&order=created_at.desc&limit=200")
    ]).then(function (all) {
      root.appendChild(section("Comments", all[0], "comments", function (card, r) {
        card.appendChild(el("p", "mod-context", r.context));
        card.appendChild(el("p", "mod-body", r.body));
      }));
      root.appendChild(section("Fan characters", all[1], "fan_characters", function (card, r) {
        card.appendChild(el("p", "mod-body", r.name + (r.house_key ? " — " + r.house_key : " — unsworn")));
        card.appendChild(el("p", "mod-body", r.concept));
        if (r.appearance) card.appendChild(el("p", "mod-sub", r.appearance));
        if (r.personality) card.appendChild(el("p", "mod-sub", r.personality));
        if (r.author_note) card.appendChild(el("p", "mod-sub", "Author note: " + r.author_note));
      }));
      root.appendChild(section("Submissions", all[2], "fan_submissions", function (card, r) {
        card.appendChild(el("p", "mod-body", "[" + r.kind + "] " + r.title));
        if (r.body) card.appendChild(el("p", "mod-body mod-clamp", r.body));
        if (r.link) {
          var a = el("a", "scrip-link", r.link);
          a.href = r.link; a.target = "_blank"; a.rel = "noopener";
          card.appendChild(a);
        }
        if (r.author_note) card.appendChild(el("p", "mod-sub", "Author note: " + r.author_note));
      }));
    }).catch(function () {
      root.appendChild(el("p", "mod-empty", "Failed to load the queues — your session may have expired. Sign in again."));
    });
  }

  var saved = sessionStorage.getItem("aurefold_mod_token");
  if (saved && isStaff(saved)) { token = saved; renderDashboard(); }
  else renderLogin();

  function renderDashboard() { loadAll(); }
})();
