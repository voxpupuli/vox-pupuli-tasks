import React, {Component} from 'react';
import {Button, Container, Header, Menu} from 'semantic-ui-react'

import RepoList from './RepoList.js';

export class Dashboard extends Component {
  render() {
    return (
      <RepoList />
    )
  };
}

export default Dashboard;