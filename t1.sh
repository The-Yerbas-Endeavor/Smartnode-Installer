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
    if [ $ADD == 1 ]
        then
    echo -e "${YELLOW}Add a new user{NC}" && sleep 1
    read -p "     New User Name: " ADDUSER
    adduser $ADDUSER
}

#MAIN

add
adduser
