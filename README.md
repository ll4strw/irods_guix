## A bit-to-bit reproducible iRODS environment using GNU Guix

```
guix time-machine -C channels.scm -- shell irods-client-icommands@4.3.1 -L ll79
```

Should your GNU Guix installation not provide `guix shell`, then either
upgrade `guix` via `[sudo] guix pull` or use the `guix shell` predecessor
`guix environment`.