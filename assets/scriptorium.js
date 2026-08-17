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
      tryAgain: "Try again",
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
      tryAgain: "Försök igen",
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
    },
    es: {
      loading: "Abriendo el Scriptorium…",
      empty: "Aún no hay contribuciones en los estantes. La primera pluma podría ser la tuya.",
      failed: "No se pudo contactar con el archivo. Inténtalo de nuevo en un momento.",
      tryAgain: "Inténtalo de nuevo",
      createTitle: "Deja una contribución",
      createIntro: "Un relato de las tierras del Estandarte, una teoría sobre la Campana, una obra de arte, una pregunta para el autor. El archivista lee todo antes de mostrarlo — las piezas más logradas son honradas, y las mejores de todas se incorporan al material.",
      kindLabel: "¿Qué es?",
      kinds: { story: "Un relato", theory: "Una teoría", art: "Arte (enlace)", question: "Una pregunta para el autor" },
      titleLabel: "Título",
      titlePh: "Dale un nombre",
      bodyLabel: "La pieza",
      bodyPh: "Escríbelo aquí (máx. 5000 caracteres). Para arte, déjalo vacío y enlázalo abajo.",
      linkLabel: "Enlace (opcional — para arte alojado en otro lugar)",
      linkPh: "https://…",
      send: "Déjalo con el archivista",
      sent: "Recibido. El archivista lee cada contribución antes de mostrarla.",
      pendingBadge: "a la espera del archivista",
      featuredBadge: "honrado por el archivista",
      adoptedBadge: "incorporado al material",
      leftBy: "dejado por",
      readLink: "Ver la pieza",
      gateIntro: "Inicia sesión para dejar tu propia contribución.",
      needContent: "Dale a la pieza un texto, o un enlace."
    },
    fr: {
      loading: "Ouverture du Scriptorium…",
      empty: "Aucune contribution sur les étagères pour l’instant. La première plume pourrait être la vôtre.",
      failed: "Impossible de joindre l’archive. Réessayez dans un instant.",
      tryAgain: "Réessayer",
      createTitle: "Déposez une contribution",
      createIntro: "Un récit des terres de la Bannière, une théorie sur la Cloche, une œuvre d’art, une question pour l’auteur. L’archiviste lit tout avant que cela ne s’affiche — les plus belles pièces sont honorées, et les toutes meilleures sont intégrées à la matière.",
      kindLabel: "Qu’est-ce que c’est ?",
      kinds: { story: "Un récit", theory: "Une théorie", art: "Art (lien)", question: "Une question pour l’auteur" },
      titleLabel: "Titre",
      titlePh: "Donnez-lui un nom",
      bodyLabel: "La pièce",
      bodyPh: "Écrivez-le ici (max 5000 caractères). Pour l’art, laissez ce champ vide et mettez le lien ci-dessous.",
      linkLabel: "Lien (facultatif — pour l’art hébergé ailleurs)",
      linkPh: "https://…",
      send: "Laissez-le à l’archiviste",
      sent: "Reçu. L’archiviste lit chaque contribution avant qu’elle ne s’affiche.",
      pendingBadge: "en attente de l’archiviste",
      featuredBadge: "honoré par l’archiviste",
      adoptedBadge: "intégré à la matière",
      leftBy: "déposé par",
      readLink: "Voir la pièce",
      gateIntro: "Connectez-vous pour déposer votre propre contribution.",
      needContent: "Donnez à la pièce un texte, ou un lien."
    },
    zh: {
      loading: "正在打开缮写室…",
      empty: "书架上还没有投稿。第一支笔或许就是你的。",
      failed: "无法连接到档案。请稍后再试。",
      tryAgain: "重试",
      createTitle: "留下一份投稿",
      createIntro: "一个来自旗帜之地的故事，一个关于钟的猜想，一件艺术作品，一个写给作者的问题。档案员会在一切显示之前先阅读——最出色的作品会获得表彰，而最杰出的那些会被收录进素材。",
      kindLabel: "这是什么？",
      kinds: { story: "故事", theory: "理论", art: "艺术作品（链接）", question: "写给作者的问题" },
      titleLabel: "标题",
      titlePh: "给它起个名字",
      bodyLabel: "内容",
      bodyPh: "在此处书写（最多 5000 字）。若是艺术作品，请留空并在下方附上链接。",
      linkLabel: "链接（可选——用于托管在别处的艺术作品）",
      linkPh: "https://…",
      send: "留给档案员",
      sent: "已收到。档案员会在每篇投稿显示之前先阅读。",
      pendingBadge: "等待档案员",
      featuredBadge: "获档案员嘉许",
      adoptedBadge: "被收录进素材",
      leftBy: "投稿者",
      readLink: "查看作品",
      gateIntro: "登录以留下你自己的投稿。",
      needContent: "请为作品填写正文，或提供链接。"
    },
    ja: {
      loading: "写字室を開いています…",
      empty: "棚にはまだ投稿がない。最初の筆はあなたのものかもしれない。",
      failed: "記録に接続できませんでした。しばらくしてからもう一度お試しください。",
      tryAgain: "もう一度試す",
      createTitle: "投稿を残す",
      createIntro: "旗の地の物語、鐘についての考察、アート作品、作者への質問。記録官はすべてを表示前に読む——最も優れた作品は称えられ、その中でも最高のものは素材に組み込まれる。",
      kindLabel: "これは何ですか？",
      kinds: { story: "物語", theory: "考察", art: "アート（リンク）", question: "作者への質問" },
      titleLabel: "タイトル",
      titlePh: "名前をつけてください",
      bodyLabel: "本文",
      bodyPh: "ここに書いてください（最大5000文字）。アートの場合はここを空欄にし、下にリンクを貼ってください。",
      linkLabel: "リンク（任意——他所に置かれたアート用）",
      linkPh: "https://…",
      send: "記録官に託す",
      sent: "受け取った。記録官はすべての投稿を表示前に読む。",
      pendingBadge: "記録官待ち",
      featuredBadge: "記録官に称えられた",
      adoptedBadge: "素材に組み込まれた",
      leftBy: "投稿者",
      readLink: "作品を見る",
      gateIntro: "サインインして、あなた自身の投稿を残してください。",
      needContent: "作品に本文かリンクを入れてください。"
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
