`timescale 1ns / 1ps

module SeqMultiplier_tb();

// CLK 100MHz
reg clk = 1;
always #5 clk = ~clk;

// I/O & Signal
reg enable = 1'b0;
reg  [ 8-1: 0] A = 8'b0;
reg  [ 8-1: 0] B = 8'b0;
wire [16-1: 0] C;

SeqMultiplier testUnit(
    .clk(clk),
    .enable(enable),
    .A(A),
    .B(B),
    .C(C)
);

initial begin
    $dumpfile("testbench.vcd");
    $dumpvars;
    #20
    A = 8'd239;
    B = 8'd163;
    #40
    enable = 1'b1;
end

endmodule
