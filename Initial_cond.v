module Initial_cond
#(parameter SIZE = 10)
(output signed [17:0] hit[SIZE-1:0][SIZE-1:0]);

integer middle = SIZE / 2, i, j;
parameter [17:0] eta = (999<<17)/1000;

for (i = 0; i < SIZE - 1; i++) begin
	for(j = 0; j < SIZE - 1; j++) begin
		hit[i][j] = 