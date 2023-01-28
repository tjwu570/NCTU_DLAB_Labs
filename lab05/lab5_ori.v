`timescale 1ns / 1ps
/////////////////////////////////////////////////////////
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
reg prev_btn_level, rev, run;
reg [127:0] row_A = "Press BTN3 to   "; // Initialize the text of the first row. 
reg [127:0] row_B = "show a message.."; // Initialize the text of the second row.
reg [4:0] val = 5'd0, val2 = 5'd0;
reg [16-1:0] Fibo [24:0];
reg [30-1:0] cnt = 30'd0;
reg [4:0] idx = 5'd0;
reg [32-1:0] prt [24:0];
reg [16-1:0] prtidx [24:0];

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
  .clock(clk),
  .btn_p(usr_btn[3]),
  .debounced_dn(btn_level)
);
    
always @(posedge clk) begin
  if (~reset_n)
  begin
    prev_btn_level <= 1;
  end
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);

always @(posedge clk) begin
  if (~reset_n) begin
    // Initialize the text when the user hit the reset button
    row_A = "Press BTN3 to   ";
    row_B = "show a message..";
    val <= 0;
    val2 <= 1;
    cnt <= 0;
    rev <= 1;
    run <= 0;
    for(idx = 0; idx < 25; idx = idx + 1 ) begin
        if(idx == 0) Fibo[idx] <= 0;
        else if(idx == 1) Fibo[idx] <= 1;
        else Fibo[idx] <= Fibo[idx -1] + Fibo[idx - 2];
        prt [idx][7:0] = Fibo[idx][3:0] + 6'd48;
        if(Fibo[idx][3:0] > 4'd9) begin
            prt [idx][7:0] = prt [idx][7:0] + 4'd7;
        end
        prt [idx][15:8] = Fibo[idx][7:4] + 6'd48;
        if(Fibo[idx][7:4] > 4'd9) begin
            prt [idx][15:8] = prt [idx][15:8] + 4'd7;
        end
        prt [idx][23:16] = Fibo[idx][11:8] + 6'd48;
        if(Fibo[idx][11:8] > 4'd9) begin
            prt [idx][23:16] = prt [idx][23:16] + 4'd7;
        end
        prt [idx][31:24] = Fibo[idx][15:12] + 6'd48;
        if(Fibo[idx][15:12] > 4'd9) begin
            prt [idx][31:24] = prt [idx][31:24] + 4'd7;
        end
        prtidx[idx][7:0] = (idx  + 1) % 10 + 8'd48;
        prtidx[idx][15:8] = (idx + 1) / 10 + 8'd48;
    end
  end else if (run) begin
    if(cnt > 70000000) begin 
      row_A <= {"Fibo #", prtidx[val], " is ", prt[val]};
      row_B <= {"Fibo #", prtidx[val2], " is ", prt[val2]};
      if(!rev) begin
      val <= val + 1;
      val2 <= val2 + 1; 
      if(val == 24) val <= 0;
      if(val2 == 24) val2 <= 0;
      end  else begin
      val <= val - 1;
      val2 <= val2 - 1;
      if(val == 0) val <= 24;
      if(val2 == 0) val2 <= 24;
      end
      cnt <= 0;
      end  else  begin
        cnt <= cnt + 1;
      end
  end
  if(btn_pressed) begin
    run <= 1;
    rev <= ~rev;
  end
  end

endmodule

module debounce(
    input clock,
    input btn_p,
    output debounced_dn
    );

    // sync with clock and combat metastability
    reg state;
    reg [3:0] shifter;
    always @(posedge clock) 
    begin
        shifter = {shifter[2:0], btn_p};
    end

    // 2.6 ms counter at 100 MHz
    reg [18:0] counter;

    always @(posedge clock)
    begin
        if (state == shifter[3])
            counter <= 0;
        else
        begin
            counter <= counter + 1;
            if (&counter)
                state <= ~state;
        end
    end

    assign debounced_dn = ~(state == shifter[3]) & (&counter) & ~state;
    
endmodule