`timescale 1ns / 1ps

module Instruction_Fetch(
    input wire clk,
    input wire mux_ctrl,
    input wire [4:0]jp_address,
    input [4:0] PC,
    output wire [31:0] instruction,
    output reg [4:0] PC_4
    );

reg [4:0] address =5'h0;

always@(posedge clk)begin
address<=PC;
end

always@* begin
if(mux_ctrl == 1'b1)begin
    PC_4=jp_address; end
else if(mux_ctrl==1'b0) begin
    PC_4=address+4;end //Se modifico a P+4 para lograr llenar el pipeline del micro correctamente
end


RAM ram_unit(.clk(clk),.addr(address),.dataIn(),.we(1'b0),.enable(1'b1),.reset(1'b0),.re(1'b1),.dataOut(instruction));


endmodule
