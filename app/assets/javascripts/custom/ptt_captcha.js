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

      form.addEventListener("submit", function(e) {
        e.preventDefault();
        hiddenField.value = getCaptchaValue(captchaId);
        form.submit();
      });
    }
  };
}).call(this);
