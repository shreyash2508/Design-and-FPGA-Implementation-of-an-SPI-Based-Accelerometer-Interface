
## 100 MHz system clock
set_property PACKAGE_PIN Y9 [get_ports {clk100}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk100}]
create_clock -period 10.000 -name sys_clk [get_ports {clk100}]

## Pmod JA1 - ADXL362
set_property PACKAGE_PIN Y11 [get_ports {PMOD_CS}]
set_property PACKAGE_PIN AA11 [get_ports {PMOD_MOSI}]
set_property PACKAGE_PIN Y10 [get_ports {PMOD_MISO}]
set_property PACKAGE_PIN AA9 [get_ports {PMOD_SCLK}]

set_property IOSTANDARD LVCMOS33 [get_ports {PMOD_CS}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD_MOSI}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD_MISO}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD_SCLK}]

## Reset button - BTNC
set_property PACKAGE_PIN P16 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

## Start button - BTNU
set_property PACKAGE_PIN T18 [get_ports {start}]
set_property IOSTANDARD LVCMOS33 [get_ports {start}]

## LEDs
set_property PACKAGE_PIN T22 [get_ports {LED[0]}]
set_property PACKAGE_PIN T21 [get_ports {LED[1]}]
set_property PACKAGE_PIN U22 [get_ports {LED[2]}]
set_property PACKAGE_PIN U21 [get_ports {LED[3]}]
set_property PACKAGE_PIN V22 [get_ports {LED[4]}]
set_property PACKAGE_PIN W22 [get_ports {LED[5]}]
set_property PACKAGE_PIN U19 [get_ports {LED[6]}]
set_property PACKAGE_PIN U14 [get_ports {LED[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]
