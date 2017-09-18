document.addEventListener('turbolinks:load', function() {
  $input = $("[data-behavior='autocomplete']")

  var options = {
    getValue: "name",
    url: function(phrase) {
      return "/en/search.json?q=" + phrase;
    },
    categories: [
      {
        listLocation: 'tags',
        header: "<strong>Tags</strong>"
      },
      {
        listLocation: 'stories',
        header: "<strong>Stories</strong>"
      },
    ],
    list: {
      onChooseEvent: function() {
        var url = $input.getSelectedItemData().url;
        $input.val("");
        Turbolinks.visit(url);
      }
    }
  }

  $input.easyAutocomplete(options);
});
