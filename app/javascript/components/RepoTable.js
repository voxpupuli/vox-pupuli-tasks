import React from 'react';
import PropTypes from 'prop-types';
import {Table, Pagination} from 'semantic-ui-react'

import {RepoPageSizeSelect} from './RepoPageSizeSelect.js';
import {RepoRow} from "./RepoRow.js";
import {RepoTableHeader} from "./RepoTableHeader.js";

export const RepoTable = (props) => {
  if (!props.repos) {
    return <React.Fragment/>;
  }
  const repoRows = props.repos.map(
    (repo, index) => <RepoRow key={index} repo={repo} />
  );
  return (
    <React.Fragment>
      <RepoPageSizeSelect
        limit={props.limit}
        onChangeLimit={props.onChangeLimit}
      />
      Total count: {props.totalCount}.
      <Table celled selectable sortable >
        <RepoTableHeader
          column={props.column}
          direction={props.direction}
          handleSort={props.handleSort}
        />

        <Table.Body>
          {repoRows}
        </Table.Body>

        <Table.Footer>
          <Table.Row>
            <Table.HeaderCell colSpan='8'>
              <Pagination
                totalPages={props.totalPages}
                activePage={props.currentPage}
                onPageChange={props.onChangePage}
              />
            </Table.HeaderCell>
          </Table.Row>
        </Table.Footer>
      </Table>
    </React.Fragment>
  );
};

RepoTable.propTypes = {
  totalCount: PropTypes.number.isRequired,
  totalPages: PropTypes.number.isRequired,
  currentPage: PropTypes.number.isRequired,
  onChangePage: PropTypes.func.isRequired,
  onChangeLimit: PropTypes.func.isRequired,
  limit: PropTypes.string.isRequired,
};