# WP Local to Staging Bash Automation

A set of bash scripts to make it easier to install and sync your WP sites between local and staging environments.

### Assumptions

- Built for MAMP installations. Can probably work with other local server setups but may require some customization.
- Consistent naming for your local db, local site folder, server db and server url. This helps reduce the amount of user prompts needed in the scripts. 
- Version controlled theme. 

### Requirements

  - SSH access to your server. Specifically private key access so you can authenticate without adding any server passwords.
  - [wp-cli](http://wp-cli.org/): Great set of tools for managing WP Installations via the command line

# Installation

### Download the package
You can choose where to install this package. I organize my scripts into a 'Scripts' directory in the root of my computer.
```sh
git clone https://github.com/celsowhite/wp-bash-scripts.git
cd wp-bash-scripts
mv config_sample.cfg config.cfg
```

In the last step of the above commands you'll add all of your custom configuration settings (db info, wp info, server settings, etc.)

### Add your alias's
Update your ~/.bash_profile with the below alias's for quick access to the scripts. Change the directory path depending on where you cloned the repository.
```sh
alias wplocalinstall="~/Scripts/wp-bash-scripts/wp_local_install.sh"
alias wpmigratetoserver="~/Scripts/wp-bash-scripts/wp_migrate_to_server.sh"
alias wpupdateserver="~/Scripts/wp-bash-scripts/wp_update_server.sh"
```

# Commands

```sh
wplocalinstall
```

Script to setup a blank WP install within local MAMP server. The install comes with a few plugins and my starter theme. Be sure to set your admin and other settings via the config.cfg file in the root of this folder.

1. Create a new folder within htdocs.
2. CD into the folder and run 'wplocalinstall'.

```sh
wpmigratetoserver
```
Script to migrate a site from a local MAMP install to the staging server for the first time.

1. Create a blank DB on staging server.
2. Copy the Github or Bitbucket theme repository URL. You'll input this into the command prompt in the next step.
3. Run 'wpmigratetoserver' command within site folder.

```sh
wpupdateserver
```
Script to update a staging site after working on it locally. You can select which part of the site to update depending on what you worked on.

1. Run 'wpupdateserver' command within site folder.
2. Select which component of the site you want to update. Options include: Update just the theme, update just the database or update the complete site including uploads and plugins folders.
3. If you want to update the complete site then you'll need to have the themes github repository URL ready to paste into the command prompt.

# To-Do

- Better error handling and messages if something goes wrong. No wifi, ssh access denied, etc.
- Flexibility beyond MAMP install. Potentially include some Vagrant focused scripts.