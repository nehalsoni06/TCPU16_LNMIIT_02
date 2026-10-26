// TCPU-16 top: holds pc, acc, ir, halted (spec 3.3) and connects the blocks.
`default_nettype none
module toy_cpu16 (
  input  wire       clk, rst_n,
  input  wire [7:0] prog_data,
  input  wire       prog_load, run, byte_sel,
  output wire [7:0] acc_out
);
  reg [2:0]  pc;
  reg [15:0] acc;
  /* verilator lint_off UNUSEDSIGNAL */
  reg [7:0]  ir;       // sim visibility only, removed by synthesis
  /* verilator lint_on UNUSEDSIGNAL */
  reg        halted;

  wire        exec = run & ~halted;
  wire [7:0]  ins;
  wire [15:0] imm, an;
  wire [2:0]  t, aop, pn, wa;
  wire        jmp, jz, hlt, we;

  loader u_ld  (.clk(clk), .rst_n(rst_n), .prog_load(prog_load), .run(run), .we(we), .wa(wa));
  pmem   u_mem (.clk(clk), .we(we), .wa(wa), .wd(prog_data), .ra(pc), .rd(ins));
  dec    u_dec (.ins(ins), .imm(imm), .t(t), .aop(aop), .jmp(jmp), .jz(jz), .hlt(hlt));
  alu    u_alu (.acc(acc), .imm(imm), .sh(t), .aop(aop), .an(an));
  npc    u_npc (.pc(pc), .t(t), .acc(acc), .jmp(jmp), .jz(jz), .hlt(hlt), .pn(pn));
  omux   u_out (.acc(acc), .byte_sel(byte_sel), .acc_out(acc_out));

  always @(posedge clk) begin
    if (!rst_n) begin
      acc <= 16'h0; pc <= 3'd0; ir <= 8'h0; halted <= 1'b0;
    end else if (exec) begin
      acc    <= an;
      pc     <= pn;
      ir     <= ins;
      halted <= halted | hlt;
    end
  end
endmodule
`default_nettype wire
