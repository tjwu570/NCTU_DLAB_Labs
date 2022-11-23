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
.btn_input(usr_btn[1]),
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
localparam [3:0] R_INIT = 0, R_PRESS = 1, R_READ = 2, R_CALCULATE = 3, R_PROMPT_NUM = 4, R_PROMPT_1 = 5, R_PROMPT_2 = 6, R_PROMPT_3 = 7, R_PROMPT_4 = 8;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1, S_UART_SEND = 2, S_UART_INCR = 3;
localparam INIT_DELAY = 100_000; // 1 msec @ 100 MHz
localparam REPLY_LEN  = 300; // length of the hello message
localparam MEM_SIZE   = REPLY_LEN;
reg [2:0] R, R_next;
reg [1:0] Q, Q_next;
sram ram0(.clk(clk), .we(sram_we), .en(sram_en),
        .addr(sram_addr), .data_i(data_in), .data_o(data_out));
assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                           // if you set 'we' to 0, Vivado fails to synthesize
                           // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_en = (R_next == R_READ); // Enable the SRAM block.
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
 
reg [0:295] prompt_1 = {"The matrix multiplication result is: ",8'h00};
 
reg [7:0] data[0:37];
reg [2:0] reading_counter;
reg [1:0] mult_num;
reg phase; // 0 for add, 1 for mul
wire reading;
wire calculating;
reg [1:0] column;
reg [1:0] row;
reg [7:0]  A;
reg [7:0]  B;
reg [17:0] C;
reg reading_A_or_B;
reg [17:0] temp_mult;
 
 
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
assign reading = (user_addr < 33);  
integer idx;
always @(posedge clk) begin
 
  if (~reset_n) begin
    user_addr <= 12'h000;
  end
 
  if(R == R_INIT) begin
    phase <= 0;
    reading_A_or_B <= 0;
  end
 
  if (R == R_READ) begin
    if (reading_A_or_B) //B
    user_addr <= column*4 + mult_num;  
    else // A
    user_addr <= row + mult_num*4;
    C <= 0;
    if (reading_A_or_B==0 && reading_counter==2) begin
      reading_counter <= 0;
      A <= user_data;
      reading_A_or_B <= 1;
    end
    else if (reading_A_or_B==1 && reading_counter==2) begin
      reading_counter <= 0;
      B <= user_data;
      reading_A_or_B <= 0;
    end
    else reading_counter <= reading_counter + 1;
  end
 
  if (R == R_CALCULATE) begin
    reading_counter <= 0;
    mult_num <= mult_num +1;
    if (phase) begin
      temp_mult <= A*B;
      phase <= 0;
    end
    else begin
      C <= C + temp_mult;
      phase <= 1;
    end
    if (row==3) begin
      row<=0;
      column <= column +1;
    end
  end
 
  if (R == R_PROMPT_NUM) begin
    data[0]   <=  ((C[17:16] > 9)? "7" : "0") + C[17:16];
    data[1]   <=  ((C[15:12] > 9)? "7" : "0") + C[15:12];
    data[2]   <=  ((C[11:8]  > 9)? "7" : "0") + C[11:8];
    data[3]   <=  ((C[7:4]   > 9)? "7" : "0") + C[7:4];
    data[4]   <=  ((C[3:0]   > 9)? "7" : "0") + C[3:0];
    data[5]   <=  8'h00;
  end
 
  if (R == R_PROMPT_1) begin
    for(idx=0; idx<37; idx= idx+1) begin
      data[idx] <= prompt_1[idx*8 +: 8];
    end
  end
 
  if (R == R_PROMPT_2) begin
    data[0]   <=  {"\015"};
    data[1]   <=  {"\012"};
    data[2]   <=  {"["};
    data[3]   <=  {" "};
    data[4]   <=  8'h00;
    mult_num  <=  0;
  end
 
  if (R == R_PROMPT_3) begin
    data[0]   <=  {","};
    data[1]   <=  {" "};
    data[2]   <=  8'h00;
    mult_num  <=  0;
  end
 
  if (R == R_PROMPT_4) begin
    data[0]   <=  {" "};
    data[1]   <=  {"]"};
    data[2]   <=  8'h00;
  end
 
end
 
// ------------------------------------------------------------------------
// Main FSM that reads the UART input and triggers
// the output of the string "Hello, World!".
always @(posedge clk) begin
if (~reset_n) R <= R_INIT;
else R <= R_next;
end
always @(*) begin // FSM next-state logic
case (R)
  R_INIT: // Wait for initial delay of the circuit.
    if (init_counter < INIT_DELAY) R_next = R_INIT;
    else R_next = R_PRESS;
 
  R_PRESS:
    if (btn_pressed) R_next = R_PROMPT_1;
    else R_next = R_PRESS;
 
  R_READ:
    if (reading) R_next = R_READ;
    else  R_next = R_CALCULATE;
  R_CALCULATE:
    if (calculating) R_next = R_CALCULATE;
    else if (mult_num < 3) R_next = R_READ;
    else R_next = R_PROMPT_NUM;
 
  R_PROMPT_1:
    if(print_done) R_next = R_PROMPT_2;
    else R_next = R_PROMPT_1;
 
  R_PROMPT_2:
    if(print_done) begin R_next = R_READ; end
    else R_next = R_PROMPT_2;
 
  R_PROMPT_3:
    if (print_done) begin R_next = R_READ; end
    else R_next = R_PROMPT_3;
 
  R_PROMPT_4:
    if (!print_done) R_next = R_PROMPT_3;
    else if (column==3 && row==3) R_next = R_INIT;
    else R_next = R_PROMPT_2;
 
  R_PROMPT_NUM: // Print the prompt message.
    if (!print_done) R_next = R_PROMPT_NUM;
    else if (column==3) R_next = R_PROMPT_4;
    else R_next = R_PROMPT_3;
 
endcase
end
// FSM output logics: print string control signals.
assign print_enable = ((((R != R_PROMPT_1 && R_next == R_PROMPT_1) || (R != R_PROMPT_2 && R_next == R_PROMPT_2)) ||  ((R != R_PROMPT_3 && R_next == R_PROMPT_3) || (R != R_PROMPT_4 && R_next == R_PROMPT_4))) || (R != R_PROMPT_NUM && R_next == R_PROMPT_NUM));
assign print_done = (tx_byte == 8'h0);
assign calculating = (mult_num == 3);
// Initialization counter.
always @(posedge clk) begin
if (R == R_INIT) init_counter <= init_counter + 1;
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
  if (print_enable) send_counter <= START_IDX;
case (R_next)
  R_INIT: send_counter <= START_IDX;
  R_PROMPT_1: send_counter <= send_counter + (Q_next == S_UART_INCR);
  R_PROMPT_2: send_counter <= send_counter + (Q_next == S_UART_INCR);
  R_PROMPT_3: send_counter <= send_counter + (Q_next == S_UART_INCR);
  R_PROMPT_4: send_counter <= send_counter + (Q_next == S_UART_INCR);
  R_PROMPT_NUM: send_counter <= send_counter + (Q_next == S_UART_INCR);
endcase
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------
endmodule
 
 
 
 
 

