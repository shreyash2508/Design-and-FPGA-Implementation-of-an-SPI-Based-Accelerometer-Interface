`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2026 14:14:16
// Design Name: 
// Module Name: adxl362_driver
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



module adxl362_driver (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire spi_miso,
    output wire spi_sclk,
    output wire spi_mosi,
    output wire spi_cs,

    output reg signed [11:0] accel_x,
    output reg signed [11:0] accel_y,
    output reg signed [11:0] accel_z,
    output reg sensor_ok,
    output reg error,
    output reg data_valid
);

    reg master_start;
    reg master_last_byte;
    reg [7:0] master_tx;
    wire [7:0] master_rx;
    wire master_busy, master_done;

    spi_master SPI (
        .clk(clk),
        .rst(rst),
        .start(master_start),
        .tx_data(master_tx),
        .last_byte(master_last_byte),
        .spi_miso(spi_miso),
        .rx_data(master_rx),
        .busy(master_busy),
        .done(master_done),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs(spi_cs)
    );

    localparam IDLE       = 0,
               ID_CMD     = 1,
               ID_CMD_W   = 2,
               ID_ADDR    = 3,
               ID_ADDR_W  = 4,
               ID_DATA    = 5,
               ID_DATA_W  = 6,
               WR_CMD     = 7,
               WR_CMD_W   = 8,
               WR_ADDR    = 9,
               WR_ADDR_W  = 10,
               WR_DATA    = 11,
               WR_DATA_W  = 12,
               RD_CMD     = 13,
               RD_CMD_W   = 14,
               RD_ADDR    = 15,
               RD_ADDR_W  = 16,
               X_LOW      = 17,
               X_LOW_W    = 18,
               X_HIGH     = 19,
               X_HIGH_W   = 20,
               Y_LOW      = 21,
               Y_LOW_W    = 22,
               Y_HIGH     = 23,
               Y_HIGH_W   = 24,
               Z_LOW      = 25,
               Z_LOW_W    = 26,
               Z_HIGH     = 27,
               Z_HIGH_W   = 28,
               WAIT_POLL  = 29,
               FAILED     = 30;

    reg [5:0] state;
    reg [7:0] x_low, y_low, z_low;
    reg [19:0] poll_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            master_start <= 0;
            master_last_byte <= 0;
            master_tx <= 0;
            accel_x <= 0;
            accel_y <= 0;
            accel_z <= 0;
            sensor_ok <= 0;
            error <= 0;
            data_valid <= 0;
            x_low <= 0;
            y_low <= 0;
            z_low <= 0;
            poll_count <= 0;
        end else begin
            master_start <= 0;
            data_valid <= 0;

            case (state)
                IDLE: begin
                    if (start) begin
                        sensor_ok <= 0;
                        error <= 0;
                        state <= ID_CMD;
                    end
                end

                ID_CMD: begin
                    master_tx <= 8'h0B;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= ID_CMD_W;
                end
                ID_CMD_W: if (master_done) state <= ID_ADDR;

                ID_ADDR: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= ID_ADDR_W;
                end
                ID_ADDR_W: if (master_done) state <= ID_DATA;

                ID_DATA: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 1;
                    master_start <= 1;
                    state <= ID_DATA_W;
                end
                ID_DATA_W: begin
                    if (master_done) begin
                        if (master_rx == 8'hAD)
                            state <= WR_CMD;
                        else begin
                            error <= 1;
                            state <= FAILED;
                        end
                    end
                end

                WR_CMD: begin
                    master_tx <= 8'h0A;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= WR_CMD_W;
                end
                WR_CMD_W: if (master_done) state <= WR_ADDR;

                WR_ADDR: begin
                    master_tx <= 8'h2D;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= WR_ADDR_W;
                end
                WR_ADDR_W: if (master_done) state <= WR_DATA;

                WR_DATA: begin
                    master_tx <= 8'h02;
                    master_last_byte <= 1;
                    master_start <= 1;
                    state <= WR_DATA_W;
                end
                WR_DATA_W: begin
                    if (master_done) begin
                        sensor_ok <= 1;
                        poll_count <= 0;
                        state <= WAIT_POLL;
                    end
                end

                WAIT_POLL: begin
                    if (poll_count >= 20'd999999) begin
                        poll_count <= 0;
                        state <= RD_CMD;
                    end else begin
                        poll_count <= poll_count + 1'b1;
                    end
                end

                RD_CMD: begin
                    master_tx <= 8'h0B;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= RD_CMD_W;
                end
                RD_CMD_W: if (master_done) state <= RD_ADDR;

                RD_ADDR: begin
                    master_tx <= 8'h0E;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= RD_ADDR_W;
                end
                RD_ADDR_W: if (master_done) state <= X_LOW;

                X_LOW: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= X_LOW_W;
                end
                X_LOW_W: begin
                    if (master_done) begin
                        x_low <= master_rx;
                        state <= X_HIGH;
                    end
                end

                X_HIGH: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= X_HIGH_W;
                end
                X_HIGH_W: begin
                    if (master_done) begin
                        accel_x <= {master_rx[3:0], x_low};
                        state <= Y_LOW;
                    end
                end

                Y_LOW: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= Y_LOW_W;
                end
                Y_LOW_W: begin
                    if (master_done) begin
                        y_low <= master_rx;
                        state <= Y_HIGH;
                    end
                end

                Y_HIGH: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= Y_HIGH_W;
                end
                Y_HIGH_W: begin
                    if (master_done) begin
                        accel_y <= {master_rx[3:0], y_low};
                        state <= Z_LOW;
                    end
                end

                Z_LOW: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 0;
                    master_start <= 1;
                    state <= Z_LOW_W;
                end
                Z_LOW_W: begin
                    if (master_done) begin
                        z_low <= master_rx;
                        state <= Z_HIGH;
                    end
                end

                Z_HIGH: begin
                    master_tx <= 8'h00;
                    master_last_byte <= 1;
                    master_start <= 1;
                    state <= Z_HIGH_W;
                end
                Z_HIGH_W: begin
                    if (master_done) begin
                        accel_z <= {master_rx[3:0], z_low};
                        data_valid <= 1;
                        poll_count <= 0;
                        state <= WAIT_POLL;
                    end
                end

                FAILED: begin
                    // Reset the FPGA or assert rst to retry
                    state <= FAILED;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

