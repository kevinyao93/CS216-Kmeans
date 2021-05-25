#!/bin/bash
wget https://iotanalytics.unsw.edu.au/iottestbed/pcap/filelist.txt -O filelist.txt --no-check-certificate
cat filelist.txt | egrep -v "(^#.*|^$)" | xargs -n 1 wget --no-check-certificate

for file in *.tar.gz; do tar -zxf "$file"; done
rm -rf ./*.tar.gz
