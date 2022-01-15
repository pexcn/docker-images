#!/bin/bash
set -e
set -o pipefail

echo
echo
echo "[$(date '+%Y-%m-%d %T.%3N')] Backup Start."
echo

# local
#rsync -avz --delete /root/docker-compose/vaultwarden /mnt/disk/backup

# daemon pull
#rsync -avz --delete user1@192.168.1.10::source /mnt/disk/backup --password-file=<(cat /etc/rsyncd.secrets | cut -d ':' -f 2)

echo
echo "[$(date '+%Y-%m-%d %T.%3N')] Backup End."
echo
