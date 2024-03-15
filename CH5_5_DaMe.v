// Owner: Dhanvin Prajapati

\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])
                   
   m4_test_prog()

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   $pc[31:0] = >>1$next_pc[31:0];
   
   
   `READONLY_MEM($pc, $$instr[31:0]);
   
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_i_instr = $instr[6:2] ==? 5'b0000x || $instr[6:2] ==? 5'b001x0 || $instr[6:2] ==? 5'b11001;
   $is_r_instr = $instr[6:2] == 5'b01011 || $instr[6:2] == 5'b01100 || $instr[6:2] == 5'b01110 || $instr[6:2] == 5'b10100;
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_b_instr = $instr[6:2] == 5'b11000;
   $is_j_instr = $instr[6:2] == 5'b11011;
   
   $opcode[6:0] = $instr[6:0];
   $rd[4:0] = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0] = $instr[19:15];
   $rs2[4:0] = $instr[24:20];
   
   $imm[31:0] = $is_i_instr ? {{21{$instr[31]}},  $instr[30:20]} :
                $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
                $is_b_instr ? {{20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
                $is_u_instr ? {$instr[31:12], 12'b0} :
                $is_j_instr ? {{12{$instr[31]}}, {$instr[19:12]}, $instr[20], $instr[30:25], $instr[24:21], 1'b0} :
                              32'b0;  // Default
   
   $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
   $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $imm_valid = $is_i_instr || $is_s_instr || $is_b_instr || $is_u_instr || $is_j_instr; 
   
   $dec_bits[10:0] = {$instr[30], $funct3, $opcode};
   
   $is_lui = $dec_bits ==? 11'bxxxx0110111;
   $is_auipc = $dec_bits ==? 11'bxxxx0010111;
   $is_jal = $dec_bits ==? 11'bxxxx1101111;
   $is_jalr = $dec_bits ==? 11'bx0001100111;
   $is_beq = $dec_bits ==? 11'bx0001100011;
   $is_bne = $dec_bits ==? 11'bx0011100011;
   $is_blt = $dec_bits ==? 11'bx1001100011;
   $is_bge = $dec_bits ==? 11'bx1011100011;
   $is_bltu = $dec_bits ==? 11'bx1101100011;
   $is_bgeu = $dec_bits ==? 11'bx1111100011;
   $is_load = $opcode == 7'b0000011;
   $is_addi = $dec_bits ==? 11'bx0000010011;
   $is_slti = $dec_bits ==? 11'bx0100010011;
   $is_sltiu = $dec_bits ==? 11'bx0110010011;
   $is_xori = $dec_bits ==? 11'bx1000010011;
   $is_ori = $dec_bits ==? 11'bx1100010011;
   $is_andi = $dec_bits ==? 11'bx1110010011;
   $is_slli = $dec_bits == 11'b00010010011;
   $is_srli = $dec_bits == 11'b01010010011;
   $is_srai = $dec_bits == 11'b11010010011;
   $is_add = $dec_bits == 11'b00000110011;
   $is_sub = $dec_bits == 11'b10000110011;
   $is_sll = $dec_bits == 11'b00010110011;
   $is_slt = $dec_bits == 11'b00100110011;
   $is_sltu = $dec_bits == 11'b00110110011;
   $is_xor = $dec_bits == 11'b01000110011;
   $is_srl = $dec_bits == 11'b01010110011;
   $is_sra = $dec_bits == 11'b11010110011;
   $is_or = $dec_bits == 11'b01100110011;
   $is_and = $dec_bits == 11'b01110110011;
   
   `BOGUS_USE($rd $rd_valid $funct3 $funct3_valid $rs1 $rs1_valid $rs2 $rs2_valid $imm $imm_valid $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add); 
   
   m4+rf(32, 32, $reset, {$rd_valid}&&{$rd != 5'b0}, $rd, $is_load ? $ld_data : $result[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   
   // SLTU and SLTI (set if less than, unsigned) results:
   $sltu_rslt[31:0] = {31'b0, $src1_value < $src2_value};
   $sltiu_rslt[31:0] = {31'b0, $src1_value < $imm};
   
   // SRA and SRAI (shift right, arithmetic) results:
   // sign-extended src1
   $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value };
   //64-bit sign-extended results, to be truncated
   $sra_rslt[63:0] = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
   
   $result[31:0] = $is_lui ? {$imm[31:12], 12'b0} :
                   $is_auipc ? $pc + $imm :
                   $is_jal ? $pc + 32'd4 :
                   $is_jalr ? $pc + 32'd4 :
                   {$is_load || $is_s_instr} ? $src1_value + $imm :        
                   $is_addi ? $src1_value + $imm :
                   $is_slti ? ( ($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0, $src1_value[31]} ) :
                   $is_sltiu ? $sltiu_rslt :
                   $is_xori ? $src1_value ^ $imm :
                   $is_ori ? $src1_value | $imm :
                   $is_andi ? $src1_value & $imm :
                   $is_slli ? $src1_value << $imm[5:0] :
                   $is_srli ? $src1_value >> $imm[5:0] :
                   $is_srai ? $srai_rslt[31:0] : 
                   $is_add ? $src1_value + $src2_value :
                   $is_sub ? $src1_value - $src2_value :
                   $is_sll ? $src1_value << $src2_value[4:0] :
                   $is_slt ? ( ($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]} ) :
                   $is_sltu ? $sltu_rslt :
                   $is_xor ? $src1_value ^ $src2_value :
                   $is_srl ? $src1_value >> $src2_value[4:0] :
                   $is_sra ? $sra_rslt[31:0] :
                   $is_or ? $src1_value | $src2_value :
                   $is_and ? $src1_value & $src2_value :
                   32'b0;

   $is_branch = $is_beq || $is_bne || $is_blt || $is_bge || $is_bltu || $is_bgeu;
   
   $taken_br[31:0] = $is_beq ? $src1_value == $src2_value :
                     $is_bne ? $src1_value != $src2_value :
                     $is_blt ? {$src1_value < $src2_value}^{$src1_value[31] != $src2_value[31]} :
                     $is_bge ? {$src1_value >= $src2_value}^{$src1_value[31] != $src2_value[31]} :
                     $is_bltu ? {$src1_value < $src2_value} :
                     $is_bgeu ? {$src1_value >= $src2_value} :
                     1'b0;
  
   $br_tgt_pc[31:0] = $pc + $imm;
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   
   $next_pc[31:0] = $reset ? 32'b0 : 
                    {{$taken_br} || {$is_jal}} ? $br_tgt_pc : 
                    $is_jalr ? $jalr_tgt_pc :
                    $pc[31:0] + 32'd4;
   
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
                 
   m4+dmem(32, 32, $reset, $result[6:2], $is_s_instr, $src2_value[31:0], $is_load, $ld_data)
   m4+cpu_viz()
\SV
   endmodule
