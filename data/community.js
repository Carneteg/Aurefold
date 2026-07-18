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

  /* Sponsor & follow links. Paste a URL to switch a button on;
     leave "" and the button stays hidden. For Swish, use a swish.me
     link or leave "" and add a QR image later. */
  support: {
    patreon: "https://www.patreon.com/AUREFOLD",
    kofi: "",
    buymeacoffee: "",
    swish: "",
    paypal: "",
    newsletter: "",
    instagram: "",
    tiktok: "",
    youtube: "",
    goodreads: ""
  }
};
