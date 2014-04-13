backups
=======

Tools for managing my backups

#@ What does this do?

This is Duptools, a backup system I wrote that wraps the Duplicity backup utility.

##@ What is Duplicity?
Duplicity is encrypted bandwidth-efficient backup using the rsync algorithm

Read all about it here: http://duplicity.nongnu.org/

## How do I use duptools?
```
  USAGE:

  ./duptools.sh backup type
  ./duptools.sh list type
  ./duptools.sh status type
  ./duptools.sh restore file [time] dest
  '
```

Where type is the type of backup environment you'd like to manage. Take environment.sample as an example backup type.

./duptools. backup environment.sample

### Scheduling backups

Install a crontab like duplicity_crontab like so

```
crontab -u $USER duplicity_crontab
```


