`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2026 14:22:58
// Design Name: 
// Module Name: spi_clock_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_clock_tb(

    );
    reg clk;
reg rst;
reg enable;

wire spi_sclk;
wire edge_tick;

spi_clock_divider DUT (
.clk(clk),
.rst(rst),
.enable(enable),
.spi_sclk(spi_sclk),
.edge_tick(edge_tick)
);

// 100 MHz clock
always #5 clk = ~clk;

initial begin

clk = 0;
rst = 1;
enable = 0;

#100;
rst = 0;

#20;
enable = 1;

#3000;
enable = 0;

#100;
$finish;

end


endmodule
