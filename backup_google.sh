#!/bin/bash

DATE=$(date +%Y-%m-%d)

rm -f /home/user/domains/backup/moodle*.sql.gz
rm -f /home/user/domains/backup/moodle*.tar.gz
rm -f /home/user/domains/backup/moodledata*.tar.gz*

tar -czf /home/user/domains/backup/moodle_${DATE}.tar.gz /home/user/domains/teaching.kse.org.ua/public_html
mysqldump -uuser_teach -pCObTJo0vV user_kse | /usr/bin/gzip > /home/user/domains/backup/moodle_${DATE}.sql.gz
tar -cf - /home/user/domains/private | /usr/bin/split -d -b 29000m - /home/user/domains/backup/moodledata_${DATE}.tar.gz

#Ротація за 4 дні
rclone delete gdrive:backups --min-age 3d --include "moodle*.tar.gz"
rclone delete gdrive:backups --min-age 3d --include "moodle*.sql.gz"  
rclone delete gdrive:backups --min-age 3d --include "moodledata*.tar.gz*"

rclone copy /home/user/domains/backup/moodle_${DATE}.tar.gz gdrive:backups
rclone copy /home/user/domains/backup/moodle_${DATE}.sql.gz gdrive:backups


for f in /home/user/domains/backup/moodledata_*.tar.gz*; do
  /usr/bin/rclone copy "$f" gdrive:backups
  sleep 10
done
    