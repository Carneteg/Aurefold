(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const $ = (id) => document.getElementById(id);
  const token = () => sessionStorage.getItem(TOKEN_KEY) || "";
  const state = { latest: null, checks: [], version: null };

  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }
  function td(value) { const cell = document.createElement("td"); cell.textContent = value == null || value === "" ? "—" : String(value); return cell; }
  function empty(body, message, columns) { const row = document.createElement("tr"); const cell = td(message); cell.colSpan = columns; row.append(cell); body.append(row); }
  function shortHash(value) { return value ? `${value.slice(0, 12)}…` : "—"; }
  function stamp(value) { return value ? new Date(value).toLocaleString() : "—"; }

  async function request(path, options = {}) {
    if (!token()) throw new Error("Not signed in");
    const response = await fetch(`${cfg.supabaseUrl}/rest/v1/${path}`, {
      ...options,
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: `Bearer ${token()}`,
        Accept: "application/json",
        ...(options.body ? { "Content-Type": "application/json" } : {}),
        ...(options.headers || {})
      }
    });
    if (!response.ok) throw new Error(`Release Gate API ${response.status}: ${(await response.text()).slice(0, 500)}`);
    const text = await response.text();
    return text ? JSON.parse(text) : null;
  }

  function renderHealth() {
    const box = $("rr-health"); clear(box);
    const run = state.latest || {};
    const metrics = [
      ["Status", run.readiness_status || "not evaluated"], ["Freshness", run.run_freshness || "—"],
      ["Blockers", run.blocker_count ?? 0], ["Warnings", run.warning_count ?? 0],
      ["Passed", run.pass_count ?? 0], ["Unknown", run.unknown_count ?? 0],
      ["Checks", run.check_count ?? 0], ["Decision", run.latest_decision || "none"]
    ];
    for (const [label, value] of metrics) { const card = document.createElement("div"); card.className = "rr-card"; const strong = document.createElement("strong"); strong.textContent = value; card.append(strong, label); box.append(card); }
    $("rr-status").textContent = !state.latest ? "No evaluation exists for this book." : run.readiness_status === "ready" ? "All blocking controls and warnings are green. Human approval is still required." : run.readiness_status === "review_required" ? "No blocker remains, but warnings require explicit acknowledgment." : "Release handling is blocked. Resolve every failed or unknown blocking check and evaluate again.";
  }

  function filteredChecks() {
    const filter = $("rr-filter").value;
    if (filter === "attention") return state.checks.filter((check) => check.result_status === "fail" || check.result_status === "unknown");
    if (filter === "blocking") return state.checks.filter((check) => check.check_severity === "blocking");
    if (filter === "warning") return state.checks.filter((check) => check.check_severity === "warning");
    return state.checks;
  }

  function renderChecks() {
    const body = $("rr-checks"); clear(body);
    for (const check of filteredChecks()) {
      const row = document.createElement("tr"); row.dataset.result = check.result_status; row.dataset.severity = check.check_severity;
      row.append(td(check.ordinal), td(check.subsystem), td(check.title), td(check.check_severity), td(check.result_status), td(check.summary), td(JSON.stringify(check.observed_value)));
      body.append(row);
    }
    if (!body.children.length) empty(body, "No checks match this filter.", 7);
  }

  function renderAcknowledgments() {
    const box = $("rr-warning-acks"); clear(box);
    const warnings = state.checks.filter((check) => check.check_severity === "warning" && (check.result_status === "fail" || check.result_status === "unknown"));
    if (!warnings.length) { const p = document.createElement("p"); p.textContent = "No warning acknowledgment is required."; box.append(p); return; }
    for (const check of warnings) {
      const label = document.createElement("label"); const input = document.createElement("input"); input.type = "checkbox"; input.name = "rr-warning"; input.value = check.check_key;
      label.append(input, ` Acknowledge ${check.check_key}: ${check.summary}`); box.append(label);
    }
  }

  function renderRuns(runs) {
    const body = $("rr-runs"); clear(body);
    for (const run of runs) {
      const row = document.createElement("tr"); row.dataset.result = run.readiness_status === "blocked" ? "fail" : "pass";
      row.append(td(stamp(run.evaluated_at)), td(run.version_label), td(run.run_freshness), td(run.readiness_status), td(run.blocker_count), td(run.warning_count), td(shortHash(run.snapshot_sha256)), td(run.latest_decision || "—")); body.append(row);
    }
    if (!runs.length) empty(body, "No Release Gate run exists.", 8);
  }

  async function refresh() {
    const book = $("rr-book").value;
    const [versions, latest, runs] = await Promise.all([
      request(`author_manuscript_sync_status?select=version_id,version_label,source_sha256,is_current&book_code=eq.${encodeURIComponent(book)}&limit=1`),
      request(`author_release_gate_latest?select=*&book_code=eq.${encodeURIComponent(book)}&limit=1`),
      request(`author_release_gate_runs?select=*&book_code=eq.${encodeURIComponent(book)}&order=evaluated_at.desc&limit=30`)
    ]);
    state.version = versions[0] || null; state.latest = latest[0] || null;
    $("rr-version").textContent = state.version ? `${state.version.version_label} · ${shortHash(state.version.source_sha256)}` : "No current manuscript version is registered.";
    state.checks = state.latest ? await request(`author_release_gate_checks?select=*&run_id=eq.${state.latest.run_id}&order=ordinal.asc`) : [];
    renderHealth(); renderChecks(); renderAcknowledgments(); renderRuns(runs);
    $("rr-decision").querySelector('option[value="approved"]').disabled = !state.latest || state.latest.readiness_status === "blocked" || state.latest.run_freshness !== "current";
  }

  async function evaluate() {
    if (!state.version) throw new Error("No current manuscript version is registered for this book.");
    $("rr-evaluate").disabled = true; $("rr-status").textContent = "Evaluating twenty live controls…";
    try { await request("rpc/author_evaluate_release_gate", { method: "POST", body: JSON.stringify({ p_manuscript_version_id: state.version.version_id, p_notes: "Evaluation from author Release Readiness workspace" }) }); await refresh(); }
    finally { $("rr-evaluate").disabled = false; }
  }

  async function recordDecision(event) {
    event.preventDefault();
    if (!state.latest) throw new Error("Evaluate the current manuscript before recording a decision.");
    const decision = $("rr-decision").value;
    const rationale = $("rr-rationale").value.trim();
    if (!rationale) throw new Error("A decision rationale is required.");
    const acknowledged = [...document.querySelectorAll('input[name="rr-warning"]:checked')].map((input) => input.value);
    $("rr-record-decision").disabled = true;
    try {
      await request("rpc/author_record_release_gate_decision", { method: "POST", body: JSON.stringify({ p_run_id: state.latest.run_id, p_decision: decision, p_acknowledged_warning_keys: acknowledged, p_rationale: rationale }) });
      $("rr-decision-status").textContent = "Decision recorded. No canon object or publication state was changed."; $("rr-rationale").value = ""; await refresh();
    } finally { $("rr-record-decision").disabled = false; }
  }

  $("rr-book").addEventListener("change", () => refresh().catch((error) => $("rr-status").textContent = error.message));
  $("rr-filter").addEventListener("change", renderChecks);
  $("rr-evaluate").addEventListener("click", () => evaluate().catch((error) => $("rr-status").textContent = error.message));
  $("rr-decision-form").addEventListener("submit", (event) => recordDecision(event).catch((error) => $("rr-decision-status").textContent = error.message));
  window.addEventListener("aurefold:loremaster-ready", () => refresh().catch((error) => $("rr-status").textContent = error.message));
  if (token()) refresh().catch((error) => $("rr-status").textContent = error.message);
}());

