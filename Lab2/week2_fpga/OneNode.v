module OneNode(output signed [17:0] u_2_mid,   // output
	       input clock,		       // clock
	       input reset,		       // reset
	       input signed [17:0] u_hit_mid,  // init hit in the middle
	       input signed [17:0] u_1_right,  // input from right node output
	       input signed [17:0] u_1_left,    // input from left node output
	       input signed [17:0] u_1_up,     // input from up node output
	       input signed [17:0] u_1_down   // input from down node output
);  

    reg signed [17:0] u_0_mid_temp;		// u_n-1 store input from last time
    reg signed [17:0] u_1_mid_temp, u_1_right_temp, u_1_left_temp, u_1_up_temp, u_1_down_temp;// u_n
    wire signed [17:0] temp1,temp2, temp3, temp4;
  

    parameter [17:0] rho = (1<<17)/20; 
    parameter [17:0] eta = (999<<17)/1000;
    // reset and update
    always @ (posedge clock)//reset or u_2_mid)
    begin
	// init hit
	if (reset == 0)
	begin
	    
	    u_1_mid_temp = u_hit_mid;//u_hit_mid;     // hit u_n
	    u_0_mid_temp = u_1_mid_temp;//u_hit_mid;     // init u_n-1
	    u_1_right_temp = 0; 
	    u_1_left_temp = 0;
	    u_1_up_temp = 0;
	    u_1_down_temp = 0;
   	end
	// update
        else
	begin
	    u_0_mid_temp = u_1_mid_temp; // store input from last time
            u_1_mid_temp = u_2_mid;	  // output to input
	    u_1_right_temp = u_1_right;  // input from the right
	    u_1_left_temp = u_1_left;	  // input from the left
	    u_1_up_temp = u_1_up;        // input from the top
	    u_1_down_temp = u_1_down;    // input from the bottom
	end
    end

    assign  temp1 = u_1_up_temp + u_1_down_temp + u_1_right_temp + u_1_left_temp - (u_1_mid_temp<<<2);
 
    signed_mult_1_17 mult_1(.out(temp2),
			    .a(temp1),
                            .b(rho)); 

    assign  temp4 = temp2 + (u_1_mid_temp<<<1) - temp3;

    signed_mult_1_17 mult_2(.out(temp3),
			    .a(u_0_mid_temp),
                            .b(eta)); 
    signed_mult_1_17 mult_3(.out(u_2_mid),
			    .a(temp4),
                            .b(eta)); 
    
    
endmodule
