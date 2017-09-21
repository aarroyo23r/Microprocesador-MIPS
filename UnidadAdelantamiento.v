`timescale 1ns / 1ps

module UnidadAdelantamiento (

  input wire reset, //Reset general

//Direcciones
  input [4:0] id_ex_rs,id_ex_rt,
  input [4:0] ex_mem_regWrite,
  input [4:0] mem_wb_regWrite,
  input [10:0] control, //Para que no se den adelantamientos con instrucciones falsas
  //input [5:0] opcode,
//Datos
  output reg memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt
);



  always @*

  if (!reset && (control !=0 && control!=10'h700)) begin

  //rs
    if (id_ex_rs == ex_mem_regWrite )begin
    memAdelant_rs=1;
    wbAdelant_rs=0;end
    else if (id_ex_rs == mem_wb_regWrite)begin
    wbAdelant_rs=1;
    memAdelant_rs=0;end
    else begin
    memAdelant_rs=0;
    wbAdelant_rs=0;
    end
    end


  else begin
    memAdelant_rs=0;
    wbAdelant_rs=0;
  end


  always @*

  if (!reset) begin

  //rt

  if (id_ex_rt == ex_mem_regWrite)begin
  memAdelant_rt=1;
  wbAdelant_rt=0;end
  else if (id_ex_rt == mem_wb_regWrite)begin
  wbAdelant_rt=1;
  memAdelant_rt=0;
  end
  else begin
  memAdelant_rt=0;
  wbAdelant_rt=0;
  end

  end

  else begin
    memAdelant_rt=0;
    wbAdelant_rt=0;
  end

  endmodule
