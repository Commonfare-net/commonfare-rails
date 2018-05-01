document.addEventListener("turbolinks:load", function() {
  var tabsWidth = 0;
  $('#pills-tab .nav-item').each(function() {
    var tabWidth = $(this).width();
    tabsWidth += tabWidth;
  })
  $('#pills-tab').css('width', tabsWidth);
});
