import React, { Component } from 'react';
import { func, bool } from 'prop-types';
import { injectIntl, FormattedMessage, intlShape } from 'react-intl';
import Switch from 'react-bootstrap-switch';
import 'react-bootstrap-switch/dist/css/bootstrap3/react-bootstrap-switch.css';

class PublishAnonymouslySwitch extends Component {
  static propTypes = {
    value: bool.isRequired,
    disabled: bool.isRequired,
    onChange: func.isRequired,
    intl: intlShape
  }

  render() {
    const { value, onChange, disabled, intl } = this.props;

    return (
      <div>
        <label htmlFor="anonymous">
          <FormattedMessage
            id="publish_anonymously"
            defaultMessage="Publish anonymously?"
          />
        </label>
        <Switch
          onChange={(el, state) => onChange(state)}
          value={value}
          name="anonymous"
          onText={intl.formatMessage({ id: 'yes' })}
          offText={intl.formatMessage({ id: 'no' })}
          disabled={disabled}
         />
      </div>
    )
  }
}

export default injectIntl(PublishAnonymouslySwitch);
