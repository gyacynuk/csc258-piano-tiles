`include "RenderingEngine.v"
`include "KeyListener.v"
`include "DigitRenderer.v"

module pianotiles(
	input CLOCK_50,
	input [3:0] KEY,
	output [9:0] LEDR,
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
	output [9:0] VGA_R, VGA_G,VGA_B
);

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable,ld_x,ld_y,ld_c;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
		.resetn(KEY[3]),
		.clock(CLOCK_50),
		.colour(colour),
		.x(8'd0 + (8'd8 - offset[2:0]) + digit_offset * 8'd10),
		.y(8'd0 + offset[5:3]),
		.plot(writeEn),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	
	wire cur_bit;
	assign colour = {cur_bit, cur_bit, cur_bit};
	wire [5:0] offset;
	wire [1:0] digit_offset;
	WeekOneTest w1(
		.clk(CLOCK_50),
		.KEY(KEY),
		.draw_en(writeEn),
		.cur_bit(cur_bit),
		.offset(offset),
		.digit_offset(digit_offset),
		.score(LEDR[5:0]),
		.ones(LEDR[9:6])
	);
			

endmodule

module WeekOneTest(
	input clk, 
	input [3:0] KEY,
	output reg draw_en, 
	output cur_bit,
	output [5:0] offset,
	output [1:0] digit_offset,
	output reg [9:0] score,
	output [3:0] ones
);

wire [3:0] key_pressed, key_held, key_released;
wire done;

reg ld_en;

KeyListener kl(
	.clk(clk),
	.resetn(KEY[3]),
	.KEY(KEY),
	.key_pressed(key_pressed),
	.key_held(key_held),
	.key_released(key_released)
);

DigitRenderer(
	.clk(clk),
	.resetn(KEY[3]),
	.draw_en(draw_en),
	.ld_en(ld_en),
	.pause(1'b0),
	.score(score),
	.done(done),
	.cur_bit(cur_bit),
	.offset(offset),
	.digit_offset(digit_offset),
	.ones(ones)
);

// KEY 3 - reset
// KEY 2 - ld_en
// KEY 1 - increase score
// KEY 0 - draw_en
always @(posedge clk) begin
	if (key_pressed[0] == 1'b1) begin
		draw_en <= 1'b1;
	end
	
	if (key_pressed[1] == 1'b1) begin
		score <= score + 1'b1;
	end
	
	if (key_pressed[2] == 1'b1) begin
		ld_en <= 1'b1;
	end
	else begin
		ld_en <= 1'b0;
	end
	
	if (KEY[3] == 1'b0) begin
		score <= 10'd1;
		draw_en <= 1'b0;
		ld_en <= 1'b0;
	end
	
	if (draw_en == 1'b1) begin
		if (done == 1'b1) begin
			draw_en <= 1'b0;
		end
	end
end

endmodule