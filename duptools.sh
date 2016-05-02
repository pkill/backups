#!/bin/bash
# Backup script to wrap the duplicity suite
# Written by Alex Elman @_pkill 2014

DATE=`date +%F`
LOGNAME="/home/$USER/logs/duplicity.log.${DATE}"
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
    if [ -n "$EXCLUDE" ]; then
        EXCLUDE="--exclude $ROOT${EXCLUDE//,/ --exclude $ROOT}"
    fi
    if [ -n "$INCLUDE" ]; then
        INCLUDE="--include $ROOT${INCLUDE//,/ --include $ROOT}"
    fi

    # perform an incremental backup to root, include directories, exclude everything else, / as reference.
    COMMAND="/usr/bin/duplicity -v8 ${ENCRYPT_KEY:+--encrypt-key $ENCRYPT_KEY} --full-if-older-than 120D --num-retries 12 $ARGS --volsize ${VOLSIZE} ${INCLUDE} ${EXCLUDE} --log-file ${LOGNAME} ${ROOT} ${BUCKET}"

    echo "Running ${COMMAND}"
    $COMMAND

    if [ ! -z $EMAIL ]; then
        mail -s 'backup report' $EMAIL < $LOGNAME
    fi
}

list() {
    /usr/bin/duplicity list-current-files --encrypt-key $ENCRYPT_KEY $BUCKET
}

restore() {
    if [ $# = 2 ]; then
        /usr/bin/duplicity restore --file-to-restore --encrypt-key $ENCRYPT_KEY --log-file $LOGNAME $1 $BUCKET $2
    else
        /usr/bin/duplicity restore --file-to-restore --encrypt-key $ENCRYPT_KEY --log-file $LOGNAME $1 --time $2 $BUCKET $3
    fi
}

status() {
    /usr/bin/duplicity collection-status --encrypt-key $ENCRYPT_KEY $BUCKET
}

sourcevars () {
    backuptype=$1
    FILE="${HOME}/backups/envs/$backuptype"
    if [ -f $FILE ]; then
        set -a
        source $FILE
    else
        usage
        exit 1
    fi
}

if [ ! -f $LOGNAME ]; then
    touch $LOGNAME
fi

if [ "$1" == 'backup' ]; then
    set -a
    echo $EXCLUDE_LIST
    sourcevars $2
    backup
elif [ "$1" == 'list' ]; then
    sourcevars $2
    list
elif [ "$1" == 'restore' ]; then
    if [ $# = 3 ]; then
        restore $2 $3
    else
        restore $2 $3 $4
    fi
elif [ "$1" == 'status' ]; then
    sourcevars $2
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
