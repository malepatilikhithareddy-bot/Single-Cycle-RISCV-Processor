//=============================================================================
// instr_mem.v - 64-word instruction ROM
//
// Pre-loaded program (address = instruction index):
//  [0]  ADDI x1, x0, 5       x1 = 5
//  [1]  ADDI x2, x0, 3       x2 = 3
//  [2]  ADD  x3, x1, x2      x3 = 8
//  [3]  SUB  x4, x3, x1      x4 = 3
//  [4]  AND  x5, x1, x2      x5 = 1
//  [5]  OR   x6, x1, x2      x6 = 7
//  [6]  XOR  x7, x1, x2      x7 = 6
//  [7]  SLL  x8, x1, x2      x8 = 40
//  [8]  SRL  x9, x8, x2      x9 = 5
//  [9]  SLT  x10,x2, x1      x10= 1
//  [10] LUI  x11,0x12345     x11= 0x12345000
//  [11] ADDI x12,x0, 15      x12= 15
//  [12] SW   x12,0(x0)       mem[0]=15
//  [13] LW   x13,0(x0)       x13= 15
//  [14] ADDI x14,x0, 99      x14= 99
//  [15] JAL  x0, 0           HALT
//=============================================================================
module instr_mem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:63];

    initial begin
        mem[0]  = 32'h00500093; // ADDI x1,x0,5
        mem[1]  = 32'h00300113; // ADDI x2,x0,3
        mem[2]  = 32'h002081B3; // ADD  x3,x1,x2
        mem[3]  = 32'h40118233; // SUB  x4,x3,x1
        mem[4]  = 32'h0020F2B3; // AND  x5,x1,x2
        mem[5]  = 32'h0020E333; // OR   x6,x1,x2
        mem[6]  = 32'h0020C3B3; // XOR  x7,x1,x2
        mem[7]  = 32'h00209433; // SLL  x8,x1,x2
        mem[8]  = 32'h002454B3; // SRL  x9,x8,x2
        mem[9]  = 32'h00112533; // SLT  x10,x2,x1
        mem[10] = 32'h123455B7; // LUI  x11,0x12345
        mem[11] = 32'h00F00613; // ADDI x12,x0,15
        mem[12] = 32'h00C02023; // SW   x12,0(x0)
        mem[13] = 32'h00002683; // LW   x13,0(x0)
        mem[14] = 32'h06300713; // ADDI x14,x0,99
        mem[15] = 32'h0000006F; // JAL  x0,0  (HALT)
        // rest = NOP
        mem[16] = 32'h00000013;
        mem[17] = 32'h00000013;
        mem[18] = 32'h00000013;
        mem[19] = 32'h00000013;
        mem[20] = 32'h00000013;
        mem[21] = 32'h00000013;
        mem[22] = 32'h00000013;
        mem[23] = 32'h00000013;
        mem[24] = 32'h00000013;
        mem[25] = 32'h00000013;
        mem[26] = 32'h00000013;
        mem[27] = 32'h00000013;
        mem[28] = 32'h00000013;
        mem[29] = 32'h00000013;
        mem[30] = 32'h00000013;
        mem[31] = 32'h00000013;
    end

    // Word-aligned: addr[7:2] picks the word
    assign instr = mem[addr[7:2]];
endmodule
