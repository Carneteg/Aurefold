/* AUREFOLD — author-only Knowledge Graph v1.
 * Epistemic state and information-transfer control. Not canon by itself.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const $ = (id) => document.getElementById(id);
  const book = $("kg-book");
  const health = $("kg-health");
  const debt = $("kg-debt");
  const propositionTable = $("kg-propositions");
  const queryResults = $("kg-query-results");
  const timelineTable = $("kg-timeline");
  const transferTable = $("kg-transfers");
  if (!book || !health || !debt || !propositionTable || !queryResults || !timelineTable || !transferTable) return;

  let entities = [];
  let characters = [];
  let scenes = [];
  let propositions = [];

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }
  function enc(v) { return encodeURIComponent(v); }
  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }
  function td(value) { const el = document.createElement("td"); el.textContent = value == null || value === "" ? "—" : String(value); return el; }
  function value(id) { const el = $(id); return el && String(el.value).trim() ? String(el.value).trim() : null; }

  async function request(path, options = {}) {
    const accessToken = token();
    if (!accessToken) throw new Error("Not signed in");
    const response = await fetch(`${cfg.supabaseUrl}/rest/v1/${path}`, {
      ...options,
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: `Bearer ${accessToken}`,
        Accept: "application/json",
        ...(options.body ? { "Content-Type": "application/json" } : {}),
        ...(options.headers || {})
      }
    });
    if (!response.ok) {
      const detail = await response.text();
      throw new Error(`Knowledge Graph API ${response.status}: ${detail.slice(0, 420)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  function option(value, label) {
    const o = document.createElement("option"); o.value = value; o.textContent = label; return o;
  }

  function fillSelect(id, rows, getValue, getLabel, includeBlank = false) {
    const select = $(id); if (!select) return;
    const existing = select.value; clear(select);
    if (includeBlank) select.appendChild(option("", "—"));
    for (const row of rows) select.appendChild(option(getValue(row), getLabel(row)));
    if ([...select.options].some((o) => o.value === existing)) select.value = existing;
  }

  async function loadEntities() {
    const rows = await request("lore_entities?select=id,slug,name,entity_type&order=name.asc");
    entities = Array.isArray(rows) ? rows : [];
    characters = entities.filter((e) => e.entity_type === "character");
    const characterLabel = (e) => `${e.name} (${e.slug})`;
    fillSelect("kg-query-character", characters, (e) => e.id, characterLabel);
    fillSelect("kg-timeline-character", characters, (e) => e.id, characterLabel);
    fillSelect("kg-event-holder", entities, (e) => e.id, (e) => `${e.name} · ${e.entity_type}`);
  }

  async function loadScenes() {
    const rows = await request(`lore_scenes?select=id,chapter_number,scene_order,title&book_code=eq.${enc(book.value)}&order=scene_order.asc`);
    scenes = Array.isArray(rows) ? rows : [];
    const label = (s) => `${s.chapter_number == null ? "Interlude" : `Ch. ${s.chapter_number}`} — ${s.title || "Untitled"}`;
    fillSelect("kg-query-scene", scenes, (s) => s.id, label);
    fillSelect("kg-event-scene", scenes, (s) => s.id, label, true);
  }

  async function loadPropositions() {
    const rows = await request("author_knowledge_propositions?select=*&order=stable_key.asc");
    propositions = (Array.isArray(rows) ? rows : []).filter((p) => p.book_code === book.value || p.book_code == null);
    clear(propositionTable);
    if (!propositions.length) {
      const tr = document.createElement("tr"); const c = td("No propositions are registered for this book."); c.colSpan = 7; tr.appendChild(c); propositionTable.appendChild(tr);
    } else {
      for (const p of propositions) {
        const tr = document.createElement("tr"); if (p.protected_ambiguity) tr.dataset.protected = "true";
        tr.append(td(p.stable_key), td(p.proposition_text), td(p.proposition_kind), td(p.authority_status), td(p.truth_scope), td(p.protected_remainder), td([p.source_document_title, p.source_locator].filter(Boolean).join(" · ")));
        propositionTable.appendChild(tr);
      }
    }
    fillSelect("kg-event-proposition", propositions, (p) => p.proposition_id, (p) => `${p.stable_key} — ${p.proposition_text.slice(0, 90)}`);
  }

  async function loadHealth() {
    const rows = await request(`author_knowledge_health?select=*&book_code=eq.${enc(book.value)}`);
    const row = Array.isArray(rows) ? rows[0] : null; clear(health);
    const cards = row ? [
      ["Propositions", row.propositions], ["Protected", row.protected_propositions], ["Current events", row.current_events],
      ["Stale events", row.stale_events], ["Imprecise timing", row.imprecise_timing_events], ["Guardrail conflicts", row.guardrail_conflicts]
    ] : [["Propositions", 0]];
    for (const [label, n] of cards) {
      const card = document.createElement("div"); card.className = "lm-card";
      const strong = document.createElement("strong"); strong.textContent = String(n ?? 0);
      const span = document.createElement("span"); span.textContent = label; card.append(strong, span); health.appendChild(card);
    }
    debt.hidden = !(row && row.knowledge_source_debt_open);
    debt.textContent = row && row.knowledge_source_debt_open
      ? "SOURCE DEBT: Book Two Character & Knowledge Map v1.0 is still unavailable. Do not treat Book Two K-state coverage as complete or invent missing acquisition states."
      : "";
  }

  async function loadTransfers() {
    const rows = await request(`author_knowledge_transfers?select=*&book_code=eq.${enc(book.value)}&order=scene_order.asc.nullsfirst,created_at.asc`);
    clear(transferTable);
    if (!Array.isArray(rows) || !rows.length) {
      const tr = document.createElement("tr"); const c = td("No information transfers recorded for this book."); c.colSpan = 8; tr.appendChild(c); transferTable.appendChild(tr); return;
    }
    for (const r of rows) {
      const tr = document.createElement("tr"); if (r.effective_status === "stale") tr.dataset.stale = "true";
      const when = r.chapter_number == null ? r.timing_precision : `Ch. ${r.chapter_number}`;
      tr.append(td(when), td(r.proposition_key), td(r.from_name), td(r.to_name), td(r.transfer_kind), td(r.source_form), td(r.meaning_shift_note), td(r.effective_status));
      transferTable.appendChild(tr);
    }
  }

  async function runKnowledgeQuery() {
    const characterId = value("kg-query-character"); const sceneId = value("kg-query-scene");
    if (!characterId || !sceneId) throw new Error("Choose both a character and a scene.");
    $("kg-query-status").textContent = "Resolving temporal knowledge state…";
    const rows = await request("rpc/author_character_knowledge_at_scene", { method: "POST", body: JSON.stringify({ p_character_id: characterId, p_scene_id: sceneId }) });
    clear(queryResults);
    if (!Array.isArray(rows) || !rows.length) {
      const tr = document.createElement("tr"); const c = td("No temporally supported knowledge states are recorded at this point. Unknown timing and unmodeled knowledge are deliberately not invented."); c.colSpan = 7; tr.appendChild(c); queryResults.appendChild(tr);
    } else {
      for (const r of rows) {
        const tr = document.createElement("tr"); if (r.protected_ambiguity) tr.dataset.protected = "true";
        const acquired = r.acquired_chapter_number == null ? r.timing_precision : `Ch. ${r.acquired_chapter_number}`;
        tr.append(td(r.proposition_text), td(r.awareness_state), td(r.stance), td(r.certainty), td(acquired), td(`${r.evidence_class} · ${r.source_revision_label || ""}`), td(r.protected_remainder));
        queryResults.appendChild(tr);
      }
    }
    $("kg-query-status").textContent = `${Array.isArray(rows) ? rows.length : 0} current proposition state(s). Book-end/unknown-timing events are excluded unless temporally justified.`;
  }

  async function loadTimeline() {
    const holder = value("kg-timeline-character"); if (!holder) throw new Error("Choose a holder.");
    const rows = await request(`author_character_knowledge_timeline?select=*&book_code=eq.${enc(book.value)}&holder_entity_id=eq.${enc(holder)}&order=scene_order.asc.nullsfirst,event_order.asc,created_at.asc`);
    clear(timelineTable);
    if (!Array.isArray(rows) || !rows.length) {
      const tr = document.createElement("tr"); const c = td("No knowledge events recorded for this holder in this book."); c.colSpan = 8; tr.appendChild(c); timelineTable.appendChild(tr); return;
    }
    for (const r of rows) {
      const tr = document.createElement("tr"); if (r.protected_ambiguity) tr.dataset.protected = "true"; if (r.effective_status === "stale") tr.dataset.stale = "true";
      const when = r.chapter_number == null ? r.timing_precision : `Ch. ${r.chapter_number} · ${r.timing_precision}`;
      tr.append(td(when), td(r.proposition_key), td(r.awareness_state), td(r.stance), td(r.certainty), td(r.source_channel), td(r.evidence_class), td(r.effective_status));
      timelineTable.appendChild(tr);
    }
  }

  async function saveKnowledgeEvent(event) {
    event.preventDefault();
    const timing = value("kg-event-timing") || "exact_scene";
    const scene = value("kg-event-scene");
    if ((timing === "exact_scene" || timing === "by_scene") && !scene) throw new Error("Exact/by-scene timing requires a scene.");
    const payload = {
      p_book_code: book.value,
      p_holder_entity_id: value("kg-event-holder"),
      p_proposition_id: value("kg-event-proposition"),
      p_scene_id: scene,
      p_timing_precision: timing,
      p_awareness_state: value("kg-event-awareness"),
      p_stance: value("kg-event-stance"),
      p_certainty: value("kg-event-certainty"),
      p_evidence_class: value("kg-event-evidence"),
      p_source_channel: value("kg-event-channel"),
      p_event_order: 50,
      p_source_entity_id: null,
      p_source_claim_id: null,
      p_source_document_id: null,
      p_source_locator: value("kg-event-locator"),
      p_source_revision_label: value("kg-event-revision") || "working",
      p_notes: value("kg-event-notes")
    };
    $("kg-event-status").textContent = "Recording knowledge event…";
    await request("rpc/author_record_knowledge_event", { method: "POST", body: JSON.stringify(payload) });
    $("kg-event-status").textContent = "Knowledge event recorded. Protected-ambiguity ownership guards were applied server-side.";
    await Promise.all([loadHealth(), loadTimeline().catch(() => {})]);
  }

  async function createWorkingProposition(event) {
    event.preventDefault();
    const protectedFlag = $("kg-prop-protected").checked;
    const payload = {
      p_stable_key: value("kg-prop-key"), p_book_code: book.value, p_proposition_text: value("kg-prop-text"),
      p_proposition_kind: value("kg-prop-kind"), p_truth_scope: value("kg-prop-truth"),
      p_subject_entity_id: null, p_event_entity_id: null, p_linked_claim_id: null, p_contradiction_group: null,
      p_protected_ambiguity: protectedFlag, p_protected_remainder: protectedFlag ? value("kg-prop-remainder") : null,
      p_source_document_id: null, p_source_label: value("kg-prop-source-label"), p_source_locator: value("kg-prop-source-locator"), p_notes: value("kg-prop-notes")
    };
    $("kg-prop-status").textContent = "Creating working proposition…";
    await request("rpc/author_create_working_knowledge_proposition", { method: "POST", body: JSON.stringify(payload) });
    $("kg-prop-status").textContent = "Working proposition created. This did not promote or ratify canon.";
    await Promise.all([loadPropositions(), loadHealth()]);
  }

  async function refresh() {
    await loadEntities();
    await Promise.all([loadScenes(), loadPropositions(), loadHealth(), loadTransfers()]);
  }

  $("kg-query-run").addEventListener("click", () => runKnowledgeQuery().catch((e) => { $("kg-query-status").textContent = e.message; }));
  $("kg-timeline-load").addEventListener("click", () => loadTimeline().catch((e) => { timelineTable.textContent = e.message; }));
  $("kg-event-form").addEventListener("submit", (e) => saveKnowledgeEvent(e).catch((err) => { $("kg-event-status").textContent = err.message; }));
  $("kg-proposition-form").addEventListener("submit", (e) => createWorkingProposition(e).catch((err) => { $("kg-prop-status").textContent = err.message; }));
  book.addEventListener("change", () => refresh().catch((e) => { $("kg-query-status").textContent = e.message; }));
  window.addEventListener("aurefold:loremaster-ready", () => refresh().catch((e) => { $("kg-query-status").textContent = e.message; }));
  if (token()) refresh().catch((e) => { $("kg-query-status").textContent = e.message; });
})();
