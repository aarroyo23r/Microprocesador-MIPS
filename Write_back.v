`timescale 1ns / 1ps

module Write_back(
    input wire MemtoReg,
    input wire [31:0] data_MEM,
    input wire [31:0] ALU_out,
    input zeroFlag,set,
    output reg [31:0] Write_data
    );

always @*
    if(set)
    Write_data =zeroFlag;
    else if (MemtoReg)
    Write_data =data_MEM;
    else
    Write_data =ALU_out;
//assign Write_data = (MemtoReg) ? data_MEM : ALU_out;

endmodule
