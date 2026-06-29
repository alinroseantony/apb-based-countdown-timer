module top_module(

    input  wire PCLK,
    input  wire PRESETn             // User Interface
    input  wire req,
    input  wire rw,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire ready,
    output wire [31:0] rdata,
    output wire timer_done
);                                 //APB bus signals
    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire PSEL;
    wire PENABLE;
    wire PWRITE;
    wire PREADY;
    apb_master u1 (                      //APB master
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .addr(addr),
        .wdata(wdata),
        .rw(rw),
        .req(req),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .ready(ready),
        .PSEL(PSEL),
        .rdata(rdata),
        .PADDR(PADDR),
        .PWDATA(PWDATA), 
        .PWRITE(PWRITE),
        .PENABLE(PENABLE)
    );
    apb_timer_slave u2 (            //APB timer slave 
        .PCLK(PCLK),
        .PRESETn(PRESETn),
                    // Slave expects an 8-bit address
        .PADDR(PADDR[7:0]),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .timer_done(timer_done)
    );
endmodule

