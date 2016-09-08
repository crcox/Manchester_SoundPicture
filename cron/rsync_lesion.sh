#!/bin/bash
SSH='/usr/bin/ssh'
ID='/home/chris/.ssh/id_rsa_cron'
USER='crcox'
REMOTE='chtc'
SSH_CMD="${SSH} -i ${ID}"
SOURCE='/home/crcox/Manchester/WholeBrain_RSA/LESION/semantic'
DEST='/home/chris/MRI/Manchester/results/WholeBrain_RSA/LESION/'

/usr/bin/rsync -avz \
  -e "${SSH_CMD}" \
  --remove-source-files \
  --include="*/" \
  --include="results.json" \
  --include="results.mat" \
  --exclude="*" \
  ${USER}@${REMOTE}:${SOURCE} ${DEST}
