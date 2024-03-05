## A bit-to-bit reproducible iRODS environment using GNU Guix

You can reproduce, bit-to-bit, my working iRODS v4.3.1 environment using
any of the commands below regardless the OS you use and when you are
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


More information at https://guix.gnu.org/