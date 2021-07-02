module fifo_memory(out,fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow,clk, rst_n, wr, rd, in);  
  input wr, rd, clk, rst_n;  
  input[7:0] in;   
  output[7:0] out;  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  wire[4:0] wrptr,rdptr;  
  wire fifo_we,fifo_rd;   
  write_pointer top1(wrptr,fifo_we,wr,fifo_full,clk,rst_n);  
  read_pointer top2(rdptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  memory_array top3(out, in, clk,fifo_we, wrptr,rdptr);  
  status_signal top4(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wrptr,rdptr,clk,rst_n);  
 endmodule  

 module memory_array(out, in, clk,fifo_we, wrptr,rdptr);  
  input[7:0] in;  
  input clk,fifo_we;  
  input[4:0] wrptr,rdptr;  
  output[7:0] out;  
  reg[7:0] out2[15:0];  
  wire[7:0] out;  
  always @(posedge clk)  
  begin  
   if(fifo_we)   
      out2[wrptr[3:0]] <=in ;  
  end  
  assign out = out2[rdptr[3:0]];  
 endmodule  

 module read_pointer(rdptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  input rd,fifo_empty,clk,rst_n;  
  output[4:0] rdptr;  
  output fifo_rd;  
  reg[4:0] rdptr;  
  assign fifo_rd = (~fifo_empty)& rd;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) rdptr <= 5'b00000;  
   else if(fifo_rd)  
    rdptr <= rdptr + 5'b00001;  
   else  
    rdptr <= rdptr;  
  end  
 endmodule  

 module status_signal(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wrptr,rdptr,clk,rst_n);  
  input wr, rd, fifo_we, fifo_rd,clk,rst_n;  
  input[4:0] wrptr, rdptr;  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  wire fbit_comp, overflow_set, underflow_set;  
  wire pointer_equal;  
  wire[4:0] pointer_result;  
  reg fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  assign fbit_comp = wrptr[4] ^ rdptr[4];  
  assign pointer_equal = (wrptr[3:0] - rdptr[3:0]) ? 0:1;  
  assign pointer_result = wrptr[4:0] - rdptr[4:0];  
  assign overflow_set = fifo_full & wr;  
  assign underflow_set = fifo_empty&rd;  
  always @(*)  
  begin  
   fifo_full =fbit_comp & pointer_equal;  
   fifo_empty = (~fbit_comp) & pointer_equal;  
   fifo_threshold = (pointer_result[4]||pointer_result[3]) ? 1:0;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_overflow <=0;  
  else if((overflow_set==1)&&(fifo_rd==0))  
   fifo_overflow <=1;  
   else if(fifo_rd)  
    fifo_overflow <=0;  
    else  
     fifo_overflow <= fifo_overflow;  
  end  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_underflow <=0;  
  else if((underflow_set==1)&&(fifo_we==0))  
   fifo_underflow <=1;  
   else if(fifo_we)  
    fifo_underflow <=0;  
    else  
     fifo_underflow <= fifo_underflow;  
  end  
 endmodule  

 module write_pointer(wrptr,fifo_we,wr,fifo_full,clk,rst_n);  
  input wr,fifo_full,clk,rst_n;  
  output[4:0] wrptr;  
  output fifo_we;  
  reg[4:0] wrptr;  
  assign fifo_we = (~fifo_full)&wr;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) wrptr <= 5'b00000;  
   else if(fifo_we)  
    wrptr <= wrptr + 5'b00001;  
   else  
    wrptr <= wrptr;  
  end  
 endmodule  