#!/usr/bin/env bash
set -Eeuo pipefail

COIN_DAEMON="yerbasd"
COIN_FOLDER="yerbas-build"
COIN_CONF_FOLDER=".yerbascore"
COIN_CONF_FILE="yerbas.conf"
COIN_NAME="YERBAS"
COIN_CLI="yerbas-cli"
COIN_PORT="15420"
YERB_REPO="The-Yerbas-Endeavor/yerbas"
BOOTSTRAP_REPO="The-Yerbas-Endeavor/YERB-Bootstrap"
LOG_FILE="$HOME/.yerbas-installer.log"

YG='\033[0;32m'
CN='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

INS_TYPE=""
PC=2
BS=2
AC=2
RPCPORT=""
RPCPASSWORD=""
RPCUSER=""
NODE_IP=""
BLS_SECRET=""
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

trap 'echo -e "${RED}Installer failed on line $LINENO. See $LOG_FILE.${CN}"' ERR

log() {
    printf '[%s] %s\n' "$(date -Is)" "$*" >> "$LOG_FILE"
}

die() {
    echo -e "${RED}ERROR: $*${CN}" >&2
    log "ERROR: $*"
    exit 1
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "Run this installer with sudo: sudo bash install.sh"
    fi
}

title() {
    clear
    echo -e "${YG}"
    echo "YYYYYYY       YYYYYYYEEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR   BBBBBBBBBBBBBBBBB               AAA                 SSSSSSSSSSSSSSS"
    echo " Y:::::Y     Y:::::Y E::::::::::::::::::::E R::::::::::::::::R  B::::::::::::::::B             A:::A              SS:::::::::::::::S"
    echo "  Y:::::Y   Y:::::Y  E::::::EEEEEEEEE::::E R::::::RRRRRR:::::R B::::::BBBBBB:::::B           A:::::A            S:::::SSSSSS::::::S"
    echo "   Y:::::Y Y:::::Y   E:::::E       EEEEEE R:::::R     R:::::R B:::::B     B:::::B         A:::::::A           S:::::S     SSSSSSS"
    echo "    Y:::::Y:::::Y    E::::::EEEEEEEEEE    R::::RRRRRR:::::R   B::::BBBBBB:::::B       A:::::A A:::::A         S::::SSSS"
    echo "     Y:::::::::Y     E:::::::::::::::E     R:::::::::::::RR    B:::::::::::::BB       A:::::A   A:::::A         SS::::::SSSSS"
    echo "      Y:::::::Y      E::::::EEEEEEEEEE     R::::RRRRRR:::::R   B::::BBBBBB:::::B     A:::::AAAAAAAAA:::::A          SSS::::::::SS"
    echo "       Y:::::Y       E:::::E               R::::R     R:::::R  B::::B     B:::::B  A:::::::::::::::::::::A                S:::::S"
    echo "       Y:::::Y       E::::::EEEEEEEE:::::E R:::::R     R:::::R B:::::BBBBBB::::::BA:::::A             A:::::A  SSSSSSS     S:::::S"
    echo "       YYYYYYY       EEEEEEEEEEEEEEEEEEEEE RRRRRRR     RRRRRRR BBBBBBBBBBBBBBBBB AAAAAAA             AAAAAAA SSSSSSSSSSSSSSS"
    echo -e "${CN}"
    echo "     $COIN_NAME combined server and Smartnode installer"
    echo
}

prompt_yes_no() {
    local prompt="$1"
    local answer
    while true; do
        read -r -p "$prompt [y/N]: " answer
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
            *) echo "Please enter y or n." ;;
        esac
    done
}

install_dependencies() {
    echo -e "${CYAN}Installing required dependencies and server protections...${CN}"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade -y
    apt-get install -y ca-certificates curl jq unzip wget nano htop pwgen \
        fail2ban ufw util-linux lsb-release
    systemctl enable --now fail2ban

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow OpenSSH
    ufw allow "${COIN_PORT}/tcp"
    ufw --force enable

    install -d -m 0755 /etc/fail2ban/jail.d
    cat >/etc/fail2ban/jail.d/yerbas-sshd.local <<'EOF'
[sshd]
enabled = true
port = ssh
maxretry = 3
EOF
    systemctl restart fail2ban
}

create_swap() {
    local size_gb=4
    if swapon --show=NAME --noheadings | grep -qx '/swapfile'; then
        echo "Existing /swapfile is active; leaving it unchanged."
        return
    fi
    if [[ -e /swapfile ]]; then
        echo "Existing /swapfile found; leaving it unchanged."
        return
    fi
    echo "Creating ${size_gb}G swap file..."
    fallocate -l "${size_gb}G" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -qF '/swapfile none swap sw 0 0' /etc/fstab ||
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
}

valid_username() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]
}

create_server_users() {
    local count username password i
    while true; do
        read -r -p "How many additional server users should be created? [0]: " count
        count="${count:-0}"
        [[ "$count" =~ ^[0-9]+$ ]] && break
        echo "Enter a whole number."
    done

    for ((i=1; i<=count; i++)); do
        while true; do
            read -r -p "Username ${i}/${count}: " username
            valid_username "$username" || { echo "Use a valid lowercase Linux username."; continue; }
            id "$username" &>/dev/null && { echo "User already exists."; continue; }
            break
        done

        while true; do
            read -r -s -p "Password for $username: " password
            echo
            [[ -n "$password" ]] || { echo "Password cannot be empty."; continue; }
            read -r -s -p "Confirm password: " confirmation
            echo
            [[ "$password" == "$confirmation" ]] || { echo "Passwords do not match."; continue; }
            break
        done

        useradd -m -s /bin/bash "$username"
        printf '%s:%s\n' "$username" "$password" | chpasswd
        echo "Created user: $username"
        unset password confirmation
    done
}

select_install_type() {
    echo "1) Install a new $COIN_NAME Smartnode"
    echo "2) Update an existing $COIN_NAME Smartnode"
    while true; do
        read -r -p "Select option [1-2]: " choice
        case "$choice" in
            1) INS_TYPE="new"; break ;;
            2) INS_TYPE="update"; break ;;
            *) echo "Invalid selection." ;;
        esac
    done
}

detect_platform() {
    ARCH="$(uname -m)"
    VERSION_ID="$(. /etc/os-release && echo "$VERSION_ID")"
    case "$ARCH" in
        x86_64|aarch64) ;;
        *) die "Unsupported architecture: $ARCH" ;;
    esac
    case "$VERSION_ID" in
        22.04|24.04|26.04) ;;
        *) die "Unsupported Ubuntu version: $VERSION_ID (supported: 22.04, 24.04, 26.04)" ;;
    esac
    echo "Detected Ubuntu $VERSION_ID on $ARCH."
}

github_latest_asset() {
    local repo="$1"
    local regex="$2"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" |
        jq -er --arg regex "$regex" \
          '.assets[] | select(.name | test($regex; "i")) | .browser_download_url' |
        head -n1
}

resolve_downloads() {
    local wallet_regex
    case "$ARCH:$VERSION_ID" in
        x86_64:22.04) wallet_regex='ubuntu-22\.04-x86-release\.(tar\.gz|tgz)$' ;;
        x86_64:24.04) wallet_regex='ubuntu-24\.04-x86-release\.(tar\.gz|tgz)$' ;;
        x86_64:26.04) wallet_regex='ubuntu-26\.04-x86-release\.(tar\.gz|tgz)$' ;;
        aarch64:*) wallet_regex='ubuntu-26\.04-arm64-release\.(tar\.gz|tgz)$' ;;
    esac

    WALLET_URL="$(github_latest_asset "$YERB_REPO" "$wallet_regex")" ||
        die "No matching wallet archive found in the latest Yerbas release."

    COIN_VERSION_NAME="$(curl -fsSL "https://api.github.com/repos/${YERB_REPO}/releases/latest" | jq -er '.tag_name')"

    if (( PC == 1 )); then
        POWCACHE_URL="$(github_latest_asset "$BOOTSTRAP_REPO" '(^|/)powcache\.dat$|powcache\.dat$')" ||
            die "powcache.dat was not found in the latest bootstrap release."
    fi

    if (( BS == 1 )); then
        BOOTSTRAP_URL="$(github_latest_asset "$BOOTSTRAP_REPO" '^bootstrap(-index)?\.zip$')" ||
            die "No bootstrap ZIP was found in the latest YERB-Bootstrap release."
        BOOTSTRAP_NAME="${BOOTSTRAP_URL##*/}"
    fi
}

stop_existing_node() {
    [[ "$INS_TYPE" == "update" ]] || return
    local cli="$TARGET_HOME/$COIN_FOLDER/$COIN_CLI"
    if [[ -x "$cli" ]]; then
        sudo -u "$TARGET_USER" "$cli" stop || true
        sleep 5
    fi
    rm -rf "$TARGET_HOME/$COIN_FOLDER"
}

download_node() {
    local temp_dir
    temp_dir="$(mktemp -d)"
    echo "Downloading $COIN_NAME $COIN_VERSION_NAME..."
    curl -fL --retry 3 "$WALLET_URL" -o "$temp_dir/wallet.tar.gz"
    tar -xzf "$temp_dir/wallet.tar.gz" -C "$temp_dir"
    rm -rf "$TARGET_HOME/$COIN_FOLDER"

    local found
    found="$(find "$temp_dir" -maxdepth 3 -type f -name "$COIN_DAEMON" -printf '%h\n' | head -n1)"
    [[ -n "$found" ]] || die "$COIN_DAEMON was not found in the downloaded archive."
    mv "$found" "$TARGET_HOME/$COIN_FOLDER"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/$COIN_FOLDER"
    rm -rf "$temp_dir"
}

download_optional_data() {
    local data_dir="$TARGET_HOME/$COIN_CONF_FOLDER"
    install -d -o "$TARGET_USER" -g "$TARGET_USER" "$data_dir"

    if (( PC == 1 )); then
        echo "Downloading latest powcache.dat..."
        curl -fL --retry 3 "$POWCACHE_URL" -o "$data_dir/powcache.dat"
        chown "$TARGET_USER:$TARGET_USER" "$data_dir/powcache.dat"
    fi

    if (( BS == 1 )); then
        echo "Downloading latest bootstrap release..."
        rm -rf "$data_dir/assets" "$data_dir/blocks" "$data_dir/chainstate" \
               "$data_dir/evodb" "$data_dir/llmq"
        curl -fL --retry 3 "$BOOTSTRAP_URL" -o "$data_dir/$BOOTSTRAP_NAME"
        unzip -q "$data_dir/$BOOTSTRAP_NAME" -d "$data_dir/bootstrap-extract"

        local source_dir="$data_dir/bootstrap-extract"
        if [[ -d "$source_dir/bootstrap" ]]; then
            source_dir="$source_dir/bootstrap"
        fi
        cp -a "$source_dir"/. "$data_dir"/
        rm -rf "$data_dir/bootstrap-extract" "$data_dir/$BOOTSTRAP_NAME"
        chown -R "$TARGET_USER:$TARGET_USER" "$data_dir"
    fi
}

configure_node() {
    [[ "$INS_TYPE" == "new" ]] || return
    read -r -p "RPC user [yerbasuser1]: " RPCUSER
    RPCUSER="${RPCUSER:-yerbasuser1}"
    read -r -s -p "RPC password [generate automatically]: " RPCPASSWORD
    echo
    RPCPASSWORD="${RPCPASSWORD:-$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)}"
    read -r -p "RPC port [9494]: " RPCPORT
    RPCPORT="${RPCPORT:-9494}"
    read -r -p "Node public IP: " NODE_IP
    read -r -s -p "BLS secret key: " BLS_SECRET
    echo

    install -d -o "$TARGET_USER" -g "$TARGET_USER" "$TARGET_HOME/$COIN_CONF_FOLDER"
    cat >"$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE" <<EOF
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPCPORT
EOF
    [[ -n "$NODE_IP" ]] && {
        echo "bind=$NODE_IP" >>"$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE"
        echo "externalip=$NODE_IP:$COIN_PORT" >>"$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE"
    }
    [[ -n "$BLS_SECRET" ]] &&
        echo "smartnodeblsprivkey=$BLS_SECRET" >>"$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE"
    chmod 600 "$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/$COIN_CONF_FOLDER/$COIN_CONF_FILE"
}

install_systemd_service() {
    local service="/etc/systemd/system/yerbasd.service"
    cat >"$service" <<EOF
[Unit]
Description=Yerbas Core daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=$TARGET_USER
Group=$TARGET_USER
WorkingDirectory=$TARGET_HOME/$COIN_FOLDER
ExecStart=$TARGET_HOME/$COIN_FOLDER/$COIN_DAEMON -daemon
ExecStop=$TARGET_HOME/$COIN_FOLDER/$COIN_CLI stop
Restart=on-failure
RestartSec=10
TimeoutStopSec=120
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    if (( AC == 1 )); then
        systemctl enable yerbasd
    else
        systemctl disable yerbasd 2>/dev/null || true
    fi
}

start_daemon() {
    echo "Starting $COIN_NAME daemon..."
    systemctl restart yerbasd
    sleep 5
    systemctl --no-pager --full status yerbasd || true
}

summary() {
    echo
    echo -e "${YG}INSTALLATION FINISHED${CN}"
    echo "Wallet version: $COIN_VERSION_NAME"
    echo "Node user: $TARGET_USER"
    echo "Data directory: $TARGET_HOME/$COIN_CONF_FOLDER"
    echo "Service: systemctl status yerbasd"
    echo "Logs: journalctl -u yerbasd -f"
    echo
    echo "The txreindex prompt has been removed; the daemon starts normally."
}

main() {
    require_root
    : >"$LOG_FILE"
    title

    install_dependencies
    create_swap
    create_server_users

    select_install_type
    detect_platform

    prompt_yes_no "Download the latest PoW cache?" && PC=1 || PC=2
    prompt_yes_no "Download the latest bootstrap?" && BS=1 || BS=2
    prompt_yes_no "Start the daemon automatically at boot?" && AC=1 || AC=2

    resolve_downloads
    stop_existing_node
    download_node
    download_optional_data
    configure_node
    install_systemd_service
    start_daemon
    summary
}

main "$@"
