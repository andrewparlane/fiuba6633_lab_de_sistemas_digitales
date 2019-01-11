# ----------------------------------------------------------------------
# Test_name: mult_test
# ----------------------------------------------------------------------
#
# RAM memory will be structured in the following manner:
#
# +---------+----------+
# | Address | Variable |
# +---------+----------+
# | RAM[00] | A        |
# | RAM[01] | B        |
# | RAM[02] | Y0       |
# | RAM[03] | Y1       |
# | RAM[04] | A0       |
# | RAM[05] | A1       |
# | RAM[06] | count    |
# +---------+----------+
#
# Where:
#  - Result: {Y1,Y0} = A*B
#  - Auxiliary: {A1,A0}
#  - count: multiplication loop counter
# ----------------------------------------------------------------------

LOADI A,0;        # Acc = 0, load the accumulator with 0
STORE A,0;        # A = 0, initialize A operand
STORE A,1;        # B = 0, initialize B operand

$begin:
LOADI A,0;        # Acc = 0, load the accumulator with 0
STORE A,2;        # Y0 = 0, initialize result Y0
STORE A,3;        # Y1 = 0, initialize result Y1
STORE A,4;        # A0 = 0, initialize auxiliary A0
STORE A,5;        # A1 = 0, initialize auxiliary A1
LOAD  A,0;        # Acc = A, load accum with A operand
STORE A,4;        # A0 = A, store in auxiliary A0 the operand A
LOADI A,8;        # Acc = 8, load the accumulator with 8
STORE A,6;        # count = 8, store the accumulator in the multiplication loop counter

$iter1:
LOAD  A,1;        # Iteration 1, load accum with B operand
NORI  A,254;      # A = B-operand ~| "11111110"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter2:
LOAD  A,1;        # Iteration 2, load accum with B operand
NORI  A,253;      # A = B-operand ~| "11111101"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter3:
LOAD  A,1;        # Iteration 3, load accum with B operand
NORI  A,251;      # A = B-operand ~| "11111011"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter4:
LOAD  A,1;        # Iteration 4, load accum with B operand
NORI  A,247;      # A = B-operand ~| "11110111"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter5:
LOAD  A,1;        # Iteration 5, load accum with B operand
NORI  A,239;      # A = B-operand ~| "11101111"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter6:
LOAD  A,1;        # Iteration 6, load accum with B operand
NORI  A,223;      # A = B-operand ~| "11011111"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter7:
LOAD  A,1;        # Iteration 7, load accum with B operand
NORI  A,191;      # A = B-operand ~| "10111111"
JUMP  $checkb;    # Go to load the accumulator with Y0

$iter8:
LOAD  A,1;        # Iteration 8: Acc = B-operand
NORI  A,127;      # Acc = B-operand ~| "01111111"

$checkb:
JZ    $loady0;    # If B operand is "00000000" then go to load the accumulatr with Y0
JUMP  $starta;    # Go to start A left shifting, Acc = A0

$loady0:
LOAD  A,2;        # Load the accumulator with Y0
ADD   A,4;        # Acc = Y0 + A0
STORE A,2;        # M[2] = Y0 + A0, store the accumulator in Y0
LOAD  A,3;        # Acc = Y1
ADDC  A,5;        # Acc = Acc + A1 + Cy = Y1 + A1 + Cy
STORE A,3;        # Store M[3] = Y1 + A1 + Cy

$starta:
LOAD  A,4;        # Start A left shifting, Acc = A0
ADD   A,4;        # Acc = A0 + A0
STORE A,4;        # M[4] = Acc = A0 + A0
LOAD  A,5;        # Acc = A1
ADDC  A,5;        # Acc = A1 + A1 + Cy
STORE A,5;        # End of A left shifting

LOAD  A,6;        # Acc = count
SUBI  A,1;        # Acc = count - 1
JZ    $end;       # Jump to END (test is finished)
STORE A,6;        # Store count with Acc
SUBI  A,1;        # Acc = Acc - 1 = count - 2
JZ    $iter8;     # Jump to iteration 8
SUBI  A,1;        # Acc = Acc - 1 = count - 3
JZ    $iter7;     # Jump to iteration 7
SUBI  A,1;        # Acc = Acc - 1 = count - 4
JZ    $iter6;     # Jump to iteration 6
SUBI  A,1;        # Acc = Acc - 1 = count - 5
JZ    $iter5;     # Jump to iteration 5
SUBI  A,1;        # Acc = Acc - 1 = count - 6
JZ    $iter4;     # Jump to iteration 4
SUBI  A,1;        # Acc = Acc - 1 = count - 7
JZ    $iter3;     # Jump to iteration 3
SUBI  A,1;        # Acc = Acc - 1 = count - 8
JZ    $iter2;     # Jump to iteration 2

$end:
LOAD  A,0;        # Load Acc with A
ADDI  A,1;        #
STORE A,0;        # A = A + 1
JC    $incb;      # If carry, increment B
JUMP  $begin;     # Loop

$incb:
LOAD  A,1;        # Load Acc with B
ADDI  A,1;        #
STORE A,1;        # B = B + 1
JUMP  $begin;     # Loop
