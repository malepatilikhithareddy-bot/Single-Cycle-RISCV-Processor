//=============================================================================
// control_unit.v
//=============================================================================
module control_unit (
    input  [6:0] opcode,
    output reg       branch,
    output reg       mem_read,
    output reg       mem_to_reg,
    output reg [1:0] alu_op,
    output reg       mem_write,
    output reg       alu_src,
    output reg       reg_write,
    output reg       jal,
    output reg       jalr,
    output reg       auipc,
    output reg       lui
);
    always @(*) begin
        {branch,mem_read,mem_to_reg,mem_write,
         alu_src,reg_write,jal,jalr,auipc,lui} = 10'b0;
        alu_op = 2'b00;
        case (opcode)
            7'b0110011: begin reg_write=1; alu_op=2'b10; end                          // R
            7'b0010011: begin reg_write=1; alu_src=1; alu_op=2'b10; end               // I-arith
            7'b0000011: begin reg_write=1; alu_src=1; mem_read=1; mem_to_reg=1; end   // LOAD
            7'b0100011: begin alu_src=1; mem_write=1; end                              // STORE
            7'b1100011: begin branch=1; alu_op=2'b01; end                             // BRANCH
            7'b0110111: begin reg_write=1; alu_src=1; lui=1; alu_op=2'b11; end        // LUI
            7'b0010111: begin reg_write=1; auipc=1; end                                // AUIPC
            7'b1101111: begin reg_write=1; jal=1; end                                  // JAL
            7'b1100111: begin reg_write=1; jalr=1; alu_src=1; end                     // JALR
            default:    alu_op = 2'b00;
        endcase
    end
endmodule
