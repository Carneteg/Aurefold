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
      saveStale: "Your sign-in has gone stale. Sign in again and retry.",
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
      saveStale: "Din inloggning hade hunnit bli gammal. Logga in igen och försök på nytt.",
      signOut: "Logga ut",
      members: function (n) { return n + (n === 1 ? " svuren läsare" : " svurna läsare"); },
      characters: function (n) { return n + (n === 1 ? " karaktär i Hallen" : " karaktärer i Hallen"); },
      pieces: function (n) { return n + (n === 1 ? " verk i Skriptoriet" : " verk i Skriptoriet"); },
      yourPending: "Dina röster som väntar på arkivarien: ",
      pendingNone: "inga"
    },
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
      var title = el("h3", "auth-gate-title", t("welcome") + ", " + (p ? p.username : "reader"));
      card.appendChild(title);

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
          .then(function (row) {
            status.textContent = t("saved");
            title.textContent = t("welcome") + ", " + row.username;
            saveBtn.disabled = false;
          })
          .catch(function (e) {
            status.textContent = (e && e.code === "stale") ? t("saveStale") : t("saveFailed");
            saveBtn.disabled = false;
          });
      });

      card.appendChild(form);
      card.appendChild(status);
      profileBox.appendChild(card);
    });
  }

  A.ready.then(function () { renderProfile(); renderStats(); });
  A.onChange(function () { renderProfile(); });
})();
