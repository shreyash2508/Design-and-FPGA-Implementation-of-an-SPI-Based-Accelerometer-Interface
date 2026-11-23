`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2026 14:10:09
// Design Name: 
// Module Name: motion_detector
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

module motion_detector #(
    parameter signed [11:0] THRESHOLD = 12'sd500,
    parameter signed [11:0] RELEASE   = 12'sd250
)(
    input wire clk,
    input wire rst,
    input wire data_valid,
    input wire signed [11:0] accel_x,
    input wire signed [11:0] accel_y,
    output reg [3:0] direction
);

    // direction[0] = RIGHT
    // direction[1] = LEFT
    // direction[2] = FORWARD
    // direction[3] = BACKWARD

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            direction <= 4'b0000;
        end else if (data_valid) begin
            case (direction)
                4'b0001: if (accel_x < RELEASE) direction <= 0;
                4'b0010: if (accel_x > -RELEASE) direction <= 0;
                4'b0100: if (accel_y < RELEASE) direction <= 0;
                4'b1000: if (accel_y > -RELEASE) direction <= 0;

                default: begin
                    if      (accel_x >  THRESHOLD) direction <= 4'b0001;
                    else if (accel_x < -THRESHOLD) direction <= 4'b0010;
                    else if (accel_y >  THRESHOLD) direction <= 4'b0100;
                    else if (accel_y < -THRESHOLD) direction <= 4'b1000;
                    else                           direction <= 4'b0000;
                end
            endcase
        end
    end
endmodule
