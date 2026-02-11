#!/bin/bash

DATE=$(date +%Y-%m-%d)

rm -f /home/user/domains/backup/moodle_*.sql.gz
rm -f /home/user/domains/backup/moodle_*.tar.gz
rm -f /home/user/domains/backup/moodledata_*.tar.gz.part*

time tar -czf /home/user/domains/backup/moodle_${DATE}.tar.gz \
  -C /home/user/domains teaching.kse.org.ua/public_html
  
time mysqldump -uuser_teach -p'CObTJo0vV' user_kse \
  --single-transaction --quick \
| /usr/bin/gzip > /home/user/domains/backup/moodle_${DATE}.sql.gz

time bash -c "tar -cf - -C /home/user/domains private \
  --exclude='private/cache/**' \
  --exclude='private/localcache/**' \
  --exclude='private/temp/**' \
  --exclude='private/trashdir/**' \
  --exclude='private/lock/**' \
| gzip \
| split -d -b 8000m - /home/user/domains/backup/moodledata_${DATE}.tar.gz.part"



rclone delete gdrive:backups --min-age 3d --include "moodle*.tar.gz"
rclone delete gdrive:backups --min-age 3d --include "moodle*.sql.gz"
rclone delete gdrive:backups --min-age 3d --include "moodledata*.tar.gz.part*"

rclone copy /home/user/domains/backup/moodle_${DATE}.tar.gz gdrive:backups
rclone copy /home/user/domains/backup/moodle_${DATE}.sql.gz gdrive:backups
for f in /home/user/domains/backup/moodledata_${DATE}.tar.gz.part*; do
  rclone copy "$f" gdrive:backups \
    --log-file=/home/user/domains/backup/rclone-backup.log \
    --log-level INFO
  sleep 10
done

