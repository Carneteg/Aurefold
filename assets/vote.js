/* AUREFOLD — the moot: load open polls, cast one vote per visitor, show results. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var root = document.getElementById("moot");
  if (!root || !cfg.supabaseUrl) return;

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
    return fetchJson(API + "/polls?select=id,question,description,poll_options(id,label,detail,sort)&open=eq.true&order=sort", { headers: HEADERS });
  }
  function loadResults() {
    return fetchJson(API + "/poll_results?select=poll_id,option_id,votes", { headers: HEADERS });
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

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text) n.textContent = text;
    return n;
  }

  function renderResults(card, poll, results, chosen) {
    var list = card.querySelector(".moot-options");
    list.innerHTML = "";
    var counts = {}, total = 0;
    (results || []).forEach(function (r) {
      if (r.poll_id === poll.id) { counts[r.option_id] = r.votes; total += r.votes; }
    });
    poll.poll_options.sort(function (a, b) { return a.sort - b.sort; }).forEach(function (o) {
      var n = counts[o.id] || 0;
      var pct = total ? Math.round((n * 100) / total) : 0;
      var row = el("div", "moot-result" + (chosen === o.id ? " chosen" : ""));
      var head = el("div", "moot-result-head");
      head.appendChild(el("span", "moot-result-label", o.label + (chosen === o.id ? " — your voice" : "")));
      head.appendChild(el("span", "moot-result-count", n + (n === 1 ? " voice" : " voices") + " · " + pct + "%"));
      var bar = el("div", "moot-bar");
      var fill = el("div", "moot-bar-fill");
      fill.style.width = (total ? Math.max(pct, 2) : 0) + "%";
      bar.appendChild(fill);
      row.appendChild(head); row.appendChild(bar);
      list.appendChild(row);
    });
    var note = card.querySelector(".moot-note");
    note.textContent = total === 0 ? "No voices yet. Yours would be the first."
      : "The moot has heard " + total + (total === 1 ? " voice." : " voices.");
  }

  function renderPoll(poll, results) {
    var card = el("article", "moot-card");
    card.appendChild(el("h2", "section-title", poll.question));
    if (poll.description) card.appendChild(el("p", "moot-desc", poll.description));
    var list = el("div", "moot-options");
    card.appendChild(list);
    var note = el("p", "moot-note");
    card.appendChild(note);

    var chosen = votedFor(poll.id);
    if (chosen) {
      renderResults(card, poll, results, chosen);
    } else {
      poll.poll_options.sort(function (a, b) { return a.sort - b.sort; }).forEach(function (o) {
        var btn = el("button", "moot-option");
        btn.type = "button";
        btn.appendChild(el("span", "moot-option-label", o.label));
        if (o.detail) btn.appendChild(el("span", "moot-option-detail", o.detail));
        btn.addEventListener("click", function () {
          btn.disabled = true;
          castVote(poll.id, o.id).then(function (res) {
            markVoted(poll.id, o.id);
            return loadResults().then(function (r) { renderResults(card, poll, r, o.id); });
          }).catch(function () {
            btn.disabled = false;
            note.textContent = "The archive could not be reached. Try again in a moment.";
          });
        });
        list.appendChild(btn);
      });
      var show = el("button", "moot-peek");
      show.type = "button";
      show.textContent = "Show the standing without voting";
      show.addEventListener("click", function () {
        loadResults().then(function (r) { renderResults(card, poll, r, null); show.remove(); });
      });
      card.appendChild(show);
      note.textContent = "One voice per reader. The archive counts; it does not watch.";
    }
    return card;
  }

  root.innerHTML = "";
  root.appendChild(el("p", "moot-note", "Convening the moot…"));
  Promise.all([loadPolls(), loadResults()]).then(function (all) {
    root.innerHTML = "";
    var polls = all[0], results = all[1];
    if (!polls.length) {
      root.appendChild(el("p", "moot-note", "The moot is not in session. Come back soon."));
      return;
    }
    polls.forEach(function (p) { root.appendChild(renderPoll(p, results)); });
  }).catch(function () {
    root.innerHTML = "";
    var msg = el("p", "moot-note");
    msg.textContent = "The archive could not be reached from here. The moot convenes on the published site — or try again in a moment.";
    root.appendChild(msg);
  });
})();
