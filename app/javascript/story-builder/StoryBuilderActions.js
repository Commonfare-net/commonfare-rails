import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { publishStory } from './api';

import Switch from 'react-bootstrap-switch';
import 'react-bootstrap-switch/dist/css/bootstrap3/react-bootstrap-switch.css';
import './StoryBuilderActions.css';

export default class StoryBuilderActions extends Component {
  static propTypes = {
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

      publishStory(storyId, { anonymous })
      .then(response => Turbolinks.visit(`/${locale}/stories/${storyId}?story_locale=${storyLocale}`))
      .catch(() => this.setState({ publishing: false }))
    }
  }

  render() {
    const { locale, storyLocale, storyId } = this.props;
    const { publishing, anonymous } = this.state;

    return (
      <div>
        <div className="row justify-content-center">
          <div className="col-12 publish-anonymously-wrapper">
            <label htmlFor="anonymous">Publish anonymously?</label>
            <Switch
              onChange={(el, state) => this.setState({ anonymous: state })}
              value={anonymous}
              name="anonymous"
              onText="Yes"
              offText="No"
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
              Preview
            </a>
          </div>
          <div className="col-6">
            <button
              style={{ cursor: 'pointer' }}
              onClick={() => this.setState({ publishing: true })}
              className="btn btn-block btn-cf"
              disabled={publishing}>
              Publish
            </button>
          </div>
        </div>
      </div>
    )
  }
}
