
/*
 * Copyright (c) 2024 Nehal Soni
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_nehalsoni06_tcpu16 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [7:0] acc_out;

  toy_cpu16 u_cpu (
      .clk       (clk),
      .rst_n     (rst_n),
      .prog_data (ui_in),
      .prog_load (uio_in[0]),
      .run       (uio_in[1] & ena),
      .byte_sel  (uio_in[2]),
      .acc_out   (acc_out)
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = acc_out;
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{uio_in[7:3], 1'b0};

endmodule

`default_nettype wire
