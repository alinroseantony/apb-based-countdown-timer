
module tb_top_module();
reg PCLK;
reg PRESETn;
reg req;
reg rw;
reg [31:0] addr;
reg [31:0] wdata;
wire ready;
wire [31:0] rdata;
wire timer_done;
top_module DUT (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .req(req),
    .rw(rw),
    .addr(addr),
    .wdata(wdata),
    .ready(ready),
    .rdata(rdata),
    .timer_done(timer_done)
);
initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
end
initial begin
    $dumpfile("top_module.vcd");
    $dumpvars();
end
initial begin
    $monitor("Time=%0t Load=%0d Count=%0d Running=%b Done=%b",
             $time,
             DUT.u2.load,
             DUT.u2.count,
             DUT.u2.running,
             timer_done);
end
initial begin                       // Initialize inputs
    PRESETn = 0;
    req = 0;
    rw = 0;
    addr = 0;
    wdata = 0;                             // Hold reset
    #20;
    PRESETn = 1;                           // Write 10 into LOAD register (0x00)
    $display("\nLoading timer with 10");
    req   = 1;
    rw    = 1;
    addr  = 32'h00;
    wdata = 32'd10;
    #30;                        // Allow master to complete transfer
    req = 0;                             
     #20;
    $display("\nStarting timer") //start timer
    req   = 1;
    rw    = 1;
    addr  = 32'h04;
    wdata = 32'd1;
    #30;
    req = 0;                         // Wait while timer counts down
    #150;
                             // Read timer_done register
    $display("\nReading STATUS register");
    req  = 1;
    rw   = 0;
    addr = 32'h08;
    #30;
    $display("STATUS Register = %0d", rdata);
    req = 0;
    #20;
    $finish;
end
endmodule
