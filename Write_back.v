`timescale 1ns / 1ps

module Write_back(
    input wire MemtoReg,
    input wire [31:0] data_MEM,
    input wire [31:0] ALU_out,
    output wire [31:0] Write_data
    );
    
assign Write_data = (MemtoReg) ? data_MEM : ALU_out;   
    
endmodule
