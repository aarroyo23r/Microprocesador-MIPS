`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2017 14:58:51
// Design Name: 
// Module Name: TOP_tb
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


module TOP_tb(
);

reg clk;
reg [31:0] PC;
reg [31:0] In;
reg [31:0] Reg_RD;
reg [31:0] Reg_RT; 
reg [31:0] Dato_1; 
reg [31:0] Dato_2; 
//////////////////////////////////////////////////////////////////////

/////////////////Señales de control de cada parte////////////////////

reg  ALUsrc;
reg [3:0] ALUcontrol;
reg Regdst; 
reg ALU_enable;
//////////////////////////////////////////////////////////////////////


//////////////////Salidas del EXE////////////////////////////////////
wire [31:0] Mux_1;
wire [31:0] Alu_resultado;
wire Zero_flag;
wire [31:0] Sumador_resultado;

Top_Exe Top_instancia(
/////////////////////Entradas del EXE//////////////////////////////////
.clk(clk),
.In(In),
.PC(PC),
.Reg_RD(Reg_RD),
.Reg_RT(Reg_RT),
.Dato_1(Dato_1), 
.Dato_2(Dato_2), 
//////////////////////////////////////////////////////////////////////

/////////////////Señales de control de cada parte////////////////////

.ALUsrc(ALUsrc),
.ALUcontrol(ALUcontrol),
.Regdst(Regdst),
.ALU_enable(ALU_enable),
//////////////////////////////////////////////////////////////////////


//////////////////Salidas del EXE////////////////////////////////////
.Mux_1(Mux_1),
.Alu_resultado(Alu_resultado),
.Zero_flag(Zero_flag),
.Sumador_resultado(Sumador_resultado)
);


    initial 
    begin
    clk = 0;
    PC = 0;
    In = 0;
    Reg_RD = 32'h2; 
    Reg_RT  = 32'h1;
    Dato_1 = 0;
    Dato_2 = 0;
    
    ALUsrc = 0;
    ALUcontrol = 0; 
    Regdst = 0;
    ALU_enable = 0;
    
    

    #30
     In = 32'h25;
     PC = 32'h4;
     Dato_1 = 32'h25;
     Dato_2 = 32'h35;;
     
     ALUsrc = 0;
     ALUcontrol = 4'b0000; 
     Regdst = 1;
     ALU_enable = 1;  

 
    end
    
    always
    begin
    #10 clk = ~clk;
    end





endmodule
