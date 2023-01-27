(function($){
  $.fn.languageSwitcher = function(lang){
    $.each(this, function(index, value) {
      if (lang == $(value).attr("lang")) {
        $(value).css("display", "inline");
      } else {
        $(value).css("display", "none");
      }
    });      
    return this;
  }
}(jQuery));
