`timescale 1ns / 1ps

module MultiCore (
  input wire clk,
  input wire reset, //Reset general

//________________________________________________________________________
//Core_1__________________________________________________________________
//________________________________________________________________________

  //IF/ID
  output  [31:0] if_id_out_instruccion,  //Salidas del Fetch
  output  [4:0] if_id_out_PC_next,
  output  [5:0] if_id_out_funct, //Salidas del Decode
  output  [5:0] if_id_out_opcode, //Salidas del Decode*/
  //ID/EX
  output [10:0] id_ex_out_control,
  output [31:0] id_ex_out_rs_read, //Dato leido 1
  output [31:0] id_ex_out_rt_read, // Dato leido 2
  output [31:0] id_ex_out_imm, // Imm ya con zero ext 2 bits
  output [31:0] id_ex_out_jaddr, //Direccion de jump
  output [4:0] id_ex_out_PC_next,// Siguiente direccion de PC
  output [4:0] id_ex_out_rt_direction, //Direccion de rt y rd para elegir donde
  output [4:0] id_ex_out_rd_direction,// guardar datos en el banco de registros
  //EX/MEM
  output [31:0] ex_mem_out_readData2, //Dato2 leido del banco de registros
  output [31:0] ex_mem_out_ALU_result,//Resultado de la ALU
  output [31:0] ex_mem_out_branchAddr,//Dirección de branch
  output [1:0]  ex_mem_out_ControlMem,
  output ex_mem_out_zeroFlag,//De la ALU
  output [10:0] ex_mem_out_control,//Señales de control
  output [4:0]ex_mem_out_write,
  output [31:0] dataWrite,

  //MEM/WB
  output [31:0] mem_wb_out_ALU_result,//Resultado de la ALU
  output [31:0] mem_wb_out_readData2,//Dato leido de memoria
  output [4:0] mem_wb_out_write_register,//Direccion del Registro en el que se va a guardar
  output [10:0] mem_wb_out_control,//Señales de control*/
  output [4:0] mem_wb_out_PC4,


  output [4:0] PC_toFetch_out,

  output   memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt,




  output  wire en_mem,

  //________________________________________________________________________
  //Core_2__________________________________________________________________
  //________________________________________________________________________

  //IF/ID
  output  [31:0] if_id_out_instruccion2,  //Salidas del Fetch
  output  [4:0] if_id_out_PC_next2,
  output  [5:0] if_id_out_funct2, //Salidas del Decode
  output  [5:0] if_id_out_opcode2, //Salidas del Decode*/
  //ID/EX
  output [10:0] id_ex_out_control2,
  output [31:0] id_ex_out_rs_read2, //Dato leido 1
  output [31:0] id_ex_out_rt_read2, // Dato leido 2
  output [31:0] id_ex_out_imm2, // Imm ya con zero ext 2 bits
  output [31:0] id_ex_out_jaddr2, //Direccion de jump
  output [4:0] id_ex_out_PC_next2,// Siguiente direccion de PC
  output [4:0] id_ex_out_rt_direction2, //Direccion de rt y rd para elegir donde
  output [4:0] id_ex_out_rd_direction2,// guardar datos en el banco de registros
  //EX/MEM
  output [31:0] ex_mem_out_readData22, //Dato2 leido del banco de registros
  output [31:0] ex_mem_out_ALU_result2,//Resultado de la ALU
  output [31:0] ex_mem_out_branchAddr2,//Dirección de branch
  output [1:0]  ex_mem_out_ControlMem2,
  output ex_mem_out_zeroFlag2,//De la ALU
  output [10:0] ex_mem_out_control2,//Señales de control
  output [4:0]ex_mem_out_write2,
  output [31:0] dataWrite2,

  //MEM/WB
  output [31:0] mem_wb_out_ALU_result2,//Resultado de la ALU
  output [31:0] mem_wb_out_readData22,//Dato leido de memoria
  output [4:0] mem_wb_out_write_register2,//Direccion del Registro en el que se va a guardar
  output [10:0] mem_wb_out_control2,//Señales de control*/
  output [4:0] mem_wb_out_PC42,


  output [4:0] PC_toFetch_out2,

  output   memAdelant_rs2,memAdelant_rt2,wbAdelant_rs2,wbAdelant_rt2,




  output  wire en_mem2

  );

   wire [31:0]memRead;
   reg jumpBlock;
   reg [1:0]contBlock;

   wire [31:0]memRead2;
   reg jumpBlock2;
   reg [1:0]contBlock2;




  //Core_1
    Micro Core_1_uut( .clk(clk),.reset(reset),

  .memAdelant_rs(memAdelant_rs),.memAdelant_rt(memAdelant_rt),.wbAdelant_rs(wbAdelant_rs),
  .wbAdelant_rt(wbAdelant_rt),
  .if_id_out_instruccion(if_id_out_instruccion),
  .if_id_out_PC_next(if_id_out_PC_next),.if_id_out_funct(if_id_out_funct),
  .if_id_out_opcode(if_id_out_opcode),

  .id_ex_out_control(id_ex_out_control),.id_ex_out_rs_read(id_ex_out_rs_read),
  .id_ex_out_rt_read(id_ex_out_rt_read),.id_ex_out_imm(id_ex_out_imm),
  .id_ex_out_jaddr(id_ex_out_jaddr),.id_ex_out_PC_next(id_ex_out_PC_next),
  .id_ex_out_rt_direction(id_ex_out_rt_direction),.id_ex_out_rd_direction(id_ex_out_rd_direction),

  .ex_mem_out_readData2(ex_mem_out_readData2),.ex_mem_out_ALU_result(ex_mem_out_ALU_result),
  .ex_mem_out_branchAddr(ex_mem_out_branchAddr),.ex_mem_out_zeroFlag(ex_mem_out_zeroFlag),
  .ex_mem_out_control(ex_mem_out_control),.ex_mem_out_write(ex_mem_out_write),

  .mem_wb_out_ALU_result(mem_wb_out_ALU_result),.mem_wb_out_readData2(mem_wb_out_readData2),
  .mem_wb_out_write_register(mem_wb_out_write_register),.mem_wb_out_control(mem_wb_out_control),
  .mem_wb_out_PC4(mem_wb_out_PC4),

  .en_mem(en_mem),.dataWrite(dataWrite),.PC_toFetch_out(PC_toFetch_out),.ex_mem_out_ControlMem(ex_mem_out_ControlMem),.memRead(memRead)
);


  //Core_2
Micro Core_2_uut( .clk(clk),.reset(reset),

.memAdelant_rs(memAdelant_rs2),.memAdelant_rt(memAdelant_rt2),.wbAdelant_rs(wbAdelant_rs2),
.wbAdelant_rt(wbAdelant_rt2),
.if_id_out_instruccion(if_id_out_instruccion2),
.if_id_out_PC_next(if_id_out_PC_next2),.if_id_out_funct(if_id_out_funct2),
.if_id_out_opcode(if_id_out_opcode2),

.id_ex_out_control(id_ex_out_control2),.id_ex_out_rs_read(id_ex_out_rs_read2),
.id_ex_out_rt_read(id_ex_out_rt_read2),.id_ex_out_imm(id_ex_out_imm2),
.id_ex_out_jaddr(id_ex_out_jaddr2),.id_ex_out_PC_next(id_ex_out_PC_next2),
.id_ex_out_rt_direction(id_ex_out_rt_direction2),.id_ex_out_rd_direction(id_ex_out_rd_direction2),

.ex_mem_out_readData2(ex_mem_out_readData22),.ex_mem_out_ALU_result(ex_mem_out_ALU_result2),
.ex_mem_out_branchAddr(ex_mem_out_branchAddr2),.ex_mem_out_zeroFlag(ex_mem_out_zeroFlag2),
.ex_mem_out_control(ex_mem_out_control2),.ex_mem_out_write(ex_mem_out_write2),

.mem_wb_out_ALU_result(mem_wb_out_ALU_result2),.mem_wb_out_readData2(mem_wb_out_readData22),
.mem_wb_out_write_register(mem_wb_out_write_register2),.mem_wb_out_control(mem_wb_out_control2),
.mem_wb_out_PC4(mem_wb_out_PC42),

.en_mem(en_mem2),.dataWrite(dataWrite2),.PC_toFetch_out(PC_toFetch_out2),.ex_mem_out_ControlMem(ex_mem_out_ControlMem2),.memRead(memRead2)
);


//Memoria_____________________________________________________________________


DualPortRAM DualPortRAM_unit (
  .addra(ex_mem_out_ALU_result[9:0]),   // Port A address bus, width determined from RAM_DEPTH
  .addrb(ex_mem_out_ALU_result2[9:0]),   // Port B address bus, width determined from RAM_DEPTH
  .dina(ex_mem_out_readData2),     // Port A RAM input data, width determined from RAM_WIDTH
  .dinb(ex_mem_out_readData22),     // Port B RAM input data, width determined from RAM_WIDTH
  .clka(clk),     // Clock
  .wea(ex_mem_out_ControlMem[1]),       // Port A write enable
  .web(ex_mem_out_ControlMem2 [1]),       // Port B write enable
  .ena(en_mem),       // Port A RAM Enable, for additional power savings, disable port when not in use
  .enb(en_mem2),       // Port B RAM Enable, for additional power savings, disable port when not in use
  .rsta(reset),     // Port A output reset (does not affect memory contents)
  .rstb(reset),     // Port B output reset (does not affect memory contents)
  .regcea(ex_mem_out_ControlMem[0]), // Port A output register enable
  .regceb(ex_mem_out_ControlMem2[0]), // Port B output register enable
  .douta(memRead),   // Port A RAM output data, width determined from RAM_WIDTH
  .doutb(memRead2)    // Port B RAM output data, width determined from RAM_WIDTH
);


      endmodule
