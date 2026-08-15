/* AUREFOLD — English Faces page canon hydration.
 * Curated public profiles replace stale card copy when the canon API is
 * available. Existing HTML remains the fail-closed fallback, so translations
 * and offline browsing are unaffected. */
(function () {
  "use strict";

  async function hydrate() {
    if (!window.AUREFOLD_CANON) return;

    let rows;
    try {
      rows = await window.AUREFOLD_CANON.fetchView(
        "site_character_profiles",
        "select=id,name,subtitle,summary,portrait_slug,sort_order&order=sort_order.asc"
      );
    } catch (error) {
      console.warn("Aurefold character canon unavailable; keeping static cards.", error);
      return;
    }

    if (!Array.isArray(rows) || rows.length === 0) return;

    const cards = Array.from(document.querySelectorAll(".face-card"));
    for (const row of rows) {
      const card = cards.find((candidate) => {
        const img = candidate.querySelector(".face-portrait");
        if (!img || !row.portrait_slug) return false;
        const src = img.getAttribute("src") || "";
        return src.endsWith(`/portraits/${row.portrait_slug}.jpg`) ||
               src.endsWith(`/portraits/${row.portrait_slug}.webp`);
      });
      if (!card) continue;

      const name = card.querySelector("h3");
      const subtitle = card.querySelector(".face-house");
      const copy = Array.from(card.querySelectorAll("p")).find(
        (p) => !p.classList.contains("face-house")
      );

      if (name && row.name) name.textContent = row.name;
      if (subtitle) subtitle.textContent = row.subtitle || "";
      if (copy && row.summary) copy.textContent = row.summary;
      card.dataset.canonSource = "supabase";
    }
  }

  hydrate();
})();
