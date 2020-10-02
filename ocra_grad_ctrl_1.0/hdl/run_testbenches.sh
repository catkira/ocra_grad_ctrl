#!/usr/bin/env bash
# Run all testbenches and halt when there's an error

globstat=0
for k in ad5781_model dac80504_model gpa_fhdo_iface grad_bram ocra1_iface ocra_grad_ctrl; do
    iverilog -o icarus_compile/000_$k.compiled $k.v -Wall
    if [ $? -ne 0 ]; then globstat=1; fi
    iverilog -o icarus_compile/000_$k\_tb.compiled $k\_tb.v -Wall    
    if [ $? -ne 0 ]; then globstat=1; fi    
    vvp -N icarus_compile/000_$k\_tb.compiled -none
    if [ $? -ne 0 ]; then globstat=1; fi    
done
exit $globstat
