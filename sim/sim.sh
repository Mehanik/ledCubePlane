#!/bin/bash
set -e

iverilog ../bench/simple_tb/pwmGenerator_tb.v \
../rtl/planeController.v \
-I../rtl/ \
-I../bench/simple_tb/ \
-o testPWM

vvp testPWM
