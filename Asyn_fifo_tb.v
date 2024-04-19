`include "Asyn_fifo.v"
module Asyn_fifo_tb();
parameter WIDTH = 8;
parameter DEPTH = 16;
reg wr_clk,rd_clk,rst;
reg read_en,write_en;
reg [WIDTH-1:0] write_data;
wire [WIDTH-1:0] read_data;
wire full,empty,read_error,write_error;
reg [8*30:0] Testcase;
integer i,j;
Asyn_fifo a0(wr_clk,rd_clk,rst,write_en,read_en,write_data,read_data,full,empty,read_error,write_error);

initial begin
wr_clk = 1;
forever #5 wr_clk = ~wr_clk;
end

initial begin
rd_clk = 1;
forever #10 rd_clk = ~rd_clk;
end

initial begin
rst = 1;
reset();
#10;
rst = 0;
$value$plusargs("Testcase=%s",Testcase);
case(Testcase)
"Full_write": write(DEPTH);
"Full_write_read": 
             begin
			 write(DEPTH);
			 read(DEPTH);
			 end		
"Read_error":
			begin
           	 read(DEPTH);
			 end
"Write_error":begin
              write(DEPTH+5);
			  end
"Concurrent_write_read":
  begin
	write_en = 1;
	read_en = 1;
		for(i = 0; i <= DEPTH; i = i+1)
		begin  
		      if(i == DEPTH)
			      write_en = 0;
	          else
			      begin
        	 	   @(posedge wr_clk);
	        	   write_data = $random();
				   end
		end
	
		for(j = i; j<=i; j = j+1)
		begin
		       if(i == DEPTH)
			        read_en = 0;
				else
        	 	    @(posedge rd_clk);
	    end
		
	end
endcase
#500;
$finish;
end

task reset();
begin
write_data=0;
read_en = 0;
write_en = 0;
end
endtask

task write(input integer no_of_loc);
begin
for(i = 0;i< DEPTH;i=i+1)
begin
    write_en = 1;
@(posedge wr_clk);
  	write_data = $random();
end
write_en = 0;
end
endtask

task read(input integer no_of_loc);
begin
for(i = 0;i< DEPTH;i=i+1)
	begin
	 read_en = 1;
	@(posedge rd_clk);
  	end
read_en = 0;
end
endtask
endmodule
