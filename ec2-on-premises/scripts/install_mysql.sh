#!/bin/bash

# Update and install packages
sudo apt-get update
sudo apt-get install -y mysql-server awscli

# Start MySQL and configure root user
sudo systemctl start mysql
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'MyStrongPass123!';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create the database
sudo mysql -uroot -pMyStrongPass123! -e "CREATE DATABASE ecommerce;"

# Download SQL files from S3
aws s3 cp s3://aws-project-management-0976/mysql/customers_data.sql /home/ubuntu/customers_data.sql
aws s3 cp s3://aws-project-management-0976/mysql/transaction.sql /home/ubuntu/transaction.sql

# Import SQL files into the ecommerce database
sudo mysql -uroot -pMyStrongPass123! ecommerce < /home/ubuntu/customers_data.sql
sudo mysql -uroot -pMyStrongPass123! ecommerce < /home/ubuntu/transaction.sql
