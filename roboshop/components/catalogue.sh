#!/bin/bash

set -e 

source components/common.sh

COMPONENT=catalogue
FUSER=roboshop 

echo -n "Configure Yum Remos for nodejs:"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> /tmp/${COMPONENT}.log 
stat $?

echo -n "Installing nodejs:"
yum install nodejs -y >> /tmp/${COMPONENT}.log 
stat $? 

echo -n "Adding $FUSER user:"   
id ${FUSER} >> /tmp/${COMPONENT}.log  || useradd ${FUSER}
stat $? 

echo -n "Download ${COMPONENT} :"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip" >> /tmp/${COMPONENT}.log 
stat $? 

echo -n "Cleanup of Old ${COMPONENT} content:"
rm -rf /home/${FUSER}/${COMPONENT}  >> /tmp/${COMPONENT}.log 
stat $?

echo -n "Extracting ${COMPONENT} content: "
cd /home/${FUSER}/ >> /tmp/${COMPONENT}.log 
unzip -o  /tmp/${COMPONENT}.zip  >> /tmp/${COMPONENT}.log   &&   mv ${COMPONENT}-main ${COMPONENT} >> /tmp/${COMPONENT}.log 
stat $? 

echo -n "Change the ownership to ${FUSER}:"
chown -R $FUSER:$FUSER $COMPONENT/
stat $?

echo -n "Install $COMPONENT Dependencies:"
cd $COMPONENT && npm install &>> /tmp/${COMPONENT}.log 
stat $? 

echo -n "Configure the Systemd file: "
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/${FUSER}/${COMPONENT}/systemd.service 
mv /home/${FUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $? 

echo -n "Service starting"
systemctl daemon-reload &>> /tmp/${COMPONENT}.log 
systemctl enalbe $COMPONENT &>> /tmp/${COMPONENT}.log 
systemctl start $COMPONENT &>> /tmp/${COMPONENT}.log 
stat $?