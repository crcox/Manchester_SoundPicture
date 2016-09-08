#!/bin/bash
SSH='/usr/bin/ssh'
ID='/home/chris/.ssh/id_rsa_cron'
USER='crcox'
REMOTE='chtc'
SSH_CMD="${SSH} -i ${ID}"
SOURCE='/home/crcox/Manchester/WholeBrain_RSA/visual/avg/grOWL2/tune'
DEST='/home/chris/MRI/Manchester/results/WholeBrain_RSA/visual/similarity/chamfer/visual/growl2/'

/usr/bin/rsync -avz \
  -e "${SSH_CMD}" \
  --include="*/" \
  --include="params.json" \
  --exclude="*" \
  ${USER}@${REMOTE}:${SOURCE} ${DEST}
