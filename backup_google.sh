#!/bin/bash

DATE=$(date +%Y-%m-%d)

rm -f /home/user/domains/backup/moodle*.sql.gz
rm -f /home/user/domains/backup/moodle*.tar.gz

tar -czf /home/user/domains/backup/moodle_${DATE}.tar.gz /home/user/domains/teaching.kse.org.ua/public_html
mysqldump -uuser_teach -pCObTJo0vV user_kse | /usr/bin/gzip > /home/user/domains/backup/moodle_${DATE}.sql.gz

rclone delete gdrive:backups --min-age 3d --include "moodle*.tar.gz"
rclone delete gdrive:backups --min-age 3d --include "moodle*.sql.gz"

rclone sync /home/user/domains/private gdrive:backups/moodledata \
  --exclude "cache/**" \
  --exclude "localcache/**" \
  --exclude "temp/**" \
  --exclude "trashdir/**" \
  --exclude "lock/**" \
