import React, { Component } from 'react';
import PropTypes from 'prop-types';
import StoryBuilder from 'storybuilder-react';

import './StoryBuilderWrapper.css';

export default class extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl'])
  }

  saveStory = (story) => console.log(story);

  render() {
    return (
      <StoryBuilder
        onSave={this.saveStory}
        {...this.props} />
    )
  }
}
