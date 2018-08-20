import cpu_pkg::*;

module alu_tb;

    // --------------------------------------------------------------
    // Ports to DUT
    // all named the same as in the DUT, so I can use .*
    // --------------------------------------------------------------

    // Arguments
    logic [7:0]     _iA;
    logic [7:0]     _iB;
    logic           _iC;

    // Control
    Operation       _iOp;

    // Result
    logic [7:0]     _oResult;

    // Flags
    logic           _oFlagCarry;
    logic           _oFlagZero;
    logic           _oFlagNeg;

    // --------------------------------------------------------------
    // DUT
    // --------------------------------------------------------------

    alu dut
    (
        .*
    );

    // --------------------------------------------------------------
    // Test stimulus
    // --------------------------------------------------------------

    Operation ops[] =
    {
        Operation_ADD,
        Operation_SUB,

        Operation_NOR,
        Operation_NAND,
        Operation_XOR,
        Operation_XNOR
    };

    typedef struct
    {
        Operation   op;
        logic [7:0] a;
        logic [7:0] b;
        logic       c;
        logic       expectedCarry;
    } CarryTest;

    CarryTest carryTests[] =
    '{
        '{ Operation_ADD,  'd100, 'd100, 0, 0 }, //  100 + 100 + 0 = no carry
        '{ Operation_ADD,  'd200, 'd100, 0, 1 }, //  200 + 100 + 0 = carry
        '{ Operation_ADD,  'd255,     0, 0, 0 }, //  255 +   0 + 0 = no carry
        '{ Operation_ADD,  'd255, 'd255, 0, 1 }, //  255 + 255 + 0 = carry
        '{ Operation_ADD, -'d100,  'd30, 0, 0 }, // -100 +  30 + 0 = no carry
        '{ Operation_ADD, -'d100, -'d30, 0, 1 }, // -100 + -30 + 0 = carry

        '{ Operation_ADD,      0, 'd100, 1, 0 }, //    0 + 100 + 1 = no carry
        '{ Operation_ADD,  'd100, 'd100, 1, 0 }, //  100 + 100 + 1 = no carry
        '{ Operation_ADD,  'd200, 'd100, 1, 1 }, //  200 + 100 + 1 = carry
        '{ Operation_ADD,  'd254,     0, 1, 0 }, //  254 +   0 + 1 = no carry
        '{ Operation_ADD,  'd255,     0, 1, 1 }, //  255 +   0 + 1 = carry
        '{ Operation_ADD,  'd255, 'd255, 1, 1 }, //  255 + 255 + 1 = carry
        '{ Operation_ADD, -'d100,  'd30, 1, 0 }, // -100 +  30 + 1 = no carry
        '{ Operation_ADD, -'d100, -'d30, 1, 1 }, // -100 + -30 + 1 = carry

        '{ Operation_SUB,  'd100,  'd100, 0, 0 }, //  100 -  100 - 0 = no carry
        '{ Operation_SUB,  'd255,  'd100, 0, 0 }, //  255 -  100 - 0 = no carry
        '{ Operation_SUB,  'd127, -'d128, 0, 1 }, //  127 - -128 - 0 = carry
        '{ Operation_SUB, -'d100,  'd100, 0, 0 }, // -100 -  100 - 0 = carry
        '{ Operation_SUB, -'d100, -'d100, 0, 0 }, // -100 - -100 - 0 = no carry

        '{ Operation_SUB,  'd100,  'd100, 1, 1 }, //  100 -  100 - 1 = no carry
        '{ Operation_SUB,  'd255,  'd100, 1, 0 }, //  255 -  100 - 1 = no carry
        '{ Operation_SUB,  'd127, -'d128, 1, 1 }, //  255 - -100 - 1 = carry
        '{ Operation_SUB, -'d100,  'd100, 1, 0 }, // -100 -  100 - 1 = carry
        '{ Operation_SUB, -'d100, -'d100, 1, 1 }  // -100 - -100 - 1 = carry
    };

    int     expectedRes;
    logic   expectedCarry;

    initial begin
        foreach (ops[op]) begin
            _iOp <= ops[op];
            $display("Performing tests on op: %s", ops[op].name);

            for (int a = 0; a <= 255; a++) begin
                _iA <= a;
                for (int b = 0; b <= 255; b++) begin
                    _iB <= b;
                    for (int c = 0; c <= 1; c++) begin
                        _iC <= c;

                        case (ops[op])
                            Operation_ADD: begin
                                expectedRes = a + b + c;
                                expectedCarry = expectedRes > 'hFF;
                            end

                            Operation_SUB: begin
                                expectedRes = a - (b + c);
                                expectedCarry = expectedRes > 'hFF;
                            end

                            Operation_NOR: begin
                                expectedRes = ~(a | b);
                                expectedCarry = 0;
                            end

                            Operation_NAND: begin
                                expectedRes = ~(a & b);
                                expectedCarry = 0;
                            end

                            Operation_XOR: begin
                                expectedRes = (a ^ b);
                                expectedCarry = 0;
                            end

                            Operation_XNOR: begin
                                expectedRes = ~(a ^ b);
                                expectedCarry = 0;
                            end

                            default: begin
                                // shouldn't get here.
                                expectedRes = 'x;
                                expectedCarry = 'x;
                            end
                        endcase

                        #10ns;

                        assert (expectedRes[7:0] == _oResult)
                            else $fatal("Test failed for op: %s, %x, %x, %x, expected %x, got %x",
                                   ops[op].name,
                                   a, b, c,
                                   expectedRes, _oResult);


                        assert (_oFlagNeg == expectedRes[7])
                            else $fatal("Test failed for op: %s, %x, %x, %x, expected neg %b, got %b",
                                   ops[op].name,
                                   a, b, c,
                                   expectedRes[7], _oFlagNeg);

                        assert (_oFlagZero == (expectedRes[7:0] == 0))
                            else $fatal("Test failed for op: %s, %x, %x, %x, expected zero %b, got %b",
                                   ops[op].name,
                                   a, b, c,
                                   (expectedRes[7:0] == 0), _oFlagZero);

                        assert (_oFlagCarry == expectedCarry)
                            else $fatal("Test failed for op: %s, %x, %x, %x, expected carry %b, got %b",
                                   ops[op].name,
                                   a, b, c,
                                   expectedCarry, _oFlagCarry);

                    end
                end
            end
        end

        // few extra tests to make sure carry flag behaves as expected
        $display("Performing carry tests");
        foreach (carryTests[test]) begin
            _iOp <= carryTests[test].op;
            _iA  <= carryTests[test].a;
            _iB  <= carryTests[test].b;
            _iC  <= carryTests[test].c;

            #10ns;

            assert (_oFlagCarry == carryTests[test].expectedCarry)
                else $fatal("Test failed for op: %s, %x, %x, %x, expected carry %b, got %b",
                       carryTests[test].op.name,
                       carryTests[test].a,
                       carryTests[test].b,
                       carryTests[test].c,
                       carryTests[test].expectedCarry,
                       _oFlagCarry);
        end
    end

endmodule
