#!/bin/bash

source components/common.sh

COMPONENT=mongodb

echo -n "Configuring the MongoDB repo:"
curl -s -o /etc/yum.repos.d/${COMPONENT}.repo https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/mongo.repo
stat $? 

echo -n "Installing ${COMPONENT}:"
yum install -y mongodb-org >> /tmp/${COMPONENT}.log
stat $? 

echo -n "Updating the $COMPONENT Config:"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf 
stat $? 

echo -n "Start the $COMPONENT service"
systemctl enable mongod >> /tmp/${COMPONENT}.log
systemctl start mongod  
stat $? 

echo -n "Download schema:"
curl -s -L -o /tmp/mongodb.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Extract $COMPONENT Schema:"
cd /tmp && unzip -o mongodb.zip && cd mongodb-main
stat $? 

echo -n "Injecting the $COMPONENT schema: "
mongo < catalogue.js && mongo < users.js 
stat $? 
