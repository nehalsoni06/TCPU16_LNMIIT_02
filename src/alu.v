// 16-bit ALU, wraps mod 65536, no flags.
`default_nettype none
`include "ops.vh"
module alu (
  input  wire [15:0] acc, imm,
  input  wire [2:0]  sh, aop,
  output reg  [15:0] an
);
  always @* begin
    case (aop)
      `A_PASS: an = imm;
      `A_ADD : an = acc + imm;
      `A_SUB : an = acc - imm;
      `A_SHL : an = acc << sh;
      `A_XOR : an = acc ^ imm;
      default: an = acc;
    endcase
  end
endmodule
`default_nettype wire
