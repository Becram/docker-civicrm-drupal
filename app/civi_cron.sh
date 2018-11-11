#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /var/www/html
/usr/local/bin/drush civicrm-api -u 1 job.execute
