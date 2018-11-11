#!/bin/bash
# CiviCRM upgrade via Drush

# Set maintenance mode
drush variable-set maintenance_mode 1

# Clear cache
drush cache-clear all

# Download tarball
$CIVICRM_VERSION = 4.7.4
curl -fSL "https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-drupal.tar.gz" -o /tmp/civicrm.tar.gz

# Upgrade and backup
$BACKUP_DIR = /var/www/
drush civicrm-upgrade --tarfile=/tmp/civicrm.tar.gz --backupdir=${BACKUP_DIR}

# Delete tarball
rm /tmp/civicrm.tar.gz

# Exit maintenance mode
drush variable-set maintenance_mode 0

# Clear cache
drush cache-clear all
