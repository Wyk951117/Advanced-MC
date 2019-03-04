module fourByFourNodePatch	// 4*4 patch
(output reg signed [17:0] u_2_mid[3:0][3:0], 			// output
 output iterFlag,									// 
 input clock,										// clock
 input reset,		       							// reset
 input signed [17:0] u_hit_mid[3:0][3:0],			// init hit in the middle
 input signed [17:0] u_1_right_1,  					// input from right 1 node output
 input signed [17:0] u_1_right_2,  					// input from right 2 node output
 input signed [17:0] u_1_right_3,  					// input from right 3 node output
 input signed [17:0] u_1_right_4,  					// input from right 4 node output
 input signed [17:0] u_1_left_1,    				// input from left 1 node output
 input signed [17:0] u_1_left_2,    				// input from left 2 node output
 input signed [17:0] u_1_left_3,    				// input from left 3 node output
 input signed [17:0] u_1_left_4,    				// input from left 4 node output
 input signed [17:0] u_1_up_1,    					// input from up 1 node output
 input signed [17:0] u_1_up_2,    					// input from up 2 node output
 input signed [17:0] u_1_up_3,    					// input from up 3 node output
 input signed [17:0] u_1_up_4,    					// input from up 4 node output
 input signed [17:0] u_1_down_1,    				// input from down 1 node ouput
 input signed [17:0] u_1_down_2,    				// input from down 2 node ouput
 input signed [17:0] u_1_down_3,    				// input from down 3 node ouput
 input signed [17:0] u_1_down_4,    					// input from down 4 node ouput
 input signed [17:0] rho
);
	reg signed [17:0] u_2_mid_temp;
	reg signed [17:0] u_1_right, u_1_left, u_1_up, u_1_down;
	reg signed [17:0] u_hit_mid_temp;
	reg signed [17:0] u_2_mid_store[3:0][3:0];  // store register for output
	reg flag;
        
	// register for u_1 and u_0
	reg signed [17:0] u_2_mid_load[3:0][3:0];
	reg signed [17:0] u_1_mid_load[3:0][3:0];
	reg signed [17:0] u_0_mid_load[3:0][3:0];
	reg signed [17:0] u_1_node;
	reg signed [17:0] u_0_node;
	

	//assign u_2_mid_init = u_hit_mid;

	parameter idle = 5'h0;
	parameter node_1_1 = 5'h1;							// node (1,1)
	parameter node_1_2 = 5'h2; 							// node (1,2)
	parameter node_1_3 = 5'h3;							// node (1,3)
	parameter node_1_4 = 5'h4;							// node (1,4)

	parameter node_2_1 = 5'h5;							// node (2,1)
	parameter node_2_2 = 5'h6;							// node (2,2)
	parameter node_2_3 = 5'h7;							// node (2,3)
	parameter node_2_4 = 5'h8;							// node (2,4)

	parameter node_3_1 = 5'h9;							// node (3,1)
	parameter node_3_2 = 5'hA; 							// node (3,2)
	parameter node_3_3 = 5'hB;							// node (3,3)
	parameter node_3_4 = 5'hC;							// node (3,4)

	parameter node_4_1 = 5'hD;							// node (4,1)
	parameter node_4_2 = 5'hE; 							// node (4,2)
	parameter node_4_3 = 5'hF;							// node (4,3)
	parameter node_4_4 = 5'h10;							// node (4,4)
	parameter store = 5'h11;
	reg [4:0] current_state, next_state;

	always @ (posedge clock)
	begin
		if (reset == 0) begin current_state <= idle;   end					
		else            begin current_state <= next_state; end		
	end

	always @ (current_state)
	begin
		case(current_state)
			// first row
			idle: begin next_state = node_1_1; end
			node_1_1: begin	next_state = node_1_2;	end
			node_1_2: begin	next_state = node_1_3;  end
			node_1_3: begin	next_state = node_1_4;  end
			node_1_4: begin	next_state = node_2_1;	end
			// second row
			node_2_1: begin	next_state = node_2_2;  end
			node_2_2: begin	next_state = node_2_3;  end
			node_2_3: begin	next_state = node_2_4;  end
			node_2_4: begin	next_state = node_3_1;  end
			// third row
			node_3_1: begin	next_state = node_3_2;  end
			node_3_2: begin	next_state = node_3_3;	end
			node_3_3: begin	next_state = node_3_4;  end
			node_3_4: begin	next_state = node_4_1;	end
			// fourth row
			node_4_1: begin next_state = node_4_2;  end
			node_4_2: begin next_state = node_4_3;  end
			node_4_3: begin	next_state = node_4_4;  end
			node_4_4: begin	next_state = store;  end
			store: begin next_state = node_1_1; end
			
			default:  begin	next_state = node_1_1; 	end
		endcase
	end
	
	always @ (posedge clock)
	begin
		if(reset == 0) 
		begin 
			//u_2_mid_store = u_hit_mid;	// init mid array
			u_2_mid_temp = u_hit_mid[0][0];
			u_1_right = 0;
			u_1_left = 0; 
			u_1_up = 0;	
			u_1_down = 0; 
			//u_hit_mid_temp = u_hit_mid[0][0];

			// load initial value into u_1 and u_0
			u_0_mid_load = u_hit_mid;
			u_1_mid_load = u_hit_mid;
	
			flag = 0;  
		end
		else 
		begin
			case(next_state)
				// first row
				/*
					* * * *
					o o o o
					o o o o
					o o o o
				*/
				node_1_1: begin	
							    	//u_2_mid_store[0][0] = u_2_mid_temp;	
								//u_hit_mid_temp = u_hit_mid[0][0];
								
								u_0_node = u_0_mid_load[0][0];
								u_1_node = u_1_mid_load[0][0];
								u_1_right = u_2_mid_store[0][1];
								u_1_left = u_1_left_1; 
								u_1_up = u_1_up_1;	
								u_1_down = u_2_mid_store[1][0];
										
								u_2_mid_load[0][0] = u_2_mid_temp;
								flag = 0;  
						  end
				node_1_2: begin 
								//u_2_mid_store[0][1] = u_2_mid_temp;
								//u_hit_mid_temp = u_hit_mid[0][1];
		
								u_0_node = u_0_mid_load[0][1];
								u_1_node = u_1_mid_load[0][1];
								u_1_right = u_2_mid_store[0][2];
								u_1_left = u_2_mid_store[0][0]; 
								u_1_up = u_1_up_2;	
								u_1_down = u_2_mid_store[1][1];
				
								u_2_mid_load[0][1] = u_2_mid_temp;
								flag = 0;  
						  end
				node_1_3: begin 
								//u_2_mid_store[0][2] = u_2_mid_temp;
								//u_hit_mid_temp = u_hit_mid[0][2];

								u_0_node = u_0_mid_load[0][2];
								u_1_node = u_1_mid_load[0][2];			
								u_1_right = u_2_mid_store[0][3];
								u_1_left = u_2_mid_store[0][1]; 
								u_1_up = u_1_up_3;	
								u_1_down = u_2_mid_store[1][2];

								flag = 0;  
						  end
				node_1_4: begin	
								//u_2_mid_store[0][3] = u_2_mid_temp;
								//u_hit_mid_temp = u_hit_mid[0][3];
								
								u_0_node = u_0_mid_load[0][3];
								u_1_node = u_1_mid_load[0][3];
								u_1_right = u_1_right_1;
								u_1_left = u_2_mid_store[0][2]; 
								u_1_up = u_1_up_4;	
								u_1_down = u_2_mid_store[1][3];

								flag = 0;  
						  end
				// second row
				/*
					o o o o
					* * * *
					o o o o
					o o o o
				*/
				node_2_1: begin 
								u_2_mid_store[1][0] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[1][0];
								u_1_right = u_2_mid_store[1][1];
								u_1_left = u_1_left_2; 
								u_1_up = u_2_mid_store[0][0];	
								u_1_down = u_2_mid_store[2][0];
																flag <= 0;  
						  end
				node_2_2: begin 
								u_2_mid_store[1][1] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[1][1];
								u_1_right = u_2_mid_store[1][2]; 
								u_1_left = u_2_mid_store[1][0]; 
								u_1_up = u_2_mid_store[0][1];	
								u_1_down = u_2_mid_store[2][1];
								
								flag = 0;  
						  end
				node_2_3: begin	
								u_2_mid_store[1][2] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[1][2];
								u_1_right = u_2_mid_store[1][3];
								u_1_left = u_2_mid_store[1][1]; 
								u_1_up = u_2_mid_store[0][2];	
								u_1_down = u_2_mid_store[2][2];
								flag = 0;
																flag <= 0;  
						  end
				node_2_4: begin	
								u_2_mid_store[1][3] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[1][3];
								u_1_right = u_1_right_2;
								u_1_left = u_2_mid_store[1][2]; 
								u_1_up = u_2_mid_store[0][3];	
								u_1_down = u_2_mid_store[2][3];
								
								flag = 0;  
						  end
			    // third row
				/*
					o o o o
					o o o o
					* * * *
					o o o o
				*/
				node_3_1: begin 
								u_2_mid_store[2][0] = u_2_mid_temp; 
								u_hit_mid_temp = u_hit_mid[2][0];
								u_1_right = u_2_mid_store[2][1];
								u_1_left = u_1_left_3; 
								u_1_up = u_2_mid_store[1][0];	
								u_1_down = u_2_mid_store[3][0];
								
								flag = 0;  
						  end
				node_3_2: begin 
								u_2_mid_store[2][1] = u_2_mid_temp;  
								u_hit_mid_temp = u_hit_mid[2][1];  
								u_1_right = u_2_mid_store[2][2];
								u_1_left = u_2_mid_store[2][0]; 
								u_1_up = u_2_mid_store[1][1];	
								u_1_down = u_2_mid_store[3][1];
								  
								flag = 0;  
						  end
				node_3_3: begin 
								u_2_mid_store[2][2] = u_2_mid_temp; 
								u_hit_mid_temp = u_hit_mid[2][2]; 
								u_1_right = u_2_mid_store[2][3];
								u_1_left = u_2_mid_store[2][1]; 
								u_1_up = u_2_mid_store[1][2];	
								u_1_down = u_2_mid_store[3][2];
								
								flag = 0;    
						  end
				node_3_4: begin	
								u_2_mid_store[2][3] = u_2_mid_temp;  
								u_hit_mid_temp = u_hit_mid[2][3]; 
								u_1_right = u_1_right_3;
								u_1_left = u_2_mid_store[2][2]; 
								u_1_up = u_2_mid_store[1][3];	
								u_1_down = u_2_mid_store[3][3];
								
								flag = 0;  
						end
			    // fourth row
				/*
					o o o o
					o o o o
					o o o o
					* * * *
				*/
				node_4_1: begin	
								u_2_mid_store[3][0] = u_2_mid_temp;  
								u_hit_mid_temp = u_hit_mid[3][0];
								u_1_right = u_2_mid_store[3][1];
								u_1_left = u_1_left_4; 
								u_1_up = u_2_mid_store[2][0];	
								u_1_down = u_1_down_1;
								
								flag = 0;     
						  end
				node_4_2: begin 
								u_2_mid_store[3][1] = u_2_mid_temp;  
								u_hit_mid_temp <= u_hit_mid[3][1];
								u_1_right = u_2_mid_store[3][2];
								u_1_left = u_2_mid_store[3][0]; 
								u_1_up = u_2_mid_store[2][1];	
								u_1_down = u_1_down_2;
								
								flag = 0;  
						  end
				node_4_3: begin 
								u_2_mid_store[3][2] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[3][2];
								u_1_right = u_2_mid_store[3][3];
								u_1_left = u_2_mid_store[3][1]; 
								u_1_up = u_2_mid_store[2][2];	
								u_1_down = u_1_down_3;
								   
								flag = 0; 
						  end
				node_4_4: begin	
								u_2_mid_store[3][3] = u_2_mid_temp;
								u_hit_mid_temp = u_hit_mid[3][3];
								u_1_right = u_1_right_4;
								u_1_left = u_2_mid_store[3][2]; 
								u_1_up = u_2_mid_store[2][3];	
								u_1_down = u_1_down_4;
								  
								flag = 1;
						  end
				default:  begin 
								u_2_mid_store[0][0] = u_2_mid_temp; 
								u_hit_mid_temp = u_hit_mid[0][0];
								u_1_right = u_2_mid_store[0][1];
								u_1_left = u_1_left_1; 
								u_1_up = u_1_up_1;	
								u_1_down = u_2_mid_store[1][0];		 
								
								flag = 0;
						  end
			endcase
		end
	end

	always @ (posedge clock)
	begin 
		if (flag == 1)
		begin
			u_2_mid = u_2_mid_store;
			flag = 1;
		end
	end
	//assign u_2_mid = u_2_mid_store;
	assign iterFlag = flag;

	OneNode recycleNode(.u_2_mid(u_2_mid_temp),
			    //.clock(clock),
		       	    //.reset(reset),
	                    //.u_hit_mid(u_hit_mid_temp),
			    .u_1_mid(u_1_node),
			    .u_0_mid(u_0_node),
	                    .u_1_right(u_1_right),
	                    .u_1_left(u_1_left),
	                    .u_1_up(u_1_up),
	       	            .u_1_down(u_1_down),
			    .rho(rho));


endmodule
