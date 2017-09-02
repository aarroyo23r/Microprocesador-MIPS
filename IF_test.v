`timescale 1ns / 1ps

module IF_test();

reg clk;
reg [3:0] jp_address;
reg mux_ctrl;
wire [31:0] data_Out;
wire [3:0] Pc_4;
    
Instruction_Fetch fetch_unit(.clk(clk),.mux_ctrl(mux_ctrl),.instruction(data_Out),
                             .PC_4(Pc_4),.jp_address(jp_address));  
                               
initial 
begin
clk=1;
mux_ctrl=0;
jp_address = 4'ha;
end


always begin
clk=~clk; 
#5; 
end
   
    
endmodule
