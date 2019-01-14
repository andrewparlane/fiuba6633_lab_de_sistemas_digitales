import cpu_pkg::*;

module alu
(
    // Arguments
    input logic [7:0]   _iA,    // accumulator
    input logic [7:0]   _iB,    // immediate / memory
    input logic         _iC,    // carry bit from previous instruction

    // Control
    input Operation     _iOp,

    // Result
    output logic [7:0]  _oResult,

    // Flags
    output logic        _oFlagCarry,
    output logic        _oFlagZero,
    output logic        _oFlagNeg
);

    // 9 bits so we can get the carry bit
    logic [8:0] tmp;

    always_comb begin
        case (_iOp)
            Operation_ADD: begin
                tmp = _iA + _iB + _iC;
            end

            Operation_SUB: begin
                tmp = _iA - _iB - _iC;
            end

            // The following operations don't generate carry flags
            // so make sure the upper bit of tmp is 0
            Operation_NOR: begin
                tmp = {1'b0, ~(_iA | _iB)};
            end

            Operation_NAND: begin
                tmp = {1'b0, ~(_iA & _iB)};
            end

            Operation_XOR: begin
                tmp = {1'b0, (_iA ^ _iB)};
            end

            Operation_XNOR: begin
                tmp = {1'b0, ~(_iA ^ _iB)};
            end

            default: begin
                tmp = 0;
            end
        endcase

        _oResult     = tmp[7:0];
        _oFlagCarry  = tmp[8];
        _oFlagNeg    = tmp[7];
        _oFlagZero   = (tmp[7:0] == 0);
    end


endmodule
