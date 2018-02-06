# config

## install

* remote

```
curl -sL https://raw.githubusercontent.com/ciiqr/config/master/scripts/install | sudo bash -s -- --roles "frontend sublime development"
```

* local (change path to wherever you've cloned to)

```
sudo ~/projects/config/scripts/install --roles "frontend sublime development"
```

## update

```
sudo /config/scripts/provision
```

## windows
### compatibility
* uses several PowerShell 5 features
* this installs salt, automatically, however you may need to install the most recent pre-release version (ie. oxygen) manually if you experience bugs [building-and-developing-on-windows](https://docs.saltstack.com/en/latest/topics/installation/windows.html#building-and-developing-on-windows)

### install (via powershell)

* remote
```
Start-Process powershell -ArgumentList '-NoProfile -NoExit -InputFormat None -Command "iex ((New-Object System.Net.WebClient).DownloadString(\"https://raw.githubusercontent.com/ciiqr/config/master/scripts/install.ps1\"))"' -verb RunAs; exit
```

* local (change path to wherever you've clone to)
```
# open an admin powershell window to wherever you cloned to
# TODO: need to update this for supplying -Roles param...
Start-Process powershell -ArgumentList '-NoExit -command "cd C:\Users\william\Dropbox\Projects\config"' -verb RunAs; exit

# install linked to cloned path
& .\scripts\install.ps1 -Roles frontend,development,gaming
```

### update (via powershell)
```
Start-Process powershell -ArgumentList '-NoProfile -NoExit -InputFormat None -File C:\config\scripts\provision.ps1' -verb RunAs; exit
```
