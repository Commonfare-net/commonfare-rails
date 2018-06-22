import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

const locales = ['en', 'it', 'nl', 'hr']

export default class LanguageChoice extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(locales).isRequired,
    storyLocale: PropTypes.oneOf(locales).isRequired,
    translatedLocales: PropTypes.arrayOf(PropTypes.oneOf(locales)).isRequired,
    storyId: PropTypes.number
  }

  render() {
    const { locale, storyLocale, translatedLocales, storyId } = this.props;

    return (
      <div>
        <FormattedMessage
          id="writing_in"
          defaultMessage="Language of your story"
        />
        <div className="dropdown d-inline">
          <button href="#" id="langSelectDropdownMenuButton" type="button" className="btn btn-link btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            <FormattedMessage id={`locale.${storyLocale}`} />
          </button>
          <div className="dropdown-menu" aria-labelledby="langSelectDropdownMenuButton">
            {locales.filter(loc => loc !== storyLocale).map(loc => (
              <a
                key={loc}
                href={`/${locale}/stories/${storyId ? `${storyId}/edit` : 'new'}?story_locale=${loc}&story_builder=true`}
                className="dropdown-item">
                <FormattedMessage id={`locale.${loc}`} />
              </a>
            ))}
          </div>
        </div>
        {/* {translatedLocales.indexOf(storyLocale) < 0 &&
          <div className="badge badge-warning">
            <FormattedMessage
              id="no_translation_in"
              defaultMessage="You haven't yet saved this Story in {locale}"
              values={{
                locale: <FormattedMessage id={`locale.${storyLocale}`} />
              }}
            />
          </div>
        } */}
      </div>
    )
  }
}
