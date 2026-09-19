// tb.v
// Starter testbench template -- YOU complete this file.

module tb;

    // Parameter configuration for override
    localparam TEST_WIDTH = 8;
    localparam TEST_DEPTH = 8;

    // TODO: declare the inputs and outputs
    reg  [$clog2(TEST_DEPTH)-1:0] t_sel;
    wire [TEST_WIDTH-1:0]         t_dout;

    // TODO: instantiate DUT here with parameter override
    lut #(
        .WIDTH(TEST_WIDTH),
        .DEPTH(TEST_DEPTH)
    ) DUT (
        .sel (t_sel),
        .dout(t_dout)
    );

    // Waveform dump configuration (DO NOT CHANGE)
    string vcd_file;
    initial begin
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(0, DUT);
        end
    end

    // Apply all address combinations
    integer k;
    initial begin
        // Initialize and cycle through all addresses 0 to DEPTH-1
        for (k = 0; k < TEST_DEPTH; k = k + 1) begin
            t_sel = k;
            #5;
        end
        $finish;
    end

    initial
        $monitor($time, "  sel=%d (%b) | dout=%d (%b)", t_sel, t_sel, t_dout, t_dout);

endmodule