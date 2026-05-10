## =============================================================================
## basys3.xdc  -  Basys3 RISC-V Processor  (Button-Step Mode)
## Top module : top
## Part       : xc7a35tcpg236-1
## =============================================================================

## -----------------------------------------------------------------------------
## 100 MHz System Clock
## -----------------------------------------------------------------------------
set_property PACKAGE_PIN W5       [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## -----------------------------------------------------------------------------
## Buttons
##   BTNU (T18) = Reset / Refresh  (up button)
##   BTNR (W19) = Step / Execute   (right button)
##   FIX: btnR was incorrectly set to T17 (BTNC = center button). Corrected to W19.
## -----------------------------------------------------------------------------
set_property PACKAGE_PIN T18      [get_ports btnU]
set_property IOSTANDARD  LVCMOS33 [get_ports btnU]

set_property PACKAGE_PIN W19      [get_ports btnR]
set_property IOSTANDARD  LVCMOS33 [get_ports btnR]

## -----------------------------------------------------------------------------
## Switches  SW[0] - SW[15]
## -----------------------------------------------------------------------------
set_property PACKAGE_PIN V17      [get_ports {sw[0]}]
set_property PACKAGE_PIN V16      [get_ports {sw[1]}]
set_property PACKAGE_PIN W16      [get_ports {sw[2]}]
set_property PACKAGE_PIN W17      [get_ports {sw[3]}]
set_property PACKAGE_PIN W15      [get_ports {sw[4]}]
set_property PACKAGE_PIN V15      [get_ports {sw[5]}]
set_property PACKAGE_PIN W14      [get_ports {sw[6]}]
set_property PACKAGE_PIN W13      [get_ports {sw[7]}]
set_property PACKAGE_PIN V2       [get_ports {sw[8]}]
set_property PACKAGE_PIN T3       [get_ports {sw[9]}]
set_property PACKAGE_PIN T2       [get_ports {sw[10]}]
set_property PACKAGE_PIN R3       [get_ports {sw[11]}]
set_property PACKAGE_PIN W2       [get_ports {sw[12]}]
set_property PACKAGE_PIN U1       [get_ports {sw[13]}]
set_property PACKAGE_PIN T1       [get_ports {sw[14]}]
set_property PACKAGE_PIN R2       [get_ports {sw[15]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {sw[*]}]

## -----------------------------------------------------------------------------
## 7-Segment Display
## seg[0]=a  [1]=b  [2]=c  [3]=d  [4]=e  [5]=f  [6]=g  (active-low)
## -----------------------------------------------------------------------------
set_property PACKAGE_PIN W7       [get_ports {seg[0]}]
set_property PACKAGE_PIN W6       [get_ports {seg[1]}]
set_property PACKAGE_PIN U8       [get_ports {seg[2]}]
set_property PACKAGE_PIN V8       [get_ports {seg[3]}]
set_property PACKAGE_PIN U5       [get_ports {seg[4]}]
set_property PACKAGE_PIN V5       [get_ports {seg[5]}]
set_property PACKAGE_PIN U7       [get_ports {seg[6]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[*]}]

## Decimal point
set_property PACKAGE_PIN V7       [get_ports dp]
set_property IOSTANDARD  LVCMOS33 [get_ports dp]

## Digit anodes (active-low): an[0] = rightmost digit
set_property PACKAGE_PIN U2       [get_ports {an[0]}]
set_property PACKAGE_PIN U4       [get_ports {an[1]}]
set_property PACKAGE_PIN V4       [get_ports {an[2]}]
set_property PACKAGE_PIN W4       [get_ports {an[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[*]}]

## -----------------------------------------------------------------------------
## LEDs  LED[0] - LED[15]
## -----------------------------------------------------------------------------
set_property PACKAGE_PIN U16      [get_ports {led[0]}]
set_property PACKAGE_PIN E19      [get_ports {led[1]}]
set_property PACKAGE_PIN U19      [get_ports {led[2]}]
set_property PACKAGE_PIN V19      [get_ports {led[3]}]
set_property PACKAGE_PIN W18      [get_ports {led[4]}]
set_property PACKAGE_PIN U15      [get_ports {led[5]}]
set_property PACKAGE_PIN U14      [get_ports {led[6]}]
set_property PACKAGE_PIN V14      [get_ports {led[7]}]
set_property PACKAGE_PIN V13      [get_ports {led[8]}]
set_property PACKAGE_PIN V3       [get_ports {led[9]}]
set_property PACKAGE_PIN W3       [get_ports {led[10]}]
set_property PACKAGE_PIN U3       [get_ports {led[11]}]
set_property PACKAGE_PIN P3       [get_ports {led[12]}]
set_property PACKAGE_PIN N3       [get_ports {led[13]}]
set_property PACKAGE_PIN P1       [get_ports {led[14]}]
set_property PACKAGE_PIN L1       [get_ports {led[15]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[*]}]

## -----------------------------------------------------------------------------
## Timing false paths  (async inputs / slow display outputs)
## -----------------------------------------------------------------------------
set_false_path -to   [get_ports {led[*]}]
set_false_path -to   [get_ports {an[*]}]
set_false_path -to   [get_ports {seg[*]}]
set_false_path -to   [get_ports dp]
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports btnU]
set_false_path -from [get_ports btnR]
