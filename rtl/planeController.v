module planeController 
#(
    parameter   OUT_NUM = 64;
    parameter   D_WIDTH = 8,    // Memory interface data bus width
    parameter   C_WIDTH = 4,    // PWM counter width
    parameter   MCU_CLK_DIVIDER = 3
)
(
    input       clk,
    input       reset,
    input       [D_WIDTH - 1:0] dataIn,
    input       dataEn,
    input       rs,
    output reg  [OUT_NUM - 1:0] pwmOut,
    output      mcuClk
);

reg [C_WIDTH - 1:0] mem [0:OUT_NUM - 1];
reg [D_WIDTH - 2:0] memAddr; // Address that will be rewrited
reg incDec = 0; // Decrement address by default
reg pwmEnabled = 0; // Enable pwm output
reg [C_WIDTH - 1:0] cnt;
reg oldDataEn;

assign mcuClk = cnt[1]; // divide clock by 4, 50 MHz / 4 = 12.5 MHz
integer j;

// Memory interface
always @(posedge clk)
begin
    if (dataEn == 1'b0 && oldDataEn == 1'b1) begin
        if (rs == 1'b1) begin
            casez(dataIn)
                8'b0000_0001: // Clear memory
						begin
							for (j = 0; j < OUT_NUM; j = j + 1)
							mem[j] <= 'b0;
						end
                8'b0000_001?: memAddr <= 'b0; // Zero address
                8'b0000_01??: incDec <= dataIn[1];
                8'b1???_????: memAddr <= dataIn[D_WIDTH - 2:0]; // Set address
                default: $display("Error: no such command");
            endcase
        end else begin
            mem[memAddr] <= dataIn;
            if (incDec)
                memAddr <= memAddr + 1;
            else
                memAddr <= memAddr - 1;
        end
    end

    oldDataEn <= dataEn;
end

// counter
always @(posedge clk)
begin
    if (!reset) begin
        cnt <= 0;
    end else begin
        cnt = cnt + 1;
    end
end

genvar i;
generate
    for (i = 0; i < OUT_NUM; i = i + 1) begin: pwmOuts
        always @(posedge clk) begin
            if (cnt == 0 && mem[i] != 0) begin
                pwmOut[i] <= 1'b1;
            end else begin
                if (mem[i] == cnt)
                    pwmOut[i] <= 0;
            end
        end
    end
endgenerate

endmodule // planeController

