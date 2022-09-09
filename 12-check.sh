#!/bin/bash 

ID=$(id -u)
if [ $ID -eq 0 ]; then 
    echo "Executing httpd installation"
    yum install httpd -y  
else 
    echo -e "\e[31m Try executing the script with sudo or a root user \e[0m"
    exit 1
fi 