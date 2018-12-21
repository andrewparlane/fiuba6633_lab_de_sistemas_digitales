module reset_sync_tb;

    // --------------------------------------------------------------
    // Ports to DUT
    // all named the same as in the DUT, so I can use .*
    // --------------------------------------------------------------

    logic _iClk;
    logic _iReset;
    logic _oReset;

    // --------------------------------------------------------------
    // DUT
    // --------------------------------------------------------------

    reset_sync dut
    (
        .*
    );

    // --------------------------------------------------------------
    // Generate the clock
    // --------------------------------------------------------------
    localparam CLOCK_FREQUENCY_MHZ = 100;
    localparam CLOCK_PERIOD_NS = 1000 / CLOCK_FREQUENCY_MHZ;

    initial begin
        _iClk <= 1'b0;
        forever begin
            #(CLOCK_PERIOD_NS/2);
            _iClk <= ~_iClk;
        end
    end

    // --------------------------------------------------------------
    // Test stimulus
    // --------------------------------------------------------------

    initial begin
        _iReset = 0;
        repeat (5) @(posedge _iClk);
        #7 _iReset = 1;
        repeat (5) @(posedge _iClk);
        #3 _iReset = 0;
        repeat (5) @(posedge _iClk);
        $stop;
    end

endmodule
