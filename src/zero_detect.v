// Zero detect (16 bits) + next PC.
`default_nettype none
module npc (
  input  wire [2:0]  pc, t,
  input  wire [15:0] acc,
  input  wire        jmp, jz, hlt,
  output reg  [2:0]  pn
);
  wire zero = (acc == 16'h0000);
  always @* begin
    pn = pc + 3'd1;
    if (jmp)             pn = t;
    else if (jz && zero) pn = t;
    else if (hlt)        pn = pc;
  end
endmodule
`default_nettype wire
