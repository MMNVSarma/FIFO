`include "fifo.v"
module fifo_tb();
parameter WIDTH = 8;
parameter DEPTH = 16;
parameter PTR_DEPTH = $clog2(DEPTH);
reg clk,rst;
reg read_en,write_en;
reg [DEPTH-1:0]write_data;
wire [DEPTH-1:0]read_data;
wire full,empty,read_error,write_error;
integer i,j;
reg [8*30:0] Testcase;
fifo f0(clk,rst,read_en,write_en,write_data,read_data,full,empty,write_error,read_error);
initial 
begin
clk = 1;
forever #5 clk = ~clk;
end

initial
begin
rst = 1;
rst_input();
#10;
rst = 0;
$value$plusargs("Testcase=%s",Testcase);
case(Testcase)
"Full_write": write(0,DEPTH);
"Full_write_read": 
             begin
			 write(0,DEPTH);
			 write_en = 0;
			 read(0,DEPTH);
			 read_en = 0;
			 end		
"Read_error":
			begin
           	 read(0,DEPTH);
			 read_en = 0;
			 end
"Write_error":begin
              write(0,DEPTH+5);
			  write_en = 0;
			  end
"Concurrent_write_read":
  begin
	write_en = 1;
	read_en = 1;
	/*
		for(i = 0; i <= DEPTH; i = i+1)
		begin  
    		   @(posedge clk);
	    	   write_data = $random();
				for(j = i; j<=i; j = j+1)
	 				begin
         				@(posedge clk);
	     			end
		end
	*/
		for(i = 0; i <= DEPTH; i = i+1)
		begin  
		      if(i == DEPTH)
			      write_en = 0;
	          else
			      begin
        	 	   @(posedge clk);
	        	   write_data = $random();
				   end
		end
	
		for(j = i; j<=i; j = j+1)
		begin
        	 	@(posedge clk);
	    end
		read_en = 0;
	end
endcase
#500;
$finish;
end

task rst_input;
begin
read_en = 0;
write_en = 0;
write_data = 0;
end
endtask

task write(input integer  start_loc,input integer end_loc); 
begin
if(~write_error)
    begin
	write_en = 1;
	for(i = start_loc; i < end_loc; i=i+1) 
	begin
		@(posedge clk) 
	    write_data = $random();
	end
    end
else
   write_en = 0;
end
endtask

task read(input integer  start_loc,input integer end_loc); 
begin
if(~read_error)
    begin
	read_en = 1;
	for(i = start_loc; i < end_loc; i=i+1) begin
	@(posedge clk); 
	end
	end
else
  read_en = 0;
end
endtask
endmodule
