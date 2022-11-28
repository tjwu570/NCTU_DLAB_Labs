`timescale 1ns / 1ps

module lab8(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // SD card specific I/O ports
  output spi_ss,
  output spi_sck,
  output spi_mosi,
  input  spi_miso,

  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

localparam [2:0] S_MAIN_INIT = 3'b000, S_MAIN_IDLE = 3'b001,
                 S_MAIN_WAIT = 3'b010, S_MAIN_READ = 3'b011,
                 S_MAIN_DONE = 3'b100, S_MAIN_SHOW = 3'b101;
                 
localparam [3:0] 
  S_MAIN_O = 4'b0000,
  S_MAIN_D = 4'b0001, S_MAIN_L = 4'b0010,
  S_MAIN_A = 4'b0011, S_MAIN_B = 4'b0100,
  S_MAIN_under = 4'b0101, S_MAIN_T_E = 4'b0110,
  S_MAIN_A_N = 4'b0111, S_MAIN_G_D = 4'b1000;

// Declare system variables
wire btn_level, btn_pressed;
reg  prev_btn_level;
reg  [2:0] P, P_next;
reg  [2:0] Q, Q_next;
reg  [9:0] sd_counter;
reg  [31:0] blk_addr;
reg  rd, rd_done;
reg  [31:0] cnt;
reg  [2:0] l_cnt;
reg  [7:0] msg; 

reg  [127:0] row_A = "SD card cannot  ";
reg  [127:0] row_B = "be initialized! ";

// Declare SD card interface signals
wire clk_sel;
wire clk_500k;
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finished;
wire [7:0] sd_dout;
wire sd_valid;

assign clk_sel = (init_finished)? clk : clk_500k; // clock for the SD controller
assign usr_led = 4'h00;

clk_divider#(200) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(clk_500k)
);

debounce btn_db0(
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
  .LCD_D(LCD_D)
);

sd_card sd_card0(
  .cs(spi_ss),
  .sclk(spi_sck),
  .mosi(spi_mosi),
  .miso(spi_miso),

  .clk(clk_sel),
  .rst(~reset_n),
  .rd_req(rd_req),
  .block_addr(rd_addr),
  .init_finished(init_finished),
  .dout(sd_dout),
  .sd_valid(sd_valid)
);

//
// Enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 0;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

// ------------------------------------------------------------------------
always @(posedge clk) begin
  if(~reset_n) begin
    rd <= 0;
    rd_done <= 0;
    cnt <= 0;
    l_cnt <= 0;
  end
  else if (P == S_MAIN_READ && sd_valid) begin   
    msg = sd_dout;
    
    if(rd == 0) begin
        case(Q)
         S_MAIN_O: begin
           if(msg == "D") Q_next = S_MAIN_D;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_D: begin
           if(msg == "L") Q_next = S_MAIN_L;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_L: begin
           if(msg == "A") Q_next = S_MAIN_A;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_A: begin
           if(msg == "B") Q_next = S_MAIN_B;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_B: begin
           if(msg == "_") Q_next = S_MAIN_under;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_under: begin
           if(msg == "T") Q_next = S_MAIN_T_E;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_T_E: begin
           if(msg == "A") Q_next = S_MAIN_A_N;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_A_N: begin
           if(msg == "G") begin
              cnt <= 0;
              rd <= 1;
              l_cnt <= 0;
           end
           else Q_next = S_MAIN_O;
         end
         default:
          Q_next = S_MAIN_O;
        endcase
    end
    else begin
      case(Q)
         S_MAIN_O: begin
           if(msg == "D") Q_next = S_MAIN_D;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_D: begin
           if(msg == "L") Q_next = S_MAIN_L;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_L: begin
           if(msg == "A") Q_next = S_MAIN_A;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_A: begin
           if(msg == "B") Q_next = S_MAIN_B;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_B: begin
           if(msg == "_") Q_next = S_MAIN_under;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_under: begin
           if(msg == "E") Q_next = S_MAIN_T_E;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_T_E: begin
           if(msg == "N") Q_next = S_MAIN_A_N;
           else Q_next = S_MAIN_O;
         end
         S_MAIN_A_N: begin
           if(msg == "D") begin
              rd_done = 1;
              rd <= 0;
              l_cnt <= 0;
           end
           else Q_next = S_MAIN_O;
         end
         default:
          Q_next = S_MAIN_O;
        endcase
      if((msg >= 65 && msg <= 90) || (msg >= 97 && msg <= 122)) begin // a letter read, upper or lower
        if(l_cnt < 4) l_cnt <= l_cnt + 1; // current word length count
      end
      else if((msg < 65 || (msg > 90 && msg < 97) || msg > 122)) begin // a non-letter character read
        if(l_cnt == 3) cnt <= cnt + 1;
        l_cnt <= 0;
      end
    end
  end
end
// ------------------------------------------------------------------------
always @(posedge clk) begin
  if (~reset_n) begin
    P <= S_MAIN_INIT;
  end
  else begin
    P <= P_next;
  end
end

always @(posedge clk) begin
  if (~reset_n) begin
    Q <= S_MAIN_O;
  end
  else begin
    Q <= Q_next;
  end
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // wait for SD card initialization
      if (init_finished == 1) P_next = S_MAIN_IDLE;
      else P_next = S_MAIN_INIT;
    S_MAIN_IDLE: // wait for button click
      if (btn_pressed == 1) P_next = S_MAIN_WAIT;
      else P_next = S_MAIN_IDLE;
    S_MAIN_WAIT: // issue a rd_req to the SD controller until it's ready
      P_next = S_MAIN_READ;
    S_MAIN_READ: // wait for the input data to enter the SRAM buffer
      if (rd_done) P_next = S_MAIN_SHOW;
      else P_next = S_MAIN_READ;
    S_MAIN_SHOW:
      if(btn_pressed == 1) P_next = S_MAIN_IDLE;
      else P_next = S_MAIN_SHOW;
  endcase
end

// FSM output logic: controls the 'rd_req' and 'rd_addr' signals.
always @(*) begin
  rd_req = (P == S_MAIN_WAIT || sd_counter == 512);
  rd_addr = blk_addr;
end

always @(posedge clk) begin
  if (~reset_n) blk_addr <= 32'h2000;
  else if (sd_counter == 512) begin 
    blk_addr <= blk_addr + 1; // In lab 6, change this line to scan all blocks
  end
  else blk_addr <= blk_addr;
end

// FSM output logic: controls the 'sd_counter' signal.
// SD card read address incrementer
always @(posedge clk) begin
  if (~reset_n || (P == S_MAIN_READ && P_next == S_MAIN_SHOW) || sd_counter == 512)
    sd_counter <= 0;
  else if ((P == S_MAIN_READ && sd_valid))
    sd_counter <= sd_counter + 1;
end

// End of the FSM of the SD card reader
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// LCD Display function.
always @(posedge clk) begin
  if (~reset_n) begin
    row_A = "SD card cannot  ";
    row_B = "be initialized! ";
  end else if (P == S_MAIN_SHOW) begin
    row_A <= { "Found ",
               ((cnt[15:12] > 9)? "7" : "0") + cnt[15:12],
               ((cnt[11:8] > 9)? "7" : "0") + cnt[11:8],
               ((cnt[7:4] > 9)? "7" : "0") + cnt[7:4],
               ((cnt[3:0] > 9)? "7" : "0") + cnt[3:0], 
               " words"};
    row_B <= "in the text file";
  end
  else if (P == S_MAIN_IDLE) begin
    row_A <= "Hit BTN2 to read";
    row_B <= "the SD card ... ";
  end
end
// End of the LCD display function
// ------------------------------------------------------------------------

endmodule
