function autocomplete(locale) {
  $input = $("[data-behavior='autocomplete']")

  var options = {
    getValue: "name",
    url: function(phrase) {
      return "/" + locale + "/autocomplete?q=" + phrase;
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
    requestDelay: 200,
    list: {
      onChooseEvent: function() {
        var url = $input.getSelectedItemData().url;
        $input.val("");
        Turbolinks.visit(url);
      }
    },
    cssClasses: 'cf-search-form'
  }

  $input.easyAutocomplete(options);
}
