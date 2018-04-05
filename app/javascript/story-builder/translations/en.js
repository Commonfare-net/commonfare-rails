import { addLocaleData, defineMessages } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';

addLocaleData(enLocaleData);

const messages = defineMessages({
  technical_issues: 'The Story Builder is experiencing some technical issues. Please refresh the page.',
  create_old: 'Create using the old editor',
  error: 'ERROR',
  uploading: 'Uploading...',
  publish_anonymously: 'Publish anonymously?',
  preview: 'Preview',
  publish: 'Publish',
  writing_in: 'You are writing in',
  'locale.en': 'English',
  'locale.it': 'Italian',
  'locale.nl': 'Dutch/Flemish',
  'locale.hr': 'Croatian',
  no_translation_in: "You haven't yet saved this Story in {locale}",
  'yes': 'Yes',
  'no': 'No'
});

export default messages;
