#!/usr/bin/wish
######################################################################################
# Copyright (C) 2013 by Octavio H. Alpago
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
######################################################################################
# File name:
# ----------
#
# simulator.tcl
#
######################################################################################
# History:
# --------
#
# Sep. 30, 2014 - O. Alpago  - Original Version
#
######################################################################################
# TODO:
# -----
#
# Nothing.
#
######################################################################################

##################################################################
# Global vars definition
##################################################################
global asm_file_name
global file_types
global prog_counter
global flag_cy
global flag_z
global flag_n
global accum
global project_loaded
global sim_reset
global program_list
global rom_list
global ram_list
global accum_list
global pc_list
global c_list
global z_list
global n_list
##################################################################

##################################################################
# Default values
##################################################################
set asm_file_name ""
set file_types {
   {"Assembly files"  {.asm} }
   {"All files"       *}
}
set prog_counter 0
set flag_cy 0
set flag_z 0
set flag_n 0
set accum 0
set project_loaded "false"
set sim_reset "true"
##################################################################

##################################################################
# File Open dialog box
##################################################################
proc file_open_dialog {} {
   global file_types
   global asm_file_name
   global project_loaded
   global sim_reset
   set asm_file_name [tk_getOpenFile -filetypes ${file_types} -parent .]
   set comp_ok [compile_asm]
   if {${comp_ok}==1} {
      load_program_file
      load_rom_memory
      reset_ram_memory
      reset_sim
      set project_loaded "true"
      set sim_reset "true"
   } else {
      set project_loaded "false"
      set sim_reset "false"
   }
}
##################################################################

##################################################################
# Compile asm file
##################################################################
proc compile_asm {} {
   global asm_file_name
   if {[file exists "lsd_asm"]} {
      set status [catch {exec ./lsd_asm ${asm_file_name} ".temp.dat" > lsd_asm.log} result]
      if {[file exists "code.lst"]} {
         catch {file delete -force "code.lst"}
      }
      if {${status}==0 && [file exists ".temp.dat"]} {
         return 1
      } else {
         if {[file exists "code.lst"]} {
            catch {file delete -force "code.lst"}
         }
         if {[file exists ".temp.dat"]} {
            catch {file delete -force ".temp.dat"}
         }
         error_compile_msg_box
         return 0
      }
   } else {
      if {[file exists "code.lst"]} {
         catch {file delete -force "code.lst"}
      }
      if {[file exists ".temp.dat"]} {
         catch {file delete -force ".temp.dat"}
      }
      compiled_not_founded_msg_box
      return 0
   }
   return 1
}
##################################################################

##################################################################
# Load rom memory
##################################################################
proc load_rom_memory {} {
   global rom_list

   set f [open ".temp.dat" r]
   set i 0
   while {[gets ${f} line] >= 0} {
      set line [string trim ${line} " "]
      if {${line}!=""} {
         set line_dec [hex2dec ${line}]
         set line_bin [hex2bin ${line}]
         if {${i}<10} {
            $rom_list delete ${i}
            $rom_list insert ${i} "  ${i} :   H${line}   D${line_dec}   B${line_bin}"
         }
         if {${i}>9 && ${i}<100} {
            $rom_list delete ${i}
            $rom_list insert ${i} " ${i} :   H${line}   D${line_dec}   B${line_bin}"
         }
         if {${i}>99} {
            $rom_list delete ${i}
            $rom_list insert ${i} "${i} :   H${line}   D${line_dec}   B${line_bin}"
         }
         incr i
      }
   }
   close ${f}
}
##################################################################

##################################################################
# Hex to decimal conversion
##################################################################
proc hex2dec {hex_x} {
   scan ${hex_x} %x dec_x
   set char_num [string length ${dec_x}]
   if {${char_num}==1} {
      set dec_x "00${dec_x}"
   }
   if {${char_num}==2} {
      set dec_x "0${dec_x}"
   }
   if {${char_num}==3} {
      set dec_x "${dec_x}"
   }
   return ${dec_x}
}
##################################################################

##################################################################
# Hex to decimal conversion
##################################################################
proc hex2bin {hex_x} {
   binary scan [binary format H* ${hex_x}] B* bin_x
   return ${bin_x}
}
##################################################################

##################################################################
# Decimal to decimal conversion
##################################################################
proc dec2dec {dec} {
   set char_num [string length ${dec}]
   if {${char_num}==1} {
      set dec_x "00${dec}"
   }
   if {${char_num}==2} {
      set dec_x "0${dec}"
   }
   if {${char_num}==3} {
      set dec_x "${dec}"
   }
   return ${dec_x}
}
##################################################################

##################################################################
# Decimal to binary conversion
##################################################################
proc dec2bin {dec_x} {
   set res {}
   while {$dec_x>0} {
      set res [expr {$dec_x%2}]$res
      set dec_x [expr {$dec_x/2}]
   }
   if {$res == {}} {set res 0}
   set width 8
   append d [string repeat 0 $width] $res
   set res [string range $d [string length $res] end]
   return $res
}
##################################################################

##################################################################
# Decimal to binary conversion
##################################################################
proc bin2dec {bin} {
   set bin [split ${bin} ""]
   set nbit [llength ${bin}]
   set dec 0
   for {set i 0} {${i}<${nbit}} {incr i} {
      set power [expr ${nbit}-1-${i}]
      set weight [expr 1<<${power}]
      set bit [lindex ${bin} ${i}]
      set dec [expr ${dec}+${bit}*${weight}]
   }
   return ${dec}
}
##################################################################

##################################################################
# Decimal to decimal conversion
##################################################################
proc dec2hex {dec_x} {
   set hex_x [format %2.2X ${dec_x}]
   return ${hex_x}
}
##################################################################

##################################################################
# Clear project
##################################################################
proc clear_project {} {
   global project_loaded

   reset_ram_memory
   reset_rom_memory
   reset_program
   reset_accum
   reset_pc
   reset_flags
   if {[file exists "code.lst"]} {
      catch {file delete -force "code.lst"}
   }
   if {[file exists ".temp.dat"]} {
      catch {file delete -force ".temp.dat"}
   }
   set project_loaded "false"
}
##################################################################

##################################################################
# Reset sim
##################################################################
proc reset_sim {} {
   global sim_reset
   reset_accum
   reset_pc
   reset_flags
   reset_ram_memory
   set sim_reset "true"
}
##################################################################

##################################################################
# Run one simulation step
##################################################################
proc run_one_step {} {
   global project_loaded
   global prog_counter
   global accum
   global flag_cy
   global flag_z
   global flag_n
   global rom_list

   if {${project_loaded}} {
      set frst_iword [$rom_list get ${prog_counter}]
      set scnd_iword [$rom_list get [expr ${prog_counter}+1]]
      # Get first and second istruction word
      set frst_iword [split ${frst_iword} "B"]
      set frst_iword [lindex ${frst_iword} 1]
      set scnd_iword [split ${scnd_iword} "B"]
      set scnd_iword [lindex ${scnd_iword} 1]
      set scnd_iword [bin2dec ${scnd_iword}]
      # Parse first instruction word
      set frst_iword [split ${frst_iword} ""]
      if {[lindex ${frst_iword} 0]==0 && [lindex ${frst_iword} 1]==0} {
         if {[lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Load A,X : A <-- M[x]
            set_accum [get_ram ${scnd_iword}]
            const_ram
         }
         if {[lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Store X,A : M[x] <-- A
            save_ram ${scnd_iword} ${accum}
         }
         if {[lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Loadi A,I : A <-- I
            set_accum ${scnd_iword}
            const_ram
         }
         if {[lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Storei A,I : M[A] <-- I
            save_ram ${accum} ${scnd_iword}
         }
         set_pc [expr ${prog_counter}+2] ${prog_counter}
      }
      if {[lindex ${frst_iword} 0]==0 && [lindex ${frst_iword} 1]==1} {
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Add A,X : A <-- A+M[X]
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${accum}+${data_ram}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Sub A,X : A <-- A-M[X]
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${accum}-${data_ram}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Addc A,X : A <-- A+M[X]+Cy
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${accum}+${data_ram}+${flag_cy}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Subc A,X : A <-- A-M[X]-Cy
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${accum}-${data_ram}-${flag_cy}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Addi A,I : A <-- A+I
            set alu_result [expr ${accum}+${scnd_iword}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Subi A,I : A <-- A-I
            set alu_result [expr ${accum}-${scnd_iword}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Addic A,I : A <-- A+I+Cy
            set alu_result [expr ${accum}+${scnd_iword}+${flag_cy}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Subic A,I : A <-- A-I-Cy
            set alu_result [expr ${accum}-${scnd_iword}-${flag_cy}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         const_ram
         set_pc [expr ${prog_counter}+2] ${prog_counter}
      }
      if {[lindex ${frst_iword} 0]==1 && [lindex ${frst_iword} 1]==0} {
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Nor A,X : A <-- ~(A | M[X])
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${data_ram} | ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Nand A,X : A <-- ~(A & M[X])
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${data_ram} & ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Xor A,X : A <-- A ^ M[X]
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${data_ram} ^ ${accum}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==0 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Xnor A,X : A <-- ~(A ^ M[X])
            set data_ram [get_ram ${scnd_iword}]
            set alu_result [expr ${data_ram} ^ ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Nori A,I : A <-- ~(A | I)
            set alu_result [expr ${scnd_iword} | ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Nandi A,I : A <-- ~(A & I)
            set alu_result [expr ${scnd_iword} & ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Xori A,I : A <-- A ^ I
            set alu_result [expr ${scnd_iword} ^ ${accum}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         if {[lindex ${frst_iword} 5]==1 && [lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Xnori A,I : A <-- ~(A ^ I)
            set alu_result [expr ${scnd_iword} ^ ${accum}]
            set alu_result [expr ~${alu_result}]
            set alu_result [set_flags ${alu_result}]
            set_accum ${alu_result}
         }
         const_ram
         set_pc [expr ${prog_counter}+2] ${prog_counter}
      }
      if {[lindex ${frst_iword} 0]==1 && [lindex ${frst_iword} 1]==1} {
         if {[lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==0} {
            # Jump X : PC <-- PC + 2 + X
            set_pc [expr ${prog_counter}+${scnd_iword}+2] ${prog_counter}
         }
         if {[lindex ${frst_iword} 6]==0 && [lindex ${frst_iword} 7]==1} {
            # Jz X : if (Z==1) then PC <-- PC + 2 + X else PC <-- PC + 2
            if {${flag_z}==1} {
               set_pc [expr ${prog_counter}+${scnd_iword}+2] ${prog_counter}
            } else {
               set_pc [expr ${prog_counter}+2] ${prog_counter}
            }
         }
         if {[lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==0} {
            # Jc X : if (Cy==1) then PC <-- PC + 2 + X else PC <-- PC + 2
            if {${flag_cy}==1} {
               set_pc [expr ${prog_counter}+${scnd_iword}+2] ${prog_counter}
            } else {
               set_pc [expr ${prog_counter}+2] ${prog_counter}
            }
         }
         if {[lindex ${frst_iword} 6]==1 && [lindex ${frst_iword} 7]==1} {
            # Jn X : if (N==1) then PC <-- PC + 2 + X else PC <-- PC + 2
            if {${flag_n}==1} {
               set_pc [expr ${prog_counter}+${scnd_iword}+2] ${prog_counter}
            } else {
               set_pc [expr ${prog_counter}+2] ${prog_counter}
            }
         }
         const_ram
      }
   }
}
##################################################################

##################################################################
# Load program file
##################################################################
proc load_program_file {} {
   global asm_file_name
   global program_list

   set f [open ${asm_file_name} r]
   set address 0
   set i 0
   while {[gets ${f} line] >= 0} {
      set line [string trim ${line} " "]
      set line2 [split ${line} ""]
      set line2_first [lindex ${line2} 0]
      if {${line2_first}!="$" && ${line2_first}!="#" && ${line}!=""} {
         if {${address}<10} {
            ${program_list} delete ${i}
            ${program_list} insert ${i} "  ${address} :   ${line}"
         }
         if {${address}>9 && ${address}<100} {
            ${program_list} delete ${i}
            ${program_list} insert ${i} " ${address} :   ${line}"
         }
         if {${address}>99} {
            ${program_list} delete ${i}
            ${program_list} insert ${i} "${address} :   ${line}"
         }
         set address [expr ${address}+2]
      }
      if {${line2_first}=="$"} {
         ${program_list} delete ${i}
         ${program_list} insert ${i} "      ${line}"
      }
      if {${line2_first}=="#"} {
         ${program_list} delete ${i}
         ${program_list} insert ${i} "        ${line}"
      }
      if {${line2_first}==""} {
         ${program_list} delete ${i}
         ${program_list} insert ${i} ""
      }
      incr i
   }
   close ${f}
}
##################################################################

##################################################################
# Reset RAM
##################################################################
proc reset_ram_memory {} {
   global ram_list

   for {set i 0} {$i<256} {incr i} {
      $ram_list delete ${i}
      if {${i}<10} {
         $ram_list insert ${i} "  ${i} :   H00   D000   B00000000"
      }
      if {${i}<100 && ${i}>9} {
         $ram_list insert ${i} " ${i} :   H00   D000   B00000000"
      }
      if {${i}>99} {
         $ram_list insert ${i} "${i} :   H00   D000   B00000000"
      }
   }
}
##################################################################

##################################################################
# Reset ROM
##################################################################
proc reset_rom_memory {} {
   global rom_list

   for {set i 0} {$i<256} {incr i} {
      $rom_list delete ${i}
      if {${i}<10} {
         $rom_list insert ${i} "  ${i} :   H00   D000   B00000000"
      }
      if {${i}<100 && ${i}>9} {
         $rom_list insert ${i} " ${i} :   H00   D000   B00000000"
      }
      if {${i}>99} {
         $rom_list insert ${i} "${i} :   H00   D000   B00000000"
      }
   }
}
##################################################################

##################################################################
# Reset program
##################################################################
proc reset_program {} {
   global program_list

   for {set i 0} {$i<256} {set i [expr $i+2]} {
      $program_list delete [expr ${i}/2]
      if {${i}<10} {
         $program_list insert [expr ${i}/2] "  ${i} :"
      }
      if {${i}<100 && ${i}>9} {
         $program_list insert [expr ${i}/2] " ${i} :"
      }
      if {${i}>99} {
         $program_list insert [expr ${i}/2] "${i} :"
      }
   }
}
##################################################################

##################################################################
# Reset accumulator
##################################################################
proc reset_accum {} {
   set_accum 0
}
##################################################################

##################################################################
# Reset program counter
##################################################################
proc reset_pc {} {
   set_pc 0 0
}
##################################################################

##################################################################
# Reset flags
##################################################################
proc reset_flags {} {
   set_flags 0
}
##################################################################

##################################################################
# Set accum
##################################################################
proc set_accum {data} {
   global accum_list
   global accum

   set accum [expr ${data}%256]
   if {${accum}<0} {
      set accum [expr ${accum}+256]
      set accum [expr ${accum}%256]
   }
   set ac_bin [dec2bin ${accum}]
   set ac_hex [dec2hex ${accum}]
   set ac_dec [dec2dec ${accum}]
   $accum_list delete 0
   $accum_list insert 0 "H${ac_hex}   D${ac_dec}   B${ac_bin}"
}
##################################################################

##################################################################
# Set program counter
##################################################################
proc set_pc {address prev_address} {
   global pc_list
   global program_list
   global rom_list
   global prog_counter
   global program_list

   set prog_counter [expr ${address}%256]
   if {${prog_counter}==0} {
      set prev 254
   }
   if {${prog_counter}<0} {
      set prog_counter [expr ${prog_counter}+256]
      set prog_counter [expr ${prog_counter}%256]
   }
   set pc_bin [dec2bin ${prog_counter}]
   set pc_hex [dec2hex ${prog_counter}]
   set pc_dec [dec2dec ${prog_counter}]
   ${pc_list} delete 0
   ${pc_list} insert 0 "H${pc_hex}   D${pc_dec}   B${pc_bin}"

   if {${address}==0 && ${prev_address}==0} {
      set max_index [${rom_list} size]
      for {set i 0} {${i}<${max_index}} {incr i} {
         ${rom_list} itemconfigure ${i} -background white
      }
      ${rom_list} itemconfigure 0 -background gray
      ${rom_list} itemconfigure 1 -background gray
      ${rom_list} see 0
      set max_index [${program_list} size]
      for {set i 0} {${i}<${max_index}} {incr i} {
         ${program_list} itemconfigure ${i} -background white
      }
      for {set i 0} {${i}<${max_index}} {incr i} {
         set cur_address [${program_list} get ${i}]
         set cur_address [split ${cur_address} ":"]
         set cur_address [lindex ${cur_address} 0]
         set cur_address [string trim ${cur_address} " "]
         if {${cur_address}==0} {
            ${program_list} itemconfigure ${i} -background gray
            ${program_list} see ${i}
         }
      }
   } else {
      ${rom_list} itemconfigure ${prev_address} -background white
      ${rom_list} itemconfigure [expr ${prev_address}+1] -background white
      ${rom_list} itemconfigure ${prog_counter} -background gray
      ${rom_list} itemconfigure [expr ${prog_counter}+1] -background gray
      ${rom_list} see [expr ${prog_counter}+1]
      set max_index [${program_list} size]
      for {set i 0} {${i}<${max_index}} {incr i} {
         set cur_address [${program_list} get ${i}]
         set cur_address [split ${cur_address} ":"]
         set cur_address [lindex ${cur_address} 0]
         set cur_address [string trim ${cur_address} " "]
         if {${cur_address}==${address}} {
            ${program_list} itemconfigure ${i} -background gray
            ${program_list} see ${i}
         }
         if {${cur_address}==${prev_address}} {
            ${program_list} itemconfigure ${i} -background white
         }
      }
   }
}
##################################################################

##################################################################
# Set flags
##################################################################
proc set_flags {alu_result} {
   global c_list
   global z_list
   global n_list

   global flag_cy
   global flag_z
   global flag_n
   if {${alu_result}>255} {
      set flag_cy 1
   } else {
      set flag_cy 0
   }
   set alu_result [expr ${alu_result}%256]
   if {${alu_result}>127} {
      set flag_n 1
   } else {
      set flag_n 0
   }
   if {${alu_result}==0} {
      set flag_z 1
   } else {
      set flag_z 0
   }
   $c_list delete 0
   $c_list insert 0 ${flag_cy}
   $n_list delete 0
   $n_list insert 0 ${flag_n}
   $z_list delete 0
   $z_list insert 0 ${flag_z}
   return ${alu_result}
}
##################################################################

##################################################################
# Get data from RAM
##################################################################
proc get_ram {address} {
   global ram_list

   set data [$ram_list get ${address}]
   set data [split ${data} "D"]
   set data [lindex ${data} 1]
   set data [split ${data} " "]
   set data [lindex ${data} 0]
   set data [split ${data} ""]
   set dec 0
   set ndig [llength ${data}]
   for {set i 0} {${i}<${ndig}} {incr i} {
      set power [expr ${ndig}-1-${i}]
      set weight 1
      for {set j 1} {${j}<=${power}} {incr j} {
         set weight [expr 10*${weight}]
      }
      set dig [lindex ${data} ${i}]
      set dec [expr ${dec}+${dig}*${weight}]
   }
   set data [bin2dec ${dec}]
   return ${data}
}
##################################################################

##################################################################
# Save accum in from RAM
##################################################################
proc save_ram {address data} {
   global ram_list

   set data_bin [dec2bin ${data}]
   set data_hex [dec2hex ${data}]
   set data_dec [dec2dec ${data}]

   set max_index [${ram_list} size]
   for {set i 0} {${i}<${max_index}} {incr i} {
      ${ram_list} itemconfigure ${i} -foreground black
   }
   ${ram_list} delete ${address}
   if {${address}<10} {
      $ram_list insert ${address} "  ${address} :   H${data_hex}   D${data_dec}   B${data_bin}"
   }
   if {${address}<100 && ${address}>9} {
      $ram_list insert ${address} " ${address} :   H${data_hex}   D${data_dec}   B${data_bin}"
   }
   if {${address}>99} {
      $ram_list insert ${address} "${address} :   H${data_hex}   D${data_dec}   B${data_bin}"
   }
   ${ram_list} itemconfigure ${address} -foreground red
}
##################################################################

##################################################################
# RAM without any change
##################################################################
proc const_ram {} {
   global ram_list

   set max_index [${ram_list} size]
   for {set i 0} {${i}<${max_index}} {incr i} {
      ${ram_list} itemconfigure ${i} -foreground black
   }
}
##################################################################

##################################################################
# Bound ALU result to be positive
##################################################################
proc bound_alu {alu_result} {
   if {${alu_result}<0} {
      set bnd_alu_rslt [expr 256+${alu_result}]
   }
   return ${bnd_alu_rslt}
}
##################################################################

##################################################################
# About message box
##################################################################
proc about_msg_box {} {
   tk_messageBox -type ok -icon info -title About -message "8-bits microprocessor simulator\nFIUBA - Digital System Laboratory\nVersion 1.0.2013"
}
##################################################################

##################################################################
# Compilation failed message box
##################################################################
proc error_compile_msg_box {} {
   tk_messageBox -type ok -icon error -title Error -message "ERROR: Compilation failed!!!\nCheck lsd_asm.log file."
}
##################################################################

##################################################################
# Compiler not founded message box
##################################################################
proc compiled_not_founded_msg_box {} {
   tk_messageBox -type ok -icon error -title Error -message "ERROR: lsd_asm compiler not founded!!!"
}
##################################################################

##################################################################
# Generate GUI
##################################################################
proc exit_cmd {} {
   if {[file exists "code.lst"]} {
      catch {file delete -force "code.lst"}
   }
   if {[file exists ".temp.dat"]} {
      catch {file delete -force ".temp.dat"}
   }
   exit
}
##################################################################

##################################################################
# Generate GUI
##################################################################
menu .mbar
. configure -menu .mbar

menu .mbar.fl -tearoff 0
.mbar add cascade -menu .mbar.fl -label File -underline 0
.mbar.fl add command -label Open  -command { file_open_dialog }
.mbar.fl add command -label Close -command { clear_project }
.mbar.fl add command -label Exit  -command { exit_cmd }

menu .mbar.run -tearoff 0
.mbar add cascade -menu .mbar.run -label Simulate -underline 0
.mbar.run add command -label "One step" -command { run_one_step }
.mbar.run add command -label "Reset sim" -command { reset_sim }

menu .mbar.ab -tearoff 0
.mbar add cascade -menu .mbar.ab -label Help -underline 0
.mbar.ab add command -label About -command { about_msg_box }

button .run_but -text "Run one step" -command run_one_step
grid   .run_but -padx 5 -pady 5 -row 0 -column 0 -sticky nsew
button .reset_but -text "Reset simulation" -command reset_sim
grid   .reset_but -padx 5 -pady 5 -row 1 -column 0 -sticky nsew

labelframe .regs_lframe -text "Registers"
.regs_lframe configure -font {-family helvetica -size 10 -weight normal -slant roman}
label .regs_lframe.accum_label -text "Accum"
label .regs_lframe.pc_label -text "PC"
label .regs_lframe.flags_label -text "Flags"
set accum_list [listbox .regs_lframe.accum_list -bg white -width 22 -height 1 -selectbackground white -selectforeground black -selectborderwidth 0]
.regs_lframe.accum_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set pc_list [listbox .regs_lframe.pc_list -bg white -width 22 -height 1 -selectbackground white -selectforeground black -selectborderwidth 0]
.regs_lframe.pc_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
frame .regs_lframe.flags_frame
label .regs_lframe.flags_frame.c_label -text "C"
label .regs_lframe.flags_frame.z_label -text "Z"
label .regs_lframe.flags_frame.n_label -text "N"
set c_list [listbox .regs_lframe.flags_frame.c_list -bg white -width 1 -height 1 -selectbackground white -selectforeground black -selectborderwidth 0]
.regs_lframe.flags_frame.c_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set z_list [listbox .regs_lframe.flags_frame.z_list -bg white -width 1 -height 1 -selectbackground white -selectforeground black -selectborderwidth 0]
.regs_lframe.flags_frame.z_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set n_list [listbox .regs_lframe.flags_frame.n_list -bg white -width 1 -height 1 -selectbackground white -selectforeground black -selectborderwidth 0]
.regs_lframe.flags_frame.n_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
grid .regs_lframe -padx 5 -pady 5 -row 2 -column 0 -sticky news
grid .regs_lframe.accum_label -padx 5 -pady 15 -row 0 -column 0 -sticky news
grid .regs_lframe.accum_list  -padx 5 -pady 15 -row 0 -column 1 -sticky nsew
grid .regs_lframe.pc_label    -padx 5 -pady 15 -row 1 -column 0 -sticky news
grid .regs_lframe.pc_list     -padx 5 -pady 15 -row 1 -column 1 -sticky news
grid .regs_lframe.flags_label -padx 5 -pady 15 -row 2 -column 0 -sticky nsew
grid .regs_lframe.flags_frame -padx 5 -pady 15 -row 2 -column 1 -sticky nsew
grid .regs_lframe.flags_frame.c_label -padx 0 -pady 0 -row 0 -column 0 -sticky nsew
grid .regs_lframe.flags_frame.z_label -padx 0 -pady 0 -row 0 -column 1 -sticky nsew
grid .regs_lframe.flags_frame.n_label -padx 0 -pady 0 -row 0 -column 2 -sticky nsew
grid .regs_lframe.flags_frame.c_list  -padx 0 -pady 0 -row 1 -column 0 -sticky nsew
grid .regs_lframe.flags_frame.z_list  -padx 0 -pady 0 -row 1 -column 1 -sticky nsew
grid .regs_lframe.flags_frame.n_list  -padx 0 -pady 0 -row 1 -column 2 -sticky nsew

labelframe  .memmaps_lframe -text "Memory maps"
.memmaps_lframe configure -font {-family helvetica -size 10 -weight normal -slant roman}
label .memmaps_lframe.prog_label -text "Assembler code"
label .memmaps_lframe.rom_label -text "ROM memory"
label .memmaps_lframe.ram_label -text "RAM memory"
frame .memmaps_lframe.prog_frame
set program_list [listbox .memmaps_lframe.prog_frame.program_list -bg white -width 50 -height 12 -selectbackground white -selectforeground black -selectborderwidth 0]
.memmaps_lframe.prog_frame.program_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set rom_list [listbox .memmaps_lframe.rom_list -bg white -width 30 -height 12 -selectbackground white -selectforeground black -selectborderwidth 0]
.memmaps_lframe.rom_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set ram_list [listbox .memmaps_lframe.ram_list -bg white -width 30 -height 12 -selectbackground white -selectforeground black -selectborderwidth 0]
.memmaps_lframe.ram_list configure -font {-family "courier new" -size 12 -weight normal -slant roman}
set prog_scroll [scrollbar .memmaps_lframe.prog_frame.prog_scroll -command [list ${program_list} yview]]
${program_list} configure -yscrollcommand [list ${prog_scroll} set]
set prog_scroll_h [scrollbar .memmaps_lframe.prog_frame.prog_scroll_h -orient h -command [list ${program_list} xview]]
${program_list} configure -xscrollcommand [list ${prog_scroll_h} set]
set rom_scroll [scrollbar .memmaps_lframe.rom_scroll -command [list ${rom_list} yview]]
${rom_list} configure -yscrollcommand [list ${rom_scroll} set]
set ram_scroll [scrollbar .memmaps_lframe.ram_scroll -command [list ${ram_list} yview]]
${ram_list} configure -yscrollcommand [list ${ram_scroll} set]
label .memmaps_lframe.space_1 -text " "
label .memmaps_lframe.space_2 -text " "
label .memmaps_lframe.space_3 -text " "
label .memmaps_lframe.space_4 -text " "
grid .memmaps_lframe -padx 5 -pady 5 -row 0 -column 1 -rowspan 3 -sticky nsew
grid .memmaps_lframe.prog_label   -padx 0 -pady 0 -row 0 -column 1 -sticky nsew
grid .memmaps_lframe.rom_label    -padx 0 -pady 0 -row 0 -column 4 -sticky nsew
grid .memmaps_lframe.ram_label    -padx 0 -pady 0 -row 0 -column 7 -sticky nsew
grid .memmaps_lframe.space_1      -padx 0 -pady 2 -row 1 -column 0 -sticky nsew
grid .memmaps_lframe.prog_frame   -padx 0 -pady 2 -row 1 -column 1 -sticky nsew
grid .memmaps_lframe.prog_frame.program_list  -padx 0 -pady 0 -row 0 -column 0 -sticky nsew
grid .memmaps_lframe.prog_frame.prog_scroll   -padx 0 -pady 0 -row 0 -column 1 -sticky nsew
grid .memmaps_lframe.prog_frame.prog_scroll_h -padx 0 -pady 0 -row 1 -column 0 -columnspan 2 -sticky nsew
grid .memmaps_lframe.space_2      -padx 0 -pady 2 -row 1 -column 3 -sticky nsew
grid .memmaps_lframe.rom_list     -padx 0 -pady 2 -row 1 -column 4 -sticky nsew
grid .memmaps_lframe.rom_scroll   -padx 0 -pady 2 -row 1 -column 5 -sticky nsew
grid .memmaps_lframe.space_3      -padx 0 -pady 2 -row 1 -column 6 -sticky nsew
grid .memmaps_lframe.ram_list     -padx 0 -pady 2 -row 1 -column 7 -sticky nsew
grid .memmaps_lframe.ram_scroll   -padx 0 -pady 2 -row 1 -column 8 -sticky nsew
grid .memmaps_lframe.space_4      -padx 0 -pady 2 -row 1 -column 9 -sticky nsew

wm protocol . WM_DELETE_WINDOW exit_cmd
wm title . "LSD Simulator"
wm maxsize .
wm resizable . 0 0
##################################################################

##################################################################
# Start aplication
##################################################################
clear_project
##################################################################
