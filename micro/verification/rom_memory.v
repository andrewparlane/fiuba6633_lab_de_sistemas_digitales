




// -----------------------------------------------------------------------------
// Copyright (C) 2012 by Octavio H. Alpago
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 59 Temple
// Place - Suite 330, Boston, MA  02111-1307, USA.
//
// -----------------------------------------------------------------------------
// Description:
// ------------
// ROM memory.
//
// -----------------------------------------------------------------------------
// File name:
// ----------
//
// rom_memory.v
//
// -----------------------------------------------------------------------------
// Interface:
// ----------
//
//    Clock, reset & enable inputs:
//       - none.
//
//    Data inputs:
//       - address  : memory address (N_ADDRESS bits, unsigned).
//
//    Data outputs:
//       - data_out : memory read data (WIDTH bits, unsigned).
//
// -----------------------------------------------------------------------------
// Parameters:
// -----------
//    - WIDTH            : number of bits of memory locations (positive integer).
//    - N_ADDRESS        : address bits number (positive integer).
//    - MEMORY_FILE_PATH : initialization memory file path (string).
//
// -----------------------------------------------------------------------------
// History:
// --------
// 2012/08/15 - O. Alpago  - Original Version
//
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

// *****************************************************************************
// Interface
// *****************************************************************************
module rom_memory #(
   parameter WIDTH            = 8,
   parameter N_ADDRESS        = 8,
   parameter MEMORY_FILE_PATH = "rom_mem.dat"
   ) (
   // -----------------------------
   // Data inputs
   // -----------------------------
   input  wire [N_ADDRESS-1:0] address,
   // -----------------------------
   // Data outputs
   // -----------------------------
   output wire [WIDTH-1:0]     data_out
   );
// *****************************************************************************

// *****************************************************************************
// Architecture
// *****************************************************************************
   reg [WIDTH-1:0] matrix [0:2**N_ADDRESS-1];

   initial begin
      $readmemh(MEMORY_FILE_PATH,matrix);
   end

   assign data_out = matrix[address];

   // Timing paths
   specify
      specparam ACCESS_TIME = 8.9;
      (address *> data_out) = ACCESS_TIME;
   endspecify
// *****************************************************************************
endmodule
