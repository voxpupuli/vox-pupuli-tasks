import React from "react";
import {Table} from "semantic-ui-react";
import Moment from "react-moment";
import PropTypes from "prop-types";

export const RepoRow = (props) => (
  <Table.Row>
    <Table.Cell>{props.repo.id}</Table.Cell>
    <Table.Cell>{props.repo.name}</Table.Cell>
    <Table.Cell>{props.repo.descriptions}</Table.Cell>
    <Table.Cell>{props.repo.stars}</Table.Cell>
    <Table.Cell>{props.repo.watchers}</Table.Cell>
    <Table.Cell>{props.repo.open_issues_count}</Table.Cell>
    <Table.Cell><Moment fromNow>{props.repo.updated_at}</Moment></Table.Cell>
  </Table.Row>
);

RepoRow.propTypes = {
  repo: PropTypes.object.isRequired,
};