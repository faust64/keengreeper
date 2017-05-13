# Keengreeper

Keep git-hosted NodeJS projects up-to-date - shrinkwrap-capable.

AKA: GreenKeeper replacement. Following on the forced migration to GreenKeeper2,
and the late annouce that we would now be charged. Shame. Here is a rudimentary
drop-in replacement, that actually handles shrinkwrap.

## Dependencies

 * bash (installing & running NVM)
 * git, runtime user should have username & email configured
 * ssh key pair, setting up passwordless access to your repositories

## Introducing KeenGreeper

The `configure` script would allow you to create and manage a
leightweight database listing the repositories we would track, a cache of the
NodeJS dependencies involved and their last known versions, as well as a list of
modules whose updates we should ignore.
Running this pseudo-shell, type `h` or `help` to display the help menu.

The `updateModules` script should then iterate on previously registered
repositories, making sure they're working on the staging branch (if such exists,
master otherwise), pulling the lastest changes from git upstream, looking for
dependencies listed in the corresponding package.json, checking for known
updates. Whenever some new versions are detected, a branch is created,
your package.json gets updated. If a `node_shrinkwrap` folder exists, its
content would be updated as well. Eventually these new branches are pushed to
upstream for further verification (hopefully: CI).

Then, the `updateVulnerabilities` script may be used to iterate on previously
cached NodeJS modules, looking for potential vulnerabilities.

## Setup

We first need to set some variables. Look at `env.sample` for an example, you
would have to define:

 * `WORKDIR`, the folder we would keep cloned repositories into
 * `TMPDIR`, the folder we will be preparing our new commits into
 * `LOGDIR`, the folder we would store npm install and shrinkwrap logs into
 * `DBDIR`, the folder we would keep our internal configurations & caches into
 * `CACHETTL`, the amount of seconds a record from npmjs.org should be kept

Having set the proper values, make sure to install that file as
`/etc/keengreeper.conf`, to have it loaded automatically - otherwise, make sure
to source that environment file before running any of the enclosed scripts. Also
make sure the directories involved do exist and are writeable by the user that
will run our scripts.

Then, we can start registering repositories:

```
git/keengreeper$ ./configure
WARNING: nodejs-update-db absent, creating empty dataset
<$ type h or help for usage, q or quit to exit
$> a PeerioTechnologies/peerio-inferno
Cloning into 'peerio-inferno'...
remote: Counting objects: 3806, done.
remote: Compressing objects: 100% (72/72), done.
remote: Total 3806 (delta 18), reused 0 (delta 0), pack-reused 3734
Receiving objects: 100% (3806/3806), 56.82 MiB | 11.56 MiB/s, done.
Resolving deltas: 100% (1758/1758), done.
Checking connectivity... done.
<add$ NOTICE: added PeerioTechnologies/peerio-inferno
$> add git@mygitlab.example.com:DevOps/awesome-project
Cloning into 'peerio-shark'...
remote: Counting objects: 6732, done.
remote: Total 6732 (delta 0), reused 0 (delta 0), pack-reused 6731
Receiving objects: 100% (6732/6732), 66.28 MiB | 11.15 MiB/s, done.
Resolving deltas: 100% (3696/3696), done.
Checking connectivity... done.
<add$ NOTICE: added git@mygitlab.example.com:DevOps/awesome-project
$> quit
```

Note that we would be assuming the user running these scripts can already
passwordlessly clone and write to the repositories you would `add`. Using an SSH
key is recommended. Running these scripts from some un-attended station:
creating a separate git user with limited privileges is encourraged.

You may configure a couple modules that shouldn't be taken into consideration
by our update process, whatever the reasons:

```
git/keengreeper$ ./configure
$> i mailparser
<add$ NOTICE: added mailparser
$> ign basho-riak-client
<add$ NOTICE: added basho-riak-client
$> ignore sinon
<add$ NOTICE: added sinon
$> di mailparser
<del$ NOTICE: removed mailparser from ignored dependencies
$> li
basho-riak-client
sinon
$> quit
```

Finally, you can use the main script updating your projects dependencies:

```
git/keengreeper$ ./updateModules
refreshing npmjs local cache
processing peerio-server
skipping peerio-server::basho-riak-client - dependency registered to exclude file
skipping peerio-server::sinon - dependency registered to exclude file
processing desktop-update-proxy
staging q@desktop-update-proxy 1.4.1 -> 1.5.0
building staged changes for desktop-update-proxy
[chaos-q1.5.0 5c6edf6] chore(package): bump q to 1.5.0
 1 file changed, 1 insertion(+), 1 deletion(-)
done
```

Being sure our magic works, you may consider setting up some cron job:

```
(
    crontab -l
    echo "30 */6 * * * `pwd`/updateModules >>log/cron.log 2>&1"
    echo "45 4 * * * `pwd`/updateVulnerabilities >>log/snyk-cron.log 2>&1"
) | crontab -
```
