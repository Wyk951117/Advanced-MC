module fourByFourNodePatch	// 4*4 patch
(output reg signed [17:0] u_2_mid, 			        // output
 output iterFlag,									// 
 input middle,                                      // a flag indicating whether current patch is at middle
 input clock,										// clock
 input reset,		       							// reset
 input signed [17:0] u_hit_mid[15:0],			// init hit in the middle
 input signed [17:0] u_right_input,  				// input from right node output
 input signed [17:0] u_left_input,    				// input from left node output
 input signed [17:0] u_up_input,    				// input from up node output
 input signed [17:0] u_down_input,    				// input from down node ouput
 input signed [17:0] rho,
 input enable
);
	reg signed [17:0] u_2_node_out;
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
	reg [4:0] current_node, next_node;
	
	
	parameter load_u0 = 4'h0;
	parameter load_u1 = 4'h1;
	parameter load_up = 4'h2;
	parameter load_downown = 4'h3;
	parameter load_right = 4'h4;
	parameter load_left = 4'h5;
	parameter write_u2 = 4'h6;
	parameter output_right = 4'h7;
	parameter output_left = 4'h8;
	parameter output_up = 4'h9;
	parameter output_down = 4'hA;
	parameter finish = 4'hB;
	reg [3:0] sub_state;
	
	
	reg [3:0] cur_address;
	reg [3:0] ram_address;
	reg [1:0] ram_index;
	reg ram_we;
	reg signed [17:0] data_out;
	reg signed [17:0] data_in;
	
	always @ (posedge clock)
	begin
		if (reset == 0) begin current_node <= idle;      end					
		else            begin current_node <= next_node; end		
	end

	always @ (current_node)
	begin
		case(current_node)
			// first row
			idle: begin next_node = node_1_1; end
			node_1_1: begin	next_node = node_1_2;	end
			node_1_2: begin	next_node = node_1_3;  end
			node_1_3: begin	next_node = node_1_4;  end
			node_1_4: begin	next_node = node_2_1;	end
			// second row
			node_2_1: begin	next_node = node_2_2;  end
			node_2_2: begin	next_node = node_2_3;  end
			node_2_3: begin	next_node = node_2_4;  end
			node_2_4: begin	next_node = node_3_1;  end
			// third row
			node_3_1: begin	next_node = node_3_2;  end
			node_3_2: begin	next_node = node_3_3;	end
			node_3_3: begin	next_node = node_3_4;  end
			node_3_4: begin	next_node = node_4_1;	end
			// fourth row
			node_4_1: begin next_node = node_4_2;  end
			node_4_2: begin next_node = node_4_3;  end
			node_4_3: begin	next_node = node_4_4;  end
			node_4_4: begin	next_node = store;  end
			store: begin next_node = node_1_1; end
			
			default:  begin	next_node = node_1_1; 	end
		endcase
	end
	
	always @ (posedge clock)
	begin
		if(reset == 0) 
		begin 
			u_2_mid_store = u_hit_mid;	// init mid array
			u_2_node_out = u_hit_mid[0][1];
			u_1_right = 0;
			u_1_left = 0; 
			u_1_up = 0;	
			u_1_down = 0; 

			// load initial value into u_1 and u_0
			for(i = 0; i < 4; i++) begin
				for(j = 0; j < 4; j++) begin
					u_0_mid_load[i][j] = 0;
				end
			end
			u_1_mid_load = u_hit_mid;
			u_2_mid_load = u_hit_mid;
	
			flag = 0;  
		end
		else 
		begin
			case(next_node)
				// first row
				/*
					* * * *
					o o o o
					o o o o
					o o o o
				*/
				node_1_1: begin	cur_address = 4'd0;
						case(sub_state)
							load_u0: begin                                
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								sub_state <= load_u1;
								flag <= 0;
							end
							load_u1: begin
								u_0_node <= data_out;// read 0 from mem 
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation            
								sub_state <= load_right;
								flag <= 0;
							end
							load_right: begin
								u_1_node <= data_out; // read 1 from mem  
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;								                  
								sub_state <= output_right;
								flag <= 0;
							end
							
							output_right: begin   
								u_1_right <= data_out;  
								ram_address <= cur_address + 3;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_left;
								flag <= 0;
							end
							load_left: begin
								u_2_mid <= data_out;
								u_1_left <= u_left_input;
								sub_state <= output_down;
								flag <= 0;
							end
							
							output_down: begin
								ram_address <= cur_address + 12;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_up;
								flag <= 0;
							end
							load_up: begin
								u_2_mid <= data_out; 
								u_1_up <= u_1_up_1;
								sub_state <= load_down;
								flag <= 0;
							end
							
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								sub_state <= finish;
								flag <= 0;
							end
							finish: begin
								u_1_down <= data_out;
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
				node_1_2: begin cur_address = 4'd1;
						case(sub_state):
							write_u2: begin 
								ram_address <= cur_address - 1;    // writing the node before
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;                        //    used to be u_2_mid_load[0][0] = u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
								ram_index <= 2'd0;
								ram_we <= 0;
								u_0_node <= data_out;                            // used to be u_0_node = u_0_mid_load[0][1];
								sub_state <= wait_0;
								end	
							wait_0: begin	
								sub_state <= load_up1;
								end
							load_up1: begin
								ram_address <= cur_address;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_node <= data_out;                            // used to be u_1_node = u_1_mid_load[0][1];
								sub_state <= wait_1;
								end
							wait_1: begin
								sub_state <= load_right;
								end
							load_right: begin
								ram_address <= cur_address + 1;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                            // used to be u_1_right = u_2_mid_store[0][2];
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                              // used to be u_1_left = u_2_mid_store[0][0]; 
								sub_state <= wait_L;
								end
							wait_L: begin
								sub_state <= load_up;
								end
							load_up: begin
								// read from register
								u_1_up <= u_1_up_2;	
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_down <= data_out;                               // used to be u_1_down = u_2_mid_store[1][1];
								sub_state <= write_u2;
								flag <= 0;
								end 
						  end
				node_1_3: begin cur_address = 4'd2;
						case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
								ram_index <= 2'd0;
								ram_we <= 0;
								u_0_node <= data_out;
								sub_state <= wait_0;
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								ram_address <= cur_address;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_node <= data_out;
								sub_state <= wait_1;
								end
							wait_1: begin
								sub_state <= load_right;
								end
							load_right: begin
								ram_address <= cur_address + 1;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;
								sub_state <= wait_L;
								end
							wait_L: begin
								sub_state <= load_up;
								end
							load_up: begin
								u_1_up <= u_1_up_3;
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_down <= data_out;
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
				node_1_4: begin	cur_address = 4'd3;
						case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;		// write output of node_1_3
								sub_state <= load_u0;
							end			
							load_u0: begin
								ram_address <= cur_address;
								ram_index <= 2'd0;
								ram_we <= 0;
								sub_state <= load_u1;
								end
							load_u1: begin
								u_0_node <= data_out;			// read u0
								
								ram_address <= cur_address;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= output_left;
								end
							
							output_left: begin
								u_1_node <= data_out;			// read u1
								ram_address <= cur_address - 3;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_right;
							end
							load_right: begin
								u_2_mid <= data_out;			// output to the node_1_1
								u_1_right <= u_right_input;		// read from INPUT(u_right_input)
								sub_state <= load_left;
							end
								
							load_left: begin
								ram_address <= cur_address - 1;	
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= output_down;
								end
								
							output_down: begin
								u_1_left <= data_out;			// read left node 
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_up;
							end
							load_up: begin
								u_2_mid <= data_out; 			// output node_4_4
								u_1_up <= u_up_input;			// read from INPUT(u_up_input)
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= finish;						
								end
							finish: begin
								u_1_down <= data_out;			// read down node
								sub_state <= write_u2;
								flag <= 0;						// finish reading all inputs
							end
						  end
				// second row
				/*
					o o o o
					* * * *
					o o o o
					o o o o
				*/
				node_2_1: begin cur_address = 4'd4;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								// read right from register
								u_1_left <= u_1_left_2;
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
				node_2_2: begin cur_address = 4'd5;								 
								case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
				node_2_3: begin	cur_address  = 4'd6;
								case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end								
						  end
				node_2_4: begin	cur_address = 4'd7; 	
								case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								u_1_right <= u_1_right_2;                  
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
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
				node_3_1: begin cur_address = 4'd8;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								// read right from register
								u_1_left <= u_1_left_3;
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
				node_3_2: begin cur_address = 4'd9;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
						  end
				node_3_3: begin cur_address = 4'd10;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								// read left from mem
								ram_address <= cur_address + 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_right <= data_out;                    
								sub_state <= wait_R;
								end
							wait_R: begin
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end
						  end
						  end
				node_3_4: begin	cur_address = 4'd11;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;
								sub_state <= load_up0;
								end
							load_up0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    // processing on patch 0
								ram_we <= 0;          // read operation
								u_0_node <= data_out;                          
								sub_state <= wait_0;    // state transfer
								end
							wait_0: begin
								sub_state <= load_up1;
								end
							load_up1: begin
								// read 1 from mem
								ram_address <= cur_address;
								ram_index <= 2'd1;     // processing on patch 1
								ram_we <= 0;           // read operation
								u_1_node <= data_out;                          
								sub_state <= wait_1;
								end
							wait_1: begin
								// wait for the second cycle of read
								sub_state <= load_right;
								end
							load_right: begin
								u_1_right <= u_1_right_3;                  
								sub_state <= load_left;
								end
							load_left: begin
								ram_address <= cur_address - 1;   // dealing with the node to the right
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_left <= data_out;                    
								sub_state <= wait_L;
								end
							wait_L: begin	
								sub_state <= load_up;
								end
							load_up: begin
								ram_address <= cur_address - 4;   // dealing with the node above
								ram_index <= 2'd1;
								ram_we <= 0;
								u_1_up <= data_out;
								sub_state <= wait_U;
								end
							wait_U: begin
								sub_state <= load_down;
								end
							load_down: begin
								ram_address <= cur_address + 4;   // dealing with the node below
								ram_index <= 2'd1;
								ram_we <= 0;	
								u_1_down <= data_out;                            
								sub_state <= wait_D;
								end
							wait_D: begin
								sub_state <= write_u2;
								flag <= 0;
								end	
								u_1_left = u_2_mid_store[2][2]; 
								u_1_up = u_2_mid_store[1][3];	
								u_1_down = u_2_mid_store[3][3];
																
								u_2_mid_load[2][3] = u_2_node_out;
								flag = 0;  
						end
			    // fourth row
				/*
					o o o o
					o o o o
					o o o o
					* * * *
				*/
				node_4_1: begin	cur_address = 4'd12;
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
									data_in <= u_2_node_out;	// write output
								sub_state <= load_u0;
								end
							load_u0: begin
								ram_address <= cur_address;
                                ram_index <= 2'd0;    
								ram_we <= 0;          
								                     
								sub_state <= load_u1;
								end
							load_u1: begin
							u_0_node <= data_out;     			// read u0
								ram_address <= cur_address;
								ram_index <= 2'd1;     
								ram_we <= 0;           
								                         
								sub_state <= load_right;
								end
							load_right: begin
								u_1_node <= data_out; 			// read u1
								ram_address <= cur_address + 1;   
								ram_index <= 2'd1;
								ram_we <= 0;								                  
								sub_state <= output_right;
								end
								
							output_right: begin
								u_1_right <= data_out; 			// read right node
								ram_address <= cur_address + 3;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_left;
							end
							load_left: begin
								u_2_mid <= data_out;			// output node_4_4
								u_1_left <= u_left_input;		// read from INPUT(u_left_input)
								sub_state <= load_up;
							end
							
							load_up: begin
								ram_address <= cur_address - 4;  
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= output_up;
							end
							
							output_up: begin
								u_1_up <= data_out;				// read up node
								ram_address <= cur_address - 12;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_down;
							end
							load_down: begin
								u_2_mid <= data_out;			// output node_1_1
								u_1_down <= u_down_input;     	// read down node
								sub_state <= finish;
							end
							
							finish: begin		
								sub_state <= write_u2;
								flag <= 0;
							end								
						  end
				node_4_2: begin 
								//u_2_mid_store[3][1] = u_2_node_out;  
								//u_hit_mid_temp <= u_hit_mid[3][1];
								u_2_mid_load[3][0] = u_2_node_out;
								u_0_node = u_0_mid_load[3][1];
								u_1_node = u_1_mid_load[3][1];
								u_1_right = u_2_mid_store[3][2];
								u_1_left = u_2_mid_store[3][0]; 
								u_1_up = u_2_mid_store[2][1];	
								u_1_down = u_1_down_2;
																								
								u_2_mid_load[3][1] = u_2_node_out;
								flag = 0;  
						  end
				node_4_3: begin 
								//u_2_mid_store[3][2] = u_2_node_out;
								//u_hit_mid_temp = u_hit_mid[3][2];
								u_2_mid_load[3][1] = u_2_node_out;
								u_0_node = u_0_mid_load[3][2];
								u_1_node = u_1_mid_load[3][2];
								u_1_right = u_2_mid_store[3][3];
								u_1_left = u_2_mid_store[3][1]; 
								u_1_up = u_2_mid_store[2][2];	
								u_1_down = u_1_down_3;
								   																
								u_2_mid_load[3][2] = u_2_node_out;
								flag = 0; 
						  end
				node_4_4: begin	cur_address = 4'd15
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;		// write output of node_4_3
								sub_state <= load_u0;
							end			
							load_u0: begin
								ram_address <= cur_address;
								ram_index <= 2'd0;
								ram_we <= 0;
								sub_state <= load_u1;
								end
							load_u1: begin
								u_0_node <= data_out;			// read u0
								ram_address <= cur_address;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= output_left;
								end
							
							output_left: begin
								u_1_node <= data_out;			// read u1
								ram_address <= cur_address - 3;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_right;
							end
							load_right: begin
								u_2_mid <= data_out;			// output to the node_4_1
								u_1_right <= u_right_input;		// read from INPUT(u_right_input)
								sub_state <= load_left;
							end
								
							load_left: begin
								ram_address <= cur_address - 1;	
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= output_up;
								end
								
							output_up: begin
								u_1_left <= data_out;			// read left node 
								ram_address <= cur_address - 12;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= load_down;
							end
							load_down: begin
								u_2_mid <= data_out; 			// output node_4_4
								u_1_down <= u_down_input;		// read from INPUT(u_up_input)
								sub_state <= load_up;
							end
								
							load_up: begin
								ram_address <= cur_address -4;
								ram_index <= 2'd1;
								ram_we <= 0;
								sub_state <= finish;						
							end
							finish: begin
								u_1_up <= data_out;				// read up node
								sub_state <= write_u2;
								flag <= 0;						// finish reading all inputs
							end		
							endcase							
						  end
				store: begin
							case(sub_state):
							write_u2: begin
								ram_address <= cur_address - 1;
								ram_index <= 2'd2;
								ram_we <= 1;
								data_in <= u_2_node_out;		// write output
								sub_state <= load_u0;
								flag <= 1;						// finish calculation for one patch
							end			
							endcase
						  end
				default:  begin 
								u_1_node <= 1; 
								u_0_node <= 2;
								u_1_right <= 3;
								u_1_left <= 4; 
								u_1_up <= 5;	
								u_1_down <= 6;		 
								flag <= 0;
						  end
			endcase
		end
	end

	always @ (posedge clock)
	begin 
		if (flag == 1)
		begin
			u_2_mid = u_2_mid_load;
			flag = 0;
		end
	end

	assign iterFlag = flag;

	OneNode recycleNode(.u_2_mid(u_2_node_out),
						.u_1_mid(u_1_node),
						.u_0_mid(u_0_node),
	                    .u_1_right(u_1_right),
	                    .u_1_left(u_1_left),
	                    .u_1_up(u_1_up),
	       	            .u_1_down(u_1_down),
			    .rho(rho));

	MLAB_18 ram(.out(data_out),        // 18 bits
				.data(data_in),      // 18 bits
                .address(ram_address),// 4 bits
				.patch_index(ram_index),//2 bits
                .we(ram_we),
                .clk(clock));

endmodule
