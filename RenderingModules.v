module ScreenClearer(
	input clk, resetn, drawn_en, 
	input [8:0] width, height,
	output reg [8:0] x, y,
	output reg done
);

	always @(posedge clk) begin
		if (!resetn) begin
			done <= 1'd0;
			x <= 9'd0;
			y <= 9'd0;
		end
		else if (draw_en) begin
			// Cleared entire screen 
			if (x == width && y == height) begin
				done <= 1'd1;
			end
			// Cleared current row
			else if (x == width) begin
				x <= 9'd0;
				y <= y + 1'b1;
			end
			// Keep clearing current row
			else begin
				x <= x + 1'b1;
			end
		end
		else begin
			done <= 1'd0;
			x <= 9'd0;
			y <= 9'd0;
		end
	end

endmodule

module VLineRenderer (
	input clk, draw_en, resetn,
	input [8:0] width, height, spacing, num_lines,
	output reg done,
	output reg [8:0] x, y
);

	reg [8:0] lines_drawn;

	always @(posedge clk) begin
		if (!resetn) begin
			done <= 1'b0;
			lines_drawn <= 9'd0;
			x <= spacing;
			y <= 9'd0;
		end
		else if (draw_en) begin
			// Check if all lines have been drawn
			if (y == 9'd0 && lines_drawn == num_lines) begin
				done <= 1'b1;
			end
			// Check if current line is done being drawn
			else if (y == height) begin
				x <= x + spacing;
				y <= 9'd0;
				lines_drawn <= lines_drawn + 1'b1;
			end
			// Continue drawning current row
			else begin
				y <= y + 1'b1;
			end
		end
		else begin
			done <= 1'b0;
			lines_drawn <= 9'd0;
			x <= spacing;
			y <= 9'd0;
		end
	end
endmodule 

module HLineRenderer (
	input clk, draw_en, resetn,
	input [8:0] width, height, spacing, num_lines,
	output reg done,
	output reg [8:0] x, y
);

	reg [8:0] lines_drawn;

	always @(posedge clk) begin
		if (!resetn) begin
			done <= 1'b0;
			lines_drawn <= 9'd0;
			x <= 9'd0;
			y <= spacing;
		end
		else if (draw_en) begin
			// Check if all lines have been drawn
			if (x == 9'd0 && lines_drawn == num_lines) begin
				done <= 1'b1;
			end
			// Check if current line is done being drawn
			else if (x == width) begin
				y <= y + spacing;
				x <= 9'd0;
				lines_drawn <= lines_drawn + 1'b1;
			end
			// Continue drawning current row
			else begin
				x <= x + 1'b1;
			end
		end
		else begin
			done <= 1'b0;
			lines_drawn <= 9'd0;
			y <= spacing;
			x <= 9'd0;
		end
	end
endmodule

module KeyRenderer (
	input clk, resetn, draw_en,
	input [8:0] width, height,
	input [3:0] key,	// one-hot vector
	output reg done, 
	output reg [8:0] x, y	// y is NOT the actual location, but relative location from 0 (Need to add offset before drawing)
);

	reg [8:0] xoffset;
	always @(key) begin
		case (key)
			4'b0000: xoffset <= 9'd0;
			4'b1000: xoffset <= 9'd0;
			4'b0100: xoffset <= width;
			4'b0010: xoffset <= width * 2;
			4'b0001: xoffset <= width * 3;
			default: xoffset <= 9'd0;
		endcase 
	end

	always @(posedge clk) begin
		if (!resetn) begin
			done <= 1'b0;
			x <= xoffset;
			y <= 9'd0;
		end
		else if (draw_en) begin
			if (key == 4'b0000) begin
				done <= 1'b1;
			end
			else if(x == xoffset + width && y == height) begin
				done <= 1'b1;
			end
			else if (x == xoffset + width) begin
				x <= xoffset;
				y <= y + 1'b1;
			end
			else begin
				x <= x + 1'b1;
			end
		end
		else begin
			done <= 1'b0;
			x <= xoffset;
			y <= 9'd0;;
		end
	end

endmodule 

module HitboxRenderer(
	input clk, resetn, draw_en,
	input [8:0] width, yoffset, spacing,
	output reg done, 
	output reg [8:0] x, y
);

	always @(posedge clk) begin
		if(!resetn) begin
			done <= 1'd0;
			x <= 9'd0;
			y <= yoffset;
		end
		else if (draw_en) begin
			if (x == width && y == yoffset + spacing) begin
				done <= 1'b1;
			end
			else if (x == width) begin
				x <= 9'd0;
				y <= yoffset + spacing;
			end
			else begin
				x <= x + 1'b1;
			end
		end
		else begin
			done <= 1'd0;
			x <= 9'd0;
			y <= yoffset;
		end
	end

endmodule 