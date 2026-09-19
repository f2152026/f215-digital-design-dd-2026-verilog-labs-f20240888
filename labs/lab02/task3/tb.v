`timescale 1ns/1ps

module tb;

    // Inputs to DUT
    reg [1:0] t_a;
    reg [1:0] t_b;

    // Outputs from DUT
    wire t_gt;
    wire t_lt;
    wire t_eq;

    // Golden / expected outputs
    reg exp_gt;
    reg exp_lt;
    reg exp_eq;

    // Error and test tracking counters
    integer errors = 0;
    integer total_tests = 0;
    integer i, j;

    // Instantiate the comparator under test
    comp2 DUT (
        .A (t_a),
        .B (t_b),
        .GT(t_gt),
        .LT(t_lt),
        .EQ(t_eq)
    );

    // Waveform dump configuration
    string vcd_file;
    initial begin
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(0, DUT);
        end
    end

    initial begin
        // Loop over all 16 combinations: A in [0..3], B in [0..3]
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                t_a = i;
                t_b = j;

                // Independently compute expected outputs
                exp_gt = (i > j);
                exp_lt = (i < j);
                exp_eq = (i == j);

                #5; // Wait for combinational logic to propagate

                total_tests = total_tests + 1;

                // Check actual vs expected using case equality (!==)
                if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
                    $display("FAIL at time %0t: A=%b (%0d) B=%b (%0d) got GT=%b LT=%b EQ=%b expected GT=%b LT=%b EQ=%b",
                             $time, t_a, t_a, t_b, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
                    errors = errors + 1;
                end
            end
        end

        // Final summary output
        if (errors == 0) begin
            $display("ALL PASSED: %0d / %0d tests passed.", total_tests, total_tests);
        end else begin
            $display("TEST FAILED: %0d passed, %0d failed out of %0d tests.",
                     (total_tests - errors), errors, total_tests);
        end

        $finish;
    end

endmodule