# pmm-custom-queries
Custom queries for Percona Monitoring and Management (PMM) 

This repository contains custom query configurations to extract additional data, compared to what MySQLd Exporter provides out of the box.

While we believe these are to be generally safe they have not need extensively tested for performance impact so use them with care

## Installation 

### Percona Monitoring and Management (PMM) v 2.x  

Percona Monitoring and Management 2.x supports multiple files with custom queries.  Custom Query Files should be installed on the node which runs MySQL or PostgreSQL exporter. They will be used for all database instances which this exporter is configured to serve.

Location of the files is */usr/local/percona/pmm2/collectors/custom-queries/TECHNOLOGY/RESOLUTION)*    for example if you want custom collector queries to be ran at low resolution for MySQL you should place them to */usr/local/percona/pmm2/collectors/custom-queries/mysql/low-resolution*

