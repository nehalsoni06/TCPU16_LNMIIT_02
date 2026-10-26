// Output byte mux, combinational.
`default_nettype none
module omux (
  input  wire [15:0] acc,
  input  wire        byte_sel,
  output wire [7:0]  acc_out
);
  assign acc_out = byte_sel ? acc[15:8] : acc[7:0];
endmodule
`default_nettype wire
