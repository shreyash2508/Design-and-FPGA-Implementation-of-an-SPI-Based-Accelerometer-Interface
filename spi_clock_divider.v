`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2026 14:26:17
// Design Name: 
// Module Name: spi_clock_divider
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


module spi_clock_divider(
    input wire clk,
    input wire rst,
    input wire enable,
    output reg spi_sclk,
    output reg edge_tick
    );
    
   parameter integer half_period = 50;
   reg [5:0] count;
   
   always @(posedge clk or posedge rst) begin
   
   if (rst) begin
   count <= 0;
   spi_sclk <= 0;
   edge_tick <= 0;
   end 
   else begin
   edge_tick <= 0;
   
   if (enable) begin
   if (count == half_period - 1) begin
   count <= 0;
   spi_sclk = ~spi_sclk;
   edge_tick <= 1;
   end 
   else begin
   count <= count + 1;
   end
   end
   
   else begin
   spi_sclk <= 0;
   count <= 0;
   end
   end
   end  
endmodule
