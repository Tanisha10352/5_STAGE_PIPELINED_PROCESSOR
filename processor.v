`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 11:17:25
// Design Name: 
// Module Name: processor
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


module processor(clk1,clk2);
input clk1,clk2;
reg [31:0] PC,IR1,NPC1;//FOR FETCH DECODE PHASE
reg [31:0] IR2,NPC2,A2,B2,IMM2;//FOR DECODE EXECUTE PHASE
reg  [31:0] IR3,ALU_OUT3,A3,B3,IMM3,NPC3;//FOR EXECUTE MEMORY PHASE
reg CONDITION3;
reg [31:0] IR4,ALU_OUT4,LOADM4;//FOR MEMORY ACCESS AND WRITE BACK PHASE
reg [2:0] instruct_type2,instruct_type3,instruct_type4;//INSTRUCTION TYPE FOR DECOSDE-EXECUTE PHASE,,EXECUTE-MEMORY ACCESS PHASE AND MEMORY ACCESS-WRITE BACK PHASE
reg [31:0] REGISTER [0:31];//32 REGISTER BANKS OF 32 BIT EACH
reg [31:0] MEMORY [0:1023];//32X1024 MEMORY SIZE
reg HALT_FLAG,FLUSH_FLAG; // FOR HALT AND BRANCH INSTRUCTION
parameter ADD=6'b000000, 
          SUB=6'b000001, 
          AND=6'b000010, 
          OR=6'b000011, 
          SLT=6'b000100, 
          MUL=6'b000101,  
          LW=6'b001000, 
          SW=6'b001001,          //INSTRUCTIONS OPERATON CODE
          ADDI=6'b001010, 
          SUBI=6'b001011, 
          SLTI=6'b001100, 
          BNEQZ=6'b001101, 
          BEQZ=6'b001110,
          HLT=6'b111111;
parameter RR_ALU = 3'B000, RM_ALU = 3'B001, LOAD = 3'B010, STORE = 3'B011 , BRANCH = 3'B100, HALT = 3'B111;//TYPES OF 0PERATION
initial begin
    PC = 0;
    HALT_FLAG = 0;
    FLUSH_FLAG = 0;
end

always @(posedge clk1) begin
if (HALT_FLAG == 0) begin//FETCH PHASE
 if (FLUSH_FLAG) begin
  IR1 <= 32'b0;     
  NPC1 <= 0;
 end else begin
  IR1 <= MEMORY[PC];
  NPC1 <= PC + 1;
  PC <= PC + 1;
 end
end
end

always @(posedge clk2) begin//DECODING PHASE
if (HALT_FLAG == 0) begin
 if (FLUSH_FLAG) begin
    IR2 <= 32'b0;    
    instruct_type2 <= HALT; 
    FLUSH_FLAG <= 0; 
end 

else begin
     A2 <= REGISTER[IR1[25:21]];
     B2 <= REGISTER[IR1[20:16]];
     IR2 <= IR1;
     NPC2 <= NPC1;
     IMM2 <= {{16{IR1[15]}}, IR1[15:0]};
  case(IR1[31:26])
    ADD, SUB, AND, OR, SLT, MUL: instruct_type2 <= RR_ALU;
    LW: instruct_type2 <= LOAD;
    SW: instruct_type2 <= STORE;
    ADDI, SUBI, SLTI: instruct_type2 <= RM_ALU;
    BNEQZ, BEQZ: instruct_type2 <= BRANCH;
    HLT: instruct_type2 <= HALT;
    default: instruct_type2 <= HALT;
  endcase
end
end
end
always @(posedge clk1) begin //EXECUTION PHASE
if (HALT_FLAG == 0) begin
//OPERAND FORWARDING FOR RAW HAZARD
if (instruct_type2 == RR_ALU && instruct_type3 == RR_ALU && IR3[15:11] == IR2[25:21]) begin
 case(IR2[31:26])
  ADD: ALU_OUT3 <= ALU_OUT3 + B2;
  SUB: ALU_OUT3 <= ALU_OUT3 - B2;
  AND: ALU_OUT3 <= ALU_OUT3 & B2;
  OR : ALU_OUT3 <= ALU_OUT3 | B2;
  SLT: ALU_OUT3 <= ALU_OUT3 < B2;
  MUL: ALU_OUT3 <= ALU_OUT3 * B2;
  default: ALU_OUT3 <= 32'bx;
 endcase

end else if (instruct_type2 == RR_ALU && instruct_type3 == RR_ALU && IR3[15:11] == IR2[20:16]) begin
 case(IR2[31:26])
  ADD: ALU_OUT3 <= A2 + ALU_OUT3;
  SUB: ALU_OUT3 <= A2 - ALU_OUT3;
  AND: ALU_OUT3 <= A2 & ALU_OUT3;
  OR : ALU_OUT3 <= A2 | ALU_OUT3;
  SLT: ALU_OUT3 <= A2 < ALU_OUT3;
  MUL: ALU_OUT3 <= A2 * ALU_OUT3;
  default: ALU_OUT3 <= 32'bx;
 endcase

end else if (instruct_type2 == RM_ALU && instruct_type3 == RR_ALU && IR3[15:11] == IR2[25:21]) begin
 case(IR2[31:26])
  ADDI:ALU_OUT3<=ALU_OUT3 + IMM2;
   SUBI:ALU_OUT3<=ALU_OUT3 - IMM2;
   SLTI:ALU_OUT3<=ALU_OUT3 < IMM2;
  default: ALU_OUT3 <= 32'bx;
 endcase

end else if (instruct_type2 == RM_ALU && instruct_type3 == RM_ALU && IR3[20:16] == IR2[25:21]) begin
 case(IR2[31:26])
  ADDI: ALU_OUT3 <= ALU_OUT3 + IMM2;
  SUBI: ALU_OUT3 <= ALU_OUT3 - IMM2;
  SLTI: ALU_OUT3 <= ALU_OUT3 < IMM2;
  default: ALU_OUT3 <= 32'bx;
 endcase

end else if (instruct_type2 == RR_ALU && instruct_type3 == RM_ALU && IR3[20:16] == IR2[25:21]) begin
  case(IR2[31:26])
   ADD: ALU_OUT3<= ALU_OUT3 + B2;
   SUB: ALU_OUT3<= ALU_OUT3 - B2;
   AND:ALU_OUT3<= ALU_OUT3 & B2;
   OR:ALU_OUT3<= ALU_OUT3 | B2;
   SLT:ALU_OUT3<= ALU_OUT3 < B2;
   MUL:ALU_OUT3<= ALU_OUT3 * B2;
   default: ALU_OUT3<= 32'bx;
   endcase
end else if (instruct_type2 == RR_ALU && instruct_type3 == RM_ALU && IR3[20:16] == IR2[20:16]) begin
  case(IR2[31:26])
  ADD: ALU_OUT3 <= A2 + ALU_OUT3;
  SUB: ALU_OUT3 <= A2 - ALU_OUT3;
  AND: ALU_OUT3 <= A2 & ALU_OUT3;
  OR : ALU_OUT3 <= A2 | ALU_OUT3;
  SLT: ALU_OUT3 <= A2 < ALU_OUT3;
  MUL: ALU_OUT3 <= A2 * ALU_OUT3;
  default: ALU_OUT3 <= 32'bx;
 endcase
 //IN CASE OF NO POSSIBILITY OF RAW HAZARD
end else begin
 case(instruct_type2)
  RR_ALU: begin
   case(IR2[31:26])
    ADD: ALU_OUT3 <= A2 + B2;
    SUB: ALU_OUT3 <= A2 - B2;
    AND: ALU_OUT3 <= A2 & B2;
    OR : ALU_OUT3 <= A2 | B2;
    SLT: ALU_OUT3 <= A2 < B2;
    MUL: ALU_OUT3 <= A2 * B2;
    default: ALU_OUT3 <= 32'bx;
   endcase
  end

  RM_ALU: begin
   case(IR2[31:26])
    ADDI: ALU_OUT3 <= A2 + IMM2;
    SUBI: ALU_OUT3 <= A2 - IMM2;
    SLTI: ALU_OUT3 <= A2 < IMM2;
    default: ALU_OUT3 <= 32'bx;
   endcase
  end

  LOAD, STORE: begin
   ALU_OUT3 <= A2 + IMM2;
   B3 <= B2;
  end

  BRANCH: begin
   ALU_OUT3 <= NPC2 + IMM2;
   if ((IR2[31:26] == BEQZ && A2 == 0) || (IR2[31:26] == BNEQZ && A2 != 0)) begin
    PC <= NPC2 + IMM2;
    FLUSH_FLAG <= 1;
   end
  end
 endcase
end

instruct_type3 <= instruct_type2;
IR3 <= IR2;
NPC3 <= NPC2;

end
end

always @(posedge clk2) begin // MEMORY ACCESS PHASE
  if (instruct_type3 != 3'b111) begin  // HALT NOT YET IN MEMORY ACCESS STAGE
    instruct_type4 <= instruct_type3;
    IR4 <= IR3;
    case (instruct_type3)
      RM_ALU, RR_ALU: ALU_OUT4 <= ALU_OUT3;
      LOAD: LOADM4 <= MEMORY[ALU_OUT3];
      STORE: begin
        if (FLUSH_FLAG == 0) begin
          MEMORY[ALU_OUT3] <= B3;
        end
      end
    endcase
  end else begin
    instruct_type4 <= instruct_type3;
    IR4 <= IR3;
  end
end

always @(posedge clk1) begin // WRITE BACK PHASE
if (FLUSH_FLAG == 0)  begin
 case(instruct_type4)
 RR_ALU: REGISTER[IR4[15:11]] <=  ALU_OUT4;
 RM_ALU: REGISTER[IR4[20:16]] <= ALU_OUT4;
 LOAD : REGISTER[IR4[20:16]] <= LOADM4;
 HALT: HALT_FLAG<=1;
 endcase
end
end

assign r1 = REGISTER[1];
assign r2 = REGISTER[2];
assign r3 = REGISTER[3];
assign r4 = REGISTER[4];
assign out4 = ALU_OUT4;
assign out3 = ALU_OUT3;
assign outa2 = A2;
assign outb2 = B2;
assign outir2 = IR2;
assign outimm2 = IMM2;
endmodule
 

   
 
 
 
 




