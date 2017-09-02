`timescale 1ns / 1ps

module Ctrl_test();

reg clk,reset;
reg [5:0] Opcode,Function;
wire [3:0] s_actual;
wire RegWrite,RegRead,RegDst,ALUsrc,MemWrite,MemRead,MemtoReg;
wire [3:0]ALU_Op;
    
Control Control_unit(.clk(clk),.Opcode(Opcode),.Function(Function),.RegWrite(RegWrite),.RegRead(RegRead),
                     .ALU_Op(ALU_Op),.RegDst(RegDst),.ALUsrc(ALUsrc),.MemWrite(MemWrite),.MemRead(MemRead),.MemtoReg(MemtoReg),.reset(reset),.s_actual(s_actual));  
                               
initial 
begin
clk=1;
reset=1;
end


always begin
clk=~clk; 
#5;
end
   
    
endmodule
