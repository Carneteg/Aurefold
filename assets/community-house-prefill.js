/* Carry a House Test result into The Banner without silently changing a member profile.
   The result is a suggestion only until the reader explicitly presses “Swear it”. */
(function () {
  "use strict";
  var params = new URLSearchParams(location.search);
  var requested = params.get("house") || localStorage.getItem("aurefold-house-quiz-result-v1") || localStorage.getItem("aurefold_house_result");
  if (!requested) return;

  var valid = (window.AUREFOLD_HOUSES || []).some(function (h) { return h.id === requested; });
  if (!valid) return;

  var root = document.getElementById("banner-profile");
  if (!root) return;

  function apply() {
    var select = root.querySelector("select");
    if (!select || select.value) return false;
    var option = Array.prototype.some.call(select.options, function (o) { return o.value === requested; });
    if (!option) return false;
    select.value = requested;

    if (!root.querySelector(".house-test-prefill-note")) {
      var note = document.createElement("p");
      note.className = "auth-gate-status house-test-prefill-note";
      note.textContent = "Your House Test result is waiting here. Nothing changes until you choose “Swear it”.";
      var form = root.querySelector("form");
      if (form) form.insertBefore(note, form.lastElementChild || null);
    }
    return true;
  }

  if (apply()) return;
  var observer = new MutationObserver(function () { if (apply()) observer.disconnect(); });
  observer.observe(root, { childList: true, subtree: true });
  setTimeout(function () { observer.disconnect(); }, 10000);
})();
