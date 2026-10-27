
`timescale 1ns/1ps

module tb_toy_cpu16;

    reg clk;
    reg rst_n;
    reg [7:0] prog_data;
    reg prog_load;
    reg run;
    reg byte_sel;

    wire [7:0] acc_out;

    integer errors;
    integer cycles;

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
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Generate waveform for GTKWave
    initial begin
        $dumpfile("build/tcpu16_wave.vcd");
        $dumpvars(0, tb_toy_cpu16);
    end

    // Load one instruction into program memory
    task load_word;
        input [7:0] word;
        begin
            @(negedge clk);
            prog_data = word;
            prog_load = 1'b1;

            @(posedge clk);

            @(negedge clk);
            prog_load = 1'b0;

            @(posedge clk);
        end
    endtask

    initial begin
        // Initialize inputs
        rst_n = 1'b0;
        prog_data = 8'h00;
        prog_load = 1'b0;
        run = 1'b0;
        byte_sel = 1'b0;
        errors = 0;
        cycles = 0;

        // Reset CPU
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // Load all 8 program-memory locations
        load_word(8'h12); // LOAD 18
        load_word(8'h64); // SHL 4
        load_word(8'h23); // ADD 3
        load_word(8'h41); // SUB 1
        load_word(8'h41); // SUB 1
        load_word(8'h41); // SUB 1
        load_word(8'hE0); // HALT
        load_word(8'hE0); // HALT filler

        $display("Program loaded successfully.");

        // Start CPU execution
        @(negedge clk);
        run = 1'b1;

        // Wait for HALT, with a timeout
        while ((dut.halted !== 1'b1) && (cycles < 30)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #1;

        // Check HALT
        if (dut.halted !== 1'b1) begin
            $display("FAIL: CPU did not halt.");
            errors = errors + 1;
        end

        // Check 16-bit accumulator
        if (dut.acc !== 16'h0120) begin
            $display("FAIL: Expected ACC=0x0120, got 0x%04h",
                     dut.acc);
            errors = errors + 1;
        end
        else begin
            $display("PASS: ACC = 0x%04h", dut.acc);
        end

        // Check lower byte
        byte_sel = 1'b0;
        #1;

        if (acc_out !== 8'h20) begin
            $display("FAIL: Expected lower byte 0x20, got 0x%02h",
                     acc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Lower byte = 0x%02h", acc_out);
        end

        // Check upper byte
        byte_sel = 1'b1;
        #1;

        if (acc_out !== 8'h01) begin
            $display("FAIL: Expected upper byte 0x01, got 0x%02h",
                     acc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Upper byte = 0x%02h", acc_out);
        end

        // Final result
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $display("Execution cycles counted: %0d", cycles);

        $finish;
    end

    // Simulation timeout
    initial begin
        #10000;
        $display("FAIL: Simulation timeout.");
        $finish;
    end

endmodule
