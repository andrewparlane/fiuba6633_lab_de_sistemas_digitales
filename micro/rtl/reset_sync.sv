module reset_sync
(
    input logic         _iClk,
    input logic         _iReset,
    output logic        _oReset
);

    // Reset syncroniser.
    // On _iReset asserting, _oReset immediately asserts.
    // On _iReset deasserting, _oReset deasserts after the
    // second rising edge of the clock

    logic tmp;

    always_ff @(posedge _iClk, posedge _iReset) begin
        if (_iReset) begin
            tmp <= 1;
            _oReset <= 1;
        end
        else begin
            tmp <= 0;
            _oReset <= tmp;
        end
    end

endmodule
