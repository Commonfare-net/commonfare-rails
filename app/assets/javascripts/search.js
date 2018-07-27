function optionsFor(input, locale, localizedCategoryNames, localizedHelpTextTop, localizedHelpTextBottom) {
  return {
    getValue: "name",
    url: function(phrase) {
      return "/" + locale + "/autocomplete?q=" + phrase;
    },
    categories: [
      {
        listLocation: 'groups',
        header: "<strong>" + localizedCategoryNames.groups + "</strong>"
      },
      {
        listLocation: 'commoners',
        header: "<strong>" + localizedCategoryNames.commoners + "</strong>"
      },
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
      },
      onShowListEvent: function() {
        $(".eac-menu-help").remove();
        $(".easy-autocomplete-container").children().prepend('\
          <div class="eac-menu-help">\
            <small>\
              ' + localizedHelpTextTop + '\
            </small>\
          </div>'
        );
        $(".easy-autocomplete-container").children().append('\
          <div class="eac-menu-help">\
            <small>\
              ' + localizedHelpTextBottom + '\
            </small>\
          </div>'
        );
      }
    },
    cssClasses: 'cf-search-form'
  }
}

function autocomplete(locale, localizedCategoryNames, localizedHelpTextTop, localizedHelpTextBottom) {
  $("[data-behavior='autocomplete']").each(function(index) {
    $(this).easyAutocomplete(optionsFor(
      this,
      locale,
      localizedCategoryNames,
      localizedHelpTextTop,
      localizedHelpTextBottom
    ));
  })
}
