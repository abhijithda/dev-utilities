# RPM commands

## F.A.Q.s

### To know the package owning (or providing) an already installed file

```bash
rpm -qf ${myfilename}
```

### To extract the contents of the RPM

```bash
rpm2cpio ${package.rpm} | cpio -idmv
```
