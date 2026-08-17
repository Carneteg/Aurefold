/* AUREFOLD — the discussion. Embeddable comment section for any page:
     <section class="comments" data-comments data-context="page:read"
              data-title="The discussion"></section>
     <script src="assets/auth.js"></script>
     <script src="assets/comments.js"></script>

   Moderation model: a posted comment is 'pending' and only visible to its
   author until staff approves it. Approved comments are public. Replies
   (parent_id) are supported by the schema; the UI keeps one flat,
   chronological thread per context for now. */
(function () {
  "use strict";

  var A = window.AurefoldAuth;
  if (!A) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      gateTitle: "Sign in to join the discussion",
      title: "The discussion",
      empty: "No voices here yet. Yours could be the first — once the archivist has seen it.",
      placeholder: "Speak plainly — what did this stir in you?",
      send: "Send to the archivist",
      pendingNote: "Your voice is with the archivist. It appears here once approved.",
      pendingBadge: "awaiting the archivist",
      gateIntro: "Sign in to join the discussion. New voices are read by the archivist before they show.",
      failed: "The archive could not be reached. Try again in a moment.",
      tryAgain: "Try again",
      tooLong: "Keep it under 2000 characters — the archive values brevity.",
      houseWord: "of House "
    },
    sv: {
      gateTitle: "Logga in för att delta i samtalet",
      title: "Diskussionen",
      empty: "Inga röster här ännu. Din kan bli den första — när arkivarien har sett den.",
      placeholder: "Tala klart — vad väckte det här i dig?",
      send: "Skicka till arkivarien",
      pendingNote: "Din röst är hos arkivarien. Den syns här när den godkänts.",
      pendingBadge: "väntar på arkivarien",
      gateIntro: "Logga in för att delta i diskussionen. Nya röster läses av arkivarien innan de syns.",
      failed: "Arkivet kunde inte nås. Försök igen om en stund.",
      tryAgain: "Försök igen",
      tooLong: "Håll det under 2000 tecken — arkivet värdesätter korthet.",
      houseWord: "av huset "
    },
  };
  function t(key) { return (TX[LANG] && TX[LANG][key]) || TX.en[key] || key; }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function esc(s) { return String(s == null ? "" : s); }

  function fmtDate(iso) {
    try {
      return new Date(iso).toLocaleDateString(document.documentElement.lang || "en", { year: "numeric", month: "short", day: "numeric" });
    } catch (e) { return ""; }
  }

  function houseLabel(key) {
    if (!key) return "";
    var houses = window.AUREFOLD_HOUSES || [];
    for (var i = 0; i < houses.length; i++) {
      if ((houses[i].id || "") === key) return t("houseWord") + String(houses[i].name || key).replace(/^House\s+/i, "");
    }
    return t("houseWord") + key.charAt(0).toUpperCase() + key.slice(1);
  }

  function mount(section) {
    var context = section.getAttribute("data-context");
    if (!context) return;
    section.classList.add("comments");
    section.innerHTML = "";
    section.appendChild(el("h2", "section-title", section.getAttribute("data-title") || t("title")));

    var list = el("div", "comment-list");
    var formBox = el("div", "comment-formbox");
    var note = el("p", "moot-note");
    note.setAttribute("role", "status");
    section.appendChild(list);
    section.appendChild(formBox);
    section.appendChild(note);

    function renderComments(rows) {
      list.innerHTML = "";
      if (!rows.length) {
        list.appendChild(el("p", "comment-empty", t("empty")));
        return;
      }
      rows.forEach(function (c) {
        var item = el("article", "comment" + (c.status === "pending" ? " is-pending" : ""));
        var head = el("p", "comment-head");
        var who = (c.profiles && c.profiles.username) || "reader";
        head.appendChild(el("span", "comment-author", who));
        var house = c.profiles && c.profiles.house_key;
        if (house) head.appendChild(el("span", "comment-house", houseLabel(house)));
        head.appendChild(el("time", "comment-date", fmtDate(c.created_at)));
        item.appendChild(head);
        item.appendChild(el("p", "comment-body", esc(c.body)));
        if (c.status === "pending") item.appendChild(el("p", "comment-pending", t("pendingBadge")));
        list.appendChild(item);
      });
    }

    function load() {
      // Own pending comments are visible to their author (RLS), so a member
      // sees their voice waiting; everyone else sees only approved ones.
      var filter = A.user()
        ? "or=(status.eq.approved,and(status.eq.pending,user_id.eq." + A.user().id + "))"
        : "status=eq.approved";
      return A.api("/comments?context=eq." + encodeURIComponent(context) +
        "&" + filter +
        "&select=id,body,status,created_at,profiles(username,house_key)&order=created_at.asc")
        .then(renderComments)
        .catch(function () {
          list.innerHTML = "";
          var err = el("p", "comment-error", t("failed") + " ");
          var retry = el("button", "linklike comment-retry", t("tryAgain"));
          retry.type = "button";
          retry.addEventListener("click", load);
          err.appendChild(retry);
          list.appendChild(err);
        });
    }

    function renderForm() {
      formBox.innerHTML = "";
      if (!A.user()) {
        A.renderGate(formBox, { title: t("gateTitle"), intro: t("gateIntro") });
        return;
      }
      var form = el("form", "comment-form");
      var area = el("textarea", "auth-input comment-input");
      area.maxLength = 2000;
      area.rows = 4;
      area.placeholder = t("placeholder");
      area.required = true;
      var btn = el("button", "btn btn-primary", t("send"));
      btn.type = "submit";
      form.appendChild(area);
      form.appendChild(btn);
      formBox.appendChild(form);

      form.addEventListener("submit", function (ev) {
        ev.preventDefault();
        var body = area.value.trim();
        if (!body) return;
        if (body.length > 2000) { note.textContent = t("tooLong"); return; }
        btn.disabled = true;
        A.api("/comments", {
          method: "POST",
          body: { context: context, body: body },
          prefer: "return=minimal"
        }).then(function () {
          area.value = "";
          note.textContent = t("pendingNote");
          btn.disabled = false;
          load();
        }).catch(function () {
          note.textContent = t("failed");
          btn.disabled = false;
        });
      });
    }

    A.ready.then(load);
    A.ready.then(renderForm);
    A.onChange(function () { load(); renderForm(); });
  }

  function boot() {
    var sections = document.querySelectorAll("[data-comments]");
    Array.prototype.forEach.call(sections, mount);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
