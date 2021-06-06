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
    
    action gen_megakey(bit<1> protocol) {
        // bitshift this to the left 17 times to get the msb where we want
    }
    
    action setoutputport(int portnum) {
        standard_metadata.egress_port = portnum;
    }

    table protocol_match
    {
        actions = {
            gen_megakey;
            NoAction;
        }
        key = {
            hdr.protocol : exact;
        }
        
        default_action = NoAction();
    }
    table megakey_match
    {
        actions = {
            setoutputport;
            NoAction;
        }
        key = {
            metadata.megakey : exact;
        }
        default_action = NoAction();
    }
    apply {
        if (hdr.ipv4.isValid()) {
          ipv4_lpm.apply();
          forward.apply();
        }
    }
    

}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
