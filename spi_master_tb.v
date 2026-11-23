`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2026 14:58:37
// Design Name: 
// Module Name: spi_master_tb
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

module spi_master_tb;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] tx_data = 8'hA5;
    reg last_byte = 1;
    reg spi_miso = 0;

    wire [7:0] rx_data;
    wire busy, done, spi_sclk, spi_mosi, spi_cs;

    integer bit_index = 0;
    reg [7:0] expected_rx = 8'h3C;

    always #5 clk = ~clk;

    spi_master #(.HALF_PERIOD(50)) DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .last_byte(last_byte),
        .spi_miso(spi_miso),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs(spi_cs)
    );

    // Supply MISO data, MSB first
    always @(negedge spi_cs) begin
        bit_index = 0;
        spi_miso = expected_rx[7];
    end

    always @(posedge spi_sclk) begin
        if (!spi_cs)
            bit_index = bit_index + 1;
    end

    always @(negedge spi_sclk) begin
        if (!spi_cs && bit_index < 8)
            spi_miso = expected_rx[7-bit_index];
    end

    initial begin
        $display("SPI MASTER TEST START");

        #100;
        rst = 0;

        @(negedge clk);
        start = 1;
        @(negedge clk);
        start = 0;

        wait(done);
        #20;

        $display("TX expected = A5");
        $display("RX received = %h", rx_data);

        if (rx_data == 8'h3C && spi_cs == 1'b1)
            $display("PASS: SPI MASTER");
        else
            $display("FAIL: SPI MASTER");

        #100;
        $finish;
    end

    initial begin
        #200000;
        $display("TIMEOUT");
        $finish;
    end

endmodule

