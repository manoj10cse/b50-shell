#!/bin/bash 
 
a=20 
# a is 20 er 

b=abc 
# abc is a string  

##

echo value of a is : $a 
echo ${a}
echo "${b}"

echo value of f is : $f

# rm -rf  /data/${DIR}  
# rm -rf /data/
# Above have not declared the dir so it will delete the /data...

echo "Good Morning Santhosh, Todays date is $DATE_COMMAND"
# This is how we can fetch the system data
echo "Number of logged in users are: $LOGGEDIN_USERS"