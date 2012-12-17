`include "timescale.v"

module testPWM;

localparam   CH_NUM = 1;       // Number of PWM channels
localparam   CNT_WIDTH = 16;   // Width of counter register
localparam   PRSC_WIDTH = 16;
localparam   PRSC_IF = 4;      // Width of prescaler interface register
localparam   PTB_ADDR = 8'h70; // Starting address of the memory for pwmTop
localparam   PRB_ADDR = 8'h8A; // Starting address of the memory for prescalers
localparam   CDB_ADDR = 8'hC4; // Starting address of the memory for pwmCurDuty
localparam   CSB_ADDR = 8'hFC; // Starting address of the memory for current output 

localparam SYSCLK_DELAY = 10;

time posedge_time = 0;
time negedge_time = 0;

reg  reset, clk, ack;
reg  [7:0] data;
wire [CH_NUM - 1:0] out;
wire sda, scl;
wire [6:0] i2cAddr;

integer i;

pwmGenerator pwmgen (.clk(clk), 
                     .reset(reset), 
                     .i2cAddr(i2cAddr), 
                     .sda(sda), 
                     .scl(scl), 
                     .pwmout(out));

pullup p1(scl); // pullup scl line
pullup p2(sda); // pullup sda line

assign i2cAddr = 7'b1001111;

// clk
always
    #SYSCLK_DELAY clk = ~clk;

always @(posedge out[0])
begin
    $display("T = %d, H = %d", ($time - posedge_time) / SYSCLK_DELAY / 2,  
                               (negedge_time - posedge_time) / SYSCLK_DELAY / 2);
    posedge_time = $time;
end

always @(negedge out[0])
begin
    negedge_time = $time;
end

initial
begin
    clk = 0;
    reset = 0;
    for (i = 0; i < 50; i = i + 1)
        @(posedge clk);
    reset = 1;
    for (i = 0; i < 50; i = i + 1)
        @(posedge clk);

    // Write modTop, pwmDuty
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write modTopH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write modTopL = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write pwmDutyH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write pwmDutyL = 8'h04 and stop at time %t\n", $time);
    data = 8'h04;
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    // Write pwmTop
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address PTB_ADDR at time %t\n", $time);
    data = PTB_ADDR;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write pwmTopH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write pwmTopL = 8'h0F and stop at time %t\n", $time);
    data = 8'h10;
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    // Write pwmPrsc, modPrsc
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address PRB_ADDR at time %t\n", $time);
    data = PRB_ADDR;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write  pwmPrsc = 8'h1, modPrsc = 8'h1 and stop at time %t\n", $time);
    data = {4'b1, 4'b1};
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    // Read pwmTop and modTop
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Establishing a connection in R mode at time %t\n", $time);
    data = {i2cAddr, 1'b1};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Read modTopH at time %t\n", $time);
    imm.i2c_recv_byte(data, 1'b0);
   
    $display("  Read modTopL at time %t\n", $time);
    imm.i2c_recv_byte(data, 1'b0);

    $display("  Read pwmDutyH at time %t\n", $time);
    imm.i2c_recv_byte(data, 1'b0);
   
    $display("  Read pwmDutyL and stop at time %t\n", $time);
    imm.i2c_recv_byte(data, 1'b1);


    //
    // Write modTop, pwmDuty
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write modTopH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write modTopL = 8'h10 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write pwmDutyH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write pwmDutyL = 8'h10 and stop at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    //
    // Write modTop, pwmDuty
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write modTopH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write modTopL = 8'h00 at time %t\n", $time);
    data = 8'h10;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write pwmDutyH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write pwmDutyL = 8'h10 and stop at time %t\n", $time);
    data = 8'h10;
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    #1000

    //
    // Write modTop, pwmDuty
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write modTopH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write modTopL = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write pwmDutyH = 8'h00 at time %t\n", $time);
    data = 8'h00;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);
   
    $display("  Write pwmDutyL = 8'h10 and stop at time %t\n", $time);
    data = 8'h08;
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    // Write pwmPrsc, modPrsc
    $display("  Establishing a connection in W mode at time %t\n", $time);
    data = {i2cAddr, 1'b0};
    imm.i2c_send_byte(data, 1'b1, 1'b0, ack);

    $display("  Set a memory address PRB_ADDR at time %t\n", $time);
    data = PRB_ADDR;
    imm.i2c_send_byte(data, 1'b0, 1'b0, ack);

    $display("  Write  pwmPrsc = 8'h1, modPrsc = 8'h1 and stop at time %t\n", $time);
    data = {4'b10, 4'b1};
    imm.i2c_send_byte(data, 1'b0, 1'b1, ack);

    #10000
    $finish;
end

// создаем файл VCD для последующего анализа сигналов
initial
begin
    $dumpfile("testPWM.vcd");
    $dumpvars(0, testPWM);
end

// наблюдаем за некоторыми сигналами системы
//initial
    //$monitor($stime,, reset,, clk);

endmodule // testPWM


//
//
//
module i2c_master_model(
    inout sda,
    inout scl);

parameter T_SU_STA = 4_700;   // Set-up time for a repeated START condition
parameter T_HD_STA = 4_000;   // After this period, the first clock pulse is generated
parameter T_SU_STO = 4_000;   // Set-up time for a repeated start condition
parameter T_BUF = 4_700;      // Bus free time between a STOP and START conditions
parameter T_HIGH = 4_000;     // LOW period of the SCL clock
parameter T_LOW = 4_700;      // HIGH perios of the SCL clock
parameter T_VD_DAT = 3_450;   // data valid time, 
                              // time for data signal from SCL LOW to SDA output
parameter T_VD_ACK = T_VD_DAT;// data valid ack time for
parameter T_HD_DAT = 300;     // data hold time
parameter T_SU_DAT = T_LOW - T_HD_DAT;     // data set-up time

reg sda_o = 1'b1;
reg scl_o = 1'b1;
assign sda = sda_o ? 1'bz : 1'b0;
assign scl = scl_o ? 1'bz : 1'b0;

integer i;

initial begin
    sda_o = 1'b1;
    scl_o = 1'b1;
end

//
//
//
task i2c_send_byte
    (input [7:0] data,
     input start_tr,
     input stop_tr,
     output ack
     );

    begin
        if (start_tr) begin
            if (scl == 1'b0) begin
                #(T_LOW);
                scl_o = 1'b1;
                #(T_SU_STA);
                $display("Sending repeated START condition at time %t\n", $time);
                sda_o = 1'b0;
                #(T_HD_STA);
                scl_o = 1'b0;
                #(T_HD_DAT);
            end
            else begin
                $display("Sending START condition at time %t\n", $time);
                sda_o = 1'b0;
                #(T_HD_STA);
                scl_o = 1'b0;
                #(T_HD_DAT);
            end
        end

        $display("Sending bype %b, at time %t\n", data, $time);
        for (i = 7; i >= 0; i = i - 1) begin
            sda_o = data[i];
            #(T_SU_DAT);
            scl_o = 1'b1;
            #(T_HIGH);
            scl_o = 1'b0;
            #(T_HD_DAT);
        end
        
        sda_o = 1'b1;
        #(T_SU_DAT);
        scl_o = 1'b1;
        #(T_HIGH);
        ack = sda; 
        scl_o = 1'b0;
        $display("Received ACK = %b, at time %t\n", ack, $time);
        #(T_HD_DAT);

        if (stop_tr) begin
            $display("Sending STOP condition at time %t\n\n", $time);
            #(T_LOW);
            scl_o = 1'b1;
            #(T_SU_STO);
            sda_o = 1'b1;
            #(T_BUF);
        end
    end
endtask // i2c_send_byte

endmodule // i2c_master_model

