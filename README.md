# tozd/rdiff-backup-remote

<https://gitlab.com/tozd/docker/rdiff-backup-remote>

Available as:

- [`tozd/rdiff-backup-remote`](https://hub.docker.com/r/tozd/rdiff-backup-remote)
- [`registry.gitlab.com/tozd/docker/rdiff-backup-remote`](https://gitlab.com/tozd/docker/rdiff-backup-remote/container_registry)

## Image inheritance

[`tozd/base`](https://gitlab.com/tozd/docker/base) ← [`tozd/dinit`](https://gitlab.com/tozd/docker/dinit) ← [`tozd/mailer`](https://gitlab.com/tozd/docker/mailer) ← [`tozd/cron`](https://gitlab.com/tozd/docker/cron) ← `tozd/rdiff-backup-remote`

## Tags

- `2`: rdiff-backup 2.0.5
- `2`: rdiff-backup 2.0.5

## Volumes

- `/config`: Configuration files.
- `/backup`: Destination to where the backup is made.

## Variables

- `RDIFF_BACKUP_SOURCE`: Remote location from which to backup. Example: `user@example.com::/`
- `RDIFF_BACKUP_EXPIRE`: How long to keep past versions, provided as a string according to
  _time formats_ section of [rdiff-backup man page](http://www.nongnu.org/rdiff-backup/rdiff-backup.1.html).
  Default is 12M for 12 months.

## Description

Docker image providing daily backups with [rdiff-backup](http://www.nongnu.org/rdiff-backup/).
The main purpose is to backup remote machines to a local backup volume. Using rdiff-backup
gives you direct access to the latest version with past versions possible to be
reconstructed using rdiff-backup. Past changes are stored using reverse increments.

For local host backup instead of remote backup, consider
[tozd/rdiff-backup Docker image](https://gitlab.com/tozd/docker/rdiff-backup).

Use a config volume `/config` for config files and mount a directory to where
you want to store the backup to `/backup` volume.

If you want to configure only parts of the remote machine to be backed up, you can provide
a `/config/backup.list` file which is passed as `include-globbing-filelist` to rdiff-backup.
Example:

```
+ /etc
+ /home
+ /root
+ /var/log
+ /usr/local/bin
+ /usr/local/etc
+ /usr/local/sbin
- /
```

This file configures that `/etc`, `/home`, `/root` and parts of `/var` and `/usr` are backed up, while the
rest of the remote machine is ignored. Consult section _file selection_ of
[rdiff-backup man page](http://www.nongnu.org/rdiff-backup/rdiff-backup.1.html)
for more information on the format of this file.

For rdiff-backup to be able to connect to the remote machine, a SSH key pair should be generated:

```
$ ssh-keygen -t rsa -f backup_rsa
```

Do not set any password on key pair. This generates two files, `backup_rsa` and `backup_rsa.pub`.
You should add (append) contents of the `backup_rsa.pub` file to `~/.ssh/authorized_keys` file on the
remote machine for the user which you are planing to use to connect to the remote machine.
Put both generated files into `/config/.ssh` directory inside the `/config` volume.

You should also configure SSH client inside the Docker container to use the private
key for the connection to the remote machine. You can do this by creating a `config`
file inside `/config/.ssh`. For example:

```
Host example.com
    HostName example.com
    User user
    Port 22
    IdentityFile /config/.ssh/backup_rsa
```

Important is to configure `IdentityFile` to point to the private key file.

Moreover, you should create `known_hosts` file inside `/config/.ssh`, with
the fingerprint of the remote machine's public key:

```
$ ssh-keyscan example.com > known_hosts
```

`/config` volume should generally contain the following files:

```
/config/backup.list
/config/.ssh/backup_rsa
/config/.ssh/backup_rsa.pub
/config/.ssh/config
/config/.ssh/known_hosts
```

Remote machine should:

- Have rdiff-backup installed at `/usr/bin/rdiff-backup`.
- Have the user used to connect to the machine configured with sudo `NOPASSWD`
  so that rdiff-backup can obtain root permissions automatically.
- Have a SSH public key added to user's `~/.ssh/authorized_keys` file.

To get e-mails with any errors during daily backups, you have also to
configure `MAILTO`, `ADMINADDR`, and `REMOTES` environment variables
as described in [`tozd/mailer`](https://gitlab.com/tozd/docker/mailer)
and [`tozd/cron`](https://gitlab.com/tozd/docker/cron) Docker images.

## GitHub mirror

There is also a [read-only GitHub mirror available](https://github.com/tozd/docker-rdiff-backup-remote),
if you need to fork the project there.
