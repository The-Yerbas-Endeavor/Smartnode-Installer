ADDUSER=''

function adduser() {
    if [ $PACK == 1 ]
        then
    echo -e "${YELLOW}Add a new user{NC}" && sleep 1
    read -p "     New User Name: " ADDUSER
    adduser $ADDUSER
}

#MAIN

adduser
