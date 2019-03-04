module OneNode(output signed [17:0] u_2_mid,   // output
	       //input clock,		       // clock
	       //input reset,		       // reset
               /* should I change to type to regisiter? */
	       input reg signed [17:0] u_hit_mid,  // init hit in the middle
	       input reg signed [17:0] u_1_right,  // input from right node output
	       input reg signed [17:0] u_1_left,    // input from left node output
	       input reg signed [17:0] u_1_up,     // input from up node output
	       input reg signed [17:0] u_1_down,   // input from down node output
	       input reg signed [17:0] rho,
	       /* add input of u_1_mid and u_0_mid to do computation */
	       input reg signed [17:0] u_1_mid,
               input reg signed [17:0] u_0_mid
);  

    //reg signed [17:0] u_0_mid_temp;		// u_n-1 store input from last time
    //reg signed [17:0] u_1_mid_temp, u_1_right_temp, u_1_left_temp, u_1_up_temp,u_1_down_temp;// u_n
    wire signed [17:0] temp1,temp2, temp3;

    parameter [17:0] rho_fix = (1<<17)/20; 		// rho = 0.2,0.1,0.09,0.08(zd)    0.05(sl)

    parameter [17:0] rho_max = (48<<17)/100;

    // reset and update
    /*always @ (posedge clock)//reset or u_2_mid)
    begin
	// init
		if (reset == 0)
		begin    
	    		u_1_mid_temp <= u_hit_mid;     // hit u_n
	   	 	u_0_mid_temp <= u_hit_mid;     // init u_n-1
			u_1_right_temp <= 0;
			u_1_left_temp <= 0;
			u_1_up_temp <= 0;
			u_1_down_temp <= 0;
   		end
		// update
        	else
		begin
	    		u_0_mid_temp <= u_1_mid_temp; // store input from last time
        		u_1_mid_temp <= u_2_mid;	  // output to input
			u_1_right_temp <= u_1_right;
			u_1_left_temp <= u_1_left;
			u_1_up_temp <= u_1_up;
			u_1_down_temp <= u_1_down;
		end
    end */

    /* the version of using intermediant wire to do computation */
    /*assign  temp1 = u_1_up_temp + u_1_down_temp + u_1_right_temp + u_1_left_temp - (u_1_mid_temp<<<2);
 
    signed_mult_1_17 mult_1(.out(temp2),
			    .a(temp1),
                            .b(rho)); 

    assign  temp3 = temp2 + (u_1_mid_temp<<<1) - (u_0_mid_temp - (u_0_mid_temp>>>10));
    assign  u_2_mid = temp3 - (temp3>>>10); */



    /* the version that directly implements inputs to do computation */
    assign  temp1 = u_1_up + u_1_down + u_1_right + u_1_left - (u_1_mid<<<2);
 
    signed_mult_1_17 mult_1(.out(temp2),
			    .a(temp1),
                            .b(rho)); 

    assign  temp3 = temp2 + (u_1_mid<<<1) - (u_0_mid - (u_0_mid>>>10));
    assign  u_2_mid = temp3 - (temp3>>>10);

    
endmodule
