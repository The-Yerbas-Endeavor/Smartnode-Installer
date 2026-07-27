# Yerbas Smartnode Installer

This repository now uses one combined installer. It installs the server dependencies first, optionally creates additional Linux users, and then installs or updates the Yerbas Smartnode.

## Run

```bash
wget -q https://raw.githubusercontent.com/The-Yerbas-Endeavor/Smartnode-Installer/main/install.sh
sudo bash install.sh
```

The installer supports Ubuntu 22.04, 24.04, and 26.04 on x86_64, plus the available ARM64 Yerbas build.

## Included behavior

- Installs required packages, UFW, and Fail2ban first
- Creates a 4 GB swap file when `/swapfile` is not already present
- Prompts for the number of additional Linux users to create
- Prompts for each new user's username and password
- Installs or updates the Yerbas Smartnode
- Retrieves the wallet from the latest Yerbas release
- Retrieves `powcache.dat` and `bootstrap.zip` or `bootstrap-index.zip` from the latest YERB-Bootstrap release
- Uses a systemd service for daemon startup
- Starts normally without a txreindex prompt

The old `firstrun.sh` script is no longer required.
