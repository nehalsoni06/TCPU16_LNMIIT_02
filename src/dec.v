// Decode: split instruction, make controls.
`default_nettype none
`include "ops.vh"
module dec (
  input  wire [7:0]  ins,
  output wire [15:0] imm,
  output wire [2:0]  t,      // jump target / shift amount
  output reg  [2:0]  aop,    // ALU select
  output reg         jmp, jz, hlt
);
  assign imm = {11'b0, ins[4:0]};
  assign t   = ins[2:0];

  always @* begin
    aop = `A_HOLD; jmp = 1'b0; jz = 1'b0; hlt = 1'b0;
    case (ins[7:5])
      `OP_LOAD: aop = `A_PASS;
      `OP_ADD : aop = `A_ADD;
      `OP_SUB : aop = `A_SUB;
      `OP_SHL : aop = `A_SHL;
      `OP_XOR : aop = `A_XOR;
      `OP_JMP : jmp = 1'b1;
      `OP_JZ  : jz  = 1'b1;
      `OP_HALT: hlt = 1'b1;
      default : ;
    endcase
  end
endmodule
`default_nettype wire
