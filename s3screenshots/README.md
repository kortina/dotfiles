### Installation

```bash
# Either source your `.sh_secrets` with the
# your AWS credentials, bucket name, and OS X username to `s3screenshots.sh`
# Or, copy the template:
test -e s3screenshots.sh || cp s3screenshots.sh.sample s3screenshots.sh
chmod 700 s3screenshots.sh
vim s3screenshots.sh
```

In order to run `s3screenshots.sh` with `Full Disk Access` in OS X,
you now need to use the `s3screenshots` binary wrapper
(compiled from `s3screenshots.go`).
Add this binary to the **Full Disk Access** list in
**System Preferences > Security & Privacy > Full Disk Access**.

![grant full disk access permission](https://4rk.s3.amazonaws.com/_/s3-screenshots.png)

Then, install the LaunchAgent:

```bash
plist="com.`id -u -n`.s3screenshots.plist"

# If your plist does not exist, create it by copying
# com.kortina.s3screenshots.plist
# and replacing all instances of 'kortina' with your username.
# This command will do the copy + replace:
test -e $plist || sed "s/kortina/`id -u -n`/g" com.kortina.s3screenshots.plist > $plist

# mkdir if nec:
mkdir -p "$HOME/Library/LaunchAgents/"

# Copy to your LaunchAgents:
agent="$HOME/Library/LaunchAgents/$plist"
cp $plist $agent
chown "`id -u -n`:staff" $agent
chmod 644 $agent

# Start the agent:
launchctl load $agent

# To stop the agent:
# launchctl unload $agent

# Touch the log file
touch $HOME/Library/Logs/s3screenshots.log
# Debug using the logs:
tail -f $HOME/Library/Logs/s3screenshots.log

# If you see errors about boto not installed, do:
mkdir ~/tmp
cd ~/tmp
pyenv local system
sudo easy_install boto
sudo easy_install watchdog
```

NB: since this uses OS X Notification Center, this must be a `LaunchAgent` not a `LaunchDaemon`.

If things are not working, you can check syslog for errors:

```bash
tail -f /var/log/system.log
```
