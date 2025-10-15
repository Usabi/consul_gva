(function() {
  "use strict";

  App.SearchInSelect = {
    initialize: function() {
      var $select = $("#proposal-select");
      var $input = $("#search-input");
      var $optionsContainer = $("#options-container");

      var allOptions = $select.find("option").map(function() {
        return { value: this.value, text: this.text };
      }).get();

      var selectedValue = $select.val();
      if (selectedValue) {
        var selectedOption = allOptions.find(function(opt) {
          return opt.value === selectedValue;
        });
        if (selectedOption) {
          $input.val(selectedOption.text);
        }
      }

      function renderOptions(options) {
        $optionsContainer.empty();
        options.forEach(function(opt) {
          var $option = $("<div>").addClass("option-item").text(opt.text).attr("data-value", opt.value);
          $optionsContainer.append($option);
        });
      }

      $optionsContainer.on("click", ".option-item", function() {
        var val = $(this).attr("data-value");
        $select.val(val).trigger("change");
        $input.val($(this).text());
        $optionsContainer.empty();
      });

      $input.on("input", function() {
        var q = $input.val().toLowerCase().trim();
        var filtered = allOptions.filter(function(opt) {
          return opt.text.toLowerCase().includes(q) || opt.value.toLowerCase().includes(q);
        });
        renderOptions(filtered);
      });

      renderOptions(allOptions);
    }
  };
}).call(this);
