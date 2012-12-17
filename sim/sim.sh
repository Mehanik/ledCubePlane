#!/bin/bash

iverilog ../bench/simple_tb/pwmGenerator_tb.v \
../rtl/counter.v \
../rtl/i2cSlave_define.v \
../rtl/i2cSlave.v \
../rtl/pwmGenerator.v \
../rtl/serialInterface.v \
-I../rtl/ \
-I../bench/simple_tb/ \
-o testPWM \
&& vvp testPWM
