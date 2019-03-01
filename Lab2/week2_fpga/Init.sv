module Init
#(parameter SIZE = 10)
(input clock,
 input reset,
 output signed [17:0] hit[SIZE-1:0][SIZE-1:0]);

integer middle = SIZE / 2, i, j, divider;
parameter [17:0] mid = 18'h2e53;


always @ (posedge clock) begin
// initialize the state of the drum if reset
if (reset) begin

	for (i = 0; i < SIZE - 1; i = i + 1) begin
		for (j = 0; j < SIZE - 1; j = j + 1) begin
			divider = (i + j) >> 1 - middle;
			hit[i][j] = mid / divider;
		end
	end
end
end // end always posedge clock

endmodule

/*
// row 1
assign hit[0][0] = 18'h58;
assign hit[0][1] = 18'hd9;
assign hit[0][2] = 18'h1b5;
assign hit[0][3] = 18'h2d1;
assign hit[0][4] = 18'h3cd;
assign hit[0][5] = 18'h433;
assign hit[0][6] = 18'h3cd;
assign hit[0][7] = 18'h2d1;
assign hit[0][8] = 18'h1b5;
assign hit[0][9] = 18'hd9;

// row 2
assign hit[0][0] = 18'h58;
assign hit[0][2] = 18'h1b5;
assign hit[0][1] = 18'hd9;
assign hit[0][3] = 18'h58;
assign hit[0][4] = 18'hd9;
assign hit[0][5] = 18'h58;
assign hit[0][6] = 18'hd9;
assign hit[0][7] = 18'h58;
assign hit[0][8] = 18'hd9;
assign hit[0][9] = 18'h58;

// row 3
assign hit[0][0] = 18'h58;
assign hit[0][1] = 18'hd9;
assign hit[0][3] = 18'h58;
assign hit[0][4] = 18'hd9;
assign hit[0][5] = 18'h58;
assign hit[0][6] = 18'hd9;
assign hit[0][7] = 18'h58;
assign hit[0][8] = 18'hd9;
assign hit[0][9] = 18'h58;

assign hit[0][0] = 18'h58;
assign hit[0][1] = 18'hd9;
assign hit[0][3] = 18'h58;
assign hit[0][4] = 18'hd9;
assign hit[0][5] = 18'h58;
assign hit[0][6] = 18'hd9;
assign hit[0][7] = 18'h58;
assign hit[0][8] = 18'hd9;
assign hit[0][9] = 18'h58;

assign hit[0][0] = 18'h58;
assign hit[0][1] = 18'hd9;
assign hit[0][3] = 18'h58;
assign hit[0][4] = 18'hd9;
assign hit[0][5] = 18'h58;
assign hit[0][6] = 18'hd9;
assign hit[0][7] = 18'h58;
assign hit[0][8] = 18'hd9;
assign hit[0][9] = 18'h58;
*/