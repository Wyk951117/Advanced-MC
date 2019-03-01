module testMultNodes
#(parameter SIZE = 10)
(output signed [17:0] mid_output, // output
 input clk,
 input reset);
    reg clk_50, rst, count;
	 reg signed [17:0] u_hit_init[SIZE-1:0][SIZE-1:0];
    reg signed [17:0] u_hit_mid[SIZE-1:0][SIZE-1:0];    // Inital hit value of each node 10*10
    reg signed [17:0] u_1_right[SIZE-1:0][SIZE-1:0]; // 
    reg signed [17:0] u_1_left[SIZE-1:0][SIZE-1:0];  //
    reg signed [17:0] u_1_up[SIZE-1:0][SIZE-1:0];    //
    reg signed [17:0] u_1_down[SIZE-1:0][SIZE-1:0];  //
    
    wire signed [17:0] u_2_mid[SIZE-1:0][SIZE-1:0];     // Output of each node
   
    //wire signed [17:0] u_2_mid;	/* One node testing */
    //reg signed [17:0] u_hit_mid;
/*    integer i,j,p,q;
always @ (posedge clk) begin
	if (reset) begin
		// Read initial hit value
		$readmemh("inithit.txt",u_hit_mid);
		for (p = 0; p < SIZE; p = p + 1) begin
			for (q = 0; q < SIZE; q = q + 1) begin
			$display("%h",u_hit_mid[i][j]);
			end
		end
	end // end if
end // end always @ (posedge clk)
*/


	///////// compute the initial state on reg u_hit_init /////////
	Init init(.hit(u_hit_init), .clock(clk), .reset(reset));
	
	
	///////// constantly update the state of the drum ///////////
   multNodes grid(.u_2_mid(u_2_mid),   		// output
		  .clock(clk),
 	          .reset(reset),		       // reset
 	          .u_hit_mid(u_hit_mid),  	// init hit in the middle
 	          .u_1_right(u_2_mid), 		//u_1_right),  // input from right node output
 	          .u_1_left(u_2_mid), 		//u_1_left),    // input from left node output
 	          .u_1_up(u_2_mid), 		//u_1_up),     // input from up node output
 	          .u_1_down(u_2_mid));		//u_1_down));

	always @ (posedge clk) begin
		//// assign the initial state of u_hit_init to u_hit_mid if reset ////
		if (reset) u_hit_mid = u_hit_init;
	end
	
	/////// assign the value of the middle point on the drum to the output //////
	assign mid_output = u_2_mid[SIZE/2][SIZE/2];
endmodule
