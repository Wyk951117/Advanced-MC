module testNodePatch
#(parameter SIZE = 4);
	reg clk_50, rst;
	reg signed [17:0] u_hit_mid[SIZE-1:0][SIZE-1:0];    // Inital hit value of each node 
	reg signed [17:0] u_2_mid_input[SIZE-1:0][SIZE-1:0]; 
	reg signed [17:0] delta_rho, rho_init, rho_max;
	reg signed [17:0] rho;
	wire signed [17:0] u_2_mid[SIZE-1:0][SIZE-1:0];     // Output of each node
   	wire iterFlag/*[5:0][5:0]*/;

	initial
	begin
		$readmemh("hit4by4.txt",u_hit_mid);
		$readmemh("hit4by4.txt",u_2_mid_input);
		clk_50 = 1'b0;
   	    	rst = 0;
        	#600
        	rst = 1; 
		rho_init = (1<<17)/20;		// 0.05
		rho = (1<<17)/20;
		rho_max = (48<<17)/100; 	// 0.48
    	end

    	always 
	begin
		#100
		clk_50  = !clk_50;
    	end

	always @ (posedge clk_50)
	begin
		if (iterFlag/*[5][5]*/ == 1)
		begin
			u_2_mid_input <= u_2_mid;
			//rho = (rho_max > rho)?(rho_init + (delta_rho>>6)):rho_max;
		if (rho_max > rho) begin rho <= rho_init + (delta_rho>>5); end
		else begin rho <= rho_max; end
		end
	end

		
		

	//assign rho = (rho_max > rho)?(rho_init + (delta_rho>>6)):rho_max;

	signed_mult_1_17 mult_rho(.out(delta_rho),
			    	  .a(u_2_mid[SIZE>>1][SIZE>>1]),
                            	  .b(u_2_mid[SIZE>>1][SIZE>>1])); 

	multPatches grid(.u_2_mid(u_2_mid),   		// output
			 .iterFlag(iterFlag), 
	  	  	 .clock(clk_50),
         		 .reset(rst),		       	// reset
 		         .u_hit_mid(u_hit_mid),		// init hit in the middle
 		         .u_1_right(u_2_mid_input), 		// input from right node output
 		         .u_1_left(u_2_mid_input), 		// input from left node output
 		         .u_1_up(u_2_mid_input), 			// input from up node output
 		         .u_1_down(u_2_mid_input),		// input from down node output
			 .rho(rho));

 
endmodule
