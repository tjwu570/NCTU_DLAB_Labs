`timescale 1ns/1ps

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


reg [0 : 127] passwd_hash = 128'hE8CD0953ABDFDE433DFEC7FAA70DF7F6;
reg found;
reg  [63:0]  att  [0:2];
wire [127:0] hash0, hash1, hash2;
wire [63:0]  ans0, ans1, ans2;
reg  [63:0]  ans_pwd;

wire btn_level, btn_pressed;
reg  prev_btn_level;
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;
debounce btn_db2(
  .clk(clk),
  .btn_input(usr_btn[2]),
  .btn_output(btn_level)
);

reg  [127:0] row_A;
reg  [127:0] row_B;
LCD_module lcd0(
    .clk(clk), 
    .reset(~reset_n), 
    .row_A(row_A), 
    .row_B(row_B),
    .LCD_E(LCD_E), 
    .LCD_RS(LCD_RS), 
    .LCD_RW(LCD_RW), 
    .LCD_D(LCD_D));

md5 m0(.clk(clk), .att(att[0]), .hash(hash0), .current_att(ans0));
md5 m1(.clk(clk), .att(att[1]), .hash(hash1), .current_att(ans1));
md5 m2(.clk(clk), .att(att[2]), .hash(hash2), .current_att(ans2));

reg  [1:0] P, P_next;
localparam [1:0] S_MAIN_INIT = 2'b00, S_MAIN_CALC = 2'b01, S_MAIN_SHOW = 2'b10;
always @(*) begin // FSM next-state logic
    case (P)
        S_MAIN_INIT:
            if (btn_pressed) P_next <= S_MAIN_CALC;
            else P_next <= S_MAIN_INIT;
        S_MAIN_CALC:
            if (found) P_next <= S_MAIN_SHOW;
            else P_next <= S_MAIN_CALC;
        S_MAIN_SHOW:
            if (btn_pressed) P_next <= S_MAIN_INIT;
            else P_next <= S_MAIN_SHOW;
        default:
            P_next <= S_MAIN_INIT;
    endcase
end
always @(posedge clk) begin
    if (~reset_n) P <= S_MAIN_INIT;
    else P <= P_next;
end
// Check md5 output
always @(posedge clk) begin
    if (P == S_MAIN_INIT) found <= 0;
    else if (hash0 == passwd_hash) begin found <= 1; ans_pwd <= ans0; end
    else if (hash1 == passwd_hash) begin found <= 1; ans_pwd <= ans1; end
    else if (hash2 == passwd_hash) begin found <= 1; ans_pwd <= ans2; end
end

// Timer & set starter
reg [95 : 0] cnt = 0;
always @(posedge clk) begin
    if (P == S_MAIN_INIT) begin
        cnt <= "000000000000";
        att[0] <= "00000000";
        att[1] <= "33333333";
        att[2] <= "66666666";
    end
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
    row_A <= "Press BTN2 TO   ";
    row_B <= "start calcualte ";
 end else if (P == S_MAIN_CALC) begin
    row_A <= "Calculating.....";
    row_B <= "                ";
 end else if (P == S_MAIN_SHOW) begin
    row_A <= {"Passwd: ", ans_pwd};
    row_B <= {"Time: ", cnt[40 +: 56], " ms"};
 end
 end

 endmodule
