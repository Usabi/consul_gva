// jquery-ujs aborts remote forms that contain a non-blank file input and falls
// back to a regular submit. Comment forms with an attached document are sent
// through AJAX here so the comment list is updated without reloading the page.
// The handler is delegated on document, so it is bound only once.
(function() {
  "use strict";

  $(document).on("ajax:aborted:file", ".comment-form form", function() {
    var form = $(this);

    $.ajax({
      url: form.attr("action"),
      type: "POST",
      data: new FormData(this),
      processData: false,
      contentType: false,
      dataType: "script"
    }).always(function() {
      form.find(":input").prop("disabled", false);
    });

    return false;
  });
}).call(this);

// Friendly file picker: shows the selected file name and lets users clear it.
(function() {
  "use strict";

  var updatePicker = function(input) {
    var picker = $(input).closest(".comment-attachment-picker");
    var name = picker.find(".comment-attachment-name");
    var file = input.files && input.files[0];

    name.text(file ? file.name : name.data("empty"));
    picker.find(".comment-attachment-clear").toggleClass("hide", !file);
  };

  $(document).on("change", ".comment-attachment-picker input[type=file]", function() {
    updatePicker(this);
  });

  $(document).on("click", ".comment-attachment-clear", function() {
    var input = $(this).closest(".comment-attachment-picker").find("input[type=file]");

    input.val("");
    updatePicker(input[0]);
  });
}).call(this);

// The new annotation form expects a JSON response and notifies the annotator
// through the ajax:complete event of the form, so it is submitted separately.
(function() {
  "use strict";

  $(document).on("ajax:aborted:file", "#new_legislation_annotation", function() {
    var form = $(this);

    $.ajax({
      url: form.attr("action"),
      type: "POST",
      data: new FormData(this),
      processData: false,
      contentType: false,
      dataType: "json"
    }).always(function(_data, _status, xhr) {
      var request = xhr && xhr.status !== undefined ? xhr : _data;

      form.find(":input").prop("disabled", false);
      form.trigger("ajax:complete", [request]);
    });

    return false;
  });
}).call(this);
