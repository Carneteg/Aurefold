/* AUREFOLD — browser-side manuscript sync.
 * The selected Markdown file is parsed and hashed locally. Only structural
 * metadata + SHA-256 hashes are sent to Supabase; prose never leaves browser.
 */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const parserVersion = "aurefold-manuscript-sync-v1";
  const $ = (id) => document.getElementById(id);
  const book = $("lm-sync-book");
  const version = $("lm-sync-version");
  const file = $("lm-sync-file");
  const previewBtn = $("lm-sync-preview-btn");
  const registerBtn = $("lm-sync-register-btn");
  const confirmBox = $("lm-sync-confirm");
  const status = $("lm-sync-status");
  const current = $("lm-sync-current");
  const tbody = $("lm-sync-preview");
  let prepared = null;

  if (!book || !version || !file || !previewBtn || !registerBtn || !confirmBox || !status || !current || !tbody) return;

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }
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
      throw new Error(`Canon API ${response.status}: ${detail.slice(0, 240)}`);
    }
    const text = await response.text();
    if (!text) return null;
    try { return JSON.parse(text); } catch (_) { return text; }
  }

  function normalizeNewlines(text) { return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n"); }
  function normalizeBlock(text) {
    const rows = normalizeNewlines(text).split("\n").map((line) => line.replace(/[ \t]+$/g, ""));
    return rows.join("\n").trim() + "\n";
  }
  function normalizeHeading(text) {
    return String(text || "").normalize("NFKC").trim().toLocaleLowerCase("en")
      .replace(/[‘’]/g, "'").replace(/[“”]/g, '"').replace(/[–—]/g, "-").replace(/\s+/g, " ");
  }
  async function digest(text) {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
    return Array.from(new Uint8Array(buf), (b) => b.toString(16).padStart(2, "0")).join("");
  }
  function wordCount(text) { return (text.match(/[\p{L}\p{N}_’'-]+/gu) || []).length; }
  function sectionType(label) {
    const low = label.toLowerCase();
    if (low.startsWith("chapter")) return "chapter";
    if (low === "interlude") return "interlude";
    if (low === "prologue") return "prologue";
    if (low === "epilogue") return "epilogue";
    return "other";
  }
  function esc(value) { return encodeURIComponent(value); }

  async function loadCurrentSections() {
    const rows = await request(`author_manuscript_current_sections?select=stable_key,section_type,ordinal,chapter_number,heading,content_sha256,body_sha256,word_count&book_code=eq.${esc(book.value)}&order=ordinal.asc`);
    return Array.isArray(rows) ? rows : [];
  }

  async function refreshCurrent() {
    try {
      const rows = await request(`author_manuscript_sync_status?select=book_code,version_label,revision_status,section_count,word_count,pending_reviews&book_code=eq.${esc(book.value)}`);
      const row = Array.isArray(rows) ? rows[0] : null;
      current.textContent = row
        ? `${row.version_label || "No manuscript baseline"} · ${row.revision_status || ""} · ${row.section_count || 0} sections · ${row.pending_reviews || 0} pending reviews`
        : "No manuscript baseline registered.";
    } catch (error) {
      current.textContent = `Could not read sync status: ${error.message}`;
    }
  }

  async function parseMarkdown(text, baseline) {
    const raw = normalizeNewlines(text);
    const lines = raw.split("\n");
    const starts = [];
    const sectionRe = /^##\s+(Chapter\b.*|Interlude|Prologue|Epilogue)\s*$/i;
    for (let i = 0; i < lines.length; i += 1) if (sectionRe.test(lines[i])) starts.push(i);
    if (!starts.length) throw new Error("No Markdown sections found. Expected headings such as '## Chapter One'.");
    starts.push(lines.length);

    const byHeading = new Map();
    const byBody = new Map();
    for (const row of baseline) {
      const hk = normalizeHeading(row.heading);
      if (!byHeading.has(hk)) byHeading.set(hk, []);
      byHeading.get(hk).push(row);
      if (!byBody.has(row.body_sha256)) byBody.set(row.body_sha256, []);
      byBody.get(row.body_sha256).push(row);
    }

    const used = new Set();
    const sections = [];
    let chapterCounter = 0;

    for (let index = 0; index < starts.length - 1; index += 1) {
      const start = starts[index];
      const end = starts[index + 1];
      const label = lines[start].replace(/^##\s+/, "").trim();
      const type = sectionType(label);
      let chapterNumber = null;
      if (type === "chapter") { chapterCounter += 1; chapterNumber = chapterCounter; }

      let heading = "";
      let bodyStart = start + 1;
      const titleMatch = (lines[start + 1] || "").match(/^###\s+(.+?)\s*$/);
      if (titleMatch) { heading = titleMatch[1].trim(); bodyStart = start + 2; }

      const bodyText = normalizeBlock(lines.slice(bodyStart, end).join("\n"));
      const sectionText = normalizeBlock(lines.slice(start, end).join("\n"));
      const [bodyHash, contentHash] = await Promise.all([digest(bodyText), digest(sectionText)]);

      let stableKey = null;
      let mappingStatus = "unmapped";
      const marker = (lines[start - 1] || "").match(/^<!--\s*aurefold:section\s+([A-Za-z0-9._:-]+)\s*-->\s*$/);
      if (marker && !used.has(marker[1])) { stableKey = marker[1]; mappingStatus = "marker"; }
      if (!stableKey && heading) {
        const candidates = (byHeading.get(normalizeHeading(heading)) || []).filter((r) => !used.has(r.stable_key));
        if (candidates.length === 1) { stableKey = candidates[0].stable_key; mappingStatus = "heading"; }
      }
      if (!stableKey) {
        const candidates = (byBody.get(bodyHash) || []).filter((r) => !used.has(r.stable_key));
        if (candidates.length === 1) { stableKey = candidates[0].stable_key; mappingStatus = "body_hash"; }
      }
      if (!stableKey) stableKey = `${book.value.replace("book-", "b")}-new-${contentHash.slice(0, 12)}`;
      if (used.has(stableKey)) throw new Error(`Duplicate stable section key: ${stableKey}`);
      used.add(stableKey);

      sections.push({
        stable_key: stableKey,
        section_type: type,
        chapter_number: chapterNumber,
        ordinal: index + 1,
        label,
        heading,
        start_line: start + 1,
        end_line: end,
        word_count: wordCount(bodyText),
        content_sha256: contentHash,
        body_sha256: bodyHash,
        metadata: { mapping_status: mappingStatus }
      });
    }

    return {
      parser_version: parserVersion,
      source_sha256: await digest(raw),
      section_count: sections.length,
      word_count: sections.reduce((n, s) => n + s.word_count, 0),
      sections
    };
  }

  function compare(baseline, parsed) {
    const oldMap = new Map(baseline.map((r) => [r.stable_key, r]));
    const newMap = new Map(parsed.sections.map((r) => [r.stable_key, r]));
    const keys = [...new Set([...oldMap.keys(), ...newMap.keys()])];
    return keys.map((key) => {
      const a = oldMap.get(key); const b = newMap.get(key);
      let change = "unchanged";
      if (!a) change = "added";
      else if (!b) change = "removed";
      else if (a.body_sha256 !== b.body_sha256) change = "modified";
      else if ((a.heading || "") !== (b.heading || "")) change = "renamed";
      else if (Number(a.ordinal) !== Number(b.ordinal)) change = "moved";
      return { stable_key: key, change_type: change, old: a, next: b, needs_review: change !== "unchanged" };
    }).sort((x, y) => Number((x.next || x.old || {}).ordinal || 9999) - Number((y.next || y.old || {}).ordinal || 9999));
  }

  function renderPreview(changes) {
    tbody.textContent = "";
    for (const row of changes) {
      const tr = document.createElement("tr");
      const vals = [row.next?.ordinal ?? row.old?.ordinal ?? "—", row.stable_key,
        row.next?.heading || row.old?.heading || "—", row.change_type,
        row.next?.metadata?.mapping_status || (row.old ? "baseline" : "—")];
      for (const value of vals) { const td = document.createElement("td"); td.textContent = String(value); tr.appendChild(td); }
      if (row.needs_review) tr.dataset.review = "true";
      tbody.appendChild(tr);
    }
  }

  async function prepare() {
    if (!file.files[0]) throw new Error("Choose a Markdown manuscript file first.");
    if (!version.value.trim()) throw new Error("Enter the new manuscript version label.");
    const baseline = await loadCurrentSections();
    if (!baseline.length) throw new Error("No current manuscript baseline exists for this book.");
    const text = await file.files[0].text();
    const parsed = await parseMarkdown(text, baseline);
    const changes = compare(baseline, parsed);
    const unmapped = parsed.sections.filter((s) => s.metadata.mapping_status === "unmapped").length;
    const review = changes.filter((c) => c.needs_review).length;
    prepared = { baseline, parsed, changes, filename: file.files[0].name };
    renderPreview(changes);
    status.textContent = `${parsed.section_count} sections · ${parsed.word_count} sync-parser words · ${review} changed/added/removed · ${unmapped} unmapped. Prose remained local.`;
    registerBtn.disabled = false;
    confirmBox.checked = false;
  }

  async function register() {
    if (!prepared) throw new Error("Preview the manuscript first.");
    if (!confirmBox.checked) throw new Error("Confirm that this version should become the current operational manuscript baseline.");
    const payload = {
      p_book_code: book.value,
      p_version_label: version.value.trim(),
      p_source_filename: prepared.filename,
      p_source_sha256: prepared.parsed.source_sha256,
      p_word_count: prepared.parsed.word_count,
      p_sections: prepared.parsed.sections,
      p_notes: "Registered through Loremaster Manuscript Sync. Hash-only upload; prose remained local."
    };
    registerBtn.disabled = true;
    status.textContent = "Registering hashes and building review queue…";
    const result = await request("rpc/author_register_manuscript_version", { method: "POST", body: JSON.stringify(payload) });
    status.textContent = `Registered ${payload.p_version_label}. Sync run: ${Array.isArray(result) ? JSON.stringify(result) : result || "complete"}. Review queue created for affected sections.`;
    prepared = null;
    await refreshCurrent();
  }

  previewBtn.addEventListener("click", () => {
    status.textContent = "Parsing and hashing locally…";
    registerBtn.disabled = true;
    prepare().catch((error) => { prepared = null; tbody.textContent = ""; status.textContent = error.message; });
  });
  registerBtn.addEventListener("click", () => register().catch((error) => { registerBtn.disabled = false; status.textContent = error.message; }));
  book.addEventListener("change", () => { prepared = null; tbody.textContent = ""; registerBtn.disabled = true; refreshCurrent(); });
  file.addEventListener("change", () => { prepared = null; registerBtn.disabled = true; confirmBox.checked = false; });

  window.addEventListener("aurefold:loremaster-ready", refreshCurrent);
  if (token()) refreshCurrent();
})();
