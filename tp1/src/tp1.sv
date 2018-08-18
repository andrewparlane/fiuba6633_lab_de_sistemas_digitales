import cpu_pkg::*;

module tp1
(
    input logic         _iClk,
    input logic         _iReset,
    input logic [7:0]   _iInstMemData,
    input logic [7:0]   _iDataMemRData,

    output logic [7:0]  _oInstMemAddr,
    output logic [7:0]  _oDataMemAddr,
    output logic [7:0]  _oDataMemWData,
    output logic        _oDataMemWrite
);



    // ==============================================================
    // ALU
    // ==============================================================

    logic [7:0] accumulator;
    logic [7:0] aluArgB;
    logic       aluArgC;
    logic       aluEn;
    logic       aluOp;
    logic [7:0] aluRes;
    logic       aluFlagCarry;
    logic       aluFlagZero;
    logic       aluFlagNeg;

    alu aluInst
    (
        // Clock / reset
        ._iClk          (_iClk),
        ._iReset        (_iReset),

        // Arguments
        ._iA            (accumulator),
        ._iB            (aluArgB),
        ._iC            (aluArgC),

        // Control
        ._iEn           (aluEn),
        ._iOp           (aluOp),

        // Result
        ._oResult       (aluRes),

        // Flags
        ._oFlagCarry    (aluFlagCarry),
        ._oFlagZero     (aluFlagZero),
        ._oFlagNeg      (aluFlagNeg)
    );



endmodule
