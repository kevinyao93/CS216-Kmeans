
# import time

# # sendp(Ether()/IP(dst="1.2.3.4",ttl=(1,4)), iface="eth1")
# send(IP(dst="10.0.1.10")/TCP(dport=5566)/"Hello World")

# send(IP(dst="10.0.1.10")/ICMP()/"Hello World")


# print(time.time())
# print('WE DID IT , HOMOS!')

#!/usr/bin/env python

import argparse
import sys
import socket
import os
import csv

import random
import struct
import re

from scapy.all import send, IP, ICMP, TCP, sendp, Raw

from scapy.all import Packet, hexdump
from scapy.all import Ether, StrFixedLenField, XByteField, IntField
from scapy.all import bind_layers
import readline
import random

# class ProjectPacket(Packet):
#     name = "ProjectPacket"
#     fields_desc = [XByteField("protocol", 0x01),
#                     IntField("ttl", 64),
#                     IntField("size", 100),
#                     IntField("dest_port", 0),
#                     IntField("pred_dest_port", 0)
                    # IntField("packet_id", 0)
# ]

# bind_layers(IP, ProjectPacket, type=0x1234)

def read_packets_csv(dir): 
    res = []
    with open(dir, 'r') as csvfile: 
        packet_reader = csv.reader(csvfile, delimiter=',')
        
        next(packet_reader) #skip header

        for row in packet_reader:
            new_packet = {}
            new_packet['id'] = int(row[0])
            new_packet['size'] = int(row[2])
            new_packet['port_dest'] = int(row[4])
            new_packet['port_source'] = int(row[5])
            res.append(new_packet)
    return res

def main():

    arr_packets = read_packets_csv(dir='./output_data.csv')
    dest_ip = '10.0.1.10'
    data = '#happypride2021'

    for packet in arr_packets[:10]:
        # pkt = IP(dst=dest_ip)/ ProjectPacket(ttl=5, size=32, dest_port=packet['port_dest'], pred_dest_port=-1)
        # pkt = IP(dst=dest_ip)/ ProjectPacket()
        # pkt = pkt / Raw(load=data)
        pkt = IP(dst=dest_ip) / TCP(sport=packet['port_source'], dport=packet['port_dest'], flags='S') / Raw(load=data)
        send(pkt)


if __name__ == '__main__':
    main()