# Design-and-FPGA-Implementation-of-an-SPI-Based-Accelerometer-Interface(ADXL362)
A pure hardware digital interface implemented in Verilog on the ZedBoard (Zynq-7020) programmable logic without a soft or hard processor. The system interfaces with an Analog Devices ADXL362 3-axis accelerometer (Digilent Pmod ACL2) over SPI, samples tilt acceleration at ~100 Hz, and visualizes movement via on-board LEDs.

Key Features
  1. **Processor-Free Architecture**: Fully autonomous RTL implementation running from a 100 MHz system clock.
  2. **SPI Master**: Configured for SPI Mode 0 with a 1 MHz SCLK and multi-byte frame handling.
  3. **31-State Driver FSM**: Performs automated device ID verification (0xAD), configures measurement mode, and executes periodic 8-byte burst reads of X, Y, and Z acceleration.
  4. **Hysteresis-Based Motion Decoder**: Decodes tilt (Right, Left, Forward, Backward) with dual-threshold hysteresis ($X/Y > \pm500$ counts to activate, $<\pm250$ counts to deactivate) to completely eliminate LED jitter.
  5. **Ultra-Low Footprint**: Consumes under 1% of device logic (146 LUTs, 126 FFs, 0 BRAM/DSP) and runs at ~4 mW dynamic power with timing closure easily met up to ~224 MHz.

**I/O & LED Mapping**
**Inputs:** BTNC (Reset), BTNU (Start/Initialize), Pmod JA (SPI bus)

**Outputs:**
**LD0** – Right Tilt
**LD1** – Left Tilt
**LD2** – Forward Tilt
**LD3** – Backward Tilt
**LD4** – Sensor Initialized (sensor_ok)
**LD5** – Device ID Error (error)
