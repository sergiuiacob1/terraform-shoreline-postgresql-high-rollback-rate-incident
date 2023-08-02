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