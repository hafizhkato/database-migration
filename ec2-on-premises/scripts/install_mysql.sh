#!/bin/bash

# Exit if any command fails
set -e

# Update and install required packages
sudo apt-get update
sudo apt-get install -y mysql-server awscli

# Allow MySQL to accept external connections
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# Define credentials
ROOT_PASS="MyStrongPass123!"
ADMIN_USER="admin"
ADMIN_PASS="StrongAdminPass123!"

# Setup root for internal (optional) and admin for external access
sudo mysql <<EOF
-- Create root for internal access (optional)
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOT_PASS}';

-- Create external admin user
CREATE USER '${ADMIN_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${ADMIN_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' WITH GRANT OPTION;

-- Optional: Lock down root from outside
DROP USER IF EXISTS 'root'@'%';

-- Finalize permissions
FLUSH PRIVILEGES;
EOF

# Create your database
mysql -u root -p${ROOT_PASS} -e "CREATE DATABASE IF NOT EXISTS ecommerce;"

# Download SQL files from S3
aws s3 cp s3://aws-project-management-0976/mysql/customers_data.sql /tmp/customers_data.sql
aws s3 cp s3://aws-project-management-0976/mysql/transaction.sql /tmp/transaction.sql

# Import SQL into the database
mysql -u root -p${ROOT_PASS} ecommerce < /tmp/customers_data.sql
mysql -u root -p${ROOT_PASS} ecommerce < /tmp/transaction.sql

echo "✅ MySQL setup complete with external admin access."
