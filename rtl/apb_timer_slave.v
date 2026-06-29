module apb_timer_slave #(parameter width=8)(
input  wire PCLK,
input wire PRESETn,
input wire [7:0]PADDR,
input wire PSEL,
input wire PENABLE,
input wire PWRITE,
input wire [31:0]PWDATA,
output wire PREADY, //PREADY is made a wire here
output reg timer_done,    //timer_done=1 indicates counting done
output reg[31:0]PRDATA);
reg[width-1:0]load;               //to load the counter value from which we have to start downcounting,value is fixed
reg[width-1:0] count;     //to store the current value of timer,the value in this reg keeps on changing as timer operates
reg running;      //running=1 timer starts, running=0 timer stops
assign PREADY=1'b1; //slave is  always ready
always@(posedge PCLK or negedge PRESETn)//write operation
begin
	if(!PRESETn)begin
	load<=0;
        count<=0;
	running<=0;
        timer_done<=0;
end
else if(PWRITE && PENABLE && PSEL)
begin
	case(PADDR)
	8'h00:load<=PWDATA[width-1:0];
	8'h04: begin running<=PWDATA[0];
	if(PWDATA[0])
	begin count<=load;
	timer_done<=0;end end default:;
endcase
end
end
always@(*) //read operation
begin
PRDATA=32'b0;
if(PSEL && PENABLE && !PWRITE)
begin case(PADDR) 
8'h00: PRDATA = {{(32-width){1'b0}}, load};
8'h04: PRDATA = {31'b0, running};
8'h08: PRDATA = {31'b0, timer_done};
8'h0C: PRDATA = {{(32-width){1'b0}}, count};
default: PRDATA = 32'b0;
endcase
end
end
always@(posedge PCLK or negedge PRESETn) //timer logic
begin
if(!PRESETn)
begin
	count<=0;
	timer_done<=1'b0;

end
else if (running)
begin
	if(count==0)begin
		timer_done<=1'b1;
	running<=1'b0; end
	else
		count<=count-1;
end

end
endmodule

