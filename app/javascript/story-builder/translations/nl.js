import { addLocaleData, defineMessages } from 'react-intl';
import nlLocaleData from 'react-intl/locale-data/nl';

addLocaleData(nlLocaleData);

const messages = defineMessages({
  technical_issues: 'De Story Builder ondervindt enkele technische problemen. Vernieuw de pagina.',
  create_old: 'Maak gebruik van de oude editor',
  error: 'Fout',
  saving: 'Besparing...',
  uploading: 'Uploaden...',
  publish_anonymously: 'Publiceer anoniem?',
  preview: 'Voorvertoning',
  publish: 'Plaats je verhaal',
  writing_in: 'Je schrijft in het',
  'locale.en': 'Engels',
  'locale.it': 'Italiaans',
  'locale.nl': 'Nederlands/Vlaams',
  'locale.hr': 'Kroatisch',
  no_translation_in: "Je hebt dit verhaal nog niet opgeslagen in het {locale}",
  'yes': 'Ja',
  'no': 'Nee',
  'publish_as_group': "Publiceer als een groep",
  'choose_group': "Kies een van je groepen",
  'no_group_found': "Geen groep gevonden"
});

export default messages;
