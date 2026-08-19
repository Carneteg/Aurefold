/* AUREFOLD — returning participation + private funnel milestones
   NON-CANON product/community layer.

   Principles:
   - no points, XP, badges or daily streak pressure;
   - reader-facing history stays local to this browser;
   - Supabase receives only anonymous milestone events, never raw answers/text;
   - Patreon clicks are intent signals only, never treated as confirmed membership.
*/
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  if (!cfg.supabaseUrl || !cfg.supabaseKey) return;

  var API = cfg.supabaseUrl + "/rest/v1/community_funnel_events";
  var ALLOWED = {
    house_test_complete: true,
    ledger_vote: true,
    sworn_reader: true,
    patreon_click: true
  };

  function visitorId() {
    var key = "ew-voter";
    var id;
    try { id = localStorage.getItem(key); } catch (e) {}
    if (id) return id;
    if (window.crypto && typeof window.crypto.randomUUID === "function") id = window.crypto.randomUUID();
    else {
      id = "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, function () {
        return Math.floor(Math.random() * 16).toString(16);
      });
    }
    try { localStorage.setItem(key, id); } catch (e2) {}
    return id;
  }

  function clean(value, max) {
    var s = String(value == null ? "" : value).replace(/[\r\n\t]+/g, " ").trim();
    return s.slice(0, max || 120);
  }

  function headers() {
    return {
      apikey: cfg.supabaseKey,
      Authorization: "Bearer " + cfg.supabaseKey,
      "Content-Type": "application/json",
      Prefer: "return=minimal"
    };
  }

  function localEventKey(name, context) {
    return "aurefold-funnel-v1:" + name + ":" + (context || "-");
  }

  function record(name, context) {
    if (!ALLOWED[name]) return Promise.resolve(false);
    context = clean(context || "", 120) || null;
    var localKey = localEventKey(name, context);
    try {
      if (localStorage.getItem(localKey)) return Promise.resolve(true);
    } catch (e) {}

    return fetch(API, {
      method: "POST",
      headers: headers(),
      body: JSON.stringify({
        visitor_id: visitorId(),
        event_name: name,
        context_key: context,
        source_path: clean(location.pathname, 200)
      })
    }).then(function (response) {
      // Unique server-side dedupe may answer 409 if local storage was cleared.
      if (!response.ok && response.status !== 409) throw new Error("community milestone failed");
      try { localStorage.setItem(localKey, "1"); } catch (e) {}
      if (typeof window.gtag === "function") {
        window.gtag("event", "community_" + name, context ? { context_key: context } : {});
      }
      return true;
    }).catch(function () { return false; });
  }

  function ledgerVotes() {
    var found = [];
    try {
      for (var i = 0; i < localStorage.length; i++) {
        var key = localStorage.key(i);
        if (!key || key.indexOf("ew-voted-ledger-") !== 0) continue;
        var pollId = key.slice("ew-voted-".length);
        if (pollId && found.indexOf(pollId) === -1) found.push(pollId);
      }
    } catch (e) {}
    return found.sort();
  }

  function syncLedgerMilestones() {
    ledgerVotes().forEach(function (pollId) { record("ledger_vote", pollId); });
  }

  function copyForLedgerCount(n) {
    var lang = (document.documentElement.lang || "en").slice(0, 2);
    var copy = {
      en: {
        title: "Your record",
        zero: "No Ledger Question is recorded on this browser yet. When you answer one, it stays here as part of your own reading history.",
        one: "One Ledger Question answered on this browser. When another opens, your earlier voice remains part of the record.",
        many: function (count) { return count + " Ledger Questions answered on this browser. You have returned to more than one argument."; },
        note: "This is not a score or a streak. It is only a local record of questions you chose to answer."
      },
      sv: {
        title: "Ditt protokoll",
        zero: "Ingen Ledger-fråga är registrerad i den här webbläsaren ännu. När du svarar på en stannar den här som en del av din egen läshistorik.",
        one: "En Ledger-fråga är besvarad i den här webbläsaren. När nästa öppnar finns din tidigare röst kvar i protokollet.",
        many: function (count) { return count + " Ledger-frågor är besvarade i den här webbläsaren. Du har återvänt till mer än ett argument."; },
        note: "Det här är varken poäng eller en streak. Det är bara ett lokalt protokoll över frågor du själv valt att besvara."
      },
      es: {
        title: "Tu registro",
        zero: "Aún no hay una Pregunta del Ledger registrada en este navegador. Cuando respondas una, quedará aquí como parte de tu propia historia de lectura.",
        one: "Una Pregunta del Ledger respondida en este navegador. Cuando se abra otra, tu voz anterior seguirá formando parte del registro.",
        many: function (count) { return count + " Preguntas del Ledger respondidas en este navegador. Has vuelto a más de un debate."; },
        note: "No es una puntuación ni una racha. Es solo un registro local de las preguntas que elegiste responder."
      },
      fr: {
        title: "Votre registre",
        zero: "Aucune Question du Ledger n’est encore enregistrée dans ce navigateur. Lorsque vous répondrez, elle restera ici dans votre propre historique de lecture.",
        one: "Une Question du Ledger répondue dans ce navigateur. Quand la suivante s’ouvrira, votre voix précédente restera dans le registre.",
        many: function (count) { return count + " Questions du Ledger répondues dans ce navigateur. Vous êtes revenu à plus d’un débat."; },
        note: "Ce n’est ni un score ni une série. C’est seulement un registre local des questions auxquelles vous avez choisi de répondre."
      },
      zh: {
        title: "你的记录",
        zero: "这个浏览器里还没有记录任何 Ledger 问题。回答后，它会作为你自己的阅读记录留在这里。",
        one: "这个浏览器里已经回答过一个 Ledger 问题。下一题开启时，你之前的声音仍会留在记录中。",
        many: function (count) { return "这个浏览器里已经回答过 " + count + " 个 Ledger 问题。你已经回来参与过不止一次争论。"; },
        note: "这不是分数，也不是连续签到。它只是你选择回答过哪些问题的本地记录。"
      },
      ja: {
        title: "あなたの記録",
        zero: "このブラウザには、まだ Ledger Question の記録がありません。答えると、自分だけの読書記録としてここに残ります。",
        one: "このブラウザで Ledger Question に1回答えています。次の問いが開かれても、以前の声は記録に残ります。",
        many: function (count) { return "このブラウザで " + count + " 件の Ledger Question に答えています。複数の議論に戻ってきています。"; },
        note: "これは点数でも連続記録でもありません。自分で答えることを選んだ問いのローカルな記録です。"
      }
    };
    var t = copy[lang] || copy.en;
    return { title: t.title, body: n === 0 ? t.zero : (n === 1 ? t.one : t.many(n)), note: t.note };
  }

  function renderLedgerRecord() {
    var moot = document.getElementById("moot");
    if (!moot) return;
    var count = ledgerVotes().length;
    var text = copyForLedgerCount(count);
    var card = document.getElementById("ledger-reader-record");
    if (!card) {
      card = document.createElement("section");
      card.id = "ledger-reader-record";
      card.className = "read-module";
      card.style.marginTop = "22px";
      card.style.marginBottom = "22px";
      moot.parentNode.insertBefore(card, moot);
    }
    card.innerHTML = "";
    var eyebrow = document.createElement("p");
    eyebrow.className = "quiz-result-eyebrow";
    eyebrow.textContent = text.title.toUpperCase();
    var body = document.createElement("p");
    body.textContent = text.body;
    var note = document.createElement("p");
    note.className = "world-note";
    note.style.marginBottom = "0";
    note.textContent = text.note;
    card.appendChild(eyebrow);
    card.appendChild(body);
    card.appendChild(note);
  }

  function syncHouseTest() {
    if (!document.getElementById("quiz")) return;
    // Shared result pages are presentation only and must never count as completions.
    if (new URLSearchParams(location.search).get("result")) return;
    if (!document.querySelector(".quiz-result")) return;
    try {
      var raw = localStorage.getItem("aurefold-house-test-v2");
      if (!raw) return;
      var parsed = JSON.parse(raw);
      if (parsed && parsed.house) record("house_test_complete", "v2");
    } catch (e) {}
  }

  function syncSwornReader() {
    if (!document.getElementById("banner-profile")) return;
    var A = window.AurefoldAuth;
    if (!A || !A.ready) return;
    A.ready.then(function () {
      if (!A.user || !A.user()) return;
      return A.profile();
    }).then(function (profile) {
      if (profile && profile.username) record("sworn_reader", "profile");
    }).catch(function () {});
  }

  function patreonIntent(anchor) {
    var text = (anchor.textContent || "").toLowerCase();
    if (/free|follow/.test(text)) return "free";
    if (/witness/.test(text)) return "witness";
    if (/chronicler/.test(text)) return "chronicler";
    if (/keeper/.test(text)) return "keeper";
    return "patreon";
  }

  document.addEventListener("click", function (event) {
    var anchor = event.target && event.target.closest ? event.target.closest('a[href*="patreon.com/AUREFOLD"]') : null;
    if (!anchor) return;
    record("patreon_click", patreonIntent(anchor));
  }, true);

  var quiz = document.getElementById("quiz");
  if (quiz) {
    syncHouseTest();
    new MutationObserver(syncHouseTest).observe(quiz, { childList: true, subtree: true });
  }

  var moot = document.getElementById("moot");
  if (moot) {
    syncLedgerMilestones();
    renderLedgerRecord();
    new MutationObserver(function () {
      syncLedgerMilestones();
      renderLedgerRecord();
    }).observe(moot, { childList: true, subtree: true });
  }

  syncSwornReader();

  window.AurefoldParticipation = {
    ledgerVotes: ledgerVotes,
    sync: function () {
      syncHouseTest();
      syncLedgerMilestones();
      renderLedgerRecord();
      syncSwornReader();
    }
  };
})();
