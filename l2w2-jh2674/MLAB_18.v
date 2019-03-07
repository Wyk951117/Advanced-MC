module MLAB_18(
 output reg signed [17:0] out,   // 18 bits output if read from mem
 input signed [17:0] data,   // 18 bits input if write to mem
 input [3:0] address,        // offset in terms of the position in a patch
 input [1:0] patch_index,    // offset indicating which patch is currently dealing with
 input we, clk               // write enable and clock
);

	parameter patch_size = 16;   // size of each patch
	(* ramstyle = "MLAB, no_rw_check" *)reg [17:0] mem [47:0];       // a huge patch contains all three patches of u0/u1/u2


	always @ (posedge clk) begin
		if (we) begin    // if write enable, write input data to mem at certain address
			mem[patch_index * patch_size + address] <= data;
		end              // otherwise, read mem at certain address to output
		out <= mem[patch_index * patch_size + address];
	end

endmodule
		
