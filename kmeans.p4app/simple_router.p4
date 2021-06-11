#include <core.p4>
#include <v1model.p4>

#include "header.p4"
#include "parser.p4"

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action sport2mac(bit<48> smac) {
        hdr.ethernet.srcAddr = smac;
    }
    action _drop() {
        mark_to_drop(standard_metadata);
    }
    table send_frame {
        actions = {
            sport2mac;
            _drop;
            NoAction;
        }
        key = {
            standard_metadata.egress_spec: exact;
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
        
        bit <3> sourceport;
        if (standard_metadata.ingress_port == 1)
        {
            sourceport = 0;
        }
        // else if (standard_metadata.ingress_port == 3063)
        // {
        //     sourceport = 1;
        // }
        // else if (standard_metadata.ingress_port == 46330)
        // {
        //     sourceport = 2;
        // }
        // else if (standard_metadata.ingress_port == 54720)
        // {
        //     sourceport = 3;
        // }
        // else if (standard_metadata.ingress_port == 56118)
        // {
        //     sourceport = 4;
        // }
        // else if (standard_metadata.ingress_port == 64307)
        // {
        //     sourceport = 5;
        // }
        else {
            sourceport = 1;
        }
        meta.ingress_metadata.megakey = bucketNum ++ hdr.ipv4.protocol ++ sourceport; 
    }
    
    action setoutputport(bit<16> portnum) {
        
       meta.ingress_metadata.class = portnum;
    }

    action _drop() {
        mark_to_drop(standard_metadata);
    }

    action setdestaddrs(bit<32> dip, bit<9> egrport, bit<48> dmac)
    {
        hdr.ipv4.dstAddr = dip;
        standard_metadata.egress_spec = egrport;
        hdr.ethernet.dstAddr = dmac;
    }

    table port2dest
    {
        actions = {
            setdestaddrs;
            _drop;
        }
        key = {
            meta.ingress_metadata.class : exact;
        }
        default_action = _drop;
    }

    table protocol_match
    {
        actions = {
            gen_megakey;
            _drop;
        }
        key = {
            hdr.ipv4.protocol : exact;
        }
        size = 1024;
        default_action = gen_megakey;
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
        size = 2048;
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
