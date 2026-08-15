/* AUREFOLD — the Scriptorium: reader contributions.
   Stories, theories, art links, and questions for the author. Everything is
   'pending' until the archivist approves it; the author can feature a piece —
   or adopt it into the material around the book ('adopted'). Contributions
   shape the world AROUND the story: side-stories, extras, public lore. The
   central plot, canon, and character fates stay the author's. */
(function () {
  "use strict";

  var A = window.AurefoldAuth;
  var root = document.getElementById("scriptorium");
  if (!A || !root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      loading: "Opening the scriptorium…",
      empty: "No contributions on the shelves yet. The first quill could be yours.",
      failed: "The archive could not be reached. Try again in a moment.",
      createTitle: "Leave a contribution",
      createIntro: "A short story from the Banner-lands, a theory about the Bell, a piece of art, a question for the author. The archivist reads everything before it shows — the finest pieces are honoured, and the very finest are taken into the material.",
      kindLabel: "What is it?",
      kinds: { story: "A story", theory: "A theory", art: "Art (link)", question: "A question for the author" },
      titleLabel: "Title",
      titlePh: "Give it a name",
      bodyLabel: "The piece",
      bodyPh: "Write it here (max 5000 characters). For art, leave this empty and link it below.",
      linkLabel: "Link (optional — for art hosted elsewhere)",
      linkPh: "https://…",
      send: "Leave it with the archivist",
      sent: "Received. The archivist reads every contribution before it shows.",
      pendingBadge: "awaiting the archivist",
      featuredBadge: "honoured by the archivist",
      adoptedBadge: "taken into the material",
      leftBy: "left by",
      readLink: "See the piece",
      gateIntro: "Sign in to leave a contribution of your own.",
      needContent: "Give the piece a body, or a link."
    },
    sv: {
      loading: "Öppnar skriptoriet…",
      empty: "Inga bidrag på hyllorna ännu. Den första fjädern kan vara din.",
      failed: "Arkivet kunde inte nås. Försök igen om en stund.",
      createTitle: "Lämna ett bidrag",
      createIntro: "En novell från Fanlanden, en teori om Klockan, ett konstverk, en fråga till författaren. Arkivarien läser allt innan det syns — de finaste styckena hedras, och de allra finaste tas in i materialet.",
      kindLabel: "Vad är det?",
      kinds: { story: "En berättelse", theory: "En teori", art: "Konst (länk)", question: "En fråga till författaren" },
      titleLabel: "Titel",
      titlePh: "Ge det ett namn",
      bodyLabel: "Stycket",
      bodyPh: "Skriv det här (max 5000 tecken). För konst, lämna tomt och länka nedan.",
      linkLabel: "Länk (valfritt — för konst på annan plats)",
      linkPh: "https://…",
      send: "Lämna hos arkivarien",
      sent: "Mottaget. Arkivarien läser varje bidrag innan det syns.",
      pendingBadge: "väntar på arkivarien",
      featuredBadge: "hedrat av arkivarien",
      adoptedBadge: "upptaget i materialet",
      leftBy: "lämnat av",
      readLink: "Se stycket",
      gateIntro: "Logga in för att lämna ett eget bidrag.",
      needContent: "Ge stycket en text, eller en länk."
    }
  };
  function t(key) {
    var v = (TX[LANG] && TX[LANG][key]) || TX.en[key];
    return v == null ? key : v;
  }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function statusBadge(status) {
    if (status === "featured") return t("featuredBadge");
    if (status === "adopted") return t("adoptedBadge");
    if (status === "pending") return t("pendingBadge");
    return null;
  }

  function renderCard(s) {
    var card = el("article", "banner-card scrip-card status-" + s.status);
    var head = el("div", "banner-card-head");
    head.appendChild(el("h3", "banner-card-name", s.title));
    head.appendChild(el("p", "banner-card-house", t("kinds")[s.kind] || s.kind));
    card.appendChild(head);

    if (s.body) card.appendChild(el("p", "banner-card-concept scrip-body", s.body));
    if (s.link) {
      var a = el("a", "scrip-link", t("readLink"));
      a.href = s.link;
      a.target = "_blank";
      a.rel = "noopener";
      card.appendChild(a);
    }

    var badge = statusBadge(s.status);
    if (badge) card.appendChild(el("p", "banner-card-badge", badge));
    if (s.status === "adopted" && s.author_note) {
      card.appendChild(el("p", "banner-card-note", s.author_note));
    }

    card.appendChild(el("p", "banner-card-byline",
      t("leftBy") + " " + ((s.profiles && s.profiles.username) || "reader")));
    return card;
  }

  var gallery = el("div", "banner-gallery");
  var formBox = el("div", "banner-formbox");
  root.innerHTML = "";
  root.appendChild(gallery);
  root.appendChild(formBox);

  function load() {
    gallery.innerHTML = "";
    gallery.appendChild(el("p", "moot-note", t("loading")));
    var filter = A.user()
      ? "or=(status.in.(approved,featured,adopted),and(status.eq.pending,user_id.eq." + A.user().id + "))"
      : "status=in.(approved,featured,adopted)";
    return A.api("/fan_submissions?" + filter +
      "&select=id,kind,title,body,link,status,author_note,created_at,profiles(username)" +
      "&order=created_at.desc")
      .then(function (rows) {
        gallery.innerHTML = "";
        if (!rows.length) { gallery.appendChild(el("p", "comment-empty", t("empty"))); return; }
        rows.forEach(function (s) { gallery.appendChild(renderCard(s)); });
      })
      .catch(function () {
        gallery.innerHTML = "";
        gallery.appendChild(el("p", "comment-empty", t("failed")));
      });
  }

  function field(label, input) {
    var wrap = el("label", "auth-field");
    wrap.appendChild(el("span", "auth-field-label", label));
    wrap.appendChild(input);
    return wrap;
  }

  function renderForm() {
    formBox.innerHTML = "";
    if (!A.user()) {
      A.renderGate(formBox, { intro: t("gateIntro") });
      return;
    }
    var card = el("div", "auth-gate banner-create");
    card.appendChild(el("h3", "auth-gate-title", t("createTitle")));
    card.appendChild(el("p", "auth-gate-body", t("createIntro")));

    var form = el("form", "auth-gate-form banner-form");

    var kind = el("select", "auth-input");
    ["story", "theory", "art", "question"].forEach(function (k) {
      kind.appendChild(new Option(t("kinds")[k], k));
    });

    var title = el("input", "auth-input");
    title.maxLength = 120; title.required = true; title.placeholder = t("titlePh");

    var body = el("textarea", "auth-input");
    body.rows = 6; body.maxLength = 5000; body.placeholder = t("bodyPh");

    var link = el("input", "auth-input");
    link.type = "url"; link.placeholder = t("linkPh");

    form.appendChild(field(t("kindLabel"), kind));
    form.appendChild(field(t("titleLabel"), title));
    form.appendChild(field(t("bodyLabel"), body));
    form.appendChild(field(t("linkLabel"), link));

    var btn = el("button", "btn btn-primary", t("send"));
    btn.type = "submit";
    form.appendChild(btn);

    var status = el("p", "auth-gate-status");
    status.setAttribute("role", "status");

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      if (!body.value.trim() && !link.value.trim()) { status.textContent = t("needContent"); return; }
      btn.disabled = true;
      A.api("/fan_submissions", {
        method: "POST",
        body: {
          kind: kind.value,
          title: title.value.trim(),
          body: body.value.trim() || null,
          link: link.value.trim() || null
        },
        prefer: "return=minimal"
      }).then(function () {
        form.reset();
        btn.disabled = false;
        status.textContent = t("sent");
        load();
      }).catch(function () {
        btn.disabled = false;
        status.textContent = t("failed");
      });
    });

    card.appendChild(form);
    card.appendChild(status);
    formBox.appendChild(card);
  }

  A.ready.then(function () { load(); renderForm(); });
  A.onChange(function () { load(); renderForm(); });
})();
