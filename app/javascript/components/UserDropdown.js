import React from "react"
import PropTypes from "prop-types"
import { Dropdown } from 'semantic-ui-react'
class UserDropdown extends React.Component {
  render () {
    return (
      <Dropdown item text={this.props.username}>
        <Dropdown.Menu>
          <Dropdown.Item href="/sessions/destroy">Log Out</Dropdown.Item>
        </Dropdown.Menu>
      </Dropdown>
    );
  }
}

UserDropdown.propTypes = {
  username: PropTypes.string
};
export default UserDropdown