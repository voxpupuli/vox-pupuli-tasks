import {Table} from "semantic-ui-react";
import React from "react";

export function RepoTableHeader(props) {
  return (
    <Table.Header>
      <Table.Row>
        <Table.HeaderCell width={1} sorted = {props.column === 'id' ? props.direction : null } onClick={() => props.handleSort('id')}>#</Table.HeaderCell>
        <Table.HeaderCell width={3} sorted = {props.column === 'name' ? props.direction : null } onClick={() => props.handleSort('name')}>Name</Table.HeaderCell>
        <Table.HeaderCell width={3} sorted = {props.column === 'description' ? props.direction : null } onClick={() => props.handleSort('description')}>Description</Table.HeaderCell>
        <Table.HeaderCell width={1} sorted = {props.column === 'stars' ? props.direction : null } onClick={() => props.handleSort('stars')}>Stars</Table.HeaderCell>
        <Table.HeaderCell width={1} sorted = {props.column === 'watchers' ? props.direction : null } onClick={() => props.handleSort('watchers')}>Watchers</Table.HeaderCell>
        <Table.HeaderCell width={1} sorted = {props.column === 'open_issues_count' ? props.direction : null } onClick={() => props.handleSort('open_issues_count')}>Open Issues</Table.HeaderCell>
        <Table.HeaderCell width={1} sorted = {props.column === 'updated_at' ? props.direction : null } onClick={() => props.handleSort('updated_at')}>Last Sync</Table.HeaderCell>
      </Table.Row>
    </Table.Header>
  )
}
