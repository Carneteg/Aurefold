/* AUREFOLD — support page: render only the channels that have a URL configured. */
(function () {
  "use strict";

  var cfg = (window.AUREFOLD_COMMUNITY || {}).support || {};

  var CHANNELS = {
    sponsor: [
      { key: "patreon", label: "Patreon", detail: "Monthly patronage — follow the writing as it happens." },
      { key: "kofi", label: "Ko-fi", detail: "One-off support, no account needed." },
      { key: "buymeacoffee", label: "Buy Me a Coffee", detail: "One-off support." },
      { key: "swish", label: "Swish", detail: "For readers in Sweden." },
      { key: "paypal", label: "PayPal", detail: "One-off or recurring." }
    ],
    follow: [
      { key: "newsletter", label: "The Dispatch", detail: "The newsletter — chapters, plates and faces as they are released." },
      { key: "instagram", label: "Instagram", detail: "" },
      { key: "tiktok", label: "TikTok", detail: "" },
      { key: "youtube", label: "YouTube", detail: "" },
      { key: "goodreads", label: "Goodreads", detail: "" }
    ]
  };

  ["sponsor", "follow"].forEach(function (group) {
    var mount = document.getElementById(group + "-channels");
    if (!mount) return;
    var live = CHANNELS[group].filter(function (c) { return (cfg[c.key] || "").trim(); });
    if (!live.length) {
      var empty = document.getElementById(group + "-empty");
      if (empty) empty.hidden = false;
      return;
    }
    live.forEach(function (c) {
      var a = document.createElement("a");
      a.className = "support-btn";
      a.href = cfg[c.key];
      a.target = "_blank";
      a.rel = "noopener";
      var l = document.createElement("span");
      l.className = "support-btn-label";
      l.textContent = c.label;
      a.appendChild(l);
      if (c.detail) {
        var d = document.createElement("span");
        d.className = "support-btn-detail";
        d.textContent = c.detail;
        a.appendChild(d);
      }
      mount.appendChild(a);
    });
  });
})();
