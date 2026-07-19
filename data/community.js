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

  /* The Moot (reader voting) — PRESENTATION only. These settings never touch
     the database, its row-level security, or the one-vote-per-reader rule.

     MOOT_REVEAL_THRESHOLD: how many votes a single poll needs before its real
     tallies are shown. Below it, options appear as a ranked standing with
     subtle bars and no raw numbers ("be among the first to weigh in"). Set to
     0 (or delete this line) to always show counts — the pre-threshold
     behaviour. Raise it while the audience is small so a 1–0 lead never looks
     like a verdict. */
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

  /* Reading-list signup (MailerLite). Fill BOTH ids to switch the signup
     form on; leave "" and the form shows a quiet "opening soon" note and
     never posts anywhere. Find these in your MailerLite embedded-form code:
       account = the number in .../jsonp/<ACCOUNT>/forms/<FORM>/subscribe
       form    = the <FORM> number in that same URL
     Nothing is sent, stored, or automated until these are set and the site
     is deployed. */
  mailerlite: {
    account: "",
    form: ""
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
