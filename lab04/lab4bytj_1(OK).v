`timescale 1ns / 1ps

module lab4(
    input clk,
	input reset_n,
	input [3:0] usr_btn,
	output [3:0] usr_led
);
    
    wire [3:0] pb_d;
	reg [6:0]  brightness[0:4]; 
    reg [2:0]  val;
    reg [3:0]  counter;
   	
	debounce debounce_btn0(.clk(clk), .btn_p(usr_btn[0]), .debounced_dn(pb_d[0]));
	debounce debounce_btn1(.clk(clk), .btn_p(usr_btn[1]), .debounced_dn(pb_d[1]));
	debounce debounce_btn2(.clk(clk), .btn_p(usr_btn[2]), .debounced_dn(pb_d[2]));    	
	debounce debounce_btn3(.clk(clk), .btn_p(usr_btn[3]), .debounced_dn(pb_d[3]));

	  always @ (posedge clk) 
	  begin
	      if(~reset_n) 
	      begin
		      brightness[0] <= 7'd5; 
		      brightness[1] <= 7'd25; 
		      brightness[2] <= 7'd50; 
		      brightness[3] <= 7'd75; 
		      brightness[4] <= 7'd100; 
              counter <= 0;
              val <= 0;
	      end 
		  else begin
            
            //-----------Storing the state of the led brightness------------
            if(pb_d[0]) 
                begin
                    if(counter != 4'b1000)
                        counter <= counter - 1;
                end 
            else if(pb_d[1]) 
                begin
                    if(counter != 4'b0111)
                        counter <= counter + 1;
                end
            //--------------------------------------------------------------

            //-----------Storing the state of the number (4 bit)------------
                if (pb_d[2]) begin
                    if(val != 3'b000)
                        val <= val - 1;
                end	  
                else if (pb_d[3]) begin
                    if(val != 3'b100)
                        val <= val + 1;
                end
            //--------------------------------------------------------------

         end
	end
   
	pwm led(.clk(clk), .duty(brightness[val]), .counter(counter), .led(usr_led));
    // "duty" is used to store current brightness state, while "counter" is to store the current number.

endmodule

module pwm (
    input            clk,
    input [6:0]      duty,
    input [3:0]      counter,
    output reg [3:0] led  
);

    reg [20-1:0]  cnt = 0;
    reg [20-1:0]  ticks = 20'd1000000;

    //-------------------- Generating a PWM cycle ------------------
    always @ (posedge clk) begin
       if (cnt >= ticks)
           cnt <= 0;
       else
           cnt <= cnt + 1;
    end
    //--------------------------------------------------------------

    always @ (posedge clk) begin
       led <= counter & {4{(cnt <= ticks * duty / 100)}};
       // the second "<=" is an equality symbol!
       // dividing 100 is due to the requirements : 5%, 25%, 50%, 75%, 100%
    end  
endmodule


module debounce(
    input clk,
    input btn_p,
    output debounced_dn
    );

    // sync with clock and combat metastability
    reg state;
    reg [3:0] shifter;
    // 2.6 ms counter at 100 MHz
    reg [18:0] counter;

    always @(posedge clk) begin
        shifter = {shifter[2:0], btn_p};
    end

    always @(posedge clk) begin
        if (state == shifter[3])
            counter <= 0;
        else begin
            counter <= counter + 1;
            if (&counter)
                state <= ~state;
        end
    end

    assign debounced_dn = ~(state == shifter[3]) & (&counter) & ~state;
    
endmodule
