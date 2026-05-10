//=============================================================================
// tb_top.v - Testbench: simulates keypad pressing "05*"
// -> should execute instruction at address 5 (OR x6,x1,x2 -> result=7)
//=============================================================================
`timescale 1ns/1ps
module tb_top;
    reg        clk, rst;
    reg [15:0] sw;

    // Simulate keypad: drive col based on row
    wire [3:0] jA_row;
    reg  [3:0] jA_col;
    wire [3:0] an;
    wire [6:0] seg;
    wire       dp;
    wire [15:0] led;

    top dut (
        .clk(clk), .btnU(rst), .sw(sw),
        .an(an), .seg(seg), .dp(dp), .led(led),
        .jA_row(jA_row), .jA_col(jA_col)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Task: press a key for ~5ms (500000 cycles) then release
    task press_key;
        input [3:0] row_mask; // which row the key is on (active low)
        input [3:0] col_mask; // which col the key is on (active low)
        integer i;
        begin
            // Wait until scanner drives the right row
            @(posedge clk);
            // Simulate key held for enough scan ticks
            repeat (300000) begin
                @(posedge clk);
                if (jA_row == row_mask)
                    jA_col = col_mask;
                else
                    jA_col = 4'hF;
            end
            jA_col = 4'hF; // release
            repeat (200000) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
        sw     = 16'h0000;
        jA_col = 4'hF;
        rst    = 1;
        repeat(20) @(posedge clk);
        rst = 0;
        repeat(100) @(posedge clk);

        $display("=== Pressing key '0' (row3, col1) ===");
        press_key(4'b0111, 4'b1101); // key '0'

        $display("=== Pressing key '5' (row1, col1) ===");
        press_key(4'b1101, 4'b1101); // key '5'

        $display("=== Pressing key '*' = CONFIRM (row3, col0) ===");
        press_key(4'b0111, 4'b1110); // key '*'

        // Wait for execution
        repeat(200) @(posedge clk);

        $display("PC     = %08h", dut.pc_o);
        $display("INSTR  = %08h", dut.instr_o);
        $display("RESULT = %08h (expect 00000007 for OR)", dut.result_latch);
        $display("LEDs   = %016b", led);

        repeat(100) @(posedge clk);
        $finish;
    end
endmodule
