(function() {
  "use strict";
  App.TomSelect = {
    initialize: function() {
      this.initializeSelects();
    },

    initializeSelects: function() {
      document.querySelectorAll('select.tom-select:not(.tomselected)').forEach(function(el) {
        var config = {
          plugins: ['dropdown_input'],
          create: false,
          allowEmptyOption: true,
          searchField: ['text', 'value'],
          render: {
            option: function(data, escape) {
              return '<div><span style="color: #8a8a8a; font-size: 0.9em;">ID' + escape(data.value) + '</span> - ' + escape(data.text) + '</div>';
            },
            item: function(data, escape) {
              return '<div>' + escape(data.text) + '</div>';
            }
          },
          onInitialize: function() {
            el.classList.add('tomselected');
          }
        };

        if (el.multiple) {
          config.plugins.remove_button = { 
            title: 'Eliminar',
            className: 'remove-button'
          };
        }

        new TomSelect(el, config);
      });
    },

    destroy: function() {
      document.querySelectorAll('select.tom-select.tomselected').forEach(function(el) {
        if (el.tomselect) {
          el.tomselect.destroy();
        }
        el.classList.remove('tomselected');
      });
    }
  };
})();
