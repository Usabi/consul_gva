// The annotation comments box is positioned next to the highlighted text and
// does not take part in the layout flow, so a tall box (e.g. with the document
// picker open) overflowed the draft container and overlapped the footer.
// The container is stretched so it always encloses the box.
(function() {
  "use strict";

  var fit = function() {
    var container = $(".draft-allegation");
    var box = $("#comments-box .comment-box:visible").first();

    if (container.length === 0) {
      return;
    }

    if (box.length === 0) {
      container.css("min-height", "");
      return;
    }

    var needed = box.offset().top + box.outerHeight(true) - container.offset().top;
    container.css("min-height", Math.ceil(needed));
  };

  var scheduleFit = function() {
    window.setTimeout(fit, 0);
  };

  $(document).on("click", "[data-cancel-comment]", function(event) {
    var wrapper = $(this).closest(".js-comment-form-annotation");

    event.preventDefault();
    wrapper.find("textarea").val("");
    wrapper.find("input[type=file]").val("").trigger("change");
    wrapper.find("details.comment-attachment").removeAttr("open");
    wrapper.hide();
    $("a.publish-comment").show();
    scheduleFit();
  });

  $(document).on("ajaxComplete", scheduleFit);
  $(document).on("toggle click change", ".draft-allegation", scheduleFit);
  $(window).on("resize", scheduleFit);
}).call(this);
