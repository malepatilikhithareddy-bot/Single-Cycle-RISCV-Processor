//=============================================================================
// riscv_core.v - Single-Cycle RV32I Processor Core
//
// HOW IT WORKS WITH KEYPAD:
//   - pc_load_en: when 1, loads pc_load_val as the new PC (keypad jump)
//   - run: when 1, processor executes; when 0, processor is paused
//   - result_out: the ALU result / write-back value of the current instruction
//   - rd_out: destination register number
//   - pc_out: current program counter
//   - instr_out: current instruction word
//=============================================================================
module riscv_core (
    input         clk,
    input         rst,
    input         run,           // 1 = execute, 0 = pause
    input         pc_load_en,   // pulse: load pc_load_val into PC
    input  [31:0] pc_load_val,  // PC to jump to (from keypad)
    output [31:0] pc_out,
    output [31:0] instr_out,
    output [31:0] result_out,   // final write-back value
    output [4:0]  rd_out,       // destination register
    output [31:0] mem_rd_out,   // memory read data
    output        halted         // 1 when JAL x0,0 detected
);

    //--- PC -------------------------------------------------------------------
    reg [31:0] pc;
    assign pc_out = pc;

    wire [31:0] pc4 = pc + 32'd4;

    //--- Instruction Fetch ----------------------------------------------------
    wire [31:0] instr;
    instr_mem imem (.addr(pc), .instr(instr));
    assign instr_out = instr;

    //--- Decode ---------------------------------------------------------------
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] f3     = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] f7     = instr[31:25];
    assign rd_out = rd;

    //--- Control --------------------------------------------------------------
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire jal, jalr, auipc, lui;
    wire [1:0] alu_op;

    control_unit cu (
        .opcode(opcode), .branch(branch), .mem_read(mem_read),
        .mem_to_reg(mem_to_reg), .alu_op(alu_op), .mem_write(mem_write),
        .alu_src(alu_src), .reg_write(reg_write), .jal(jal),
        .jalr(jalr), .auipc(auipc), .lui(lui)
    );

    //--- Immediate ------------------------------------------------------------
    wire [31:0] imm;
    imm_gen ig (.instr(instr), .imm(imm));

    //--- Register File --------------------------------------------------------
    wire [31:0] rd1, rd2, wb_data;

    register_file rf (
        .clk(clk), .we(reg_write & run),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wb_data), .rd1(rd1), .rd2(rd2)
    );

    //--- ALU ------------------------------------------------------------------
    wire [3:0]  ac;
    wire [31:0] alu_res;
    wire        zero;

    wire [31:0] alu_a = auipc ? pc : rd1;
    wire [31:0] alu_b = alu_src ? imm : rd2;

    alu_control acl (.alu_op(alu_op), .funct3(f3), .funct7(f7), .alu_ctrl(ac));
    alu         au  (.a(alu_a), .b(alu_b), .alu_ctrl(ac), .result(alu_res), .zero(zero));

    //--- Branch ---------------------------------------------------------------
    wire taken;
    branch_control bc (.branch(branch), .funct3(f3), .rs1(rd1), .rs2(rd2), .taken(taken));

    //--- Data Memory ----------------------------------------------------------
    wire [31:0] mem_rd;
    data_mem dm (
        .clk(clk), .we(mem_write & run), .re(mem_read),
        .funct3(f3), .addr(alu_res), .wd(rd2), .rd(mem_rd)
    );
    assign mem_rd_out = mem_rd;

    //--- Write-back -----------------------------------------------------------
    assign wb_data = (jal|jalr) ? pc4 :
                     mem_to_reg ? mem_rd :
                                  alu_res;
    assign result_out = wb_data;

    //--- Halt detect ----------------------------------------------------------
    assign halted = (instr == 32'h0000006F); // JAL x0,0

    //--- Next PC --------------------------------------------------------------
    wire [31:0] pc_branch = pc + imm;
    wire [31:0] pc_jalr   = alu_res & 32'hFFFFFFFE;

    wire [31:0] next_pc = jal    ? pc_branch :
                          jalr   ? pc_jalr   :
                          taken  ? pc_branch :
                                   pc4;

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'd0;
        else if (pc_load_en)
            pc <= pc_load_val;      // keypad jump
        else if (run && !halted)
            pc <= next_pc;
        // if halted or not running: hold PC
    end

endmodule
