package cpu_pkg;

    // ==============================================================
    // Operations
    // ==============================================================
    localparam [1:0] OP_TYPE_MEM    = 'h0;
    localparam [1:0] OP_TYPE_ARITH  = 'h1;
    localparam [1:0] OP_TYPE_LOGIC  = 'h2;
    localparam [1:0] OP_TYPE_JUMP   = 'h3;

    localparam [7:0] OP_LOAD    = 'h00;
    localparam [7:0] OP_STORE   = 'h01;
    localparam [7:0] OP_LOADI   = 'h02;
    localparam [7:0] OP_STOREI  = 'h03;

    localparam [7:0] OP_ADD     = 'h40;
    localparam [7:0] OP_SUB     = 'h41;
    localparam [7:0] OP_ADDC    = 'h42;
    localparam [7:0] OP_SUBC    = 'h43;
    localparam [7:0] OP_ADDI    = 'h44;
    localparam [7:0] OP_SUBI    = 'h45;
    localparam [7:0] OP_ADDIC   = 'h46;
    localparam [7:0] OP_SUBIC   = 'h47;

    localparam [7:0] OP_NOR     = 'h80;
    localparam [7:0] OP_NAND    = 'h81;
    localparam [7:0] OP_XOR     = 'h82;
    localparam [7:0] OP_XNOR    = 'h83;
    localparam [7:0] OP_NORI    = 'h84;
    localparam [7:0] OP_NANDI   = 'h85;
    localparam [7:0] OP_XORI    = 'h86;
    localparam [7:0] OP_XNORI   = 'h87;

    localparam [7:0] OP_JUMP    = 'hC0;
    localparam [7:0] OP_JZ      = 'hC1;
    localparam [7:0] OP_JC      = 'hC2;
    localparam [7:0] OP_JN      = 'hC3;

    typedef enum
    {
        Operation_LOAD,
        Operation_STORE,
        Operation_ADD,
        Operation_SUB,
        Operation_NOR,
        Operation_NAND,
        Operation_XOR,
        Operation_XNOR,
        Operation_JUMP,
        Operation_JZ,
        Operation_JC,
        Operation_JN
    } Operation;
endpackage
