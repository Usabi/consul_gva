(function() {
  "use strict";

  App.HTMLEditor.initialize = function() {
    $("textarea.html-area").each(function() {
      if ($(this).hasClass("admin")) {
        CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "admin", height: 500 });
      } else if($(this).hasClass("admincustom")) {
        CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "admincustom", height: 500 });

      } else  {
        CKEDITOR.replace(this.name, { language: $("html").attr("lang") });
      }
    });
  }

}).call(this);
