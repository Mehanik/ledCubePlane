module planeController 
#(
    parameter   OUT_NUM = 64,
    parameter   D_WIDTH = 8,    // Memory interface data bus width
    parameter   C_WIDTH = 5,     // PWM counter width
    parameter   MCU_CLK_DIVIDER = 2 // f(mcuClk) = f(clk) / 2^MCU_CLK_DIVIDER
)
(
    input       clk,
    input       reset,
    input       [D_WIDTH - 1:0] dataIn,
    input       dataEn,
    input       rs,
    output      [OUT_NUM - 1:0] pwmOut,
    output      mcuClk
);

reg [C_WIDTH - 1:0] mem [0:OUT_NUM - 1];
reg [D_WIDTH - 2:0] memAddr; // Pointer to current address in memory.
reg [C_WIDTH - 1:0] cnt; // Counter that used for PWM signal generation
reg incDec; // Decriment or increment address. Decrementation is by default.
reg pwmEnabled; // Enable pwm output.
reg prevDataEn;
reg syncDataEn;
reg dataEnNegEdge;

assign mcuClk = cnt[MCU_CLK_DIVIDER];

// Control interface: memAddr, incDec, pwmEnabled
always @(posedge clk) begin
    if (!reset) begin
        pwmEnabled <= 1'b0;
        memAddr <= 1'b0;
        incDec <= 1'b0;
    end else begin
        if (dataEnNegEdge) begin
            if (rs == 1'b1) begin
                casez(dataIn) // synthesis parallel_case
                    8'b0000_001?: memAddr <= 'b0; // Zero address
                    8'b0000_01??: incDec <= dataIn[1];
                    8'b0000_1???: pwmEnabled <= dataIn[2];
                    8'b1???_????: memAddr <= dataIn[D_WIDTH - 2:0]; // Set address
                endcase
            end else begin
                if (incDec)
                    memAddr <= memAddr + 1'b1;
                else
                    memAddr <= memAddr - 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
 dataEnNegEdge <= (prevDataEn == 1'b1 && syncDataEn == 1'b0);
end

always @(posedge clk) begin
    syncDataEn <= dataEn;
end

always @(posedge clk) begin
    prevDataEn <= syncDataEn;
end

// counter
always @(posedge clk)
begin
    if (!reset) begin
        cnt <= 0;
    end else begin
        if (cnt <= 8'b11101) begin //
            cnt <= cnt + 1'b1;
        end else begin
            cnt <= 0;
        end
    end
end

genvar i;
generate
for (i = 0; i < OUT_NUM; i = i + 1) begin: pwmOuts
    // Memory interface
    always @(posedge clk) begin
        if (reset) begin
            if (dataEnNegEdge) begin
                if (rs == 1'b1 && dataIn == 8'b0000_0001) begin // `clean memory' command
                    mem[i] <= 'b0;
                end else begin
                    if (memAddr == i[C_WIDTH - 1:0]) begin
                        mem[i] <= dataIn[C_WIDTH - 1:0]; // load value to memory
                    end
                end
            end
        end
    end

    assign pwmOut[i] = pwmEnabled ? ({1'b0, cnt} < mem[i]) : 1'b0;
end
endgenerate

endmodule // planeController

