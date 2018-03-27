module SongLookupUnit (
	input clk, resetn,
	input [3:0] key_pressed,
	output reg [123:0] song			// 4 bits per row of keys (one-hot vectors)
);

	wire [123:0] mary_had_a_little_lamb;
	assign mary_had_a_little_lamb = 124'b
		0010
		0100
		1000
		0100
		0010
		0010
		0010
		0100
		0100
		0100
		0010
		0001
		0001
		0010
		0100
		1000
		0100
		0010
		0010
		0010
		0010
		0100
		0100
		0010
		0100
		1000
		0000
		0000
		0000
		0000
		0000;
		
		always @(posedge clk) begin
			if (!resetn)  begin
				song <= mary_had_a_little_lamb;
			end
			else if (key_pressed == 4'b0010) begin	// key 1
				song <= mary_had_a_little_lamb;
			end
			else if (key_pressed == 4'b0100) begin	// key 2
				song <= mary_had_a_little_lamb;	// Replace with song 2 (medium)
			end
			else if (key_pressed == 4'b1000) begin	// key 3
				song <= mary_had_a_little_lamb; // Replace with song 3 (hard)
			end
		end
	
endmodule 