(function() {
  "use strict";
  App.BudgetEditAssociations = {
    initialize: function() {
      $(".js-legislation-process-users-list [type='checkbox']").on({
        change: function() {
          var admin_count, valuator_count;

          admin_count = $("#administrators_list :checked").length;
          valuator_count = $("#valuators_list :checked").length;

          App.I18n.set_pluralize($(".js-legislation-process-show-administrators-list"), admin_count);
          App.I18n.set_pluralize($(".js-legislation-process-show-valuators-list"), valuator_count);
        }
      });
      $(".js-legislation-process-show-users-list").on({
        click: function(e) {
          var div_id;

          e.preventDefault();
          div_id = $(this).data().toggle;
          $(".js-legislation-process-users-list").each(function() {
            if (this.id !== div_id && !$(this).hasClass("is-hidden")) {
              $(this).addClass("is-hidden");
            }
          });
        }
      });
    }
  };
}).call(this);
