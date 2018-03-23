import React, { Component } from 'react';
import PropTypes from 'prop-types';
import StoryBuilder from 'storybuilder-react';
import { uploadImage, deleteImage, updateContent } from './api';
import StoryBuilderActions from './StoryBuilderActions';

import './StoryBuilderWrapper.css';

export default class extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
    storyLocale: PropTypes.oneOf(['en', 'it', 'hr', 'nl']).isRequired,
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
    const { story } = this.props;
    this.setState({ status: 'Uploading...' });

    return uploadImage(story, file, onProgress)
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

  imageDeleteHandler = ({ content: imageUrl }) => {
    const { story: { commoner_id } } = this.props;
    return deleteImage(commoner_id, imageUrl)
           .catch(error => this.setState({ status: 'ERROR' }));
  }

  saveStory = (story) => {
    const { storyLocale } = this.props;
    const { storyId } = this.state;

    this.setState({ status: 'Saving...' });

    return updateContent(storyId, story, storyLocale)
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
    const { locale, storyLocale, availableTags, story: { title_draft, place_draft, content_json_draft, tags, anonymous } } = this.props;
    const { status, storyId } = this.state;

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
          imageDeleteHandler={this.imageDeleteHandler}
          onSave={this.saveStory}
          title={title_draft}
          place={place_draft}
          content_json={content_json_draft || []}
          tags={tags}
          locale={locale}
          storyLocale={storyLocale}
        />
        {storyId &&
          <StoryBuilderActions
            locale={locale}
            storyLocale={storyLocale}
            storyId={storyId}
            anonymous={anonymous}
          />
        }
      </div>
    )
  }
}
