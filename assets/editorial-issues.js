/* AUREFOLD — author-only editorial issue workflow.
 * Editorial issues are development diagnostics. They do not create or amend canon.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const $ = (id) => document.getElementById(id);
  const book = $("lm-editorial-book");
  const statusFilter = $("lm-editorial-filter-status");
  const tbody = $("lm-editorial-list");
  const health = $("lm-editorial-health");
  const form = $("lm-editorial-form");
  const message = $("lm-editorial-status");

  if (!book || !statusFilter || !tbody || !health || !form || !message) return;

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
      throw new Error(`Editorial API ${response.status}: ${detail.slice(0, 320)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  function parseChapters(value) {
    const result = new Set();
    for (const raw of String(value || "").split(",")) {
      const part = raw.trim();
      if (!part) continue;
      const range = part.match(/^(\d+)\s*-\s*(\d+)$/);
      if (range) {
        const a = Number(range[1]); const b = Number(range[2]);
        if (a < 1 || b < 1 || a > 999 || b > 999) throw new Error(`Invalid chapter range: ${part}`);
        for (let n = Math.min(a, b); n <= Math.max(a, b); n += 1) result.add(n);
      } else if (/^\d+$/.test(part)) {
        const n = Number(part);
        if (n < 1 || n > 999) throw new Error(`Invalid chapter number: ${part}`);
        result.add(n);
      } else {
        throw new Error(`Could not parse chapter scope: ${part}`);
      }
    }
    return [...result].sort((a, b) => a - b);
  }

  function parseSlugs(value) {
    return [...new Set(String(value || "").split(",").map((s) => s.trim()).filter(Boolean))];
  }

  function scopeLabel(row) {
    const chapters = Array.isArray(row.chapters) ? row.chapters : [];
    const entities = Array.isArray(row.entity_names) ? row.entity_names : [];
    const parts = [];
    if (chapters.length) parts.push(`Ch. ${chapters.join(", ")}`);
    if (entities.length) parts.push(entities.join(", "));
    return parts.length ? parts.join(" · ") : "Book-wide / not yet scoped";
  }

  function makeStatusSelect(row) {
    const select = document.createElement("select");
    const statuses = ["open","investigating","planned","in_revision","resolved","deferred","wont_fix","superseded"];
    for (const state of statuses) {
      const option = document.createElement("option"); option.value = state; option.textContent = state.replaceAll("_", " ");
      if (state === row.status) option.selected = true;
      select.appendChild(option);
    }
    return select;
  }

  async function updateIssue(row, nextStatus) {
    let note = window.prompt(`Editorial note for ${row.issue_key}:`, nextStatus === row.status ? "Review note" : `Move ${row.status} → ${nextStatus}`);
    if (note === null) return;
    note = note.trim();
    let resolvedVersion = null;
    if (nextStatus === "resolved") {
      resolvedVersion = window.prompt("Resolved in manuscript version:", row.target_version || "English Master v1.7");
      if (resolvedVersion === null || !resolvedVersion.trim()) throw new Error("Resolved version is required.");
      resolvedVersion = resolvedVersion.trim();
    }
    if ((nextStatus === "deferred" || nextStatus === "wont_fix") && !note) throw new Error("A note is required for deferred/wont_fix.");

    await request("rpc/author_update_editorial_issue", {
      method: "POST",
      body: JSON.stringify({
        p_issue_id: row.id,
        p_status: nextStatus,
        p_note: note || null,
        p_diagnosis: null,
        p_recommendation: null,
        p_acceptance_criteria: null,
        p_target_version: row.target_version || null,
        p_resolved_in_version: resolvedVersion
      })
    });
    message.textContent = `${row.issue_key} updated to ${nextStatus}.`;
    await refresh();
  }

  function renderIssues(rows) {
    clear(tbody);
    if (!rows.length) {
      const tr = document.createElement("tr"); const cell = td("No editorial issues match this filter."); cell.colSpan = 7; tr.appendChild(cell); tbody.appendChild(tr); return;
    }
    for (const row of rows) {
      const tr = document.createElement("tr"); tr.dataset.severity = row.severity;
      const titleCell = document.createElement("td");
      const strong = document.createElement("strong"); strong.textContent = row.title;
      const desc = document.createElement("div"); desc.className = "lm-small"; desc.textContent = row.description;
      titleCell.append(strong, desc);

      const scopeCell = td(scopeLabel(row));
      const target = td(row.target_version || "—");
      const actionCell = document.createElement("td");
      const select = makeStatusSelect(row);
      const button = document.createElement("button"); button.type = "button"; button.className = "btn"; button.textContent = "Update";
      button.addEventListener("click", () => updateIssue(row, select.value).catch((error) => { message.textContent = error.message; }));
      actionCell.append(select, document.createTextNode(" "), button);

      tr.append(td(row.severity.toUpperCase()), td(row.category), titleCell, scopeCell, td(row.status.replaceAll("_", " ")), target, actionCell);
      tbody.appendChild(tr);
    }
  }

  async function loadHealth() {
    const rows = await request(`author_editorial_health?select=book_code,title,total_issues,active_issues,critical_active,high_active,resolved_issues,in_revision&book_code=eq.${esc(book.value)}`);
    const row = Array.isArray(rows) ? rows[0] : null;
    clear(health);
    if (!row) { health.textContent = "No editorial health row available."; return; }
    const items = [
      ["Active", row.active_issues],
      ["Critical", row.critical_active],
      ["High", row.high_active],
      ["In revision", row.in_revision],
      ["Resolved", row.resolved_issues]
    ];
    for (const [label, value] of items) {
      const card = document.createElement("div"); card.className = "lm-card";
      const strong = document.createElement("strong"); strong.textContent = String(value ?? 0);
      const span = document.createElement("span"); span.textContent = label;
      card.append(strong, span); health.appendChild(card);
    }
  }

  async function loadIssues() {
    let query = `select=id,issue_key,book_code,title,category,severity,status,description,diagnosis,recommendation,acceptance_criteria,discovered_in_version,target_version,resolved_in_version,source_kind,source_label,scene_count,chapters,entity_names&book_code=eq.${esc(book.value)}&order=severity.asc,updated_at.desc`;
    if (statusFilter.value !== "active" && statusFilter.value !== "all") query += `&status=eq.${esc(statusFilter.value)}`;
    const rows = await request(`author_editorial_issues?${query}`);
    const filtered = statusFilter.value === "active"
      ? (Array.isArray(rows) ? rows.filter((r) => !["resolved","wont_fix","superseded"].includes(r.status)) : [])
      : (Array.isArray(rows) ? rows : []);
    renderIssues(filtered);
  }

  async function refresh() {
    await Promise.all([loadHealth(), loadIssues()]);
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    try {
      const chapters = parseChapters($("lm-editorial-chapters").value);
      const slugs = parseSlugs($("lm-editorial-entities").value);
      const payload = {
        p_book_code: book.value,
        p_title: $("lm-editorial-title").value.trim(),
        p_category: $("lm-editorial-category").value,
        p_severity: $("lm-editorial-severity").value,
        p_description: $("lm-editorial-description").value.trim(),
        p_diagnosis: $("lm-editorial-diagnosis").value.trim() || null,
        p_recommendation: $("lm-editorial-recommendation").value.trim() || null,
        p_acceptance_criteria: $("lm-editorial-acceptance").value.trim() || null,
        p_discovered_in_version: $("lm-editorial-discovered").value.trim() || null,
        p_target_version: $("lm-editorial-target").value.trim() || null,
        p_source_kind: $("lm-editorial-source-kind").value,
        p_source_label: $("lm-editorial-source-label").value.trim() || null,
        p_source_notes: "Created in Loremaster Editorial Issues.",
        p_chapter_numbers: chapters.length ? chapters : null,
        p_entity_slugs: slugs.length ? slugs : null
      };
      message.textContent = "Creating editorial issue…";
      const id = await request("rpc/author_create_editorial_issue", { method: "POST", body: JSON.stringify(payload) });
      message.textContent = `Editorial issue created: ${Array.isArray(id) ? id[0] : id}.`;
      form.reset();
      $("lm-editorial-target").value = "English Master v1.7";
      $("lm-editorial-discovered").value = "English Master v1.6";
      await refresh();
    } catch (error) {
      message.textContent = error.message;
    }
  });

  book.addEventListener("change", () => refresh().catch((error) => { message.textContent = error.message; }));
  statusFilter.addEventListener("change", () => loadIssues().catch((error) => { message.textContent = error.message; }));
  window.addEventListener("aurefold:loremaster-ready", () => refresh().catch((error) => { message.textContent = error.message; }));
  if (token()) refresh().catch((error) => { message.textContent = error.message; });
})();
