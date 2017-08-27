`timescale 1ns / 1ps

module Instruction_Fetch(
    input wire clk,
    input wire mux_ctrl,
    input wire [3:0]jp_address,
    output reg [31:0] instruction,
    output reg [3:0] Pc_4
    );

reg [3:0] address=4'h0;
reg [3:0]PC=4'h0;


always@*begin
if(mux_ctrl == 1'b0)begin
    address=address+1; end
else if(mux_ctrl == 1'b1)begin
    address=jp_address;end
else begin
    address=address; end  
end 

always@(posedge clk)begin
    PC<=address;end

RAM ram_unit(.clk(clk),.addr(PC),.dataIn(),.we(1'b0),.enable(1'b1),.reset(1'b0),.re(1'b1),.dataOut(instruction));
    
endmodule
