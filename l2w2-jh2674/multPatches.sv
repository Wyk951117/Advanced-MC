module multPatches
#(parameter SIZE = 4)
(output reg signed [17:0] u_2_mid[SIZE-1:0][SIZE-1:0],   // output 
 output iterFlag,//[5:0][5:0],
 input clock,
 input reset,		       // reset
 input signed [17:0] u_hit_mid[SIZE-1:0][SIZE-1:0],  // init hit in the middle
 input signed [17:0] u_1_right[SIZE-1:0][SIZE-1:0],  // input from right node output
 input signed [17:0] u_1_left[SIZE-1:0][SIZE-1:0],    // input from left node output
 input signed [17:0] u_1_up[SIZE-1:0][SIZE-1:0],     // input from up node output
 input signed [17:0] u_1_down[SIZE-1:0][SIZE-1:0],    // input from down node ouput
 input signed [17:0] rho
);
	//reg signed [17:0] u_2_mid;  
	wire patchFlag[5:0][5:0];
	/*		fourByFourNodePatch patch(.u_2_mid(u_2_mid),
						  .iterFlag(flag),  
			     			  .clock(clock),
		             			  .reset(reset),
	                 	   		  .u_hit_mid(u_hit_mid),
						  .u_1_right_1(0),  					
						  .u_1_right_2(0),  					
						  .u_1_right_3(0),  					
 						  .u_1_right_4(0),  					
 						  .u_1_left_1(0),    				
 						  .u_1_left_2(0),    				
						  .u_1_left_3(0),    				
						  .u_1_left_4(0),    				
 						  .u_1_up_1(0),    					
						  .u_1_up_2(0),    					
						  .u_1_up_3(0),    					
 						  .u_1_up_4(0),    					
 						  .u_1_down_1(0),    				
 						  .u_1_down_2(0),    				
 						  .u_1_down_3(0),    				
 						  .u_1_down_4(0),
						  .rho(rho));*/

	genvar i,j;
	generate
	for (i = 0; i < SIZE; i = i + 4) begin: row
	    for (j = 0; j < SIZE; j = j + 4) begin: col
			wire flag;//[5:0][5:0];
			wire signed [17:0] u_1_right_1;  					// input from right 1 node output
 			wire signed [17:0] u_1_right_2;  					// input from right 2 node output
 			wire signed [17:0] u_1_right_3;  					// input from right 3 node output
 			wire signed [17:0] u_1_right_4;  					// input from right 4 node output
 			wire signed [17:0] u_1_left_1;   				// input from left 1 node output
 			wire signed [17:0] u_1_left_2;   				// input from left 2 node output
 			wire signed [17:0] u_1_left_3;   				// input from left 3 node output
 			wire signed [17:0] u_1_left_4;   				// input from left 4 node output
 			wire signed [17:0] u_1_up_1; 					// input from up 1 node output
 			wire signed [17:0] u_1_up_2; 					// input from up 2 node output
 			wire signed [17:0] u_1_up_3; 					// input from up 3 node output
 			wire signed [17:0] u_1_up_4; 					// input from up 4 node output
 			wire signed [17:0] u_1_down_1;   				// input from down 1 node ouput
 			wire signed [17:0] u_1_down_2;   				// input from down 2 node ouput
 			wire signed [17:0] u_1_down_3;   				// input from down 3 node ouput
 			wire signed [17:0] u_1_down_4;    					// input from down 4 node ouput
			wire signed [17:0] u_hit_16[3:0][3:0];
			wire signed [17:0] u_mid_16[3:0][3:0];	

			// assign input for the patch
		    	assign u_1_right_1 = (j == SIZE-4) ? 0 : u_1_right[i][j+4];
			assign u_1_right_2 = (j == SIZE-4) ? 0 : u_1_right[i+1][j+4];
			assign u_1_right_3 = (j == SIZE-4) ? 0 : u_1_right[i+2][j+4];
			assign u_1_right_4 = (j == SIZE-4) ? 0 : u_1_right[i+3][j+4];
			assign u_1_left_1 = (j == 0) ? 0 : u_1_left[i][j-1];
			assign u_1_left_2 = (j == 0) ? 0 : u_1_left[i+1][j-1];
			assign u_1_left_3 = (j == 0) ? 0 : u_1_left[i+2][j-1];
			assign u_1_left_4 = (j == 0) ? 0 : u_1_left[i+3][j-1];
			assign u_1_up_1 = (i == 0) ? 0 : u_1_up[i-1][j];
			assign u_1_up_2 = (i == 0) ? 0 : u_1_up[i-1][j+1];
			assign u_1_up_3 = (i == 0) ? 0 : u_1_up[i-1][j+2];
			assign u_1_up_4 = (i == 0) ? 0 : u_1_up[i-1][j+3];
			assign u_1_down_1 = (i == SIZE-4) ? 0 : u_1_down[i+1][j]; 
			assign u_1_down_2 = (i == SIZE-4) ? 0 : u_1_down[i+1][j+1]; 
			assign u_1_down_3 = (i == SIZE-4) ? 0 : u_1_down[i+1][j+2]; 
			assign u_1_down_4 = (i == SIZE-4) ? 0 : u_1_down[i+1][j+3]; 
			assign u_hit_16[0][0] = u_hit_mid[i][j];
			assign u_hit_16[0][1] = u_hit_mid[i][j+1];
			assign u_hit_16[0][2] = u_hit_mid[i][j+2];
			assign u_hit_16[0][3] = u_hit_mid[i][j+3];
			assign u_hit_16[1][0] = u_hit_mid[i+1][j];
			assign u_hit_16[1][1] = u_hit_mid[i+1][j+1];
			assign u_hit_16[1][2] = u_hit_mid[i+1][j+2];
			assign u_hit_16[1][3] = u_hit_mid[i+1][j+3];
			assign u_hit_16[2][0] = u_hit_mid[i+2][j];
			assign u_hit_16[2][1] = u_hit_mid[i+2][j+1];
			assign u_hit_16[2][2] = u_hit_mid[i+2][j+2];
			assign u_hit_16[2][3] = u_hit_mid[i+2][j+3];
			assign u_hit_16[3][0] = u_hit_mid[i+3][j];
			assign u_hit_16[3][1] = u_hit_mid[i+3][j+1];
			assign u_hit_16[3][2] = u_hit_mid[i+3][j+2];
			assign u_hit_16[3][3] = u_hit_mid[i+3][j+3];


			fourByFourNodePatch patch(.u_2_mid(u_mid_16),
						  .iterFlag(flag),  
			     			  .clock(clock),
		             			  .reset(reset),
	                 	   		  .u_hit_mid(u_hit_16),
						  .u_1_right_1(u_1_right_1),  					
						  .u_1_right_2(u_1_right_2),  					
						  .u_1_right_3(u_1_right_3),  					
 						  .u_1_right_4(u_1_right_4),  					
 						  .u_1_left_1(u_1_left_1),    				
 						  .u_1_left_2(u_1_left_2),    				
						  .u_1_left_3(u_1_left_3),    				
						  .u_1_left_4(u_1_left_4),    				
 						  .u_1_up_1(u_1_up_1),    					
						  .u_1_up_2(u_1_up_2),    					
						  .u_1_up_3(u_1_up_3),    					
 						  .u_1_up_4(u_1_up_4),    					
 						  .u_1_down_1(u_1_down_1),    				
 						  .u_1_down_2(u_1_down_2),    				
 						  .u_1_down_3(u_1_down_3),    				
 						  .u_1_down_4(u_1_down_4),
						  .rho(rho));
			// update the grid from the output of patch
			assign u_2_mid[i][j] = u_mid_16[0][0];
			assign u_2_mid[i][j+1] = u_mid_16[0][1];
			assign u_2_mid[i][j+2] = u_mid_16[0][2];
			assign u_2_mid[i][j+3] = u_mid_16[0][3];
			assign u_2_mid[i+1][j] = u_mid_16[1][0];
			assign u_2_mid[i+1][j+1] = u_mid_16[1][1];
			assign u_2_mid[i+1][j+2] = u_mid_16[1][2];
			assign u_2_mid[i+1][j+3] = u_mid_16[1][3];
			assign u_2_mid[i+2][j] = u_mid_16[2][0];
			assign u_2_mid[i+2][j+1] = u_mid_16[2][1];
			assign u_2_mid[i+2][j+2] = u_mid_16[2][2];
			assign u_2_mid[i+2][j+3] = u_mid_16[2][3];
			assign u_2_mid[i+3][j] = u_mid_16[3][0];
			assign u_2_mid[i+3][j+1] = u_mid_16[3][1];
			assign u_2_mid[i+3][j+2] = u_mid_16[3][2];
			assign u_2_mid[i+3][j+3] = u_mid_16[3][3];
			assign patchFlag[i>>2][j>>2] = flag;
			//iterFlag
	    end
	end
	endgenerate
	assign iterFlag = patchFlag[0][0]&patchFlag[0][1]&patchFlag[0][2]&patchFlag[0][3]&patchFlag[0][4]&patchFlag[0][5]
			 &patchFlag[1][0]&patchFlag[1][1]&patchFlag[1][2]&patchFlag[1][3]&patchFlag[1][4]&patchFlag[1][5]
			 &patchFlag[2][0]&patchFlag[2][1]&patchFlag[2][2]&patchFlag[2][3]&patchFlag[2][4]&patchFlag[2][5]
			 &patchFlag[3][0]&patchFlag[3][1]&patchFlag[3][2]&patchFlag[3][3]&patchFlag[3][4]&patchFlag[3][5]
			 &patchFlag[4][0]&patchFlag[4][1]&patchFlag[4][2]&patchFlag[4][3]&patchFlag[4][4]&patchFlag[4][5]
			 &patchFlag[5][0]&patchFlag[5][1]&patchFlag[5][2]&patchFlag[5][3]&patchFlag[5][4]&patchFlag[5][5];
 endmodule
