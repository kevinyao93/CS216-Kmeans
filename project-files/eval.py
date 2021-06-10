from scapy.all import *
import os
import csv


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
    # get output pcap from h1
    loc_h1_packets = './output_data.csv'
    h1_packets = read_packets_csv(loc_h1_packets)

    # get input pcap from h2
    # load pcap from h2 into a thing
    loc_h2_pcap = './out/s1-eth1_out.pcap'
    h2_packets = rdpcap(loc_h2_pcap)

    arr_matching_ports = [] #bool, yes or no
    for idx, h2_packet in enumerate(h2_packets): # 
        import pdb; pdb.set_trace() #TODO figure this out since broadcast is being used lol
        # if h2_packet.haslayer(IP):
        h2_source = h2_packet.sport
        h1_packet = h1_packets[idx]
        if h2_source == h1_packet['dest']: 
            arr_matching_ports.append(1)
        else: 
            arr_matching_ports.append(0)
    acc = 100 * (sum(arr_matching_ports) / len(arr_matching_ports))
    print(f"P4 Accuracy = .3f{acc}%")
    

if __name__ == "__main__": 
    main()