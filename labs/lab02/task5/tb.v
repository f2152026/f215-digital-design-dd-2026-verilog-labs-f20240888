`timescale 1ns/1ps

module tb;

    reg  [3:0] t_a;
    reg  [3:0] t_b;
    reg        t_op;
    wire [3:0] t_result;

    reg  [3:0] exp_result;
    integer errors = 0;
    integer total_tests = 0;

    // Instantiate DUT
    alu DUT (
        .a     (t_a),
        .b     (t_b),
        .op    (t_op),
        .result(t_result)
    );

    // Waveform dump configuration
    string vcd_file;
    initial begin
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(0, DUT);
        end
    end

    task check_alu;
        input [3:0] a_val;
        input [3:0] b_val;
        input       op_val;
        begin
            t_a  = a_val;
            t_b  = b_val;
            t_op = op_val;

            // Independently compute expected result (4-bit truncation)
            if (op_val == 1'b0)
                exp_result = a_val + b_val;
            else
                exp_result = a_val - b_val;

            #5; // Wait for combinational propagation
            total_tests = total_tests + 1;

            if (t_result !== exp_result) begin
                $display("FAIL at time %0t: a=%d b=%d op=%b | got result=%d expected=%d",
                         $time, t_a, t_b, t_op, t_result, exp_result);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // 1. Test op toggle with operands held fixed (exposes sensitivity list bug)
        check_alu(4'd7, 4'd3, 1'b0); // 7 + 3 = 10
        check_alu(4'd7, 4'd3, 1'b1); // 7 - 3 = 4 (same operands, only op changed)

        // 2. Test subtraction variations (exposes non-blocking bug)
        check_alu(4'd5, 4'd2, 1'b1); // 5 - 2 = 3
        check_alu(4'd9, 4'd4, 1'b1); // 9 - 4 = 5
        check_alu(4'd8, 4'd8, 1'b1); // 8 - 8 = 0
        check_alu(4'd2, 4'd5, 1'b1); // 2 - 5 = -3 (4'b1101 = 13)

        // 3. Test addition variations
        check_alu(4'd2, 4'd3, 1'b0); // 2 + 3 = 5
        check_alu(4'd8, 4'd7, 1'b0); // 8 + 7 = 15
        check_alu(4'd12, 4'd6, 1'b0); // 12 + 6 = 18 -> 4-bit 2

        if (errors == 0)
            $display("ALL PASSED: %0d / %0d tests passed.", total_tests, total_tests);
        else
            $display("TEST FAILED: %0d failed out of %0d tests.", errors, total_tests);

        $finish;
    end

endmodule