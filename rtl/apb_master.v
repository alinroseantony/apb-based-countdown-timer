
module apb_master(input wire PCLK,
input wire PRESETn,
input wire  [31:0]addr,
input wire [31:0]wdata,
input wire rw,
input wire req,
input wire PREADY,
input wire [31:0]PRDATA,
output reg ready,
output reg PSEL,
output reg [31:0]rdata,
output reg [31:0]PADDR,
output reg [31:0]PWDATA,
output reg PWRITE,
output reg PENABLE);
reg[1:0]state,n_state;
localparam idle=2'b00;
localparam setup=2'b01;
localparam access=2'b10;
always@(posedge PCLK or negedge PRESETn)
begin
        if(!PRESETn)
                state<= idle;
        else
                state<= n_state;
end
always@(*)
begin
case(state)
idle:begin
if(req)n_state=setup;
else
        n_state=idle;
end
setup: begin n_state=access;end
access: if(PREADY)
begin
        if(req)
                n_state=setup;
        else
                n_state=idle;

end
else n_state=access;
default:n_state=idle;
endcase
end
always@(*)
begin
PADDR=32'b0;
PWRITE=1'b0;
PSEL=1'b0;
PENABLE=1'b0;
PWDATA=32'b0;
ready=1'b0;
case(state)
idle: begin
end
setup:begin
PADDR=addr;
PWRITE=rw;
PSEL=1'b1;
PENABLE=1'b0;
ready=1'b0;
if(rw)
        PWDATA=wdata;
end
access: begin
PSEL=1'b1;
PENABLE=1'b1;
PADDR=addr;
PWRITE=rw;
ready=1'b1;
if(rw)
        PWDATA=wdata;
end
default:;
endcase
end
always@(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
        rdata<=32'b0;
else
        if(state==access&&PREADY&&!rw)begin
                rdata<=PRDATA;end
end
endmodule

