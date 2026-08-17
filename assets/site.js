/* AUREFOLD — shared page behaviour: expandable house cards and the optional chart plate. */
(function () {
  "use strict";

  // Footer follow-links, driven by config (only the ones with a URL appear).
  var socialBox = document.getElementById("social-links");
  if (socialBox) {
    var sup = ((window.AUREFOLD_COMMUNITY || {}).support) || {};
    var order = [
      ["patreon", "Patreon"], ["discord", "Discord"], ["tiktok", "TikTok"],
      ["instagram", "Instagram"], ["youtube", "YouTube"], ["goodreads", "Goodreads"]
    ];
    order.forEach(function (pair) {
      var url = sup[pair[0]];
      if (url && String(url).trim()) {
        var a = document.createElement("a");
        a.className = "social-link";
        a.href = String(url).trim();
        a.target = "_blank";
        a.rel = "noopener";
        a.textContent = pair[1];
        socialBox.appendChild(a);
      }
    });
    if (socialBox.children.length) socialBox.removeAttribute("hidden");
  }

  // Mobile navigation toggle (hamburger).
  var nav = document.querySelector(".site-nav");
  var navToggle = nav && nav.querySelector(".nav-toggle");
  if (nav && navToggle) {
    var closeMenu = function (focusToggle) {
      nav.classList.remove("open");
      navToggle.setAttribute("aria-expanded", "false");
      navToggle.setAttribute("aria-label", "Open menu");
      if (focusToggle) navToggle.focus();
    };
    navToggle.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      navToggle.setAttribute("aria-expanded", String(open));
      navToggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    });
    // Close when a menu link is tapped.
    nav.querySelectorAll("#nav-menu a").forEach(function (a) {
      a.addEventListener("click", function () { closeMenu(false); });
    });
    // Escape closes the menu and returns focus to the toggle.
    document.addEventListener("keydown", function (e) {
      if ((e.key === "Escape" || e.key === "Esc") && nav.classList.contains("open")) {
        closeMenu(true);
      }
    });
  }

  // "The Archive" nav dropdown: the CSS drives the reveal (hover/focus on
  // desktop, always-nested on mobile); JS only keeps aria-expanded honest and
  // adds Escape-to-close. Degrades to plain links with JS off.
  var subToggle = nav && nav.querySelector(".nav-sub-toggle");
  if (subToggle) {
    var subGroup = subToggle.closest(".has-sub");
    var subMenu = subGroup && subGroup.querySelector(".sub-menu");
    var syncSub = function () {
      var shown = subMenu && getComputedStyle(subMenu).display !== "none";
      subToggle.setAttribute("aria-expanded", shown ? "true" : "false");
    };
    ["mouseenter", "mouseleave", "focusin", "focusout"].forEach(function (ev) {
      subGroup.addEventListener(ev, function () { setTimeout(syncSub, 0); });
    });
    window.addEventListener("resize", syncSub);
    subToggle.addEventListener("keydown", function (e) {
      if (e.key === "Escape" || e.key === "Esc") { subToggle.blur(); setTimeout(syncSub, 0); }
    });
    syncSub();
  }

  // Expandable house cards (houses.html).
  document.querySelectorAll(".house-card").forEach((card) => {
    const toggle = card.querySelector(".house-toggle");
    if (!toggle) return;
    toggle.addEventListener("click", () => {
      const open = card.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
    });
  });

  // Deep link: houses.html#<house-id> opens that card. Guard against hashes
  // that aren't a simple id (e.g. map.html uses #house/<id>, which would be an
  // invalid selector) so this stays inert on other pages.
  if (location.hash && /^#[A-Za-z][\w-]*$/.test(location.hash)) {
    const card = document.querySelector(`.house-card${location.hash}`);
    if (card) {
      card.classList.add("open");
      const toggle = card.querySelector(".house-toggle");
      if (toggle) toggle.setAttribute("aria-expanded", "true");
      card.scrollIntoView({ block: "center" });
    }
  }

  // Character portraits (characters.html): try the named file, then the
  // optional data-fallback source, else hide the slot.
  document.querySelectorAll(".face-portrait").forEach((img) => {
    const fail = () => {
      const fb = img.dataset.fallback;
      if (fb && !img.src.endsWith(fb)) img.src = fb;
      else img.hidden = true;
    };
    img.addEventListener("error", fail);
    if (img.complete && img.naturalWidth === 0) fail();
  });

  // Front-page Patreon call-to-action (config-driven; stays hidden if unset).
  var patreonUrl = ((window.AUREFOLD_COMMUNITY || {}).support || {}).patreon;
  var frontPatreon = document.getElementById("front-patreon");
  if (frontPatreon && patreonUrl && patreonUrl.trim()) {
    frontPatreon.href = patreonUrl.trim();
    frontPatreon.hidden = false;
  }

  // ---- Cookie consent (Google Consent Mode v2) + gated third parties --------
  // GA loads in "denied" mode by default (see the gtag snippet in <head>), so it
  // sets no cookies until the visitor accepts. MailerLite's universal.js is not
  // loaded at all until consent, since it also sets cookies. The choice is
  // remembered in localStorage; the footer "Cookie settings" link reopens it.
  var CONSENT_KEY = "aurefold_consent";
  function readConsent() { try { return localStorage.getItem(CONSENT_KEY); } catch (e) { return null; } }
  function writeConsent(v) { try { localStorage.setItem(CONSENT_KEY, v); } catch (e) {} }

  // MailerLite reading-list embed — loaded ONLY after consent is granted.
  var mlCfg = (window.AUREFOLD_COMMUNITY || {}).mailerlite || {};
  var mlBox = document.getElementById("ml-embed");
  var signupSoon = document.getElementById("signup-soon");
  var mlConfigured = !!(mlBox && mlCfg.account && mlCfg.form &&
    String(mlCfg.account).trim() && String(mlCfg.form).trim());
  var mlLoaded = false;
  function loadMailerLite() {
    if (mlLoaded || !mlConfigured) return;
    mlLoaded = true;
    mlBox.setAttribute("data-form", String(mlCfg.form).trim());  // config is source of truth
    mlBox.hidden = false;
    if (signupSoon) signupSoon.hidden = true;
    // Official MailerLite universal.js loader (queues calls, then renders forms).
    (function (w, d, e, u, f, l, n) {
      w[f] = w[f] || function () { (w[f].q = w[f].q || []).push(arguments); };
      l = d.createElement(e); l.async = 1; l.src = u;
      n = d.getElementsByTagName(e)[0]; n.parentNode.insertBefore(l, n);
    })(window, document, "script", "https://assets.mailerlite.com/js/universal.js", "ml");
    window.ml("account", String(mlCfg.account).trim());
  }
  // When the form is configured but consent isn't granted, offer an inline
  // Localized consent strings (keyed by <html lang>). English is the fallback;
  // more languages are added as the site is translated.
  var CONSENT_I18N = {
    en: { banner: "Aurefold uses cookies for anonymous visitor analytics — and, if you join the reading list, the email signup form. You choose.",
          privacy: "Privacy &amp; cookies", decline: "Decline", accept: "Accept",
          gatePre: "To load the email signup form we need your consent to cookies. ",
          allow: "Allow &amp; load the form", gateOr: ", or ", patreon: "follow free on Patreon" },
    sv: { banner: "Aurefold använder cookies för anonym besöksstatistik — och, om du går med i läslistan, e-postformuläret. Du väljer.",
          privacy: "Integritet &amp; cookies", decline: "Neka", accept: "Acceptera",
          gatePre: "För att ladda e-postformuläret behöver vi ditt samtycke till cookies. ",
          allow: "Tillåt &amp; ladda formuläret", gateOr: ", eller ", patreon: "följ gratis på Patreon" },
    es: { banner: "Aurefold usa cookies para estadísticas anónimas de visitantes — y, si te unes a la lista de lectura, el formulario de correo. Tú eliges.",
          privacy: "Privacidad y cookies", decline: "Rechazar", accept: "Aceptar",
          gatePre: "Para cargar el formulario de correo necesitamos tu consentimiento a las cookies. ",
          allow: "Permitir y cargar el formulario", gateOr: ", o ", patreon: "sigue gratis en Patreon" },
    fr: { banner: "Aurefold utilise des cookies pour des statistiques de visite anonymes — et, si vous rejoignez la liste de lecture, le formulaire d’inscription par e-mail. À vous de choisir.",
          privacy: "Confidentialité et cookies", decline: "Refuser", accept: "Accepter",
          gatePre: "Pour charger le formulaire d’inscription, nous avons besoin de votre consentement aux cookies. ",
          allow: "Autoriser et charger le formulaire", gateOr: ", ou ", patreon: "suivez gratuitement sur Patreon" },
    zh: { banner: "Aurefold 使用 Cookie 进行匿名访客统计——如果你加入阅读清单，还会用于邮件订阅表单。由你选择。",
          privacy: "隐私与 Cookie", decline: "拒绝", accept: "接受",
          gatePre: "为加载邮件订阅表单，我们需要你同意使用 Cookie。",
          allow: "允许并加载表单", gateOr: "，或 ", patreon: "在 Patreon 上免费关注" },
    ja: { banner: "Aurefold は匿名のアクセス統計のために Cookie を使用します——読書リストに登録する場合は、メール登録フォームにも使用します。選ぶのはあなたです。",
          privacy: "プライバシーと Cookie", decline: "拒否する", accept: "同意する",
          gatePre: "メール登録フォームを読み込むには、Cookie への同意が必要です。",
          allow: "許可してフォームを読み込む", gateOr: "、または ", patreon: "Patreon で無料でフォローする" }
  };
  var CT = CONSENT_I18N[(document.documentElement.lang || "en").slice(0, 2)] || CONSENT_I18N.en;

  // one-click enable (instead of the generic "opens soon" note).
  function showSignupGate() {
    if (!mlConfigured || !signupSoon || mlLoaded) return;
    signupSoon.innerHTML =
      CT.gatePre +
      '<button type="button" class="linklike" id="signup-consent">' + CT.allow + '</button>' +
      CT.gateOr + '<a href="https://www.patreon.com/AUREFOLD" target="_blank" rel="noopener">' + CT.patreon + '</a>.';
    var b = document.getElementById("signup-consent");
    if (b) b.addEventListener("click", acceptConsent);
    signupSoon.hidden = false;
  }

  function applyGranted() {
    if (typeof window.gtag === "function") {
      window.gtag("consent", "update", {
        ad_storage: "granted", ad_user_data: "granted",
        ad_personalization: "granted", analytics_storage: "granted"
      });
    }
    loadMailerLite();
  }

  var banner = null;
  function removeBanner() { if (banner && banner.parentNode) banner.parentNode.removeChild(banner); banner = null; }
  function acceptConsent() { writeConsent("granted"); applyGranted(); removeBanner(); }
  function declineConsent() { writeConsent("denied"); removeBanner(); showSignupGate(); }
  function showBanner() {
    if (banner) return;
    banner = document.createElement("div");
    banner.className = "cookie-banner";
    banner.setAttribute("role", "dialog");
    banner.setAttribute("aria-label", "Cookie consent");
    banner.innerHTML =
      '<p class="cookie-text">' + CT.banner + ' <a href="privacy.html">' + CT.privacy + '</a>.</p>' +
      '<div class="cookie-actions">' +
        '<button type="button" class="btn btn-ghost" data-consent="decline">' + CT.decline + '</button>' +
        '<button type="button" class="btn btn-primary" data-consent="accept">' + CT.accept + '</button>' +
      '</div>';
    document.body.appendChild(banner);
    banner.querySelector('[data-consent="accept"]').addEventListener("click", acceptConsent);
    banner.querySelector('[data-consent="decline"]').addEventListener("click", declineConsent);
  }

  var storedConsent = readConsent();
  if (storedConsent === "granted") applyGranted();
  else if (storedConsent === "denied") showSignupGate();
  else { showBanner(); showSignupGate(); }

  // Any "Cookie settings" control (footer link, privacy-page button) reopens
  // the banner so a choice can be changed later.
  Array.prototype.forEach.call(
    document.querySelectorAll("#cookie-settings, #cookie-settings-footer"),
    function (el) {
      el.addEventListener("click", function (e) { e.preventDefault(); showBanner(); });
    }
  );

  // Copy-link share buttons (any [data-copy] element). Delegated from the
  // document so it also covers buttons injected after load — e.g. the quiz
  // result screen — not just the ones present in the initial markup.
  document.addEventListener("click", function (e) {
    var btn = e.target.closest && e.target.closest("[data-copy]");
    if (!btn || btn.dataset.copyBusy) return;
    var text = btn.getAttribute("data-copy");
    var label = btn.textContent;
    btn.dataset.copyBusy = "1";
    var done = function () {
      btn.textContent = "Copied!";
      setTimeout(function () { btn.textContent = label; delete btn.dataset.copyBusy; }, 1800);
    };
    if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, done); else done();
  });

  // Read page: reveal the sticky "keep reading" bar once past the intro.
  var sticky = document.getElementById("read-sticky");
  if (sticky) {
    var onScroll = function () {
      var y = window.pageYOffset || document.documentElement.scrollTop;
      var nearBottom = (y + window.innerHeight) > (document.body.scrollHeight - 260);
      if (y > 500 && !nearBottom) sticky.classList.add("show");
      else sticky.classList.remove("show");
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  }

  // Privacy-friendly analytics (Plausible). Loads ONLY when a domain is
  // configured in data/community.js; otherwise nothing external is requested.
  // No cookies, no personal data. Also tracks a few key conversion events
  // without any per-element markup.
  var an = (window.AUREFOLD_COMMUNITY || {}).analytics || {};
  if (an.plausibleDomain && String(an.plausibleDomain).trim()) {
    var ps = document.createElement("script");
    ps.defer = true;
    ps.setAttribute("data-domain", String(an.plausibleDomain).trim());
    ps.src = "https://plausible.io/js/script.outbound-links.js";
    document.head.appendChild(ps);
    window.plausible = window.plausible || function () {
      (window.plausible.q = window.plausible.q || []).push(arguments);
    };
    document.addEventListener("click", function (e) {
      var a = e.target.closest && e.target.closest("a");
      if (!a) return;
      var href = a.getAttribute("href") || "";
      if (/patreon\.com/i.test(href)) window.plausible("Patreon click");
      else if (/support\.html/i.test(href)) window.plausible("Support click");
      else if (/read\.html/i.test(href)) window.plausible("Read click");
    });
  }

  // Show Plate I on the front page only if the chart image exists.
  const plateImg = document.getElementById("chart-plate-img");
  if (plateImg) {
    const plate = document.getElementById("chart-plate");
    if (plateImg.complete && plateImg.naturalWidth > 0) plate.hidden = false;
    else plateImg.addEventListener("load", () => { plate.hidden = false; });
  }

  // Social-proof line ("Join N readers …") wherever a .social-proof element
  // exists. Driven by momentum.members; stays hidden until it's a positive
  // number, so no fabricated counts ever show.
  var spMembers = ((window.AUREFOLD_COMMUNITY || {}).momentum || {}).members;
  if (typeof spMembers === "number" && spMembers > 0) {
    var spText = "Join " + spMembers + " reader" + (spMembers === 1 ? "" : "s") + " following the road to publication";
    document.querySelectorAll(".social-proof").forEach(function (n) {
      if (!n.textContent) n.textContent = spText;
      n.removeAttribute("hidden");
    });
  }

  // ---- Homepage freshness signals (all inert until they have real data) ----
  var freshCfg = window.AUREFOLD_COMMUNITY || {};

  // 1) Momentum strip: render only the fields that are set. A null/blank value
  //    — or a number that isn't > 0 — is skipped, so nothing ever shows "0".
  var momentumBox = document.getElementById("momentum");
  if (momentumBox) {
    var mo = freshCfg.momentum || {};
    var addStat = function (value, label, isText) {
      var item = document.createElement("div");
      item.className = "momentum-item" + (isText ? " is-text" : "");
      var v = document.createElement("span"); v.className = "momentum-value"; v.textContent = value;
      var l = document.createElement("span"); l.className = "momentum-label"; l.textContent = label;
      item.appendChild(v); item.appendChild(l); momentumBox.appendChild(item);
    };
    var posNum = function (n) { return (typeof n === "number" && isFinite(n) && n > 0) ? n : null; };
    if (posNum(mo.members)) addStat(String(mo.members), mo.members === 1 ? "member" : "members", false);
    if (posNum(mo.votesCast)) addStat(String(mo.votesCast), mo.votesCast === 1 ? "vote cast" : "votes cast", false);
    var milestone = mo.latestMilestone && String(mo.latestMilestone).trim();
    if (milestone) addStat(milestone, "Latest milestone", true);
    if (momentumBox.children.length) momentumBox.removeAttribute("hidden");
  }

  // 2) Latest-from-the-Journal teaser, driven by AUREFOLD_COMMUNITY.journal.
  var homeJournal = document.getElementById("home-journal");
  if (homeJournal) {
    var jo = freshCfg.journal || {};
    var jTitle = jo.latestTitle && String(jo.latestTitle).trim();
    if (jTitle) {
      var jDate = jo.latestDate && String(jo.latestDate).trim();
      var jKind = document.createElement("span");
      jKind.className = "home-journal-kind";
      jKind.textContent = "Latest from the Journal" + (jDate ? " · " + jDate : "");
      var jLink = document.createElement("a");
      jLink.href = (jo.url && String(jo.url).trim()) || "journal.html";
      jLink.textContent = jTitle + " →";
      homeJournal.appendChild(jKind);
      homeJournal.appendChild(document.createElement("br"));
      homeJournal.appendChild(jLink);
      homeJournal.removeAttribute("hidden");
    }
  }

  // 3) Latest-from-the-Moot line: the leading option of the primary poll,
  //    read from the SAME poll_tallies data vote.js uses. Stays hidden until
  //    the poll reaches its reveal threshold (shared per-poll resolver).
  var mootLatest = document.getElementById("moot-latest");
  if (mootLatest && freshCfg.supabaseUrl && freshCfg.supabaseKey) {
    var mApi = freshCfg.supabaseUrl + "/rest/v1";
    var mHead = { apikey: freshCfg.supabaseKey, Authorization: "Bearer " + freshCfg.supabaseKey };
    var mGet = function (u) { return fetch(u, { headers: mHead }).then(function (r) { return r.ok ? r.json() : null; }); };
    Promise.all([
      mGet(mApi + "/polls?select=id,question,poll_options(id,label,sort)&open=eq.true&order=sort"),
      mGet(mApi + "/poll_tallies?select=poll_id,option_id,votes")
    ]).then(function (all) {
      var polls = all[0], tallies = all[1];
      if (!polls || !polls.length || !tallies) return;
      var poll = polls[0]; // primary poll (lowest sort)
      // per-poll threshold — resolved only now that the poll id is known,
      // through the same shared resolver vote.js uses (data/community.js)
      var mThreshold = freshCfg.resolveMootThreshold ? freshCfg.resolveMootThreshold(poll.id) : 0;
      var total = 0, topId = null, topN = -1;
      tallies.forEach(function (t) {
        if (t.poll_id !== poll.id) return;
        total += t.votes;
        if (t.votes > topN) { topN = t.votes; topId = t.option_id; }
      });
      if (total <= 0 || total < mThreshold || topId == null) return;
      var top = null;
      (poll.poll_options || []).forEach(function (o) { if (o.id === topId) top = o; });
      if (!top) return;
      var mKind = document.createElement("span");
      mKind.className = "home-journal-kind";
      mKind.textContent = "Latest from the Moot";
      var mLink = document.createElement("a");
      mLink.href = "vote.html";
      mLink.textContent = "“" + top.label + "” leads the vote →";
      mootLatest.appendChild(mKind);
      mootLatest.appendChild(document.createElement("br"));
      mootLatest.appendChild(mLink);
      mootLatest.removeAttribute("hidden");
    }).catch(function () { /* leave hidden on any error */ });
  }
})();
