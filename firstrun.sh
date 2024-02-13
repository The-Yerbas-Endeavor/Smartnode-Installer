
YG='\033[0;32m'
CN='\033[0m'
RED='\033[0;31m'
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m" 
PURPLE="\033[0;35m"
BLINKRED='\033[1;31;5m'
NC='\033[0m'
STOP='\e[0m'
ADDUSER=''

function adduser(){
    echo -e "${YELLOW}Add a new user{NC}" && sleep 1
    read -p "     New User Name: " ADDUSER
    adduser $ADDUSER
}

function create_swap() {
  echo -e "${YELLOW}Creating swap if none detected...${NC}" && sleep 1
  if ! grep -q "swapfile" /etc/fstab; then
    if whiptail --yesno "No swapfile detected would you like to create one?" 8 54; then
      sudo fallocate -l 4G /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
      echo -e "${YELLOW}Created ${SEA}4G${YELLOW} swapfile${NC}"
    fi
  fi
  sleep 1
}

function install_packages() { 
        echo -e "     ${CYAN}Install firts time packages? Need's sudo privlages to do so!"
        echo "       1) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        1) PACK=1;;
        2) PACK=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;packages;
        esac
        echo " "
        if [ $PACK == 1 ]
                then
        echo -e "${YELLOW}Installing Packages...${NC}"
                sudo apt-get update -y
                sudo apt-get upgrade -y
                sudo apt-get install nano htop pwgen figlet unzip curl jq fail2ban -y
                sudo apt install ufw -y
                sudo ufw default deny incoming
                sudo ufw default allow outgoing
                sudo ufw allow ssh
                sudo ufw allow 15420/tcp
                sudo ufw enable
                echo "[sshd]
                enabled = true
                port = 22
                filter = sshd
                logpath = /var/log/auth.log
                maxretry = 3" | sudo tee -a /etc/fail2ban/jail.local
                echo -e "${YELLOW}Packages complete...Will now reboot the system${NC}"
                sleep 10
                sudo reboot
          else
                echo -n "     Skipping Packages update"
                dots
                echo -e "${YELLOW}Skipped.${CN}"
        fi
}

#MAIN
install_packages
create_swap
