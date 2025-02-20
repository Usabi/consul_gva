// Add calls to your custom JavaScript code using this file.
//
// We recommend creating your custom JavaScript code under the
// `app/assets/javascripts/custom/` folder and calling it from here.
//
// See the `docs/en/customization/javascript.md` file for more information.

var initialize_modules = function() {
  "use strict";

  // Add calls to your custom code here; this will be called when
  // loading a page.

  //= require custom/welcome_counter
  //= require custom/select_local

  (function() {
    "use strict";

    App = App || {};

    App.Investments = {
      initializeSelection: function() {
        var selectAllButton = document.getElementById('select-all');
        var checkboxes = document.querySelectorAll('input[type="checkbox"][name="investment_ids[]"]');

        selectAllButton.addEventListener('click', function() {
          checkboxes.forEach(function(checkbox) {
            checkbox.checked = true;
          });
        });
      },
      initialize: function() {
        this.initializeSelection();
      }
    };

    document.addEventListener('DOMContentLoaded', function() {
      App.Investments.initialize();
    });
  }).call(this);

};

var destroy_non_idempotent_modules = function() {
  "use strict";

  // Add calls to your custom code here when your JavaScript code added
  // in `initialize_modules` is not idempotent.
};

$(document).on("turbolinks:load", initialize_modules);
$(document).on("turbolinks:before-cache", destroy_non_idempotent_modules);
