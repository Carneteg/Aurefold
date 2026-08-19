/* AUREFOLD — House Test v2
   NON-CANON community/acquisition experience.
   Twelve moral dilemmas score affinities across the Ten Great Houses.
   Canon remains governed elsewhere; this script never declares a House morally correct. */
(function () {
  "use strict";

  var root = document.getElementById("quiz");
  if (!root) return;

  var HOUSES = {
    blackthorn: {
      name: "House Blackthorn", philosophy: "Intellect",
      strength: "You distrust improvisation when foresight can prevent avoidable harm. You want decisions to survive contact with consequences.",
      cost: "The danger is waiting for certainty until the moment for action has already passed."
    },
    ashbourne: {
      name: "House Ashbourne", philosophy: "Courage",
      strength: "You believe fear should not be allowed to make the decisive choice. Someone must move first when everyone else hesitates.",
      cost: "Courage can become momentum for its own sake, and bravery can make other people's risks feel too easy to spend."
    },
    whitehart: {
      name: "House Whitehart", philosophy: "Faith",
      strength: "You believe people need convictions deeper than calculation, especially when evidence cannot remove every uncertainty.",
      cost: "Conviction can harden into certainty, and certainty can make doubt look like moral failure."
    },
    stormrider: {
      name: "House Stormrider", philosophy: "Unity",
      strength: "You judge institutions by whether people can still act together when pressure would otherwise tear them apart.",
      cost: "Unity can become coercion when disagreement is treated as a threat to the whole."
    },
    ravenshade: {
      name: "House Ravenshade", philosophy: "Information",
      strength: "You look for what is missing, concealed or strategically withheld before accepting the story everyone else has been given.",
      cost: "When information becomes power, trust can become merely another vulnerability to manage."
    },
    ironvale: {
      name: "House Ironvale", philosophy: "Innovation",
      strength: "You would rather redesign a failing system than preserve it because people are accustomed to its flaws.",
      cost: "What can be built is not always what should be built, and the first users often pay for everyone else's learning."
    },
    blackcrest: {
      name: "House Blackcrest", philosophy: "The Victor's History",
      strength: "You understand that records, institutions and shared narratives shape what a society can remember and therefore what it can become.",
      cost: "The hand that preserves history also acquires frightening power over which version survives."
    },
    stonebear: {
      name: "House Stonebear", philosophy: "Honor",
      strength: "You believe a promise that survives only while convenient was never much of a promise. Reliability is a form of moral infrastructure.",
      cost: "An oath can outlive the conditions that made it just, turning integrity into a prison."
    },
    tidebreaker: {
      name: "House Tidebreaker", philosophy: "Knowledge",
      strength: "You want decisions grounded in accumulated understanding rather than urgency, fashion or whoever speaks loudest.",
      cost: "Knowledge guarded too carefully becomes a hierarchy, and expertise can become an excuse to keep others dependent."
    },
    phoenix: {
      name: "House Phoenix", philosophy: "The Future",
      strength: "You are willing to endure disruption now if it creates a world that could be substantially better than the one inherited.",
      cost: "The future has no voice in the room, which makes it dangerously easy to spend the people who do."
    }
  };

  var ORDER = ["blackthorn", "ashbourne", "whitehart", "stormrider", "ravenshade", "ironvale", "blackcrest", "stonebear", "tidebreaker", "phoenix"];

  function a(text, primary, secondary) {
    var scores = {};
    scores[primary] = 3;
    if (secondary) scores[secondary] = 1;
    return { text: text, primary: primary, scores: scores };
  }

  var Q = [
    {
      q: "A warning could save lives. The evidence is credible but incomplete, and publishing it may cause a deadly panic. What do you do?",
      a: [
        a("Publish now. People deserve the information needed to choose their own risk.", "ravenshade", "blackcrest"),
        a("Hold it briefly. Verify the evidence before fear becomes its own disaster.", "blackthorn", "tidebreaker"),
        a("Warn the people in immediate danger first and accept responsibility for acting before certainty.", "ashbourne", "whitehart"),
        a("Coordinate one message and one response so the warning does not fracture the community.", "stormrider", "blackthorn")
      ]
    },
    {
      q: "You swore an oath to a ruler who is now harming the people you meant to serve. Which obligation matters most?",
      a: [
        a("The oath. Break your word once and every future promise becomes cheaper.", "stonebear", "stormrider"),
        a("The people. Loyalty to a person cannot outrank the purpose the oath was meant to serve.", "whitehart", "ashbourne"),
        a("A lawful transition. Remove the ruler without teaching everyone that power changes hands by impulse.", "blackthorn", "blackcrest"),
        a("The next system. Use the crisis to replace the structure that made one person's failure so dangerous.", "phoenix", "ironvale")
      ]
    },
    {
      q: "A new machine could end a generation of dangerous labor, but its first failures will almost certainly hurt people. What should happen?",
      a: [
        a("Test it under strict limits, learn fast, and improve it until the old danger can be retired.", "ironvale", "blackthorn"),
        a("Deploy it. Every year of delay also condemns people to the dangers of the old system.", "phoenix", "ashbourne"),
        a("Study the failures first. Progress without understanding simply moves ignorance into a new shape.", "tidebreaker", "blackthorn"),
        a("Ask for volunteers who understand the risk. No one else gets to spend their bodies for progress.", "ashbourne", "stonebear")
      ]
    },
    {
      q: "An archive contains knowledge that could prevent a future catastrophe, but publishing all of it would also reveal methods that could cause one. Who should have access?",
      a: [
        a("Qualified custodians. Knowledge has responsibilities as well as value.", "tidebreaker", "stonebear"),
        a("Everyone. Concentrated control over dangerous knowledge may be more dangerous than the knowledge itself.", "ravenshade", "phoenix"),
        a("Release a public record of what exists while restricting the dangerous operational details.", "blackcrest", "blackthorn"),
        a("Build institutions capable of using it safely, then expand access as those institutions prove themselves.", "ironvale", "stormrider")
      ]
    },
    {
      q: "An enemy city surrenders after committing atrocities. Your own people demand revenge. What does victory require?",
      a: [
        a("Honor the surrender terms. Your word matters most when breaking it would be popular.", "stonebear", "blackcrest"),
        a("Public truth first: document what happened so peace cannot be built on convenient forgetting.", "blackcrest", "ravenshade"),
        a("Integrate the city quickly. A peace that leaves two peoples waiting for the next war is only an interval.", "stormrider", "whitehart"),
        a("Punish the responsible decisively, then stop. Mercy without consequence teaches the wrong lesson.", "ashbourne", "stonebear")
      ]
    },
    {
      q: "A beloved leader is making a disastrous decision. Challenging them publicly may split the coalition holding the country together. What do you do?",
      a: [
        a("Challenge them privately first. Preserve unity if the error can still be corrected without a public fracture.", "stormrider", "blackthorn"),
        a("Publish the evidence. Loyalty cannot require everyone else to remain ignorant.", "ravenshade", "blackcrest"),
        a("Prepare a succession plan before confronting them. Removing one failure should not create three new ones.", "blackthorn", "tidebreaker"),
        a("Oppose them openly. Leadership that cannot survive honest refusal has already become dangerous.", "ashbourne", "stonebear")
      ]
    },
    {
      q: "There is not enough grain for everyone until spring. Any allocation will leave someone in danger. Which principle comes first?",
      a: [
        a("Maximize survival using the best forecasts available, even if the distribution feels unequal.", "blackthorn", "tidebreaker"),
        a("Protect the most vulnerable first. A society reveals its faith by who it refuses to abandon.", "whitehart", "stonebear"),
        a("Keep enough seed and skilled labor alive to ensure this famine is not followed by another.", "phoenix", "tidebreaker"),
        a("Make the rationing collective and visible so every district carries part of the burden.", "stormrider", "blackcrest")
      ]
    },
    {
      q: "A law is orderly, popular and clearly unjust to a small minority. What is the strongest reason to change it?",
      a: [
        a("Justice does not become less binding because the injured group is small.", "whitehart", "stonebear"),
        a("A system that cannot correct known injustice is badly designed and should be rebuilt.", "ironvale", "phoenix"),
        a("Minorities often see failures that majorities are structurally protected from noticing.", "ravenshade", "tidebreaker"),
        a("Because leaving the injustice in place makes future conflict more dangerous for everyone.", "stormrider", "blackthorn")
      ]
    },
    {
      q: "Two witnesses give incompatible accounts of the same killing. Both appear sincere. What belongs in the official record?",
      a: [
        a("Both accounts, clearly separated. The record should preserve disagreement rather than manufacture certainty.", "blackcrest", "tidebreaker"),
        a("Only what can be independently verified. A record should not give rumor the weight of fact.", "blackthorn", "tidebreaker"),
        a("The contradictions themselves. What each witness could not know may matter more than what they say.", "ravenshade", "blackcrest"),
        a("A provisional account with an explicit duty to revise it when better evidence appears.", "ironvale", "blackthorn")
      ]
    },
    {
      q: "A conquered region can be made peaceful faster by replacing its customs with your own institutions. What do you do?",
      a: [
        a("Keep local customs wherever they do not violate the peace. Rule that erases dignity breeds another rebellion.", "stonebear", "whitehart"),
        a("Create shared institutions that require both peoples to depend on one another.", "stormrider", "ironvale"),
        a("Preserve both legal traditions in the record before deciding what can actually coexist.", "blackcrest", "tidebreaker"),
        a("Replace the parts that fail and keep the parts that work. Tradition is evidence, not a veto.", "ironvale", "phoenix")
      ]
    },
    {
      q: "Your closest friend is accused of treason. The evidence is weak, but your public defense could destroy your own position. What do you owe them?",
      a: [
        a("Stand beside them until proof exists. Friendship that disappears under accusation is only convenience.", "stonebear", "whitehart"),
        a("Find out what everyone is missing before choosing loyalty or condemnation.", "ravenshade", "blackthorn"),
        a("Defend the standard, not the person: no punishment without evidence, whoever is accused.", "blackcrest", "stonebear"),
        a("Risk your position. Institutions become cowardly when everyone waits for someone safer to speak first.", "ashbourne", "whitehart")
      ]
    },
    {
      q: "A project could transform life for the next century, but the people alive today will bear most of its cost. When is that sacrifice justified?",
      a: [
        a("When the future gain is large enough. Refusing every present cost can be another way of stealing from people not yet born.", "phoenix", "blackthorn"),
        a("Only after exhausting designs that distribute the cost more fairly. Innovation should solve the moral problem too.", "ironvale", "whitehart"),
        a("Only if those paying the price have a real voice in the decision.", "stormrider", "stonebear"),
        a("Only when the evidence is strong enough to distinguish a future from a promise about one.", "tidebreaker", "ravenshade")
      ]
    }
  ];

  var picks = [];

  function el(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text != null) node.textContent = text;
    return node;
  }

  function hrefForHouse(key) {
    return "house-" + key + ".html";
  }

  function tally() {
    var scores = {};
    var primary = {};
    ORDER.forEach(function (h) { scores[h] = 0; primary[h] = 0; });
    picks.forEach(function (choice, i) {
      if (choice == null) return;
      var answer = Q[i].a[choice];
      Object.keys(answer.scores).forEach(function (h) { scores[h] += answer.scores[h]; });
      primary[answer.primary] += 1;
    });
    return ORDER.slice().sort(function (aKey, bKey) {
      if (scores[bKey] !== scores[aKey]) return scores[bKey] - scores[aKey];
      if (primary[bKey] !== primary[aKey]) return primary[bKey] - primary[aKey];
      return ORDER.indexOf(aKey) - ORDER.indexOf(bKey);
    });
  }

  function renderQuestion(i) {
    root.innerHTML = "";

    var progress = el("p", "quiz-progress", "Dilemma " + (i + 1) + " of " + Q.length);
    root.appendChild(progress);

    var rule = el("div", "quiz-rule");
    rule.setAttribute("aria-hidden", "true");
    rule.appendChild(el("span", "quiz-rule-mark"));
    root.appendChild(rule);

    root.appendChild(el("h2", "quiz-question", Q[i].q));
    var list = el("div", "quiz-options");

    Q[i].a.forEach(function (opt, idx) {
      var b = el("button", "quiz-option", opt.text);
      b.type = "button";
      b.addEventListener("click", function () {
        picks[i] = idx;
        picks = picks.slice(0, i + 1);
        if (i + 1 < Q.length) renderQuestion(i + 1);
        else renderResult();
      });
      list.appendChild(b);
    });
    root.appendChild(list);

    if (i > 0) {
      var back = el("button", "btn btn-ghost", "← Back");
      back.type = "button";
      back.addEventListener("click", function () { renderQuestion(i - 1); });
      root.appendChild(back);
    }
  }

  function renderResult(sharedKey) {
    var ranking = sharedKey && HOUSES[sharedKey] ? [sharedKey].concat(ORDER.filter(function (h) { return h !== sharedKey; })) : tally();
    var best = ranking[0];
    var second = ranking[1];
    var house = HOUSES[best];

    root.innerHTML = "";
    var card = el("div", "quiz-result");
    card.style.setProperty("--hc", "var(--house-" + best + ")");

    var sigil = document.createElement("img");
    sigil.className = "result-sigil";
    sigil.src = "assets/sigils/" + best + ".webp";
    sigil.alt = "";
    sigil.onerror = function () {
      if (this.dataset.f) this.hidden = true;
      else { this.dataset.f = "1"; this.src = "assets/sigils/" + best + ".png"; }
    };
    card.appendChild(sigil);

    card.appendChild(el("p", "quiz-result-eyebrow", sharedKey ? "A SHARED HOUSE" : "YOUR STRONGEST AFFINITY"));
    card.appendChild(el("h2", "quiz-result-house", house.name));
    card.appendChild(el("p", "quiz-result-phil", house.philosophy));

    var strength = el("p", "quiz-result-line");
    strength.innerHTML = "<strong>What draws you:</strong> " + house.strength;
    card.appendChild(strength);

    var cost = el("p", "world-note");
    cost.innerHTML = "<strong>What it can cost:</strong> " + house.cost;
    card.appendChild(cost);

    if (!sharedKey && second && HOUSES[second]) {
      var counter = el("p", "world-note");
      counter.innerHTML = "<strong>Your closest counterweight:</strong> " + HOUSES[second].name + " — " + HOUSES[second].philosophy + ".";
      card.appendChild(counter);
    }

    var row = el("div", "cta-row");
    var read = el("a", "btn btn-primary", "Read about " + house.name.replace(/^House /, ""));
    read.href = hrefForHouse(best);
    row.appendChild(read);

    if (!sharedKey) {
      var moot = el("a", "btn btn-ghost", "Take the Ledger Question");
      moot.href = "vote.html?house=" + encodeURIComponent(best);
      row.appendChild(moot);
    }
    card.appendChild(row);

    if (!sharedKey) {
      var shareTitle = el("p", "world-note", "Make the argument harder: send your House to someone who will disagree.");
      card.appendChild(shareTitle);

      var shareRow = el("div", "cta-row");
      var shareUrl = new URL(location.href);
      shareUrl.search = "?result=" + encodeURIComponent(best);
      var shareText = "My strongest Aurefold affinity is " + house.name + ". Which House would you follow?";

      var share = el("button", "btn btn-ghost", navigator.share ? "Share result" : "Copy result link");
      share.type = "button";
      share.addEventListener("click", function () {
        if (navigator.share) {
          navigator.share({ title: "My Aurefold House", text: shareText, url: shareUrl.toString() }).catch(function () {});
        } else if (navigator.clipboard) {
          navigator.clipboard.writeText(shareUrl.toString()).then(function () { share.textContent = "Copied"; });
        }
      });
      shareRow.appendChild(share);

      var patreon = el("a", "btn btn-ghost", "Join Aurefold free");
      patreon.href = "https://www.patreon.com/AUREFOLD";
      patreon.target = "_blank";
      patreon.rel = "noopener";
      shareRow.appendChild(patreon);
      card.appendChild(shareRow);

      try {
        localStorage.setItem("aurefold-house-test-v2", JSON.stringify({ house: best, counterweight: second, at: new Date().toISOString() }));
      } catch (e) {}
      if (typeof window.gtag === "function") window.gtag("event", "house_test_complete", { house: best, counterweight: second });
    } else {
      var take = el("button", "btn btn-primary", "Take the 12-dilemma test");
      take.type = "button";
      take.addEventListener("click", function () {
        history.replaceState({}, "", location.pathname);
        picks = [];
        renderQuestion(0);
      });
      card.appendChild(take);
    }

    var note = el("p", "world-note", "This test is a community experience, not canon. No House is the correct moral answer, and no result says what you should believe.");
    card.appendChild(note);
    root.appendChild(card);
  }

  var shared = new URLSearchParams(location.search).get("result");
  if (shared && HOUSES[shared]) renderResult(shared);
  else renderQuestion(0);
})();
