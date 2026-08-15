/* AUREFOLD — author-only Scene Scorecards v1.
 * Structured editorial observations, not automatic literary grades and not canon.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const $ = (id) => document.getElementById(id);
  const book = $("lm-score-book");
  const filter = $("lm-score-filter");
  const health = $("lm-score-health");
  const list = $("lm-score-list");
  const runs = $("lm-score-runs");
  const form = $("lm-score-form");
  const status = $("lm-score-status");
  const selectedLabel = $("lm-score-selected");
  const sceneId = $("lm-score-scene-id");

  if (!book || !filter || !health || !list || !runs || !form || !status || !selectedLabel || !sceneId) return;

  const structuredIds = [
    "desire-clarity","obstacle-pressure","conflict-pressure","choice-weight","cost-weight",
    "emotional-change","relationship-change","information-change","material-consequence",
    "reversal-strength","hook-strength","exposition-load","removal-impact"
  ];
  const textIds = [
    "desire","obstacle","conflict","choice","cost","emotional-text","relationship-text",
    "information-text","material-text","reversal-text","hook-text","world-text","theme-text","notes"
  ];

  let rows = [];
  let activeRow = null;

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }
  function esc(value) { return encodeURIComponent(value); }
  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }
  function td(value) { const el = document.createElement("td"); el.textContent = value == null ? "" : String(value); return el; }

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
      throw new Error(`Scorecard API ${response.status}: ${detail.slice(0, 320)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  function signalNames(row) {
    const out = [];
    if (row.information_only_signal) out.push("information-only");
    if (row.static_scene_signal) out.push("static");
    if (row.exposition_dominance_signal) out.push("exposition-heavy");
    if (row.passive_pov_signal) out.push("passive POV");
    if (row.low_removal_cost_signal) out.push("low removal cost");
    if (row.weak_exit_signal) out.push("weak exit");
    return out;
  }

  function isFlagged(row) { return signalNames(row).length > 0; }

  function matchesFilter(row) {
    switch (filter.value) {
      case "priority": return Number(row.open_editorial_issues || 0) > 0;
      case "unassessed": return row.effective_status === "unassessed";
      case "reviewed": return row.effective_status === "reviewed";
      case "draft": return row.effective_status === "draft";
      case "stale": return row.effective_status === "stale";
      case "flagged": return isFlagged(row);
      default: return true;
    }
  }

  function sortedRows(input) {
    const copy = [...input];
    if (filter.value === "priority") {
      copy.sort((a, b) =>
        Number(b.critical_editorial_issues || 0) - Number(a.critical_editorial_issues || 0) ||
        Number(b.high_editorial_issues || 0) - Number(a.high_editorial_issues || 0) ||
        Number(a.scene_order || 9999) - Number(b.scene_order || 9999));
    } else {
      copy.sort((a, b) => Number(a.scene_order || 9999) - Number(b.scene_order || 9999));
    }
    return copy;
  }

  function editButton(row) {
    const button = document.createElement("button");
    button.type = "button"; button.className = "btn"; button.textContent = row.scorecard_id ? "Review" : "Assess";
    button.addEventListener("click", () => selectRow(row));
    return button;
  }

  function renderList() {
    clear(list);
    const shown = sortedRows(rows.filter(matchesFilter));
    if (!shown.length) {
      const tr = document.createElement("tr"); const cell = td("No scenes match this filter."); cell.colSpan = 8; tr.appendChild(cell); list.appendChild(tr); return;
    }
    for (const row of shown) {
      const tr = document.createElement("tr");
      if (isFlagged(row)) tr.dataset.review = "true";
      if (row.effective_status === "stale") tr.dataset.severity = "high";
      const issues = Array.isArray(row.issue_keys) && row.issue_keys.length ? row.issue_keys.join(", ") : "—";
      const signals = signalNames(row).join(", ") || "—";
      const action = document.createElement("td"); action.appendChild(editButton(row));
      tr.append(
        td(row.chapter_number == null ? "—" : row.chapter_number),
        td(row.pov_name || "—"),
        td(row.title || "—"),
        td(row.effective_status || "unassessed"),
        td(signals),
        td(issues),
        td(row.source_revision_label || row.current_version_label || "—"),
        action
      );
      list.appendChild(tr);
    }
  }

  async function loadHealth() {
    const data = await request(`author_scene_scorecard_health?select=*&book_code=eq.${esc(book.value)}`);
    const row = Array.isArray(data) ? data[0] : null;
    clear(health);
    if (!row) { health.textContent = "No scorecard health data."; return; }
    const cards = [
      ["Reviewed", row.reviewed], ["Unassessed", row.unassessed], ["Draft", row.drafts], ["Stale", row.stale],
      ["Info-only signals", row.information_only_signals], ["Static signals", row.static_scene_signals],
      ["Exposition signals", row.exposition_dominance_signals], ["Passive POV signals", row.passive_pov_signals]
    ];
    for (const [label, value] of cards) {
      const card = document.createElement("div"); card.className = "lm-card";
      const strong = document.createElement("strong"); strong.textContent = String(value ?? 0);
      const span = document.createElement("span"); span.textContent = label;
      card.append(strong, span); health.appendChild(card);
    }
  }

  async function loadRows() {
    const data = await request(`author_scene_scorecard_priority?select=*&book_code=eq.${esc(book.value)}&order=scene_order.asc`);
    rows = Array.isArray(data) ? data : [];
    renderList();
  }

  async function loadRuns() {
    const data = await request(`author_scene_scorecard_signal_runs?select=signal_type,start_chapter,end_chapter,run_length,titles&book_code=eq.${esc(book.value)}&order=start_scene_order.asc`);
    clear(runs);
    if (!Array.isArray(data) || !data.length) {
      const tr = document.createElement("tr"); const cell = td("No consecutive diagnostic-signal runs yet."); cell.colSpan = 4; tr.appendChild(cell); runs.appendChild(tr); return;
    }
    for (const row of data) {
      const tr = document.createElement("tr");
      const range = row.start_chapter === row.end_chapter ? `Ch. ${row.start_chapter}` : `Ch. ${row.start_chapter ?? "—"}–${row.end_chapter ?? "—"}`;
      tr.append(td(row.signal_type.replaceAll("_", " ")), td(range), td(row.run_length), td((row.titles || []).join(" → ")));
      runs.appendChild(tr);
    }
  }

  function setValue(id, value) { const el = $(`lm-score-${id}`); if (el) el.value = value == null ? "" : String(value); }
  function getValue(id) { const el = $(`lm-score-${id}`); return el && el.value.trim() ? el.value.trim() : null; }

  function selectRow(row) {
    activeRow = row; sceneId.value = row.scene_id;
    selectedLabel.textContent = `${row.chapter_number == null ? "Interlude / scene" : `Chapter ${row.chapter_number}`} — ${row.title || "Untitled"} · ${row.pov_name || "POV unresolved"} · ${row.effective_status}`;

    const map = {
      "desire": row.desire_text, "obstacle": row.obstacle_text, "conflict": row.conflict_text,
      "choice": row.choice_text, "cost": row.cost_text, "emotional-text": row.emotional_change_text,
      "relationship-text": row.relationship_change_text, "information-text": row.information_change_text,
      "material-text": row.material_consequence_text, "reversal-text": row.reversal_text,
      "hook-text": row.hook_text, "world-text": row.world_house_function_text,
      "theme-text": row.thematic_function_text, "notes": row.notes,
      "desire-clarity": row.desire_clarity, "obstacle-pressure": row.obstacle_pressure,
      "conflict-pressure": row.conflict_pressure, "choice-weight": row.choice_weight,
      "cost-weight": row.cost_weight, "emotional-change": row.emotional_change,
      "relationship-change": row.relationship_change, "information-change": row.information_change,
      "material-consequence": row.material_consequence, "reversal-strength": row.reversal_strength,
      "hook-strength": row.hook_strength, "exposition-load": row.exposition_load,
      "removal-impact": row.removal_impact
    };
    Object.entries(map).forEach(([key, value]) => setValue(key, value));
    form.hidden = false;
    form.scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function clearEditor() {
    activeRow = null; sceneId.value = ""; selectedLabel.textContent = "Choose a scene from the table above.";
    for (const id of [...structuredIds, ...textIds]) setValue(id, null);
    form.hidden = true;
  }

  function requiredStructuredMissing() {
    return structuredIds.filter((id) => !getValue(id));
  }

  async function save(nextStatus) {
    if (!sceneId.value) throw new Error("Choose a scene first.");
    if (nextStatus === "reviewed") {
      const missing = requiredStructuredMissing();
      if (missing.length) throw new Error(`Reviewed scorecards require every structured dimension. Missing: ${missing.join(", ")}`);
    }
    const payload = {
      p_scene_id: sceneId.value,
      p_assessment_status: nextStatus,
      p_desire_text: getValue("desire"), p_obstacle_text: getValue("obstacle"), p_conflict_text: getValue("conflict"),
      p_choice_text: getValue("choice"), p_cost_text: getValue("cost"), p_emotional_change_text: getValue("emotional-text"),
      p_relationship_change_text: getValue("relationship-text"), p_information_change_text: getValue("information-text"),
      p_material_consequence_text: getValue("material-text"), p_reversal_text: getValue("reversal-text"),
      p_hook_text: getValue("hook-text"), p_world_house_function_text: getValue("world-text"),
      p_thematic_function_text: getValue("theme-text"), p_notes: getValue("notes"),
      p_desire_clarity: getValue("desire-clarity"), p_obstacle_pressure: getValue("obstacle-pressure"),
      p_conflict_pressure: getValue("conflict-pressure"), p_choice_weight: getValue("choice-weight"),
      p_cost_weight: getValue("cost-weight"), p_emotional_change: getValue("emotional-change"),
      p_relationship_change: getValue("relationship-change"), p_information_change: getValue("information-change"),
      p_material_consequence: getValue("material-consequence"), p_reversal_strength: getValue("reversal-strength"),
      p_hook_strength: getValue("hook-strength"), p_exposition_load: getValue("exposition-load"),
      p_removal_impact: getValue("removal-impact"),
      p_note: nextStatus === "reviewed" ? "Reviewed through Loremaster Scene Scorecards v1." : "Draft saved through Loremaster Scene Scorecards v1."
    };
    status.textContent = `Saving ${nextStatus} scorecard…`;
    const result = await request("rpc/author_upsert_scene_scorecard", { method: "POST", body: JSON.stringify(payload) });
    status.textContent = `Scorecard saved (${nextStatus}). ${Array.isArray(result) ? result[0] : result || ""}`;
    await refresh();
    const refreshed = rows.find((r) => r.scene_id === payload.p_scene_id);
    if (refreshed) selectRow(refreshed);
  }

  async function refresh() {
    await Promise.all([loadHealth(), loadRows(), loadRuns()]);
  }

  $("lm-score-save-draft").addEventListener("click", () => save("draft").catch((e) => { status.textContent = e.message; }));
  $("lm-score-save-reviewed").addEventListener("click", () => save("reviewed").catch((e) => { status.textContent = e.message; }));
  $("lm-score-clear").addEventListener("click", clearEditor);
  book.addEventListener("change", () => { clearEditor(); refresh().catch((e) => { status.textContent = e.message; }); });
  filter.addEventListener("change", renderList);
  window.addEventListener("aurefold:loremaster-ready", () => refresh().catch((e) => { status.textContent = e.message; }));
  if (token()) refresh().catch((e) => { status.textContent = e.message; });
})();
