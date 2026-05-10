//=============================================================================
// data_mem.v - 64-word byte-addressable data RAM
//=============================================================================
module data_mem (
    input         clk,
    input         we, re,
    input  [2:0]  funct3,
    input  [31:0] addr,
    input  [31:0] wd,
    output reg [31:0] rd
);
    reg [31:0] mem [0:63];
    integer k;
    initial for (k=0;k<64;k=k+1) mem[k]=0;

    wire [5:0] wa = addr[7:2];

    always @(posedge clk)
        if (we) mem[wa] <= wd; // word write (SW)

    always @(*) begin
        rd = 32'd0;
        if (re) begin
            case (funct3)
                3'b010: rd = mem[wa];                                    // LW
                3'b000: rd = {{24{mem[wa][7]}}, mem[wa][7:0]};           // LB
                3'b001: rd = {{16{mem[wa][15]}}, mem[wa][15:0]};         // LH
                3'b100: rd = {24'b0, mem[wa][7:0]};                      // LBU
                3'b101: rd = {16'b0, mem[wa][15:0]};                     // LHU
                default: rd = mem[wa];
            endcase
        end
    end
endmodule
