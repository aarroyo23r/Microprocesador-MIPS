`timescale 1ns / 1ps

module Micro (

  input wire clk,
  input wire reset, //Reset general


  //IF/ID
  output  [31:0] if_id_out_instruccion,  //Salidas del Fetch
  output  [4:0] if_id_out_PC_next,
  output  [5:0] if_id_out_funct, //Salidas del Decode
  output  [5:0] if_id_out_opcode, //Salidas del Decode
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
  output ex_mem_out_zeroFlag,//De la ALU
  output [10:0] ex_mem_out_control,//Señales de control
  output [4:0]ex_mem_out_write,
  //MEM/WB
  output [31:0] mem_wb_out_ALU_result,//Resultado de la ALU
  output [31:0] mem_wb_out_readData2,//Dato leido de memoria
  output [4:0] mem_wb_out_write_register,//Direccion del Registro en el que se va a guardar
  output [10:0] mem_wb_out_control,//Señales de control*/
  output [4:0] mem_wb_out_PC4,

  output [31:0] dataWrite,
  output [4:0] PC_toFetch_out,

  output   memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt
  );


//******************************************************************************
  //Pipeline______________________________________________________________________
  reg if_id_en=1;
  reg id_ex_en=1;
  reg ex_mem_en=1;
  reg mem_wb_en=1; // Constantes por que aun no e manejan operaciones que necesiten control sobre estos registros

  //IF/ID
  wire  [31:0] instruccion;//Instrucción a ejecutar
  wire [4:0] PC_next; //Solo se estan manejando 5 bits en PC por lo que solo
  //se pueden manejar 32 instrucciones en PC
  //ID/EX
  wire  [31:0] rs_data,rt_data;  // Salidas del decode entradas exe
  wire  [10:0] senalesControl;
  //EX/MEM
  wire zeroFlag;//De la ALU
  wire [4:0] writeRegister; //Dirección del registro de escritura, proviene de un mux
  wire [31:0] ALUresult; //Resultado de la ALU
  wire [4:0] branchAddr;//Dirección de branch  %%%%Ahorita solo se estan usando 4 por el tamaño de PC
  //MEM/WB
  wire [31:0] memRead; //Dato leido de memoria

  //Outputs
  reg [31:0]if_id[1:0];
  reg [31:0] id_ex[4:0];
  reg [31:0] ex_mem [3:0];
  reg [31:0] mem_wb [2:0];



//Control_______________________________________________________________________
  wire RegWrite,RegRead;
  wire [3:0]ALU_Op;
  wire RegDst;
  wire ALUsrc;
  wire MemWrite,MemRead;
  wire MemtoReg,Muxif; //Muxif indica si hay jump o branch
  wire [3:0] s_actual;



//Fetch_________________________________________________________________________
  wire mux_ctrl; //Entrada maquina de control
  wire [3:0]jp_address;//In
  wire [31:0] instruction;
  reg [4:0] PC_4;

//Decode_________________________________________________________________________
  //Extención de signo
  reg [31:0] extSign; //Salida con el signo extendido
  wire [15:0] sigTemp; //Registro temporal para realizar la extencion de signo

//Mem_________________________________________________________________________

  wire jumpBranch;

  //WB___________________________________________________________________________
  wire [31:0] Write_data; //Dato a Escribir

//******************************************************************************
//Inicio del Micro
//Logica para llenar el Pipeline

reg run;//Variable activa cuando se esta llenando el Pipeline
reg [4:0] PC_toFetch; //PC siguiente correcto

always@(posedge clk)
if (reset) begin  //Reset inicial necesario **********##########********
PC_toFetch<=0;
end
else if (run)begin
PC_toFetch<=PC_toFetch+1;//Siguiente PC hasta que se llene el Pipeline
end

else begin
PC_toFetch<=mem_wb[2][20:16];
end

always @(posedge clk)
if (reset)
run<=1;
else if (PC_toFetch>=4 && mem_wb[2][20:16]==0) //Pipeline lleno
run<=0;
else
run<=run;
/*reg run=1;//Variable activa cuando se esta llenando el Pipeline
reg [4:0] PC_toFetch=0; //PC siguiente correcto

always@(posedge clk)
if (reset) begin  //Reset inicial necesario **********##########********
PC_toFetch<=0;
end
else if (id_ex[0][0]) begin //jump
PC_toFetch<=id_ex[1][4:0];
end
else if (run)begin
PC_toFetch<=PC_toFetch+1;//Siguiente PC hasta que se llene el Pipeline
end

else begin
PC_toFetch<=mem_wb[2][20:16];
end
//**************Hay que generalizar el apagado del run
always @(posedge clk)
if (reset | senalesControl[0])
run<=1;
else if (PC_toFetch==6 ) //Pipeline lleno
run<=0;
else
run<=run;
*/
//******************************************************************************
//Pipeline
//******************************************************************************

generate
integer i;
initial begin
        for (i = 0; i <= 1; i = i + 1) begin //Inicio if/id
          if_id[i] = 32'b0; end
        for (i = 0; i <= 4; i = i + 1) begin //Inicio id/ex
          id_ex[i] = 32'b0; end
        for (i = 0; i <= 3; i = i + 1) begin //Inicio ex/mem
          ex_mem[i] = 32'b0; end
        for (i = 0; i <= 2; i = i + 1) begin //Inicio mem/wb
          mem_wb[i] = 32'b0; end
          end
 endgenerate

//______________________________________________________________________________
//Logica de los registros
//______________________________________________________________________________
//IF/ID
always @(posedge clk)

    if (if_id_en)
        begin
        if_id[0] <= instruccion;
        if_id[1][4:0] <= PC_next; //Se guarda PC+4 en los primeros bits del registro
        end

//ID/EX
always @(posedge clk)
    if (id_ex_en)
        begin
        id_ex[0] [10:0]<= senalesControl; //señales de control provenientes de la maquina de estados
        id_ex[0][15:11] <= if_id[0][15:11]; //almacena la dirección de escritura de rd
        id_ex[0][20:16] <= if_id[0][20:16]; //almacena la dirección de escritura de rt
        id_ex[0][31:25] <= if_id[1][4:0]; // PC+4 que se arrastra
        //Nota: se ingreso PC+4 en este registro para no agregar otro mas pero
        //como solo sobran 5 bits en él solo se pueden manejar 32  instrucciones en PC

        id_ex[1] <= rs_data;
        id_ex[2] <= rt_data;
        id_ex[3] <= extSign;
        id_ex[4][25:0] <= if_id[0][15:0];//Aqui tambien se podria agregar PC+4 para aumentar el numero de instrucciones posibles
        //de la instruccion ejecutandose en el decode y se tiene que pasar al exe
        id_ex[4][30:26]<=if_id[0][25:21];// Direccion de escritura rs
        end

//EX/MEM
always @ ( posedge clk)
   if (ex_mem_en)begin
        ex_mem[0][10:0]<=id_ex[0] [10:0]; //Señales de control
        ex_mem[0][15:11]<=writeRegister; //Dirección del registro de escritura
        ex_mem[0][16]<=zeroFlag;  //Proviene de la ALU
        ex_mem[1]<=id_ex[2]; //Dato de rt para la escritura en memoria
        ex_mem[2]<=ALUresult;//Resultado de la ALU
        ex_mem[3][4:0]<=branchAddr;//Dirección de branch
        ex_mem[3][9:5]<=id_ex[0][31:25];//PC+4
   end

//MEM/WB
always @( posedge clk)

  if (mem_wb_en)begin
        mem_wb[0]<=memRead; //Dato leido de memoria
        mem_wb[1]<=ex_mem[2];//Resultado de la ALU
        mem_wb[2][4:0]<=ex_mem[0][15:11];//Dirección del registro de escritura
        mem_wb[2][15:5]<=ex_mem[0][10:0];//Señales de control
        mem_wb[2][20:16]<=ex_mem[3][9:5];//PC+4
        mem_wb[2][21]<=ex_mem[0][16];//zero flag
        mem_wb[2][22]<=set;//set indica si es una instruccion set
  end


//******************************************************************************
//******************************************************************************



//------------------------------------------------------------------------------
//Instanciaciones _______________________________________________________________
//-------------------------------------------------------------------------------


//Control_______________________________________________________________________


 assign senalesControl={ALU_Op,RegWrite,RegRead,RegDst,ALUsrc,MemWrite,MemRead,MemtoReg,Muxif};

Control Control_unit(.Opcode(if_id[0][31:26]),.Function(if_id[0][5:0]),.RegWrite(RegWrite),.RegRead(RegRead),
                     .ALU_Op(ALU_Op),.RegDst(RegDst),.ALUsrc(ALUsrc),.MemWrite(MemWrite),.MemRead(MemRead),.MemtoReg(MemtoReg),.reset(reset),.Muxif(Muxif),.clk(clk));



 //------------------------------------------------------------------------------
 //Fetch___________________________________________________________________________

 Instruction_Fetch fetch_unit(.clk(clk),.mux_ctrl(senalesControl[0]),.instruction(instruccion),
                              .PC_4(PC_next),.jp_address(id_ex[1][4:0]),.PC(PC_toFetch));



//------------------------------------------------------------------------------
//Decode___________________________________________________________________________

//Extención de signo

assign sigTemp = (if_id[0][15]) ? 16'hffff : 0;

always @*
if (!reset)begin
extSign[15:0]=if_id[0][15:0];
extSign[31:16]=sigTemp; end
else begin
extSign=0;end
//Fin de la extencion de signo

registers register_bank_unit(.clk(clk),.addrRead_A(if_id[0][25:21]),.addrRead_B(if_id[0][20:16]),
  .addrWrite(mem_wb[2][4:0]),.dataIn(Write_data),.write_en(mem_wb[2][12]),.dataOutA(rs_data),.dataOutB(rt_data),.read_en(RegRead)   //Dato registro B
  );
//Fin Decode___________________________________________________________________________

//Exe_**************************************************************************

//Unidad de adelantamiento _______________________________________________________________

//Datos
//wire  memAdelant_rs,memAdelant_rt,wbAdelant_rs,wbAdelant_rt;

wire set;

UnidadAdelantamiento UnidadAdelantamiento_unit (
 .control(id_ex[0] [10:0]),.reset(reset),.id_ex_rs(id_ex[4][30:26]),.id_ex_rt(id_ex[0][20:16]),
 .ex_mem_regWrite(ex_mem[0][15:11]),.mem_wb_regWrite(mem_wb[2][4:0]),

  .memAdelant_rs(memAdelant_rs),.memAdelant_rt(memAdelant_rt),
  .wbAdelant_rs(wbAdelant_rs),.wbAdelant_rt(wbAdelant_rt)
);


Top_Exe exe_unit(
  /////////////////////Unidad de Adelantamiento//////////////////////////////////
  .set(set),.memAdeltantado(ex_mem[2]),.wbAdelantado(Write_data),

.memAdelant_rt(memAdelant_rt),.wbAdelant_rt(wbAdelant_rt),
.memAdelant_rs(memAdelant_rs),.wbAdelant_rs(wbAdelant_rs),
/////////////////////Entradas del EXE//////////////////////////////////
.clk(clk),
.In(id_ex[3]),
.PC(id_ex[0][29:25]),
.Reg_RD(id_ex[0][15:11]),
.Reg_RT(id_ex[0][20:16]),
.Dato_1(id_ex[1]),
.Dato_2(id_ex[2]),
//////////////////////////////////////////////////////////////////////

/////////////////Señales de control de cada parte////////////////////

.ALUsrc(id_ex[0][4]),
.ALUcontrol(id_ex[0] [10:8]),
.Regdst(id_ex[0][5]),
.ALU_enable(1),
//////////////////////////////////////////////////////////////////////


//////////////////Salidas del EXE////////////////////////////////////
.Mux_1(writeRegister),
.Alu_resultado(ALUresult),
.Zero_flag(zeroFlag),
.Sumador_resultado(branchAddr)
);


//------------------------------------------------------------------------------
//Mem___________________________________________________________________________

//Agregar branch
assign jumpBranch = ex_mem[0][0] && ex_mem[0][16];
wire en_mem;

assign en_mem=ex_mem[0][3] ||ex_mem[0][2];

DataMemory memoriaDatos_unit (.addr(ex_mem[2][9:0]),.dataIn(ex_mem[1]),.clk(clk),.we(ex_mem[0][3]),.enable(en_mem),.reset(reset),                           // Output reset (does not affect memory contents)
  .re(ex_mem[0][2]),.dataOut(memRead)          // RAM output data
);

//------------------------------------------------------------------------------
//WB___________________________________________________________________________


Write_back writeBack_unit (.zeroFlag(mem_wb[2][21]),.set(mem_wb[2][22]),.MemtoReg(mem_wb[2][6]),.data_MEM(mem_wb[0]),.ALU_out(mem_wb[1]),.Write_data(Write_data)

);

//IF/ID
assign if_id_out_instruccion= (!reset) ? if_id[0] : 0;
assign if_id_out_PC_next = (!reset) ? if_id[1][4:0]: 0;
assign if_id_out_funct = (!reset) ? if_id[0][5:0]: 0;//Hacia la maquina de estados
assign if_id_out_opcode =(!reset) ? if_id[0][31:26]: 0;//Hacia la maquina de estados
//ID/EX
assign id_ex_out_rs_read =(!reset) ? id_ex[1]: 0;
assign id_ex_out_rt_read =(!reset) ? id_ex[2]: 0;
assign id_ex_out_imm =(!reset) ? id_ex[3]: 0;
assign id_ex_out_jaddr =(!reset) ? id_ex[4]: 0;
assign id_ex_out_PC_next =(!reset) ? id_ex[0][31:25]: 0;//En el registro 0 sobran 2 bits
assign id_ex_out_rt_direction =(!reset) ? id_ex[0][20:16]: 0;
assign id_ex_out_rd_direction =(!reset) ? id_ex[0][15:11]: 0;
assign id_ex_out_control =(!reset) ? id_ex[0] [10:0]: 0;
//EX/MEM

assign ex_mem_out_readData2 =(!reset) ? ex_mem[1]: 0;
assign ex_mem_out_ALU_result =(!reset) ? ex_mem[2]: 0;
assign ex_mem_out_branchAddr =(!reset) ? ex_mem[3]: 0;
assign ex_mem_out_zeroFlag =(!reset) ? ex_mem[0][16]: 0;
assign ex_mem_out_control =(!reset) ? ex_mem[0][10:0]: 0;
assign ex_mem_out_write =(!reset) ? ex_mem[0][15:11]: 0;
//MEM/WB
assign mem_wb_out_ALU_result =(!reset) ? mem_wb[1]: 0;
assign mem_wb_out_readData2 =(!reset) ? mem_wb[0]: 0;
assign mem_wb_out_write_register =(!reset) ? mem_wb[2][4:0]: 0;
assign mem_wb_out_control =(!reset) ? mem_wb[2][15:5]: 0;
assign mem_wb_out_PC4 =(!reset) ? mem_wb[2][20:16]: 0;

assign dataWrite=Write_data;
assign PC_toFetch_out=PC_toFetch;
endmodule
