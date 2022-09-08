#!/bin/bash 

ACTION=$1

case $ACTION in 
    start)
        echo "Starting XZ Service" 
        ;; 
    stop)
        echo "Stopping XZ Service"
        ;;
    restart)
        echo "Restarting XZ Service"
        ;;
    *)
        echo -e "Valid options are start or stop or restart only"
esac 