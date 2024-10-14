(function() {
  "use strict";

  App.HTMLEditor.initialize = function() {
    debugger
    $("textarea.html-area").each(function() {
      if ($(this).hasClass("admin")) {
        debugger
        CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "admin", height: 500 });
      } else if($(this).hasClass("custom")) {
        debugger
        CKEDITOR.replace(this.name, { language: $("html").attr("lang"), toolbar: "page", height: 500 });
      } else  {
        CKEDITOR.replace(this.name, { language: $("html").attr("lang") });
      }
    });
  }

}).call(this);
