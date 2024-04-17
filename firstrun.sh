COIN_NAME='YERBAS'
File=".err.log"
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


function yerbas_title() {
        echo -e "${YG}YYYYYYY       YYYYYYYEEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR   BBBBBBBBBBBBBBBBB               AAA                 SSSSSSSSSSSSSSS   "
        echo "Y:::::Y       Y:::::YE::::::::::::::::::::ER::::::::::::::::R  B::::::::::::::::B             A:::A              SS:::::::::::::::S  "
        echo "Y:::::Y       Y:::::YE::::::::::::::::::::ER::::::RRRRRR:::::R B::::::BBBBBB:::::B           A:::::A            S:::::SSSSSS::::::S  "
        echo "Y::::::Y     Y::::::YEE::::::EEEEEEEEE::::ERR:::::R     R:::::RBB:::::B     B:::::B         A:::::::A           S:::::S     SSSSSSS  "
        echo "YYY:::::Y   Y:::::YYY  E:::::E       EEEEEE  R::::R     R:::::R  B::::B     B:::::B        A:::::::::A          S:::::S              "
        echo "   Y:::::Y Y:::::Y     E:::::E               R::::R     R:::::R  B::::B     B:::::B       A:::::A:::::A         S:::::S              "
        echo "    Y:::::Y:::::Y      E::::::EEEEEEEEEE     R::::RRRRRR:::::R   B::::BBBBBB:::::B       A:::::A A:::::A         S::::SSSS           "
        echo "     Y:::::::::Y       E:::::::::::::::E     R:::::::::::::RR    B:::::::::::::BB       A:::::A   A:::::A         SS::::::SSSSS      "
        echo "      Y:::::::Y        E:::::::::::::::E     R::::RRRRRR:::::R   B::::BBBBBB:::::B     A:::::A     A:::::A          SSS::::::::SS    "
        echo "       Y:::::Y         E::::::EEEEEEEEEE     R::::R     R:::::R  B::::B     B:::::B   A:::::AAAAAAAAA:::::A            SSSSSS::::S   "
        echo "       Y:::::Y         E:::::E               R::::R     R:::::R  B::::B     B:::::B  A:::::::::::::::::::::A                S:::::S  "
        echo "       Y:::::Y         E:::::E       EEEEEE  R::::R     R:::::R  B::::B     B:::::B A:::::AAAAAAAAAAAAA:::::A               S:::::S  "
        echo "       Y:::::Y       EE::::::EEEEEEEE:::::ERR:::::R     R:::::RBB:::::BBBBBB::::::BA:::::A             A:::::A  SSSSSSS     S:::::S  "
        echo "    YYYY:::::YYYY    E::::::::::::::::::::ER::::::R     R:::::RB:::::::::::::::::BA:::::A               A:::::A S::::::SSSSSS:::::S  "
        echo "    Y:::::::::::Y    E::::::::::::::::::::ER::::::R     R:::::RB::::::::::::::::BA:::::A                 A:::::AS:::::::::::::::SS   "
        echo -e "    YYYYYYYYYYYYY    EEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRRBBBBBBBBBBBBBBBBBAAAAAAA                   AAAAAAASSSSSSSSSSSSSSS     ${CN}"


        echo ""
        echo ""
        echo "     $COIN_NAME Smartnode setup first run package installer script"
        echo ""
        rm .err.log &>> ~/.err.log
        touch ~/.err.log

}

function dots(){
        sleep 0.5
        read -t 0.25 -p " ."
        read -t 0.25 -p "."
        read -t 0.25 -p "."
        read -t 0.25 -p ". "
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
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install nano htop pwgen figlet unzip curl jq fail2ban -y
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
                sudo rm -r firstrun.sh
                echo -e "${YELLOW}Packages complete...Will now reboot the system${NC}"
                sleep 10
                sudo reboot
          else
                echo -n "     Skipping Packages update"
                dots
                echo -e "${YELLOW}Skipped.${CN}"
        fi
}

function create_swap() {
  echo -e "${YELLOW}Creating swap if none detected...${NC}" && sleep 1
  if ! grep -q "swapfile" /etc/fstab; then
    if whiptail --yesno "No swapfile detected would you like to create one?" 8 54; then
      sudo fallocate -l 6G /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
      echo -e "${YELLOW}Created ${SEA}4G${YELLOW} swapfile${NC}"
    fi
  fi
  sleep 1
}

#MAIN

yerbas_title
install_packages
create_swap

