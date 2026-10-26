// Program loader: prog_load rising-edge detect, write pointer.
`default_nettype none
module loader (
  input  wire       clk, rst_n, prog_load, run,
  output wire       we,
  output wire [2:0] wa
);
  reg       plq;   // previous prog_load
  reg [2:0] la;    // load address
  wire lp = prog_load & ~plq & ~run;   // load pulse

  always @(posedge clk) begin
    plq <= prog_load;                  // every edge, even in reset
    if (!rst_n)  la <= 3'd0;
    else if (lp) la <= la + 3'd1;
  end

  assign we = rst_n & lp;
  assign wa = la;
endmodule
`default_nettype wire
