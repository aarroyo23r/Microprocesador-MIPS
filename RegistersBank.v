`timescale 1ns / 1ps


module registers(
  input wire clk,
  input wire [4:0] addrRead_A, //5 bits para elegir el primer registro a leer
  input wire [4:0] addrRead_B, //5 bits para elegir el segundo registro a leer
  input wire [4:0] addrWrite,  //5 bits para elegir el registro a escribir

  input wire [31:0] dataIn,    //Dato a escribir

  input wire write_en,         //Modo escritura en alto, lectura en bajo
  input wire read_en,

  output reg [31:0] dataOutA,  //Dato registro A
  output reg [31:0] dataOutB   //Dato registro B
  );

//Registros
reg [31:0] registers[31:0]; //32 registros de 32 bits cada uno

always @*
    if (read_en)
        begin         //Modo escritura
        dataOutA = registers[addrRead_A];
        dataOutB = registers[addrRead_B];

        end

    else
        begin             //Modo Lectura
        dataOutA=dataOutA; //Podria ponerse en alta impedancia
        dataOutB=dataOutB;
        end

//Lógica del banco de registros
always @(posedge clk)
    if (write_en)
        begin         //Modo escritura
        registers[addrWrite] <= dataIn;
        end
/*
    else
        begin             //Modo Lectura
        registers[addrWrite]<=registers[addrWrite];
        end*/



endmodule
