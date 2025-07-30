(function() {
  "use strict";

  function updateDocumentPositions(container) {
    if (!container) return;

    Array.from(container.children).forEach((item, index) => {
      const positionField = item.querySelector('.document-position-field');
      if (positionField) {
        positionField.value = index + 1;
      }
    });
  }

  App.Sortable = {
    initialize: function() {
      $(".sortable").each(function() {
        var $container = $(this);
        var containerId = $container.attr('id');

        var isDocumentContainer = (containerId === 'nested-documents' || containerId === 'nested-documents-consult-document');

        $container.sortable({
          animation: 150,
          handle: '.drag-handle',
          update: function() {
            if (isDocumentContainer) {
              updateDocumentPositions($container[0]);
            } else {
              var jsUrl = $container.data("js-url");
              if (jsUrl) {
                var new_order = $(this).sortable("toArray", {
                  attribute: "data-option-id"
                });
                $.ajax({
                  url: jsUrl,
                  data: {
                    ordered_list: new_order
                  },
                  type: "POST"
                });
              }
            }
          }
        });

        if (isDocumentContainer) {
          $container.on('cocoon:after-insert cocoon:after-remove', function() {
            updateDocumentPositions($container[0]);
          });
        }
      });

      updateDocumentPositions(document.getElementById('nested-documents'));
      updateDocumentPositions(document.getElementById('nested-documents-consult-document'));
    }
  };

}).call(this);
