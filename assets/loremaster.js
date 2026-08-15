/* AUREFOLD — author-only Loremaster dashboard.
 * Uses a normal Supabase Auth access token. No service-role secret is shipped
 * to the browser; RLS requires app_metadata.aurefold_role=author|admin. */
(function () {
  "use strict";

  const cfg = window.AUREFOLD_COMMUNITY || {};
  const TOKEN_KEY = "aurefold_loremaster_access_token";
  const login = document.getElementById("lm-login");
  const dashboard = document.getElementById("lm-dashboard");
  const form = document.getElementById("lm-login-form");
  const status = document.getElementById("lm-login-status");
  const signout = document.getElementById("lm-signout");
  const book = document.getElementById("lm-book");

  function token() { return sessionStorage.getItem(TOKEN_KEY) || ""; }

  async function rest(path, query = "") {
    const accessToken = token();
    if (!accessToken) throw new Error("Not signed in");
    const response = await fetch(`${cfg.supabaseUrl}/rest/v1/${path}${query ? `?${query}` : ""}`, {
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: `Bearer ${accessToken}`,
        Accept: "application/json"
      }
    });
    if (!response.ok) {
      const detail = await response.text();
      const err = new Error(`Canon API ${response.status}`);
      err.detail = detail;
      throw err;
    }
    return response.json();
  }

  function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }
  function td(value) { const el = document.createElement("td"); el.textContent = value == null ? "" : String(value); return el; }

  async function signIn(email, password) {
    const response = await fetch(`${cfg.supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: "POST",
      headers: { apikey: cfg.supabaseKey, "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    const body = await response.json().catch(() => ({}));
    if (!response.ok || !body.access_token) throw new Error(body.error_description || body.msg || "Sign-in failed");
    sessionStorage.setItem(TOKEN_KEY, body.access_token);
  }

  async function renderMetrics() {
    const rows = await rest("author_canon_overview", "select=metric,value&order=metric.asc");
    const root = document.getElementById("lm-metrics"); clear(root);
    for (const row of rows) {
      const card = document.createElement("div"); card.className = "lm-card";
      const n = document.createElement("strong"); n.textContent = row.value;
      const label = document.createElement("span"); label.textContent = row.metric.replaceAll("_", " ");
      card.append(n, label); root.appendChild(card);
    }
  }

  async function renderScenes() {
    const rows = await rest("author_scene_control", `select=book_code,chapter_number,title,pov_name,summary,state&book_code=eq.${encodeURIComponent(book.value)}&order=chapter_number.asc,scene_order.asc`);
    const root = document.getElementById("lm-scenes"); clear(root);
    for (const row of rows) {
      const tr = document.createElement("tr");
      tr.append(td(row.chapter_number), td(row.pov_name || "—"), td(row.title || "—"), td(row.summary || ""));
      root.appendChild(tr);
    }
  }

  async function renderDebts() {
    const rows = await rest("author_source_debts", "select=source_name,description,impact,status&status=eq.open&order=source_name.asc");
    const root = document.getElementById("lm-debts"); clear(root);
    for (const row of rows) {
      const tr = document.createElement("tr"); tr.append(td(row.source_name), td(row.description), td(row.impact)); root.appendChild(tr);
    }
    if (!rows.length) {
      const tr = document.createElement("tr"); const cell = td("No open source debt."); cell.colSpan = 3; tr.appendChild(cell); root.appendChild(tr);
    }
  }

  async function renderPhrases() {
    const [phrases, houses] = await Promise.all([
      rest("lore_phrases", "select=house_entity_id,phrase_kind,phrase_text,state,visibility&state=eq.proposal&order=phrase_kind.asc"),
      rest("lore_entities", "select=id,name&entity_type=eq.house")
    ]);
    const names = new Map(houses.map((h) => [h.id, h.name]));
    const root = document.getElementById("lm-phrases"); clear(root);
    for (const row of phrases) {
      const tr = document.createElement("tr");
      tr.append(td(names.get(row.house_entity_id) || "House"), td(row.phrase_kind), td(row.phrase_text));
      root.appendChild(tr);
    }
  }

  async function loadDashboard() {
    status.textContent = "Checking author access…";
    try {
      await Promise.all([renderMetrics(), renderDebts(), renderPhrases()]);
      await renderScenes();
      login.hidden = true; dashboard.hidden = false; signout.hidden = false; status.textContent = "";
      window.dispatchEvent(new Event("aurefold:loremaster-ready"));
    } catch (error) {
      sessionStorage.removeItem(TOKEN_KEY);
      dashboard.hidden = true; signout.hidden = true; login.hidden = false;
      status.textContent = error.message.includes("401") || error.message.includes("403")
        ? "Signed in, but this account is not authorized as an Aurefold author/admin."
        : `Could not load Loremaster: ${error.message}`;
    }
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault(); status.textContent = "Signing in…";
    try {
      await signIn(document.getElementById("lm-email").value, document.getElementById("lm-password").value);
      document.getElementById("lm-password").value = "";
      await loadDashboard();
    } catch (error) { status.textContent = error.message; }
  });

  signout.addEventListener("click", () => {
    sessionStorage.removeItem(TOKEN_KEY); dashboard.hidden = true; signout.hidden = true; login.hidden = false; status.textContent = "Signed out.";
  });

  book.addEventListener("change", () => renderScenes().catch((error) => { status.textContent = error.message; }));
  if (token()) loadDashboard();
})();
