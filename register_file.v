//=============================================================================
// register_file.v - 32x32 registers, x0 hardwired 0
//=============================================================================
module register_file (
    input         clk,
    input         we,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] regs [31:0];
    integer k;
    initial for (k=0;k<32;k=k+1) regs[k]=0;

    always @(posedge clk)
        if (we && rd != 5'd0) regs[rd] <= wd;

    assign rd1 = (rs1==5'd0) ? 32'd0 : regs[rs1];
    assign rd2 = (rs2==5'd0) ? 32'd0 : regs[rs2];
endmodule
