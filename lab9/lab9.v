`timescale 1ns / 1ps
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
 
 
reg [0:8*16-1]password_hash = 128'hE8CD0953ABDFDE433DFEC7FAA70DF7F6;
 
 
reg [127:0] row_A = "Press BTN3 to   ";
reg [127:0] row_B = "crack passwd....";
 
reg [127:0] row_A_input;
reg [127:0] row_B_input;
 
wire [1:0]  btn_level, btn_pressed;
reg  [1:0]  prev_btn_level;
reg [2:0] P, P_next;
wire cal_done;
 
wire reset_md5;
wire output_valid [0:32];
wire input_valid;
wire [0:128-1] output_hash[0:32];
wire [3:0] md5_state [0:32];
reg [0:8*32-1] output_hash_str [0:32];
reg [8*8-1:0] answer_str;
 
reg [8*8-1:0] test_str [0:32];
reg [8*8-1:0] prev_test_str [0:32];
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
md5 md5_14( .clk(clk),  .reset(reset_md5),  .input_num(test_str[14]),  .input_valid(input_valid),  .output_hash(output_hash[14]),  .output_valid(output_valid[14]),  .state(md5_state[14]));
md5 md5_15( .clk(clk),  .reset(reset_md5),  .input_num(test_str[15]),  .input_valid(input_valid),  .output_hash(output_hash[15]),  .output_valid(output_valid[15]),  .state(md5_state[15]));
md5 md5_16( .clk(clk),  .reset(reset_md5),  .input_num(test_str[16]),  .input_valid(input_valid),  .output_hash(output_hash[16]),  .output_valid(output_valid[16]),  .state(md5_state[16]));
md5 md5_17( .clk(clk),  .reset(reset_md5),  .input_num(test_str[17]),  .input_valid(input_valid),  .output_hash(output_hash[17]),  .output_valid(output_valid[17]),  .state(md5_state[17]));
md5 md5_18( .clk(clk),  .reset(reset_md5),  .input_num(test_str[18]),  .input_valid(input_valid),  .output_hash(output_hash[18]),  .output_valid(output_valid[18]),  .state(md5_state[18]));
md5 md5_19( .clk(clk),  .reset(reset_md5),  .input_num(test_str[19]),  .input_valid(input_valid),  .output_hash(output_hash[19]),  .output_valid(output_valid[19]),  .state(md5_state[19]));
md5 md5_20( .clk(clk),  .reset(reset_md5),  .input_num(test_str[20]),  .input_valid(input_valid),  .output_hash(output_hash[20]),  .output_valid(output_valid[20]),  .state(md5_state[20]));
md5 md5_21( .clk(clk),  .reset(reset_md5),  .input_num(test_str[21]),  .input_valid(input_valid),  .output_hash(output_hash[21]),  .output_valid(output_valid[21]),  .state(md5_state[21]));
md5 md5_22( .clk(clk),  .reset(reset_md5),  .input_num(test_str[22]),  .input_valid(input_valid),  .output_hash(output_hash[22]),  .output_valid(output_valid[22]),  .state(md5_state[22]));
md5 md5_23( .clk(clk),  .reset(reset_md5),  .input_num(test_str[23]),  .input_valid(input_valid),  .output_hash(output_hash[23]),  .output_valid(output_valid[23]),  .state(md5_state[23]));
md5 md5_24( .clk(clk),  .reset(reset_md5),  .input_num(test_str[24]),  .input_valid(input_valid),  .output_hash(output_hash[24]),  .output_valid(output_valid[24]),  .state(md5_state[24]));
md5 md5_25( .clk(clk),  .reset(reset_md5),  .input_num(test_str[25]),  .input_valid(input_valid),  .output_hash(output_hash[25]),  .output_valid(output_valid[25]),  .state(md5_state[25]));
md5 md5_26( .clk(clk),  .reset(reset_md5),  .input_num(test_str[26]),  .input_valid(input_valid),  .output_hash(output_hash[26]),  .output_valid(output_valid[26]),  .state(md5_state[26]));
md5 md5_27( .clk(clk),  .reset(reset_md5),  .input_num(test_str[27]),  .input_valid(input_valid),  .output_hash(output_hash[27]),  .output_valid(output_valid[27]),  .state(md5_state[27]));
md5 md5_28( .clk(clk),  .reset(reset_md5),  .input_num(test_str[28]),  .input_valid(input_valid),  .output_hash(output_hash[28]),  .output_valid(output_valid[28]),  .state(md5_state[28]));
md5 md5_29( .clk(clk),  .reset(reset_md5),  .input_num(test_str[29]),  .input_valid(input_valid),  .output_hash(output_hash[29]),  .output_valid(output_valid[29]),  .state(md5_state[29]));
md5 md5_30( .clk(clk),  .reset(reset_md5),  .input_num(test_str[30]),  .input_valid(input_valid),  .output_hash(output_hash[30]),  .output_valid(output_valid[30]),  .state(md5_state[30]));
md5 md5_31( .clk(clk),  .reset(reset_md5),  .input_num(test_str[31]),  .input_valid(input_valid),  .output_hash(output_hash[31]),  .output_valid(output_valid[31]),  .state(md5_state[31]));
md5 md5_32( .clk(clk),  .reset(reset_md5),  .input_num(test_str[32]),  .input_valid(input_valid),  .output_hash(output_hash[32]),  .output_valid(output_valid[32]),  .state(md5_state[32]));
 
 
debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[3]),
  .btn_output(btn_level)
);          
 
assign reset_md5 = (P == S_MD5_RESET);
assign input_valid = (P == S_MD5_READ_INPUT);
assign matched = (((((( password_hash == output_hash[0] ) || ( password_hash == output_hash[1] ))  ||  (( password_hash == output_hash[2] ) || ( password_hash == output_hash[3] ))) || ((( password_hash == output_hash[4] ) || ( password_hash == output_hash[5] ))  ||  (( password_hash == output_hash[6] ) || ( password_hash == output_hash[7] )))) || (((( password_hash == output_hash[8] ) || ( password_hash == output_hash[9] ))  ||  (( password_hash == output_hash[10] ) || ( password_hash == output_hash[11] ))) || ((( password_hash == output_hash[12] ) || ( password_hash == output_hash[13] ))  ||  (( password_hash == output_hash[14] ) || ( password_hash == output_hash[15] )))) ||
                 (((( password_hash == output_hash[16] ) || ( password_hash == output_hash[17] ))  ||  (( password_hash == output_hash[18] ) || ( password_hash == output_hash[19] ))) || ((( password_hash == output_hash[20] ) || ( password_hash == output_hash[21] ))  ||  (( password_hash == output_hash[22] ) || ( password_hash == output_hash[23] )))) || (((( password_hash == output_hash[24] ) || ( password_hash == output_hash[25] ))  ||  (( password_hash == output_hash[26] ) || ( password_hash == output_hash[27] ))) || ((( password_hash == output_hash[28] ) || ( password_hash == output_hash[29] ))  ||  (( password_hash == output_hash[30] ) || ( password_hash == output_hash[31] ))))) || (( password_hash == output_hash[32] ) || ( password_hash == output_hash[32] )));
 
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
                else if ( password_hash == output_hash[14]) row_A_input <= {"Passwd: ", prev_test_str[14]};
                else if ( password_hash == output_hash[15]) row_A_input <= {"Passwd: ", prev_test_str[15]};
                else if ( password_hash == output_hash[16]) row_A_input <= {"Passwd: ", prev_test_str[16]};
                else if ( password_hash == output_hash[17]) row_A_input <= {"Passwd: ", prev_test_str[17]};
                else if ( password_hash == output_hash[18]) row_A_input <= {"Passwd: ", prev_test_str[18]};
                else if ( password_hash == output_hash[19]) row_A_input <= {"Passwd: ", prev_test_str[19]};
                else if ( password_hash == output_hash[20]) row_A_input <= {"Passwd: ", prev_test_str[20]};
                else if ( password_hash == output_hash[21]) row_A_input <= {"Passwd: ", prev_test_str[21]};
                else if ( password_hash == output_hash[22]) row_A_input <= {"Passwd: ", prev_test_str[22]};
                else if ( password_hash == output_hash[23]) row_A_input <= {"Passwd: ", prev_test_str[23]};
                else if ( password_hash == output_hash[24]) row_A_input <= {"Passwd: ", prev_test_str[24]};
                else if ( password_hash == output_hash[25]) row_A_input <= {"Passwd: ", prev_test_str[25]};
                else if ( password_hash == output_hash[26]) row_A_input <= {"Passwd: ", prev_test_str[26]};
                else if ( password_hash == output_hash[27]) row_A_input <= {"Passwd: ", prev_test_str[27]};
                else if ( password_hash == output_hash[28]) row_A_input <= {"Passwd: ", prev_test_str[28]};
                else if ( password_hash == output_hash[29]) row_A_input <= {"Passwd: ", prev_test_str[29]};
                else if ( password_hash == output_hash[30]) row_A_input <= {"Passwd: ", prev_test_str[30]};
                else if ( password_hash == output_hash[31]) row_A_input <= {"Passwd: ", prev_test_str[31]};
                else if ( password_hash == output_hash[32]) row_A_input <= {"Passwd: ", prev_test_str[32]};
                row_B_input <= {"Time: ", cnt[40 +: 56], " ms"};
            end
        end
    end
end
 
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
        output_hash_str[14][(i*8)+:8] <= ((output_hash[14][(i*4)+:4]>9)? "7" : "0") + output_hash[14][(i*4)+:4];
        output_hash_str[15][(i*8)+:8] <= ((output_hash[15][(i*4)+:4]>9)? "7" : "0") + output_hash[15][(i*4)+:4];
        output_hash_str[16][(i*8)+:8] <= ((output_hash[16][(i*4)+:4]>9)? "7" : "0") + output_hash[16][(i*4)+:4];
        output_hash_str[17][(i*8)+:8] <= ((output_hash[17][(i*4)+:4]>9)? "7" : "0") + output_hash[17][(i*4)+:4];
        output_hash_str[18][(i*8)+:8] <= ((output_hash[18][(i*4)+:4]>9)? "7" : "0") + output_hash[18][(i*4)+:4];
        output_hash_str[19][(i*8)+:8] <= ((output_hash[19][(i*4)+:4]>9)? "7" : "0") + output_hash[19][(i*4)+:4];
        output_hash_str[20][(i*8)+:8] <= ((output_hash[20][(i*4)+:4]>9)? "7" : "0") + output_hash[20][(i*4)+:4];
        output_hash_str[21][(i*8)+:8] <= ((output_hash[21][(i*4)+:4]>9)? "7" : "0") + output_hash[21][(i*4)+:4];
        output_hash_str[22][(i*8)+:8] <= ((output_hash[22][(i*4)+:4]>9)? "7" : "0") + output_hash[22][(i*4)+:4];
        output_hash_str[23][(i*8)+:8] <= ((output_hash[23][(i*4)+:4]>9)? "7" : "0") + output_hash[23][(i*4)+:4];
        output_hash_str[24][(i*8)+:8] <= ((output_hash[24][(i*4)+:4]>9)? "7" : "0") + output_hash[24][(i*4)+:4];
        output_hash_str[25][(i*8)+:8] <= ((output_hash[25][(i*4)+:4]>9)? "7" : "0") + output_hash[25][(i*4)+:4];
        output_hash_str[26][(i*8)+:8] <= ((output_hash[26][(i*4)+:4]>9)? "7" : "0") + output_hash[26][(i*4)+:4];
        output_hash_str[27][(i*8)+:8] <= ((output_hash[27][(i*4)+:4]>9)? "7" : "0") + output_hash[27][(i*4)+:4];
        output_hash_str[28][(i*8)+:8] <= ((output_hash[28][(i*4)+:4]>9)? "7" : "0") + output_hash[28][(i*4)+:4];
        output_hash_str[29][(i*8)+:8] <= ((output_hash[29][(i*4)+:4]>9)? "7" : "0") + output_hash[29][(i*4)+:4];
        output_hash_str[30][(i*8)+:8] <= ((output_hash[30][(i*4)+:4]>9)? "7" : "0") + output_hash[30][(i*4)+:4];
        output_hash_str[31][(i*8)+:8] <= ((output_hash[31][(i*4)+:4]>9)? "7" : "0") + output_hash[31][(i*4)+:4];
        output_hash_str[32][(i*8)+:8] <= ((output_hash[32][(i*4)+:4]>9)? "7" : "0") + output_hash[32][(i*4)+:4];
    end
end
 
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
        for (idx_1=0; idx_1 <= 32; idx_1 = idx_1 +1) begin
            answer_str[idx_1] <= test_str[idx_1];
        end
    end
end
 
integer idx;
always @(posedge clk) begin
    if (~reset_n) begin
        test_str[0] <= "00000000";
        test_str[1] <= "03000000";
        test_str[2] <= "06000000";
        test_str[3] <= "09000000";
        test_str[4] <= "12000000";
        test_str[5] <= "15000000";
        test_str[6] <= "18000000";
        test_str[7] <= "21000000";
        test_str[8] <= "24000000";
        test_str[9] <= "27000000";
        test_str[10] <= "30000000";
        test_str[11] <= "33000000";
        test_str[12] <= "36000000";
        test_str[13] <= "39000000";
        test_str[14] <= "42000000";
        test_str[15] <= "45000000";
        test_str[16] <= "48000000";
        test_str[17] <= "51000000";
        test_str[18] <= "54000000";
        test_str[19] <= "57000000";
        test_str[20] <= "60000000";
        test_str[21] <= "63000000";
        test_str[22] <= "66000000";
        test_str[23] <= "69000000";
        test_str[24] <= "72000000";
        test_str[25] <= "75000000";
        test_str[26] <= "78000000";
        test_str[27] <= "81000000";
        test_str[28] <= "84000000";
        test_str[29] <= "87000000";
        test_str[30] <= "90000000";
        test_str[31] <= "93000000";
        test_str[32] <= "96000000";
       
        prev_test_str[0] <= "00000000";
        prev_test_str[1] <= "03000000";
        prev_test_str[2] <= "06000000";
        prev_test_str[3] <= "09000000";
        prev_test_str[4] <= "12000000";
        prev_test_str[5] <= "15000000";
        prev_test_str[6] <= "18000000";
        prev_test_str[7] <= "21000000";
        prev_test_str[8] <= "24000000";
        prev_test_str[9] <= "27000000";
        prev_test_str[10] <= "30000000";
        prev_test_str[11] <= "33000000";
        prev_test_str[12] <= "36000000";
        prev_test_str[13] <= "39000000";
        prev_test_str[14] <= "42000000";
        prev_test_str[15] <= "45000000";
        prev_test_str[16] <= "48000000";
        prev_test_str[17] <= "51000000";
        prev_test_str[18] <= "54000000";
        prev_test_str[19] <= "57000000";
        prev_test_str[20] <= "60000000";
        prev_test_str[21] <= "63000000";
        prev_test_str[22] <= "66000000";
        prev_test_str[23] <= "69000000";
        prev_test_str[24] <= "72000000";
        prev_test_str[25] <= "75000000";
        prev_test_str[26] <= "78000000";
        prev_test_str[27] <= "81000000";
        prev_test_str[28] <= "84000000";
        prev_test_str[29] <= "87000000";
        prev_test_str[30] <= "90000000";
        prev_test_str[31] <= "93000000";
        prev_test_str[32] <= "96000000";
    end
    else if(P == S_MD5_COMPARE) begin
        for (idx=0; idx<=32; idx=idx+1) begin
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
 
 
 
always @(posedge clk) begin
  if (~reset_n) P <= S_WAIT_BUTTON;
  else P <= P_next;
end
always @(*) begin
    case (P)
        S_WAIT_BUTTON:
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
        S_MD5_COMPARE:
            if(matched) P_next = S_SHOW_RESULT;
            else P_next = S_MD5_RESET;
        S_SHOW_RESULT:
            if (btn_pressed == 1) P_next = S_WAIT_BUTTON;
            else P_next = S_SHOW_RESULT;
  endcase
end
 
assign usr_led = {(P==S_MD5_RESET), (P==S_MD5_READ_INPUT), (P==S_MD5_CALCULATE), (P==S_MD5_COMPARE)};
 
 
endmodule
 

