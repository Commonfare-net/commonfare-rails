function optionsFor(input, locale, localizedCategoryNames) {
  return {
    getValue: "name",
    url: function(phrase) {
      return "/" + locale + "/autocomplete?q=" + phrase;
    },
    categories: [
      {
        listLocation: 'tags',
        header: "<strong>" + localizedCategoryNames.tags + "</strong>"
      },
      {
        listLocation: 'stories',
        header: "<strong>" + localizedCategoryNames.stories + "</strong>"
      },
      {
        listLocation: 'listings',
        header: "<strong>" + localizedCategoryNames.listings + "</strong>"
      },
    ],
    requestDelay: 200,
    list: {
      onChooseEvent: function() {
        var url = $(input).getSelectedItemData().url;
        $(input).val("");
        Turbolinks.visit(url);
      }
    },
    cssClasses: 'cf-search-form'
  }
}

function autocomplete(locale, localizedCategoryNames) {
  $("[data-behavior='autocomplete']").each(function(index) {
    $(this).easyAutocomplete(optionsFor(this, locale, localizedCategoryNames));
  })
}
