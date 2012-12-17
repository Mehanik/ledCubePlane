`define CNT_WIDTH  16
`define PS_WIDTH  4
`include "timescale.v"

module test_counter;

reg reset, clk;

prscClk prsc( 
    .clkIn(clk),
    //.clk_out(clk_d),
    .reset(reset)
);

// clk
always
  #2 clk = ~clk;
 
initial
begin
  clk = 0;
  reset = 0;
  #8 reset = 1;
end

initial
begin
  #200 $finish;
end

// создаем файл VCD для последующего анализа сигналов
initial
begin
    $dumpfile("out.vcd");
    $dumpvars(0, prsc);
end

// наблюдаем за некоторыми сигналами системы
initial
    $monitor($stime,, reset,, clk);

endmodule
