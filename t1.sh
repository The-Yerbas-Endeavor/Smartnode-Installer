
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

function add() {
        echo -e "     ${CYAN}Add a new user?"
        echo "       1) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        1) ADD=1;;
        2) ADD=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;add;
        esac
        echo " "
}

function adduser() {
    echo -e "${YELLOW}Add a new user{NC}" && sleep 1
    read -p "     New User Name: " ADDUSER
}

#MAIN

add
adduser
