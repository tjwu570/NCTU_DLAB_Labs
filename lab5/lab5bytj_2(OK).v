`timescale 1ns / 1ps
module lab5(
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
 
    wire btn_level, btn_pressed;
    reg prev_btn_level;
    reg rev = 0;
    reg launched = 0;                       // Whether entered into the demo, or stuck in the welcome message
    reg [127:0] row_A = "Press BTN3 to   "; // Initialize the text of the first row.
    reg [127:0] row_B = "show a message.."; // Initialize the text of the second row.
 
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

    debounce btn_db0(
        .clk(clk),
        .btn_input(usr_btn[3]),
        .btn_output(btn_level)
    );
 
 
 
    always @(posedge clk) begin
        if (~reset_n)
            prev_btn_level <= 1;
        else
            prev_btn_level <= btn_level;
    end
 
    assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);
 
    // Upon are given in the sample code
 
    reg [4:0] show_1 = 5'd0;           // The # of Fibonacci number to show on the upper LCD
    reg [4:0] show_2 = 5'd1;           // The # of Fibonacci number to show on the lower LCD
    reg [16-1:0] Fibo [24:0];          // The array to store Fibonacci numbers
    reg [30-1:0] cycle = 30'd0;        // Duration of refreshing the LCD
    reg [4:0] idx = 5'd0;              // Index for the for loop
    reg [32-1:0] Fibon_hex [24:0];     // The array to store Fibonacci numbers in hexadecimal type corresponding to the ASCII table
    reg [16-1:0] idx_hex [24:0];       // The index number # in hexadecimal type corresponding to the ASCII table
 
    always @(posedge clk) begin
        if (~reset_n) begin
            // Initialize the text when the user hit the reset button
            row_A = "Press BTN3 to   ";
            row_B = "show a message..";
            show_1 <= 0;
            show_2 <= 1;
            cycle <= 0;
            rev <= 0;
            launched <= 0;
 
            for(idx = 0; idx < 25; idx = idx + 1 ) begin
                
                if(idx == 0) Fibo[idx] <= 0;
                else if(idx == 1) Fibo[idx] <= 1;
                else Fibo[idx] <= Fibo[idx -1] + Fibo[idx - 2];
//------------------------------------------------------------------------------------------------------------------------------
 
                if(Fibo[idx][3:0] > 4'd9) 
                    Fibon_hex [idx][7:0] <= {4'd0,Fibo[idx][3:0]} + 6'd55;
                else
                    Fibon_hex [idx][7:0] <= {4'd0,Fibo[idx][3:0]} + 6'd48;

 //------------------------------------------------------------------------------------------------------------------------------
 
                if(Fibo[idx][7:4] > 4'd9) 
                    Fibon_hex [idx][15:8] = {4'd0,Fibo[idx][7:4]} + 6'd55;
                else
                    Fibon_hex [idx][15:8] = {4'd0,Fibo[idx][7:4]} + 6'd48;

 //------------------------------------------------------------------------------------------------------------------------------
 
                if(Fibo[idx][11:8] > 4'd9) 
                    Fibon_hex [idx][23:16] = {4'd0,Fibo[idx][11:8]} + 6'd55;
                else
                    Fibon_hex [idx][23:16] = {4'd0,Fibo[idx][11:8]} + 6'd48;

 //------------------------------------------------------------------------------------------------------------------------------
 
                if(Fibo[idx][15:12] > 4'd9) 
                    Fibon_hex [idx][31:24] = {4'd0,Fibo[idx][15:12]} + 6'd55;
                else
                    Fibon_hex [idx][31:24] = {4'd0,Fibo[idx][15:12]} + 6'd48;

 //------------------------------------------------------------------------------------------------------------------------------
 
                if ((idx + 1) % 16 > 9)
                    idx_hex[idx][7:0] = (idx + 1) % 16 + 8'd55;
                else
                    idx_hex[idx][7:0] = (idx + 1) % 16 + 8'd48;
 
                if (idx > 14)
                    idx_hex[idx][15:8] =  8'd49;
                else
                    idx_hex[idx][15:8] =  8'd48;
                    
//------------------------------------------------------------------------------------------------------------------------------
 
            end
        end
 
        else if (launched) begin
            if(cycle > 70000000) begin
                row_A <= {"Fibo #", idx_hex[show_1], " is ", Fibon_hex[show_1]};
                row_B <= {"Fibo #", idx_hex[show_2], " is ", Fibon_hex[show_2]};
                
                if(!rev) begin
                    if(show_1 == 24) show_1 <= 0;
                    else show_1 <= show_1 + 1;

                    if(show_2 == 24) show_2 <= 0;
                    else show_2 <= show_2 + 1;
                end  
                else begin
                    if(show_1 == 0) show_1 <= 24;
                    else show_1 <= show_1 - 1;

                    if(show_2 == 0) show_2 <= 24;
                    else show_2 <= show_2 - 1;
                end
                cycle <= 0;
            end
            else begin
                cycle <= cycle + 1;
            end
        end

        if(btn_pressed) begin
            if (launched) rev <= ~rev;
            else launched <= 1;
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
 
 
 

