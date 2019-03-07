module multPatches
#(parameter PATCH_NUM = 36,	// 36 patches for 24*24 grid
  parameter PATCH_NUM_DIMENSION = 6,	// 6*6=36
  parameter MIDDLE_PATCH = 21,
  parameter PATCH_SIZE = 4) // 4*4 patch size 
(output reg signed [17:0] mid_node_out,   // output the middle node
 input clock,							  // clock
 input reset,		       				  // reset
 input enable,							  // enable solver
 input signed [17:0] rho				  // rho
);

	reg signed [17:0] u_init[PATCH_SIZE*PATCH_SIZE*PATCH_NUM-1:0];    // inital hit value of each node, size:576 
	reg signed [17:0] data_out[PATCH_SIZE*PATCH_SIZE-1:0];			  // output data from patch, size:16
	wire middle;
	
	initial
	begin
		$readmemh("hit24by24.txt",u_init);
    end
		
	
	genvar i;
	generate
	for (i = 0; i < PATCH_NUM; i = i + 1) begin: patch
			
		
			wire signed [17:0] u_1_right;  				// input from right
 			wire signed [17:0] u_1_left;   				// input from left 
 			wire signed [17:0] u_1_up; 					// input from up
 			wire signed [17:0] u_1_down;   				// input from down

			assign middle = (i == MIDDLE_PATCH) ? 1 : 0;

			// assign input for the patch
		    assign u_1_right = ((i % PATCH_NUM_DIMENSION) == (PATCH_NUM_DIMENSION - 1) ) ? 0 : data_out[i+1];	// the value is zero when patch in the last col
			assign u_1_left = ((i % PATCH_NUM_DIMENSION) == 0) ? 0 : data_out[i-1];								// the value is zero when patch in the first col
			assign u_1_up = (i < PATCH_NUM_DIMENSION) ? 0 : data_out[i-PATCH_NUM_DIMENSION];					// the value is zero when patch in the first row
			assign u_1_down = (i > (PATCH_NUM - 3)) ? 0 : data_out[i+PATCH_NUM_DIMENSION]; 						// the value is zero when patch in the last row
			
			fourByFourNodePatch patch(.data_out(data_out[i]),
									  .middle(middle),
									  .clock(clock),
		             			      .reset(reset),
	                 	   		      .init(u_init[i*PATCH_NODE_NUM:(i+1)*PATCH_NODE_NUM-1]),
									  .u_1_right(u_1_right),  					
									  .u_1_left_1(u_1_left),    				
									  .u_1_up_1(u_1_up),    					
									  .u_1_down_1(u_1_down),    				
						              .rho(rho),
									  .enable(enable));
									  
	end
	endgenerate
	
	always @ (posedge clock)
	begin
		mid_node_out <= data_out[MIDDLE_PATCH];
	end
	

 endmodule
