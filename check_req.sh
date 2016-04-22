#Catch operating System running 
uname -a
#Display system configuration and diagnostic information
/usr/sbin/prtdiag
#Memory Installed
/usr/sbin/prtconf  | grep Memory
#Java location
/usr/ucb/whereis java
#Default java version
java -version
#Catch all the postgres instances
svcs "*postgres*" 
# Report some statistics
iostat 3 3
vmstat 3 3

