## clone_Slackware_repo_rsync
Clone Slackware mirror to a local folder using rsync

#### Default mirror : rsync://ftp.osuosl.org/slackware

#### Use:
```sh
$ ./clone_Slackware_repo_JBs.sh
```

#### You can chose:
* the **Slackware version** (e.g., **14.1**, **14.2**, **current**)
* the architecture (**32** or **64** bits)
* with **sorce code** or not
* with **md5 checksum** or not

#### Also can create a ISO file with:

```sh
$ ./create_ISO_without_some_packages_rsync_JBs.sh
```
You can create the ISO with all packages or remove all the packages in **packagesList** from the final ISO
