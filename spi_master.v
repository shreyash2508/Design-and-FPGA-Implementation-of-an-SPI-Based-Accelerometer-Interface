`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2026 14:55:37
// Design Name: 
// Module Name: spi_master
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

module spi_master #(
    parameter integer HALF_PERIOD = 50
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       last_byte,
    input  wire       spi_miso,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        done,
    output reg        spi_sclk,
    output reg        spi_mosi,
    output reg        spi_cs
);

    reg [7:0] tx_shift, rx_shift;
    reg [2:0] bit_count;
    reg [15:0] divider_count;
    reg final_byte;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_shift      <= 0;
            rx_shift      <= 0;
            bit_count     <= 0;
            divider_count <= 0;
            final_byte    <= 0;
            rx_data       <= 0;
            busy          <= 0;
            done          <= 0;
            spi_sclk      <= 0;
            spi_mosi      <= 0;
            spi_cs        <= 1;
        end else begin
            done <= 0;

            if (!busy) begin
                if (start) begin
                    tx_shift      <= tx_data;
                    rx_shift      <= 0;
                    bit_count     <= 0;
                    divider_count <= 0;
                    final_byte    <= last_byte;
                    spi_mosi      <= tx_data[7];
                    spi_sclk      <= 0;
                    spi_cs        <= 0;
                    busy          <= 1;
                end
            end else begin
                if (divider_count == HALF_PERIOD-1) begin
                    divider_count <= 0;

                    if (!spi_sclk) begin
                        // Rising edge: sample MISO
                        spi_sclk <= 1;
                        rx_shift <= {rx_shift[6:0], spi_miso};
                    end else begin
                        // Falling edge: prepare next MOSI bit
                        spi_sclk <= 0;

                        if (bit_count == 7) begin
                            rx_data <= rx_shift;
                            busy <= 0;
                            done <= 1;

                            if (final_byte)
                                spi_cs <= 1;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            spi_mosi <= tx_shift[6];
                        end
                    end
                end else begin
                    divider_count <= divider_count + 1'b1;
                end
            end
        end
    end
endmodule
