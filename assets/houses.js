/* AUREFOLD — English Great Houses page canon hydration.
 * The checked-in HTML remains the fail-closed fallback. Only public-safe
 * `site_houses` and ratified public phrase rows are read here. */
(function () {
  "use strict";

  async function hydrate() {
    if (!window.AUREFOLD_CANON) return;

    let houses;
    try {
      houses = await window.AUREFOLD_CANON.fetchView(
        "site_houses",
        "select=id,name,philosophy,seat,region,line,question,note&order=id.asc"
      );
    } catch (error) {
      console.warn("Aurefold House canon unavailable; keeping static cards.", error);
      return;
    }

    if (!Array.isArray(houses) || houses.length !== 10) return;

    for (const house of houses) {
      const card = document.getElementById(house.id);
      if (!card) continue;

      const name = card.querySelector(".house-name");
      const philosophy = card.querySelector(".house-philosophy");
      const seat = card.querySelector(".house-seat");
      const question = card.querySelector(".house-question em");
      const line = card.querySelector(".house-line");

      if (name && house.name) name.textContent = house.name;
      if (philosophy && house.philosophy) philosophy.textContent = house.philosophy;
      if (seat) seat.textContent = [house.seat, house.region].filter(Boolean).join(" · ");
      if (question && house.question) question.textContent = `“${house.question.replace(/^“|”$/g, "")}”`;
      if (line && house.line) line.textContent = house.line;
      card.dataset.canonSource = "supabase";
    }

    // Phrase ecology stays invisible until an individual phrase is explicitly
    // ratified + public. This keeps working slogans and hostile folklore off the
    // reader site by default.
    let phrases = [];
    try {
      phrases = await window.AUREFOLD_CANON.fetchView(
        "site_house_phrases",
        "select=house_id,phrase_text,phrase_kind,provenance&order=house_id.asc"
      );
    } catch (_) {
      return;
    }

    for (const phrase of phrases) {
      if (!['house_words','house_saying'].includes(phrase.phrase_kind)) continue;
      const card = document.getElementById(phrase.house_id);
      const body = card && card.querySelector('.card-body-inner');
      if (!body || body.querySelector(`[data-phrase-kind="${phrase.phrase_kind}"]`)) continue;

      const p = document.createElement('p');
      p.className = 'house-public-phrase';
      p.dataset.phraseKind = phrase.phrase_kind;
      p.textContent = phrase.phrase_text;
      const link = body.querySelector('.map-link');
      body.insertBefore(p, link || null);
    }
  }

  hydrate();
})();
