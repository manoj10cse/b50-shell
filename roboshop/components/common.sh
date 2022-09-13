
# validating whether the executing user is root or not
ID=$(id -u)
if [ $ID -ne 0 ]; then 
    echo -e "\e[31m Try executing the script with sudo or a root user \e[0m"
    exit 1
fi 

# Declaring the stat function
stat() {
    if [ $1 -eq 0 ] ; then 
        echo -e "\e[32m Success \e[0m" 
    else
        echo -e "\e[31m Failure. Look for the logs \e[0m"  
    fi 
}

FUSER=roboshop
LOGFILE=robot.log

USER_SETUP() {
    echo -n "Adding $FUSER user:"
    id ${FUSER} &>> LOGFILE  || useradd ${FUSER}   
    stat $? 
}

DOWNLOAD_AND_EXTRACT() {
    echo -n "Downloading ${COMPONENT} :"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" >> /tmp/${COMPONENT}.log 
    stat $? 

    echo -n "Cleanup of Old ${COMPONENT} content:"
    rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log 
    stat $?

    echo -n "Extracting ${COMPONENT} content: "
    cd /home/${FUSER}/ >> /tmp/${COMPONENT}.log 
    unzip -o  /tmp/${COMPONENT}.zip  >> /tmp/${COMPONENT}.log   &&   mv ${COMPONENT}-main ${COMPONENT} >> /tmp/${COMPONENT}.log 
    stat $? 

    echo -n "Changing the ownership to ${FUSER}:"
    chown -R $FUSER:$FUSER $COMPONENT/
    stat $?
} 

CONFIG_SVC() {
    echo -n "Configuring the Systemd file: "
    sed -i -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/'  -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/${FUSER}/${COMPONENT}/systemd.service     mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
    stat $? 

    echo -n "Starting the service"
    systemctl daemon-reload  &>> /tmp/${COMPONENT}.log 
    systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
    systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
    stat $?
}

NODEJS() {
    echo -n "Configure Yum Remos for nodejs:"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> /tmp/${COMPONENT}.log 
    stat $?

    echo -n "Installing nodejs:"
    yum install nodejs -y >> /tmp/${COMPONENT}.log 
    stat $? 
    
    
    USER_SETUP 


    DOWNLOAD_AND_EXTRACT

    echo -n "Installing $COMPONENT Dependencies:"
    cd $COMPONENT && npm install &>> /tmp/${COMPONENT}.log 
    stat $? 
    

    CONFIG_SVC
}

MAVEN() {
    echo -n "Installing Maven: "
    yum install maven -y &>> LOGFILE
    stat $? 

    USER_SETUP

    DOWNLOAD_AND_EXTRACT
    
    echo -n "Generating the artifact :"
    cd /home/${FUSER}/${COMPONENT}
    mvn clean package   &>> LOGFILE
    mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
    stat $? 
    
    CONFIG_SVC
}