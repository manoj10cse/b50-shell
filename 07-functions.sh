# sample() {
#     echo "Hi santhosh"
#     echo "started learning the scripting"
#     lsblk

# }

# sample



stat() {
    echo "Load Average for last 1 min is : $(uptime | awk -F : '{print $NF}' | awk -F , '{print $1}')"
    echo "list the number of users logedin : $(who|wc -l)" 
    echo "done"
} 

stat

stat

stat