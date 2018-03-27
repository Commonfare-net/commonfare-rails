import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { IntlProvider, FormattedMessage } from 'react-intl';
import StoryBuilder from 'storybuilder-react';

import { uploadImage, deleteImage, updateContent } from './api';
import LanguageChoice from './LanguageChoice';
import StoryBuilderActions from './StoryBuilderActions';

import './StoryBuilderWrapper.css';

const locales = ['en', 'it', 'hr', 'nl'];
import * as translations from './translations';

export default class extends Component {
  static propTypes = {
    locale: PropTypes.oneOf(locales).isRequired,
    storyLocale: PropTypes.oneOf(locales).isRequired,
    story: PropTypes.object.isRequired,
    availableTags: PropTypes.array.isRequired
  }

  constructor(props) {
    super(props);
    this.state = {
      storyId: props.story.id,
      translatedLocales: props.story.translated_locales,
      hasError: false,
      status: undefined
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
    this.setState({ status: 'uploading' });

    return uploadImage(story, file, onProgress)
           .then(response => new Promise((resolve, reject) => {
             if (response.status === 200) {
               resolve(response.data.url);
             } else {
               reject(response);
             }
           }))
           .catch(error => this.setState({ status: 'error' }))
           .finally(() => this.setState({ status: undefined }))
  }

  imageDeleteHandler = ({ content: imageUrl }) => {
    const { story: { commoner_id } } = this.props;
    return deleteImage(commoner_id, imageUrl)
           .catch(error => this.setState({ status: 'error' }));
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
                 translatedLocales: data.translated_locales,
                 status: undefined
               })
             }
           })
           .catch(error => this.setState({ status: 'error' }))
  }

  render() {
    const { locale, storyLocale, availableTags, story: { title_draft, place_draft, content_json_draft, tags, anonymous } } = this.props;
    const { status, storyId, translatedLocales } = this.state;

    if (this.state.hasError) {
      return (
        <div className="story-builder story-builder--has-error">
          <FormattedMessage
            id="tehnical_issues"
            defaultMessage="The Story Builder is experiencing some technical issues. Please refresh the page."
          />
        </div>
      )
    }

    return (
      <IntlProvider locale={locale} messages={translations[locale]}>
        <div className="story-builder-wrapper">
          <div className="row">
            <div className="col-12 col-sm-6 order-12 order-sm-1">
              <LanguageChoice
                locale={locale}
                storyLocale={storyLocale}
                storyId={storyId}
                translatedLocales={translatedLocales} />
            </div>
            {!storyId &&
              <div className="col-12 col-sm-6 order-1 order-sm-12 text-sm-right">
                <a href={`/${locale}/stories/new`}>
                  <FormattedMessage
                    id="create_old"
                    defaultMessage="Create using the old editor"
                  />
                </a>
              </div>
            }
          </div>
          <div className="story-builder-wrapper__status">
            {status &&
              <FormattedMessage id={status} />
            }
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
      </IntlProvider>
    )
  }
}
