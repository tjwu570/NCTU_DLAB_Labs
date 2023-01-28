`timescale 1ns / 1ps
 
module lab4(
   input clk,
   input reset_n,
   input [3:0] usr_btn,
   output [3:0] usr_led
);
  
   wire [3:0] d_btn;
   reg [2:0]  brightness;
   reg [3:0]  number;
  
   Debouncing btn_0(.clk(clk), .btn(usr_btn[0]), .debounced_btn(d_btn[0]));
   Debouncing btn_1(.clk(clk), .btn(usr_btn[1]), .debounced_btn(d_btn[1]));
   Debouncing btn_2(.clk(clk), .btn(usr_btn[2]), .debounced_btn(d_btn[2]));       
   Debouncing btn_3(.clk(clk), .btn(usr_btn[3]), .debounced_btn(d_btn[3]));
 
     always @ (posedge clk) begin
 
         if(~reset_n) begin
             number <= 0;
             brightness <= 0;
         end
 
         else begin
          
           if(d_btn[0] && (number != 4'b1000) ) begin
               number <= number - 1;
           end
 
           if(d_btn[1] && (number != 4'b0111) ) begin
               number <= number + 1;
           end
 
           if (d_btn[2] && (brightness != 3'b000) ) begin
               brightness <= brightness - 1;
           end  
 
           if (d_btn[3] && (brightness != 3'b100)) begin
               brightness <= brightness + 1;
           end
 
        end
   end
 
   PWM led(.clk(clk), .brightness(brightness), .number(number), .led(usr_led));
   // "duty" is used to store current brightness state, while "number" is to store the current number.
 
endmodule
 
module PWM(
   input            clk,
   input [3:0]      brightness,
   input [3:0]      number,
   output reg [3:0] led 
);
 
   reg [20-1:0]  curr = 0;
   reg [20-1:0]  period = 20'd 1_000_000;
 
   always @ (posedge clk) begin
       if (curr >= period)
           curr <= 0;
       else
          curr <= curr + 1;
 
       case(brightness)
           0: led <= number & {4{(curr <= 50000  )}};
           1: led <= number & {4{(curr <= 250000 )}};
           2: led <= number & {4{(curr <= 500000 )}};
           3: led <= number & {4{(curr <= 750000 )}};
           4: led <= number ;
       endcase
   end
 
endmodule
 
 
module Debouncing(
   input clk,
   input btn,
   output reg debounced_btn
   );
 
   reg is_waiting;
   reg [25:0] current_cycle;
 
   always @(posedge clk) begin
       if(~is_waiting)begin
           if(btn)begin
               debounced_btn <= 1;
               is_waiting <= 1;
           end
       end
       else begin
            debounced_btn <= 0; // May be omitted?
           // Presume that the user won't press the button for more than 0.5 sec if only one press is expected.
           // User can long press the button and initiate multiple presses.
           if (current_cycle < 40000000) begin
               current_cycle <= current_cycle + 1;
           end
           else begin
            if (~btn) begin
                is_waiting <= 0;
                current_cycle <= 0;
            end
           end
       end
   end
  
endmodule