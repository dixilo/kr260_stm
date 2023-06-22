#include <ap_int.h>

void axi_reader(ap_uint<94> *cnt_in,
                ap_uint<94> *cnt_out){
// Stream in/out.
#pragma HLS INTERFACE mode=s_axilite port=cnt_out clock=s_axi_aclk
// Ctrl interface suppression.
#pragma HLS INTERFACE ap_ctrl_none port=return

    *cnt_out = *cnt_in;
}
