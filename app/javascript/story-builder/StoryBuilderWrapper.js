import React, { Component } from 'react';
import PropTypes from 'prop-types';
import StoryBuilder from 'storybuilder-react';
import { uploadImage, updateContent } from './api';

import './StoryBuilderWrapper.css';

export default class extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    story: PropTypes.object.isRequired,
    availableTags: PropTypes.array.isRequired
  }

  constructor(props) {
    super(props);
    this.state = {
      storyId: props.story.id,
      hasError: false,
      status: ''
    };
  }

  componentDidCatch(error, info) {
    // Display fallback UI
    this.setState({ hasError: true });
    // You can also log the error to an error reporting service
    console.log(error, info);
  }

  imageUploadHandler = (file, onProgress) => {
    const { story: { commoner_id } } = this.props;
    this.setState({ status: 'Uploading...' });

    return uploadImage(commoner_id, file, onProgress)
           .then(response => new Promise((resolve, reject) => {
             if (response.status === 200) {
               resolve(response.data.url);
             } else {
               reject(response);
             }
           }))
           .catch(error => this.setState({ status: 'ERROR' }))
           .finally(() => this.setState({ status: undefined }))
  }

  saveStory = (story) => {
    const { locale } = this.props;
    const { storyId } = this.state;

    this.setState({ status: 'Saving...' });

    return updateContent(storyId, story, locale)
           .then(({ status, data }) => {
             if (status === 200) {
               this.setState({
                 storyId: data.id,
                 status: ''
               })
             }
           })
           .catch(error => this.setState({ status: 'ERROR' }))
  }

  render() {
    const { availableTags } = this.props;
    const { status } = this.state;

    if (this.state.hasError) {
      return (
        <div className="story-builder story-builder--has-error">
          The Story Builder is experiencing some technical issues. Please refresh the page.
        </div>
      )
    }

    return (
      <div className="story-builder-wrapper">
        <div className="story-builder-wrapper__status">
          {status}
        </div>
        <StoryBuilder
          availableTags={availableTags.map(({ id, name }) => ({ id, name }))}
          imageUploadHandler={this.imageUploadHandler}
          onSave={this.saveStory}
          {...this.props.story} />
      </div>
    )
  }
}
