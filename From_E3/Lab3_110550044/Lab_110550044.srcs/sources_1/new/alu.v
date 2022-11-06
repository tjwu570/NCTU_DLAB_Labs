`timescale 1ns / 1ps

module alu (
    output reg [7:0] alu_out, 
    output wire zero, 
    input[2:0] opcode, 
    input signed [7:0] accum, 
    input signed [7:0] data, 
    input reset,
    input clk); 
    reg [7:0] temp;
    assign zero = !(|(0^accum));
 
    always @ (posedge clk) begin
        if(!reset) begin
            if(opcode == 3'bxxx) 
                alu_out = 0; 
            else begin
                case(opcode)
                    0: alu_out <= accum; 
                    1: alu_out <= accum + data;
                    2: alu_out <= accum - data;
                    3: alu_out <= accum & data;
                    4: alu_out <= accum ^ data;
                    5: alu_out <= accum[7] ? ~accum+1 : accum;
                    6: alu_out <= (accum[3]^data[3]) ? 
                                    ((accum[3]) ? 
                                        -((-accum[2:0]&8'h07)*data[2:0]): 
                                        -((-data[2:0]&8'h07)*accum[2:0])):
                                    (accum[2:0]*data[2:0]);
                    7: alu_out <= data;
                endcase
            end
        end
        else begin
            alu_out <= 0;
        end
    end
endmodule
