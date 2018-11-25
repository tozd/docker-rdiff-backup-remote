Docker image providing backups with [rdiff-backup](http://www.nongnu.org/rdiff-backup/).
The main purpose is to backup remote machines to a local backup volume. Using rdiff-backup
gives you direct access to the latest version with past versions possible to be
reconstructed using rdiff-backup. Past changes are stored using reverse increments.
Backup runs daily.

For local host backup instead of remote backup, consider
[tozd/rdiff-backup Docker image](https://github.com/tozd/docker-rdiff-backup).

Use a config volume `/config` for config files and mount a directory to where
you want to store the backup to `/backup` volume.

If you want to configure only parts of the remote machine to be backed up, you can provide
a `/config/backup.list` file which is passed as `include-globbing-filelist` to rdiff-backup.
Example:

```
+ /etc
+ /home
+ /root
+ /backups
+ /log
+ /usr/local/bin
+ /usr/local/etc
+ /usr/local/sbin
- /
```

This file configures that `/etc`, `/home`, `/root` and parts of `/var` are backed up, while the
rest of the remote machine is ignored. Consult section *file selection* of
[rdiff-backup man page](http://www.nongnu.org/rdiff-backup/rdiff-backup.1.html)
for more information on the format of this file.

Used environment variables:
 * `RDIFF_BACKUP_SOURCE` – remote location from which to backup;
   example: `user@example.com::/`
 * `RDIFF_BACKUP_EXPIRE` – how long to keep past versions, provided as a string according to
   *time formats* section of [rdiff-backup man page](http://www.nongnu.org/rdiff-backup/rdiff-backup.1.html);
   default: `12M` for 12 months

For rdiff-backup to be able to connect to the remote machine, a SSH key pair should be generated:

```
$ ssh-keygen -t rsa -f backup_rsa
```

Do not set any password on key pair. This generates two files, `backup_rsa` and `backup_rsa.pub`.
You should add contents of the `backup_rsa.pub` file to `~/.ssh/authorized_keys` file on the
remote machine for the user which you are planing to use to connect to the remote machine.

You should also configure SSH client inside the Docker container to use the private
key for the connection to the remote machine. You can do this by creating a `config`
file. For example:

```
Host example.com
    HostName example.com
    User user
    Port 22
    IdentityFile /config/.ssh/backup_rsa
```

`/config` volume should generally contain the following files:

```
/config/backup.list
/config/.ssh/backup_rsa
/config/.ssh/backup_rsa.pub
/config/.ssh/config
```

Remote machine should:
 * Have rdiff-backup installed at `/usr/bin/rdiff-backup`.
 * Have the user used to connect to the machine configured with sudo `NOPASSWD`
   so that rdiff-backup can obtain root permissions automatically.
 * Have a SSH public key added to user's `~/.ssh/authorized_keys` file.
