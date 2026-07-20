/* AUREFOLD — "Which of the Ten Houses would you follow?" A shareable quiz.
   Uses only the public house philosophies (locked canon; no spoilers). */
(function () {
  "use strict";
  var root = document.getElementById("quiz");
  if (!root) return;

  var HOUSES = {
    blackthorn:  { name: "House Blackthorn",  phil: "Intellect",           line: "They plan for every future — and act a moment too late." },
    ravenshade:  { name: "House Ravenshade",  phil: "Information",          line: "They trade in what people would rather keep hidden." },
    ashbourne:   { name: "House Ashbourne",   phil: "Courage",             line: "They ride at the thing everyone else flinches from." },
    whitehart:   { name: "House Whitehart",   phil: "Faith",               line: "They listen for a voice — and test those who claim to hear it." },
    stormrider:  { name: "House Stormrider",  phil: "Unity",               line: "They hold people together — as long as the one who binds them lives." },
    ironvale:    { name: "House Ironvale",    phil: "Innovation",          line: "They measure everything, and build what no one else dares." },
    blackcrest:  { name: "House Blackcrest",  phil: "the victor's history", line: "They keep the record — and the record is a kind of power." },
    stonebear:   { name: "House Stonebear",   phil: "Honor",               line: "They keep their word past the point it costs them everything." },
    tidebreaker: { name: "House Tidebreaker", phil: "Knowledge",           line: "They chart all of it, and share almost none." },
    phoenix:     { name: "House Phoenix",     phil: "the future",          line: "They build on scorched ground and refuse to look down." }
  };

  var Q = [
    { q: "A hard decision looms. What do you trust most?", a: [
      ["A careful plan for every outcome.", "blackthorn"],
      ["What I can find out that others can't.", "ravenshade"],
      ["My own nerve.", "ashbourne"],
      ["What I believe to be true.", "whitehart"] ] },
    { q: "The realm is fracturing. Your first instinct is to—", a: [
      ["Hold everyone together.", "stormrider"],
      ["Build something new from the pieces.", "ironvale"],
      ["Make sure the true account survives.", "blackcrest"],
      ["Keep the oath I swore, whatever it costs.", "stonebear"] ] },
    { q: "People would say your greatest strength is—", a: [
      ["I understand more than I let on.", "tidebreaker"],
      ["I never give up on tomorrow.", "phoenix"],
      ["I think three moves ahead.", "blackthorn"],
      ["I'm simply not afraid.", "ashbourne"] ] },
    { q: "A stranger asks for your help. You—", a: [
      ["Weigh what it will cost me first.", "blackthorn"],
      ["Ask what they're not telling me.", "ravenshade"],
      ["Help — and keep my word on it.", "stonebear"],
      ["Trust the impulse to do right.", "whitehart"] ] },
    { q: "Which sounds most like you?", a: [
      ["Knowledge is worth more than gold.", "tidebreaker"],
      ["Unity is worth more than being right.", "stormrider"],
      ["The story we tell becomes the truth.", "blackcrest"],
      ["The future is worth any fire.", "phoenix"] ] },
    { q: "When everything goes wrong, you—", a: [
      ["Rebuild, better than before.", "phoenix"],
      ["Charge the problem head-on.", "ashbourne"],
      ["Find the fact everyone missed.", "ravenshade"],
      ["Stand by what I promised.", "stonebear"] ] }
  ];

  var answers = [];

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function render(i) {
    root.innerHTML = "";
    var total = Q.length;
    var prog = el("p", "quiz-progress", "Question " + (i + 1) + " of " + total);
    root.appendChild(prog);
    var bar = el("div", "quiz-bar");
    var fill = el("div", "quiz-bar-fill");
    fill.style.width = Math.round((i / total) * 100) + "%";
    bar.appendChild(fill); root.appendChild(bar);

    root.appendChild(el("h2", "quiz-question", Q[i].q));
    var list = el("div", "quiz-options");
    Q[i].a.forEach(function (opt) {
      var b = el("button", "quiz-option", opt[0]);
      b.type = "button";
      b.addEventListener("click", function () {
        answers[i] = opt[1];
        if (i + 1 < total) render(i + 1); else result();
      });
      list.appendChild(b);
    });
    root.appendChild(list);
    if (i > 0) {
      var back = el("button", "quiz-back", "← Back");
      back.type = "button";
      back.addEventListener("click", function () { render(i - 1); });
      root.appendChild(back);
    }
  }

  function result() {
    var tally = {};
    answers.forEach(function (h) { tally[h] = (tally[h] || 0) + 1; });
    // highest score; ties broken by earliest appearance in answers
    var best = null, bestN = -1;
    answers.forEach(function (h) {
      if (tally[h] > bestN) { bestN = tally[h]; best = h; }
    });
    var house = HOUSES[best];

    root.innerHTML = "";
    var card = el("div", "quiz-result");
    card.appendChild(el("p", "quiz-result-eyebrow", "YOU WOULD FOLLOW"));
    card.appendChild(el("h2", "quiz-result-house", house.name));
    card.appendChild(el("p", "quiz-result-phil", house.phil));
    card.appendChild(el("p", "quiz-result-line", "“" + house.line + "”"));

    var shortName = house.name.replace(/^House\s+/, "");
    var pageUrl = "https://aurefold.com/quiz.html";
    var shareText = "I'm House " + shortName + " in Aurefold — which house are you?";

    // Primary next steps: carry the result into the Moot, or follow the journey.
    var row = el("div", "cta-row");
    row.style.justifyContent = "center";

    // Pre-fills the matching option in the Moot's house poll (never submits).
    var a1 = el("a", "btn btn-primary", "Cast this as your vote in The Moot");
    a1.href = "vote.html#house=" + encodeURIComponent(best);

    // "Follow free" uses whatever support link is configured — no hardcoded URL.
    var sup = ((window.AUREFOLD_COMMUNITY || {}).support) || {};
    var followUrl = (sup.patreon && String(sup.patreon).trim()) ? String(sup.patreon).trim() : "support.html";
    var a2 = el("a", "btn btn-ghost", "Follow free");
    a2.href = followUrl;
    if (/^https?:/i.test(followUrl)) { a2.target = "_blank"; a2.rel = "noopener"; }

    row.appendChild(a1); row.appendChild(a2);
    card.appendChild(row);

    // Share chips reuse the site-wide .share-row pattern; the Copy chip uses the
    // shared [data-copy] handler in site.js. Nothing shares or copies on its own.
    var shareBlock = el("div", "share-block");
    shareBlock.appendChild(el("p", "share-label", "Tell them which house you'd follow"));
    var share = el("div", "share-row");
    var enc = encodeURIComponent, t = enc(shareText), u = enc(pageUrl);
    [
      ["Share on X", "https://twitter.com/intent/tweet?text=" + t + "&url=" + u],
      ["Facebook", "https://www.facebook.com/sharer/sharer.php?u=" + u],
      ["Reddit", "https://www.reddit.com/submit?url=" + u + "&title=" + t]
    ].forEach(function (l) {
      var a = el("a", "share-btn", l[0]);
      a.href = l[1]; a.target = "_blank"; a.rel = "noopener";
      share.appendChild(a);
    });
    var copy = el("button", "share-btn", "Copy");
    copy.type = "button";
    copy.setAttribute("data-copy", shareText + " " + pageUrl);
    share.appendChild(copy);
    shareBlock.appendChild(share);
    card.appendChild(shareBlock);

    var again = el("button", "quiz-back", "↻ Take it again");
    again.type = "button";
    again.addEventListener("click", function () { answers = []; render(0); });
    card.appendChild(again);

    card.appendChild(el("p", "quiz-note", "The book's canon and central mysteries are the author's; the Moot and this quiz shape the world around it — what the archive opens or explores next — never the story's heart."));
    root.appendChild(card);

    if (window.plausible) window.plausible("Quiz result", { props: { house: house.name } });
  }

  render(0);
})();
