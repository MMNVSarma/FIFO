module fifo(clk,rst,read_en,write_en,write_data,read_data,full,empty,write_error,read_error);
parameter WIDTH = 8;
parameter DEPTH = 16;
parameter PTR_DEPTH = $clog2(DEPTH);
input clk,rst;
input read_en,write_en;
input [WIDTH-1:0]write_data;
output reg [WIDTH-1:0]read_data;
output reg full,empty,read_error,write_error;
reg[PTR_DEPTH-1:0] wr_ptr,rd_ptr;
reg wr_toggle_flag,rd_toggle_flag;
reg [WIDTH-1:0] memory[DEPTH-1:0];
integer i;
always@(posedge clk) begin
if(rst)
 begin
     read_data = 0;
     full = 0;
     empty = 1;
     read_error = 0;
     write_error = 0;
     wr_ptr = 0;
     rd_ptr = 0;
     wr_toggle_flag = 0;
     rd_toggle_flag = 0;
     for(i = 0; i<DEPTH; i=i+1) memory[i] = 0;
 end
else
 begin
    if(write_en) begin
        if(full) 
           write_error = 1;
        else
           begin
           memory[wr_ptr] = write_data;
           wr_ptr = wr_ptr + 1;
			   if(wr_ptr == DEPTH-1) 
			       	wr_toggle_flag = ~wr_toggle_flag;
           end   
	end
	
if(read_en) begin
        if(empty)
             read_error = 1;
         else
		  begin
           read_data = memory[rd_ptr];
           rd_ptr = rd_ptr + 1;
		   		if(rd_ptr == DEPTH-1) 
            		rd_toggle_flag = ~rd_toggle_flag;
		   end
end       
	if(wr_ptr == rd_ptr && rd_toggle_flag != wr_toggle_flag)
             full = 1;
	else
	     full = 0;
	if(wr_ptr == rd_ptr && rd_toggle_flag == wr_toggle_flag)
       empty = 1;
	else
	   empty = 0;

end
end
endmodule
