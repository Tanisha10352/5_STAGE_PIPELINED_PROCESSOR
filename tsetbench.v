`timescale 1ns / 1ps

module tb_processor;

reg clk1, clk2;
parameter ADD=6'b000000, 
          SUB=6'b000001, 
          AND=6'b000010, 
          OR=6'b000011, 
          SLT=6'b000100, 
          MUL=6'b000101,  
          LW=6'b001000, 
          SW=6'b001001,        
          ADDI=6'b001010, 
          SUBI=6'b001011, 
          SLTI=6'b001100, 
          BNEQZ=6'b001101, 
          BEQZ=6'b001110,
          HLT=6'b111111;


processor uut (.clk1(clk1), .clk2(clk2));

integer i;


initial begin
  clk1 = 0; clk2 = 0;
  forever begin
    #5 clk1 = 1; #5 clk1 = 0;
    #5 clk2 = 1; #5 clk2 = 0;
  end
end



initial begin
    for (i = 0; i < 32; i = i + 1)
        uut.REGISTER[i] = 0;
    for (i = 0; i < 1024; i = i + 1)
        uut.MEMORY[i] = 0;
uut.MEMORY[0] = {ADDI, 5'd0, 5'd1, 16'd10}; //R1<-R0 + IMM
uut.MEMORY[1] = {ADDI, 5'd0, 5'd2, 16'd5};  // R2 <- RO +IMM
uut.MEMORY[2] = {ADD,  5'd1, 5'd2, 5'd3, 11'd0}; // R3<- R1 + R2
uut.MEMORY[3] = {ADDI, 5'd3, 5'd4, 16'd1};  // R4 = R3 + 1 
uut.MEMORY[4] = {ADDI, 5'd0, 5'd0, 16'd0}; 
uut.MEMORY[5] = {SW, 5'd0, 5'd3, 16'd20};       // SW R3, 20(R0)  
uut.MEMORY[6] = {LW, 5'd0, 5'd1, 16'd20};       // LW R1, 20(R0) 
uut.MEMORY[7] = {ADDI, 5'd0, 5'd4, 16'd0};      // R4 = 0
uut.MEMORY[8] = {BEQZ, 5'd4, 21'd2};            // Jump to PC+2 
uut.MEMORY[9] = {ADDI, 5'd0, 5'd2, 16'd99};     
uut.MEMORY[10] = {ADDI, 5'd0, 5'd3, 16'd99};   
uut.MEMORY[11] = {ADDI, 5'd0, 5'd2, 16'd111};   // R2 = 111
uut.MEMORY[12] = {BNEQZ, 5'd2, 21'd2};          // Jump to instruction 15
uut.MEMORY[13] = {ADDI, 5'd0, 5'd3, 16'd222};   
uut.MEMORY[14] = {ADDI, 5'd0, 5'd4, 16'd222};   
uut.MEMORY[15] = {ADDI, 5'd0, 5'd3, 16'd123};   // R3 = 123
uut.MEMORY[16] = {HLT, 26'd0};                  // HALT
           
end


initial begin
    $monitor($time, " clk1=%b clk2=%b", clk1, clk2);
    #2000 $finish; 
end

endmodule
