/* AUREFOLD — the moot: load open polls, cast one vote per visitor, show results.
   This file is PRESENTATION ONLY. The Supabase data layer, its row-level
   security, the poll_tallies aggregate, and the one-vote-per-reader rule
   (unique vote per ew-voter) are all unchanged — no schema changes are made
   or required by anything below.

   Localized interface: the Moot's own chrome (buttons, notes, standings)
   follows <html lang>. Poll questions and options are served from Supabase
   in the language they were authored in, so they are shown verbatim. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var root = document.getElementById("moot");
  if (!root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      decidedLast: "What the Moot decided last time",
      kindHouse: "The house question",
      kindNext: "What opens next",
      kindQuestion: "A question for the Moot",
      notPublished: "The moot convenes on the published site.",
      yourVoice: "Your voice — ",
      counted: "counted",
      voicesWord: function (n) { return n === 1 ? " voice" : " voices"; },
      changeChoice: "Change your choice",
      addVoice: "Add your voice",
      heard: function (total) { return "The Moot has heard " + total + (total === 1 ? " voice." : " voices."); },
      noVoicesYet: "No voices yet. Yours would be the first.",
      countedStanding: "Your voice is counted. The full standing opens once more readers weigh in.",
      earlyDays: "Early days — be among the first to weigh in.",
      keepChoice: "Keep my current choice",
      pickAnother: "Pick another option to change your voice, or keep your current one.",
      showStanding: "Show the standing without voting",
      onePerReader: "One voice per reader. The archive counts; it does not watch.",
      currentVoiceSuffix: " — your current voice",
      oneVoiceKept: "The Moot keeps one voice per reader — your first choice stands.",
      memberOnly: "The great questions ask for a sworn voice — sign in to cast yours. One reader, one voice, counted across every device.",
      onePerMember: "One voice per sworn reader. The archive counts; it does not watch.",
      notReached: "The archive could not be reached. Try again in a moment.",
      fromQuiz: "From your quiz — this house is highlighted below. Cast it, or choose another. Nothing is sent until you pick.",
      convening: "Convening the moot…",
      notInSession: "The moot is not in session. Come back soon.",
      notReachedHere: "The archive could not be reached from here. The moot convenes on the published site — or try again in a moment."
    },
    sv: {
      decidedLast: "Vad Tinget beslutade förra gången",
      kindHouse: "Husfrågan",
      kindNext: "Vad som öppnas härnäst",
      kindQuestion: "En fråga till Tinget",
      notPublished: "Tinget sammanträder på den publicerade sajten.",
      yourVoice: "Din röst — ",
      counted: "räknad",
      voicesWord: function (n) { return n === 1 ? " röst" : " röster"; },
      changeChoice: "Ändra ditt val",
      addVoice: "Lägg till din röst",
      heard: function (total) { return "Tinget har hört " + total + (total === 1 ? " röst." : " röster."); },
      noVoicesYet: "Inga röster ännu. Din skulle vara den första.",
      countedStanding: "Din röst är räknad. Hela ställningen öppnas när fler läsare har sagt sitt.",
      earlyDays: "Tidiga dagar — var bland de första att säga sitt.",
      keepChoice: "Behåll mitt nuvarande val",
      pickAnother: "Välj ett annat alternativ för att ändra din röst, eller behåll ditt nuvarande.",
      showStanding: "Visa ställningen utan att rösta",
      onePerReader: "En röst per läsare. Arkivet räknar; det övervakar inte.",
      currentVoiceSuffix: " — din nuvarande röst",
      oneVoiceKept: "Tinget håller en röst per läsare — ditt första val gäller.",
      memberOnly: "De stora frågorna kräver en svuren röst — logga in för att lägga din. En läsare, en röst, räknad på alla dina enheter.",
      onePerMember: "En röst per svuren läsare. Arkivet räknar; det övervakar inte.",
      notReached: "Arkivet kunde inte nås. Försök igen om en stund.",
      fromQuiz: "Från ditt test — det här huset är markerat nedan. Lägg din röst på det, eller välj ett annat. Inget skickas förrän du väljer.",
      convening: "Sammankallar tinget…",
      notInSession: "Tinget är inte i session. Kom tillbaka snart.",
      notReachedHere: "Arkivet kunde inte nås härifrån. Tinget sammanträder på den publicerade sajten — eller försök igen om en stund."
    },
    es: {
      decidedLast: "Lo que decidió El Cónclave la última vez",
      kindHouse: "La pregunta de las casas",
      kindNext: "Qué se abre a continuación",
      kindQuestion: "Una pregunta para El Cónclave",
      notPublished: "El cónclave se reúne en el sitio publicado.",
      yourVoice: "Tu voz — ",
      counted: "contada",
      voicesWord: function (n) { return n === 1 ? " voz" : " voces"; },
      changeChoice: "Cambia tu elección",
      addVoice: "Añade tu voz",
      heard: function (total) { return "El Cónclave ha oído " + total + (total === 1 ? " voz." : " voces."); },
      noVoicesYet: "Aún no hay voces. La tuya sería la primera.",
      countedStanding: "Tu voz está contada. El recuento completo se abre cuando más lectores participen.",
      earlyDays: "Es pronto — sé de los primeros en participar.",
      keepChoice: "Mantener mi elección actual",
      pickAnother: "Elige otra opción para cambiar tu voz, o mantén la actual.",
      showStanding: "Ver el recuento sin votar",
      onePerReader: "Una voz por lector. El archivo cuenta; no vigila.",
      currentVoiceSuffix: " — tu voz actual",
      oneVoiceKept: "El Cónclave guarda una voz por lector — tu primera elección se mantiene.",
      memberOnly: "Las grandes preguntas piden una voz juramentada — inicia sesión para dar la tuya. Un lector, una voz, contada en todos tus dispositivos.",
      onePerMember: "Una voz por lector juramentado. El archivo cuenta; no vigila.",
      notReached: "No se pudo contactar con el archivo. Inténtalo de nuevo en un momento.",
      fromQuiz: "De tu test — esta casa está resaltada abajo. Vótala, o elige otra. Nada se envía hasta que elijas.",
      convening: "Convocando el cónclave…",
      notInSession: "El cónclave no está en sesión. Vuelve pronto.",
      notReachedHere: "No se pudo contactar con el archivo desde aquí. El cónclave se reúne en el sitio publicado — o inténtalo de nuevo en un momento."
    },
    fr: {
      decidedLast: "Ce que le Conseil a décidé la dernière fois",
      kindHouse: "La question des maisons",
      kindNext: "Ce qui s’ouvre ensuite",
      kindQuestion: "Une question pour le Conseil",
      notPublished: "Le conseil se réunit sur le site publié.",
      yourVoice: "Votre voix — ",
      counted: "comptée",
      voicesWord: function (n) { return " voix"; },
      changeChoice: "Changez votre choix",
      addVoice: "Ajoutez votre voix",
      heard: function (total) { return "Le Conseil a entendu " + total + " voix."; },
      noVoicesYet: "Aucune voix pour l’instant. La vôtre serait la première.",
      countedStanding: "Votre voix est comptée. Le décompte complet s’ouvre quand plus de lecteurs auront participé.",
      earlyDays: "C’est tôt — soyez parmi les premiers à participer.",
      keepChoice: "Garder mon choix actuel",
      pickAnother: "Choisissez une autre option pour changer votre voix, ou gardez la vôtre.",
      showStanding: "Voir le classement sans voter",
      onePerReader: "Une voix par lecteur. L’archive compte ; elle ne surveille pas.",
      currentVoiceSuffix: " — votre voix actuelle",
      oneVoiceKept: "Le Conseil garde une voix par lecteur — votre premier choix prévaut.",
      memberOnly: "Les grandes questions demandent une voix assermentée — connectez-vous pour donner la vôtre. Un lecteur, une voix, comptée sur tous vos appareils.",
      onePerMember: "Une voix par lecteur assermenté. L’archive compte ; elle ne surveille pas.",
      notReached: "Impossible de joindre l’archive. Réessayez dans un instant.",
      fromQuiz: "D’après votre quiz — cette maison est mise en avant ci-dessous. Votez-la, ou choisissez-en une autre. Rien n’est envoyé tant que vous n’avez pas choisi.",
      convening: "Convocation du conseil…",
      notInSession: "Le conseil n’est pas en session. Revenez bientôt.",
      notReachedHere: "Impossible de joindre l’archive d’ici. Le conseil se réunit sur le site publié — ou réessayez dans un instant."
    },
    zh: {
      decidedLast: "议会上次的决定",
      kindHouse: "家族问题",
      kindNext: "接下来揭示什么",
      kindQuestion: "给议会的一个问题",
      notPublished: "议会在已发布的站点上召开。",
      yourVoice: "你的一票——",
      counted: "已计入",
      voicesWord: function (n) { return " 票"; },
      changeChoice: "更改你的选择",
      addVoice: "投出你的一票",
      heard: function (total) { return "议会已听到 " + total + " 票。"; },
      noVoicesYet: "还没有票。你的将是第一票。",
      countedStanding: "你的一票已计入。当更多读者参与后，完整排名将会公开。",
      earlyDays: "为时尚早——成为最早参与的人之一。",
      keepChoice: "保留我当前的选择",
      pickAnother: "选择另一个选项来更改你的一票，或保留当前的。",
      showStanding: "不投票也查看排名",
      onePerReader: "每位读者一票。档案只计数，不监视。",
      currentVoiceSuffix: "——你当前的一票",
      oneVoiceKept: "议会每位读者只保留一票——你的第一次选择有效。",
      memberOnly: "重大问题需要宣誓之声——登录后方可投出你的一票。每位读者一票，跨设备计数。",
      onePerMember: "每位宣誓读者一票。档案只计数，不监视。",
      notReached: "无法连接档案。请稍后再试。",
      fromQuiz: "来自你的测验——下方高亮显示了这个家族。为它投票，或另选一个。在你做出选择前不会发送任何内容。",
      convening: "正在召集议会……",
      notInSession: "议会未在开会。请稍后再来。",
      notReachedHere: "无法从这里连接档案。议会在已发布的站点上召开——或稍后再试。"
    },
    ja: {
      decidedLast: "合議が前回決めたこと",
      kindHouse: "家をめぐる問い",
      kindNext: "次に何が開かれるか",
      kindQuestion: "合議への問い",
      notPublished: "合議は公開されたサイトで開かれます。",
      yourVoice: "あなたの声——",
      counted: "集計済み",
      voicesWord: function (n) { return "票"; },
      changeChoice: "選択を変える",
      addVoice: "あなたの声を加える",
      heard: function (total) { return "合議は" + total + "票を聞きました。"; },
      noVoicesYet: "まだ票がありません。あなたが最初の一票になります。",
      countedStanding: "あなたの声は集計されました。より多くの読者が参加すると、完全な結果が公開されます。",
      earlyDays: "まだ始まったばかり——最初に参加する一人になってください。",
      keepChoice: "現在の選択を保つ",
      pickAnother: "別の選択肢を選んで票を変えるか、現在のままにしてください。",
      showStanding: "投票せずに結果を見る",
      onePerReader: "読者一人につき一票。記録は数えるだけで、監視はしません。",
      currentVoiceSuffix: "——あなたの現在の一票",
      oneVoiceKept: "合議は読者一人につき一票を保ちます——最初の選択が有効です。",
      memberOnly: "大いなる問いには宣誓の声が必要です——ログインしてあなたの一票を。読者一人に一票、どの端末でも数えられます。",
      onePerMember: "宣誓した読者一人につき一票。記録は数えるだけで、監視はしません。",
      notReached: "記録に接続できませんでした。少し経ってからもう一度お試しください。",
      fromQuiz: "あなたの診断より——この家が下でハイライトされています。これに投票するか、別を選んでください。選ぶまで何も送信されません。",
      convening: "合議を招集しています……",
      notInSession: "合議は開会していません。またお越しください。",
      notReachedHere: "ここからは記録に接続できませんでした。合議は公開されたサイトで開かれます——または少し経ってからお試しください。"
    }
  };
  var T = TX[LANG] || TX.en;

  // Below this many votes a poll shows a ranked standing with subtle bars and
  // NO raw numbers ("be among the first"); at or above it, the real tallies
  // show. Inert until configured: an unset/zero value means "always reveal",
  // i.e. the previous behaviour.
  var threshold = Number(cfg.MOOT_REVEAL_THRESHOLD);
  if (!(threshold > 0)) threshold = 0;

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text) n.textContent = text;
    return n;
  }

  // Normalise a house label or key for matching, e.g. "House Whitehart" and
  // "whitehart" both become "whitehart".
  function normHouse(s) {
    return String(s == null ? "" : s).toLowerCase().replace(/^house\s+/, "").replace(/[^a-z0-9]/g, "");
  }

  // "What the Moot decided last time" — config-only, needs no network, so it
  // renders first and survives even if Supabase is unreachable. Hidden when
  // no title is set.
  function renderLastOutcome(last) {
    var card = el("article", "moot-card moot-outcome");
    card.appendChild(el("p", "moot-kind", T.decidedLast));
    card.appendChild(el("h2", "section-title", last.title));
    if (last.note && String(last.note).trim()) card.appendChild(el("p", "moot-desc", last.note));
    return card;
  }

  // A short eyebrow that tells the two questions apart at a glance. The poll
  // question text is authored in English in the data layer, so the keyword
  // match stays English; only the label shown to the reader is localized.
  function kindFor(poll) {
    var q = (poll.question || "").toLowerCase();
    if (/house/.test(q)) return T.kindHouse;
    if (/thread|chapter|scene|excerpt|\bopen|\bnext\b|topic|read|reveal|material/.test(q)) return T.kindNext;
    return T.kindQuestion;
  }

  root.innerHTML = "";
  var last = (cfg.moot && cfg.moot.lastOutcome) || null;
  if (last && last.title && String(last.title).trim()) {
    root.appendChild(renderLastOutcome(last));
  }

  var pollsBox = el("div", "moot-polls");
  root.appendChild(pollsBox);

  if (!cfg.supabaseUrl || !cfg.supabaseKey) {
    pollsBox.appendChild(el("p", "moot-note", T.notPublished));
    return;
  }

  var API = cfg.supabaseUrl + "/rest/v1";
  // Authorization mirrors apikey so PostgREST resolves the anon role reliably.
  var HEADERS = {
    apikey: cfg.supabaseKey,
    Authorization: "Bearer " + cfg.supabaseKey,
    "Content-Type": "application/json"
  };

  // One anonymous voter id per browser (never sent anywhere except the vote row).
  function voterId() {
    var id = localStorage.getItem("ew-voter");
    if (!id) {
      id = (crypto.randomUUID && crypto.randomUUID()) ||
        "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, function () {
          return Math.floor(Math.random() * 16).toString(16);
        });
      localStorage.setItem("ew-voter", id);
    }
    return id;
  }
  function votedFor(pollId) { return localStorage.getItem("ew-voted-" + pollId); }
  function markVoted(pollId, optionId) { localStorage.setItem("ew-voted-" + pollId, optionId); }

  function fetchJson(url, opts) {
    return fetch(url, opts).then(function (r) {
      if (!r.ok && r.status !== 409) throw new Error("HTTP " + r.status);
      return r.status === 409 ? { conflict: true } : (r.status === 201 ? {} : r.json());
    });
  }

  function loadPolls() {
    return fetchJson(API + "/polls?select=id,question,description,requires_auth,poll_options(id,label,detail,sort)&open=eq.true&order=sort", { headers: HEADERS });
  }
  function loadResults() {
    // Aggregated counts live in a dedicated tally table (kept in sync by a
    // trigger). It exposes only the counts; raw votes stay private under RLS.
    return fetchJson(API + "/poll_tallies?select=poll_id,option_id,votes", { headers: HEADERS });
  }
  function castVote(pollId, optionId) {
    // return=minimal is required: voters may insert a vote but may not read
    // it back, so asking PostgREST to return the row would fail the request.
    var postHeaders = {
      apikey: HEADERS.apikey,
      Authorization: HEADERS.Authorization,
      "Content-Type": "application/json",
      Prefer: "return=minimal"
    };
    return fetchJson(API + "/votes", {
      method: "POST",
      headers: postHeaders,
      body: JSON.stringify({ poll_id: pollId, option_id: optionId, voter: voterId() })
    });
  }

  /* Polls marked requires_auth ("the great questions") take signed-in votes
     through member_votes instead — one voice per account, not per browser.
     AurefoldAuth carries the member's token; RLS + the (poll_id, user_id)
     primary key enforce the one-voice rule server-side. */
  var Auth = window.AurefoldAuth || null;

  function castMemberVote(pollId, optionId) {
    return Auth.api("/member_votes", {
      method: "POST",
      body: { poll_id: pollId, option_id: optionId },
      prefer: "return=minimal"
    });
  }

  function fetchMemberVote(pollId) {
    return Auth.api("/member_votes?poll_id=eq." + encodeURIComponent(pollId) +
      "&user_id=eq." + Auth.user().id + "&select=option_id")
      .then(function (rows) { return rows && rows.length ? rows[0].option_id : null; })
      .catch(function () { return null; });
  }

  function renderPoll(poll, results) {
    var isAuthPoll = !!poll.requires_auth && !!Auth;
    var card = el("article", "moot-card" + (isAuthPoll ? " moot-card--sworn" : ""));
    card.appendChild(el("p", "moot-kind", kindFor(poll)));
    card.appendChild(el("h2", "section-title", poll.question));
    if (poll.description) card.appendChild(el("p", "moot-desc", poll.description));
    var body = el("div", "moot-body");
    var note = el("p", "moot-note");
    card.appendChild(body);
    card.appendChild(note);

    // Per-poll state: the latest tallies, and whether the server has told us
    // that changing a vote isn't allowed (a 409 on re-cast).
    var state = { results: results, changeLocked: false };

    function optionById(id) {
      for (var i = 0; i < poll.poll_options.length; i++) {
        if (poll.poll_options[i].id === id) return poll.poll_options[i];
      }
      return null;
    }

    function tallies() {
      var counts = {}, total = 0, max = 0;
      (state.results || []).forEach(function (r) {
        if (r.poll_id === poll.id) {
          counts[r.option_id] = r.votes;
          total += r.votes;
          if (r.votes > max) max = r.votes;
        }
      });
      return { counts: counts, total: total, max: max };
    }

    // Show the standing. `chosen` is the option id this reader voted for (or
    // null when peeking). Below the reveal threshold we rank the options and
    // hide raw numbers; at/above it we show real counts and percentages.
    function showResults(chosen) {
      body.innerHTML = "";
      var t = tallies();
      var revealed = t.total >= threshold;

      if (chosen) {
        var opt = optionById(chosen);
        body.appendChild(el("p", "moot-yourvoice", T.yourVoice + (opt ? opt.label : T.counted)));
      }

      var ordered = poll.poll_options.slice().sort(function (a, b) {
        var d = (t.counts[b.id] || 0) - (t.counts[a.id] || 0);
        return d !== 0 ? d : a.sort - b.sort;
      });

      ordered.forEach(function (o, i) {
        var n = t.counts[o.id] || 0;
        var isChosen = chosen === o.id;
        var row = el("div", "moot-result" + (isChosen ? " chosen" : "") + (revealed ? "" : " ranked"));
        var head = el("div", "moot-result-head");
        head.appendChild(el("span", "moot-result-label", o.label));
        if (revealed) {
          var pct = t.total ? Math.round((n * 100) / t.total) : 0;
          head.appendChild(el("span", "moot-result-count", n + T.voicesWord(n) + " · " + pct + "%"));
        } else {
          head.appendChild(el("span", "moot-result-rank", "#" + (i + 1)));
        }
        var bar = el("div", "moot-bar");
        var fill = el("div", "moot-bar-fill");
        // Revealed: width is the true share. Ranked: width is relative to the
        // leader and capped low, so it reads as "order", not "proportion".
        var w = 0;
        if (revealed) w = t.total ? Math.max(Math.round((n * 100) / t.total), 2) : 0;
        else w = t.max ? Math.round((n / t.max) * 70) : 0;
        fill.style.width = w + "%";
        bar.appendChild(fill);
        row.appendChild(head);
        row.appendChild(bar);
        body.appendChild(row);
      });

      if (chosen && !state.changeLocked) {
        var change = el("button", "moot-peek moot-change", T.changeChoice);
        change.type = "button";
        change.addEventListener("click", function () { showVoting(chosen); });
        body.appendChild(change);
      } else if (!chosen) {
        var addVoice = el("button", "moot-peek moot-change", T.addVoice);
        addVoice.type = "button";
        addVoice.addEventListener("click", function () { showVoting(null); });
        body.appendChild(addVoice);
      }

      if (revealed) {
        note.textContent = t.total ? T.heard(t.total) : T.noVoicesYet;
      } else if (chosen) {
        note.textContent = T.countedStanding;
      } else {
        note.textContent = T.earlyDays;
      }
    }

    // Show the ballot. When `prevChoice` is set the reader is changing an
    // existing vote, so we add a "keep" escape hatch and honour the server's
    // one-vote rule on submit. Sworn (requires_auth) polls ask anonymous
    // visitors to sign in first — the gate renders instead of the ballot.
    function showVoting(prevChoice) {
      body.innerHTML = "";

      if (isAuthPoll && !Auth.user()) {
        note.textContent = T.memberOnly;
        Auth.renderGate(body);
        return;
      }

      var list = el("div", "moot-options");
      poll.poll_options.slice().sort(function (a, b) { return a.sort - b.sort; }).forEach(function (o) {
        var btn = el("button", "moot-option");
        btn.type = "button";
        btn.setAttribute("data-house", normHouse(o.label));
        if (prevChoice && o.id === prevChoice) btn.className = "moot-option is-current";
        btn.appendChild(el("span", "moot-option-label", o.label + (prevChoice && o.id === prevChoice ? T.currentVoiceSuffix : "")));
        if (o.detail) btn.appendChild(el("span", "moot-option-detail", o.detail));
        btn.addEventListener("click", function () {
          if (prevChoice && o.id === prevChoice) { showResults(prevChoice); return; }
          Array.prototype.forEach.call(body.querySelectorAll(".moot-option"), function (b) { b.disabled = true; });
          (isAuthPoll ? castMemberVote(poll.id, o.id) : castVote(poll.id, o.id)).then(function (res) {
            if (prevChoice && res && res.conflict) {
              // The server keeps one vote per reader (unique on ew-voter); a
              // re-cast is refused. Reflect the stored choice and say so.
              state.changeLocked = true;
              showResults(prevChoice);
              note.textContent = T.oneVoiceKept;
              return;
            }
            markVoted(poll.id, o.id);
            return loadResults().then(function (r) { state.results = r; showResults(o.id); });
          }).catch(function () {
            Array.prototype.forEach.call(body.querySelectorAll(".moot-option"), function (b) { b.disabled = false; });
            note.textContent = T.notReached;
          });
        });
        list.appendChild(btn);
      });
      body.appendChild(list);

      if (prevChoice) {
        var keep = el("button", "moot-peek moot-change", T.keepChoice);
        keep.type = "button";
        keep.addEventListener("click", function () { showResults(prevChoice); });
        body.appendChild(keep);
        note.textContent = T.pickAnother;
      } else {
        var peek = el("button", "moot-peek", T.showStanding);
        peek.type = "button";
        peek.addEventListener("click", function () { showResults(null); });
        body.appendChild(peek);
        note.textContent = isAuthPoll ? T.onePerMember : T.onePerReader;
      }
    }

    // Sworn polls: the member's standing voice lives server-side, so it is the
    // same on every device. Anonymous polls keep the per-browser record.
    if (isAuthPoll) {
      Auth.ready.then(function () {
        if (!Auth.user()) { showVoting(null); return; }
        fetchMemberVote(poll.id).then(function (serverChoice) {
          var chosen = serverChoice || votedFor(poll.id);
          if (serverChoice) markVoted(poll.id, serverChoice);
          if (chosen) showResults(chosen);
          else showVoting(null);
        });
      });
      return card;
    }

    var chosen = votedFor(poll.id);
    if (chosen) showResults(chosen);
    else showVoting(null);
    return card;
  }

  // A reader arriving from the quiz (vote.html#house=<key>) gets the matching
  // house pre-selected in the ballot — highlighted only, never auto-cast. Does
  // nothing if they've already voted (no ballot to highlight) or find no match.
  function prehighlightFromHash(cards) {
    var m = /(?:^|[#&])house=([^&]+)/.exec(location.hash || "");
    if (!m) return;
    var raw;
    try { raw = decodeURIComponent(m[1]); } catch (e) { raw = m[1]; }
    var want = normHouse(raw);
    if (!want) return;
    for (var i = 0; i < cards.length; i++) {
      var btns = cards[i].querySelectorAll(".moot-option");
      for (var j = 0; j < btns.length; j++) {
        if (btns[j].getAttribute("data-house") === want) {
          btns[j].classList.add("is-suggested");
          btns[j].setAttribute("aria-current", "true");
          var note = cards[i].querySelector(".moot-note");
          if (note) note.textContent = T.fromQuiz;
          if (btns[j].scrollIntoView) btns[j].scrollIntoView({ block: "center" });
          return;
        }
      }
    }
  }

  pollsBox.appendChild(el("p", "moot-note", T.convening));
  Promise.all([loadPolls(), loadResults()]).then(function (all) {
    pollsBox.innerHTML = "";
    var polls = all[0], results = all[1];
    if (!polls.length) {
      pollsBox.appendChild(el("p", "moot-note", T.notInSession));
      return;
    }
    var cards = polls.map(function (p) {
      var c = renderPoll(p, results);
      pollsBox.appendChild(c);
      return c;
    });
    prehighlightFromHash(cards);
  }).catch(function () {
    pollsBox.innerHTML = "";
    pollsBox.appendChild(el("p", "moot-note", T.notReachedHere));
  });
})();
