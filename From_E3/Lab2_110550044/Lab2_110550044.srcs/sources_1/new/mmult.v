`timescale 1ns / 1ps

module mmult(
    input clk,
    input reset_n,
    input enable,
    input [0:9*8-1] A_mat, 
    input [0:9*8-1] B_mat,
    output valid,
    output reg [0:9*17-1] C_mat
    );
    //reg [0:9*17-1]C;
    reg [1:0] c; //counter for how many cycles done, total should be 3
    reg [2:0] j; //counter for the for loop

    always @(reset_n) begin // Triggered when the signal "reset_n" is changed
        if(!reset_n) begin
            C_mat <= 0;
            c <= 0;
        end
    end



    assign valid = (c == 3);
    //Output would not be valid if the calculation is not done or not enabled

    always @(posedge clk) begin
        if(enable) begin
            if(c<3) begin
                for(j=0; j<3; j=j+1) begin
                    C_mat[ (c*3+j)*17 +: 17] <= 
                    A_mat[ (c*3  )*8 +: 8] * B_mat[ (j  )*8 +: 8] + 
                    A_mat[ (c*3+1)*8 +: 8] * B_mat[ (j+3)*8 +: 8] + 
                    A_mat[ (c*3+2)*8 +: 8] * B_mat[ (j+6)*8 +: 8];
                end
                c <= c+1;
            end
        end
        else begin
            c <= 0;
        end
    end
endmodule
