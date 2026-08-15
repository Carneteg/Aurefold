/* AUREFOLD — interactive chart of the Banner-lands.
 * Public House data is loaded from the Aurefold Supabase canon layer when
 * available, with data/houses.js retained as an offline/failure fallback. */
(function () {
  "use strict";

  const SVG_NS = "http://www.w3.org/2000/svg";
  const FALLBACK_HOUSES = window.AUREFOLD_HOUSES || [];

  async function loadHouses() {
    const cfg = window.AUREFOLD_COMMUNITY || {};
    if (!cfg.supabaseUrl || !cfg.supabaseKey || typeof fetch !== "function") {
      return FALLBACK_HOUSES;
    }

    const endpoint =
      `${cfg.supabaseUrl}/rest/v1/site_houses` +
      "?select=id,name,philosophy,seat,region,line,note,map_x,map_y,sort_order" +
      "&order=sort_order.asc";

    try {
      const response = await fetch(endpoint, {
        headers: {
          apikey: cfg.supabaseKey,
          Authorization: `Bearer ${cfg.supabaseKey}`,
          Accept: "application/json",
        },
      });
      if (!response.ok) throw new Error(`canon API ${response.status}`);

      const rows = await response.json();
      // The public site recognizes exactly ten Great Houses. If the API ever
      // returns an incomplete set, fail closed to the checked-in fallback.
      if (!Array.isArray(rows) || rows.length !== 10) return FALLBACK_HOUSES;

      return rows.map((row) => ({
        id: row.id,
        name: row.name,
        philosophy: row.philosophy,
        seat: row.seat,
        region: row.region,
        line: row.line || "",
        note: row.note || "",
        coords: { x: row.map_x, y: row.map_y },
      }));
    } catch (error) {
      console.warn("Aurefold canon data unavailable; using static fallback.", error);
      return FALLBACK_HOUSES;
    }
  }

  async function init() {
    const HOUSES = await loadHouses();
    const localeMatch = location.pathname.match(/^\/(sv|es|fr|zh|ja)\//);
    const localePrefix = localeMatch ? `/${localeMatch[1]}` : "";

    const svg = document.getElementById("map");
    const viewport = document.getElementById("viewport");
    const housesLayer = document.getElementById("houses-layer");
    const tooltip = document.getElementById("tooltip");
    const listEl = document.getElementById("seat-list");

    if (!svg || !viewport || !housesLayer || !tooltip || !listEl) return;

    const detail = {
      root: document.getElementById("detail"),
      sigil: document.getElementById("detail-sigil"),
      name: document.getElementById("detail-name"),
      sub: document.getElementById("detail-sub"),
      philosophy: document.getElementById("detail-philosophy"),
      people: document.getElementById("detail-people"),
      line: document.getElementById("detail-line"),
      link: document.getElementById("detail-link"),
      close: document.getElementById("detail-close"),
    };

    // --------------------------------------------------------------- viewport
    const MIN_SCALE = 0.7;
    const MAX_SCALE = 6;
    const CENTER = { x: 600, y: 450 };
    const view = { scale: 1, tx: 0, ty: 0 };

    function applyView() {
      viewport.setAttribute(
        "transform",
        `translate(${view.tx} ${view.ty}) scale(${view.scale})`
      );
    }

    function toViewBox(evt) {
      const pt = new DOMPoint(evt.clientX, evt.clientY);
      return pt.matrixTransform(svg.getScreenCTM().inverse());
    }

    function zoomAt(cx, cy, factor) {
      const next = Math.min(MAX_SCALE, Math.max(MIN_SCALE, view.scale * factor));
      factor = next / view.scale;
      view.tx = cx - factor * (cx - view.tx);
      view.ty = cy - factor * (cy - view.ty);
      view.scale = next;
      applyView();
    }

    svg.addEventListener(
      "wheel",
      (evt) => {
        evt.preventDefault();
        const p = toViewBox(evt);
        zoomAt(p.x, p.y, evt.deltaY < 0 ? 1.15 : 1 / 1.15);
      },
      { passive: false }
    );

    let drag = null;
    svg.addEventListener("pointerdown", (evt) => {
      if (evt.button !== 0) return;
      drag = { start: toViewBox(evt), tx: view.tx, ty: view.ty, moved: false };
      svg.setPointerCapture(evt.pointerId);
    });

    svg.addEventListener("pointermove", (evt) => {
      if (drag) {
        const p = toViewBox(evt);
        const dx = p.x - drag.start.x;
        const dy = p.y - drag.start.y;
        if (Math.hypot(dx, dy) > 3) drag.moved = true;
        view.tx = drag.tx + dx;
        view.ty = drag.ty + dy;
        applyView();
      }
      moveTooltip(evt);
    });

    svg.addEventListener("pointerup", (evt) => {
      if (drag && !drag.moved) handleMapClick(evt);
      drag = null;
      svg.releasePointerCapture(evt.pointerId);
    });
    svg.addEventListener("pointerleave", () => {
      drag = null;
      hideTooltip();
    });

    document.getElementById("zoom-in").addEventListener("click", () =>
      zoomAt(CENTER.x, CENTER.y, 1.3)
    );
    document.getElementById("zoom-out").addEventListener("click", () =>
      zoomAt(CENTER.x, CENTER.y, 1 / 1.3)
    );
    document.getElementById("zoom-reset").addEventListener("click", () =>
      animateView({ scale: 1, tx: 0, ty: 0 })
    );

    function animateView(target, duration = 500) {
      const from = { ...view };
      const t0 = performance.now();
      const ease = (t) => 1 - Math.pow(1 - t, 3);
      function frame(now) {
        const t = Math.min(1, (now - t0) / duration);
        const k = ease(t);
        view.scale = from.scale + (target.scale - from.scale) * k;
        view.tx = from.tx + (target.tx - from.tx) * k;
        view.ty = from.ty + (target.ty - from.ty) * k;
        applyView();
        if (t < 1) requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    }

    function flyTo(x, y, scale = 2) {
      animateView({ scale, tx: CENTER.x - scale * x, ty: CENTER.y - scale * y });
    }

    // ---------------------------------------------------------------- markers
    const markerById = new Map();
    const shortName = (house) => house.name.replace(/^House\s+/, "");

    function makeMarker(house) {
      if (!Number.isFinite(house.coords?.x) || !Number.isFinite(house.coords?.y)) return;

      const g = document.createElementNS(SVG_NS, "g");
      g.setAttribute("class", "house-marker");
      g.setAttribute("transform", `translate(${house.coords.x} ${house.coords.y})`);
      g.dataset.id = house.id;

      const halo = document.createElementNS(SVG_NS, "circle");
      halo.setAttribute("class", "halo");
      halo.setAttribute("r", "16");

      const seal = document.createElementNS(SVG_NS, "circle");
      seal.setAttribute("class", "seal");
      seal.setAttribute("r", "9");

      const center = document.createElementNS(SVG_NS, "circle");
      center.setAttribute("class", "seal-center");
      center.setAttribute("r", "3");

      const label = document.createElementNS(SVG_NS, "text");
      label.setAttribute("y", "28");
      label.textContent = shortName(house);

      g.append(halo, seal, center, label);
      g.addEventListener("pointerenter", () => showTooltip(house));
      g.addEventListener("pointerleave", hideTooltip);
      housesLayer.appendChild(g);
      markerById.set(house.id, g);
    }

    function handleMapClick(evt) {
      const marker = evt.target.closest(".house-marker");
      if (marker) selectHouse(marker.dataset.id, { fly: false });
      else clearSelection();
    }

    // ---------------------------------------------------------------- tooltip
    function showTooltip(house) {
      tooltip.textContent = `${house.seat} — seat of ${house.name}`;
      tooltip.hidden = false;
    }
    function hideTooltip() {
      tooltip.hidden = true;
    }
    function moveTooltip(evt) {
      if (tooltip.hidden) return;
      const rect = svg.parentElement.getBoundingClientRect();
      tooltip.style.left = `${evt.clientX - rect.left + 14}px`;
      tooltip.style.top = `${evt.clientY - rect.top + 14}px`;
    }

    // ---------------------------------------------------------------- sidebar
    let selected = null;

    function buildList() {
      for (const house of HOUSES) {
        const li = document.createElement("li");
        li.dataset.id = house.id;
        li.innerHTML =
          `<span class="seat-house">${house.name}</span>` +
          `<span class="seat-name">${house.seat} · ${house.region}</span>`;
        li.addEventListener("click", () => selectHouse(house.id, { fly: true }));
        listEl.appendChild(li);
      }
    }

    function refreshSelection() {
      for (const [id, marker] of markerById) {
        marker.classList.toggle("selected", id === selected);
      }
      for (const li of listEl.children) {
        li.classList.toggle("selected", li.dataset.id === selected);
      }
    }

    function selectHouse(id, { fly }) {
      const house = HOUSES.find((h) => h.id === id);
      if (!house) return;
      selected = id;
      location.hash = `house/${id}`;

      detail.sigil.hidden = true;
      detail.sigil.onload = () => {
        detail.sigil.hidden = false;
      };
      detail.sigil.onerror = () => {
        if (!detail.sigil.src.includes("/sigill_")) {
          detail.sigil.src = `/assets/sigils/sigill_${house.id}.png`;
        }
      };
      detail.sigil.src = `/assets/sigils/${house.id}.png`;
      detail.name.textContent = house.name;
      detail.sub.textContent = `${house.seat} · ${house.region}`;
      detail.philosophy.textContent = house.philosophy;
      detail.people.innerHTML = house.note
        ? `<div class="detail-note">${house.note}</div>`
        : "";
      detail.line.textContent = house.line;
      detail.link.href = `${localePrefix}/houses.html#${house.id}`;
      detail.root.hidden = false;

      if (fly) flyTo(house.coords.x, house.coords.y);
      refreshSelection();
    }

    function clearSelection() {
      if (selected === null) return;
      selected = null;
      detail.root.hidden = true;
      history.replaceState(null, "", location.pathname + location.search);
      refreshSelection();
    }

    detail.close.addEventListener("click", clearSelection);

    // -------------------------------------------------------------------- init
    HOUSES.forEach(makeMarker);
    buildList();
    applyView();

    const hashMatch = location.hash.match(/^#house\/(.+)$/);
    if (hashMatch) selectHouse(hashMatch[1], { fly: true });
  }

  init();
})();
