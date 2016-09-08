#!/bin/bash
SSH='/usr/bin/ssh'
ID='/home/chris/.ssh/id_rsa_cron'
USER='crcox'
REMOTE='chtc'
SSH_CMD="${SSH} -i ${ID}"
SOURCE='/home/crcox/Manchester/WholeBrain_RSA/semantic/avg/visual/grOWL2/final'
DEST='/home/chris/MRI/Manchester/results/WholeBrain_RSA/semantic/similarity/featurenorms/cosine/visual/growl2/'

/usr/bin/rsync -avz \
  -e "${SSH_CMD}" \
  --remove-source-files \
  --include="*/" \
  --include="results.json" \
  --include="results.mat" \
  --exclude="*" \
  ${USER}@${REMOTE}:${SOURCE} ${DEST}
