#!/bin/bash
wget https://iotanalytics.unsw.edu.au/iottestbed/pcap/filelist.txt -O filelist.txt --no-check-certificate
# Covert to getting the csv file
sed -i.bu 's/pcap/csv/' filelist.txt
sed -i.bu 's/tar.gz/csv.zip/' filelist.txt
cat filelist.txt | egrep -v "(^#.*|^$)" | xargs -n 1 wget --no-check-certificate

#for file in *.tar.gz; do tar -zxf "$file"; done
#rm -rf ./*.tar.gz
for file in *.csv.zip; do unzip "$file"; done
rm -rf ./*.csv.zip

python parse_data.py
