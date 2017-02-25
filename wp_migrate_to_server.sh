#!/bin/bash

# ============================
# Script to migrate a site from a local MAMP install 
# to the staging server for the first time.

# 1. Create a blank DB on staging server.
# 2. Copy the Github or Bitbucket theme repository URL. You’ll input this into the command prompt in the next step.
# 3. Run ‘wpmigratetoserver’ command within site folder
# ============================

# ============================
# Variables
# ============================

sitename=${PWD##*/}

# Source the config file for universal variables

root=$(cd $(dirname $0)/ && pwd)

config_path=${root}/config.cfg

. $config_path

# User prompt to get the repository URL to clone from

read -p "Bitbucket or Github Repo URL: " repositoryURL
read -p "Server Database Name: " dbname

# ============================
# Download DB
# ============================

echo "Downloading local DB 👇"

wp db export $sitename.sql

cd ../

clear

# ============================
# Send Local Files To Server
# ============================

echo "Zipping $sitename files 💾"

# Zip the full installation not including the themes folder or config file

tar --exclude="./$sitename/wp-content/themes" --exclude="./$sitename/wp-config.php" -zcvf $sitename.tar.gz $sitename

#clear

echo "Sending $sitename files to the server 🖥"

# Copy it to the public_html folder on the server

scp -P $ssh_port $sitename.tar.gz $ssh_userhost:$server_path

clear

# ============================
# Login to server
# ============================

ssh $ssh_userhost -p$ssh_port bash -c "'

	# Unzip the site
	# =======================

	cd public_html
	tar -zxvf $sitename.tar.gz
	rm $sitename.tar.gz

	# Create a config file
	# =======================

	cd $sitename
	wp core config --dbname=$dbname --dbuser=$server_db_user --dbpass=$server_db_password

	# Import Database
	# =======================

	wp db import $sitename.sql
	wp search-replace 'http://localhost:8888/$sitename' '$server_url/$sitename'

	# Setup Theme
	# =======================

	mkdir -p wp-content/themes/$sitename
	cd wp-content/themes/$sitename
	git clone $repositoryURL .

'"

# ============================
# Clean Up local environment
# ============================

clear

# Remove original zip file

rm $sitename.tar.gz

# Go back into folder to end

cd $sitename

echo 'All Set Up 🤘'