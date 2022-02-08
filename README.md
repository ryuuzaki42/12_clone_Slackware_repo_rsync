## clone_Slackware_repo_rsync
Clone Slackware mirror to a local folder using rsync

#### Use:
```sh
$ ./clone_Slackware_repo_JBs.sh
```

#### You can chose:
* the **mirror source**, the default is **rsync://slackware.uk/slackware**
* the **Slackware version** (e.g., **14.2**, **15.0**, **current**)
* the architecture (**32** or **64** bits)
* with **sorce code** or not
* with **md5 check** or not

#### Also can create a ISO file with:

```sh
$ ./create_ISO_without_some_packages_rsync_JBs.sh
```

You can create the ISO with all packages or remove the packages in **packagesList** from the final ISO
