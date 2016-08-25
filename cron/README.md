USE CRON TO DOWNLOAD AND REMOVE RESULTS FROM SUBMIT NODE
========================================================
`cron` is a simple job scheduler that exists on just about every \*nix
system (unverified assumption). You can use it to automatically repeat a
task at regular intervals/times of day. You may want to use it to check
for new data on the submit node and pull it down to your machine.

You might want to do this because:
- Data on the submit node is not backed up.
- You have a disk quota on the submit node.
- You cannot work with the results on the submit node, so you are going
  to need to download them at some point, anyway.

This is done with `ssh` and `rsync`, which itself establishes and `ssh`
connection to transfer files between the remote server (submit node) and
your computer.

Problems with `cron`
--------------------
Unfortunately, `cron` does not execute in the same environment you are
in as you work at the terminal interactively. Many variables are not
defined, and there are just a lot of things that it cannot see. As a
general rule, you should use complete absolute paths for just about
everything while using `cron`. This includes any of the standard console
commands, including `ssh` and `rsync`. Use `which ssh` to determine the
full path to where the `ssh` command actually resides on your machine,
for example.

`cron` also does not know where to look for your `ssh` private key file,
so you will need to explicitly tell `ssh` _and_ `rsync` where to find
it.

Finally---and this is truly frustrating---`cron` can not tell if you
have entered your `ssh` keychain passcode during the current session,
because `cron` actually runs in its own session where the passcode has
not been answered. Furthermore, because `cron` is not interactive, the
system will not prompt you for a passcode when required, for example
when `ssh` is called by a `cron` job.

Solution
--------
To use `ssh` and `rsync` wth `cron`, you will need to create an `ssh`
private key that does not have a passcode associated with it:

```
ssh-keygen -t rsa -f ~/.ssh/id_rsa_cron
[enter without entering a passcode]
[enter to repeat no passcode]
```

Then point `ssh` to this identity file like so:

```
/usr/bin/ssh -i /home/<username>/.ssh/id_rsa_cron <user>@<host> [cmd to execute]
```

or, in the context of `rsync`

```
/usr/bin/rsync -avz -e "/usr/bin/ssh -i /home/<username>/.ssh/id_rsa_cron" [options]
<user>@<host>:<source/dir> <target/dir/>
```

Configuring your `crontab`
--------------------------
You will have to read up a bit on `crontab` online, but this may be
enough to get started. 

```
crontab -e
```

Is how you will interact with your person `crontab` file. Always run
this command whenever you want to modify your `crontab`. Your contab is
where you list the commands you want to run and when you want to run
then.

`crontab -e` will generate a file for you with some useful notes at the
top that try to give you enough information about the syntax to dive
right in. Here is an example, that runs each of the three files in this
directory once every 15 minutes.

```
*/15 * * * *
/home/chris/src/Manchester_SoundPicture/cron/download_roi_data >>
/home/chris/download_roi_data.log 2>&1
*/15 * * * *
/home/chris/src/Manchester_SoundPicture/cron/download_visvis_tune_data
/home/chris/download_visvis_tune_data.log 2>&1
*/15 * * * *
/home/chris/src/Manchester_SoundPicture/cron/download_semvis_tune_data
/home/chris/download_semvis_tune_data.log 2>&1
```

Use flock to prevent duplicate jobs
-----------------------------------
It might happen that your `cron` job runs long enough that it is still
running when it is time for the job to be run again. This is generally
something you do not want to happen. One way to prevent it is to issue
your primary command using `flock`, which will generate a maintain
lockfiles for you. In short, the lockfile will contain the process ID of
the job `cron` launches. If `cron` tries to launch the job and the
lockfile already exists, `flock` will check the process ID in the lock
file and see if that process is still running. If it is, then the
command will not be issued again. Simple. I have used flock in the
scripts in this directory.

Conclusion
----------
`cron` is useful, but very quirky and hard to get a handle on at first.
Once you have `cron` job scheduled and working properly, it will then be
easy to tweak for future needs, but that first time is bound to be a
headache. Persevere, you will produce a reliable automated solution for
your data storage and keep your submit node clean.
