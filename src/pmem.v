// Program memory: 8x8 flops, no reset, comb read.
`default_nettype none
module pmem (
  input  wire       clk, we,
  input  wire [2:0] wa,
  input  wire [7:0] wd,
  input  wire [2:0] ra,
  output wire [7:0] rd
);
  reg [7:0] m [0:7];
  always @(posedge clk) if (we) m[wa] <= wd;
  assign rd = m[ra];
endmodule
`default_nettype wire
