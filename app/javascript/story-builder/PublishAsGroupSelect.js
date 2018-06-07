import React, { Component } from 'react';
import { number, array, func, bool } from 'prop-types';
import { injectIntl, FormattedMessage, intlShape } from 'react-intl';
import Select from 'react-select';
import 'react-select/dist/react-select.css';

class PublishAsGroupSelect extends Component {
  static propTypes = {
    groups: array.isRequired,
    groupId: number,
    disabled: bool.isRequired,
    onChange: func.isRequired,
    intl: intlShape
  }

  render() {
    const { groups, groupId, onChange, disabled, intl } = this.props;

    return (
      <div>
        <label htmlFor="publish_as_group">
          <FormattedMessage
            id="publish_as_group"
            defaultMessage="Publish as a Group?"
          />
        </label>
        <Select
          name="publish_as_group"
          value={groupId}
          onChange={selectedGroup => onChange(selectedGroup ? selectedGroup.value : null)}
          disabled={disabled}
          options={groups.map((group) => ({ label: group.name, value: group.id }))}
          placeholder={intl.formatMessage({ id: 'choose_group' })}
          noResultsText={intl.formatMessage({ id: 'no_group_found' })}
        />
      </div>
    )
  }
}

export default injectIntl(PublishAsGroupSelect);
