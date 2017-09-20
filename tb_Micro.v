`timescale 1ns / 1ps

module tb_Micro();

//Entradas
reg clk;
reg reset; //Reset general


//Salidas
//IF/ID
wire  [31:0] if_id_out_instruccion;  //Salidas del Fetch
wire  [4:0] if_id_out_PC_next;
wire  [5:0] if_id_out_funct; //Salidas del Decode
wire  [5:0] if_id_out_opcode; //Salidas del Decode
//ID/EX
wire [10:0] id_ex_out_control;
wire [31:0] id_ex_out_rs_read; //Dato leido 1
wire [31:0] id_ex_out_rt_read; // Dato leido 2
wire [31:0] id_ex_out_imm; // Imm ya con zero ext 2 bits
wire [31:0] id_ex_out_jaddr; //Direccion de jump
wire [4:0] id_ex_out_PC_next;// Siguiente direccion de PC
wire [4:0] id_ex_out_rt_direction; //Direccion de rt y rd para elegir donde
wire [4:0] id_ex_out_rd_direction;// guardar datos en el banco de registros
//EX/MEM
wire [31:0] ex_mem_out_readData2; //Dato2 leido del banco de registros
wire [31:0] ex_mem_out_ALU_result;//Resultado de la ALU
wire [31:0] ex_mem_out_branchAddr;//Dirección de branch
wire ex_mem_out_zeroFlag;//De la ALU
wire [10:0] ex_mem_out_control;//Señales de control
wire [4:0]ex_mem_out_write;
//MEM/WB
wire [31:0] mem_wb_out_ALU_result;//Resultado de la ALU
wire [31:0] mem_wb_out_readData2;//Dato leido de memoria
wire [4:0] mem_wb_out_write_register;//Direccion del Registro en el que se va a guardar
wire [10:0] mem_wb_out_control;//Señales de control*/
wire [4:0] mem_wb_out_PC4;

wire [31:0] dataWrite;
wire [4:0] PC_toFetch_out;

wire memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt;

Micro Micro_uut( .clk(clk),.reset(reset),

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

  .dataWrite(dataWrite),.PC_toFetch_out(PC_toFetch_out)
  );

//Primer instruccion addi 1 0 0x0fff 20010fff
                   //add  8 1 1      00214020 000000 00001 00001 01000 00000 100000
            //       ori  3 0 0x0006 34030006
                    //jr 3   00600008      000000 0011 00000 00000 00000 001000
//                   andi 2 0 0x0011 30020011
//                   addi 4 0 0x00ff 200400ff
//                   andi 5 1 0x0011 30250011
                  // add  6 1 1      00213020 000000 00001 00001 00110 00000 100000
                //  0000 0000 0010 0011 0011 0000 0010 0000
                //   sw  3 4[0]
                //1010 1100 0000 0011 0000 0000 0000 0100
                //ac030004
                //   lw  7 4[0]
                //1000 1100 0000 0111 0000 0000 0000 0100
                //8c070004

                //jr 3   00600008      0000 0000 0110 0000 00000 00000 001000

reg [35:0] print [31:0]; //Arreglo para impresion
integer i;
  always
  begin
  clk=~clk;
  #10;
  if (mem_wb_out_control[7]!= 0) begin
  print[mem_wb_out_write_register] = {mem_wb_out_write_register,dataWrite};end

  end

  initial begin
  for (i = 0; i < 32; i = i + 1) begin //Inicio del arreglo print en 0
    print[i] = {i,32'b0}; end

  clk=0;
  reset=1;//Reset inicial obligatorio
  #20;
  reset=0;
  print[mem_wb_out_write_register] = {mem_wb_out_write_register,dataWrite};
  #500;
  $writememh("Resultados.txt", print);
  $finish;
  end






  endmodule
