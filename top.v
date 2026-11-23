`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2026 14:18:13
// Design Name: 
// Module Name: top
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


module top (
    input  wire clk100,
    input  wire rst,
    input  wire start,

    input  wire PMOD_MISO,
    output wire PMOD_SCLK,
    output wire PMOD_MOSI,
    output wire PMOD_CS,

    output wire [7:0] LED
);

    (* MARK_DEBUG = "TRUE" *) wire signed [11:0] accel_x;
    (* MARK_DEBUG = "TRUE" *) wire signed [11:0] accel_y;
    (* MARK_DEBUG = "TRUE" *) wire signed [11:0] accel_z;
    (* MARK_DEBUG = "TRUE" *) wire sensor_ok;
    (* MARK_DEBUG = "TRUE" *) wire error;
    (* MARK_DEBUG = "TRUE" *) wire data_valid;

    wire [3:0] direction;

    adxl362_driver DRIVER (
        .clk(clk100),
        .rst(rst),
        .start(start),
        .spi_miso(PMOD_MISO),
        .spi_sclk(PMOD_SCLK),
        .spi_mosi(PMOD_MOSI),
        .spi_cs(PMOD_CS),
        .accel_x(accel_x),
        .accel_y(accel_y),
        .accel_z(accel_z),
        .sensor_ok(sensor_ok),
        .error(error),
        .data_valid(data_valid)
    );

    motion_detector DETECTOR (
        .clk(clk100),
        .rst(rst),
        .data_valid(data_valid),
        .accel_x(accel_x),
        .accel_y(accel_y),
        .direction(direction)
    );

    // LED[0] RIGHT
    // LED[1] LEFT
    // LED[2] FORWARD
    // LED[3] BACKWARD
    // LED[4] Sensor initialized successfully
    // LED[5] Device ID / initialization error

    assign LED = {2'b00, error, sensor_ok, direction};

endmodule

