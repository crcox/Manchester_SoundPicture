#!/bin/bash
SSH='/usr/bin/ssh'
ID='/home/chris/.ssh/id_rsa_cron'
USER='crcox'
REMOTE='chtc'
SSH_CMD="${SSH} -i ${ID}"
SOURCE='/home/crcox/FacePlaceObject/WholeBrain_MVPA/soslasso'
DEST='/home/chris/MRI/FacePlaceObject/results/WholeBrain_MVPA/'

/usr/bin/rsync -avz \
  -e "${SSH_CMD}" \
  --remove-source-files \
  --include="*/" \
  --include="results.json" \
  --include="results.mat" \
  --exclude="*" \
  ${USER}@${REMOTE}:${SOURCE} ${DEST}
