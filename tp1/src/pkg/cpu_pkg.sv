package cpu_pkg;

    // ==============================================================
    // Operations
    // ==============================================================
    localparam [7:0] OP_ADD     = 'h40;
    localparam [7:0] OP_SUB     = 'h41;
    localparam [7:0] OP_ADD_C   = 'h42;
    localparam [7:0] OP_SUB_C   = 'h43;
    localparam [7:0] OP_ADD_I   = 'h44;
    localparam [7:0] OP_SUB_I   = 'h45;
    localparam [7:0] OP_ADD_IC  = 'h46;
    localparam [7:0] OP_SUB_IC  = 'h47;

    localparam [7:0] OP_NOR     = 'h80;
    localparam [7:0] OP_NAND    = 'h81;
    localparam [7:0] OP_XOR     = 'h82;
    localparam [7:0] OP_XNOR    = 'h83;
    localparam [7:0] OP_NOR_I   = 'h84;
    localparam [7:0] OP_NAND_I  = 'h85;
    localparam [7:0] OP_XOR_I   = 'h86;
    localparam [7:0] OP_XNOR_I  = 'h87;

    typedef enum
    {
        Operation_ADD,
        Operation_SUB,
        Operation_NOR,
        Operation_NAND,
        Operation_XOR,
        Operation_XNOR
    } Operation;
endpackage
