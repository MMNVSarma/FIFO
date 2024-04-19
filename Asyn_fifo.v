module Asyn_fifo(wr_clk,rd_clk,rst,write_en,read_en,write_data,read_data,full,empty,read_error,write_error);
parameter WIDTH = 8;
parameter DEPTH = 16;
parameter PTR_DEPTH = $clog2(DEPTH);
input wr_clk,rd_clk,rst;
input read_en,write_en;
input [WIDTH-1:0] write_data;
output reg [WIDTH-1:0] read_data;
output reg full,empty,read_error,write_error;
reg [PTR_DEPTH-1:0] rd_ptr,wr_ptr,rd_ptr_wr_clk,wr_ptr_rd_clk;
reg wr_toggle_flag,rd_toggle_flag,wr_toggle_flag_rd_clk,rd_toggle_flag_wr_clk;

integer i;
reg [WIDTH-1:0] memory[DEPTH-1:0];
always@(posedge wr_clk) begin
if(rst)
begin
read_data = 0;
full = 0;
empty = 1;
read_error = 0;
write_error = 0;
rd_ptr = 0;
wr_ptr = 0;
rd_ptr_wr_clk = 0;
wr_ptr_rd_clk = 0;
wr_toggle_flag = 0;
rd_toggle_flag = 0;
rd_toggle_flag_wr_clk = 0;
wr_toggle_flag_rd_clk = 0;
for(i = 0;i< DEPTH;i=i+1) memory[i] = 0;
end
    else
        begin
            if(write_en) 
                begin
                    if(full)
                        write_error = 1;
                    else
                        begin
                             memory[wr_ptr] = write_data;
                              write_error = 0;
							      if(wr_ptr == DEPTH-1)
                                       wr_toggle_flag = ~wr_toggle_flag;
						     wr_ptr = wr_ptr + 1;
                          end
                      end 
               end
        end
always@(posedge rd_clk)
begin
      if(!rst)
           begin
		  if(read_en)begin
              if(empty)
                  read_error = 1;
               else
                   begin
                        read_data = memory[rd_ptr];
                           read_error = 0;
							if(rd_ptr == DEPTH-1)
							    rd_toggle_flag = ~rd_toggle_flag;
					    rd_ptr = rd_ptr + 1;
                   end
          end
	end
end


//Synchronization of wr_clk with rd_ptr_wr_clk
always@(posedge wr_clk) begin
rd_ptr_wr_clk <= rd_ptr;
rd_toggle_flag_wr_clk <= rd_toggle_flag;
end
//Synchronization of rd_clk with wr_ptr_rd_clk
always@(posedge rd_clk) begin
wr_ptr_rd_clk <= wr_ptr;
wr_toggle_flag_rd_clk <= wr_toggle_flag;
end

always@(*) begin
if(wr_ptr == rd_ptr_wr_clk && wr_toggle_flag != rd_toggle_flag_wr_clk)
     full = 1;
else
     full = 0;
if(wr_ptr_rd_clk == rd_ptr && wr_toggle_flag_rd_clk == rd_toggle_flag)
     empty = 1;
else
     empty = 0;
end

endmodule
