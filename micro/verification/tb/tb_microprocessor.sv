// -----------------------------------------------------------------------------
// Copyright (c) 2013 by Fabricio Alcalde and Gabriel Sanca
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; version 2.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
// 02111-1307, USA.
//
// -----------------------------------------------------------------------------
// File name:
// ----------
//
// tb_microprocessor.v
//
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

`define RAM_FILE_PATH "ram_mem.dat"

module micro_tb #
(
    // Test names: mult_test/nand_test/xor_test/nor_test/add_test/sub_test
    parameter TEST_NAME = "mult_test",
    // ROM name = TEST_NAME.dat
    parameter ROM_FILE_PATH = "mult_test.dat"
);

   // --------------------------------------------------------------------
   // Testbench signals
   // --------------------------------------------------------------------
   reg             tb_clk;
   reg             tb_rst;
   wire     [ 7:0] tb_ram_word_rd;
   wire     [ 7:0] tb_rom_word;
   wire     [ 7:0] tb_ram_addr;
   wire     [ 7:0] tb_rom_addr;
   wire     [ 7:0] tb_ram_word_wr;
   wire            tb_ram_write_ena;
   // --------------------------------------------------------------------

   // --------------------------------------------------------------------
   // Device under verification (DUV)
   // --------------------------------------------------------------------
   micro duv(._iClk            (tb_clk),
             ._iReset          (tb_rst),

             ._iInstMemData    (tb_rom_word),
             ._oInstMemAddr    (tb_rom_addr),

             ._oDataMemWData   (tb_ram_word_wr),
             ._iDataMemRData   (tb_ram_word_rd),
             ._oDataMemAddr    (tb_ram_addr),
             ._oDataMemWrite   (tb_ram_write_ena));
   // --------------------------------------------------------------------

   // --------------------------------------------------------------------
   // Data memory
   // --------------------------------------------------------------------
   ram_memory #(
      .WIDTH            (8),
      .N_ADDRESS        (8),
      .MEMORY_FILE_PATH (`RAM_FILE_PATH)
   ) ram (
      // ----------------------------------
      // Inputs
      // ----------------------------------
      .address       (tb_ram_addr),
      .data_in       (tb_ram_word_wr),
      .wr_ena        (tb_ram_write_ena),
      // ----------------------------------
      // Outputs
      // ----------------------------------
      .data_out      (tb_ram_word_rd)
   );
   // --------------------------------------------------------------------

   // --------------------------------------------------------------------
   // Program memory
   // --------------------------------------------------------------------
   rom_memory #(
      .WIDTH            (8),
      .N_ADDRESS        (8),
      .MEMORY_FILE_PATH (ROM_FILE_PATH)
   ) rom (
      // ----------------------------------
      // Inputs
      // ----------------------------------
      .address       (tb_rom_addr),
      // ----------------------------------
      // Outputs
      // ----------------------------------
      .data_out      (tb_rom_word)
   );
   // --------------------------------------------------------------------

   // --------------------------------------------------------------------
   // Tests
   // --------------------------------------------------------------------
   task mult_test;
      reg      [15:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         $display("i=%0d", i);
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'h87);
            if (tb_rom_addr==8'h87) begin
               gld_ref = (i*j);
               duv_val = {ram.matrix[3],ram.matrix[2]};
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d * %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d * %0d = %0d",j,i,gld_ref);
               //$display ("");
               #50;
            end
            wait (tb_rom_addr!=8'h87);
         end
         #20;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task nand_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = ~(i&j);
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d ~& %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d ~& %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task nor_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = ~(i|j);
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d ~| %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d ~| %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task sub_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = j-i;
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d - %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d - %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task add_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = j+i;
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated: %0d + %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct   : %0d + %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task xor_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = j^i;
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d ^ %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d ^ %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask

   task xnor_test;
      reg      [7:0] gld_ref;
      reg      [15:0] duv_val;
      integer         error;
      integer         correct;
      integer         i;
      integer         j;
   begin
      error = 0;
      correct = 0;
      #12 tb_rst = 1'b0;
      #10;
      for (i=0;i<256;i=i+1) begin
         for (j=0;j<256;j=j+1) begin
            wait (tb_rom_addr==8'd8);
            if (tb_rom_addr==8'd8) begin
               gld_ref = ~(j^i);
               duv_val = ram.matrix[2];
               if (gld_ref!=duv_val) begin
                  $display ("ERROR: Incorrect calculation @%0t ns.",$time);
                  error = error + 1;
               end
               else begin
                  //$display ("INFO: Correct calculation @%0t ns.",$time);
                  correct = correct + 1;
               end
               //$display ("Calculated : %0d ~^ %0d = %0d",ram.matrix[0],ram.matrix[1],duv_val);
               //$display ("Correct    : %0d ~^ %0d = %0d",j,i,gld_ref);
               //$display ("");
               #30;
            end
            wait (tb_rom_addr!=8'h8);
         end
         #30;
      end
      $display ("");
      $display ("INFO: Found %0d errors.",error);
      $display ("INFO: Found %0d correct values.",correct);
      $display ("");
   end
   endtask
   // --------------------------------------------------------------------

   // --------------------------------------------------------------------
   // Run simulation
   // --------------------------------------------------------------------
   initial begin
      $dumpfile ("./waves/microprocessor.vcd");
      $dumpvars;
   end

   always begin
      #5 tb_clk = ~tb_clk;
   end

   initial begin
      tb_clk   = 1'b0;
      tb_rst   = 1'b1;
      if (TEST_NAME == "mult_test") begin
        mult_test();
      end
      else if (TEST_NAME == "nand_test") begin
        nand_test();
      end
      else if (TEST_NAME == "xor_test") begin
        xor_test();
      end
      else if (TEST_NAME == "xnor_test") begin
        xnor_test();
      end
      else if (TEST_NAME == "nor_test") begin
        nor_test();
      end
      else if (TEST_NAME == "add_test") begin
        add_test();
      end
      else if (TEST_NAME == "sub_test") begin
        sub_test();
      end
      else begin
        $fatal(1, "Unknown test %s", TEST_NAME);
      end

      $finish;
   end
   // --------------------------------------------------------------------

endmodule
