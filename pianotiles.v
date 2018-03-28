`include "GameStateManager.v"

module pianotiles(
	input CLOCK_50,
	input [3:0] KEY,
	input [9:0] SW,
	output [9:0] LEDR,
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
	output [9:0] VGA_R, VGA_G,VGA_B
);

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [8:0] colour;
	wire [8:0] x;
	wire [8:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
		.resetn(SW[9]),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
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
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	
	GameStateManager gsm(
		.clk(CLOCK_50),
		.resetn(SW[9]),
		.KEY(KEY),
		.x(x),
		.y(y),
		.color(colour),
		.draw_en(writeEn)
	);
endmodule