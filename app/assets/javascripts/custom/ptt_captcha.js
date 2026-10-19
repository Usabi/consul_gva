(function() {
  "use strict";

  // The PTT front script only renders the widget on DOMContentLoaded, which
  // Turbolinks does not fire when navigating, so the div stays empty until the
  // page is reloaded. On a full load the script has already filled the div, so
  // this only acts on Turbolinks visits. The script is loaded asynchronously
  // there, hence the retries until its entry point exists.
  var renderOnTurbolinksVisit = function(widget) {
    var attempts = 0;

    var tryRender = function() {
      if (widget.innerHTML.trim() !== "") {
        return;
      }

      if (typeof window.captxaExtern === "function") {
        window.captxaExtern();
      } else if (attempts < 50) {
        attempts += 1;
        setTimeout(tryRender, 100);
      }
    };

    setTimeout(tryRender, 0);
  };

  App.PttCaptcha = {
    initialize: function() {
      var widget = document.querySelector("[data-captcha-id]");
      var hiddenField = document.getElementById("ptt_valor_captcha");
      if (!widget || !hiddenField) {
        return;
      }

      var form = widget.closest("form");
      if (!form) {
        return;
      }

      var captchaId = widget.dataset.captchaId;

      renderOnTurbolinksVisit(widget);

      var submitted = false;

      form.addEventListener("submit", function(e) {
        e.preventDefault();
        // PTT only allows validating each captcha id once, so a double click
        // or double Enter would burn the id and the second request gets a 422.
        if (submitted) {
          return;
        }
        submitted = true;
        hiddenField.value = getCaptchaValue(captchaId);
        form.submit();
      });
    }
  };
}).call(this);
