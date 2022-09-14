
#!/bin/bash

source components/common.sh

COMPONENT=rabbitmq

echo -n "Configure and Install dependencyes:"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>> ${LOGFILE} 
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash  &>> ${LOGFILE} 
stat $? 

echo -n "Install RabbitMQ: "
yum install rabbitmq-server -y  &>> ${LOGFILE} 
stat $? 

echo -n "S $COMPONENT :"
systemctl enable rabbitmq-server &>> ${LOGFILE} 
systemctl start rabbitmq-server &>> ${LOGFILE} 
stat $? 

rabbitmqctl list_users | grep roboshop  2>> ${LOGFILE} 
if [ $? -ne 0 ]; then 
    echo -n "Creating $COMPONENT Application user:" &>> ${LOGFILE} 
    rabbitmqctl add_user roboshop roboshop123 &>> ${LOGFILE} 
    stat $? 
fi 

echo -n "Configure the $COMPONENT $FUSER permissions: "
rabbitmqctl set_user_tags roboshop administrator &>> ${LOGFILE}  &&  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> ${LOGFILE} 
stat $? 