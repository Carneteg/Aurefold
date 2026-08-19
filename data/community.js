/* AUREFOLD — community configuration.
   Everything the Vote and Support pages need lives in this one file. */

window.AUREFOLD_COMMUNITY = {
  /* The voting backend (Supabase project "aurefold-site", eu-north-1).
     This key is a PUBLISHABLE key — safe to ship in a public site; the
     database's row-level security decides what it may do (read polls,
     read aggregated results, cast one vote per poll — nothing else). */
  supabaseUrl: "https://akboesleczddqdikjzbw.supabase.co",
  // Legacy anon key (a JWT with role=anon baked in). Safe to publish — the
  // database's row-level security decides what it may do. A JWT is used rather
  // than the newer sb_publishable_ key so PostgREST can decode the role
  // directly from the Authorization bearer on every request.
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrYm9lc2xlY3pkZHFkaWtqemJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4NjM4MzUsImV4cCI6MjA5OTQzOTgzNX0.AG1LPOUP-O9icpNOFQZ1w8tNFlW4MeTPWvKfDbrf90w",

  /* Reader accounts (The Banner). Sign-in is by magic email link and works out
     of the box. Discord sign-in shows as a second button once the provider is
     enabled in Supabase (Authentication → Providers → Discord) — then set
     discord: true here. */
  auth: {
    discord: false
  },

  /* The Moot (reader voting) — PRESENTATION only. These settings never touch
     the database, its row-level security, or the one-vote-per-reader rule.

     MOOT_REVEAL_THRESHOLDS: how many votes a single poll needs before its real
     tallies are shown. Below it, options appear as a ranked standing with
     subtle bars and no raw numbers ("be among the first to weigh in").
     `default` applies to every poll; add a "<poll-id>": N entry to give one
     poll its own threshold. Set default to 0 to always show counts — the
     pre-threshold behaviour. Raise it while the audience is small so a 1–0
     lead never looks like a verdict. The old single-value
     MOOT_REVEAL_THRESHOLD is still honoured as a fallback if this map is
     removed. */
  MOOT_REVEAL_THRESHOLDS: {
    "default": 10,
    "next-reveal": 5
  },
  MOOT_REVEAL_THRESHOLD: 10,

  /* "What the Moot decided last time" — a short retrospective panel above the
     live polls, showing that past votes actually changed the site. Leave
     title "" and the whole panel stays hidden. Edit title/note after each
     round; nothing here is sent anywhere. */
  moot: {
    lastOutcome: {
      title: "",
      note: ""
    }
  },

  /* Momentum / freshness signals for the homepage. Inert until configured:
     every field starts empty, and the homepage renders ONLY the fields you
     set — an empty or zero value is hidden entirely (never shown as "0").
     Fill these in by hand from REAL figures; do not invent numbers.
       members         — your Patreon member count (from the Patreon dashboard)
       votesCast       — total votes cast in the Moot (sum the poll_tallies, or
                         the running total you keep); leave null to hide
       latestMilestone — one short, true milestone phrase, e.g.
                         "Reader testing underway" (leave "" to hide) */
  momentum: {
    members: null,
    votesCast: null,
    latestMilestone: "Book One complete — Book Two in development"
  },

  /* The homepage "Latest from the Journal" teaser. Update these three when you
     post a new entry at the top of journal.html. `url` can point at that
     entry's anchor (each entry now has an id). Leave latestTitle "" to hide
     the teaser entirely. */
  journal: {
    latestTitle: "Book Two has a name: The Road Still Open",
    latestDate: "15 August 2026",
    url: "journal.html#book-two-has-a-name"
  },

  /* Book One availability + the free download.
       amazonUrl        — shows the "Get it free on Amazon" button (already set).
       downloadFile     — path to a file you host for direct download, e.g.
                          "assets/aurefold-the-bell-of-silence.pdf". Leave "" and
                          the direct-download button stays hidden until you add one.
       downloadCountThreshold — the honest click-counter (clicks on this page,
                          not Amazon's totals) stays hidden until it passes this.
     Ratings & reviews are stored in Supabase and MODERATED: a submitted review
     only appears after you set approved = true on its row in the Supabase
     dashboard (table: reviews). Nothing shows publicly until you approve it. */
  book: {
    amazonUrl: "https://www.amazon.com/dp/B0H9JH9KGH",
    downloadFile: "assets/aurefold-the-bell-of-silence.pdf",
    downloadCountThreshold: 20
  },

  /* Reading-list signup (MailerLite). Fill BOTH ids to switch the signup
     form on; leave "" and the form shows a quiet "opening soon" note and
     never posts anywhere. Find these in your MailerLite embedded-form code:
       account = the number in .../jsonp/<ACCOUNT>/forms/<FORM>/subscribe
       form    = the <FORM> number in that same URL
     Nothing is sent, stored, or automated until these are set and the site
     is deployed. */
  mailerlite: {
    account: "2567507",
    form: "yjubzQ"
  },

  /* Privacy-friendly analytics (Plausible — no cookies, no consent banner).
     Sign up at plausible.io, add the site "aurefold.com", then paste that
     exact domain here. Empty = analytics stays OFF and no external script
     loads. When set, pageviews plus a few key events (Patreon clicks, support
     and read clicks) are tracked — no personal data, no cookies. */
  analytics: {
    plausibleDomain: ""
  },

  /* Sponsor & follow links. Paste a URL to switch a button on;
     leave "" and the button stays hidden. For Swish, use a swish.me
     link or leave "" and add a QR image later. */
  support: {
    patreon: "https://www.patreon.com/AUREFOLD",
    discord: "https://discord.gg/TGQgmpU8s",
    tiktok: "https://www.tiktok.com/@aurefold",
    instagram: "",
    youtube: "",
    goodreads: "",
    kofi: "",
    buymeacoffee: "",
    swish: "",
    paypal: "",
    newsletter: ""
  }
};

/* Per-poll reveal threshold — the single source of truth for how many votes
   a poll needs before real tallies show. Consumed by BOTH assets/vote.js
   (the live Moot, renderPoll()) and assets/site.js (the homepage "Latest
   from the Moot" teaser). They share no module, but both read
   window.AUREFOLD_COMMUNITY after this file loads, so one function here
   keeps the two places from ever disagreeing about the same poll. */
window.AUREFOLD_COMMUNITY.resolveMootThreshold = function (pollId) {
  var map = window.AUREFOLD_COMMUNITY.MOOT_REVEAL_THRESHOLDS || {};
  var specific = Number(map[pollId]);
  if (specific > 0) return specific;
  var fallback = Number(map["default"] != null ? map["default"] : window.AUREFOLD_COMMUNITY.MOOT_REVEAL_THRESHOLD);
  return (fallback > 0) ? fallback : 0;
};

/* Canon hydration bootstrap.
   The English Houses page predates the canon database, so keep its checked-in
   HTML as the offline fallback and load the public-safe Supabase projection on
   top. Localized House pages stay static until translation-aware projections
   exist. */
(function loadCanonHouseHydration() {
  if (document.documentElement.lang !== "en" || !document.querySelector(".house-grid")) return;

  const canon = document.createElement("script");
  canon.src = "/assets/canon-data.js?v=202608151140";
  canon.onload = function () {
    const houses = document.createElement("script");
    houses.src = "/assets/houses.js?v=202608151140";
    document.body.appendChild(houses);
  };
  document.body.appendChild(canon);
})();

/* Swedish Book One publication hook.
   The localized Book page predates the completed Swedish master and used to
   point at the English PDF/EPUB. Keep the checked-in localized page intact,
   but surface the Swedish full-book reader and clearly separate the English
   edition until dedicated Swedish PDF/EPUB files are produced. */
(function publishSwedishBookOne() {
  function wire() {
    if (document.documentElement.lang !== "sv" || !/\/sv\/book\.html$/.test(location.pathname)) return;
    const get = document.querySelector("#get");
    if (!get || document.getElementById("book-sv-reader")) return;

    document.title = "Tystnadens klocka — Läs Bok Ett gratis | Aurefold";
    const title = document.querySelector(".book-title");
    if (title) title.textContent = "TYSTNADENS KLOCKA";

    const intro = get.querySelector("p");
    if (intro) intro.innerHTML = "<em>Tystnadens klocka</em> finns nu som en <strong>fullständig svensk läsversion</strong>. Läs hela romanen direkt på Aurefold, eller ladda ner den svenska textfilen. Den engelska originalutgåvan finns kvar separat.";

    const row = get.querySelector(".cta-row");
    if (row) {
      row.querySelectorAll("a").forEach(function (a) { a.hidden = true; });

      const read = document.createElement("a");
      read.className = "btn btn-primary book-dl";
      read.id = "book-sv-reader";
      read.href = "/sv/tystnadens-klocka.html";
      read.textContent = "Läs hela boken på svenska";

      const download = document.createElement("a");
      download.className = "btn btn-ghost book-dl";
      download.id = "book-sv-download";
      download.href = "/assets/books/Aurefold_Tystnadens_Klocka_Swedish_Master_v1.3.md";
      download.setAttribute("download", "");
      download.textContent = "Ladda ner svensk text";

      const english = document.createElement("a");
      english.className = "btn btn-ghost book-dl";
      english.href = "/book.html#get";
      english.textContent = "Engelsk utgåva";

      row.append(read, download, english);
    }

    const coming = document.querySelector(".book-coming");
    if (coming) coming.textContent = "BOK ETT — UTE NU · HELA BOKEN PÅ SVENSKA";
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", wire);
  else wire();
})();

/* Community participation bootstrap.
   This layer records only explicit community milestones (completed quiz,
   Ledger votes, sworn-reader state, Patreon intent) and renders the local
   Ledger record. It does not create passive page-view tracking. */
(function loadCommunityParticipation() {
  function load() {
    if (document.querySelector('script[data-aurefold-participation]')) return;
    const script = document.createElement("script");
    script.src = "/assets/community-participation.js?v=202608190540";
    script.dataset.aurefoldParticipation = "1";
    document.body.appendChild(script);
  }
  if (document.body) load();
  else document.addEventListener("DOMContentLoaded", load, { once: true });
})();
