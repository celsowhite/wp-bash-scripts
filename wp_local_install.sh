#!/bin/bash

# ============================
# Script to setup a blank WP install within local MAMP server. 
# The install comes with a few plugins and my starter theme. 
# Be sure to set your admin and other settings via the config.cfg file in the root of this folder.
#
# 1. Create a new folder within htdocs.
# 2. CD into the folder and run ‘wplocalinstall’.
# ============================

# ============================
# Variables
# ============================

sitename=${PWD##*/}

# Source the config file for universal variables

root=$(cd $(dirname $0)/ && pwd)

config_path=${root}/config.cfg

. $config_path

# ============================
# Download & Install Wordpress
# ============================

echo "Downloading and Installing Wordpress 👇"

# Download Wordpress

wp core download

# Create a WP Config File

wp core config --dbname=$sitename --dbuser=root --dbpass=root --extra-php <<PHP 
define( 'WP_DEBUG', true ); 
PHP

# Create the database

wp db create 

# Install Wordpress

wp core install --url=http://localhost:8888/$sitename  --title=$sitename --admin_user=$wp_user --admin_password=$wp_password --admin_email=$wp_email

clear

# ============================
# Setup Plugins
# ============================

echo "Setting up plugins 🛠"

# Delete Akismet and Hello Dolly

wp plugin delete akismet
wp plugin delete hello

# Add Limit Login Attempts

wp plugin install limit-login-attempts --activate

# Add Advanced Custom Fields if a key is present in the config file

if [ ! -z "$acf_key" ]
then 
	acf_zip_file="$(wp plugin path)/acf-pro.zip"
	wget -O ${acf_zip_file} "https://connect.advancedcustomfields.com/index.php?p=pro&a=download&k=$acf_key"
	wp plugin install ${acf_zip_file} --activate
	rm ${acf_zip_file}
fi

clear

# ============================
# Setup Themes
# ============================

echo "Setting up themes 🏙"

# Download starter theme from Github

wp theme install $starter_theme

# Change theme name

mv wp-content/themes/_s wp-content/themes/$sitename

# Active theme

wp theme activate $sitename

# Delete Standard WP Themes

wp theme delete twentyfifteen twentysixteen twentyseventeen

clear

# ============================
# Setup Admin Settings
# ============================

echo "Adjusting the dashboard settings 🏡"

# Create homepage and set it as the front page

wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
wp post create --post_type=page --post_title=Homepage --post_status=publish
wp option update show_on_front "page"
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=homepage --field=ID --format=ids)

# Set pretty urls

wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

clear

# ============================
# Open Project
# ============================

# Source Code in VS Code

code wp-content/themes/$sitename -r

# Site in Chrome

/usr/bin/open -a "/Applications/Google Chrome.app" "http://localhost:8888/$sitename"

echo 'All Set Up 🤘'