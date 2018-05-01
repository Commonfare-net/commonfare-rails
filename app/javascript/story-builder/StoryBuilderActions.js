import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage, injectIntl, intlShape } from 'react-intl';
import { publishStory } from './api';

import Switch from 'react-bootstrap-switch';
import 'react-bootstrap-switch/dist/css/bootstrap3/react-bootstrap-switch.css';
import './StoryBuilderActions.css';

class StoryBuilderActions extends Component {
  static propTypes = {
    intl: intlShape.isRequired,
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyLocale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyId: PropTypes.number.isRequired,
    anonymous: PropTypes.bool.isRequired
  }

  constructor(props) {
    super(props);
    this.state = {
      publishing: false,
      anonymous: props.anonymous
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if (!prevState.publishing && this.state.publishing) {
      const { locale, storyLocale, storyId } = this.props;
      const { anonymous } = this.state;

      publishStory(storyId, locale, { anonymous })
      .then(response => Turbolinks.visit(`/${locale}/stories/${storyId}?story_locale=${storyLocale}`))
      .catch(() => this.setState({ publishing: false }))
    }
  }

  render() {
    const { intl, locale, storyLocale, storyId } = this.props;
    const { publishing, anonymous } = this.state;

    return (
      <div>
        <div className="row justify-content-center">
          <div className="col-12 publish-anonymously-wrapper">
            <label htmlFor="anonymous">
              <FormattedMessage
                id="publish_anonymously"
                defaultMessage="Publish anonymously?"
              />
            </label>
            <Switch
              onChange={(el, state) => this.setState({ anonymous: state })}
              value={anonymous}
              name="anonymous"
              onText={intl.formatMessage({ id: 'yes' })}
              offText={intl.formatMessage({ id: 'no' })}
              disabled={publishing}
             />
          </div>
        </div>
        <div className="row justify-content-center">
          <div className="col-6">
            <a
              href={`/${locale}/stories/${storyId}/preview?story_locale=${storyLocale}`}
              className={`btn btn-block btn-outline-cf ${publishing && 'disabled'}`}
              role="button"
              aria-disabled={publishing}>
              <FormattedMessage
                id="preview"
                defaultMessage="Preview"
              />
            </a>
          </div>
          <div className="col-6">
            <button
              style={{ cursor: 'pointer' }}
              onClick={() => this.setState({ publishing: true })}
              className="btn btn-block btn-cf"
              disabled={publishing}>
              <FormattedMessage
                id="publish"
                defaultMessage="Publish"
              />
            </button>
          </div>
        </div>
      </div>
    )
  }
}

export default injectIntl(StoryBuilderActions)
