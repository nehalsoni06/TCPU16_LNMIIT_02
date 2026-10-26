// TCPU-16 opcodes. Instruction = {op[7:5], operand[4:0]}
// imm = operand[4:0] zero-extended; sh = t = operand[2:0]; HALT ignores operand.
`ifndef OPS_VH
`define OPS_VH
`define OP_LOAD 3'b000 // ACC <= imm
`define OP_ADD  3'b001 // ACC <= ACC + imm
`define OP_SUB  3'b010 // ACC <= ACC - imm
`define OP_SHL  3'b011 // ACC <= ACC << sh
`define OP_XOR  3'b100 // ACC <= ACC ^ imm
`define OP_JMP  3'b101 // PC <= t
`define OP_JZ   3'b110 // PC <= (ACC==0) ? t : PC+1
`define OP_HALT 3'b111 // halted <= 1, PC held
// ALU select codes
`define A_HOLD 3'd0
`define A_PASS 3'd1
`define A_ADD  3'd2
`define A_SUB  3'd3
`define A_SHL  3'd4
`define A_XOR  3'd5
`endif
