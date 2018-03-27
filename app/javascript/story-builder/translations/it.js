import { addLocaleData, defineMessages } from 'react-intl';
import itLocaleData from 'react-intl/locale-data/it';

addLocaleData(itLocaleData);

const messages = defineMessages({
  technical_issues: 'Si è verificato un problema. Aggiorna la pagina.',
  create_old: "Usa l'editor tradizionale",
  error: 'ERRORE',
  uploading: 'Caricamento...',
  publish_anonymously: 'Pubblica in modo anonimo?',
  preview: 'Anteprima',
  publish: 'Pubblica',
  writing_in: 'Stai scrivendo in',
  'locale.en': 'Inglese',
  'locale.it': 'Italiano',
  'locale.nl': 'Olandese/Fiammingo',
  'locale.hr': 'Croato',
  no_translation_in: "Non hai ancora salvato questa storia in {locale}",
  'yes': 'Sì',
  'no': 'No'
});

export default messages;