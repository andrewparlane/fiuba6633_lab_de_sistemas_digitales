import cpu_pkg::*;

module decode
(
    input logic [7:0]   _iInst,

    output Operation    _oDecodeOp,
    output logic        _oDecodeValid,
    output logic        _oDecodeImm,
    output logic        _oDecodeCarry,
    output logic        _oDecodeALU
);

    always_comb begin
        // get _oDecodeOp
        // assume valid
        _oDecodeValid = 1;
        case (_iInst)
            OP_LOAD, OP_LOADI:                  _oDecodeOp = Operation_LOAD;
            OP_STORE, OP_STOREI:                _oDecodeOp = Operation_STORE;

            OP_ADD, OP_ADDC, OP_ADDI, OP_ADDIC: _oDecodeOp = Operation_ADD;
            OP_SUB, OP_SUBC, OP_SUBI, OP_SUBIC: _oDecodeOp = Operation_SUB;

            OP_NOR, OP_NORI:                    _oDecodeOp = Operation_NOR;
            OP_NAND, OP_NANDI:                  _oDecodeOp = Operation_NAND;
            OP_XOR, OP_XORI:                    _oDecodeOp = Operation_XOR;
            OP_XNOR, OP_XNORI:                  _oDecodeOp = Operation_XNOR;

            OP_JUMP:                            _oDecodeOp = Operation_JUMP;
            OP_JZ:                              _oDecodeOp = Operation_JZ;
            OP_JC:                              _oDecodeOp = Operation_JC;
            OP_JN:                              _oDecodeOp = Operation_JN;

            // use NOR in default case to avoid infering latches
            // should do nothing since, decodeValid isn't set
            default: begin
                _oDecodeOp = Operation_NOR;
                _oDecodeValid = 0;
            end
        endcase

        // get _oDecodeALU
        _oDecodeALU = (_iInst[7:6] == OP_TYPE_ARITH) ||
                      (_iInst[7:6] == OP_TYPE_LOGIC);

        // get _oDecodeImm
        case (_iInst)
            OP_LOADI, OP_STOREI,
            OP_ADDI, OP_SUBI, OP_ADDIC, OP_SUBIC,
            OP_NORI, OP_NANDI, OP_XORI, OP_XNORI:   _oDecodeImm = 1;
            default:                                _oDecodeImm = 0;
        endcase

        // get _oDecodeCarry
        case (_iInst)
            OP_ADDC, OP_SUBC,
            OP_ADDIC, OP_SUBIC:     _oDecodeCarry = 1;
            default:                _oDecodeCarry = 0;
        endcase
    end

endmodule
