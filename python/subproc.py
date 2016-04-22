#!/usr/bin/python
# Import the module
import subprocess

# Set up the echo command and direct the output to a pipe
p1=subprocess.Popen("svn info https://prog.nctdc.com/svn/CSP/Projects/ANSWRS/source/module/db/trunk/create_fun_with_revision.sql  | grep 'Last Changed Rev' | awk '{print $4}'", stdout=subprocess.PIPE, shell=True)
# Run the command
output = p1.communicate()[0]

print output
