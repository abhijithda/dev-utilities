# dev-utilities

Utilities used during development and testing.

## cpdiff

cpdiff - copy files with diff from a git repo on dev system to the current system.

Create a cpdiff.conf.json with dev_system, repo_path and other info:

```json
# cat cpdiff.conf.json
{
  "dev_system": "abhijith@10.81.78.230",
  "repo_path": "/home/abhijith/workspace/sfnas",
  "replace_paths": [
    {
      "source": "test",
      "destination": "/tmp/"
    }
    {
      "source": "unix/common",
      "destination": "/opt/VRTSnas"
    },
  ]
}
```

To specify a different conf file, set env variable `CPDIFF_JSON_CONF_FILE`.
I.e., `CPDIFF_JSON_CONF_FILE=<conf-file.json>`

Ex: CPDIFF_JSON_CONF_FILE="cpdiff.conf.json"

### Sample output `cpdiff`

```bash
@abhijithda ➜ /workspaces/dev-utilities (master) $ ./cpdiff 
WARNING: CPDIFF_JSON_CONF_FILE ENV variable not set.
Assuming default config file.
To customize, set CPDIFF_JSON_CONF_FILE=<conf-file.json>
CPDIFF_JSON_CONF_FILE="cpdiff.conf.json"

./cpdiff: line 79: cd: /workspace/: No such file or directory
Copying file: cpdiff...
Destination path: cpdiff
Copying file: cpdiff.conf.json...
Destination path: cpdiff.conf.json
Copying file: unix/common/test/ab...
Destination path: unix/common//tmp/ab
unix/common/test/ab
@abhijithda ➜ /workspaces/dev-utilities (master) $ 
```
