module fourByFourNodePatch	// 4*4 patch
(output reg signed [17:0] u_2_mid[3:0][3:0], 			// output
 output iterFlag,									// 
 input middle,                                      // a flag indicating whether current patch is at middle
 input clock,										// clock
 input reset,		       							// reset
 input signed [17:0] u_hit_mid[3:0][3:0],			// init hit in the middle
 input signed [17:0] u_right_input,  				// input from right node output
 input signed [17:0] u_left_input,    				// input from left node output
 input signed [17:0] u_up_input,    				// input from up node output
 input signed [17:0] u_down_input,    				// input from down node ouput
 input signed [17:0] rho,
 input enable
);
	reg signed [17:0] u_2_mid_temp;
	reg signed [17:0] u_1_right, u_1_left, u_1_up, u_1_down;
	reg signed [17:0] u_hit_mid_temp;
	reg signed [17:0] u_2_mid_store[3:0][3:0];  // store register for output
	reg flag;
        
	integer i, j;
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
			u_2_mid_store = u_hit_mid;	// init mid array
			u_2_mid_temp = u_hit_mid[0][1];
			u_1_right = 0;
			u_1_left = 0; 
			u_1_up = 0;	
			u_1_down = 0; 
			//u_hit_mid_temp = u_hit_mid[0][0];

			// load initial value into u_1 and u_0
			for(i = 0; i < 4; i++) begin
				for(j = 0; j < 4; j++) begin
					u_0_mid_load[i][j] = 0;
				end
			end
			//u_0_mid_load = u_hit_mid * 0; // should be 0000
			u_1_mid_load = u_hit_mid;
			u_2_mid_load = u_hit_mid;
	
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
				node_1_1: begin	cur_address = 3'd0;
						case(sub_state)
							
							load_0: begin
                                                                // read 0 from mem 
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          //  used to be u_0_node = u_0_mid_load[0][0];
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
                                                                // wait for the second cycle of read
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          //  used to be u_1_node = u_1_mid_load[0][0];
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                          //  used to be u_1_right = u_2_mid_store[0][1];
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
							load_L: begin
								// read right from register
								u_1_left <= u_1_left_1;
								sub_state <= load_U;
								end
							load_U: begin
								// read up from register 
								u_1_up <= u_1_up_1;
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            // used to be u_1_down = u_2_mid_store[1][0];
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				node_1_2: begin cur_address = 3'd1;
						case(sub_state):
							write_2: begin 
								state_address <= cur_address - 1;    // writing the node before
								state_index <= 2'2;
								state_we <= 1;
								state_data <= u_2_mid_temp;                        //    used to be u_2_mid_load[0][0] = u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
								state_index <= 2'd0;
								state_we <= 0;
								u_0_node <= state_out;                            // used to be u_0_node = u_0_mid_load[0][1];
								sub_state <= wait_0;
								end	
							wait_0: begin	
								sub_state <= load_1;
								end
							load_1: begin
								state_address <= cur_address;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_node <= state_out;                            // used to be u_1_node = u_1_mid_load[0][1];
								sub_state <= wait_1;
								end
							wait_1: begin
								sub_state <= load_R;
								end
							load_R: begin
								state_address <= cur_address + 1;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                            // used to be u_1_right = u_2_mid_store[0][2];
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                              // used to be u_1_left = u_2_mid_store[0][0]; 
								sub_state <= wait_L;
								end
							wait_L: begin
								sub_state <= load_U;
								end
							load_U: begin
								// read from register
								u_1_up <= u_1_up_2;	
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_down <= state_out;                               // used to be u_1_down = u_2_mid_store[1][1];
								sub_state <= write_2;
								flag <= 0;
								end 
						  end
				node_1_3: begin cur_address = 3'd2;
						case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
								state_index <= 2'd0;
								state_we <= 0;
								u_0_node <= state_out;
								sub_state <= wait_0;
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								state_address <= cur_address;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_node <= state_out;
								sub_state <= wait_1;
								end
							wait_1: begin
								sub_state <= load_R;
								end
							load_R: begin
								state_address <= cur_address + 1;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;
								sub_state <= wait_L;
								end
							wait_L: begin
								sub_state <= load_U;
								end
							load_U: begin
								u_1_up <= u_1_up_3;
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_down <= state_out;
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				node_1_4: begin	cur_address = 3'd3;
						case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
								state_index <= 2'd0;
								state_we <= 0;
								u_0_node <= state_out;
								sub_state <= wait_0;
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								state_address <= cur_address;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_node <= state_out;
								sub_state <= wait_1;
								end
							wait_1: begin
								sub_state <= load_R;
								end
							load_R: begin
								u_1_right = u_1_right_1;
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;
								sub_state <= wait_L;
								end
							wait_L: begin
								sub_state <= load_U;
								end
							load_U: begin
								u_1_up <= u_1_up_3;
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;
								state_index <= 2'd1;
								state_we <= 0;
								u_1_down <= state_out;
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				// second row
				/*
					o o o o
					* * * *
					o o o o
					o o o o
				*/
				node_2_1: begin cur_address = 3'd4;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								// read right from register
								u_1_left <= u_1_left_2;
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				node_2_2: begin cur_address = 3'd5;								 
								case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				node_2_3: begin	cur_address  = 3'd6;
								case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end								
						  end
				node_2_4: begin	cur_address = 3'd7; 	
								case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								u_1_right <= u_1_right_2;                  
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end	
						  end
			    // third row
				/*
					o o o o
					o o o o
					* * * *
					o o o o
				*/
				node_3_1: begin cur_address = 3'd8;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								// read right from register
								u_1_left <= u_1_left_3;
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
				node_3_2: begin cur_address = 3'd9;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
						  end
				node_3_3: begin cur_address = 3'd10;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end
						  end
						  end
				node_3_4: begin	cur_address = 3'd11;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								u_1_right <= u_1_right_3;                  
								sub_state <= load_L;
								end
							load_L: begin
								state_address <= cur_address - 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_left <= state_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								state_address <= cur_address + 4;   // dealing with the node below
								state_index <= 2'd1;
								state_we <= 0;	
								u_1_down <= state_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_2;
								flag <= 0;
								end	
								u_1_left = u_2_mid_store[2][2]; 
								u_1_up = u_2_mid_store[1][3];	
								u_1_down = u_2_mid_store[3][3];
																
								u_2_mid_load[2][3] = u_2_mid_temp;
								flag = 0;  
						end
			    // fourth row
				/*
					o o o o
					o o o o
					o o o o
					* * * *
				*/
				node_4_1: begin	cur_address = 3'd12;
							case(sub_state):
							write_2: begin
								state_address <= cur_address - 1;
								state_index <= 2'd2;
								state_we <= 1;
								state_data <= u_2_mid_temp;
								sub_state <= load_0;
								end
							load_0: begin
								state_address <= cur_address;
                                state_index <= 2'd0;    // processing on patch 0
								state_we <= 0;          // read operation
								u_0_node <= state_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_1;
								end
							load_1: begin
								// read 1 from mem
								state_address <= cur_address;
								state_index <= 2'd1;     // processing on patch 1
								state_we <= 0;           // read operation
								u_1_node <= state_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_R;
								end
							load_R: begin
								// read left from mem
								state_address <= cur_address + 1;   // dealing with the node to the right
								state_index <= 2'd1;
								state_we <= 0;
								u_1_right <= state_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_L;
								end
							load_L: begin
								// read right from register
								u_1_left <= u_1_left_4;
								sub_state <= load_U;
								end
							load_U: begin
								state_address <= cur_address - 4;   // dealing with the node above
								state_index <= 2'd1;
								state_we <= 0;
								u_1_up <= state_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_D;
								end
							load_D: begin
								u_1_down <= u_1_down_1;                            
								sub_state <= write_2;
								flag <= 0;
								end								
						  end
				node_4_2: begin 
								//u_2_mid_store[3][1] = u_2_mid_temp;  
								//u_hit_mid_temp <= u_hit_mid[3][1];
								u_2_mid_load[3][0] = u_2_mid_temp;
								u_0_node = u_0_mid_load[3][1];
								u_1_node = u_1_mid_load[3][1];
								u_1_right = u_2_mid_store[3][2];
								u_1_left = u_2_mid_store[3][0]; 
								u_1_up = u_2_mid_store[2][1];	
								u_1_down = u_1_down_2;
																								
								u_2_mid_load[3][1] = u_2_mid_temp;
								flag = 0;  
						  end
				node_4_3: begin 
								//u_2_mid_store[3][2] = u_2_mid_temp;
								//u_hit_mid_temp = u_hit_mid[3][2];
								u_2_mid_load[3][1] = u_2_mid_temp;
								u_0_node = u_0_mid_load[3][2];
								u_1_node = u_1_mid_load[3][2];
								u_1_right = u_2_mid_store[3][3];
								u_1_left = u_2_mid_store[3][1]; 
								u_1_up = u_2_mid_store[2][2];	
								u_1_down = u_1_down_3;
								   																
								u_2_mid_load[3][2] = u_2_mid_temp;
								flag = 0; 
						  end
				node_4_4: begin	
								//u_2_mid_store[3][3] = u_2_mid_temp;
								//u_hit_mid_temp = u_hit_mid[3][3];
								u_2_mid_load[3][2] = u_2_mid_temp;

								u_0_node = u_0_mid_load[3][3];
								u_1_node = u_1_mid_load[3][3];
								u_1_right = u_1_right_4;
								u_1_left = u_2_mid_store[3][2]; 
								u_1_up = u_2_mid_store[2][3];	
								u_1_down = u_1_down_4;
								  																
								u_2_mid_load[3][3] = u_2_mid_temp;
								flag = 1;
						  end
				store: begin
								u_2_mid_load[3][3] = u_2_mid_temp;
								u_0_mid_load = u_1_mid_load;
								u_1_mid_load = u_2_mid_load;
								u_2_mid_store = u_2_mid_load;
								flag = 0;
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
			//u_2_mid = u_2_mid_store;
			u_2_mid = u_2_mid_load;
			flag = 0;
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

	stateMachine recycleState(.out(state_out),        // 18 bits
				  .data(state_data),      // 18 bits
                                  .address(state_address),// 3 bits
				  .patch_index(state_index),//2 bits
                                  .we(state_we),
                                  .clk(clock));

endmodule
