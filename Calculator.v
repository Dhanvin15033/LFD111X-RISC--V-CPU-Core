// Owner: Dhanvin Prajapati

\m4_TLV_version 1d: tl-x.org
   
\SV
   
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/calc_viz.tlv']) 
\TLV
   
   $val1[31:0] = {26'b0, $val1_rand[5:0]};
   $val2[31:0] = {28'b0, $val2_rand[3:0]};
   
   $sum[31:0] = $val1[31:0] + $val2[31:0];
   $diff[31:0] = $val1[31:0] - $val2[31:0];
   $prod[31:0] = $val1[31:0] * $val2[31:0];
   $quot[31:0] = $val1[31:0] / $val2[31:0];
   
   $out[31:0] = $op[1:0] == 2'b00 ? $sum :
                $op[1:0] == 2'b01 ? $diff :
                $op[1:0] == 2'b10 ? $prod :
                                    $quot; //default 
                
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
   m4+calc_viz()
\SV
   endmodule
