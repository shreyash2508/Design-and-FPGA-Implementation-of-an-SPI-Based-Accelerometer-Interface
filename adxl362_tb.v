`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2026 14:20:36
// Design Name: 
// Module Name: adxl362_tb
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


module adxl362_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg spi_miso = 0;

    wire spi_sclk;
    wire spi_mosi;
    wire spi_cs;

    wire signed [11:0] accel_x;
    wire signed [11:0] accel_y;
    wire signed [11:0] accel_z;

    wire sensor_ok;
    wire error;
    wire data_valid;

    integer bit_count = 0;
    integer transaction = 0;
    integer data_index = 0;

    reg [7:0] response_byte;

    // 100 MHz clock
    always #5 clk = ~clk;

    // DUT
    adxl362_driver DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .spi_miso(spi_miso),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs(spi_cs),
        .accel_x(accel_x),
        .accel_y(accel_y),
        .accel_z(accel_z),
        .sensor_ok(sensor_ok),
        .error(error),
        .data_valid(data_valid)
    );

    // Detect beginning of each CS transaction
    always @(negedge spi_cs) begin
        transaction = transaction + 1;
        bit_count = 0;
        spi_miso = 0;

        $display("\nTransaction %0d started", transaction);
    end

    // Count SPI rising edges
    always @(posedge spi_sclk) begin
        if (!spi_cs)
            bit_count = bit_count + 1;
    end

    // Simulate ADXL362 MISO response.
    // First 16 bits are command and address.
    // Subsequent bits are returned data.
    always @(negedge spi_sclk) begin
        if (!spi_cs && bit_count >= 16) begin

            data_index = (bit_count - 16) / 8;

            if (transaction == 1) begin
                // Device ID register response
                response_byte = 8'hAD;
            end
            else if (transaction == 3) begin
                // XYZ burst read response
                case (data_index)
                    0: response_byte = 8'h34; // X low
                    1: response_byte = 8'h02; // X high
                    2: response_byte = 8'h78; // Y low
                    3: response_byte = 8'h05; // Y high
                    4: response_byte = 8'hBC; // Z low
                    5: response_byte = 8'h0A; // Z high
                    default: response_byte = 8'h00;
                endcase
            end
            else begin
                // Configuration write transaction
                response_byte = 8'h00;
            end

            spi_miso = response_byte[7-((bit_count-16)%8)];
        end
        else begin
            spi_miso = 0;
        end
    end

    // Check completed XYZ readings
    always @(posedge clk) begin
        if (data_valid) begin
            #1;

            $display("\n========== SENSOR RESULTS ==========");
            $display("Sensor OK : %b", sensor_ok);
            $display("Error     : %b", error);

            $display("X = %h (%0d)",
                     accel_x, $signed(accel_x));

            $display("Y = %h (%0d)",
                     accel_y, $signed(accel_y));

            $display("Z = %h (%0d)",
                     accel_z, $signed(accel_z));

            $display("====================================");

            if (sensor_ok &&
                !error &&
                accel_x == 12'h234 &&
                accel_y == 12'h578 &&
                accel_z == 12'hABC) begin

                $display("PASS: ADXL362 DRIVER TEST");
            end
            else begin
                $display("FAIL: ADXL362 DRIVER TEST");
            end

            $finish;
        end
    end

    // Test sequence
    initial begin
        $display("ADXL362 DRIVER TEST START");

        #100;
        rst = 0;

        #50;
        start = 1;

        #20;
        start = 0;
    end

    // Timeout: 15 ms
    initial begin
        #15000000;
        $display("TIMEOUT: No XYZ data received");
        $finish;
    end

endmodule
