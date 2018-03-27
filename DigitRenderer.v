/*
This module renders a score from 0 to 999.
	* draw_en must be enabled during the drawing process. When draw_en is low, data is reset.
	* ld_en must be enabled to load the users score into the module.
	* When done rendering, the done flag will be set to high.
*/
module DigitRenderer(
	input clk, resetn, draw_en, ld_en, pause,
	input [9:0] score,
	output reg done, cur_bit,
	output reg [5:0] offset,
	output reg [1:0] digit_offset
);

reg [9:0] number;			// register holding the score
reg [1:0] num_digits;	// number of digits in the decimal representation of the score
reg [3:0] dlu_select;	// the current decimal digit being rendered
wire [63:0] bitarray;

wire [9:0] ones_col, tens_col, hundreds_col;
assign ones_col = number % 10'd10;
assign tens_col = (number / 10'd10) % 10'd10;
assign hundreds_col = (number / 10'd100) % 10'd10;

DigitLookupUnit dlu(
	.select(dlu_select),
	.bitarray(bitarray)
);

// Determine number of digits to be rendered, and the current digit being rendered
always @(*)
begin
	if (number > 10'd99) begin
		num_digits <= 2'd2;
	end
	else if (number > 10'd9) begin
		num_digits <= 2'd1;
	end
	else begin
		num_digits <= 2'd0;
	end
	
	// 1's col
	if (num_digits - digit_offset == 2'b0) begin
		dlu_select <= ones_col[3:0];
	end
	// 10's col
	else if (num_digits - digit_offset == 2'b1) begin
		dlu_select <= tens_col[3:0];
	end
	// 100's col
	else begin
		dlu_select <= hundreds_col[3:0];
	end
end


always @(posedge clk)
begin
	if (!resetn) begin
		done <= 1'd0;
		cur_bit <= 1'd0;
		offset <= 6'd0;
		digit_offset <= 2'd0;
		number <= 10'd0;
	end
	else begin
		if (ld_en) begin
			number <= score;
		end
		if (draw_en) begin
			if(!pause) begin
				if (offset == 6'd0 && digit_offset > num_digits) begin
					done <= 1'b1;
					digit_offset <= 2'd0;
				end
				else begin
					cur_bit <= bitarray[offset];
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
			cur_bit <= 1'd0;
			offset <= 6'd0;
		end
	end
end

endmodule 

module DigitLookupUnit(select, bitarray);
	input [3:0] select;
	output [63:0] bitarray;
	reg [63:0] q;
	
	always @(*)
	begin
		case(select[3:0])
			4'd0: q = 64'b0001100000100100010000100100001001000010010000100010010000011000; 	
			4'd1: q = 64'b0111111000011000000110000001100000011000011110000011100000011000; 
			4'd2: q = 64'b0111111001000010010000000011000000001100000000100100001000111100;
			4'd3: q = 64'b0111111001000010000000100000111000001110000000100100001001111110; 
			4'd4: q = 64'b0000001000000010000000100011111001000010010000100100001001000010; 
			4'd5: q = 64'b0011110001000010000000100000111001110000010000000100001001111110; 
			4'd6: q = 64'b0011110001000010010000100111110001000000010000000100001000111100;
			4'd7: q = 64'b0110000001100000001100000001100000001100000001100100001001111110; 
			4'd8: q = 64'b0011110001000010010000100100001000111100010000100100001000111100; 
			4'd9: q = 64'b0000001000000010000000100011111001000010010000100100001000111100; 
			default: q = 64'b0001100000100100010000100100001001000010010000100010010000011000; 	
		endcase
	end
	
	assign bitarray = q;
endmodule 