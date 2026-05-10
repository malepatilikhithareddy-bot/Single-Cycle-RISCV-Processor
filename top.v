//=============================================================================
// top.v - RISC-V Processor Top Level for Basys3
//
// BEHAVIOUR:
//   - Press BTNR (right button) once → execute the NEXT instruction
//     and show its write-back result on the 7-segment display.
//   - The processor starts at PC=0 and advances by one instruction each
//     button press.
//   - Press BTNU (up button) at any time to reset everything to PC=0.
//
// 7-SEGMENT DISPLAY:
//   Always shows the result of the LAST executed instruction.
//   SW[1:0] selects WHAT to display:
//     00 = ALU / write-back result  (default)
//     01 = Current Program Counter
//     10 = Destination register number (rd)
//     11 = Memory read data (useful after LW)
//   SW[2]:
//     0  = lower 16 bits of the selected value
//     1  = upper 16 bits of the selected value
//
// LED INDICATORS:
//   LED[15]  = HALT  (processor reached JAL x0,0 - instruction 15)
//   LED[14:0]= lower 15 bits of last write-back result
//
// BUTTONS (on-board, no external wiring needed):
//   BTNU  (T18) = Full reset / Refresh
//   BTNR  (W19) = Step: execute next instruction  [FIX: was T17 = BTNC]
//
// SWITCHES (SW[2:0] used; rest ignored):
//   SW[0] | SW[1:0] display select (see above)
//   SW[1] |
//   SW[2]  = upper/lower 16-bit view
//=============================================================================
module top (
    input        clk,
    input        btnU,     // BTNU = reset
    input        btnR,     // BTNR = step (execute next instruction)
    input  [15:0] sw,
    output [3:0]  an,
    output [6:0]  seg,
    output        dp,
    output [15:0] led
);

    wire rst = btnU;

    //=========================================================================
    // BUTTON DEBOUNCE
    // Converts the raw btnR press into a single clean pulse (btn_pulse).
    // Uses a 20-bit counter at 100 MHz → ~10 ms debounce window.
    //=========================================================================
    reg [19:0] db_cnt;
    reg        db_ff0, db_ff1, db_sync;
    reg        btn_prev;
    wire       btn_pulse;   // one-cycle pulse on each confirmed press

    // Two-FF synchroniser
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            db_ff0 <= 0; db_ff1 <= 0;
        end else begin
            db_ff0 <= btnR;
            db_ff1 <= db_ff0;
        end
    end

    // Debounce counter
    // FIX: Counter must increment while input DIFFERS from stable value.
    //      Original had the condition inverted (== instead of !=), so
    //      db_sync never changed and btn_pulse was always 0.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            db_cnt  <= 0;
            db_sync <= 0;
        end else begin
            if (db_ff1 == db_sync) begin
                db_cnt <= 0;           // input matches stable → reset counter
            end else if (db_cnt == 20'hFFFFF) begin
                db_sync <= db_ff1;     // held different for ~10 ms → accept
            end else begin
                db_cnt <= db_cnt + 1;
            end
        end
    end

    // Rising-edge detect on debounced signal
    always @(posedge clk or posedge rst)
        if (rst) btn_prev <= 0;
        else     btn_prev <= db_sync;

    assign btn_pulse = db_sync & ~btn_prev;  // 1-cycle pulse on press

    //=========================================================================
    // STEP CONTROLLER
    // On each btn_pulse: tell the core to run for exactly one clock cycle.
    // The single-cycle core completes Fetch→Decode→Execute→Mem→WB in one
    // clock, so one 'run=1' cycle = one fully retired instruction.
    //=========================================================================
    reg core_run;   // 1 for one cycle to execute current instruction

    always @(posedge clk or posedge rst) begin
        if (rst)
            core_run <= 0;
        else
            core_run <= btn_pulse;  // pulse follows the debounced edge
    end

    //=========================================================================
    // RISC-V CORE
    //=========================================================================
    wire [31:0] pc_o, instr_o, result_o, mem_rd_o;
    wire [4:0]  rd_o;
    wire        halted;

    riscv_core core (
        .clk         (clk),
        .rst         (rst),
        .run         (core_run),
        .pc_load_en  (1'b0),      // no external PC jump in this mode
        .pc_load_val (32'd0),
        .pc_out      (pc_o),
        .instr_out   (instr_o),
        .result_out  (result_o),
        .rd_out      (rd_o),
        .mem_rd_out  (mem_rd_o),
        .halted      (halted)
    );

    //=========================================================================
    // RESULT LATCH
    // FIX: Capture outputs ONE cycle AFTER core_run, not on the same cycle.
    //      The core registers its outputs on the posedge where run=1, so
    //      result_o / pc_o are only valid the cycle after core_run fires.
    //=========================================================================
    reg core_run_d;  // core_run delayed by one cycle

    always @(posedge clk or posedge rst)
        if (rst) core_run_d <= 0;
        else     core_run_d <= core_run;

    // FIX: rd_latch widened to 32 bits to match the display mux usage.
    reg [31:0] result_latch;
    reg [31:0] pc_latch;
    reg [31:0] rd_latch;   // was [4:0] - widened to 32 bits
    reg [31:0] mem_latch;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result_latch <= 32'd0;
            pc_latch     <= 32'd0;
            rd_latch     <= 32'd0;
            mem_latch    <= 32'd0;
        end else if (core_run_d) begin   // latch AFTER the core has updated
            result_latch <= result_o;
            pc_latch     <= pc_o;
            rd_latch     <= {27'b0, rd_o};
            mem_latch    <= mem_rd_o;
        end
    end

    //=========================================================================
    // DISPLAY MUX  (SW[1:0] selects signal, SW[2] selects half)
    //=========================================================================
    reg [31:0] disp32;
    always @(*) begin
        case (sw[1:0])
            2'b00: disp32 = result_latch;
            2'b01: disp32 = pc_latch;
            2'b10: disp32 = rd_latch;
            2'b11: disp32 = mem_latch;
        endcase
    end

    wire [15:0] disp16 = sw[2] ? disp32[31:16] : disp32[15:0];

    //=========================================================================
    // 7-SEGMENT DISPLAY
    //=========================================================================
    seg7 display (
        .clk  (clk),
        .rst  (rst),
        .data (disp16),
        .dp_en(1'b0),   // no blinking needed in button-step mode
        .an   (an),
        .seg  (seg),
        .dp   (dp)
    );

    //=========================================================================
    // LEDs
    //=========================================================================
    assign led[15]   = halted;
    assign led[14:0] = result_latch[14:0];

endmodule