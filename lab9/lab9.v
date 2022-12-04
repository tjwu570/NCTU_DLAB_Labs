`timescale 1ns / 1ps
/////////////////////////////////////////////////////////
module lab9(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);
 
localparam [2:0] S_WAIT_BUTTON = 3'b000, S_MD5_RESET = 3'b001,S_MD5_READ_INPUT = 3'b010, S_MD5_CALCULATE= 3'b011,
                 S_MD5_COMPARE = 3'b100, S_SHOW_RESULT = 3'b101;  
// turn off all the LEDs
 
 
reg [0:8*16-1]password_hash =128'hef775988943825d2871e1cfa75473ec0;
 
/*
reg [0:8*16-1]password_hash =
{
        8'h82, 8'hCF, 8'h9f, 8'ha6, 8'h47, 8'hDd, 8'h1b, 8'h3f,
        8'hbd, 8'h9d, 8'he7, 8'h1b, 8'hbf, 8'hb8, 8'h3f, 8'hb2
};
*/
reg [127:0] row_A = "Press BTN to    "; // Initialize the text of the first row.
reg [127:0] row_B = "crack passwd...."; // Initialize the text of the second row.
 
reg [127:0] row_A_input; // Initialize the text of the first row.
reg [127:0] row_B_input; // Initialize the text of the second row.
 
wire [1:0]  btn_level, btn_pressed;
reg  [1:0]  prev_btn_level;
reg [2:0] P, P_next;
wire cal_done;
 
// md5 IO
wire reset_md5;
wire output_valid [0:13];
wire input_valid;
wire [0:128-1] output_hash[0:13];
wire [3:0] md5_state [0:13];
reg [0:8*32-1] output_hash_str [0:13];
reg [8*8-1:0] answer_str;
 
reg [8*8-1:0] test_str [0:13];
reg [8*8-1:0] prev_test_str [0:13];
integer cvt_idx;
 
wire matched;
 
LCD_module lcd0(
  .clk(clk),
  .reset(~reset_n),
  .row_A(row_A),
  .row_B(row_B),
  .LCD_E(LCD_E),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_D(LCD_D)
);
 
md5 md5_0( .clk(clk),  .reset(reset_md5),  .input_num(test_str[0]),  .input_valid(input_valid),  .output_hash(output_hash[0]),  .output_valid(output_valid[0]),  .state(md5_state[0]));
md5 md5_1( .clk(clk),  .reset(reset_md5),  .input_num(test_str[1]),  .input_valid(input_valid),  .output_hash(output_hash[1]),  .output_valid(output_valid[1]),  .state(md5_state[1]));
md5 md5_2( .clk(clk),  .reset(reset_md5),  .input_num(test_str[2]),  .input_valid(input_valid),  .output_hash(output_hash[2]),  .output_valid(output_valid[2]),  .state(md5_state[2]));
md5 md5_3( .clk(clk),  .reset(reset_md5),  .input_num(test_str[3]),  .input_valid(input_valid),  .output_hash(output_hash[3]),  .output_valid(output_valid[3]),  .state(md5_state[3]));
md5 md5_4( .clk(clk),  .reset(reset_md5),  .input_num(test_str[4]),  .input_valid(input_valid),  .output_hash(output_hash[4]),  .output_valid(output_valid[4]),  .state(md5_state[4]));
md5 md5_5( .clk(clk),  .reset(reset_md5),  .input_num(test_str[5]),  .input_valid(input_valid),  .output_hash(output_hash[5]),  .output_valid(output_valid[5]),  .state(md5_state[5]));
md5 md5_6( .clk(clk),  .reset(reset_md5),  .input_num(test_str[6]),  .input_valid(input_valid),  .output_hash(output_hash[6]),  .output_valid(output_valid[6]),  .state(md5_state[6]));
md5 md5_7( .clk(clk),  .reset(reset_md5),  .input_num(test_str[7]),  .input_valid(input_valid),  .output_hash(output_hash[7]),  .output_valid(output_valid[7]),  .state(md5_state[7]));
md5 md5_8( .clk(clk),  .reset(reset_md5),  .input_num(test_str[8]),  .input_valid(input_valid),  .output_hash(output_hash[8]),  .output_valid(output_valid[8]),  .state(md5_state[8]));
md5 md5_9( .clk(clk),  .reset(reset_md5),  .input_num(test_str[9]),  .input_valid(input_valid),  .output_hash(output_hash[9]),  .output_valid(output_valid[9]),  .state(md5_state[9]));
md5 md5_10( .clk(clk),  .reset(reset_md5),  .input_num(test_str[10]),  .input_valid(input_valid),  .output_hash(output_hash[10]),  .output_valid(output_valid[10]),  .state(md5_state[10]));
md5 md5_11( .clk(clk),  .reset(reset_md5),  .input_num(test_str[11]),  .input_valid(input_valid),  .output_hash(output_hash[11]),  .output_valid(output_valid[11]),  .state(md5_state[11]));
md5 md5_12( .clk(clk),  .reset(reset_md5),  .input_num(test_str[12]),  .input_valid(input_valid),  .output_hash(output_hash[12]),  .output_valid(output_valid[12]),  .state(md5_state[12]));
md5 md5_13( .clk(clk),  .reset(reset_md5),  .input_num(test_str[13]),  .input_valid(input_valid),  .output_hash(output_hash[13]),  .output_valid(output_valid[13]),  .state(md5_state[13]));
 
 
debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[3]),
  .btn_output(btn_level)
);          
 
assign reset_md5 = (P == S_MD5_RESET);
assign input_valid = (P == S_MD5_READ_INPUT);
assign matched = (((( password_hash == output_hash[0] ) || ( password_hash == output_hash[1] ))  ||  (( password_hash == output_hash[2] ) || ( password_hash == output_hash[3] ))) || ((( password_hash == output_hash[4] ) || ( password_hash == output_hash[5] ))  ||  (( password_hash == output_hash[6] ) || ( password_hash == output_hash[7] )))) || (((( password_hash == output_hash[8] ) || ( password_hash == output_hash[9] ))  ||  (( password_hash == output_hash[10] ) || ( password_hash == output_hash[11] ))) || ((( password_hash == output_hash[12] ) || ( password_hash == output_hash[13] ))  ||  (( password_hash == output_hash[13] ) || ( password_hash == output_hash[13] ))));
 
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1;
  else
    prev_btn_level <= btn_level;
end
 
assign btn_pressed = (btn_level & ~prev_btn_level);
 
 
 
 
//write LCD
always @(posedge clk) begin
    row_A <= row_A_input;
    row_B <=  row_B_input;
end
 
always @(posedge clk) begin
    if (~reset_n) begin
        row_A_input <= "Press BTN3 to   ";
        row_B_input <= "start cracking  ";
    end
    else begin
        if(P == S_WAIT_BUTTON)begin
            row_A_input <= "Press BTN3 to   ";
            row_B_input <= "start cracking  ";
        end
        else if(P == S_SHOW_RESULT)begin
            if(output_valid[0])begin
                if ( password_hash == output_hash[0]) row_A_input <= {"Passwd: ", prev_test_str[0]};
                else if ( password_hash == output_hash[1]) row_A_input <= {"Passwd: ", prev_test_str[1]};
                else if ( password_hash == output_hash[2]) row_A_input <= {"Passwd: ", prev_test_str[2]};
                else if ( password_hash == output_hash[3]) row_A_input <= {"Passwd: ", prev_test_str[3]};
                else if ( password_hash == output_hash[4]) row_A_input <= {"Passwd: ", prev_test_str[4]};
                else if ( password_hash == output_hash[5]) row_A_input <= {"Passwd: ", prev_test_str[5]};
                else if ( password_hash == output_hash[6]) row_A_input <= {"Passwd: ", prev_test_str[6]};
                else if ( password_hash == output_hash[7]) row_A_input <= {"Passwd: ", prev_test_str[7]};
                else if ( password_hash == output_hash[8]) row_A_input <= {"Passwd: ", prev_test_str[8]};
                else if ( password_hash == output_hash[9]) row_A_input <= {"Passwd: ", prev_test_str[9]};
                else if ( password_hash == output_hash[10]) row_A_input <= {"Passwd: ", prev_test_str[10]};
                else if ( password_hash == output_hash[11]) row_A_input <= {"Passwd: ", prev_test_str[11]};
                else if ( password_hash == output_hash[12]) row_A_input <= {"Passwd: ", prev_test_str[12]};
                else if ( password_hash == output_hash[13]) row_A_input <= {"Passwd: ", prev_test_str[13]};
                row_B_input <= {"Time: ", cnt[40 +: 56], " ms"};
            end
        end
    end
end
 
// convert output hash to ASCII hex
integer i;
always @(posedge clk) begin
    for (i = 0; i< 32; i = i+1)begin
        output_hash_str[0][(i*8)+:8] <= ((output_hash[0][(i*4)+:4]>9)? "7" : "0") + output_hash[0][(i*4)+:4];
        output_hash_str[1][(i*8)+:8] <= ((output_hash[1][(i*4)+:4]>9)? "7" : "0") + output_hash[1][(i*4)+:4];
        output_hash_str[2][(i*8)+:8] <= ((output_hash[2][(i*4)+:4]>9)? "7" : "0") + output_hash[2][(i*4)+:4];
        output_hash_str[3][(i*8)+:8] <= ((output_hash[3][(i*4)+:4]>9)? "7" : "0") + output_hash[3][(i*4)+:4];
        output_hash_str[4][(i*8)+:8] <= ((output_hash[4][(i*4)+:4]>9)? "7" : "0") + output_hash[4][(i*4)+:4];
        output_hash_str[5][(i*8)+:8] <= ((output_hash[5][(i*4)+:4]>9)? "7" : "0") + output_hash[5][(i*4)+:4];
        output_hash_str[6][(i*8)+:8] <= ((output_hash[6][(i*4)+:4]>9)? "7" : "0") + output_hash[6][(i*4)+:4];
        output_hash_str[7][(i*8)+:8] <= ((output_hash[7][(i*4)+:4]>9)? "7" : "0") + output_hash[7][(i*4)+:4];
        output_hash_str[8][(i*8)+:8] <= ((output_hash[8][(i*4)+:4]>9)? "7" : "0") + output_hash[8][(i*4)+:4];
        output_hash_str[9][(i*8)+:8] <= ((output_hash[9][(i*4)+:4]>9)? "7" : "0") + output_hash[9][(i*4)+:4];
        output_hash_str[10][(i*8)+:8] <= ((output_hash[10][(i*4)+:4]>9)? "7" : "0") + output_hash[10][(i*4)+:4];
        output_hash_str[11][(i*8)+:8] <= ((output_hash[11][(i*4)+:4]>9)? "7" : "0") + output_hash[11][(i*4)+:4];
        output_hash_str[12][(i*8)+:8] <= ((output_hash[12][(i*4)+:4]>9)? "7" : "0") + output_hash[12][(i*4)+:4];
        output_hash_str[13][(i*8)+:8] <= ((output_hash[13][(i*4)+:4]>9)? "7" : "0") + output_hash[13][(i*4)+:4];
    end
end
 
// conver dec integer to dec string
always @(posedge clk) begin
    if ( (P ==S_MD5_RESET) | (P ==S_SHOW_RESULT) ) begin
        if (cvt_idx>100) cvt_idx <=100;
        else cvt_idx <= cvt_idx +1;
    end else begin
        cvt_idx <= 0;
    end
end
 
integer idx_1;
always @(posedge clk) begin
    if(P==S_SHOW_RESULT && cvt_idx < 8) begin
        for (idx_1=0; idx_1 <= 13; idx_1 = idx_1 +1) begin
            answer_str[idx_1] <= test_str[idx_1];
        end
    end
end
 
integer idx;
// FSM of the main controller
always @(posedge clk) begin
    if (~reset_n) begin
        test_str[0] <= "00000000";
        test_str[1] <= "07000000";
        test_str[2] <= "14000000";
        test_str[3] <= "21000000";
        test_str[4] <= "28000000";
        test_str[5] <= "35000000";
        test_str[6] <= "42000000";
        test_str[7] <= "49000000";
        test_str[8] <= "56000000";
        test_str[9] <= "63000000";
        test_str[10] <= "70000000";
        test_str[11] <= "77000000";
        test_str[12] <= "84000000";
        test_str[13] <= "91000000";
       
        prev_test_str[0] <= "00000000";
        prev_test_str[1] <= "07000000";
        prev_test_str[2] <= "14000000";
        prev_test_str[3] <= "21000000";
        prev_test_str[4] <= "28000000";
        prev_test_str[5] <= "35000000";
        prev_test_str[6] <= "42000000";
        prev_test_str[7] <= "49000000";
        prev_test_str[8] <= "56000000";
        prev_test_str[9] <= "63000000";
        prev_test_str[10] <= "70000000";
        prev_test_str[11] <= "77000000";
        prev_test_str[12] <= "84000000";
        prev_test_str[13] <= "91000000";
    end
    else if(P == S_MD5_COMPARE) begin
        for (idx=0; idx<=13; idx=idx+1) begin
            if (test_str[idx][ 0 +: 4] == 4'h9) begin test_str[idx][ 0 +: 4] <= 4'h0;
            if (test_str[idx][ 8 +: 4] == 4'h9) begin test_str[idx][ 8 +: 4] <= 4'h0;
            if (test_str[idx][16 +: 4] == 4'h9) begin test_str[idx][16 +: 4] <= 4'h0;
            if (test_str[idx][24 +: 4] == 4'h9) begin test_str[idx][24 +: 4] <= 4'h0;
            if (test_str[idx][32 +: 4] == 4'h9) begin test_str[idx][32 +: 4] <= 4'h0;
            if (test_str[idx][40 +: 4] == 4'h9) begin test_str[idx][40 +: 4] <= 4'h0;
            if (test_str[idx][48 +: 4] == 4'h9) begin test_str[idx][48 +: 4] <= 4'h0;
            if (test_str[idx][56 +: 4] == 4'h9) begin test_str[idx][56 +: 4] <= 4'h0;
            end else test_str[idx][56 +: 4] <= test_str[idx][56 +: 4] + 1;
            end else test_str[idx][48 +: 4] <= test_str[idx][48 +: 4] + 1;
            end else test_str[idx][40 +: 4] <= test_str[idx][40 +: 4] + 1;
            end else test_str[idx][32 +: 4] <= test_str[idx][32 +: 4] + 1;
            end else test_str[idx][24 +: 4] <= test_str[idx][24 +: 4] + 1;
            end else test_str[idx][16 +: 4] <= test_str[idx][16 +: 4] + 1;
            end else test_str[idx][ 8 +: 4] <= test_str[idx][ 8 +: 4] + 1;
            end else test_str[idx][ 0 +: 4] <= test_str[idx][ 0 +: 4] + 1;
            prev_test_str[idx] <= test_str[idx];
        end
    end
 
end
 
 
 
reg [95 : 0] cnt = 0;
always @(posedge clk) begin
    if (P == S_WAIT_BUTTON) begin
        cnt <= "000000000000";
    end
    else if (P != S_SHOW_RESULT) begin
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
 
 
 
// FSM of the main controller
always @(posedge clk) begin
  if (~reset_n) P <= S_WAIT_BUTTON; // read samples at 000 first
  else P <= P_next;
end
always @(*) begin // FSM next-state logic
    case (P)
        S_WAIT_BUTTON: // send an address to the SRAM
            if(btn_pressed) P_next = S_MD5_RESET;
            else P_next = S_WAIT_BUTTON;
        S_MD5_RESET:
            if(cvt_idx >=8) P_next = S_MD5_READ_INPUT;
            else P_next =S_MD5_RESET;
        S_MD5_READ_INPUT:
            P_next = S_MD5_CALCULATE;
        S_MD5_CALCULATE:
            if (output_valid[0]) P_next = S_MD5_COMPARE;
            else P_next = S_MD5_CALCULATE;
        S_MD5_COMPARE: // output data to lcd
            if(matched) P_next = S_SHOW_RESULT;
            else P_next = S_MD5_RESET;
        S_SHOW_RESULT: // wait for a button click
            if (btn_pressed == 1) P_next = S_WAIT_BUTTON;
            else P_next = S_SHOW_RESULT;
  endcase
end
 
assign usr_led = {(P==S_MD5_RESET), (P==S_MD5_READ_INPUT), (P==S_MD5_CALCULATE), (P==S_MD5_COMPARE)};
 
 
endmodule
 
//Issues: parallel,  wrong answer
 

