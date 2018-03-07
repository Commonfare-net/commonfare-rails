import React, { Component } from 'react';
import PropTypes from 'prop-types';
import StoryBuilder from 'storybuilder-react';

import './StoryBuilderWrapper.css';

export default class extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl'])
  }

  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  componentDidCatch(error, info) {
    // Display fallback UI
    this.setState({ hasError: true });
    // You can also log the error to an error reporting service
    console.log(error, info);
  }

  saveStory = (story) => console.log(story);

  render() {
    if (this.state.hasError) {
      return (
        <div className="story-builder story-builder--has-error">
          The Story Builder is experiencing some technical issues. Please refresh the page.
        </div>
      )
    }

    return (
      <StoryBuilder
        onSave={this.saveStory}
        {...this.props} />
    )
  }
}
