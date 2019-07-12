import cpu_pkg::*;

module micro
(
    input logic         _iClk,
    input logic         _iReset,

    // Instruction ROM signals
    input  logic [7:0]  _iInstMemData,
    output logic [7:0]  _oInstMemAddr,

    // Data RAM signals
    input  logic [7:0]  _iDataMemRData,
    output logic [7:0]  _oDataMemAddr,
    output logic [7:0]  _oDataMemWData,
    output logic        _oDataMemWrite
);

    typedef enum logic [1:0]
    {
        State_IF = 'd0,     // Instruction Fetch
        State_AFD,          // Argument Fetch and decode
        State_MEM,          // Memory
        State_EXWB          // Execute and Write Back
    } State;

    // ==============================================================
    // Variables
    // ==============================================================

    logic rst;

    // the aluXXX vars are wires and not registered
    logic [7:0] aluArgB;
    logic       aluArgC;    // carry bit
    logic [7:0] aluRes;
    logic       aluFlagCarry;
    logic       aluFlagZero;
    logic       aluFlagNeg;

    // internal registers
    logic [7:0] pc;
    logic [7:0] inst;
    logic [7:0] arg;
    logic [7:0] mem;

    // external registers
    logic [7:0] accumulator;
    logic       flagCarry;
    logic       flagZero;
    logic       flagNeg;

    // State machine registers
    State       state;

    // Decode wires
    Operation   decodeOp;
    logic       decodeValid;
    logic       decodeImm;
    logic       decodeCarry;
    logic       decodeALU;

    // ==============================================================
    // Reset Syncroniser
    // ==============================================================
    reset_sync resetSync
    (
        ._iClk          (_iClk),
        ._iReset        (_iReset),
        ._oReset        (rst)
    );

    // ==============================================================
    // Decode
    // ==============================================================

    decode decodeInst
    (
        ._iInst         (inst),

        ._oDecodeOp     (decodeOp),
        ._oDecodeValid  (decodeValid),
        ._oDecodeImm    (decodeImm),
        ._oDecodeCarry  (decodeCarry),
        ._oDecodeALU    (decodeALU)
    );

    // ==============================================================
    // state machine
    // ==============================================================

    always_ff @(posedge _iClk, posedge rst) begin
        if (rst) begin
            pc          <= 0;
            inst        <= 0;
            arg         <= 0;
            mem         <= 0;

            accumulator <= 0;
            flagCarry   <= 0;
            flagZero    <= 1; // initialise to one because accumulator is 0
            flagNeg     <= 0;

            state       <= State_IF;

            _oInstMemAddr   <= 0;
            _oDataMemAddr   <= 0;
            _oDataMemWData  <= 0;
            _oDataMemWrite  <= 0;
        end
        else begin
            // should only ever be set for one clock tick
            // so bring it low if it was high
            _oDataMemWrite <= 0;

            case (state)
                State_IF: begin
                    // Register the read instruction
                    inst <= _iInstMemData;

                    // Request the argument
                    _oInstMemAddr <= pc | 1'h1;

                    state <= State_AFD;
                end

                State_AFD: begin
                    // Register the read argument
                    arg <= _iInstMemData;

                    // Many instructions require us to read from data memory
                    // all of those use the instruction argument as the address to
                    // read from. There's no harm in always reading, so just do it.
                    _oDataMemAddr <= _iInstMemData;
                    _oDataMemWData <= accumulator;

                    // The next pc is pc + 2
                    // unless there's a jump, in which case it's
                    // pc + 2 + arg
                    // so update pc to pc + 2 here
                    pc <= pc + 2'd2;

                    state <= State_MEM;
                end

                State_MEM: begin
                    // Register the read data memory
                    mem <= _iDataMemRData;

                    // Update PC
                    if ((decodeOp == Operation_JUMP) ||
                        ((decodeOp == Operation_JZ) && flagZero) ||
                        ((decodeOp == Operation_JC) && flagCarry) ||
                        ((decodeOp == Operation_JN) && flagNeg)) begin
                        pc <= pc + arg;
                    end

                    // In the next stage we deal with STORE instructions, by
                    // asserting the write line. We want the WData and the addr
                    // to be stable by then, so set them up here.
                    // There are two options:
                    //  1) STORE - address is the instruction argument
                    //             WData is the accumulator
                    //             We're already set up with this from the previous stage.

                    //  2) STOREI - address is the accumulator
                    //              WData is the instruction argument (immediat
                    if ((decodeOp == Operation_STORE) &&
                        decodeImm) begin
                        _oDataMemAddr <= accumulator;
                        _oDataMemWData <= arg;
                    end

                    state <= State_EXWB;
                end

                State_EXWB: begin
                    // if we are a store, then assert the WE pin now
                    // deasserted on the next clock.
                    if (decodeOp == Operation_STORE) begin
                        _oDataMemWrite <= 1;
                    end

                    // Update the accumulator and flags
                    if (decodeOp == Operation_LOAD) begin
                        if (decodeImm) begin
                            // loadi
                            accumulator <= arg;
                        end
                        else begin
                            // load
                            accumulator <= mem;
                        end
                    end
                    else if (decodeALU && decodeValid) begin
                        accumulator <= aluRes;
                        flagCarry   <= aluFlagCarry;
                        flagZero    <= aluFlagZero;
                        flagNeg     <= aluFlagNeg;
                    end

                    // start fetch of next instruction
                    _oInstMemAddr <= pc;

                    state <= State_IF;
                end
            endcase
        end
    end

    // ==============================================================
    // ALU
    // ==============================================================

    // calculate the ALU args based on the decoded instruction
    assign aluArgB = decodeImm   ? arg          : mem;
    assign aluArgC = decodeCarry ? flagCarry    : 0;

    alu aluInst
    (
        // Arguments
        ._iA            (accumulator),
        ._iB            (aluArgB),
        ._iC            (aluArgC),

        // Control
        ._iOp           (decodeOp),

        // Result
        ._oResult       (aluRes),

        // Flags
        ._oFlagCarry    (aluFlagCarry),
        ._oFlagZero     (aluFlagZero),
        ._oFlagNeg      (aluFlagNeg)
    );

endmodule
