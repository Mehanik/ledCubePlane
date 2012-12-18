module planeController 
#(
    parameter   OUT_NUM = 64,
    parameter   D_WIDTH = 8,    // Memory interface data bus width
    parameter   C_WIDTH = 5    // PWM counter width
)
(
    input       clk,
    input       reset,
    input       [D_WIDTH - 1:0] dataIn,
    input       dataEn,
    input       rs,
    output reg  [OUT_NUM - 1:0] pwmOut
);

reg [C_WIDTH - 1:0] mem [0:OUT_NUM - 1];
reg [D_WIDTH - 2:0] memAddr; // Address that will be rewrited
reg incDec; // Decrement address by default
reg pwmEnabled; // Enable pwm output
reg [C_WIDTH - 1:0] cnt;
reg oldDataEn;

integer j;
// Memory interface
always @(posedge clk)
begin
    if (!reset) begin
        pwmEnabled <= 0;
        memAddr <= 0;
        incDec <= 0;
        for (j = 0; j < OUT_NUM; j = j + 1)
            mem[j] <= 'b0;
    end else begin
        if (dataEn == 1'b0 && oldDataEn == 1'b1) begin
            if (rs == 1'b1) begin
                casex(dataIn)
                    8'b0000_0001: begin // Clear memory
                        for (j = 0; j < OUT_NUM; j = j + 1)
                            mem[j] <= 'b0;
                    end
                    8'b0000_001?: memAddr <= 'b0; // Zero address
                    8'b0000_01??: incDec <= dataIn[1];
                    8'b0000_1???: pwmEnabled <= dataIn[2];
                    8'b1???_????: memAddr <= dataIn[D_WIDTH - 2:0]; // Set address
                    default: $display("Error: no such command");
                endcase
            end else begin
                mem[memAddr] <= dataIn;
                if (incDec)
                    memAddr <= memAddr + 'b1;
                else
                    memAddr <= memAddr - 'b1;
            end
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
        cnt <= cnt + 1;
    end
end

genvar i;
generate
for (i = 0; i < OUT_NUM; i = i + 1) begin: pwmOuts
    always @(posedge clk) begin
        //        if (pwmEnabled == 1'b1) begin
        //            if (cnt == 0) begin
        //                if (mem[i] != 0) begin
        //                    pwmOut[i] <= 1'b1;
        //                end else begin
        //                    pwmOut[i] <= 1'b0;
        //                end
        //            end else begin
        //                if (mem[i] == cnt)
        //                    pwmOut[i] <= 1'b0;
        //            end
        //        end else begin
        //            pwmOut[i] <= 1'b0;
        //        end

        if (pwmEnabled == 1'b1) begin
            if (cnt <= mem[i] ) begin
                pwmOut[i] <= 1'b1;
            end else begin
                pwmOut[i] <= 1'b0;
            end
        end
    end
end
endgenerate

endmodule // planeController

