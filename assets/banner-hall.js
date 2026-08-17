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
      gateTitle: "Sign in to raise a character",
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
      gateTitle: "Logga in för att resa en karaktär",
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
    },
    es: {
      gateTitle: "Inicia sesión para alzar un personaje",
      loading: "Abriendo la Sala…",
      empty: "La Sala está vacía — aún no hay personajes jurados por lectores. El tuyo podría ser el primero en alzar un estandarte.",
      failed: "No se pudo contactar con el archivo. Inténtalo de nuevo en un momento.",
      tryAgain: "Inténtalo de nuevo",
      createTitle: "Alza tu estandarte",
      createIntro: "Da forma a un personaje de las tierras del Estandarte: un soldado, un escriba, un contrabandista de secretos. Viven en el mundo que rodea al libro — el archivista lee cada uno antes de mostrarlo.",
      nameLabel: "Nombre",
      namePh: "¿Cómo se llaman?",
      houseLabel: "Su estandarte",
      houseNone: "Sin jurar — sin casa",
      conceptLabel: "Quiénes son",
      conceptPh: "Un soldado que lee demasiado. Un portazguero que nunca olvida un rostro. (obligatorio, máx. 600)",
      appearanceLabel: "Cómo son (opcional)",
      appearancePh: "Canas en las sienes, una cojera desde la guerra… (máx. 600)",
      personalityLabel: "Cómo se comportan (opcional)",
      personalityPh: "Lentos para la ira, rápidos para la risa… (máx. 600)",
      send: "Júralos",
      sent: "Tu personaje está con el archivista. Aparecerá en la Sala una vez aprobado.",
      pendingBadge: "a la espera del archivista",
      featuredBadge: "honrado por el archivista",
      adoptedBadge: "incorporado al material",
      swornBy: "jurado por",
      unsworn: "sin jurar",
      gateIntro: "Inicia sesión para alzar un personaje propio.",
      conceptRequired: "Dales al menos una línea de quiénes son."
    },
    fr: {
      gateTitle: "Connectez-vous pour dresser un personnage",
      loading: "Ouverture de la Salle…",
      empty: "La Salle se dresse vide — aucun personnage juré par un lecteur pour l’instant. Le vôtre pourrait être le premier à lever une bannière.",
      failed: "Impossible de joindre l’archive. Réessayez dans un instant.",
      tryAgain: "Réessayer",
      createTitle: "Levez votre bannière",
      createIntro: "Façonnez un personnage des terres de la Bannière : un soldat, un scribe, un contrebandier de secrets. Ils vivent dans le monde autour du livre — l’archiviste lit chacun avant qu’il ne s’affiche.",
      nameLabel: "Nom",
      namePh: "Comment s’appellent-ils ?",
      houseLabel: "Leur bannière",
      houseNone: "Sans serment — sans maison",
      conceptLabel: "Qui ils sont",
      conceptPh: "Un soldat qui lit trop. Un péager qui n’oublie jamais un visage. (requis, max 600)",
      appearanceLabel: "À quoi ils ressemblent (facultatif)",
      appearancePh: "Des tempes grisonnantes, une claudication depuis la guerre… (max 600)",
      personalityLabel: "Comment ils se comportent (facultatif)",
      personalityPh: "Lents à la colère, prompts au rire… (max 600)",
      send: "Faites-leur prêter serment",
      sent: "Votre personnage est avec l’archiviste. Il apparaîtra dans la Salle une fois approuvé.",
      pendingBadge: "en attente de l’archiviste",
      featuredBadge: "honoré par l’archiviste",
      adoptedBadge: "intégré à la matière",
      swornBy: "juré par",
      unsworn: "sans serment",
      gateIntro: "Connectez-vous pour lever un personnage bien à vous.",
      conceptRequired: "Donnez-leur au moins une ligne sur qui ils sont."
    },
    zh: {
      gateTitle: "登录以创建角色",
      loading: "正在打开大厅…",
      empty: "大厅空无一人——尚无读者宣誓创建的角色。你的角色也许会是第一个举起旗帜的人。",
      failed: "无法连接到档案。请稍后再试。",
      tryAgain: "重试",
      createTitle: "举起你的旗帜",
      createIntro: "塑造一个来自旗帜之地的角色：士兵、书记，或秘密的走私者。他们生活在这本书周围的世界中——档案员会在每一位角色显示之前先阅读。",
      nameLabel: "姓名",
      namePh: "他们叫什么名字？",
      houseLabel: "他们的旗帜",
      houseNone: "未宣誓——无家族",
      conceptLabel: "他们是谁",
      conceptPh: "一个读书太多的士兵。一个从不忘记面孔的收税人。（必填，最多 600 字）",
      appearanceLabel: "他们的外貌（可选）",
      appearancePh: "鬓角已灰白，因战争留下跛行…（最多 600 字）",
      personalityLabel: "他们待人接物的方式（可选）",
      personalityPh: "不轻易动怒，笑得却很快…（最多 600 字）",
      send: "宣誓让他们加入",
      sent: "你的角色已交给档案员。一旦获批，就会出现在大厅中。",
      pendingBadge: "等待档案员",
      featuredBadge: "获档案员嘉许",
      adoptedBadge: "被收录进素材",
      swornBy: "宣誓者",
      unsworn: "未宣誓",
      gateIntro: "登录以举起属于你自己的旗帜角色。",
      conceptRequired: "请至少写一行说明他们是谁。"
    },
    ja: {
      gateTitle: "サインインしてキャラクターを立てる",
      loading: "広間を開いています…",
      empty: "広間はまだ空だ——読者が誓いを立てたキャラクターはまだいない。最初に旗印を掲げるのはあなたかもしれない。",
      failed: "記録に接続できませんでした。しばらくしてからもう一度お試しください。",
      tryAgain: "もう一度試す",
      createTitle: "旗印を掲げる",
      createIntro: "旗の地のキャラクターを形づくろう：兵士、書記、秘密を運ぶ密輸人。彼らはこの本を取り巻く世界に生きている——記録官は表示される前にひとりひとりを読む。",
      nameLabel: "名前",
      namePh: "何と呼ばれていますか？",
      houseLabel: "彼らの旗印",
      houseNone: "未誓約——家門なし",
      conceptLabel: "彼らが何者か",
      conceptPh: "本を読みすぎる兵士。決して顔を忘れない関守。（必須、最大600文字）",
      appearanceLabel: "外見（任意）",
      appearancePh: "こめかみに白いものが混じり、戦争以来足を引きずっている…（最大600文字）",
      personalityLabel: "振る舞い方（任意）",
      personalityPh: "怒るのは遅く、笑うのは早い…（最大600文字）",
      send: "誓いを立てさせる",
      sent: "あなたのキャラクターは記録官のもとにある。承認されれば広間に現れる。",
      pendingBadge: "記録官待ち",
      featuredBadge: "記録官に称えられた",
      adoptedBadge: "素材に組み込まれた",
      swornBy: "誓いを立てた者",
      unsworn: "未誓約",
      gateIntro: "サインインして、あなた自身のキャラクターに旗印を掲げさせよう。",
      conceptRequired: "彼らが何者か、少なくとも一行は書いてください。"
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
      A.renderGate(formBox, { title: t("gateTitle"), intro: t("gateIntro") });
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
