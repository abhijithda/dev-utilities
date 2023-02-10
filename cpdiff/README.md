# cpdiff

cpdiff - copy files with diff from a git repo on dev system to the current system.

## Prerequisites

Passwordless ssh setup between dev system (where your git source repository is present) to the current test system.

To setup passwordless ssh, you could run `ssh-copy-id ${user}@${dev_system}`.

## Configuration

Create a cpdiff.conf.json with dev_system, repo_path and replace_path_patterns info as shown below:

```json
# cat cpdiff.conf.json
{
  "dev_system": "abhijith@10.81.78.230",
  "repo_path": "/workspace/",
  "replace_path_patterns": [
    {
      "source": "test",
      "destination": "/tmp"
    },
    {
      "source": "unix/common",
      "destination": "/opt/VRTSnas"
    }
  ]
}
```

### Custom config file - `CPDIFF_JSON_CONF_FILE`

To specify a custom configuration file, set env variable `CPDIFF_JSON_CONF_FILE`.
I.e., `CPDIFF_JSON_CONF_FILE=<conf-file.json>`

Ex: CPDIFF_JSON_CONF_FILE="cpdiff.conf.json"

## Sample output `cpdiff`

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
