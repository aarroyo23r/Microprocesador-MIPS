`timescale 1ns / 1ps

//  Xilinx Single Port Read First RAM
//  This code implements a parameterizable single-port read-first memory where when data
//  is written to the memory, the output reflects the prior contents of the memory location.
//  If the output data is not needed during writes or the last read value is desired to be
//  retained, it is suggested to set WRITE_MODE to NO_CHANGE as it is more power efficient.
//  If a reset or enableble is not necessary, it may be tied off or removed from the code.
//  Modify the parameters for the desired RAM characteristics.

module RAM #(
  parameter RAM_WIDTH = 32,                       // Specify RAM data width
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] addr,  // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dataIn,           // RAM input data
  input clk,                           // Clock
  input we,                            // Write enableble
  input enable,                            // RAM enableble, for additional power savings, disable port when not in use
  input reset,                           // Output reset (does not affect memory contents)
  input re,                         // Output register enableble
  output [RAM_WIDTH-1:0] dataOut          // RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clk)
    if (enable) begin
      if (we)
        BRAM[addr] <= dataIn;
      ram_data <= BRAM[addr];
    end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign dataOut = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] dataOut_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        if (reset)
          dataOut_reg <= {RAM_WIDTH{1'b0}};
        else if (re)
          dataOut_reg <= ram_data;

      assign dataOut = dataOut_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for xilinx_single_port_ram_read_first
/*
  //  Xilinx Single Port Read First RAM
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addr(addr),     // Address bus, width determined from RAM_DEPTH
    .dataIn(dataIn),       // RAM input data, width determined from RAM_WIDTH
    .clk(clk),       // Clock
    .we(we),         // Write enableble
    .enable(enable),         // RAM enableble, for additional power savings, disable port when not in use
    .reset(reset),       // Output reset (does not affect memory contents)
    .re(re),   // Output register enableble
    .dataOut(dataOut)      // RAM output data, width determined from RAM_WIDTH
  );
*/
