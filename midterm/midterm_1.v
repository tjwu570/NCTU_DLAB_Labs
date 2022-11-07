// A file that can show ABC...on row_A and row_B, 
// while after pressing any buttons, they start shifting 
// one position every 1 second, where row_A goes left, row_B goes right.
// Pressing any buttons again can stop the shifting, then again to start
// shifting, and so on.


`timescale 1ns / 1ps

module midterm(
    input clk,
    input reset_n,
    input [3:0] usr_btn,
    output [3:0] usr_led,
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
);
 
    // turn off all the LEDs
    assign usr_led = 4'b0000;
 
    // Setting up the four buttons
    wire btn_level_0, btn_pressed_0;
    reg prev_btn_level_0;    
    wire btn_level_1, btn_pressed_1;
    reg prev_btn_level_1;
    wire btn_level_2, btn_pressed_2;
    reg prev_btn_level_2;    
    wire btn_level_3, btn_pressed_3;
    reg prev_btn_level_3;

    always @(posedge clk) begin
        if (~reset_n) begin
            prev_btn_level_0 <= 1;
            prev_btn_level_1 <= 1;
            prev_btn_level_2 <= 1;
            prev_btn_level_3 <= 1;
        end
        else begin
            prev_btn_level_0 <= btn_level_0;
            prev_btn_level_1 <= btn_level_1;
            prev_btn_level_2 <= btn_level_2;
            prev_btn_level_3 <= btn_level_3;
        end
    end
 
    debounce btn_db0(
        .clk(clk),
        .btn_input(usr_btn[0]),
        .btn_output(btn_level_0)
    );
    debounce btn_db1(
        .clk(clk),
        .btn_input(usr_btn[1]),
        .btn_output(btn_level_1)
    );
    debounce btn_db2(
        .clk(clk),
        .btn_input(usr_btn[2]),
        .btn_output(btn_level_2)
    );
    debounce btn_db3(
        .clk(clk),
        .btn_input(usr_btn[3]),
        .btn_output(btn_level_3)
    );

    assign btn_pressed_0 = (btn_level_0 == 1 && prev_btn_level_0 == 0);
    assign btn_pressed_1 = (btn_level_1 == 1 && prev_btn_level_1 == 0);
    assign btn_pressed_2 = (btn_level_2 == 1 && prev_btn_level_2 == 0);
    assign btn_pressed_3 = (btn_level_3 == 1 && prev_btn_level_3 == 0);
    // End setting up the four buttons



    reg [26:0] counter = 0;
    reg launched = 0;  // Whether entered into the demo, or stuck in the welcome message
    reg [4:0]idx = 0;
    //reg [127:0] alphabet = "ABCDEFGHIJKLMNOP";
    //reg [4:0] current_alphabet;
    
    reg [127:0] row_A = "ABCDEFGHIJKLMNOP";
    reg [127:0] row_B = "QRSTUVWXYZABCDEF";
     
     
    //-----------------------------------
    //shifting module
    //-----------------------------------


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
 
    // Upon are given in the sample code
 

    always @(posedge clk) begin
        if (~reset_n) begin
            launched <= 0;
            row_A <= "ABCDEFGHIJKLMNOP";
            row_B <= "QRSTUVWXYZABCDEF";
        end
 
        else if (launched) begin

            if (btn_pressed_0) launched <= 0;
            if (btn_pressed_1) launched <= 0;
            if (btn_pressed_2) launched <= 0;
            if (btn_pressed_3) launched <= 0;

            if (counter < 100000000) begin
                counter <= counter + 1;
            end
            else begin
                counter<=0;
                for(idx = 0; idx<16; idx = idx+1 ) begin 
                    if (row_A[idx*8 +: 8] >= "Z") row_A[idx*8 +: 8] <= "A"; 
                    else row_A[idx*8 +: 8] <= row_A[idx*8 +: 8] + 1;
                end

                for(idx = 0; idx<16; idx = idx+1 ) begin 
                    if (row_B[idx*8 +: 8] <= "A") row_B[idx*8 +: 8] <= "Z"; 
                    else row_B[idx*8 +: 8] <= row_B[idx*8 +: 8] - 1;
                end
            end
        end
        else if(~launched) begin
            if (btn_pressed_0) launched <= 1;
            if (btn_pressed_1) launched <= 1;
            if (btn_pressed_2) launched <= 1;
            if (btn_pressed_3) launched <= 1;
        end
    end
 
endmodule
 
module debounce(
    input clk,
    input btn_input,
    output reg btn_output
);
    reg is_waiting;
    reg [25:0] current_cycle;
    always @(posedge clk) begin
        if(~is_waiting)begin
            if(btn_input)begin
                btn_output <= 1;
                is_waiting <= 1;
            end
        end
        else begin
            btn_output <= 0;
            if (current_cycle < 40000000) begin
                current_cycle <= current_cycle + 1;
            end
            else begin
                if (~btn_input) begin
                    is_waiting <= 0;
                    current_cycle <= 0;
                end
            end
        end
    end
endmodule
 
 
 

