#!/bin/bash

# ============================
# Script to update a staging site after working on it locally. 
# You can select which part of the site to update depending on what you worked on.
#
# 1. Run ‘wpupdateserver’ command within site folder.
# 2. Select which component of the site you want to update. Options include: Update just the theme, update just the database or update the complete site including uploads and plugins folders.
# 3. If you want to update the complete site then you’ll need to have the themes github repository URL ready to paste into the command prompt.
# ============================

# ============================
# Variables
# ============================

sitename=${PWD##*/}

# Pull variables from Config File

root=$(cd $(dirname $0)/ && pwd)

config_path=${root}/config.cfg

. $config_path

# ============================
# User Prompt
# ============================

PS3='Please enter your choice 👉 '
options=("Update Theme" "Update Database" "Update Theme, DB and WP-Content's folder")
select opt in "${options[@]}"
do
    case $opt in
        "Update Theme")

			# ============================
			# Login to server
			# ============================

			ssh $ssh_userhost -p$ssh_port bash -c "'

				# Update theme
				# =======================

				cd public_html/$sitename/wp-content/themes/$sitename
				git pull origin master

			'"
			clear
			echo 'Theme updated 🤘'
			break
            ;;
        "Update Database")
            # ============================
			# Prepare Local Files
			# ============================

			# Download DB

			echo "Downloading local DB 👇"

			wp db export $sitename.sql

			clear

			# ============================
			# Send DB to server
			# ============================

			echo "Sending $sitename database to the server 🖥"

			# Copy it to the public_html folder on the server

			scp -P $ssh_port $sitename.sql $ssh_userhost:$server_path/$sitename

			clear

			# ============================
			# Login to server
			# ============================

			ssh $ssh_userhost -p$ssh_port bash -c "'

				# Update the Database
				# =======================

				cd public_html/$sitename
				wp db reset --yes
				wp db import $sitename.sql
				wp search-replace 'http://localhost:8888/$sitename' '$server_url/$sitename'

			'"

			# ============================
			# Clean Up local environment
			# ============================

			clear

			# Remove original wp-content zip and database files

			rm $sitename.sql

			clear
			echo 'Staging database updated 🤘'
			break
            ;;
        "Update Theme, DB and WP-Content's folder")
			
			read -p "Bitbucket or Github Repo URL: " repositoryURL

            # ============================
			# Prepare Local Files
			# ============================

			# Download DB

			echo "Downloading local DB 👇"

			wp db export $sitename.sql

			# Zip the wp-content Folder

			echo "Zipping $sitename files 💾"

			tar --exclude="./wp-content/themes" -zcvf wp-content.tar.gz wp-content

			clear

			# ============================
			# Send DB and wp-content to server
			# ============================

			echo "Sending $sitename database and wp-content to the server 🖥"

			# Copy it to the public_html folder on the server

			scp -P $ssh_port $sitename.sql wp-content.tar.gz $ssh_userhost:$server_path/$sitename

			clear

			# ============================
			# Login to server
			# ============================

			ssh $ssh_userhost -p$ssh_port bash -c "'

				# Update the Database
				# =======================

				cd public_html/$sitename
				wp db reset --yes
				wp db import $sitename.sql
				wp search-replace 'http://localhost:8888/$sitename' '$server_url/$sitename'

				# Update wp-content
				# =======================

				rm -rf wp-content
				tar -zxvf wp-content.tar.gz
				rm wp-content.tar.gz

				# Update theme
				# =======================

				mkdir -p wp-content/themes/$sitename
				cd wp-content/themes/$sitename
				git clone $repositoryURL .

			'"

			# ============================
			# Clean Up local environment
			# ============================

			clear

			# Remove original wp-content zip and database files

			rm wp-content.tar.gz $sitename.sql

			echo 'Staging site updated 🤘'
			break
            ;;
        *) echo invalid option;;
    esac
done