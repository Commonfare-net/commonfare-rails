import { addLocaleData, defineMessages } from 'react-intl';
import hrLocaleData from 'react-intl/locale-data/hr';

addLocaleData(hrLocaleData);

const messages = defineMessages({
  technical_issues: 'Story Builder doživljava neke tehničke probleme. Osvježite stranicu.',
  create_old: 'Napravite pomoću starog uređivača',
  error: 'Greška',
  uploading: 'Prijenos...',
  publish_anonymously: 'Objavite anonimno?',
  preview: 'Pregled',
  publish: 'Objavite',
  writing_in: 'Pišete na',
  'locale.en': 'Engleski',
  'locale.it': 'Talijanski',
  'locale.nl': 'Nizozemski/Flamanski',
  'locale.hr': 'Hrvatski',
  no_translation_in: "Još niste spremili priču na {locale}",
  'yes': 'Da',
  'no': 'Ne'
});

export default messages;
