#!/bin/bash
for x in $(cat server.txt); do     
echo 'Collecting info from servers'
echo $x
ssh jho@rivrs 'bash -s' < check_req.sh >> report.txt 
echo "END COLLECTION" >> report.txt
ssh jho@rivrs 'bash -s' < check_req.sh >> report.txt 
echo "END COLLECTION" >> report.txt
done

