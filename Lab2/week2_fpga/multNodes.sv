module multNodes
#(parameter SIZE = 10)
(output signed [17:0] u_2_mid[SIZE-1:0][SIZE-1:0],   // output
 input clock,
 input reset,		       // reset
 input signed [17:0] u_hit_mid[SIZE-1:0][SIZE-1:0],  // init hit in the middle
 input signed [17:0] u_1_right[SIZE-1:0][SIZE-1:0],  // input from right node output
 input signed [17:0] u_1_left[SIZE-1:0][SIZE-1:0],    // input from left node output
 input signed [17:0] u_1_up[SIZE-1:0][SIZE-1:0],     // input from up node output
 input signed [17:0] u_1_down[SIZE-1:0][SIZE-1:0]    // input from down node ouput
);
  
    genvar i,j,k;
    generate
	for (k = 1; k < SIZE-1; k = k + 1) begin: side
		OneNode nodeUp(.u_2_mid(u_2_mid[0][k]),
			       .clock(clock),
		               .reset(reset),
	                       .u_hit_mid(u_hit_mid[0][k]),
	                       .u_1_right(u_1_right[0][k+1]),
	                       .u_1_left(u_1_left[0][k-1]),
	                       .u_1_up(0),
	       	               .u_1_down(u_1_down[1][k]));  
		OneNode nodeDown(.u_2_mid(u_2_mid[SIZE-1][k]), 
			         .clock(clock),
		                 .reset(reset),
	                         .u_hit_mid(u_hit_mid[SIZE-1][k]),
	                         .u_1_right(u_1_right[SIZE-1][k+1]),
	                         .u_1_left(u_1_left[SIZE-1][k-1]),
	                         .u_1_up(u_1_up[SIZE-2][k]),
	       	                 .u_1_down(0));
		OneNode nodeLeft(.u_2_mid(u_2_mid[k][0]),//[(i-1)*SIZE+j], 
			         .clock(clock),
		                 .reset(reset),//[(i-1)*SIZE+j],
	                         .u_hit_mid(u_hit_mid[k][0]),//[(i-1)*SIZE+j],  // init hit in the middle
	                         .u_1_right(u_1_right[k][1]),//[(i-1)*SIZE+j],  // input from right node output
	                         .u_1_left(0),//[(i-1)*SIZE+j],   // input from left node output
	                         .u_1_up(u_1_up[k-1][0]),//[(i-1)*SIZE+j],     // input from up node output
	       	                 .u_1_down(u_1_down[k+1][0]));//[(i-1)*SIZE+j]); 
		OneNode nodeRight(.u_2_mid(u_2_mid[k][SIZE-1]), 
			         .clock(clock),
		                 .reset(reset),
	                         .u_hit_mid(u_hit_mid[k][SIZE-1]),
	                         .u_1_right(0),
	                         .u_1_left(u_1_left[k][SIZE-2]),
	                         .u_1_up(u_1_up[k+1][SIZE-1]),
	       	                 .u_1_down(u_1_down[k-1][SIZE-1])); 
	end
    endgenerate

    generate
	for (k = 0; k < SIZE; k = k + 10) begin: corner
		OneNode UpLeftCorner(.u_2_mid(u_2_mid[0][k]), 
			             .clock(clock),
		                     .reset(reset),
	                             .u_hit_mid(u_hit_mid[0][k]),
	                             .u_1_right(u_1_right[0][k+1]),
	                             .u_1_left(0),
	                             .u_1_up(0),
	       	                     .u_1_down(u_1_down[1][k]));
		OneNode UpRightCorner(.u_2_mid(u_2_mid[k][SIZE-1]), 
			             .clock(clock),
		                     .reset(reset),
	                             .u_hit_mid(u_hit_mid[k][SIZE-1]),
	                             .u_1_right(0),
	                             .u_1_left(u_1_left[k][SIZE-2]),
	                             .u_1_up(0),
	       	                     .u_1_down(u_1_down[k+1][SIZE-1]));
		OneNode DownLeftCorner(.u_2_mid(u_2_mid[SIZE-1][k]), 
			               .clock(clock),
		                       .reset(reset),
	                               .u_hit_mid(u_hit_mid[k][SIZE-1]),
	                               .u_1_right(u_1_right[SIZE-1][k+1]),
	                               .u_1_left(0),
	                               .u_1_up(u_1_up[SIZE-1][k]),
	       	                      .u_1_down(0));  
		OneNode DownRightCorner(.u_2_mid(u_2_mid[SIZE-1][SIZE-1]), 
			                .clock(clock),
		                        .reset(reset),
	                                .u_hit_mid(u_hit_mid[SIZE-1][SIZE-1]),
	                                .u_1_right(0),
	                                .u_1_left(u_1_left[SIZE-1][SIZE-2]),
	                                .u_1_up(u_1_up[SIZE-2][SIZE-1]),
	       	                        .u_1_down(0));      
	end
    endgenerate

    generate
	for (i = 1; i < SIZE-1; i = i + 1) begin: row
	    for (j = 1; j < SIZE-1; j = j + 1) begin: col
		OneNode node(.u_2_mid(u_2_mid[i][j]),//[(i-1)*SIZE+j], 
			     .clock(clock),
		             .reset(reset),//[(i-1)*SIZE+j],
	                     .u_hit_mid(u_hit_mid[i][j]),//[(i-1)*SIZE+j],  // init hit in the middle
	                     .u_1_right(u_1_right[i][j+1]),//[(i-1)*SIZE+j],  // input from right node output
	                     .u_1_left(u_1_left[i][j-1]),//[(i-1)*SIZE+j],   // input from left node output
	                     .u_1_up(u_1_up[i-1][j]),//[(i-1)*SIZE+j],     // input from up node output
	       	             .u_1_down(u_1_down[i+1][j]));//[(i-1)*SIZE+j]);  
	    end
	end
    endgenerate



endmodule
