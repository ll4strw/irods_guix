## A bit-to-bit reproducible iRODS environment using GNU Guix

You can reproduce, bit-to-bit, my working iRODS v4.3.1 environment using
any of the commands below, regardless the OS you use and when you are
re-creating the environment

```
# install only irods-client-icommands v4.3.1
guix time-machine -C channels.scm -- shell irods-client-icommands@4.3.1 -L ll79

# install any packages specified in manifest.scm
guix time-machine -C channels.scm -- shell -m manifest.scm -L ll79
```

Should your GNU Guix installation not provide `guix shell`, then either
upgrade `guix` via `[sudo] guix pull` or use the `guix shell` predecessor
`guix environment`.

Sometimes, it is useful to hack the code of iRODS or the icommands to try
things out. Download the the source code, hack it and make a new <em>tgz</em>
archive. Finally, instruct GNU Guix to use <em>your</em> source code and not
the one coming from the package definition. You do this by either changing the
 pkg source definition in [irods.scm](ll79/irods.scm) or by using `guix build|package` transformation options, specifically `--with-source`.

More information at https://guix.gnu.org/ and https://debbugs.gnu.org/cgi/bugreport.cgi?bug=69751 