
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Postgresql high rollback rate incident
---

This incident type refers to a situation where the Postgresql database has a high rollback rate, which means that a high percentage of transactions are being aborted compared to the committed ones. This can cause issues with data consistency and performance, and may require investigation and resolution by the responsible team. The incident details may include information about the affected database instance, the service or system impacted, the urgency level, and any related alerts or escalations.

### Parameters
```shell
# Environment Variables

export TABLE_NAME="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export DATABASE_USERNAME="PLACEHOLDER"

export DATABASE_PORT="PLACEHOLDER"

export DATABASE_HOST="PLACEHOLDER"

export DATABASE_PASSWORD="PLACEHOLDER"

```

## Debug

### Check the status of the PostgreSQL service
```shell
systemctl status postgresql
```

### Check the PostgreSQL logs for any errors
```shell
journalctl -u postgresql
```

### Check the PostgreSQL configuration file for any issues
```shell
cat /etc/postgresql/main/postgresql.conf
```

### Check the current connections to PostgreSQL and their status
```shell
psql -U ${DATABASE_USERNAME} -h ${DATABASE_HOST} -c "SELECT * FROM pg_stat_activity;"
```

### Check the PostgreSQL version installed
```shell
psql --version
```

### Check the system resources being used by PostgreSQL
```shell
top
```

### Check the disk usage and available space
```shell
df -h
```

### Check the PostgreSQL database for any inconsistencies
```shell
psql -U ${DATABASE_USERNAME} -h ${DATABASE_HOST} -c "CHECK TABLE ${TABLE_NAME}"
```

### Check the PostgreSQL database for any corrupted data
```shell
psql -U ${DATABASE_USERNAME} -h ${DATABASE_HOST} -c "SELECT * FROM pg_database WHERE datname = '${DATABASE_NAME}'"
```

### Check the PostgreSQL database for any deadlocks
```shell
psql -U ${DATABASE_USERNAME} -h ${DATABASE_HOST} -c "SELECT * FROM pg_locks WHERE NOT granted;"
```

### Check the PostgreSQL database for the current transaction status
```shell
psql -U ${DATABASE_USERNAME} -h ${DATABASE_HOST} -c "SELECT * FROM pg_stat_database WHERE datname = '${DATABASE_NAME}'"
```

### Measure the rollback rate 
```shell
SELECT
  sum(t.rollback_time) / sum(t.xact_rollback) AS rollback_rate
FROM
  pg_stat_database d
JOIN
  pg_stat_bgwriter t
ON
  d.datname = current_database()
WHERE
  d.datname = current_database();
```

## Repair

### Optimize the database configuration to reduce the frequency of rollbacks. Adjusting the database settings can help to optimize the rollback rate.
```shell
#!/bin/bash

# Define the database parameters

${DATABASE_NAME}="${DATABASE_NAME}"

${DATABASE_USER}="${DATABASE_USER}"

${DATABASE_PASSWORD}="${DATABASE_PASSWORD}"

${DATABASE_HOST}="${DATABASE_HOST}"

${DATABASE_PORT}="${DATABASE_PORT}"

# Backup the current database configuration

cp  /etc/postgresql/main/postgresql.conf /etc/postgresql/main/postgresql.conf.bak
# Modify the database configuration to optimize rollback rate

sed -i 's/#max_connections = 100/max_connections = 500/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#shared_buffers = 128MB/shared_buffers = 2GB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#work_mem = 4MB/work_mem = 64MB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#maintenance_work_mem = 64MB/maintenance_work_mem = 256MB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#max_wal_size = 1GB/max_wal_size = 2GB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#min_wal_size = 80MB/min_wal_size = 1GB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#checkpoint_completion_target = 0.5/checkpoint_completion_target = 0.9/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#wal_buffers = -1/wal_buffers = 16MB/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#wal_writer_delay = 200ms/wal_writer_delay = 2s/g'  /etc/postgresql/main/postgresql.conf

sed -i 's/#commit_delay = 0/commit_delay = 1000/g'  /etc/postgresql/main/postgresql.conf

# Restart the database

systemctl restart postgresql


echo "Database configuration has been optimized to reduce rollback rate."

```