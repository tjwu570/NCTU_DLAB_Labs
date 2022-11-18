`timescale 1ns / 1ps
module lab7(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,
  // UART
  input  uart_rx,
  output uart_tx
);


// declare system variables
wire  btn_level, btn_pressed;
reg   prev_btn_level;
reg  [11:0] user_addr;
reg  [7:0]  user_data;

// declare SRAM control signals
wire [10:0] sram_addr;
wire [7:0]  data_in;
wire [7:0]  data_out;
wire        sram_we, sram_en;

debounce btn_db1(
  .clk(clk),
  .btn_input(usr_btn),
  .btn_output(btn_level)
);

// Enable one cycle of btn_pressed per each button hit
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 1'b0;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level & ~prev_btn_level);

// End of the user's button control.
// ------------------------------------------------------------------------
//
localparam START_IDX = 0;
localparam [2:0] S_PRINT_INIT = 0, S_PRINT_press = 1, S_PRINT_READ = 2, S_PRINT_CALCULATION = 3, S_PRINT_PROMPT = 4;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1, S_UART_SEND = 2, S_UART_INCR = 3;
localparam INIT_DELAY = 100_000; // 1 msec @ 100 MHz
localparam REPLY_LEN  = 168; // length of the hello message
localparam MEM_SIZE   = REPLY_LEN; 

reg [2:0] R, R_next; 
reg [1:0] Q, Q_next;

sram ram0(.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out));

assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                             // if you set 'we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_en = (R_next == S_PRINT_READ); // Enable the SRAM block.
assign sram_addr = user_addr[11:0];
assign data_in = 8'b0; // SRAM is read-only so we tie inputs to zeros.

always @(posedge clk) begin
  if (~reset_n) user_data <= 8'b0;
  else if (sram_en && !sram_we) user_data <= data_out;
end

// declare system variables
wire print_enable, print_done;
reg [$clog2(MEM_SIZE):0] send_counter;
reg [$clog2(INIT_DELAY):0] init_counter;
reg [0:REPLY_LEN*8 - 1] answer = { "\015\012The matrix multiplication result is: \015\012[ 00000, 00000, 00000, 00000 ]\015\012[ 00000, 00000, 00000, 00000 ]\015\012[ 00000, 00000, 00000, 00000 ]\015\012[ 00000, 00000, 00000, 00000 ]", 8'h00 };
reg [7:0] data[0:MEM_SIZE-1];
wire reading;
wire calculating;

reg [1:0] c_cnt = 0; 
reg [4:0] r_cnt = 0;
assign calculating = (c_cnt < 3);
reg [7:0]  A [0:15];
reg [7:0]  B [0:15];
reg [17:0] C [0:15];

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;  // if recevied is true, rx_temp latches rx_byte for ONLY ONE CLOCK CYCLE!
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

/* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
uart uart(
  .clk(clk),
  .rst(~reset_n),
  .rx(uart_rx),
  .tx(uart_tx),
  .transmit(transmit),
  .tx_byte(tx_byte),
  .received(received),
  .rx_byte(rx_byte),
  .is_receiving(is_receiving),
  .is_transmitting(is_transmitting),
  .recv_error(recv_error)
);

// Initializes some strings.
// System Verilog has an easier way to initialize an array,
// but we are using Verilog 2001 :(
//

assign reading = (user_addr < 33);    
integer idx, r_idx;

always @(posedge clk) begin
  if (~reset_n) begin
	  user_addr <= 12'h000;
	  for (idx = 0; idx < REPLY_LEN; idx = idx + 1) data[idx] = answer[idx*8+:8];   
  end
  if(R == S_PRINT_INIT) begin
    c_cnt <= 0;
    r_cnt <= 0;
    r_idx = 43;
  end
  else if (R == S_PRINT_READ) begin	
	  if ((user_addr - 2) >= 0 && (user_addr - 2) < 16)
	      A[user_addr - 2] <= user_data; 
	  else if ((user_addr - 2) >= 16) 
	      B[user_addr - 2 - 16] <= user_data;
	 user_addr <= user_addr + 1; 
  end
  else if (R == S_PRINT_CALCULATION) begin
		C[c_cnt * 4 + 0] <=  A[c_cnt + 4 * 0] * B[0] + A[c_cnt + 4 * 1] * B[1] + A[c_cnt + 4 * 2] * B[2] + A[c_cnt + 4 * 3] * B[3];
		C[c_cnt * 4 + 1] <=  A[c_cnt + 4 * 0] * B[4] + A[c_cnt + 4 * 1] * B[5] + A[c_cnt + 4 * 2] * B[6] + A[c_cnt + 4 * 3] * B[7];
		C[c_cnt * 4 + 2] <=  A[c_cnt + 4 * 0] * B[8] + A[c_cnt + 4 * 1] * B[9] + A[c_cnt + 4 * 2] * B[10] + A[c_cnt + 4 * 3] * B[11];
		C[c_cnt * 4 + 3] <=  A[c_cnt + 4 * 0] * B[12] + A[c_cnt + 4 * 1] * B[13] + A[c_cnt + 4 * 2] * B[14] + A[c_cnt + 4 * 3] * B[15];
    // Calculate the answer in row-major order
    // Use four periods to calculate 
		c_cnt <= c_cnt + 1;
  end
  else if (R == S_PRINT_PROMPT) begin

		data[r_idx]     <=  ((C[r_cnt][17:16] > 9)? "7" : "0") + C[r_cnt][17:16];
		data[r_idx+1]   <=  ((C[r_cnt][15:12] > 9)? "7" : "0") + C[r_cnt][15:12];
		data[r_idx+2]   <=  ((C[r_cnt][11:8]  > 9)? "7" : "0") + C[r_cnt][11:8];
		data[r_idx+3]   <=  ((C[r_cnt][7:4]   > 9)? "7" : "0") + C[r_cnt][7:4];
		data[r_idx+4]   <=  ((C[r_cnt][3:0]   > 9)? "7" : "0") + C[r_cnt][3:0];
		
		r_cnt <= r_cnt + 1;
		if(r_cnt % 4 != 3) r_idx <= r_idx + 7;
		else r_idx <= r_idx + 11; //the length between two data in the prompt message, length accross two rows are " ]\015\012[ "
      
  end
end

// ------------------------------------------------------------------------
// Main FSM that reads the UART input and triggers
// the output of the string "Hello, World!".
always @(posedge clk) begin
  if (~reset_n) R <= S_PRINT_INIT;
  else R <= R_next;
end

always @(*) begin // FSM next-state logic
  case (R)
    S_PRINT_INIT: // Wait for initial delay of the circuit.
      if (init_counter < INIT_DELAY) R_next = S_PRINT_INIT;
      else R_next = S_PRINT_press;
    S_PRINT_press:
      if (btn_pressed) R_next = S_PRINT_READ;
      else R_next = S_PRINT_press;
    S_PRINT_READ:
      if (reading) R_next = S_PRINT_READ; // not done
      else R_next = S_PRINT_CALCULATION;   
      // else R_next = S_PRINT_PROMPT;   
    S_PRINT_CALCULATION:
      if (calculating) R_next = S_PRINT_CALCULATION;
      else R_next = S_PRINT_PROMPT;  
    S_PRINT_PROMPT: // Print the prompt message.
      if (print_done) R_next = S_PRINT_INIT;
      else R_next = S_PRINT_PROMPT;
  endcase
end

// FSM output logics: print string control signals.
assign print_enable = (R == S_PRINT_CALCULATION && R_next == S_PRINT_PROMPT);
assign print_done = (tx_byte == 8'h0);

// Initialization counter.
always @(posedge clk) begin
  if (R == S_PRINT_INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the controller that sends a string to the UART.
always @(posedge clk) begin
  if (~reset_n) Q <= S_UART_IDLE;
  else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
  case (Q)
    S_UART_IDLE: // wait for the print_string flag
      if (print_enable) Q_next = S_UART_WAIT;
      else Q_next = S_UART_IDLE;
    S_UART_WAIT: // wait for the transmission of current data byte begins
      if (is_transmitting == 1) Q_next = S_UART_SEND;
      else Q_next = S_UART_WAIT;
    S_UART_SEND: // wait for the transmission of current data byte finishes
      if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
      else Q_next = S_UART_SEND;
    S_UART_INCR:
      if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end

// FSM output logics: UART transmission control signals
assign transmit = (Q_next == S_UART_WAIT || print_enable);
assign tx_byte = data[send_counter];

// UART send_counter control circuit
always @(posedge clk) begin
	case (R_next)
		S_PRINT_INIT: send_counter <= START_IDX;  
		S_PRINT_PROMPT: send_counter <= send_counter + (Q_next == S_UART_INCR);
	endcase
end
// End of the FSM of the print string controller

// ------------------------------------------------------------------------
endmodule