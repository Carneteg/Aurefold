/* AUREFOLD — public Faces page canon + character-art hydration.
 *
 * Public text comes only from the spoiler-safe site_character_gallery view.
 * Public images come only from ratified rows in character_art. Author-only canon
 * tables are never queried by the browser. Existing HTML remains the fail-closed
 * fallback, so the page still works if Supabase is unavailable.
 */
(function () {
  "use strict";

  const COPY = {
    en: {
      eyebrow: "THE PORTRAIT ARCHIVE",
      title: "Faces from Book One",
      intro: "Twenty-six ratified character studies from the author archive. Open a portrait to see the full figure and the character at work.",
      open: "Open character study",
      portrait: "Portrait",
      fullbody: "Full figure",
      atWork: "At work",
      close: "Close",
    },
    sv: {
      eyebrow: "PORTRÄTTARKIVET",
      title: "Ansikten ur Bok Ett",
      intro: "Tjugosex ratificerade karaktärsstudier ur författararkivet. Öppna ett porträtt för att se helfigur och karaktären i arbete.",
      open: "Öppna karaktärsstudie",
      portrait: "Porträtt",
      fullbody: "Helfigur",
      atWork: "I arbete",
      close: "Stäng",
    },
    es: {
      eyebrow: "EL ARCHIVO DE RETRATOS",
      title: "Rostros del Libro Uno",
      intro: "Veintiséis estudios de personajes ratificados del archivo del autor. Abre un retrato para ver la figura completa y al personaje en su trabajo.",
      open: "Abrir estudio del personaje",
      portrait: "Retrato",
      fullbody: "Figura completa",
      atWork: "En su trabajo",
      close: "Cerrar",
    },
    fr: {
      eyebrow: "LES ARCHIVES DE PORTRAITS",
      title: "Visages du Livre Un",
      intro: "Vingt-six études de personnages ratifiées issues des archives de l’auteur. Ouvrez un portrait pour voir la silhouette entière et le personnage au travail.",
      open: "Ouvrir l’étude du personnage",
      portrait: "Portrait",
      fullbody: "Plein pied",
      atWork: "Au travail",
      close: "Fermer",
    },
    zh: {
      eyebrow: "人物肖像档案",
      title: "第一部人物",
      intro: "作者档案中二十六组已经确认的人物设定图。打开肖像即可查看全身形象与工作场景。",
      open: "打开人物设定",
      portrait: "肖像",
      fullbody: "全身",
      atWork: "工作场景",
      close: "关闭",
    },
    ja: {
      eyebrow: "人物肖像アーカイブ",
      title: "第一巻の登場人物",
      intro: "作者アーカイブから、承認済みの人物設定画26組。肖像を開くと、全身像と仕事中の姿を見ることができます。",
      open: "人物設定を開く",
      portrait: "肖像",
      fullbody: "全身",
      atWork: "仕事中",
      close: "閉じる",
    },
  };

  function lang() {
    const raw = (document.documentElement.lang || "en").toLowerCase();
    return COPY[raw] ? raw : "en";
  }

  function storageUrl(path, sha) {
    if (!path) return "";
    const cfg = window.AUREFOLD_COMMUNITY || {};
    if (!cfg.supabaseUrl) return "";
    const safePath = path.split("/").map(encodeURIComponent).join("/");
    const version = sha ? `?v=${encodeURIComponent(sha.slice(0, 12))}` : "";
    return `${cfg.supabaseUrl}/storage/v1/object/public/character-art/${safePath}${version}`;
  }

  function slugFromExistingCard(card) {
    if (card.dataset.characterId) return card.dataset.characterId;
    const img = card.querySelector(".face-portrait");
    if (!img) return "";
    const src = img.getAttribute("src") || "";
    const match = src.match(/\/portraits\/([^/.]+)\.(?:jpg|jpeg|png|webp)(?:\?.*)?$/i);
    return match ? match[1].toLowerCase() : "";
  }

  function hydrateExistingCards(rows) {
    const byId = new Map(rows.map((row) => [row.id, row]));
    const currentLang = lang();

    document.querySelectorAll(".face-card").forEach((card) => {
      const id = slugFromExistingCard(card);
      const row = byId.get(id);
      if (!row) return;

      card.dataset.characterId = id;
      card.dataset.canonSource = "supabase";

      const img = card.querySelector(".face-portrait");
      const portrait = storageUrl(row.portrait_path, row.portrait_sha256);
      if (img && portrait) {
        img.src = portrait;
        img.decoding = "async";
      }

      // The database copy is English. Keep the hand-translated static copy on
      // localized pages; hydrate text only on the English source page.
      if (currentLang !== "en" || !row.has_public_profile) return;

      const name = card.querySelector("h3");
      const subtitle = card.querySelector(".face-house");
      const body = Array.from(card.querySelectorAll("p")).find(
        (p) => !p.classList.contains("face-house")
      );
      if (name && row.name) name.textContent = row.name;
      if (subtitle && row.subtitle) subtitle.textContent = row.subtitle;
      if (body && row.summary) body.textContent = row.summary;
    });
  }

  function makeImage(src, alt, eager) {
    const img = document.createElement("img");
    img.src = src;
    img.alt = alt;
    img.decoding = "async";
    img.loading = eager ? "eager" : "lazy";
    return img;
  }

  function ensureDialog() {
    let dialog = document.getElementById("character-study-dialog");
    if (dialog) return dialog;

    const c = COPY[lang()];
    dialog = document.createElement("dialog");
    dialog.id = "character-study-dialog";
    dialog.className = "character-study-dialog";
    dialog.innerHTML = `
      <div class="character-study-shell">
        <div class="character-study-head">
          <div>
            <p class="character-study-kicker"></p>
            <h2 class="character-study-name"></h2>
            <p class="character-study-subtitle"></p>
          </div>
          <button type="button" class="character-study-close" aria-label="${c.close}">${c.close}</button>
        </div>
        <p class="character-study-summary"></p>
        <div class="character-study-grid"></div>
      </div>`;
    document.body.appendChild(dialog);

    dialog.querySelector(".character-study-close").addEventListener("click", () => dialog.close());
    dialog.addEventListener("click", (event) => {
      if (event.target === dialog) dialog.close();
    });
    return dialog;
  }

  function openStudy(row) {
    const dialog = ensureDialog();
    const c = COPY[lang()];
    dialog.querySelector(".character-study-kicker").textContent = c.eyebrow;
    dialog.querySelector(".character-study-name").textContent = row.name || "";
    const subtitle = dialog.querySelector(".character-study-subtitle");
    subtitle.textContent = lang() === "en" ? (row.subtitle || "") : "";
    subtitle.hidden = !subtitle.textContent;

    const summary = dialog.querySelector(".character-study-summary");
    summary.textContent = lang() === "en" ? (row.summary || "") : "";
    summary.hidden = !summary.textContent;

    const variants = [
      [c.portrait, row.portrait_path, row.portrait_sha256],
      [c.fullbody, row.fullbody_path, row.fullbody_sha256],
      [c.atWork, row.at_work_path, row.at_work_sha256],
    ].filter(([, path]) => path);

    const grid = dialog.querySelector(".character-study-grid");
    grid.replaceChildren();
    for (const [label, path, sha] of variants) {
      const figure = document.createElement("figure");
      const url = storageUrl(path, sha);
      const img = makeImage(url, `${row.name} — ${label.toLowerCase()}`, false);
      const caption = document.createElement("figcaption");
      caption.textContent = label;
      figure.append(img, caption);
      grid.appendChild(figure);
    }

    dialog.showModal();
    dialog.querySelector(".character-study-close").focus();
  }

  function renderArchive(rows) {
    const artRows = rows.filter((row) => row.portrait_path);
    if (!artRows.length) return;

    const c = COPY[lang()];
    const section = document.createElement("section");
    section.className = "character-archive";
    section.setAttribute("aria-labelledby", "character-archive-title");
    section.innerHTML = `
      <div class="character-archive-head">
        <div>
          <p class="character-archive-eyebrow">${c.eyebrow}</p>
          <h2 id="character-archive-title">${c.title}</h2>
        </div>
        <p>${c.intro}</p>
      </div>
      <div class="character-archive-track" role="list"></div>`;

    const track = section.querySelector(".character-archive-track");
    for (const row of artRows) {
      const item = document.createElement("article");
      item.className = "character-archive-card";
      item.setAttribute("role", "listitem");

      const button = document.createElement("button");
      button.type = "button";
      button.className = "character-archive-open";
      button.setAttribute("aria-label", `${c.open}: ${row.name}`);

      const portrait = storageUrl(row.portrait_path, row.portrait_sha256);
      const img = makeImage(portrait, row.name, false);
      const label = document.createElement("span");
      label.className = "character-archive-name";
      label.textContent = row.name;
      button.append(img, label);
      button.addEventListener("click", () => openStudy(row));
      item.appendChild(button);
      track.appendChild(item);
    }

    const intro = document.querySelector("main.page > .page-intro");
    if (intro) intro.insertAdjacentElement("afterend", section);
    else document.querySelector("main.page")?.prepend(section);
  }

  async function hydrate() {
    if (!window.AUREFOLD_CANON) return;

    let rows;
    try {
      rows = await window.AUREFOLD_CANON.fetchView(
        "site_character_gallery",
        "select=id,name,subtitle,summary,sort_order,portrait_path,fullbody_path,at_work_path,portrait_sha256,fullbody_sha256,at_work_sha256,has_public_profile&order=sort_order.asc,name.asc"
      );
    } catch (error) {
      console.warn("Aurefold character gallery unavailable; keeping static Faces page.", error);
      return;
    }

    if (!Array.isArray(rows) || rows.length === 0) return;
    hydrateExistingCards(rows);
    renderArchive(rows);
  }

  hydrate();
})();
