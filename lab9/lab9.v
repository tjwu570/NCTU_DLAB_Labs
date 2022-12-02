`timescale 1ps/1ns

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
reg [95 : 0] cnt = 0;
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


