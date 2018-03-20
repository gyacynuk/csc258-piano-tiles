/*
*** IMPORTANT ***
scale must be either 1, 2, 4 or 8, and the signal must be held constant!

This module scales a pixel input by a constant value.
*/
module Scaler(
	input clk, draw_en,
	input [3:0] scale,
	output reg done,
	output reg [5:0] offset 
);

wire [7:0] max_offset;
assign max_offset = {3'b000, scale} * {3'b000, scale} - 1'b1;

always @(posedge clk) begin
	if (draw_en) begin
		if (offset == max_offset[5:0]) begin
			done = 1'b1;
		end
		else begin 
			offset <= offset + 1'b1;
		end
	end
	else begin
		done <= 1'b0;
		offset <= 6'd0;
	end
end

endmodule 

/*
This module renders a score from 0 to 999.
	* draw_en must be enabled during the drawing process. When draw_en is low, data is reset.
	* ld_en must be enabled to load the users score into the module.
	* When done rendering, the done flag will be set to high.
*/
module DigitRenderer(
	input clk, draw_en, ld_en, pause,
	input [9:0] score,
	output reg done,
	output reg [5:0] offset,
	output reg [1:0] digit_offset,
	output [63:0] bitarray
);

reg [9:0] number;			// register holding the score
reg [1:0] num_digits;	// number of digits in the decimal representation of the score
reg [3:0] dlu_select;	// the current decimal digit being rendered

DigitLookupUnit dlu(
	.select(dlu_select),
	.bitarray(bitarray)
);

// Determine number of digits to be rendered, and the current digit being rendered
always @(*)
begin
	if (number > 10'd99) begin
		num_digits = 2'd2;
	end
	else if (number > 10'd9) begin
		num_digits = 2'd1;
	end
	else begin
		num_digits = 2'd0;
	end
	
	if (num_digits - digit_offset == 2'b0) begin
		dlu_select = number % 10'd10;
	end
	else if (num_digits - digit_offset == 2'b1) begin
		dlu_select = (number / 10'd10) % 10'd10;
	end
	else begin
		dlu_select = (number / 10'd100) % 10'd10;
	end
end


always @(posedge clk)
begin
	if (ld_en) begin
		number <= score;
	end
	if (draw_en) begin
		if(!pause) begin
			if (offset == 6'd0 && digit_offset > num_digits) begin
				done <= 1'b1;
			end
			else begin
				if (offset == 6'd63) begin
					offset <= 6'd0;
					digit_offset <= digit_offset + 1'b1;
				end
				else begin
					offset <= offset + 1'b1;
				end
			end
		end
	end
	else begin
		done <= 1'd0;
		offset <= 6'd0;
		digit_offset <= 2'd0;
		number <= 10'd0;
	end
end

endmodule 

module DigitLookupUnit(select, bitarray);
	input [2:0] select;
	output [63:0] bitarray;
	reg [63:0] q;
	
	always @(*)
	begin
		case(select[2:0])
			3'd0: q = 64'b0001100000100100010000100100001001000010010000100010010000011000; 	
			3'd1: q = 64'b0001100000111000011110000001100000011000000110000001100001111110; 	
			3'd2: q = 64'b0011110001000010000000100000110000110000010000000100001001111110; 	
			3'd3: q = 64'b0111111001000010000000100000111000001110000000100100001001111110; 	
			3'd4: q = 64'b0100001001000010010000100100001000111110000000100000001000000010; 	
			3'b5: q = 64'b0111111001000010010000000111000000001110000000100100001000111100; 	
			3'b6: q = 64'b0011110001000010010000000100000001111100010000100100001000111100; 	
			3'b7: q = 64'b0111111001000010000001100000110000011000001100000110000001100000;  
			3'b8: q = 64'b0011110001000010010000100011110001000010010000100100001000111100; 
			3'b9: q = 64'b0011110001000010010000100100001000111110000000100000001000000010; 
			default: q = 64'b0001100000100100010000100100001001000010010000100010010000011000; 	
		endcase
	end
	
	assign bitarray = q;
endmodule 