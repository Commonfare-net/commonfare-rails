import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { publishStory } from './api';

export default class StoryBuilderActions extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyLocale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyId: PropTypes.number.isRequired
  }

  constructor(props) {
    super(props);
    this.state = {
      publishing: false
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if (!prevState.publishing && this.state.publishing) {
      const { locale, storyLocale, storyId } = this.props;

      publishStory(storyId)
      .then(response => Turbolinks.visit(`/${locale}/stories/${storyId}?story_locale=${storyLocale}`))
      .catch(() => this.setState({ publishing: false }))
    }
  }

  render() {
    const { locale, storyLocale, storyId } = this.props;
    const { publishing } = this.state;

    return (
      <div className="row justify-content-center">
        <div className="col-md-6">
          <a
            href={`/${locale}/stories/${storyId}/preview?story_locale=${storyLocale}`}
            className={`btn btn-block btn-outline-cf ${publishing && 'disabled'}`}
            role="button"
            aria-disabled={publishing}>
            Preview
          </a>
        </div>
        <div className="col-md-6">
          <button
            style={{ cursor: 'pointer' }}
            onClick={() => this.setState({ publishing: true })}
            className="btn btn-block btn-cf"
            disabled={publishing}>
            Publish
          </button>
        </div>
      </div>
    )
  }
}
