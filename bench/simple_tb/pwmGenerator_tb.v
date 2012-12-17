`include "timescale.v"

module testPWM;

localparam   OUT_NUM = 64;
localparam   D_WIDTH = 8;    // Memory interface data bus widt;
localparam   C_WIDTH = 5;    // PWM counter width

localparam SYSCLK_DELAY = 10;

reg  reset, clk, clk4;
reg  [D_WIDTH - 1:0] data;
wire [OUT_NUM - 1:0] pwmOut;
reg dataEn, rs;

integer i;

planeController  pc(
    .clk(clk), 
    .reset(reset), 
    .dataIn(data), 
    .dataEn(dataEn), 
    .rs(rs), 
    .pwmOut(pwmOut));

// clk
always
    #SYSCLK_DELAY clk = ~clk;

// clk
always
    #(SYSCLK_DELAY*4) clk4 = ~clk4;

initial
begin
    clk = 0;
    clk4 = 0;
    reset = 0;
    for (i = 0; i < 5; i = i + 1)
        @(posedge clk);
    reset = 1;
    for (i = 0; i < 5; i = i + 1)
        @(posedge clk);

    send_command(8'b0000_0001, 1'b1);
    send_command(8'b0000_0010, 1'b1);
    send_command(8'b0000_0110, 1'b1);
    send_command(8'b0000_1100, 1'b1);

    send_command(8'b0000_1111, 1'b0);
    send_command(8'b0000_1111, 1'b0);
    send_command(8'b0000_1111, 1'b0);
    send_command(8'b0000_1111, 1'b0);

    send_command(8'b1111_1111, 1'b0);
    send_command(8'b1111_1111, 1'b0);
    send_command(8'b1111_1111, 1'b0);
    send_command(8'b1111_1111, 1'b0);

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

task send_command (
    input [7:0] dataIn,
    input rsIn
);
begin
    rs = rsIn;
    dataEn = 1;
    data = dataIn;
    @(posedge clk4);
    dataEn = 0;
    @(posedge clk4);
end
endtask // send_command

endmodule // testPWM

