`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2026 14:15:11
// Design Name: 
// Module Name: motion_detector_tb
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


`timescale 1ns/1ps

module motion_detector_tb;

    reg clk = 0;
    reg rst = 1;
    reg data_valid = 0;

    reg signed [11:0] accel_x = 0;
    reg signed [11:0] accel_y = 0;

    wire [3:0] direction;

    always #5 clk = ~clk;

    motion_detector #(
        .THRESHOLD(12'sd500),
        .RELEASE(12'sd250)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .accel_x(accel_x),
        .accel_y(accel_y),
        .direction(direction)
    );

    task apply_sample;
        input signed [11:0] x;
        input signed [11:0] y;
        begin
            @(negedge clk);
            accel_x = x;
            accel_y = y;
            data_valid = 1;

            @(negedge clk);
            data_valid = 0;

            #1;
        end
    endtask

    initial begin
        $display("MOTION DETECTOR TEST START");

        #30;
        rst = 0;

        // RIGHT
        apply_sample(12'sd600, 12'sd0);
        if (direction != 4'b0001)
            $display("FAIL: RIGHT");
        else
            $display("PASS: RIGHT");

        // Hysteresis: should remain RIGHT at 400
        apply_sample(12'sd400, 12'sd0);
        if (direction != 4'b0001)
            $display("FAIL: RIGHT HYSTERESIS");
        else
            $display("PASS: RIGHT HYSTERESIS");

        // Return to neutral
        apply_sample(12'sd100, 12'sd0);

        // LEFT
        apply_sample(-12'sd600, 12'sd0);
        if (direction != 4'b0010)
            $display("FAIL: LEFT");
        else
            $display("PASS: LEFT");

        apply_sample(12'sd0, 12'sd0);

        // FORWARD
        apply_sample(12'sd0, 12'sd600);
        if (direction != 4'b0100)
            $display("FAIL: FORWARD");
        else
            $display("PASS: FORWARD");

        apply_sample(12'sd0, 12'sd0);

        // BACKWARD
        apply_sample(12'sd0, -12'sd600);
        if (direction != 4'b1000)
            $display("FAIL: BACKWARD");
        else
            $display("PASS: BACKWARD");

        apply_sample(12'sd0, 12'sd0);

        // Neutral
        if (direction == 4'b0000)
            $display("PASS: NEUTRAL");
        else
            $display("FAIL: NEUTRAL");

        $display("MOTION DETECTOR TEST COMPLETE");
        #50;
        $finish;
    end

endmodule
