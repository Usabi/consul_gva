// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_ES.md#javascript
//
//

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
