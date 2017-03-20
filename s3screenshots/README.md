WIP.

This will ultimately probably end up in a new git repo.

### Installation

Copy `s3screenshots.sh.sample` to `s3screenshots.sh`.

Permissions should be:

`-rwx------  1 kortina  staff`

Add your AWS credentials, bucket name, and OS X username.

Copy `com.kortina.s3screenshots.plist` to a new file, replacing `kortina` with your OS X username.

Replace all instances of `kortina` in `com.kortina.s3screenshots.plist` with your OS X username.

Copy your plist file to `~/Library/LaunchAgents/`.

Permissions should be:

`-rw-r--r--  1 kortina  staff`

NB: since this uses OS X Notification Center, this must be a `LaunchAgent` not a `LaunchDaemon`.
