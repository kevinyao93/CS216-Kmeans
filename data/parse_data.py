import sys
import os
import csv
from csv import DictReader
from heapq import nlargest
from operator import itemgetter
from collections import Counter

with open("output_data.csv", 'w') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(('Packet ID', 'Time', 'Size', 'IP Protocol', 'Port Destination', 'Port Source'))
    portcount = {};
    csvfiles = [f for f in os.listdir('.') if f.endswith('.csv')]
    for file in os.listdir():
        if file.endswith(".csv") and file != "output_data.csv":
            with open(file, "r") as read_obj:
                csv_dict_reader = DictReader(read_obj)
                column_names = csv_dict_reader.fieldnames
                for row in csv_dict_reader:
                    if row["port.dst"] in portcount:
                        portcount[row["port.dst"]] += 1
                    else:
                        portcount[row["port.dst"]] = 1

    common_ports = Counter(portcount)
    ports = []
    for port in common_ports.most_common(4):
        ports.append(port[0])

    for file in os.listdir():
        if file.endswith(".csv") and file != "output_data.csv":
            with open(file, "r") as read_obj:
                csv_dict_reader = DictReader(read_obj)
                column_names = csv_dict_reader.fieldnames
                for row in csv_dict_reader:
                    if (row["port.dst"] in ports):
                        filewriter.writerow([row["Packet ID"], row["TIME"], row["Size"], row["IP.proto"], row["port.dst"], row["port.src"]])
