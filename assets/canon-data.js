/* AUREFOLD — public canon data client.
 * Reads only public-safe Supabase views using the existing publishable/anon key.
 * Internal canon tables remain protected by RLS and are never queried here. */
(function () {
  "use strict";

  async function fetchView(view, query) {
    const cfg = window.AUREFOLD_COMMUNITY || {};
    if (!cfg.supabaseUrl || !cfg.supabaseKey || typeof fetch !== "function") {
      throw new Error("Aurefold canon API is not configured");
    }

    const suffix = query ? `?${query}` : "";
    const response = await fetch(`${cfg.supabaseUrl}/rest/v1/${view}${suffix}`, {
      headers: {
        apikey: cfg.supabaseKey,
        Authorization: `Bearer ${cfg.supabaseKey}`,
        Accept: "application/json",
      },
    });

    if (!response.ok) throw new Error(`Aurefold canon API ${response.status}`);
    return response.json();
  }

  window.AUREFOLD_CANON = Object.freeze({ fetchView });
})();
