#include <core.p4>
#include <v1model.p4>

#include "header.p4"
#include "parser.p4"

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action rewrite_mac(bit<48> smac) {
        hdr.ethernet.srcAddr = smac;
    }
    action _drop() {
        mark_to_drop(standard_metadata);
    }
    table send_frame {
        actions = {
            rewrite_mac;
            _drop;
            NoAction;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
        size = 256;
        default_action = NoAction();
    }
    apply {
        if (hdr.ipv4.isValid()) {
          send_frame.apply();
        }
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    
    action gen_megakey() {
        bit<3> bucketNum;
        if (hdr.ipv4.totalLen >= 800)
        {
            bucketNum = 5;
        }
        else if (hdr.ipv4.totalLen >= 200)
        {
            bucketNum = 4;
        }
        else if (hdr.ipv4.totalLen >= 150)
        {
            bucketNum = 3;
        }
        else if (hdr.ipv4.totalLen >= 100)
        {
            bucketNum = 2;
        }
        else if (hdr.ipv4.totalLen >= 50)
        {
            bucketNum = 1;
        }
        else 
        {
            bucketNum = 0;
        }
        
        bit<7> extra = 0;
        bit<16> sourceport = extra ++ standard_metadata.ingress_port;
        meta.ingress_metadata.megakey = bucketNum ++ hdr.ipv4.protocol ++ sourceport; 
    }
    
    action setoutputport(bit<9> portnum) {
        standard_metadata.egress_port = portnum;
    }

    table protocol_match
    {
        actions = {
            gen_megakey;
            NoAction;
        }
        key = {
            hdr.ipv4.protocol : exact;
        }
        size = 1024;
        default_action = NoAction();
    }
    table megakey_match
    {
        actions = {
            setoutputport;
            NoAction;
        }
        key = {
            meta.ingress_metadata.megakey : exact;
        }
        size = 512;
        default_action = NoAction();
    }
    apply {
        if (hdr.ipv4.isValid()) {
          protocol_match.apply();
          megakey_match.apply();
        }
    }
    

}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
