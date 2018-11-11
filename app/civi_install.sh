#!/bin/bash

LOCK=/var/www/civi_install.lock

# Only initialize once
if [ -f $LOCK ]; then
  echo "App container: CiviCRM already installed."
  exit 0
fi

echo "Waiting for Database container..."
while ! mysqladmin ping --host=db --silent; do
  sleep 1
done

echo "Database container ready."

echo "Installing Drupal..."

drush -y site-install minimal \
  --account-name=${DEFAULT_ACCOUNT} \
  --account-pass=${DEFAULT_ACCOUNT_PASS} \
  --account-mail=${DEFAULT_ACCOUNT_MAIL} \
  --db-url="mysqli://${MYSQL_USER}:${MYSQL_PASSWORD}@db/${MYSQL_DATABASE}" \
  --site-name=${SITE_NAME} \
  --site-mail=${SITE_MAIL}

# Harden Drupal file/folder permissions
chown -R www-data:www-data ${WEB_ROOT}
chmod -R 755 ${WEB_ROOT}

echo "Finished installing Drupal."

echo "Installing CiviCRM..."

# TODO: there must be a better way...
mysql \
  --host=db \
  --user=root \
  --password=${MYSQL_ROOT_PASSWORD} \
  --execute="CREATE DATABASE ${MYSQL_DATABASE_CIVICRM};"
mysql \
  --host=db \
  --user=root \
  --password=${MYSQL_ROOT_PASSWORD} \
  --execute="GRANT ALL ON ${MYSQL_DATABASE_CIVICRM}.* TO '${MYSQL_USER}'@'%';"

drush -y civicrm-install \
  --dbuser=${MYSQL_USER} \
  --dbpass=${MYSQL_PASSWORD} \
  --dbhost=db \
  --dbname=${MYSQL_DATABASE_CIVICRM} \
  --tarfile=/var/www/civicrm.tar.gz \
  --destination=sites/all/modules \
  --site_url=${VIRTUAL_HOST} \
  --ssl=on \
  --load_generated_data=0

# TODO: there must be a better way....
chown -R root:www-data ${WEB_ROOT}/sites/all/modules/civicrm
chown -R root:www-data ${WEB_ROOT}/sites/default/files/civicrm
find ${WEB_ROOT}/sites/default/files/civicrm -type d -exec chmod ug=rwx,o=rx '{}' \;
find ${WEB_ROOT}/sites/default/files/civicrm -type f -exec chmod ug=rwx,o=rx '{}' \;

echo "Finished installing CiviCRM."

echo "Cleaning up..."

# TODO: verify environment is clean on next startup
unset DEFAULT_ACCOUNT
unset DEFAULT_ACCOUNT_PASS
unset DEFAULT_ACCOUNT_MAIL
unset SITE_NAME
unset SITE_MAIL
unset MYSQL_USER
unset MYSQL_PASSWORD
unset MYSQL_ROOT_PASSWORD
unset MYSQL_DATABASE
unset MYSQL_DATABASE_CIVICRM
unset WEB_ROOT
unset VIRTUAL_HOST

echo "Done!"

touch $LOCK
