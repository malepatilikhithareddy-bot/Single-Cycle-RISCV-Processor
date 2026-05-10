//=============================================================================
// seg7.v - 4-digit multiplexed 7-segment display for Basys3
// Shows 4 hex digits. Refresh ~381Hz per digit.
//=============================================================================
module seg7 (
    input         clk,
    input         rst,
    input  [15:0] data,     // 16-bit hex value to display
    input         dp_en,    // 1 = blink decimal point (entry mode)
    output reg [3:0] an,    // active-low anodes
    output reg [6:0] seg,   // active-low segments (abcdefg)
    output        dp        // decimal point
);
    // Blink counter for DP
    reg [24:0] blink_cnt;
    always @(posedge clk or posedge rst)
        if (rst) blink_cnt <= 0;
        else     blink_cnt <= blink_cnt + 1;

    assign dp = dp_en ? blink_cnt[24] : 1'b1; // 1=OFF on Basys3

    // Refresh counter
    reg [17:0] cnt;
    always @(posedge clk or posedge rst)
        if (rst) cnt <= 0;
        else     cnt <= cnt + 1;

    wire [1:0] sel = cnt[17:16];

    reg [3:0] nibble;
    always @(*) begin
        case (sel)
            2'b00: begin an=4'b1110; nibble=data[3:0];   end
            2'b01: begin an=4'b1101; nibble=data[7:4];   end
            2'b10: begin an=4'b1011; nibble=data[11:8];  end
            2'b11: begin an=4'b0111; nibble=data[15:12]; end
        endcase
    end

    // seg[6:0] = {g,f,e,d,c,b,a}  (active-low; seg[0]=a=top per XDC)
    always @(*) begin
        case (nibble)
            //             gfedcba
            4'h0: seg=7'b1000000; // a,b,c,d,e,f ON  ; g OFF
            4'h1: seg=7'b1111001; // b,c ON
            4'h2: seg=7'b0100100; // a,b,d,e,g ON
            4'h3: seg=7'b0110000; // a,b,c,d,g ON
            4'h4: seg=7'b0011001; // b,c,f,g ON
            4'h5: seg=7'b0010010; // a,c,d,f,g ON
            4'h6: seg=7'b0000010; // a,c,d,e,f,g ON
            4'h7: seg=7'b1111000; // a,b,c ON
            4'h8: seg=7'b0000000; // all ON
            4'h9: seg=7'b0010000; // a,b,c,d,f,g ON
            4'hA: seg=7'b0001000; // a,b,c,e,f,g ON
            4'hB: seg=7'b0000011; // c,d,e,f,g ON
            4'hC: seg=7'b1000110; // a,d,e,f ON
            4'hD: seg=7'b0100001; // b,c,d,e,g ON
            4'hE: seg=7'b0000110; // a,d,e,f,g ON
            4'hF: seg=7'b0001110; // a,e,f,g ON
            default: seg=7'b1111111; // all OFF
        endcase
    end
endmodule
