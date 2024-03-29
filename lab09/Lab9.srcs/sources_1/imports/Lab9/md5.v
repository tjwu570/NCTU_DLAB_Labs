module md5(
    input  clk,
    input  [63:0]  att,
    output reg [127:0] hash,
    output reg [63:0] current_att 
);

reg initialized = 0;
wire done;
reg state = 0;

localparam h0 = 32'h67452301;
localparam h1 = 32'hefcdab89;
localparam h2 = 32'h98badcfe;
localparam h3 = 32'h10325476;
reg [31 : 0] a = 32'h67452301;
reg [31 : 0] b = 32'hefcdab89;
reg [31 : 0] c = 32'h98badcfe;
reg [31 : 0] d = 32'h10325476;

// reg [31 : 0] k = {
// 0     32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 
// 4     32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501, 
// 8     32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 
// 12    32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821, 
// 16    32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 
// 20    32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8, 
// 24    32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 
// 28    32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a, 
// 32    32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 
// 36    32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70, 
// 40    32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 
// 44    32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665, 
// 48    32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 
// 52    32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1, 
// 56    32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 
// 60    32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};

reg [511:0] w = {
    32'hd76aa478, 32'hd76aa478, 
    32'h80000000, 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'h0       ,
    32'h0       , 32'd64      };

//  reg [4:0] r [0:7] = 
//  {  7, 12, 17, 22,
//     7, 12, 17, 22,
//     7, 12, 17, 22,
//     7, 12, 17, 22,
//     5,  9, 14, 20,
//     5,  9, 14, 20,
//     5,  9, 14, 20,
//     5,  9, 14, 20,
//     4, 11, 16, 23,
//     4, 11, 16, 23,
//     4, 11, 16, 23,
//     4, 11, 16, 23,
//     6, 10, 15, 21,
//     6, 10, 15, 21,
//     6, 10, 15, 21,
//     6, 10, 15, 21};
 reg [31 : 0] f;
 reg [ 7 : 0] g;
 reg [ 7 : 0] i;
assign done = (i==63) ? 1 : 0;

localparam [2:0] S_INIT = 0, S_INC = 1, S_LOOP_1 = 2, S_LOOP_2 = 3, S_ADD = 4, S_DONE = 5;
reg [2:0] S, S_next;
always @(*) begin
 case (S)
    S_INIT:
        if (initialized) S_next = S_LOOP_1;
        else S_next <= S_INIT;
    S_INC:
        S_next <= S_LOOP_1;
    S_LOOP_1:
        S_next <= S_LOOP_2;
    S_LOOP_2:
        if (i<63) S_next <= S_LOOP_1;
        else S_next <= S_ADD;
    S_ADD:
        S_next <= S_DONE;
    S_DONE:
        S_next <= S_INC;
    default:
        S_next <= S_INIT;
 endcase
end

always @(posedge clk) begin
    if (S==S_INIT) begin
        w[511:448] <= att[63:0];
        state <= 0;
        initialized <= 1;
    end
    else if (S==S_INC) begin
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
    end
    else if (S==S_LOOP_1) begin
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
    end
    else if (S==S_LOOP_2) begin
        d <= c;
        c <= b;
        a <= d;        
        if(i==0 ) b <= b + (((a + f + 32'hd76aa478 + w[g]) <<  7) | ((a + f + 32'hd76aa478 + w[g]) >> (32 -  7)));
        if(i==1 ) b <= b + (((a + f + 32'he8c7b756 + w[g]) << 12) | ((a + f + 32'he8c7b756 + w[g]) >> (32 - 12)));
        if(i==2 ) b <= b + (((a + f + 32'h242070db + w[g]) << 17) | ((a + f + 32'h242070db + w[g]) >> (32 - 17)));
        if(i==3 ) b <= b + (((a + f + 32'hc1bdceee + w[g]) << 22) | ((a + f + 32'hc1bdceee + w[g]) >> (32 - 22)));
        if(i==4 ) b <= b + (((a + f + 32'hf57c0faf + w[g]) <<  7) | ((a + f + 32'hf57c0faf + w[g]) >> (32 -  7)));
        if(i==5 ) b <= b + (((a + f + 32'h4787c62a + w[g]) << 12) | ((a + f + 32'h4787c62a + w[g]) >> (32 - 12)));
        if(i==6 ) b <= b + (((a + f + 32'ha8304613 + w[g]) << 17) | ((a + f + 32'ha8304613 + w[g]) >> (32 - 17)));
        if(i==7 ) b <= b + (((a + f + 32'hfd469501 + w[g]) << 22) | ((a + f + 32'hfd469501 + w[g]) >> (32 - 22)));
        if(i==8 ) b <= b + (((a + f + 32'h698098d8 + w[g]) <<  7) | ((a + f + 32'h698098d8 + w[g]) >> (32 -  7)));
        if(i==9 ) b <= b + (((a + f + 32'h8b44f7af + w[g]) << 12) | ((a + f + 32'h8b44f7af + w[g]) >> (32 - 12)));
        if(i==10) b <= b + (((a + f + 32'hffff5bb1 + w[g]) << 17) | ((a + f + 32'hffff5bb1 + w[g]) >> (32 - 17)));
        if(i==11) b <= b + (((a + f + 32'h895cd7be + w[g]) << 22) | ((a + f + 32'h895cd7be + w[g]) >> (32 - 22)));
        if(i==12) b <= b + (((a + f + 32'h6b901122 + w[g]) <<  7) | ((a + f + 32'h6b901122 + w[g]) >> (32 -  7)));
        if(i==13) b <= b + (((a + f + 32'hfd987193 + w[g]) << 12) | ((a + f + 32'hfd987193 + w[g]) >> (32 - 12)));
        if(i==14) b <= b + (((a + f + 32'ha679438e + w[g]) << 17) | ((a + f + 32'ha679438e + w[g]) >> (32 - 17)));
        if(i==15) b <= b + (((a + f + 32'h49b40821 + w[g]) << 22) | ((a + f + 32'h49b40821 + w[g]) >> (32 - 22)));
        if(i==16) b <= b + (((a + f + 32'hf61e2562 + w[g]) <<  5) | ((a + f + 32'hf61e2562 + w[g]) >> (32 -  5)));
        if(i==17) b <= b + (((a + f + 32'hc040b340 + w[g]) <<  9) | ((a + f + 32'hc040b340 + w[g]) >> (32 -  9)));
        if(i==18) b <= b + (((a + f + 32'h265e5a51 + w[g]) << 14) | ((a + f + 32'h265e5a51 + w[g]) >> (32 - 14)));
        if(i==19) b <= b + (((a + f + 32'he9b6c7aa + w[g]) << 20) | ((a + f + 32'he9b6c7aa + w[g]) >> (32 - 20)));
        if(i==20) b <= b + (((a + f + 32'hd62f105d + w[g]) <<  5) | ((a + f + 32'hd62f105d + w[g]) >> (32 -  5)));
        if(i==21) b <= b + (((a + f + 32'h02441453 + w[g]) <<  9) | ((a + f + 32'h02441453 + w[g]) >> (32 -  9)));
        if(i==22) b <= b + (((a + f + 32'hd8a1e681 + w[g]) << 14) | ((a + f + 32'hd8a1e681 + w[g]) >> (32 - 14)));
        if(i==23) b <= b + (((a + f + 32'he7d3fbc8 + w[g]) << 20) | ((a + f + 32'he7d3fbc8 + w[g]) >> (32 - 20)));
        if(i==24) b <= b + (((a + f + 32'h21e1cde6 + w[g]) <<  5) | ((a + f + 32'h21e1cde6 + w[g]) >> (32 -  5)));
        if(i==25) b <= b + (((a + f + 32'hc33707d6 + w[g]) <<  9) | ((a + f + 32'hc33707d6 + w[g]) >> (32 -  9)));
        if(i==26) b <= b + (((a + f + 32'hf4d50d87 + w[g]) << 14) | ((a + f + 32'hf4d50d87 + w[g]) >> (32 - 14)));
        if(i==27) b <= b + (((a + f + 32'h455a14ed + w[g]) << 20) | ((a + f + 32'h455a14ed + w[g]) >> (32 - 20)));
        if(i==28) b <= b + (((a + f + 32'ha9e3e905 + w[g]) <<  5) | ((a + f + 32'ha9e3e905 + w[g]) >> (32 -  5)));
        if(i==29) b <= b + (((a + f + 32'hfcefa3f8 + w[g]) <<  9) | ((a + f + 32'hfcefa3f8 + w[g]) >> (32 -  9)));
        if(i==30) b <= b + (((a + f + 32'h676f02d9 + w[g]) << 14) | ((a + f + 32'h676f02d9 + w[g]) >> (32 - 14)));
        if(i==31) b <= b + (((a + f + 32'h8d2a4c8a + w[g]) << 20) | ((a + f + 32'h8d2a4c8a + w[g]) >> (32 - 20)));
        if(i==32) b <= b + (((a + f + 32'hfffa3942 + w[g]) <<  4) | ((a + f + 32'hfffa3942 + w[g]) >> (32 -  4)));
        if(i==33) b <= b + (((a + f + 32'h8771f681 + w[g]) << 11) | ((a + f + 32'h8771f681 + w[g]) >> (32 - 11)));
        if(i==34) b <= b + (((a + f + 32'h6d9d6122 + w[g]) << 16) | ((a + f + 32'h6d9d6122 + w[g]) >> (32 - 16)));
        if(i==35) b <= b + (((a + f + 32'hfde5380c + w[g]) << 23) | ((a + f + 32'hfde5380c + w[g]) >> (32 - 23)));
        if(i==36) b <= b + (((a + f + 32'ha4beea44 + w[g]) <<  4) | ((a + f + 32'ha4beea44 + w[g]) >> (32 -  4)));
        if(i==37) b <= b + (((a + f + 32'h4bdecfa9 + w[g]) << 11) | ((a + f + 32'h4bdecfa9 + w[g]) >> (32 - 11)));
        if(i==38) b <= b + (((a + f + 32'hf6bb4b60 + w[g]) << 16) | ((a + f + 32'hf6bb4b60 + w[g]) >> (32 - 16)));
        if(i==39) b <= b + (((a + f + 32'hbebfbc70 + w[g]) << 23) | ((a + f + 32'hbebfbc70 + w[g]) >> (32 - 23)));
        if(i==40) b <= b + (((a + f + 32'h289b7ec6 + w[g]) <<  4) | ((a + f + 32'h289b7ec6 + w[g]) >> (32 -  4)));
        if(i==41) b <= b + (((a + f + 32'heaa127fa + w[g]) << 11) | ((a + f + 32'heaa127fa + w[g]) >> (32 - 11)));
        if(i==42) b <= b + (((a + f + 32'hd4ef3085 + w[g]) << 16) | ((a + f + 32'hd4ef3085 + w[g]) >> (32 - 16)));
        if(i==43) b <= b + (((a + f + 32'h04881d05 + w[g]) << 23) | ((a + f + 32'h04881d05 + w[g]) >> (32 - 23)));
        if(i==44) b <= b + (((a + f + 32'hd9d4d039 + w[g]) <<  4) | ((a + f + 32'hd9d4d039 + w[g]) >> (32 -  4)));
        if(i==45) b <= b + (((a + f + 32'he6db99e5 + w[g]) << 11) | ((a + f + 32'he6db99e5 + w[g]) >> (32 - 11)));
        if(i==46) b <= b + (((a + f + 32'h1fa27cf8 + w[g]) << 16) | ((a + f + 32'h1fa27cf8 + w[g]) >> (32 - 16)));
        if(i==47) b <= b + (((a + f + 32'hc4ac5665 + w[g]) << 23) | ((a + f + 32'hc4ac5665 + w[g]) >> (32 - 23)));
        if(i==48) b <= b + (((a + f + 32'hf4292244 + w[g]) <<  6) | ((a + f + 32'hf4292244 + w[g]) >> (32 -  6)));
        if(i==49) b <= b + (((a + f + 32'h432aff97 + w[g]) << 10) | ((a + f + 32'h432aff97 + w[g]) >> (32 - 10)));
        if(i==50) b <= b + (((a + f + 32'hab9423a7 + w[g]) << 15) | ((a + f + 32'hab9423a7 + w[g]) >> (32 - 15)));
        if(i==51) b <= b + (((a + f + 32'hfc93a039 + w[g]) << 21) | ((a + f + 32'hfc93a039 + w[g]) >> (32 - 21)));
        if(i==52) b <= b + (((a + f + 32'h655b59c3 + w[g]) <<  6) | ((a + f + 32'h655b59c3 + w[g]) >> (32 -  6)));
        if(i==53) b <= b + (((a + f + 32'h8f0ccc92 + w[g]) << 10) | ((a + f + 32'h8f0ccc92 + w[g]) >> (32 - 10)));
        if(i==54) b <= b + (((a + f + 32'hffeff47d + w[g]) << 15) | ((a + f + 32'hffeff47d + w[g]) >> (32 - 15)));
        if(i==55) b <= b + (((a + f + 32'h85845dd1 + w[g]) << 21) | ((a + f + 32'h85845dd1 + w[g]) >> (32 - 21)));
        if(i==56) b <= b + (((a + f + 32'h6fa87e4f + w[g]) <<  6) | ((a + f + 32'h6fa87e4f + w[g]) >> (32 -  6)));
        if(i==57) b <= b + (((a + f + 32'hfe2ce6e0 + w[g]) << 10) | ((a + f + 32'hfe2ce6e0 + w[g]) >> (32 - 10)));
        if(i==58) b <= b + (((a + f + 32'ha3014314 + w[g]) << 15) | ((a + f + 32'ha3014314 + w[g]) >> (32 - 15)));
        if(i==59) b <= b + (((a + f + 32'h4e0811a1 + w[g]) << 21) | ((a + f + 32'h4e0811a1 + w[g]) >> (32 - 21)));
        if(i==60) b <= b + (((a + f + 32'hf7537e82 + w[g]) <<  6) | ((a + f + 32'hf7537e82 + w[g]) >> (32 -  6)));
        if(i==61) b <= b + (((a + f + 32'hbd3af235 + w[g]) << 10) | ((a + f + 32'hbd3af235 + w[g]) >> (32 - 10)));
        if(i==62) b <= b + (((a + f + 32'h2ad7d2bb + w[g]) << 15) | ((a + f + 32'h2ad7d2bb + w[g]) >> (32 - 15)));
        if(i==63) b <= b + (((a + f + 32'heb86d391 + w[g]) << 21) | ((a + f + 32'heb86d391 + w[g]) >> (32 - 21)));

        i <= i + 1;
    end
    else if (S==S_ADD) begin
        a <= a + h0;
        b <= b + h1;
        c <= c + h2;
        d <= d + h3;
    end
    else if (S==S_DONE) begin
        hash <= {a,b,c,d};
        current_att <= {att[63:0]};
        i <= 0;
        initialized <= 0;
    end 
 end

 endmodule