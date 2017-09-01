`timescale 1ns / 1ps


module Control(
    input wire clk,reset,
    input wire [5:0] Opcode,
    input wire [5:0] Function,
    output reg RegWrite,RegRead,
    output reg [3:0]ALU_Op,
    output reg RegDst,
    output reg ALUsrc,
    output reg MemWrite,MemRead,
    output reg MemtoReg,Muxif, //Muxif indica si hay jump o branch
    output reg [3:0] s_actual
    );
    
//----------Variables----------------------------------------------------------------
    
//reg [3:0] s_next;reg [3:0] s_actual=4'hf; //estado inicial apagado
    
    
//---------declaración de estados---------------------------------------------------_

localparam [3:0] s0 = 4'h0, //add
                 s1 = 4'h1, //and
                 s2 = 4'h2, //addi
                 s3 = 4'h3, //andi
                 s4 = 4'h4, //jump
                 s5 = 4'h5, //jr
                 s6 = 4'h6, //lw
                 s7 = 4'h7, //nor
                 s8 = 4'h8, //or
                 s9 = 4'h9, //ori
                 s10 = 4'ha,//slt
                 s11 = 4'hb, //slti
                 s12 = 4'hc, //sw
                 s13 = 4'hd, //sub
                 s14 = 4'he, //subi
                 s15 = 4'hf; //apagada

//-----Lógica de reset y de estado siguiente------------------------------------- 

always @*begin
    if(reset)begin                               //si se activa 'reset' se entra a estado donde se apagan todas las señales 
        s_actual =s15;end        
    else if(Opcode == 6'h00 && Function ==6'h20)begin
        s_actual =s0;end                        //condición de salto a estado add
    else if(Opcode == 6'h00 && Function ==6'h24)begin
        s_actual=s1;end                         //condición de salto a estado and    
    else if(Opcode == 6'h8)begin
        s_actual=s2;end                         //condición de salto a estado addi
    else if(Opcode == 6'hc)begin
        s_actual =s3;end                        //condición de salto a estado andi
    else if(Opcode == 6'h2)begin
        s_actual =s4;end                        //condición de salto a estado jump
    else if(Opcode == 6'h00 & Function == 6'h8)begin
        s_actual =s5;end                        //condición de salto a estado jr    
    else if(Opcode == 6'h23)begin
        s_actual =s6;end                        //condición de salto a estado lw
    else if(Opcode == 6'h00 && Function ==6'h27)begin
        s_actual =s7;end                        //condición de salto a nor
    else if(Opcode == 6'h00 && Function ==6'h25)begin
        s_actual =s8;end                        //condición de salto a or
    else if(Opcode ==6'hd)begin
        s_actual =s9;end                        //condicion de salto ori
    else if(Opcode == 6'h00 && Function == 6'h2a)begin
        s_actual =s10;end                       //condición de salto slt
    else if(Opcode == 6'ha)begin
        s_actual =s11;end                       //condición de salto slti
    else if(Opcode == 6'h2b)begin
        s_actual =s12;end                       //condición de salto sw
    else if(Opcode == 6'h00 && Function == 6'h22)begin
        s_actual =s13;end                       //condición de salto a sub
    else if(Opcode == 6'h00 && Function == 6'h23)begin
        s_actual=s14;end                        //condición de salto a subu
          
    else
        s_actual=s_actual;
end
 
  
always@* begin
    
    case(s_actual)
    s15:begin                  //estado apagado
       RegWrite=1'b1;         //todas las señales de control desactivan cuando estan en 1
       RegRead =1'b1;
       RegDst = 1'b1;
       ALUsrc = 1'b1;
       MemWrite = 1'b1;
       MemRead = 1'b1;
       MemtoReg= 1'b1;
       Muxif = 1'b0;
       ALU_Op = 4'b0000;      // Ninguna operación selesccionada
       end
    s0:begin                  //estado add
       RegWrite=1'b0;         //señales de control para instrucción add
       RegRead =1'b0;                       
       RegDst = 1'b1;         //guarda el resultado en 'rd' 
       ALUsrc = 1'b0;
       MemWrite = 1'b1;
       MemRead = 1'b1;
       Muxif = 1'b0;
       MemtoReg= 1'b0;        //pasa el resultado de la ALU directamente
       ALU_Op = 4'b0001;      // Operación suma
       end
    s1:begin                  //estado and
       RegWrite=1'b0;         //señales de control para instrucción and
       RegRead =1'b0;
       RegDst = 1'b1;         //guarda el resultado en 'rd'
       ALUsrc = 1'b0;
       MemWrite = 1'b1;
       MemRead = 1'b1;
       Muxif = 1'b0;
       MemtoReg= 1'b0;        //pasa el resultado de la ALU directamente
       ALU_Op = 4'b0010;      // Operación and
       end
    s2:begin                  //estado addi
       RegWrite=1'b0;         //señales de control para instrucción addi
       RegRead =1'b0;
       RegDst = 1'b0;         //guarda el resultado en 'rt'
       ALUsrc = 1'b1;         //pasa el dato Inmediate a la ALU
       MemWrite = 1'b1;
       MemRead = 1'b1;
       Muxif = 1'b0;
       MemtoReg= 1'b0;        //pasa el resultado de la ALU directamente
       ALU_Op = 4'b0001;      // Operación suma
       end
    s3:begin                  //estado andi
       RegWrite=1'b0;         //señales de control para instrucción andi
       RegRead =1'b0;
       RegDst = 1'b0;         //guarda el resultado en 'rt'
       ALUsrc = 1'b1;         //pasa el dato Inmediate a la ALU
       MemWrite = 1'b1;
       MemRead = 1'b1;
       Muxif = 1'b0;
       MemtoReg= 1'b0;        //pasa el resultado de la ALU directamente
       ALU_Op = 4'b0010;      // Operación and
       end
    s4:begin                  //estado jump
       RegWrite=1'b1;         //señales de control para instrucción jump
       RegRead =1'b1;
       RegDst = 1'b0;         //no importa
       ALUsrc = 1'b1;         //no importa
       MemWrite = 1'b1;
       MemRead = 1'b1;
       Muxif = 1'b1;          //pasa la nueva dirección de salto   
       MemtoReg= 1'b0;        //no importa
       ALU_Op = 4'b0000;      // Ninguna operación
       end   
    endcase

end

  
endmodule