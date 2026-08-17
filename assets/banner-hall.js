/* AUREFOLD — the Banner Hall: reader-sworn characters.
   Readers create a character sworn to one of the ten banners (or none).
   Every character waits for the archivist (status 'pending') before it shows
   publicly; the author can feature it — or adopt it into the material around
   the book ('adopted', with an author note). Characters never alter canon;
   the Banner Hall lives around the story, not inside it. */
(function () {
  "use strict";

  var A = window.AurefoldAuth;
  var root = document.getElementById("banner-hall");
  if (!A || !root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      loading: "Opening the hall…",
      empty: "The hall stands empty — no reader-sworn characters yet. Yours could be the first to raise a banner.",
      failed: "The archive could not be reached. Try again in a moment.",
      tryAgain: "Try again",
      createTitle: "Raise your banner",
      createIntro: "Shape a character of the Banner-lands: a soldier, a scribe, a smuggler of secrets. They live in the world around the book — the archivist reads every one before it shows.",
      nameLabel: "Name",
      namePh: "What are they called?",
      houseLabel: "Their banner",
      houseNone: "Unsworn — no house",
      conceptLabel: "Who they are",
      conceptPh: "A soldier who reads too much. A tollkeeper who never forgets a face. (required, max 600)",
      appearanceLabel: "How they look (optional)",
      appearancePh: "Grey at the temples, a limp from the war… (max 600)",
      personalityLabel: "How they carry themselves (optional)",
      personalityPh: "Slow to anger, quicker to laugh… (max 600)",
      send: "Swear them in",
      sent: "Your character is with the archivist. They appear in the hall once approved.",
      pendingBadge: "awaiting the archivist",
      featuredBadge: "honoured by the archivist",
      adoptedBadge: "taken into the material",
      swornBy: "sworn by",
      unsworn: "unsworn",
      gateIntro: "Sign in to raise a character of your own.",
      conceptRequired: "Give them at least a line of who they are."
    },
    sv: {
      loading: "Öppnar hallen…",
      empty: "Hallen står tom — inga läsarsvurna karaktärer ännu. Din kan bli den första att resa ett baner.",
      failed: "Arkivet kunde inte nås. Försök igen om en stund.",
      tryAgain: "Försök igen",
      createTitle: "Res ditt baner",
      createIntro: "Forma en karaktär i Fanlanden: en soldat, en skrivare, en hemlighetssmugglare. De lever i världen runt boken — arkivarien läser var och en innan den syns.",
      nameLabel: "Namn",
      namePh: "Vad kallas de?",
      houseLabel: "Deras baner",
      houseNone: "Osvuren — inget hus",
      conceptLabel: "Vem de är",
      conceptPh: "En soldat som läser för mycket. En tullvaktare som aldrig glömmer ett ansikte. (krävs, max 600)",
      appearanceLabel: "Hur de ser ut (valfritt)",
      appearancePh: "Grå vid tinningarna, haltar sedan kriget… (max 600)",
      personalityLabel: "Hur de bär sig åt (valfritt)",
      personalityPh: "Sen till vrede, snabb till skratt… (max 600)",
      send: "Svär in dem",
      sent: "Din karaktär är hos arkivarien. Den syns i hallen när den godkänts.",
      pendingBadge: "väntar på arkivarien",
      featuredBadge: "hedrad av arkivarien",
      adoptedBadge: "upptagen i materialet",
      swornBy: "svuren av",
      unsworn: "osvuren",
      gateIntro: "Logga in för att resa en egen karaktär.",
      conceptRequired: "Ge dem åtminstone en rad om vem de är."
    }
  };
  function t(key) { return (TX[LANG] && TX[LANG][key]) || TX.en[key] || key; }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function houseName(key) {
    var houses = window.AUREFOLD_HOUSES || [];
    for (var i = 0; i < houses.length; i++) {
      if (houses[i].id === key) return houses[i].name;
    }
    return null;
  }

  function statusBadge(status) {
    if (status === "featured") return t("featuredBadge");
    if (status === "adopted") return t("adoptedBadge");
    if (status === "pending") return t("pendingBadge");
    return null;
  }

  function renderCard(c) {
    var card = el("article", "banner-card status-" + c.status);
    var head = el("div", "banner-card-head");
    head.appendChild(el("h3", "banner-card-name", c.name));
    var banner = c.house_key && houseName(c.house_key);
    head.appendChild(el("p", "banner-card-house", banner || t("unsworn")));
    card.appendChild(head);

    card.appendChild(el("p", "banner-card-concept", c.concept));
    if (c.appearance) card.appendChild(el("p", "banner-card-extra", c.appearance));
    if (c.personality) card.appendChild(el("p", "banner-card-extra", c.personality));

    var badge = statusBadge(c.status);
    if (badge) card.appendChild(el("p", "banner-card-badge", badge));
    if (c.status === "adopted" && c.author_note) {
      card.appendChild(el("p", "banner-card-note", c.author_note));
    }

    var by = el("p", "banner-card-byline");
    by.textContent = t("swornBy") + " " + ((c.profiles && c.profiles.username) || "reader");
    card.appendChild(by);
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
    return A.api("/fan_characters?" + filter +
      "&select=id,name,house_key,concept,appearance,personality,status,author_note,created_at,profiles(username)" +
      "&order=created_at.desc")
      .then(function (rows) {
        gallery.innerHTML = "";
        if (!rows.length) { gallery.appendChild(el("p", "comment-empty", t("empty"))); return; }
        rows.forEach(function (c) { gallery.appendChild(renderCard(c)); });
      })
      .catch(function () {
        gallery.innerHTML = "";
        var err = el("p", "comment-error", t("failed") + " ");
        var retry = el("button", "linklike comment-retry", t("tryAgain"));
        retry.type = "button";
        retry.addEventListener("click", load);
        err.appendChild(retry);
        gallery.appendChild(err);
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

    var name = el("input", "auth-input");
    name.maxLength = 60; name.required = true; name.placeholder = t("namePh");

    var house = el("select", "auth-input");
    house.appendChild(new Option(t("houseNone"), ""));
    (window.AUREFOLD_HOUSES || []).forEach(function (h) { house.appendChild(new Option(h.name, h.id)); });

    var concept = el("textarea", "auth-input");
    concept.rows = 3; concept.maxLength = 600; concept.required = true; concept.placeholder = t("conceptPh");

    var appearance = el("textarea", "auth-input");
    appearance.rows = 2; appearance.maxLength = 600; appearance.placeholder = t("appearancePh");

    var personality = el("textarea", "auth-input");
    personality.rows = 2; personality.maxLength = 600; personality.placeholder = t("personalityPh");

    form.appendChild(field(t("nameLabel"), name));
    form.appendChild(field(t("houseLabel"), house));
    form.appendChild(field(t("conceptLabel"), concept));
    form.appendChild(field(t("appearanceLabel"), appearance));
    form.appendChild(field(t("personalityLabel"), personality));

    var btn = el("button", "btn btn-primary", t("send"));
    btn.type = "submit";
    form.appendChild(btn);

    var status = el("p", "auth-gate-status");
    status.setAttribute("role", "status");

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      if (!concept.value.trim()) { status.textContent = t("conceptRequired"); return; }
      btn.disabled = true;
      A.api("/fan_characters", {
        method: "POST",
        body: {
          name: name.value.trim(),
          house_key: house.value || null,
          concept: concept.value.trim(),
          appearance: appearance.value.trim() || null,
          personality: personality.value.trim() || null
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
