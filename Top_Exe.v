`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07.09.2017 14:35:07
// Design Name:
// Module Name: Top_Exe
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


module Top_Exe(
/////////////////////Entradas del EXE//////////////////////////////////

input clk,
input wire [4:0] PC,//Entrada al sumador del PC + 4
input wire [31:0] In,//Inmediato
input wire [4:0] Reg_RD,// Registro rd que va por el mux 1, lo controlaRegDst (Este registro pasa por todos los pipelines antes de llegar al write register
input wire [4:0] Reg_RT,//Registro rt que tambien va a al mismo mux del anterior.
input wire [31:0] Dato_1,//Dato que viene del Read data 1
input wire [31:0] Dato_2,//Dato que viene del Read data 2
input wire  memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt,
input wire [31:0] memAdeltantado,wbAdelantado,
//////////////////////////////////////////////////////////////////////

/////////////////Señales de control de cada parte////////////////////

input wire  ALUsrc, //Señal que controla el mux que elige entre el inmediato o el dato 2
input wire [4:0] ALUcontrol, //Señal para seleccionar que va a hacer la ALU
input wire Regdst, //Señal que controla el mux que selecciona entre los registros rd y rt
input ALU_enable, //Señal para saber si la ALU puede o no trabajar
//////////////////////////////////////////////////////////////////////
output reg set,

//////////////////Salidas del EXE////////////////////////////////////
output  reg  [4:0] Mux_1,//La salida de este mux va directo al pipeline
output [31:0] Alu_resultado,// Resultado de la alu
output reg Zero_flag, //Salida de la bandera de cero
output wire [4:0] Sumador_resultado// Resultado del sumador de 32 bits (NO tiene overflow)
//////////////////////////////////////////////////////////////////////
);

reg [31:0] Mux_2; // Este registro es para almacenar la salida del mux del inmediato y el data 2 que va a la ALU

//////////////Mux 1, para registros////////////////////
       always @*
          if (Regdst)
             Mux_1 = Reg_RD; //Si Regdst es 1 escoge a RD
          else
             Mux_1 = Reg_RT; //Si no, a RT

/////////////////////////////////////////////////////////

//adelantamiento
reg [31:0] rs_mux;
//Mux rs


         always @*
           if (memAdelant_rs)
                rs_mux =memAdeltantado;
           else if (wbAdelant_rs)
                rs_mux = wbAdelantado;
           else
                rs_mux = Dato_1; //Si no, escoge el Dato_2

//////////////Mux 2, para la ALU////////////////////

         always @*
           if (ALUsrc)
                Mux_2 = In; //Si ALUsrc es 1, escoge el inmediato
           else if (memAdelant_rt)
                Mux_2 =memAdeltantado;
           else if (wbAdelant_rt)
                Mux_2 = wbAdelantado;

           else
                Mux_2 = Dato_2; //Si no, escoge el Dato_2


/////////////////////////////////////////////////////////

////////////////////////////ALU//////////////////////////

reg [31:0] Outreg;

    always @*
    if(ALUcontrol==4'b0101)begin
      set=1;
      if (rs_mux<Mux_2)begin
        Zero_flag=1;
         end
       else begin
          Zero_flag=0;
        end
    end

    else begin
    set=0;
    end


    always @*
      if (ALU_enable)
      begin
         case (ALUcontrol)
            4'b0000:begin
            Outreg = rs_mux + Mux_2;
            end
            4'b0001: begin
            Outreg = rs_mux & Mux_2;
            end
            4'b0010: begin
            Outreg = rs_mux | Mux_2;
            end
            4'b0011: begin
            Outreg = ~(rs_mux | Mux_2);
            end
            4'b0100: begin
            Outreg = rs_mux - Mux_2 ; //Aquí va la resta sin complemento a2
            end
            4'b0110: begin
            Outreg = rs_mux - Mux_2; //Esto hace la resta con complemento a2
            end
            default: Outreg = 0 ;
         endcase
        end

        else begin
        Outreg=0; end



assign Alu_resultado = Outreg;


/////////////////////////////////////////////////////////

///////////////////////Shift/////////////////////////////

wire [31:0] Inm_corrido;

assign Inm_corrido = In << 2;

/////////////////////////////////////////////////////////


assign Sumador_resultado = Inm_corrido + PC;







endmodule
