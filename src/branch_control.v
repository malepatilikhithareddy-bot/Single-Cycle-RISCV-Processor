//=============================================================================
// branch_control.v
//=============================================================================
module branch_control (
    input        branch,
    input  [2:0] funct3,
    input  [31:0] rs1, rs2,
    output reg   taken
);
    always @(*) begin
        taken = 0;
        if (branch) case (funct3)
            3'b000: taken = (rs1 == rs2);
            3'b001: taken = (rs1 != rs2);
            3'b100: taken = ($signed(rs1) < $signed(rs2));
            3'b101: taken = ($signed(rs1) >= $signed(rs2));
            3'b110: taken = (rs1 < rs2);
            3'b111: taken = (rs1 >= rs2);
            default: taken = 0;
        endcase
    end
endmodule
