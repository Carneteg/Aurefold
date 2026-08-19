/* AUREFOLD — House Test v1.0
   Community identity feature. NOT CANON.
   Twelve morally difficult questions map to the Ten Great Houses without any
   House being treated as the correct answer. One anonymous result per browser
   may be recorded in Supabase; raw rows are not publicly readable. */
(function () {
  "use strict";

  var root = document.getElementById("house-quiz");
  var start = document.getElementById("house-quiz-start");
  var cfg = window.AUREFOLD_COMMUNITY || {};
  var houses = window.AUREFOLD_HOUSES || [];
  if (!root || !start || !houses.length) return;

  var houseById = {};
  houses.forEach(function (h) { houseById[h.id] = h; });

  var RESULT_COPY = {
    blackthorn: "You tend to trust judgment before impulse. You are willing to carry the burden of deciding what matters most, but the danger is waiting for certainty until the moment for action has passed.",
    ashbourne: "You would rather accept the cost of action than hide behind caution. Courage can save people when hesitation becomes its own decision — and can also turn conviction into momentum nobody knows how to stop.",
    whitehart: "You are drawn to commitments that bind people beyond immediate advantage: trust, belief, duty and meaning. That can hold a community together when evidence runs thin — and can make doubt feel like betrayal.",
    stormrider: "You instinctively protect the whole. Unity can turn frightened individuals into something capable of surviving together, but the price appears when the group asks a person to surrender too much of themselves.",
    ravenshade: "You believe survival begins with knowing what others do not. Information can prevent disasters and expose lies, but the keeper of secrets eventually has to decide who deserves the truth.",
    ironvale: "You look for the thing that can be changed, tested or built better. Innovation creates possibilities older systems cannot imagine, but every useful experiment asks someone to live with its failures.",
    blackcrest: "You notice that societies do not live on facts alone; they live on the stories that organize those facts. A shared record can prevent chaos — and can quietly decide which people disappear from memory.",
    stonebear: "You place unusual weight on keeping faith with a promise once it has been made. Honor makes trust possible between people who cannot control one another, but a kept word can become cruel when circumstances change.",
    tidebreaker: "You want the record before the verdict. Knowledge protects against confident error and inherited lies, yet gathering more evidence can become another way of postponing the moment when somebody must decide.",
    phoenix: "You are willing to leave inherited arrangements behind when they no longer serve the future. Reinvention can break cycles everyone else accepts as permanent — and can dismiss losses that cannot simply be redesigned away."
  };

  var questions = [
    {
      q: "A city may panic if you publish a warning that is probably true but not fully verified. What do you do?",
      a: [
        { t: "Publish the evidence", d: "People deserve the truth even if they use it badly.", s: { ravenshade: 2, tidebreaker: 2, ashbourne: 1 } },
        { t: "Release only what can be acted on", d: "Give people enough truth to protect themselves without amplifying uncertainty.", s: { blackthorn: 2, stormrider: 1, tidebreaker: 1 } },
        { t: "Hold it until a response is ready", d: "Information without the means to act can become another form of harm.", s: { stormrider: 2, blackcrest: 1, whitehart: 1 } }
      ]
    },
    {
      q: "A rescue party cannot reach everyone before the storm closes the pass. How should they choose?",
      a: [
        { t: "Save those with the best chance", d: "A terrible choice is still a choice; maximize the lives that can actually be saved.", s: { blackthorn: 2, ironvale: 1, tidebreaker: 1 } },
        { t: "Go first to the most vulnerable", d: "Need matters most precisely when efficiency argues otherwise.", s: { whitehart: 2, stonebear: 1, ashbourne: 1 } },
        { t: "Keep the rescue line together", d: "Do not trade the safety of the whole party for isolated victories.", s: { stormrider: 2, stonebear: 1, blackthorn: 1 } }
      ]
    },
    {
      q: "You gave your word years ago. Keeping it now will harm people you never expected to be involved.",
      a: [
        { t: "Keep the oath", d: "A promise that survives only convenient circumstances was never much of a promise.", s: { stonebear: 2, whitehart: 1 } },
        { t: "Break it openly", d: "Accept the shame yourself rather than make strangers pay for your old decision.", s: { ashbourne: 2, phoenix: 1, blackcrest: 1 } },
        { t: "Honor the purpose, not the wording", d: "The obligation matters; the exact form can change when reality does.", s: { blackthorn: 2, ironvale: 1, phoenix: 1 } }
      ]
    },
    {
      q: "A new invention could prevent thousands of deaths, but its long-term failures are not understood.",
      a: [
        { t: "Deploy it now", d: "Known suffering is not morally safer than uncertain risk.", s: { phoenix: 2, ironvale: 2, ashbourne: 1 } },
        { t: "Test it in controlled use", d: "Move fast enough to learn, slowly enough to notice whom the failures hurt.", s: { ironvale: 2, tidebreaker: 1, blackthorn: 1 } },
        { t: "Wait for stronger proof", d: "A cure can become a catastrophe when urgency replaces evidence.", s: { tidebreaker: 2, blackthorn: 1, stonebear: 1 } }
      ]
    },
    {
      q: "A war ends. The victors need one public account of what happened, but witnesses contradict one another.",
      a: [
        { t: "Write a single usable record", d: "A society cannot govern itself through endless incompatible versions.", s: { blackcrest: 2, stormrider: 1, blackthorn: 1 } },
        { t: "Preserve every contradiction", d: "Future certainty is less important than not erasing what people actually said.", s: { tidebreaker: 2, ravenshade: 2 } },
        { t: "Keep a common account and the dissent beside it", d: "People need a shared story, but not at the price of pretending disagreement never existed.", s: { blackcrest: 1, stormrider: 1, whitehart: 1, tidebreaker: 1 } }
      ]
    },
    {
      q: "A beloved leader is clearly failing, but removing them may fracture the coalition holding the country together.",
      a: [
        { t: "Remove them publicly", d: "A leader who cannot serve must not become more important than the people they lead.", s: { ashbourne: 2, phoenix: 1, stonebear: 1 } },
        { t: "Prepare the succession first", d: "Correct action at the wrong moment can destroy the thing it was meant to save.", s: { blackthorn: 2, stormrider: 2 } },
        { t: "Keep the symbol, move the power", d: "Continuity may matter more than whether the public structure matches the private one.", s: { ravenshade: 2, blackcrest: 2 } }
      ]
    },
    {
      q: "A secret source warns you of an attack. Revealing the evidence will almost certainly expose the source.",
      a: [
        { t: "Reveal it", d: "A protected source cannot outweigh lives that can still be saved.", s: { ashbourne: 2, stormrider: 1, whitehart: 1 } },
        { t: "Act without revealing why", d: "Use the information while protecting the person who made action possible.", s: { ravenshade: 2, blackthorn: 2 } },
        { t: "Refuse to act on untestable evidence", d: "Power based on secrets becomes impossible for anyone else to challenge.", s: { tidebreaker: 2, stonebear: 1, blackcrest: 1 } }
      ]
    },
    {
      q: "Food will not last the winter. Every rationing system will leave someone worse off.",
      a: [
        { t: "Divide it equally", d: "Shared hardship is the only rule people can survive without turning on one another.", s: { stormrider: 2, stonebear: 1, whitehart: 1 } },
        { t: "Prioritize those the settlement depends on", d: "Equal portions mean little if the systems keeping everyone alive collapse.", s: { blackthorn: 2, ironvale: 1, tidebreaker: 1 } },
        { t: "Let each community set its own ration", d: "People closest to the cost understand needs a central rule cannot see.", s: { phoenix: 1, whitehart: 1, ravenshade: 1, ashbourne: 1 } }
      ]
    },
    {
      q: "A court cannot prove an accused person guilty, but releasing them may cause political violence.",
      a: [
        { t: "Release them", d: "A verdict cannot become whatever stability requires it to be.", s: { tidebreaker: 2, stonebear: 2 } },
        { t: "Choose the verdict that prevents bloodshed", d: "Institutions exist inside society; consequences do not disappear because procedure is clean.", s: { stormrider: 2, blackcrest: 1, blackthorn: 1 } },
        { t: "Refuse a final verdict", d: "Uncertainty should remain visible rather than being converted into false certainty.", s: { tidebreaker: 2, blackthorn: 1, ravenshade: 1 } }
      ]
    },
    {
      q: "People fleeing an enemy arrive at your border. You know hostile agents may be hidden among them.",
      a: [
        { t: "Open the border", d: "People in immediate danger should not pay for crimes they may have nothing to do with.", s: { whitehart: 2, ashbourne: 1, stormrider: 1 } },
        { t: "Screen every arrival", d: "Compassion without verification can hand an enemy access to everyone already inside.", s: { ravenshade: 2, blackthorn: 1, tidebreaker: 1 } },
        { t: "Build a protected settlement outside the old system", d: "If the existing choices are both unacceptable, create a third structure.", s: { phoenix: 2, ironvale: 2, stormrider: 1 } }
      ]
    },
    {
      q: "A comforting national story is probably false, but belief in it helps hold rival communities together.",
      a: [
        { t: "Expose the falsehood", d: "A peace that requires people not to know what happened is already compromised.", s: { tidebreaker: 2, ravenshade: 2 } },
        { t: "Protect the story", d: "Shared meaning can be socially real even when the historical claim beneath it is uncertain.", s: { whitehart: 2, stormrider: 1, blackcrest: 1 } },
        { t: "Replace it gradually", d: "Do not destroy an old structure until something more honest can carry its weight.", s: { phoenix: 2, blackcrest: 1, ironvale: 1 } }
      ]
    },
    {
      q: "Peace is possible, but only if your side makes a public apology many citizens believe is humiliating and unfair.",
      a: [
        { t: "Make the apology", d: "If your pride costs other people another war, pride is too expensive.", s: { stormrider: 2, stonebear: 1, whitehart: 1 } },
        { t: "Refuse it", d: "Peace purchased by saying what you believe is false teaches everyone that coercion works.", s: { ashbourne: 2, stonebear: 2 } },
        { t: "Find words both sides can live with", d: "Language is not decoration; sometimes the shape of the record is what makes coexistence possible.", s: { blackcrest: 2, ravenshade: 1, blackthorn: 1 } }
      ]
    }
  ];

  var index = 0;
  var answers = [];
  var scores = {};
  var strongHits = {};
  houses.forEach(function (h) { scores[h.id] = 0; strongHits[h.id] = 0; });

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) { return ({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"})[c]; });
  }

  function track(name, params) {
    if (typeof window.gtag === "function") window.gtag("event", name, params || {});
  }

  function renderQuestion() {
    var q = questions[index];
    var pct = Math.round((index / questions.length) * 100);
    root.innerHTML = '<div class="quiz-card">' +
      '<div class="quiz-progress"><div class="quiz-progress-track"><div class="quiz-progress-bar" style="width:' + pct + '%"></div></div><span class="quiz-progress-label">' + (index + 1) + ' / ' + questions.length + '</span></div>' +
      '<h2 class="quiz-question">' + esc(q.q) + '</h2>' +
      '<div class="quiz-options">' + q.a.map(function (a, i) {
        return '<button class="quiz-option" type="button" data-choice="' + i + '"><strong>' + esc(a.t) + '</strong><span>' + esc(a.d) + '</span></button>';
      }).join('') + '</div></div>';

    Array.prototype.forEach.call(root.querySelectorAll("[data-choice]"), function (btn) {
      btn.addEventListener("click", function () { choose(Number(btn.getAttribute("data-choice"))); });
    });
  }

  function choose(choiceIndex) {
    var opt = questions[index].a[choiceIndex];
    answers.push(choiceIndex);
    Object.keys(opt.s).forEach(function (id) {
      scores[id] += opt.s[id];
      if (opt.s[id] >= 2) strongHits[id] += 1;
    });
    index += 1;
    if (index < questions.length) renderQuestion();
    else finish();
  }

  function rankedResults() {
    return houses.slice().sort(function (a, b) {
      if (scores[b.id] !== scores[a.id]) return scores[b.id] - scores[a.id];
      if (strongHits[b.id] !== strongHits[a.id]) return strongHits[b.id] - strongHits[a.id];
      return a.name.localeCompare(b.name);
    });
  }

  function getBrowserId() {
    var key = "aurefold-house-quiz-browser-v1";
    var id = localStorage.getItem(key);
    if (id) return id;
    if (window.crypto && typeof window.crypto.randomUUID === "function") id = window.crypto.randomUUID();
    else id = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c){var r=Math.random()*16|0,v=c==='x'?r:(r&3|8);return v.toString(16);});
    localStorage.setItem(key, id);
    return id;
  }

  function recordResult(primary) {
    if (!cfg.supabaseUrl || !cfg.supabaseKey) return Promise.resolve(false);
    var body = {
      browser_id: getBrowserId(),
      house_key: primary.id,
      locale: (document.documentElement.lang || "en").slice(0, 12),
      source: "house-test-v1",
      scores: scores
    };
    return fetch(cfg.supabaseUrl + "/rest/v1/house_quiz_results", {
      method: "POST",
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: "Bearer " + cfg.supabaseKey,
        "Content-Type": "application/json",
        Prefer: "return=minimal"
      },
      body: JSON.stringify(body)
    }).then(function (r) {
      if (r.ok || r.status === 409) return true;
      throw new Error("quiz result not recorded");
    }).catch(function () { return false; });
  }

  function loadDistribution() {
    if (!cfg.supabaseUrl || !cfg.supabaseKey) return Promise.resolve(null);
    return fetch(cfg.supabaseUrl + "/rest/v1/house_quiz_tallies?select=house_key,result_count&order=result_count.desc", {
      headers: { apikey: cfg.supabaseKey, Authorization: "Bearer " + cfg.supabaseKey }
    }).then(function (r) { if (!r.ok) throw new Error(); return r.json(); })
      .then(function (rows) {
        var total = rows.reduce(function (n, r) { return n + Number(r.result_count || 0); }, 0);
        if (total < 20) return null;
        return { rows: rows, total: total };
      }).catch(function () { return null; });
  }

  function distributionHtml(data) {
    if (!data) return "";
    return '<section class="quiz-distribution"><h3>Where readers are landing</h3><p>' + data.total + ' anonymous completed results. This is community data, not a verdict on the Houses.</p><div class="quiz-distribution-list">' +
      data.rows.map(function (r) {
        var h = houseById[r.house_key];
        var pct = Math.round((Number(r.result_count) / data.total) * 100);
        return '<div class="quiz-distribution-row"><span>' + esc(h ? h.name.replace("House ", "") : r.house_key) + '</span><div class="quiz-distribution-track"><div class="quiz-distribution-fill" style="width:' + pct + '%"></div></div><strong>' + pct + '%</strong></div>';
      }).join('') + '</div></section>';
  }

  function finish() {
    var ranked = rankedResults();
    var primary = ranked[0];
    var secondary = ranked[1];
    var close = secondary && (scores[primary.id] - scores[secondary.id] <= 2);
    localStorage.setItem("aurefold-house-quiz-result-v1", primary.id);
    localStorage.setItem("aurefold_house_result", primary.id);
    track("house_quiz_complete", { house: primary.id });

    root.innerHTML = '<div class="quiz-loading">The archive is counting your choices…</div>';

    Promise.all([recordResult(primary), loadDistribution()]).then(function (parts) {
      var patreon = cfg.support && cfg.support.patreon;
      var shareText = "My Aurefold House is " + primary.name + " — " + primary.philosophy + ". Which House are you?";
      root.innerHTML = '<div class="quiz-result">' +
        '<p class="quiz-result-kicker">YOUR BANNER LEANS TOWARD</p>' +
        '<h2 class="quiz-result-title">' + esc(primary.name) + '</h2>' +
        '<div class="quiz-result-philosophy">' + esc(primary.philosophy) + '</div>' +
        '<p class="quiz-result-copy">' + esc(RESULT_COPY[primary.id]) + '</p>' +
        (close ? '<p class="quiz-secondary"><strong>Close second:</strong> ' + esc(secondary.name) + ' — ' + esc(secondary.philosophy) + '. Your answers sit near the border between these two instincts.</p>' : '') +
        '<div class="quiz-result-actions">' +
          '<button class="btn btn-primary" type="button" id="quiz-share">Share my House</button>' +
          '<a class="btn btn-ghost" href="community.html?house=' + encodeURIComponent(primary.id) + '">Take my place under the Banner</a>' +
          '<a class="btn btn-ghost" href="vote.html?house=' + encodeURIComponent(primary.id) + '">Bring it to the Moot</a>' +
          (patreon ? '<a class="btn btn-ghost" href="' + esc(patreon) + '" target="_blank" rel="noopener" id="quiz-patreon">Join Aurefold free</a>' : '') +
        '</div><p class="quiz-share-status" id="quiz-share-status" role="status"></p>' +
        distributionHtml(parts[1]) +
        '<button class="linklike quiz-retake" type="button" id="quiz-retake">Retake the test</button>' +
        '</div>';

      var share = document.getElementById("quiz-share");
      var status = document.getElementById("quiz-share-status");
      share.addEventListener("click", function () {
        var payload = { title: "My Aurefold House", text: shareText, url: location.origin + "/house-test.html" };
        if (navigator.share) {
          navigator.share(payload).then(function () { status.textContent = "Shared."; track("house_quiz_share", { house: primary.id, method: "native" }); }).catch(function () {});
        } else if (navigator.clipboard) {
          navigator.clipboard.writeText(shareText + " " + payload.url).then(function () { status.textContent = "Result copied to your clipboard."; track("house_quiz_share", { house: primary.id, method: "clipboard" }); });
        }
      });

      var p = document.getElementById("quiz-patreon");
      if (p) p.addEventListener("click", function () { track("house_quiz_patreon_click", { house: primary.id }); });
      document.getElementById("quiz-retake").addEventListener("click", function () {
        index = 0; answers = []; scores = {}; strongHits = {};
        houses.forEach(function (h) { scores[h.id] = 0; strongHits[h.id] = 0; });
        renderQuestion();
        root.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });
  }

  start.addEventListener("click", function () {
    track("house_quiz_start");
    renderQuestion();
    root.scrollIntoView({ behavior: "smooth", block: "start" });
  });
})();
