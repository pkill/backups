#!/bin/bash
# Backup script to wrap the duplicity suite
# Written by Alex Elman @_pkill 2014

DATE=`date +%F`
LOGNAME="/home/aelman/logs/duplicity.log.${DATE}"
usage() {
  echo '
  duptools - manage duplicity backup

  USAGE:

  ./duptools.sh backup type
  ./duptools.sh list type
  ./duptools.sh status type
  ./duptools.sh restore file [time] dest
  '
}

backup() {
  # perform an incremental backup to root, include directories, exclude everything else, / as reference.
  export PASSPHRASE
  EXCLUDES=""
  INCLUDES=""
  if [ -n "$EXCLUDE" ]; then
      for item in $EXCLUDE; do
          EXCLUDES="${EXCLUDES} --exclude ${item}"
      done
  fi
  echo "excludes are ${EXCLUDES}"
  if [ -n "$INCLUDE" ]; then
      for item in $INCLUDE; do
          INCLUDES="${INCLUDES} --include ${item}"
      done
  fi

  COMMAND="/usr/bin/duplicity -v8 ${ENCRYPT_KEY:+--encrypt-key} --full-if-older-than 120D --num-retries 12 $ARGS --volsize ${VOLSIZE} ${INCLUDES} ${EXCLUDES} --log-file ${LOGNAME} ${SOURCE} ${BUCKET}"

  echo "Running duplicity -v8 ${COMMAND}"
  $COMMAND

  if [ ! -z $EMAIL ]; then
    mail -s 'backup report' $EMAIL < $LOGNAME
  fi
}

list() {
    export PASSPHRASE
    /usr/bin/duplicity list-current-files --encrypt-key $ENCRYPT_KEY $BUCKET
}

restore() {
    export PASSPHRASE
  if [ $# = 2 ]; then
      /usr/bin/duplicity restore --file-to-restore --encrypt-key $ENCRYPT_KEY --log-file $LOGNAME $1 $BUCKET $2
  else
      /usr/bin/duplicity restore --file-to-restore --encrypt-key $ENCRYPT_KEY --log-file $LOGNAME $1 --time $2 $BUCKET $3
  fi
}

status() {
    export PASSPHRASE
    /usr/bin/duplicity collection-status --encrypt-key $ENCRYPT_KEY $BUCKET
}

sourcevars () {
    backuptype=$1
    FILE="${HOME}/backups/$backuptype"
    if [ -f $FILE ]; then
        source $FILE
        set -a
    else
        usage
        exit 1
    fi
}

if [ ! -f $LOGNAME ]; then
    touch $LOGNAME
fi

if [ "$1" = 'backup' ]; then
    sourcevars $2 || usage
    backup
elif [ "$1" = 'list' ]; then
    sourcevars $2 || usage
    list
elif [ "$1" = 'restore' ]; then
    if [ $# = 3 ]; then
        restore $2 $3
    else
        restore $2 $3 $4
    fi
elif [ "$1" = 'status' ]; then
    sourcevars $2 || usage
    status
else
    usage
fi

unset GD_APP_SPECIFIC_PW
unset ENCRYPT_KEY
unset PASSPHRASE
unset SOURCE
unset EXCLUDE
unset BUCKET
unset VOLSIZE
unset EMAIL
unset ARGS
