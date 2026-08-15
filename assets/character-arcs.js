/* AUREFOLD — author-only Character Arc Graph v1.
 * Developmental character-change mapping, not canon and not an automatic story grade.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const $ = (id) => document.getElementById(id);
  const book = $("lm-arc-book");
  const health = $("lm-arc-health");
  const queue = $("lm-arc-queue");
  const form = $("lm-arc-form");
  const beatForm = $("lm-arc-beat-form");
  const beatList = $("lm-arc-beats");
  const graph = $("lm-arc-graph");
  const status = $("lm-arc-status");
  const selected = $("lm-arc-selected");
  if (!book || !health || !queue || !form || !beatForm || !beatList || !graph || !status || !selected) return;

  let queueRows = [];
  let activeCharacter = null;
  let activeAssessment = null;
  let beats = [];
  let scenes = [];

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }
  function enc(v) { return encodeURIComponent(v); }
  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }
  function td(value) { const el = document.createElement("td"); el.textContent = value == null ? "" : String(value); return el; }
  function value(id) { const el = $(id); return el && el.value.trim() ? el.value.trim() : null; }
  function set(id, v) { const el = $(id); if (el) el.value = v == null ? "" : String(v); }

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
      throw new Error(`Character Arc API ${response.status}: ${detail.slice(0, 360)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  async function loadHealth() {
    const rows = await request(`author_character_arc_health?select=*&book_code=eq.${enc(book.value)}`);
    const row = Array.isArray(rows) ? rows[0] : null;
    clear(health);
    const cards = row ? [
      ["Candidates", row.candidate_characters], ["Tracked", row.tracked_characters], ["Reviewed", row.reviewed_current],
      ["Draft", row.draft_current], ["Unassessed", row.unassessed_characters], ["Stale arcs", row.stale_assessments],
      ["Current beats", row.current_beats], ["Scorecard mismatches", row.scorecard_mismatch_signals]
    ] : [["Candidates", 0]];
    for (const [label, v] of cards) {
      const card = document.createElement("div"); card.className = "lm-card";
      const strong = document.createElement("strong"); strong.textContent = String(v ?? 0);
      const span = document.createElement("span"); span.textContent = label;
      card.append(strong, span); health.appendChild(card);
    }
  }

  function selectButton(row) {
    const b = document.createElement("button"); b.type = "button"; b.className = "btn";
    b.textContent = row.assessment_id ? "Open arc" : "Start arc";
    b.addEventListener("click", () => selectCharacter(row).catch((e) => { status.textContent = e.message; }));
    return b;
  }

  async function loadQueue() {
    const rows = await request(`author_character_arc_queue?select=*&book_code=eq.${enc(book.value)}&order=priority_score.desc,character_name.asc`);
    queueRows = Array.isArray(rows) ? rows : [];
    clear(queue);
    if (!queueRows.length) {
      const tr = document.createElement("tr"); const c = td("No character candidates are mapped for this book yet."); c.colSpan = 8; tr.appendChild(c); queue.appendChild(tr); return;
    }
    for (const row of queueRows) {
      const tr = document.createElement("tr");
      if (Number(row.high_editorial_issues || 0) > 0) tr.dataset.review = "true";
      if (row.arc_status === "stale") tr.dataset.severity = "high";
      const action = document.createElement("td"); action.appendChild(selectButton(row));
      tr.append(td(row.character_name), td(row.pov_units), td(row.linked_units), td(row.active_editorial_issues),
        td(row.arc_status || "unassessed"), td(row.beat_count || 0), td(row.priority_score || 0), action);
      queue.appendChild(tr);
    }
  }

  async function loadScenes() {
    const rows = await request(`lore_scenes?select=id,chapter_number,scene_order,title&book_code=eq.${enc(book.value)}&order=scene_order.asc`);
    scenes = Array.isArray(rows) ? rows : [];
    const select = $("lm-arc-beat-scene"); clear(select);
    const blank = document.createElement("option"); blank.value = ""; blank.textContent = "Choose scene…"; select.appendChild(blank);
    for (const s of scenes) {
      const o = document.createElement("option"); o.value = s.id;
      o.textContent = `${s.chapter_number == null ? "Interlude" : `Ch. ${s.chapter_number}`} — ${s.title || "Untitled"}`;
      select.appendChild(o);
    }
  }

  async function currentAssessment(row) {
    const rows = await request(`author_character_arc_assessments?select=*&book_code=eq.${enc(book.value)}&character_id=eq.${enc(row.character_id)}&order=updated_at.desc&limit=1`);
    return Array.isArray(rows) && rows.length ? rows[0] : null;
  }

  async function loadBeats() {
    beats = [];
    if (!activeAssessment) { renderBeats(); renderGraph(); return; }
    const rows = await request(`author_character_arc_beats?select=*&assessment_id=eq.${enc(activeAssessment.assessment_id)}&order=scene_order.asc`);
    beats = Array.isArray(rows) ? rows : [];
    renderBeats(); renderGraph();
  }

  function mismatchLabel(row) {
    const out = [];
    if (row.agency_scorecard_mismatch) out.push("agency ↔ scorecard");
    if (row.relationship_scorecard_mismatch) out.push("relationship ↔ scorecard");
    if (row.turning_point_scorecard_mismatch) out.push("turning point ↔ scorecard");
    return out.join(", ") || "—";
  }

  function renderBeats() {
    clear(beatList);
    if (!beats.length) {
      const tr = document.createElement("tr"); const c = td("No arc beats recorded for this revision."); c.colSpan = 8; tr.appendChild(c); beatList.appendChild(tr); return;
    }
    for (const row of beats) {
      const tr = document.createElement("tr");
      if (row.effective_state === "stale" || mismatchLabel(row) !== "—") tr.dataset.review = "true";
      const edit = document.createElement("button"); edit.type = "button"; edit.className = "btn"; edit.textContent = "Edit";
      edit.addEventListener("click", () => editBeat(row));
      const remove = document.createElement("button"); remove.type = "button"; remove.className = "btn"; remove.textContent = "Remove";
      remove.addEventListener("click", () => removeBeat(row).catch((e) => { status.textContent = e.message; }));
      const actions = document.createElement("td"); actions.append(edit, document.createTextNode(" "), remove);
      tr.append(td(row.chapter_number == null ? "—" : row.chapter_number), td(row.title), td(row.beat_type), td(row.significance),
        td(row.agency_mode), td(row.effective_state), td(mismatchLabel(row)), actions);
      beatList.appendChild(tr);
    }
  }

  function renderGraph() {
    clear(graph);
    if (!beats.length) { graph.textContent = "No recorded movement yet."; return; }
    let prev = null;
    for (const row of beats) {
      if (prev) {
        const edge = document.createElement("div"); edge.className = "lm-arc-edge";
        const gap = Math.max(Number(row.scene_order || 0) - Number(prev.scene_order || 0) - 1, 0);
        edge.textContent = gap ? `→ ${gap} unit${gap === 1 ? "" : "s"} →` : "→";
        graph.appendChild(edge);
      }
      const card = document.createElement("div"); card.className = "lm-card lm-arc-node";
      const h = document.createElement("strong"); h.textContent = `${row.chapter_number == null ? "Interlude" : `Ch. ${row.chapter_number}`} · ${row.beat_type}`;
      const meta = document.createElement("div"); meta.className = "lm-small"; meta.textContent = `${row.significance} · agency ${row.agency_mode}`;
      const movement = document.createElement("div"); movement.textContent = [row.state_before, row.state_after].filter(Boolean).join(" → ") || row.choice_action || "Recorded beat";
      card.append(h, meta, movement); graph.appendChild(card); prev = row;
    }
  }

  function assessmentMap(a) {
    return {
      "lm-arc-question": a?.arc_question, "lm-arc-start-belief": a?.starting_belief,
      "lm-arc-start-desire": a?.starting_desire, "lm-arc-start-fear": a?.starting_fear,
      "lm-arc-defense": a?.defense_strategy, "lm-arc-need": a?.latent_need,
      "lm-arc-end-belief": a?.ending_belief, "lm-arc-end-desire": a?.ending_desire,
      "lm-arc-end-fear": a?.ending_fear, "lm-arc-changed-strategy": a?.changed_strategy,
      "lm-arc-relationships": a?.primary_relationships, "lm-arc-summary": a?.arc_summary, "lm-arc-notes": a?.notes
    };
  }

  async function selectCharacter(row) {
    activeCharacter = row;
    activeAssessment = await currentAssessment(row);
    selected.textContent = `${row.character_name} · ${book.value === "book-1" ? "The Bell of Silence" : "The Road Still Open"} · ${activeAssessment?.effective_status || "unassessed"}`;
    $("lm-arc-character-id").value = row.character_id;
    for (const [id, v] of Object.entries(assessmentMap(activeAssessment))) set(id, v);
    form.hidden = false;
    await loadScenes();
    await loadBeats();
    beatForm.hidden = !activeAssessment;
    status.textContent = activeAssessment ? `Loaded ${activeAssessment.source_revision_label}.` : "No arc assessment exists for the current revision. Save a draft to start one.";
    form.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  async function saveAssessment(nextStatus) {
    if (!activeCharacter) throw new Error("Choose a character first.");
    const payload = {
      p_book_code: book.value, p_character_id: activeCharacter.character_id, p_assessment_status: nextStatus,
      p_arc_question: value("lm-arc-question"), p_starting_belief: value("lm-arc-start-belief"),
      p_starting_desire: value("lm-arc-start-desire"), p_starting_fear: value("lm-arc-start-fear"),
      p_defense_strategy: value("lm-arc-defense"), p_latent_need: value("lm-arc-need"),
      p_ending_belief: value("lm-arc-end-belief"), p_ending_desire: value("lm-arc-end-desire"),
      p_ending_fear: value("lm-arc-end-fear"), p_changed_strategy: value("lm-arc-changed-strategy"),
      p_primary_relationships: value("lm-arc-relationships"), p_arc_summary: value("lm-arc-summary"), p_notes: value("lm-arc-notes"),
      p_note: `${nextStatus} through Loremaster Character Arc Graph v1.`
    };
    status.textContent = `Saving ${nextStatus} arc…`;
    await request("rpc/author_upsert_character_arc_assessment", { method: "POST", body: JSON.stringify(payload) });
    await refresh();
    const updated = queueRows.find((r) => r.character_id === activeCharacter.character_id);
    if (updated) await selectCharacter(updated);
  }

  function clearBeatEditor() {
    $("lm-arc-beat-id").value = ""; set("lm-arc-beat-scene", ""); set("lm-arc-beat-type", "pressure");
    set("lm-arc-beat-significance", "medium"); set("lm-arc-beat-agency", "reactive");
    ["state-before","pressure","choice","cost","state-after","belief","relationship","notes"].forEach((x) => set(`lm-arc-beat-${x}`, ""));
  }

  function editBeat(row) {
    $("lm-arc-beat-id").value = row.beat_id; set("lm-arc-beat-scene", row.scene_id); set("lm-arc-beat-type", row.beat_type);
    set("lm-arc-beat-significance", row.significance); set("lm-arc-beat-agency", row.agency_mode);
    set("lm-arc-beat-state-before", row.state_before); set("lm-arc-beat-pressure", row.pressure); set("lm-arc-beat-choice", row.choice_action);
    set("lm-arc-beat-cost", row.cost_text); set("lm-arc-beat-state-after", row.state_after); set("lm-arc-beat-belief", row.belief_effect);
    set("lm-arc-beat-relationship", row.relationship_effect); set("lm-arc-beat-notes", row.notes);
    beatForm.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  async function saveBeat(event) {
    event.preventDefault();
    if (!activeAssessment) throw new Error("Save the arc assessment before adding beats.");
    const scene = value("lm-arc-beat-scene"); if (!scene) throw new Error("Choose a scene.");
    const payload = {
      p_assessment_id: activeAssessment.assessment_id, p_scene_id: scene,
      p_beat_type: value("lm-arc-beat-type"), p_significance: value("lm-arc-beat-significance"), p_agency_mode: value("lm-arc-beat-agency"),
      p_state_before: value("lm-arc-beat-state-before"), p_pressure: value("lm-arc-beat-pressure"), p_choice_action: value("lm-arc-beat-choice"),
      p_cost_text: value("lm-arc-beat-cost"), p_state_after: value("lm-arc-beat-state-after"), p_belief_effect: value("lm-arc-beat-belief"),
      p_relationship_effect: value("lm-arc-beat-relationship"), p_notes: value("lm-arc-beat-notes"), p_note: "Saved through Loremaster Character Arc Graph v1."
    };
    status.textContent = "Saving arc beat…";
    await request("rpc/author_upsert_character_arc_beat", { method: "POST", body: JSON.stringify(payload) });
    clearBeatEditor(); await loadBeats(); await loadHealth(); await loadQueue(); status.textContent = "Arc beat saved.";
  }

  async function removeBeat(row) {
    if (!window.confirm(`Remove the recorded arc beat for ${row.title}? History will retain the removed data.`)) return;
    await request("rpc/author_remove_character_arc_beat", { method: "POST", body: JSON.stringify({ p_beat_id: row.beat_id, p_note: "Removed through Loremaster Character Arc Graph v1." }) });
    await loadBeats(); await loadHealth(); await loadQueue(); status.textContent = "Arc beat removed; history retained.";
  }

  async function refresh() { await Promise.all([loadHealth(), loadQueue()]); }

  $("lm-arc-save-draft").addEventListener("click", () => saveAssessment("draft").catch((e) => { status.textContent = e.message; }));
  $("lm-arc-save-reviewed").addEventListener("click", () => saveAssessment("reviewed").catch((e) => { status.textContent = e.message; }));
  $("lm-arc-clear").addEventListener("click", () => { activeCharacter = null; activeAssessment = null; form.hidden = true; beatForm.hidden = true; clear(beatList); clear(graph); });
  $("lm-arc-beat-clear").addEventListener("click", clearBeatEditor);
  beatForm.addEventListener("submit", (e) => saveBeat(e).catch((err) => { status.textContent = err.message; }));
  book.addEventListener("change", () => { activeCharacter = null; activeAssessment = null; form.hidden = true; beatForm.hidden = true; refresh().catch((e) => { status.textContent = e.message; }); });
  window.addEventListener("aurefold:loremaster-ready", () => refresh().catch((e) => { status.textContent = e.message; }));
  if (token()) refresh().catch((e) => { status.textContent = e.message; });
})();
