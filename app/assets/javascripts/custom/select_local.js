(function() {
  "use strict";

  document.addEventListener("turbolinks:load", function() {
    $("input[type=radio][name=select-local]").on("change", function() {
      window.location.assign($(this).val());
    });
  });
}).call(this);
