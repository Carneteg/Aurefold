/* AUREFOLD — reader auth: magic-link sign-in, optional Discord OAuth, session
   keeping, and a tiny PostgREST helper. Plain fetch, no dependencies — the
   same pattern as vote.js and the Loremaster. Security lives in Postgres
   (row-level security); this file only carries the reader's own token.

   Exposes window.AurefoldAuth:
     .ready            Promise — resolves after hash-token parsing + refresh
     .user()           the signed-in user object, or null
     .profile()        Promise — the reader's profiles row, or null
     .saveProfile({username, house_key})
     .signInEmail(email, redirectTo)   — sends the magic link
     .signInDiscord(redirectTo)        — full-page redirect (if enabled)
     .signOut()
     .api(path, opts)  — fetch against /rest/v1 with the best available token
     .onChange(cb)     — cb(user) on sign-in / sign-out
     .renderGate(el, opts)  — shared "sign in to take part" box
     .t(key)           — localized chrome string (en + sv; others fall back)
*/
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var URL = cfg.supabaseUrl;
  var KEY = cfg.supabaseKey;
  var LS_KEY = "aurefold_session_v1";

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      gateTitle: "Take part",
      gateBody: "Swear in with your email and the archive sends you a sign-in link — no password, no fuss. One reader, one voice.",
      emailLabel: "Your email",
      emailButton: "Send my sign-in link",
      emailSent: "Check your email — the link is on its way. It opens you right back here.",
      discordButton: "Sign in with Discord",
      orWord: "or",
      invalidEmail: "That email does not look right. Try again?",
      failed: "The archive could not be reached. Try again in a moment.",
      linkBad: "That sign-in link had already been spent. Send yourself a fresh one below.",
      signedInAs: "Signed in as",
      signOut: "Sign out",
      rateLimited: "The archive asks you to wait a moment before sending another link."
    },
    sv: {
      gateTitle: "Delta",
      gateBody: "Svär in dig med din e-post så skickar arkivet en inloggningslänk — inget lösenord, inget krångel. En läsare, en röst.",
      emailLabel: "Din e-post",
      emailButton: "Skicka min inloggningslänk",
      emailSent: "Kolla din e-post — länken är på väg. Den öppnar dig direkt här igen.",
      discordButton: "Logga in med Discord",
      orWord: "eller",
      invalidEmail: "Den e-posten ser inte riktigt rätt ut. Försök igen?",
      failed: "Arkivet kunde inte nås. Försök igen om en stund.",
      linkBad: "Den inloggningslänken var redan förbrukad. Skicka en ny nedan.",
      signedInAs: "Inloggad som",
      signOut: "Logga ut",
      rateLimited: "Arkivet ber dig vänta en stund innan nästa länk skickas."
    },
    es: {
      gateTitle: "Participa",
      gateBody: "Júrate con tu correo y el archivo te enviará un enlace de acceso — sin contraseña, sin complicaciones. Un lector, una voz.",
      emailLabel: "Tu correo",
      emailButton: "Enviar mi enlace de acceso",
      emailSent: "Revisa tu correo — el enlace va en camino. Te traerá de vuelta aquí.",
      discordButton: "Iniciar sesión con Discord",
      orWord: "o",
      invalidEmail: "Ese correo no parece correcto. ¿Lo intentas de nuevo?",
      failed: "No se pudo contactar con el archivo. Inténtalo de nuevo en un momento.",
      linkBad: "Ese enlace de acceso ya se había usado. Envíate uno nuevo abajo.",
      signedInAs: "Sesión iniciada como",
      signOut: "Cerrar sesión",
      rateLimited: "El archivo te pide esperar un momento antes de enviar otro enlace."
    },
    fr: {
      gateTitle: "Participez",
      gateBody: "Prêtez serment avec votre e-mail et l’archive vous envoie un lien de connexion — pas de mot de passe, pas de complications. Un lecteur, une voix.",
      emailLabel: "Votre e-mail",
      emailButton: "Envoyer mon lien de connexion",
      emailSent: "Vérifiez votre e-mail — le lien est en chemin. Il vous ramène ici directement.",
      discordButton: "Se connecter avec Discord",
      orWord: "ou",
      invalidEmail: "Cet e-mail ne semble pas correct. Réessayer ?",
      failed: "Impossible de joindre l’archive. Réessayez dans un instant.",
      linkBad: "Ce lien de connexion avait déjà été utilisé. Envoyez-vous-en un nouveau ci-dessous.",
      signedInAs: "Connecté en tant que",
      signOut: "Se déconnecter",
      rateLimited: "L’archive vous demande d’attendre un instant avant d’envoyer un autre lien."
    },
    zh: {
      gateTitle: "参与",
      gateBody: "用你的邮箱宣誓加入，档案会给你发送一个登录链接——无需密码，毫不繁琐。一位读者，一个声音。",
      emailLabel: "你的邮箱",
      emailButton: "发送我的登录链接",
      emailSent: "查看你的邮箱——链接正在路上。点击它会直接带你回到这里。",
      discordButton: "使用 Discord 登录",
      orWord: "或",
      invalidEmail: "这个邮箱地址似乎不对。要再试一次吗？",
      failed: "无法连接到档案。请稍后再试。",
      linkBad: "那个登录链接已经用过了。请在下方给自己发送一个新的。",
      signedInAs: "已登录为",
      signOut: "退出登录",
      rateLimited: "档案请你稍候片刻，再发送下一个链接。"
    },
    ja: {
      gateTitle: "参加する",
      gateBody: "メールで誓いを立てると、記録がサインインリンクを送ります——パスワードも面倒もいりません。一人の読者、一つの声。",
      emailLabel: "メールアドレス",
      emailButton: "サインインリンクを送る",
      emailSent: "メールをご確認ください——リンクは届く途中です。開くと、ここに戻ってきます。",
      discordButton: "Discord でサインイン",
      orWord: "または",
      invalidEmail: "そのメールアドレスは正しくないようです。もう一度試しますか？",
      failed: "記録に接続できませんでした。しばらくしてからもう一度お試しください。",
      linkBad: "そのサインインリンクはすでに使われています。下から新しいものを送ってください。",
      signedInAs: "サインイン中",
      signOut: "サインアウト",
      rateLimited: "記録は、次のリンクを送る前に少し待つようお願いしています。"
    }
  };
  function t(key) { return (TX[LANG] && TX[LANG][key]) || TX.en[key] || key; }

  var session = null;
  var listeners = [];

  function notify() {
    var u = session && session.user;
    listeners.forEach(function (cb) { try { cb(u); } catch (e) {} });
  }

  function save() {
    try {
      if (session) localStorage.setItem(LS_KEY, JSON.stringify(session));
      else localStorage.removeItem(LS_KEY);
    } catch (e) {}
  }

  function load() {
    try {
      var raw = localStorage.getItem(LS_KEY);
      if (raw) session = JSON.parse(raw);
    } catch (e) { session = null; }
  }

  function storeFromTokenBody(body) {
    if (!body || !body.access_token) return false;
    session = {
      access_token: body.access_token,
      refresh_token: body.refresh_token || (session && session.refresh_token) || null,
      expires_at: Math.floor(Date.now() / 1000) + (body.expires_in || 3600),
      user: body.user || (session && session.user) || null
    };
    save();
    return true;
  }

  /* Magic links and OAuth redirects come back with tokens in the URL hash
     (#access_token=...&refresh_token=...). Lift them into storage and clean
     the address bar. Errors arrive the same way (#error=...). */
  function parseHash() {
    if (!location.hash || location.hash.indexOf("access_token=") === -1 && location.hash.indexOf("error=") === -1) return null;
    var params = {};
    location.hash.slice(1).split("&").forEach(function (kv) {
      var i = kv.indexOf("=");
      if (i > -1) params[decodeURIComponent(kv.slice(0, i))] = decodeURIComponent(kv.slice(i + 1).replace(/\+/g, " "));
    });
    var err = params.error_description || params.error || null;
    if (params.access_token) {
      storeFromTokenBody({
        access_token: params.access_token,
        refresh_token: params.refresh_token,
        expires_in: parseInt(params.expires_in || "3600", 10),
        user: null // filled by fetchUser() below
      });
    }
    // Clean the hash without adding a history entry.
    if (history.replaceState) history.replaceState(null, "", location.pathname + location.search);
    return err ? { error: err } : (params.access_token ? { signedIn: true } : null);
  }

  function fetchUser() {
    if (!session || !session.access_token) return Promise.resolve(null);
    return fetch(URL + "/auth/v1/user", {
      headers: { apikey: KEY, Authorization: "Bearer " + session.access_token }
    }).then(function (r) {
      if (!r.ok) throw new Error("user fetch failed");
      return r.json();
    }).then(function (u) {
      session.user = u;
      save();
      return u;
    }).catch(function () { return null; });
  }

  function refresh() {
    if (!session || !session.refresh_token) return Promise.resolve(false);
    return fetch(URL + "/auth/v1/token?grant_type=refresh_token", {
      method: "POST",
      headers: { apikey: KEY, "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: session.refresh_token })
    }).then(function (r) { return r.json().then(function (b) { return { ok: r.ok, b: b }; }); })
      .then(function (res) {
        if (!res.ok || !storeFromTokenBody(res.b)) {
          session = null; save();
          return false;
        }
        return true;
      }).catch(function () { return false; });
  }

  function token() {
    if (!session) return Promise.resolve(null);
    var now = Math.floor(Date.now() / 1000);
    if (session.expires_at && session.expires_at - 60 > now) return Promise.resolve(session.access_token);
    return refresh().then(function (ok) { return ok ? session.access_token : null; });
  }

  /* PostgREST helper. Uses the reader's token when signed in, else the anon
     key. `opts`: method, body (object), prefer (string), single (bool). */
  function api(path, opts) {
    opts = opts || {};
    return token().then(function (tok) {
      var headers = { apikey: KEY, Authorization: "Bearer " + (tok || KEY) };
      if (opts.body !== undefined) headers["Content-Type"] = "application/json";
      if (opts.prefer) headers["Prefer"] = opts.prefer;
      if (opts.single) headers["Accept"] = "application/vnd.pgrst.object+json";
      return fetch(URL + "/rest/v1" + path, {
        method: opts.method || "GET",
        headers: headers,
        body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined
      }).then(function (r) {
        if (r.status === 409) return { conflict: true };
        if (!r.ok) {
          var err = new Error("HTTP " + r.status);
          err.status = r.status;
          throw err;
        }
        if (r.status === 201 || r.status === 204) return {};
        return r.json();
      });
    });
  }

  function profile() {
    if (!session || !session.user) return Promise.resolve(null);
    return api("/profiles?id=eq." + session.user.id + "&select=id,username,house_key,role", { single: true })
      .catch(function () { return null; });
  }

  function saveProfile(patch) {
    if (!session || !session.user) return Promise.reject(new Error("signed out"));
    return api("/profiles?id=eq." + session.user.id, {
      method: "PATCH",
      body: patch,
      prefer: "return=minimal"
    });
  }

  function signInEmail(email, redirectTo) {
    return fetch(URL + "/auth/v1/otp", {
      method: "POST",
      headers: { apikey: KEY, "Content-Type": "application/json" },
      body: JSON.stringify({
        email: email,
        options: { emailRedirectTo: redirectTo || (location.origin + location.pathname), shouldCreateUser: true }
      })
    }).then(function (r) {
      if (r.status === 429) { var e = new Error("rate limited"); e.code = "rate"; throw e; }
      if (!r.ok) throw new Error("otp failed");
    });
  }

  function signInDiscord(redirectTo) {
    location.href = URL + "/auth/v1/authorize?provider=discord&redirect_to=" +
      encodeURIComponent(redirectTo || (location.origin + location.pathname));
  }

  function signOut() {
    var done = function () { session = null; save(); notify(); };
    token().then(function (tok) {
      if (!tok) return done();
      fetch(URL + "/auth/v1/logout", {
        method: "POST",
        headers: { apikey: KEY, Authorization: "Bearer " + tok }
      }).then(done, done);
    });
  }

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  /* The shared sign-in box. opts: { intro } — extra sentence above the form. */
  function renderGate(container, opts) {
    opts = opts || {};
    container.innerHTML = "";
    var card = el("div", "auth-gate");
    card.appendChild(el("h3", "auth-gate-title", opts.title || t("gateTitle")));
    var body = el("p", "auth-gate-body", opts.intro || t("gateBody"));
    card.appendChild(body);

    var form = el("form", "auth-gate-form");
    var input = el("input", "auth-input");
    input.type = "email";
    input.required = true;
    input.autocomplete = "email";
    input.placeholder = t("emailLabel");
    input.setAttribute("aria-label", t("emailLabel"));
    var btn = el("button", "btn btn-primary", t("emailButton"));
    btn.type = "submit";
    form.appendChild(input);
    form.appendChild(btn);
    card.appendChild(form);

    var status = el("p", "auth-gate-status");
    status.setAttribute("role", "status");
    card.appendChild(status);

    if (cfg.auth && cfg.auth.discord) {
      var or = el("p", "auth-gate-or", "— " + t("orWord") + " —");
      card.appendChild(or);
      var dbtn = el("button", "btn btn-ghost", t("discordButton"));
      dbtn.type = "button";
      dbtn.addEventListener("click", function () { signInDiscord(); });
      card.appendChild(dbtn);
    }

    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      var email = input.value.trim();
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) { status.textContent = t("invalidEmail"); return; }
      btn.disabled = true;
      signInEmail(email).then(function () {
        status.textContent = t("emailSent");
        form.hidden = true;
      }).catch(function (e) {
        status.textContent = e && e.code === "rate" ? t("rateLimited") : t("failed");
        btn.disabled = false;
      });
    });

    container.appendChild(card);
    return card;
  }

  var ready = (function () {
    load();
    var hashResult = parseHash();
    var p = session && !session.user ? fetchUser() : Promise.resolve(session && session.user);
    return p.then(function () {
      if (hashResult && hashResult.signedIn) notify();
      return hashResult;
    });
  })();

  window.AurefoldAuth = {
    ready: ready,
    t: t,
    user: function () { return session && session.user; },
    profile: profile,
    saveProfile: saveProfile,
    signInEmail: signInEmail,
    signInDiscord: signInDiscord,
    signOut: signOut,
    api: api,
    onChange: function (cb) { listeners.push(cb); },
    renderGate: renderGate,
    _hashError: null
  };

  // Surface a spent/expired magic link where a gate is rendered.
  ready.then(function (res) {
    if (res && res.error) window.AurefoldAuth._hashError = res.error;
  });
})();
