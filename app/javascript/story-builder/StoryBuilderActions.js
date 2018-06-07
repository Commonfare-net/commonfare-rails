import React, { Component } from 'react';
import { oneOf, number, bool, array } from 'prop-types';
import { FormattedMessage, injectIntl, intlShape } from 'react-intl';
import { publishStory } from './api';

import PublishAnonymouslySwitch from './PublishAnonymouslySwitch';
import PublishAsGroupSelect from './PublishAsGroupSelect';

import './StoryBuilderActions.css';

class StoryBuilderActions extends Component {
  static propTypes = {
    intl: intlShape.isRequired,
    locale: oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyLocale: oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyId: number.isRequired,
    anonymous: bool.isRequired,
    availableGroups: array.isRequired,
    groupId: number
  }

  constructor(props) {
    super(props);
    this.state = {
      publishing: false,
      anonymous: props.anonymous,
      groupId: props.groupId
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if (!prevState.publishing && this.state.publishing) {
      const { locale, storyLocale, storyId } = this.props;
      const { anonymous, groupId } = this.state;

      publishStory(storyId, locale, { anonymous, group_id: groupId })
      .then(response => Turbolinks.visit(`/${locale}/stories/${storyId}?story_locale=${storyLocale}`))
      .catch(() => this.setState({ publishing: false }))
    }
  }

  render() {
    const { intl, locale, storyLocale, storyId, availableGroups } = this.props;
    const { publishing, anonymous, groupId } = this.state;

    return (
      <div>
        <div className="row justify-content-center my-4">
          <div className="col-6 publish-anonymously-wrapper">
            <PublishAnonymouslySwitch
              onChange={(state) => this.setState({
                anonymous: state,
                groupId: state ? undefined : groupId
              })}
              value={anonymous}
              disabled={publishing}
            />
          </div>
          <div className="col-6 publish-as-group-wrapper">
            <PublishAsGroupSelect
              onChange={(groupId) => this.setState({ groupId })}
              groups={availableGroups}
              groupId={groupId}
              disabled={publishing || anonymous || availableGroups.length === 0}
            />
          </div>
        </div>
        <div className="row justify-content-center pt-4">
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
