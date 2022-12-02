module md5(
    input  clk,
    input  [63:0]  att,
    output [127:0] hash,
    output reg [63:0] current_att 
);

reg initialized = 0;
wire done;
assign done = (i==63) ? 1 : 0;
reg state = 0;

localparam h0 = 32'h67452301;
localparam h1 = 32'hefcdab89;
localparam h2 = 32'h98badcfe;
localparam h3 = 32'h10325476;
reg [31 : 0] a = 32'h67452301;
reg [31 : 0] b = 32'hefcdab89;
reg [31 : 0] c = 32'h98badcfe;
reg [31 : 0] d = 32'h10325476;

reg [31 : 0] k [0 : 7] = {
32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 
32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501, 
32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 
32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821, 
32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 
32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8, 
32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 
32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a, 
32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 
32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70, 
32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 
32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665, 
32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 
32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1, 
32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 
32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};

reg [511:0] w = {
    32'hd76aa478, 32'hd76aa478, 
    32'h80000000, 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'd64      };

 reg [4:0] r [0:7] = 
 {  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};
 reg [31 : 0] f;
 reg [ 7 : 0] g;
 reg [ 7 : 0] i;

 localparam [2:0] S_INIT = 0, S_LOOP_2 = 1, S_LOOP_2 = 2, S_ADD = 3, S_DONE = 4;
reg [2:0] S, S_next;
always @(*) begin
 case (S)
    S_INIT:
        if (initialized) S_next = S_LOOP;
        else S_INIT;
    S_INC:
        S_next <= S_LOOP_1;
    S_LOOP_1:
        S_next = S_LOOP_2;
    S_LOOP_2:
        if (i<63) S_next = S_INC;
        else S_next = S_ADD;
    S_ADD:
        S_next = S_DONE;
    S_DONE:
        S_next = S_INIT;
 endcase
end

 always @(posedge clk) begin

    case (S)
    S_INIT:
        w[511:448] <= att[63:0];
        state <= 0;
        initialized <= 1;

    S_INC:
        if (w[448 +: 4] == 4'h9) begin w[448 +: 4] <= 4'h0;
        if (w[456 +: 4] == 4'h9) begin w[456 +: 4] <= 4'h0;
        if (w[464 +: 4] == 4'h9) begin w[464 +: 4] <= 4'h0;
        if (w[472 +: 4] == 4'h9) begin w[472 +: 4] <= 4'h0;
        if (w[480 +: 4] == 4'h9) begin w[480 +: 4] <= 4'h0;
        if (w[488 +: 4] == 4'h9) begin w[488 +: 4] <= 4'h0;
        if (w[496 +: 4] == 4'h9) begin w[496 +: 4] <= 4'h0;
        if (w[504 +: 4] == 4'h9) begin w[504 +: 4] <= 4'h0;
        end else w[504 +: 4] <= w[504 +: 4] + 1;
        end else w[496 +: 4] <= w[496 +: 4] + 1;
        end else w[488 +: 4] <= w[488 +: 4] + 1;
        end else w[480 +: 4] <= w[480 +: 4] + 1;
        end else w[472 +: 4] <= w[472 +: 4] + 1;
        end else w[464 +: 4] <= w[464 +: 4] + 1;
        end else w[456 +: 4] <= w[456 +: 4] + 1;
        end else w[448 +: 4] <= w[448 +: 4] + 1;

        a <= 32'h67452301;
        b <= 32'hefcdab89;
        c <= 32'h98badcfe;
        d <= 32'h10325476;

    S_LOOP_1:
        if (i < 16) begin
            f <= (b & c) | ((~b) & d);
            g <= i;
        end
        else if (i < 32) begin
            f <= (d & b) | ((~d) & c);
            g <= (5 * i + 1) % 16;
        end
        else if (i < 48) begin
            f <= b ^ c ^ d;
            g <= (3 * i + 5) % 16;
        end
        else begin
            f <= c ^ (b | (~d));
            g <= (7 * i) % 16;
        end

    S_LOOP_2:
        d <= c;
        c <= b;
        b <= b + (((a + f + k[i] + w[g]) << r[i]) | ((a + f + k[i] + w[g]) >> (32 - r[i])))
        a <= d;
        i <= i + 1;

    S_ADD:

        a <= a + h0;
        b <= b + h1;
        c <= c + h2;
        d <= d + h3;

    S_DONE:
        hash <= {a,b,c,d};
        current_att <= {att[63:0]};
        i <= 0;
        initialized <= 0;
    endcase
    
 end

 endmodule