/* AUREFOLD — the Banner (community hub): sign-in, reader profile with house
   allegiance, and live counts of the sworn company. The three doors (Moot,
   Banner Hall, Scriptorium) are static links in the page; this module handles
   the profile card and the numbers. */
(function () {
  "use strict";

  var A = window.AurefoldAuth;
  var profileBox = document.getElementById("banner-profile");
  var statsBox = document.getElementById("banner-stats");
  if (!A || !profileBox) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      welcome: "Well met",
      gateIntro: "Swear in to vote in the Moot's great questions, raise a character in the Banner Hall, and leave work in the Scriptorium.",
      usernameLabel: "The name you go by",
      usernamePh: "2–24 letters, spaces, dashes",
      houseLabel: "Your allegiance",
      houseNone: "No banner yet — the quiz can help you choose",
      save: "Swear it",
      saved: "Recorded. The archive remembers.",
      saveFailed: "That name is taken, or the archive stumbled. Try another.",
      signOut: "Sign out",
      members: function (n) { return n + (n === 1 ? " sworn reader" : " sworn readers"); },
      characters: function (n) { return n + (n === 1 ? " character in the Hall" : " characters in the Hall"); },
      pieces: function (n) { return n + (n === 1 ? " piece in the Scriptorium" : " pieces in the Scriptorium"); },
      yourPending: "Your voices waiting on the archivist: ",
      pendingNone: "none"
    },
    sv: {
      welcome: "Väl mött",
      gateIntro: "Svär in dig för att rösta i Tingets stora frågor, resa en karaktär i Banerhallen och lämna verk i Skriptoriet.",
      usernameLabel: "Namnet du går under",
      usernamePh: "2–24 bokstäver, mellanslag, bindestreck",
      houseLabel: "Din trohet",
      houseNone: "Inget baner ännu — testet kan hjälpa dig välja",
      save: "Svär det",
      saved: "Antecknat. Arkivet minns.",
      saveFailed: "Det namnet är taget, eller arkivet snubblade. Försök med ett annat.",
      signOut: "Logga ut",
      members: function (n) { return n + (n === 1 ? " svuren läsare" : " svurna läsare"); },
      characters: function (n) { return n + (n === 1 ? " karaktär i Hallen" : " karaktärer i Hallen"); },
      pieces: function (n) { return n + (n === 1 ? " verk i Skriptoriet" : " verk i Skriptoriet"); },
      yourPending: "Dina röster som väntar på arkivarien: ",
      pendingNone: "inga"
    },
    es: {
      welcome: "Bien hallado",
      gateIntro: "Júrate para votar en las grandes cuestiones de El Cónclave, alzar un personaje en la Sala de los Estandartes y dejar tu obra en el Scriptorium.",
      usernameLabel: "El nombre por el que te conocen",
      usernamePh: "2–24 letras, espacios, guiones",
      houseLabel: "Tu lealtad",
      houseNone: "Aún sin estandarte — el test puede ayudarte a elegir",
      save: "Júralo",
      saved: "Anotado. El archivo recuerda.",
      saveFailed: "Ese nombre ya está tomado, o el archivo tropezó. Prueba con otro.",
      signOut: "Cerrar sesión",
      members: function (n) { return n === 1 ? n + " lector jurado" : n + " lectores jurados"; },
      characters: function (n) { return n === 1 ? n + " personaje en la Sala" : n + " personajes en la Sala"; },
      pieces: function (n) { return n === 1 ? n + " pieza en el Scriptorium" : n + " piezas en el Scriptorium"; },
      yourPending: "Tus voces a la espera del archivista: ",
      pendingNone: "ninguna"
    },
    fr: {
      welcome: "Bien trouvé",
      gateIntro: "Prêtez serment pour voter aux grandes questions du Conseil, élever un personnage dans la Salle des Bannières et déposer une œuvre au Scriptorium.",
      usernameLabel: "Le nom sous lequel vous êtes connu",
      usernamePh: "2 à 24 lettres, espaces, tirets",
      houseLabel: "Votre allégeance",
      houseNone: "Pas encore de bannière — le test peut vous aider à choisir",
      save: "Jurez-le",
      saved: "Noté. L’archive s’en souvient.",
      saveFailed: "Ce nom est déjà pris, ou l’archive a trébuché. Essayez-en un autre.",
      signOut: "Se déconnecter",
      members: function (n) { return n === 1 ? n + " lecteur juré" : n + " lecteurs jurés"; },
      characters: function (n) { return n === 1 ? n + " personnage dans la Salle" : n + " personnages dans la Salle"; },
      pieces: function (n) { return n === 1 ? n + " pièce au Scriptorium" : n + " pièces au Scriptorium"; },
      yourPending: "Vos voix en attente de l’archiviste : ",
      pendingNone: "aucune"
    },
    zh: {
      welcome: "幸会",
      gateIntro: "宣誓加入，即可在议会的重大议题上投票、在旗帜大厅创建角色，并在缮写室留下作品。",
      usernameLabel: "你惯用的名字",
      usernamePh: "2–24 个字母、空格、连字符",
      houseLabel: "你的效忠",
      houseNone: "尚未选定旗帜——测验可以帮你决定",
      save: "宣誓",
      saved: "已记录。档案会记得。",
      saveFailed: "这个名字已被使用，或者档案打了个趔趄。请换一个试试。",
      signOut: "退出登录",
      members: function (n) { return n + " 位宣誓读者"; },
      characters: function (n) { return "大厅中有 " + n + " 位角色"; },
      pieces: function (n) { return "缮写室中有 " + n + " 篇作品"; },
      yourPending: "你等待档案员审核的声音：",
      pendingNone: "无"
    },
    ja: {
      welcome: "よくぞ会えた",
      gateIntro: "誓いを立てれば、合議の重大な議題に投票し、旗印の広間でキャラクターを立て、写字室に作品を残せます。",
      usernameLabel: "名乗る名前",
      usernamePh: "2〜24字（英字・スペース・ハイフン）",
      houseLabel: "あなたの忠誠",
      houseNone: "まだ旗印なし——テストが選ぶ手助けになる",
      save: "誓う",
      saved: "記録した。忘れはしない。",
      saveFailed: "その名前はすでに使われているか、記録がつまずいたようです。別の名前をお試しください。",
      signOut: "サインアウト",
      members: function (n) { return "誓いを立てた読者" + n + "人"; },
      characters: function (n) { return "広間のキャラクター" + n + "人"; },
      pieces: function (n) { return "写字室の作品" + n + "点"; },
      yourPending: "記録官の確認待ちのあなたの声：",
      pendingNone: "なし"
    }
  };
  function t(key) { var v = (TX[LANG] && TX[LANG][key]) || TX.en[key]; return v == null ? key : v; }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function countOf(path) {
    // Cheap exact counts via PostgREST's Content-Range header.
    return A.api(path + "&select=id", {}).then(function (rows) {
      return Array.isArray(rows) ? rows.length : 0;
    }).catch(function () { return null; });
  }

  function renderStats() {
    if (!statsBox) return;
    Promise.all([
      countOf("/profiles?"),
      countOf("/fan_characters?status=in.(approved,featured,adopted)"),
      countOf("/fan_submissions?status=in.(approved,featured,adopted)")
    ]).then(function (counts) {
      statsBox.innerHTML = "";
      var parts = [];
      if (counts[0] != null && counts[0] > 0) parts.push(t("members")(counts[0]));
      if (counts[1] != null && counts[1] > 0) parts.push(t("characters")(counts[1]));
      if (counts[2] != null && counts[2] > 0) parts.push(t("pieces")(counts[2]));
      if (!parts.length) return; // stay silent rather than show zeroes
      statsBox.appendChild(el("p", "banner-stats-line", parts.join(" · ")));
    });
  }

  function renderProfile() {
    profileBox.innerHTML = "";
    if (!A.user()) {
      A.renderGate(profileBox, { intro: t("gateIntro") });
      return;
    }
    A.profile().then(function (p) {
      profileBox.innerHTML = "";
      var card = el("div", "auth-gate banner-profile-card");
      card.appendChild(el("h3", "auth-gate-title", t("welcome") + ", " + (p ? p.username : "reader")));

      var form = el("form", "auth-gate-form banner-form");

      var uname = el("input", "auth-input");
      uname.maxLength = 24;
      uname.required = true;
      uname.pattern = "[A-Za-z0-9][A-Za-z0-9_ \\-]{1,23}";
      uname.placeholder = t("usernamePh");
      uname.value = p ? p.username : "";

      var house = el("select", "auth-input");
      house.appendChild(new Option(t("houseNone"), ""));
      (window.AUREFOLD_HOUSES || []).forEach(function (h) { house.appendChild(new Option(h.name, h.id)); });
      house.value = (p && p.house_key) || "";

      var wrap1 = el("label", "auth-field");
      wrap1.appendChild(el("span", "auth-field-label", t("usernameLabel")));
      wrap1.appendChild(uname);
      var wrap2 = el("label", "auth-field");
      wrap2.appendChild(el("span", "auth-field-label", t("houseLabel")));
      wrap2.appendChild(house);

      form.appendChild(wrap1);
      form.appendChild(wrap2);

      var row = el("div", "cta-row banner-actions");
      var saveBtn = el("button", "btn btn-primary", t("save"));
      saveBtn.type = "submit";
      var outBtn = el("button", "btn btn-ghost", t("signOut"));
      outBtn.type = "button";
      outBtn.addEventListener("click", function () { A.signOut(); });
      row.appendChild(saveBtn);
      row.appendChild(outBtn);
      form.appendChild(row);

      var status = el("p", "auth-gate-status");
      status.setAttribute("role", "status");

      form.addEventListener("submit", function (ev) {
        ev.preventDefault();
        saveBtn.disabled = true;
        A.saveProfile({ username: uname.value.trim(), house_key: house.value || null })
          .then(function () { status.textContent = t("saved"); saveBtn.disabled = false; })
          .catch(function () { status.textContent = t("saveFailed"); saveBtn.disabled = false; });
      });

      card.appendChild(form);
      card.appendChild(status);
      profileBox.appendChild(card);
    });
  }

  A.ready.then(function () { renderProfile(); renderStats(); });
  A.onChange(function () { renderProfile(); });
})();
