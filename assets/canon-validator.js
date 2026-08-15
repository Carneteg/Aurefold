/* AUREFOLD — author-only Canon Validator v1.
 * Manuscript text stays in the browser. Supabase receives rule IDs, locations,
 * hashes and review metadata only; no manuscript excerpts are uploaded.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const ENGINE_VERSION = "aurefold-canon-validator-v1";
  const $ = (id) => document.getElementById(id);
  const book = $("lm-validator-book");
  const version = $("lm-validator-version");
  const file = $("lm-validator-file");
  const scanBtn = $("lm-validator-scan");
  const registerBtn = $("lm-validator-register");
  const dbBtn = $("lm-validator-db");
  const status = $("lm-validator-status");
  const previewBody = $("lm-validator-preview");
  const latestStatus = $("lm-validator-latest-status");
  const latestBody = $("lm-validator-latest");
  let prepared = null;

  if (!book || !version || !file || !scanBtn || !registerBtn || !dbBtn || !status || !previewBody || !latestStatus || !latestBody) return;

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }
  function esc(value) { return encodeURIComponent(value); }
  function normalizeHeading(value) {
    return String(value || "").normalize("NFKC").trim().toLocaleLowerCase("en")
      .replace(/[‘’]/g, "'").replace(/[“”]/g, '"').replace(/[–—]/g, "-").replace(/\s+/g, " ");
  }
  function normalizeNewlines(text) { return String(text || "").replace(/\r\n/g, "\n").replace(/\r/g, "\n"); }
  function td(value) { const el = document.createElement("td"); el.textContent = value == null ? "" : String(value); return el; }
  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }

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
      throw new Error(`Canon API ${response.status}: ${detail.slice(0, 280)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  async function digest(text) {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(String(text || "")));
    return Array.from(new Uint8Array(buf), (b) => b.toString(16).padStart(2, "0")).join("");
  }

  function parseSections(rawText, baseline) {
    const raw = normalizeNewlines(rawText);
    const lines = raw.split("\n");
    const starts = [];
    const sectionRe = /^##\s+(Chapter\b.*|Interlude|Prologue|Epilogue)\s*$/i;
    for (let i = 0; i < lines.length; i += 1) if (sectionRe.test(lines[i])) starts.push(i);

    if (!starts.length) {
      return [{ ordinal: 1, chapter_number: null, heading: "Whole manuscript", stable_key: null, start_line: 1, end_line: lines.length, text: raw }];
    }
    starts.push(lines.length);

    const byHeading = new Map();
    for (const row of baseline) {
      const key = normalizeHeading(row.heading);
      if (!key) continue;
      if (!byHeading.has(key)) byHeading.set(key, []);
      byHeading.get(key).push(row);
    }

    const sections = [];
    let chapterCounter = 0;
    for (let i = 0; i < starts.length - 1; i += 1) {
      const start = starts[i]; const end = starts[i + 1];
      const label = lines[start].replace(/^##\s+/, "").trim();
      const isChapter = /^Chapter\b/i.test(label);
      if (isChapter) chapterCounter += 1;
      const titleMatch = (lines[start + 1] || "").match(/^###\s+(.+?)\s*$/);
      const heading = titleMatch ? titleMatch[1].trim() : label;
      const candidates = byHeading.get(normalizeHeading(heading)) || [];
      const stable = candidates.length === 1 ? candidates[0].stable_key : null;
      sections.push({
        ordinal: i + 1,
        chapter_number: isChapter ? chapterCounter : null,
        heading,
        stable_key: stable,
        start_line: start + 1,
        end_line: end,
        text: lines.slice(start, end).join("\n")
      });
    }
    return sections;
  }

  function lineForMatch(section, index) {
    const prior = section.text.slice(0, Math.max(0, index));
    return section.start_line + (prior.match(/\n/g) || []).length;
  }

  function localExcerpt(text, start, length) {
    const a = Math.max(0, start - 120); const b = Math.min(text.length, start + length + 160);
    return text.slice(a, b).replace(/\s+/g, " ").trim();
  }

  async function loadRules() {
    const rows = await request(`author_canon_validation_rules?select=rule_key,title,description,severity,scope,book_code,detector_type,detector_config,source_lock_number,source_continuity_rule_key,blocking_mode&enabled=eq.true&or=(scope.eq.global,and(scope.eq.book,book_code.eq.${esc(book.value)}))&order=severity.asc,rule_key.asc`);
    return Array.isArray(rows) ? rows : [];
  }

  async function loadBaseline() {
    const rows = await request(`author_manuscript_current_sections?select=stable_key,heading,chapter_number,ordinal&book_code=eq.${esc(book.value)}&order=ordinal.asc`);
    return Array.isArray(rows) ? rows : [];
  }

  async function runRule(rule, raw, sections) {
    const findings = [];
    const cfgRule = rule.detector_config || {};
    const patterns = Array.isArray(cfgRule.patterns) ? cfgRule.patterns : [];

    if (rule.detector_type === "manual_semantic") {
      const triggers = Array.isArray(cfgRule.trigger_patterns) ? cfgRule.trigger_patterns : [];
      if (triggers.length) {
        const relevant = triggers.some((p) => { try { return new RegExp(p, "isu").test(raw); } catch (_) { return false; } });
        if (!relevant) return findings;
      }
      findings.push({
        rule_key: rule.rule_key, title: rule.title, severity: rule.severity,
        section_key: null, chapter_number: null, line_start: null, line_end: null,
        confidence: "manual_required", detector_code: "manual_semantic",
        evidence_sha256: null, detector_detail: {},
        message: cfgRule.finding_message || rule.description,
        excerpt: "Manual semantic review required; no prose was uploaded."
      });
      return findings;
    }

    if (rule.detector_type === "local_required_all") {
      const missing = [];
      patterns.forEach((p, index) => {
        try { if (!new RegExp(p, "isu").test(raw)) missing.push(index); }
        catch (_) { missing.push(index); }
      });
      if (missing.length) findings.push({
        rule_key: rule.rule_key, title: rule.title, severity: rule.severity,
        section_key: null, chapter_number: null, line_start: null, line_end: null,
        confidence: "candidate", detector_code: "required_signal_missing",
        evidence_sha256: null, detector_detail: { missing_pattern_indexes: missing, pattern_count: patterns.length },
        message: cfgRule.finding_message || rule.description,
        excerpt: `Required signal check missing ${missing.length} of ${patterns.length} expected pattern(s).`
      });
      return findings;
    }

    if (rule.detector_type !== "local_regex") return findings;
    let emitted = 0;
    for (let pIndex = 0; pIndex < patterns.length; pIndex += 1) {
      let regex;
      try { regex = new RegExp(patterns[pIndex], "gisu"); } catch (_) { continue; }
      for (const section of sections) {
        regex.lastIndex = 0;
        let match;
        while ((match = regex.exec(section.text)) && emitted < 12) {
          const line = lineForMatch(section, match.index);
          findings.push({
            rule_key: rule.rule_key, title: rule.title, severity: rule.severity,
            section_key: section.stable_key || `unmapped:${section.ordinal}`,
            chapter_number: section.chapter_number,
            line_start: line, line_end: line + (match[0].match(/\n/g) || []).length,
            confidence: "candidate", detector_code: "regex_candidate",
            evidence_sha256: await digest(match[0]),
            detector_detail: { pattern_index: pIndex, match_length: match[0].length, section_ordinal: section.ordinal },
            message: cfgRule.finding_message || rule.description,
            excerpt: localExcerpt(section.text, match.index, match[0].length)
          });
          emitted += 1;
          if (!match[0].length) regex.lastIndex += 1;
        }
        if (emitted >= 12) break;
      }
      if (emitted >= 12) break;
    }
    return findings;
  }

  function renderPreview(findings) {
    clear(previewBody);
    if (!findings.length) {
      const tr = document.createElement("tr"); const cell = td("No lexical candidates or manual checks were generated."); cell.colSpan = 5; tr.appendChild(cell); previewBody.appendChild(tr); return;
    }
    for (const f of findings) {
      const tr = document.createElement("tr"); tr.dataset.severity = f.severity;
      const source = f.rule_key.startsWith("global.") ? "Constitution" : (f.rule_key.startsWith("book1.") ? "Book One lock/control" : "Rule");
      tr.append(td(f.severity.toUpperCase()), td(f.title), td(f.section_key || "whole manuscript"), td(f.excerpt || f.message), td(source));
      previewBody.appendChild(tr);
    }
  }

  async function scan() {
    if (!file.files[0]) throw new Error("Choose a Markdown manuscript first.");
    status.textContent = "Reading and checking manuscript locally…";
    const [rules, baseline, text] = await Promise.all([loadRules(), loadBaseline(), file.files[0].text()]);
    const raw = normalizeNewlines(text);
    const sections = parseSections(raw, baseline);
    const findings = [];
    for (const rule of rules) findings.push(...await runRule(rule, raw, sections));
    const sourceSha = await digest(raw);
    prepared = { findings, source_sha256: sourceSha, filename: file.files[0].name, sections: sections.length };
    renderPreview(findings);
    const lexical = findings.filter((f) => f.confidence === "candidate").length;
    const manual = findings.filter((f) => f.confidence === "manual_required").length;
    status.textContent = `${sections.length} sections checked locally · ${lexical} candidate finding(s) · ${manual} manual semantic check(s). No manuscript prose left the browser.`;
    registerBtn.disabled = false;
  }

  async function registerValidation() {
    if (!prepared) throw new Error("Run a local scan first.");
    const payloadFindings = prepared.findings.map((f) => ({
      rule_key: f.rule_key,
      section_key: f.section_key,
      chapter_number: f.chapter_number,
      line_start: f.line_start,
      line_end: f.line_end,
      confidence: f.confidence,
      detector_code: f.detector_code,
      evidence_sha256: f.evidence_sha256,
      detector_detail: f.detector_detail
    }));
    const payload = {
      p_book_code: book.value,
      p_manuscript_version_label: version.value.trim() || null,
      p_source_sha256: prepared.source_sha256,
      p_engine_version: ENGINE_VERSION,
      p_findings: payloadFindings,
      p_notes: `Validated locally from ${prepared.filename}. No manuscript prose uploaded.`
    };
    registerBtn.disabled = true;
    status.textContent = "Registering hash-only validation result…";
    const run = await request("rpc/author_register_canon_validation_run", { method: "POST", body: JSON.stringify(payload) });
    status.textContent = `Validation registered. Run ${Array.isArray(run) ? run[0] : run}. Open candidates keep status yellow until reviewed; confirmed critical/error findings turn it red.`;
    prepared = null;
    await refreshLatest();
  }

  async function runDatabaseValidation() {
    dbBtn.disabled = true; status.textContent = "Running deterministic canon database checks…";
    try {
      const run = await request("rpc/author_run_database_canon_validation", { method: "POST", body: JSON.stringify({}) });
      status.textContent = `Database canon validation complete. Run ${Array.isArray(run) ? run[0] : run}.`;
      await refreshLatest(true);
    } finally { dbBtn.disabled = false; }
  }

  async function reviewFinding(id, nextState) {
    await request("rpc/author_review_canon_validation_finding", {
      method: "POST",
      body: JSON.stringify({ p_finding_id: id, p_state: nextState, p_note: "Reviewed in Loremaster Canon Validator." })
    });
    await refreshLatest();
  }

  function actionButton(label, fn) {
    const button = document.createElement("button"); button.type = "button"; button.className = "btn"; button.textContent = label;
    button.addEventListener("click", fn); return button;
  }

  async function refreshLatest(databaseOnly = false) {
    const filter = databaseOnly ? "validation_kind=eq.database" : `book_code=eq.${esc(book.value)}`;
    const runs = await request(`author_canon_validation_runs?select=id,validation_kind,book_code,manuscript_version_label,overall_status,critical_count,error_count,warning_count,info_count,open_count,confirmed_count,started_at&${filter}&order=started_at.desc&limit=1`);
    const run = Array.isArray(runs) ? runs[0] : null;
    clear(latestBody);
    if (!run) { latestStatus.textContent = "No validation run registered yet."; return; }
    latestStatus.textContent = `${run.overall_status.toUpperCase()} · ${run.validation_kind} · ${run.open_count} open · ${run.confirmed_count} confirmed · ${run.critical_count} critical · ${run.error_count} error · ${run.warning_count} warning`;
    const findings = await request(`author_canon_validation_findings?select=id,rule_key,title,source_lock_number,source_continuity_rule_key,section_key,chapter_number,severity,finding_state,confidence,finding_message&run_id=eq.${run.id}&order=severity.asc,rule_key.asc`);
    if (!Array.isArray(findings) || !findings.length) {
      const tr = document.createElement("tr"); const cell = td("No findings. This run is clean."); cell.colSpan = 6; tr.appendChild(cell); latestBody.appendChild(tr); return;
    }
    for (const f of findings) {
      const tr = document.createElement("tr");
      const source = f.source_lock_number ? `Lock #${String(f.source_lock_number).padStart(3, "0")}` : (f.source_continuity_rule_key || "—");
      const actions = document.createElement("td");
      if (f.finding_state === "open") {
        actions.append(actionButton("Confirm", () => reviewFinding(f.id, "confirmed").catch((e) => { status.textContent = e.message; })), document.createTextNode(" "), actionButton("Dismiss", () => reviewFinding(f.id, "dismissed").catch((e) => { status.textContent = e.message; })));
      } else actions.textContent = f.finding_state;
      tr.append(td(f.severity.toUpperCase()), td(f.title), td(f.section_key || "whole manuscript"), td(f.finding_state), td(source), actions);
      latestBody.appendChild(tr);
    }
  }

  scanBtn.addEventListener("click", () => {
    prepared = null; registerBtn.disabled = true; clear(previewBody);
    scan().catch((error) => { status.textContent = error.message; });
  });
  registerBtn.addEventListener("click", () => registerValidation().catch((error) => { registerBtn.disabled = false; status.textContent = error.message; }));
  dbBtn.addEventListener("click", () => runDatabaseValidation().catch((error) => { status.textContent = error.message; dbBtn.disabled = false; }));
  book.addEventListener("change", () => { prepared = null; registerBtn.disabled = true; clear(previewBody); refreshLatest().catch((e) => { latestStatus.textContent = e.message; }); });
  file.addEventListener("change", () => { prepared = null; registerBtn.disabled = true; clear(previewBody); });

  window.addEventListener("aurefold:loremaster-ready", () => refreshLatest().catch((e) => { latestStatus.textContent = e.message; }));
  if (token()) refreshLatest().catch((e) => { latestStatus.textContent = e.message; });
})();
