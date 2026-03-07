#!/bin/bash
# Daily Firestore backup script.
# Schedule via cron: 0 3 * * * /path/to/backup-firestore.sh
#
# Requires:
# - gcloud CLI authenticated with project access
# - Cloud Storage bucket: gs://hey-cape-cod-backups
#
# Usage: ./scripts/backup-firestore.sh [project-id]

set -euo pipefail

PROJECT_ID="${1:-hey-cape-cod}"
BUCKET="gs://${PROJECT_ID}-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="${BUCKET}/firestore/${TIMESTAMP}"

echo "Starting Firestore backup for project: ${PROJECT_ID}"
echo "Destination: ${BACKUP_PATH}"

# Export all collections
gcloud firestore export "${BACKUP_PATH}" \
  --project="${PROJECT_ID}" \
  --collection-ids=users,pois,stories,spending,metrics

echo "Backup completed: ${BACKUP_PATH}"

# Clean up backups older than 30 days
echo "Cleaning up old backups..."
CUTOFF=$(date -d '30 days ago' +%Y%m%d 2>/dev/null || date -v-30d +%Y%m%d)
gsutil ls "${BUCKET}/firestore/" | while read -r dir; do
  DIR_DATE=$(basename "$dir" | cut -d'-' -f1-3 | tr -d '-')
  if [[ "${DIR_DATE}" < "${CUTOFF}" ]]; then
    echo "Removing old backup: ${dir}"
    gsutil -m rm -r "${dir}"
  fi
done

echo "Backup and cleanup complete."
