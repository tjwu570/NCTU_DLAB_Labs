`timescale 1ps/1ns

reg [0 : 127] passwd_hash = 128'hE8CD0953ABDFDE433DFEC7FAA70DF7F6;

reg [95 : 0] cnt = 0;

reg [4 : 0] r [0 : 5] = {
7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 
5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 
4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 
6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21 };

reg [31 : 0] k [0 : 5] = {
32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 
32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501, 
32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 
32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821, 
32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 
32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8, 
32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 
32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a, 
32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 
32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70, 
32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 
32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665, 
32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 
32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1, 
32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 
32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};
 

module lab9(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,

  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

reg [127 : 0] hash_0 = 0;

md5_0000_0000 md5_0(
    hash_outcome(hash_0)
)

wire btn_level, btn_pressed;
reg  prev_btn_level;
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;
debounce btn_db2(
  .clk(clk),
  .btn_input(usr_btn[2]),
  .btn_output(btn_level)
);

LCD_module lcd0(
    .clk(clk), 
    .reset(~reset_n), 
    .row_A(row_A), 
    .row_B(row_B),
    .LCD_E(LCD_E), 
    .LCD_RS(LCD_RS), 
    .LCD_RW(LCD_RW), 
    .LCD_D(LCD_D));

// Timer
always @(posedge clk) begin
    if (P == S_MAIN_INIT)
        cnt <= "000000000000";
    else if (P == S_MAIN_CALC) begin
        if (cnt[ 0 +: 4] == 4'h9) begin cnt[ 0 +: 4] <= 4'h0;
        if (cnt[ 8 +: 4] == 4'h9) begin cnt[ 8 +: 4] <= 4'h0;
        if (cnt[16 +: 4] == 4'h9) begin cnt[16 +: 4] <= 4'h0;
        if (cnt[24 +: 4] == 4'h9) begin cnt[24 +: 4] <= 4'h0;
        if (cnt[32 +: 4] == 4'h9) begin cnt[32 +: 4] <= 4'h0;
        if (cnt[40 +: 4] == 4'h9) begin cnt[40 +: 4] <= 4'h0;
        if (cnt[48 +: 4] == 4'h9) begin cnt[48 +: 4] <= 4'h0;
        if (cnt[56 +: 4] == 4'h9) begin cnt[56 +: 4] <= 4'h0;
        if (cnt[64 +: 4] == 4'h9) begin cnt[64 +: 4] <= 4'h0;
        if (cnt[72 +: 4] == 4'h9) begin cnt[72 +: 4] <= 4'h0;
        if (cnt[80 +: 4] == 4'h9) begin cnt[80 +: 4] <= 4'h0;
        if (cnt[88 +: 4] == 4'h9) begin cnt[88 +: 4] <= 4'h0;
        end else cnt[88 +: 4] <= cnt[88 +: 4] + 1;
        end else cnt[80 +: 4] <= cnt[80 +: 4] + 1;
        end else cnt[72 +: 4] <= cnt[72 +: 4] + 1;
        end else cnt[64 +: 4] <= cnt[64 +: 4] + 1;
        end else cnt[56 +: 4] <= cnt[56 +: 4] + 1;
        end else cnt[48 +: 4] <= cnt[48 +: 4] + 1;
        end else cnt[40 +: 4] <= cnt[40 +: 4] + 1;
        end else cnt[32 +: 4] <= cnt[32 +: 4] + 1;
        end else cnt[24 +: 4] <= cnt[24 +: 4] + 1;
        end else cnt[16 +: 4] <= cnt[16 +: 4] + 1;
        end else cnt[ 8 +: 4] <= cnt[ 8 +: 4] + 1;
        end else cnt[ 0 +: 4] <= cnt[ 0 +: 4] + 1;
    end
end

 // LCD Display function.
 always @(posedge clk) begin
 if (P == S_MAIN_INIT) begin
    row_A <= "Press BTN2 TO ";
    row_B <= "start calcualte ";
 end else if (P == S_MAIN_CALC) begin
    row_A <= "Calculating.....";
    row_B <= " ";
 end else if (P == S_MAIN_SHOW) begin
    row_A <= {"Passwd: ", ans_reg};
    row_B <= {"Time: ", cnt[40 +: 56], " ms"};
 end
 end

 endmodule



 module md5_0000_0000(output reg [127 : 0] hash_outcome)

 reg [31 : 0] h0 = 32'h67452301;
 reg [31 : 0] h1 = 32'h67452301;
 reg [31 : 0] h2 = 32'h67452301;
 reg [31 : 0] h3 = 32'h67452301;

 endmodule