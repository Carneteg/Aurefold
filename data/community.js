/* EMBERWOLD — community configuration.
   Everything the Vote and Support pages need lives in this one file. */

window.EMBERWOLD_COMMUNITY = {
  /* The voting backend (Supabase project "emberwold-site", eu-north-1).
     This key is a PUBLISHABLE key — safe to ship in a public site; the
     database's row-level security decides what it may do (read polls,
     read aggregated results, cast one vote per poll — nothing else). */
  supabaseUrl: "https://akboesleczddqdikjzbw.supabase.co",
  supabaseKey: "sb_publishable_mlzeWnEtamNepkL8yW_p0A_nb_TvMea",

  /* Sponsor & follow links. Paste a URL to switch a button on;
     leave "" and the button stays hidden. For Swish, use a swish.me
     link or leave "" and add a QR image later. */
  support: {
    patreon: "",
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
