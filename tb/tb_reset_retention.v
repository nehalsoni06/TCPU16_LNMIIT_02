
`timescale 1ns/1ps

module tb_reset_retention;

    reg clk;
    reg rst_n;
    reg [7:0] prog_data;
    reg prog_load;
    reg run;
    reg byte_sel;

    wire [7:0] acc_out;

    // Instantiate the CPU
    toy_cpu16 dut (
        .clk(clk),
        .rst_n(rst_n),
        .prog_data(prog_data),
        .prog_load(prog_load),
        .run(run),
        .byte_sel(byte_sel),
        .acc_out(acc_out)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Load one instruction into program memory
    task load_instruction;
        input [7:0] instruction;
        begin
            @(negedge clk);
            prog_data = instruction;
            prog_load = 1'b1;

            @(negedge clk);
            prog_load = 1'b0;

            // Allow loader edge detection to settle
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin
        clk       = 0;
        rst_n     = 0;
        prog_data = 0;
        prog_load = 0;
        run       = 0;
        byte_sel  = 0;

        $display("Starting reset-retention test");

        // Initial reset
        repeat (2) @(negedge clk);
        rst_n = 1;

        // Load three instructions
        load_instruction({3'b000, 5'd5}); // LOAD 5
        load_instruction({3'b001, 5'd3}); // ADD 3
        load_instruction({3'b111, 5'd0}); // HALT

        // Stop execution and reset the CPU
        run = 0;
        @(negedge clk);
        rst_n = 0;
        repeat (2) @(negedge clk);

        // Check that program memory retained its contents.
        // Change dut.u_prog_mem.mem to match your actual RTL hierarchy.
        if (dut.u_prog_mem.mem[0] !== {3'b000, 5'd5})
            $error("Instruction 0 was not retained");

        if (dut.u_prog_mem.mem[1] !== {3'b001, 5'd3})
            $error("Instruction 1 was not retained");

        if (dut.u_prog_mem.mem[2] !== {3'b111, 5'd0})
            $error("Instruction 2 was not retained");

        $display("Program memory retention check passed");

        // Release reset and restart execution
        rst_n = 1;
        repeat (2) @(negedge clk);
        run = 1;

        // Observe PC and accumulator during execution
        repeat (10) begin
            @(negedge clk);
            $display("Time=%0t PC=%0d ACC_OUT=%h",
                     $time, dut.pc, acc_out);
        end

        run = 0;
        $display("Reset-retention test completed");
        $finish;
    end

endmodule
