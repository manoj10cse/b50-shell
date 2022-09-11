#!/bin/bash

set -e

source components/common.sh

COMPONENT=catalogue
FUSER=roboshop

echo -n "configure yum repos to nodeJS:"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> /tmp/${COMPONENT}.log 
stat $?

echo -n "Install NodejS""
yum install nodejs -y >> /tmp/${COMPONENT}.log 
stat $?

echo -n "addd user roboshop"
id ${FUSER} >> /tmp/${COMPONENT}.log  || useradd ${roboshop} 
stat $?

echo -n "download $COMPONENT:"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" >> /tmp/${COMPONENT}.log 
stat $?

echo -n "Cleanup of Old ${COMPONENT} content:"
rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log 
stat $?

echo -n "Extract ${COMPONENT} content: "
cd /home/${FUSER}/ >> /tmp/${COMPONENT}.log 
unzip -o  /tmp/{COMPONENT}.zip  >> /tmp/${COMPONENT}.log   &&   mv ${COMPONENT}-main ${COMPONENT} >> /tmp/${COMPONENT}.log 
stat $? 

echo -n "Change ownership to ${FUSER}:"
chown -R $FUSER:$FUSER $COMPONENT/
stat $?

echo -n "Install $COMPONENT Dependencies:"
cd $COMPONENT && npm install &>> /tmp/${COMPONENT}.log 
stat $? 

# echo -n "Config the Systemd file: "
# sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/${FUSER}/${COMPONENT}/systemd.service 
# mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/catalogue.service
# stat $? 

# echo -n "Starting the service"
# systemctl daemon-reload  &>> /tmp/${COMPONENT}.log 
# systemctl enable ${COMPONENT} &>> /tmp/${COMPONENT}.log
# systemctl start ${COMPONENT} &>> /tmp/${COMPONENT}.log
# stat $?