`timescale 1ns / 1ps


module Pipeline(
  input wire clk,
  input wire reset, //Reset general del Pipeline
  input wire if_id_en, id_ex_en, ex_mem_en, mem_wb_en, // Habilitadores de los registros
  //IF/ID
  input  [31:0] instruccion,//Instrucción a ejecutar
  input wire [4:0] PC_next, //Solo se estan manejando 5 bits en PC por lo que solo
  //se pueden manejar 32 instrucciones en PC
  //ID/EX
  input  [31:0] rs_data,rt_data,imm,addrJump,  // Salidas del decode entradas exe
  input  [10:0] senalesControl,
  //EX/MEM
  input zeroFlag,//De la ALU
  input [4:0] writeRegister, //Dirección del registro de escritura, proviene de un mux
  input [31:0] dataRt, //Salidas de exe entradas a mem
  input [31:0] ALUresult, //Resultado de la ALU
  input [31:0] branchAddr,//Dirección de branch
  //MEM/WB
  input [31:0] memRead, //Dato leido de memoria

  //Outputs
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
  output [4:0] ex_mem_out_write_register, //seleccion de que posicion del banco de registros se escribe
  output [31:0] ex_mem_out_readData2, //Dato2 leido del banco de registros
  output [31:0] ex_mem_out_ALU_result,//Resultado de la ALU
  output [31:0] ex_mem_out_branchAddr,//Dirección de branch
  output ex_mem_out_zeroFlag,//De la ALU
  output [10:0] ex_mem_out_control,//Señales de control
  //MEM/WB
  output [31:0] mem_wb_out_ALU_result,//Resultado de la ALU
  output [31:0] mem_wb_out_readData2,//Dato leido de memoria
  output [4:0] mem_wb_out_write_register,//Direccion del Registro en el que se va a guardar
  output [10:0] mem_wb_out_control//Señales de control
  );

//______________________________________________________________________________
//Definición de los Registros del Pipeline y su organización
//______________________________________________________________________________
reg [31:0]if_id[1:0];   //Reg1=instruccion
                        //Reg2=PC+4
reg [31:0] id_ex[4:0];  // reg0=direccion de rd[15:11],rt [20:16] PC+4 y señales de control
                        // reg1 = dato leido rs
                        // reg2 = dato leido rt
                        // reg3 = immediate
                        // reg4 = address(jump) [25:0]

reg [31:0] ex_mem [3:0]; //reg1 = control, write register, zero flag
                         //reg2 = dato leido de la segunda salida del banco de reg
                         //reg3 = Resultado de la ALU
                         //reg4 = Branch address


reg [31:0] mem_wb [2:0]; //reg1= Resultado de la ALU
                          //reg2= Dato leido de la memoria
                          //reg3= Registro a escribir y control

//______________________________________________________________________________
//Inicializando los registros en 0
//______________________________________________________________________________
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
        id_ex[3] <= imm;
        id_ex[4] <= addrJump;//Aqui tambien se podria agregar PC+4 para aumentar el numero de instrucciones posibles
        //de la instruccion ejecutandose en el decode y se tiene que pasar al exe
        end

//EX/MEM
always @ ( posedge clk)
   if (ex_mem_en)begin
        ex_mem[0][10:0]<=id_ex[0] [10:0]; //Señales de control
        ex_mem[0][15:11]<=writeRegister; //Dirección del registro de escritura
        ex_mem[0][16]<=zeroFlag;  //Proviene de la ALU
        ex_mem[1]<=dataRt; //Dato de rt para la escritura en memoria
        ex_mem[2]<=ALUresult;//Resultado de la ALU
        ex_mem[3]<=branchAddr;//Dirección de branch
   end

//MEM/WB
always @( posedge clk)

  if (mem_wb_en)begin
        mem_wb[0]<=memRead; //Dato leido de memoria
        mem_wb[1]<=ex_mem[2];//Resultado de la ALU
        mem_wb[2][4:0]<=ex_mem[0][15:11];//Dirección del registro de escritura
        mem_wb[2][15:5]<=ex_mem[0][10:0];//Señales de control
  end

//______________________________________________________________________________
//Asignacion de las salidas y reset
//______________________________________________________________________________

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
assign id_ex_out_PC_next =(!reset) ? id_ex[0][29:25]: 0;//En el registro 0 sobran 2 bits
assign id_ex_out_rt_direction =(!reset) ? id_ex[0][20:16]: 0;
assign id_ex_out_rd_direction =(!reset) ? id_ex[0][15:11]: 0;
assign id_ex_out_control =(!reset) ? id_ex[0] [10:0]: 0;
//EX/MEM
assign ex_mem_out_write_register =(!reset) ? ex_mem[0][15:11]: 0;
assign ex_mem_out_readData2 =(!reset) ? ex_mem[1]: 0;
assign ex_mem_out_ALU_result =(!reset) ? ex_mem[2]: 0;
assign ex_mem_out_branchAddr =(!reset) ? ex_mem[3]: 0;
assign ex_mem_out_zeroFlag =(!reset) ? ex_mem[0][16]: 0;
assign ex_mem_out_control =(!reset) ? ex_mem[0][10:0]: 0;
//MEM/WB
assign mem_wb_out_ALU_result =(!reset) ? mem_wb[1]: 0;
assign mem_wb_out_readData2 =(!reset) ? mem_wb[0]: 0;
assign mem_wb_out_write_register =(!reset) ? mem_wb[2][4:0]: 0;
assign mem_wb_out_control =(!reset) ? mem_wb[2][15:5]: 0;

endmodule
