osType="$(uname -m)"
VERSION_ID="$(lsb_release -sr)"
COIN_DAEMON='yerbasd'
COIN_FOLDER='yerbas-build'
COIN_CONF_FOLDER='.yerbascore'
COIN_NAME='YERBAS'
COIN_CLI='yerbas-cli'
COIN_TX='yerbas-tx'
COIN_URL='https://github.com/The-Yerbas-Endeavor/yerbas/releases'
WALLET_TAR_ARM_64=$(curl -s https://api.github.com/repos/The-Yerbas-Endeavor/yerbas/releases/latest | jq -r '.assets[] | select(.name|test("arm64.")) | .browser_download_url')
WALLET_TAR_U_20=$(curl -s https://api.github.com/repos/The-Yerbas-Endeavor/yerbas/releases/latest | jq -r '.assets[] | select(.name|test("ubuntu20.")) | .browser_download_url')
WALLET_TAR_U_22=$(curl -s https://api.github.com/repos/The-Yerbas-Endeavor/yerbas/releases/latest | jq -r '.assets[] | select(.name|test("ubuntu22.")) | .browser_download_url')
COIN_URL_POWER='https://github.com/The-Yerbas-Endeavor/YERB-Bootstrap/releases/download/1.0.0.0/powcache.dat'
COIN_URL_BOOT='https://github.com/The-Yerbas-Endeavor/YERB-Bootstrap/releases/download/1.0.0.0/bootstrap.zip'
COIN_VERSION_NAME="$(curl -sL https://api.github.com/repos/The-Yerbas-Endeavor/yerbas/releases/latest | jq -r ".tag_name")"
COIN_CONF_FILE='yerbas.conf'
COIN_PORT='15420'
NODE_IP=''
BLS_SECRET=''
INS_TYPE=''
RPCPORT=''
RPCPASSWORD=''
RPCUSER=''
File=".err.log"
USERNAME="$(whoami)"


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
        echo "     $COIN_NAME install script .... created by Azrelix"
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


function install_type(){
        echo -e "     ${CYAN}Select option"
        echo "       1) Install new $COIN_NAME node"
        echo -e "       2) Update existing $COIN_NAME node${CN}"
        read -p "     " n
        case $n in
        1) INS_TYPE='new';;
        2) INS_TYPE='update';;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;install_type;
        esac
        echo " "
}

function detect_os() {
        echo -n "     Detecting system"
        dots
        if [ $osType == "x86_64" ]
                then
                echo -e "${YG}$osType system detected.${CN}"
        elif [ $osType == "aarch64" ]
                then
                echo -e "${YG}$osType system detected.${CN}"
        else
                echo -e "${RED}ERROR ERROR ERROR...."
                echo ""
                echo -e "SCRIPT FAILED... NO MATCHING OS FOUND found${CN}"
                end
        fi
}

function detect_version() {
        echo -n "     Detecting version"
        dots
        if [ $VERSION_ID == "22.04" ]
                then
                echo -e "${YG}$VERSION_ID system detected.${CN}"
        elif [ $VERSION_ID == "20.04" ]
                then
                echo -e "${YG}$VERSION_ID system detected.${CN}"
        elif [ $VERSION_ID == "aarch64" ]
                then
                echo -e "${YG}$VERSION_ID system detected.${CN}"
        else
                echo -e "${RED}ERROR ERROR ERROR...."
                echo ""
                echo -e "SCRIPT FAILED... NO MATCHING OS FOUND found${CN}"
                end
        fi
}


function uninstall_old() {
        if [ $INS_TYPE == "update" ]
                then
                echo -n "     Stopping $COIN_NAME Daemon"
                dots
                cd ~/$COIN_FOLDER &>> ~/.err.log
                cd ~
                if ! grep -q "No such file or directory" "$File"; then
                        cd ~/$COIN_FOLDER
                        ./$COIN_CLI stop &>> ~/.err.log
                        cd ~
                        if ! grep -q "error:" "$File"; then
                                echo -e "${YG}Success.${CN}"
                        else
                                echo -e "${RED}Failed.  Daemon not running, attempting to continue.${CN}"
                        fi
                        echo -n "     Removing $COIN_FOLDER folder "
                        dots
                        rm -r $COIN_FOLDER &>> ~/.err.log
                        if ! grep -q "cannot remove 'yerbas-build'" "$File"; then
                                echo -e "${YG}Success.${CN}"
                        else
                                echo -e "${RED}Failed. Unable to remove $COIN_FOLDER folder, either wrong location or $COIN_NAME not installed, attempting to continue.${CN}"
                        fi
                else
                        echo -e "${RED}$COIN_FOLDER directory not found, either wrong location or yerbas not installed, attempting to continue.${CN}"
                fi
        fi
}

function download_node() {
        echo -n "     Fetching $COIN_NAME $COIN_VERSION_NAME"
        dots
        if [ $osType == "x86_64" ] && [ $VERSION_ID == "22.04" ] 
                then
                mkdir temp
                mkdir yerbas-build
                curl -L $WALLET_TAR_U_22 | tar xz -C ./temp;
                mv temp/* ~/
                rm -r temp

        elif [ $osType == "x86_64" ] && [ $VERSION_ID == "20.04" ]
                then
                mkdir temp
                curl -L $WALLET_TAR_U_20 | tar xz -C ./temp;
                mv temp/* ~/yerbas-build/
                rm -r temp

        elif [ $osType == "aarch64" ]
                then
                mkdir temp
                curl -L $WALLET_TAR_ARM_64 | tar xz -C ./temp;
                mv temp/* ~/
                rm -r temp

        fi
        echo -e "${YG}Success.${CN}"
        echo -n "     Cleaing up"
        dots
        echo -e "${YG}Success.${CN}"
        if [ $PC == 1 ]
                then
                cd ~
                mkdir $COIN_CONF_FOLDER &>> ~/.err.log
                cd $COIN_CONF_FOLDER
                echo -n "     Fetching $COIN_URL_POWER"
                dots
                wget -q $COIN_URL_POWER
                echo -e "${YG}Success.${CN}"

        else
                echo -n "     Skipping $COIN_URL_POWER"
                dots
                echo -e "${YELLOW}Skipped.${CN}"
        fi

        if [ $BS == 1 ]
                then
                cd ~
                mkdir $COIN_CONF_FOLDER &>> ~/.err.log
                cd $COIN_CONF_FOLDER
                rm -r assets &>> ~/.err.log
                rm -r blocks &>> ~/.err.log
                rm -r chainstate &>> ~/.err.log
                rm -r evodb &>> ~/.err.log
                rm -r llmq &>> ~/.err.log
                echo -n "     Fetching $COIN_URL_BOOT"
                dots
                wget -q $COIN_URL_BOOT
                echo -e "${YG}Success.${CN}"
                echo -n "     Unzipping $COIN_URL_BOOT"
                dots
                unzip -q bootstrap
                echo -e "${YG}Success.${CN}"
                echo -n "     Moving $COIN_NAME bootstrap files to $COIN_CONF_FOLDER folder"
                dots
                mv bootstrap/* .
                rm -r bootstrap
                rm -r bootstrap.zip
                echo -e "${YG}Success.${CN}"

        else
                echo -n "     Skipping $COIN_URL_BOOT"
                dots
                echo -e "${YELLOW}Skipped.${CN}"
        fi

}

function power_cache() {
        echo -e "     ${CYAN}Download Power Cache?"
        echo "       1) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        1) PC=1;;
        2) PC=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;power_cache;
        esac
        echo " "
}

function bootstrap() {
        echo -e "     ${CYAN}Download Bootstrap?"
        echo "       1) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        1) BS=1;;
        2) BS=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;bootstrap;
        esac
        echo " "
}

function tx_reindex() {
        echo " "
        echo -e "     ${CYAN}Is txreindex required on Daemon start? Will take a long time...Type Yes to confirm"
        echo "       Yes) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        Yes) TX=Yes;;
        2) TX=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;tx_reindex;
        esac
        echo " "
}

function add_to_cron() {
        echo " "
        echo -e "     ${CYAN}Add $COIN_NAME to Crontab? (this will start $COIN_NAME daemon on Boot)"
        echo "       1) Yes"
        echo -e "       2) No${CN}"
        read -p "     " n
        case $n in
        1) AC=1;;
        2) AC=2;;
        *) echo -e "     ${RED}invalid option selected.. :( try again${CN}"  ;add_to_cron;
        esac
        echo " "
}

function start_daemon () {
        tx_reindex
        if [ $TX == Yes ]
        then
                echo -n "     Starting $COIN_NAME daemon with -reindex enabled"
                dots
                cd ~/$COIN_FOLDER
                ./$COIN_DAEMON -reindex &>> ~/.err.log
                #add error catching if daemon doesnt start
                cd ~
                echo -e "${YG}Success.${CN}"
        else 
                        echo -n "     Starting $COIN_NAME daemon "
                dots
                cd ~/$COIN_FOLDER
                ./$COIN_DAEMON &>> ~/.err.log
                #add error catching if daemon doesnt start
                cd ~
                echo -e "${YG}Success.${CN}"
        fi
}

function node_settings () {
        echo " "
        echo -e "${CYAN}     (Press enter to skip)"
        read -p "     RPC User: " RPCUSER
        read -p "     RPC Password: " RPCPASSWORD
        read -p "     RPC port to use (default 9494): " RPCPORT
        read -p "     Enter node IP: " NODE_IP
        read -p "     Enter BLS secret Key: " BLS_SECRET
        echo -e "${CN} "
}

function update_config () {
        if [ $INS_TYPE == update ]
        then 
                echo -n "     Skipping updating $COIN_NAME config as daemon upgrade only"
                dots
                echo -e "${YELLOW}Skipped.${CN}"
        else
                node_settings
                echo -n "     Updating $COIN_NAME config file"
                dots
                echo rpcallowip=127.0.0.1 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                echo listen=1 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                echo server=1 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                echo daemon=1 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                echo rpcpassword=$RPCPASSWORD >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE

                if ! [ -z $RPCUSER ]
                then
                        echo rpcuser=$RPCUSER >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                else 
                        echo rpcuser=yerbasuser1 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                fi
                if ! [ -z $RPCPORT ]
                then
                        echo rpcport=$RPCPORT >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                else 
                        echo rpcport=9494 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                fi
                if ! [ -z $NODE_IP ]
                then
                        echo bind=$NODE_IP >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                fi
                if ! [ -z $NODE_IP ]
                then
                        echo externalip=$NODE_IP:15420 >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                fi
                if ! [ -z $BLS_SECRET ]
                then
                        echo smartnodeblsprivkey=$BLS_SECRET >> ~/$COIN_CONF_FOLDER/$COIN_CONF_FILE
                fi
                echo -e "${YG}Success.${CN}"
        fi
}

function add_cron() {
        if [ $AC == 1 ]
                then
                echo -n "     Adding $COIN_NAME to crontab"
                dots
                cat <(crontab -l) <(echo "@reboot sleep 20 && ~/yerbas-build/yerbasd") | crontab -
                echo -e "${YG}Success.${CN}"
        fi
}

function check_node() {

                echo -n "     Loading blocks and checking Smartnode Status. Wait 1 minute. Roll one up"
                sleep 60
                dots
                cd ~/$COIN_FOLDER &>> ~/.err.log
                ./$COIN_CLI smartnode status &>> ~/.err.log
                cd ~
                if [ $(grep -c "READY" "$File") -eq 1 ]; 
                        then
                        echo -e "${YG}Your Smartnode is READY ready to rock! ${CN}"
                elif [ $(grep -c "make sure server is running" "$File") -eq 1 ];
                        then
                       echo -e "${YG}make sure server is running and you are connecting to the correct RPC port ${CN}"
                elif [ $(grep -c "WAITING_FOR_PROTX" "$File") -eq 1 ];
                        then
                       echo -e "${YG} NOT READY! Waiting for ProTx to appear on-chain.${CN}"
                else
                        echo -e "${RED}Something is up, check your .conf setings.${CN}"
                fi
        
}


function 4204life() {
        echo " "
        echo " "
        echo " "
        echo -e "     ${YG}INSTALLATION FINISHED${CN}"
        echo " "
}


#MAIN

clear

yerbas_title
install_type
power_cache
bootstrap
detect_os
detect_version
uninstall_old
download_node
update_config
start_daemon
add_to_cron
add_cron
check_node

4204life
