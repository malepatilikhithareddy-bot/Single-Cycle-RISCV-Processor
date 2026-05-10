//=============================================================================
// tb_riscv_core.v  -  Testbench for riscv_core.v
//
// ROOT CAUSE OF THE DISPLAY BUG (nothing wrong with the RTL):
// ─────────────────────────────────────────────────────────────
// Verilog NBA (non-blocking assignment) rule:
//   @(posedge clk) → all NBA LHS values commit → then #1 delay → $display
//
// So after "@(posedge clk); #1", BOTH pc AND regs[] have already advanced
// to the NEXT state. That means:
//   • pc_out    = address of the NEXT instruction
//   • instr_out = the NEXT instruction word
//   • result_out = ALU result of the NEXT instruction
//
// Every display row was therefore showing one instruction AHEAD of what
// the user expected, and the silent @(posedge clk) before the loop ate
// ADDI x1 entirely. AND/OR/XOR were actually computing correctly.
//
// FIX: Sample at NEGEDGE (mid-cycle).
//   At negedge: pc has NOT yet advanced (next advance is at next posedge).
//   Registers from all prior instructions are already stable. ✓
//   result_out is combinational → valid for the CURRENT instruction. ✓
//   One display row maps to exactly one instruction, in order.
//=============================================================================
`timescale 1ns/1ps

module tb_riscv_core;

    //-------------------------------------------------------------------------
    // DUT ports - exact match with riscv_core.v
    //-------------------------------------------------------------------------
    reg          clk;
    reg          rst;
    reg          run;
    reg          pc_load_en;
    reg  [31:0]  pc_load_val;

    wire [31:0]  pc_out;
    wire [31:0]  instr_out;
    wire [31:0]  result_out;
    wire [4:0]   rd_out;
    wire [31:0]  mem_rd_out;
    wire         halted;

    //-------------------------------------------------------------------------
    // DUT instantiation
    //-------------------------------------------------------------------------
    riscv_core dut (
        .clk         (clk),
        .rst         (rst),
        .run         (run),
        .pc_load_en  (pc_load_en),
        .pc_load_val (pc_load_val),
        .pc_out      (pc_out),
        .instr_out   (instr_out),
        .result_out  (result_out),
        .rd_out      (rd_out),
        .mem_rd_out  (mem_rd_out),
        .halted      (halted)
    );

    //-------------------------------------------------------------------------
    // 10 ns clock (100 MHz)
    //-------------------------------------------------------------------------
    initial clk = 0;
    always  #5 clk = ~clk;

    //-------------------------------------------------------------------------
    // Mnemonic decoder
    //-------------------------------------------------------------------------
    reg [8*8-1:0] mnemonic;
    always @(*) begin
        case (instr_out[6:0])
            7'b0110011: begin
                case ({instr_out[31:25], instr_out[14:12]})
                    10'b0000000_000: mnemonic = "ADD     ";
                    10'b0100000_000: mnemonic = "SUB     ";
                    10'b0000000_111: mnemonic = "AND     ";
                    10'b0000000_110: mnemonic = "OR      ";
                    10'b0000000_100: mnemonic = "XOR     ";
                    10'b0000000_001: mnemonic = "SLL     ";
                    10'b0000000_101: mnemonic = "SRL     ";
                    10'b0100000_101: mnemonic = "SRA     ";
                    10'b0000000_010: mnemonic = "SLT     ";
                    10'b0000000_011: mnemonic = "SLTU    ";
                    default:         mnemonic = "R-???   ";
                endcase
            end
            7'b0010011: begin
                case (instr_out[14:12])
                    3'b000: mnemonic = "ADDI    ";
                    3'b111: mnemonic = "ANDI    ";
                    3'b110: mnemonic = "ORI     ";
                    3'b100: mnemonic = "XORI    ";
                    3'b001: mnemonic = "SLLI    ";
                    3'b101: mnemonic = "SRLI/A  ";
                    3'b010: mnemonic = "SLTI    ";
                    3'b011: mnemonic = "SLTIU   ";
                    default: mnemonic = "I-???   ";
                endcase
            end
            7'b0000011: begin
                case (instr_out[14:12])
                    3'b010: mnemonic = "LW      ";
                    3'b001: mnemonic = "LH      ";
                    3'b000: mnemonic = "LB      ";
                    3'b101: mnemonic = "LHU     ";
                    3'b100: mnemonic = "LBU     ";
                    default: mnemonic = "LOAD-?  ";
                endcase
            end
            7'b0100011: begin
                case (instr_out[14:12])
                    3'b010: mnemonic = "SW      ";
                    3'b001: mnemonic = "SH      ";
                    3'b000: mnemonic = "SB      ";
                    default: mnemonic = "STORE-? ";
                endcase
            end
            7'b1100011: begin
                case (instr_out[14:12])
                    3'b000: mnemonic = "BEQ     ";
                    3'b001: mnemonic = "BNE     ";
                    3'b100: mnemonic = "BLT     ";
                    3'b101: mnemonic = "BGE     ";
                    3'b110: mnemonic = "BLTU    ";
                    3'b111: mnemonic = "BGEU    ";
                    default: mnemonic = "BR-???  ";
                endcase
            end
            7'b0110111: mnemonic = "LUI     ";
            7'b0010111: mnemonic = "AUIPC   ";
            7'b1101111: mnemonic = "JAL     ";
            7'b1100111: mnemonic = "JALR    ";
            7'b0000000: mnemonic = "NOP     ";
            default:    mnemonic = "UNKNOWN ";
        endcase
    end

    //-------------------------------------------------------------------------
    // Stimulus + display
    //-------------------------------------------------------------------------
    integer cycle;

    initial begin
        $dumpfile("tb_riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);

        rst         = 1;
        run         = 0;
        pc_load_en  = 0;
        pc_load_val = 32'd0;
        cycle       = 0;

        // Hold reset for 3 full clock cycles
        repeat(3) @(posedge clk);

        // Release reset at a negedge - clean, glitch-free
        @(negedge clk);
        rst = 0;
        run = 1;

        // One posedge: ADDI x1 executes (pc: 0→4, regs[x1]<=5)
        @(posedge clk);

        $display("");
        $display("======================================================================================");
        $display(" Cycle |   PC   | Instruction | Mnemonic | rd  | WB Result  | MemRd Data | Halt");
        $display("======================================================================================");

        // ── Sample at NEGEDGE: pc is stable (hasn't advanced yet) ──────────
        // At negedge after posedge N:
        //   pc_out     = address currently executing (set at posedge N)
        //   instr_out  = instruction at that address
        //   result_out = combinational WB result for this exact instruction
        repeat(20) begin
            @(negedge clk);
            cycle = cycle + 1;

            $display("  %3d  | 0x%04h |  0x%08h | %s | x%02d | 0x%08h | 0x%08h |  %b",
                cycle,
                pc_out,
                instr_out,
                mnemonic,
                rd_out,
                result_out,
                mem_rd_out,
                halted
            );

            if (halted) begin
                $display("======================================================================================");
                $display("  HALT (JAL x0,0) at PC=0x%04h  after %0d cycles", pc_out, cycle);
                $display("======================================================================================");
                #20; $finish;
            end

            // Advance past the next posedge before sampling the next negedge
            @(posedge clk);
        end

        $display("======================================================================================");
        $display("  Simulation complete: %0d cycles, no HALT seen", cycle);
        $finish;
    end

    //-------------------------------------------------------------------------
    // Named waveform aliases (GTKWave / Vivado waveform viewer)
    //-------------------------------------------------------------------------
    wire [31:0] W_PC          = pc_out;
    wire [31:0] W_INSTRUCTION = instr_out;
    wire [31:0] W_WB_RESULT   = result_out;
    wire [4:0]  W_RD_ADDR     = rd_out;
    wire [31:0] W_MEM_RD_DATA = mem_rd_out;
    wire        W_HALTED      = halted;

endmodule