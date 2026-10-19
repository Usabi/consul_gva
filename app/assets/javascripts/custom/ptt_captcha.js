(function() {
  "use strict";

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
