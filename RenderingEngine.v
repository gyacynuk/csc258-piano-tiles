`include "DigitRenderer.v"
`include "RenderingModules.v"

module RenderingEngine(
	input clk, draw_en, resetn,
	input [19:0] keys, 		// 5 one-hot vector representing visible keys 
	input [8:0] yoffset, 	// y distance of bottom most key from the TOP of the screen
	input [1:0] num_hit,    // number of keys correctly played currently on screen
	input [9:0] score,		// player score
	output reg [9:0] x, y,
	output reg [8:0] color,
	output reg done
);

	localparam [8:0] WIDTH = 9'd160;
	localparam [8:0] HEIGHT = 9'd120;
	localparam [8:0] NUM_LINES = 9'd3; 
	localparam [8:0] X_SPACING = 9'40;
	localparam [8:0] Y_SPACING = 9'30;
	localparam [8:0] HITBOX_OFFSET = 9'100;
	localparam [8:0] HITBOX_SPACING = 9'10;
	localparam [8:0] TEXT_X_OFFSET = 9'5;
	localparam [8:0] TEXT_Y_OFFSET = 9'5;
	
	// Screen clearer
	wire [8:0] sc_x, sc_y;
	wire sc_done;
	ScreenClearer sc(
		.clk(clk),
		.resetn(resetn),
		.draw_en(sc_en),
		.x(sc_x), .y(sc_y),
		.done(sc_done)
	);
	
	// Verticle line renderer
	wire [8:0] vlr_x, vlr_y; 
	wire vlr_done; 
	VLineRenderer vlr(
		.clk(clk),
		.resetn(resetn),
		.draw_en(vlr_en),
		.width(WIDTH),
		.height(HEIGHT),
		.spacing(X_SPACING),
		.num_lines(NUM_LINES),
		.x(vlr_x), .y(vlr_y),
		.done(vlr_done)
	);
	
	// Horizontal line renderer
	wire [8:0] hlr_x, hlr_y; 
	wire hlr_done;
	HLineRenderer hlr(
		.clk(clk),
		.resetn(resetn),
		.draw_en(hlr_en),
		.width(WIDTH),
		.height(HEIGHT),
		.spacing(Y_SPACING),
		.num_lines(NUM_LINES),
		.x(hlr_x), .y(hlr_y),
		.done(hlr_done)
	);
	
	// Key renderer
	wire [8:0] kr_x, kr_y, kr_key, kr_height; 
	wire kr_done;
	KeyRenderer kr(
		.clk(clk),
		.resetn(resetn),
		.draw_en(kr_en),
		.width(X_SPACING),
		.height(Y_SPACING),
		.key(kr_key),
		.x(kr_x), .y(kr_y),
		.done(kr_done)
	);
	
	// Hitbox Renderer
	wire [8:0] hbr_x, hbr_y; 
	wire hbr_done;
	HitboxRenderer hbr(
		.clk(clk),
		.resetn(resetn),
		.draw_en(hbr_en),
		.width(WIDTH),
		.yoffset(HITBOX_OFFSET),
		.spacing(HITBOX_SPACING),
		.x(hbr_x), .y(hbr_y),
		.done(hbr_done)
	);
	
	// Digit renderer
	wire [8:0] dr_x, dr_y, dr_color; 
	wire [5:0] temp_offset;
	wire [1:0] digit_offset;
	wire dr_done;
	assign dr_x = TEXT_X_OFFSET + (8'd8 - temp_offset[2:0]) + digit_offset * 8'd10;
	assign dr_y = TEXT_Y_OFFSET + temp_offset[5:3];
	DigitRenderer dr(
		.clk(clk),
		.resetn(resetn),
		.draw_en(dr_en),
		.ld_en(lds_en),
		.pause(1'b0), 		// Depricated
		.score(score),
		.cur_bit(dr_color),		
		.offset(temp_offset),
		.digit_offset(digit_offset)
	);
	
	// Render Control
	wire sc_en, vlr_en, hlr_en, kr_en, key1_en, key2_en, key3_en, key4_en, key5_en, hbr_en, lds_en, dr_en;
	RenderControl rc(
		.clk(clk),
		.resetn(resetn),
		.draw_en(draw_en),
		
		.sc_done(sc_done),
		.vlr_done(vlr_done),
		.hlr_done(hlr_done),
		.kr_done(kr_done),
		.hbr_done(hbr_done),
		.dr_done(dr_done),

		.sc_en(sc_en),
		.vlr_en(vlr_en),
		.hlr_en(hlr_en),
		.kr_en(kr_en),
		.key1_en(key1_en),
		.key2_en(key2_en),
		.key3_en(key3_en),
		.key4_en(key4_en),
		.key5_en(key5_en),
		.hbr_en(hbr_en),
		.lds_en(lds_en),
		.dr_en(dr_en),
		
		.done(done)
	);
	
	// RenderDataPath
	RenderDataPath rdp(
		.sc_en(sc_en),
		.vlr_en(vlr_en),
		.hlr_en(hlr_en),
		.key1_en(kr_en), .key2_en(key2_en), .key3_en(key3_en), .key4_en(key4_en), .key5_en(key5_en),
		.hbr_en(hbr_en),
		.dr_en(dr_en),
		.sc_en(sc_en),
		.keys(keys),
		.height(HEIGHT),
		.key_height(Y_SPACING),
		.yoffset(yoffset),
		.sc_x(sc_x), .sc_y(sc_y),
		.vlr_x(vlr_x), .vlr_y(vlr_y),
		.hlr_x(hlr_x), .hlr_y(hlr_y),
		.kr_x(kr_x), .kr_y(kr_y),
		.hbr_x(hbr_x), .hbr_y(hbr_y),
		.dr_x(dr_x), .dr_y(dr_y),
		.dr_color(dr_color),
		.num_hit(num_hit),
		.x(x), .y(y),
		.color(color),
		.cur_key_height(kr_height),
		.cur_key(kr_key)
	);

endmodule

module RenderDataPath (
	input sc_en, vlr_en, hlr_en, kr_en, key1_en, key2_en, key3_en, key4_en, key5_en, hbr_en, lds_en, dr_en,
	input [19:0] keys,
	input [8:0] height, key_height, yoffset, 
	input [8:0] sc_x, sc_y, vlr_x, vlr_y, hlr_x, hlr_y, kr_x, kr_y, hbr_x, hbr_y, dr_x, dr_y, dr_color,
	input [1:0] num_hit, 
	output reg [8:0] x, y, color, cur_key_height,
	output reg [3:0] cur_key
);

	localparam [8:0] BLACK 	= 9'b000000000;
	localparam [8:0] GREY 	= 9'b100100100;
	localparam [8:0] GREEN 	= 9'b000111000;
	
	// Key position selector
	reg [8:0] key_y, key_color;
	always @(*) begin
		if (key1_en) begin
			cur_key = keys[19:16];
			key_y = 9'd0;
			cur_key_height = key_height - height + yoffset; // key_height - (height - yoffset)
		end
		else if (key2_en) begin
			cur_key = keys[15:12];
			key_y = yoffset - 3*key_height;
			cur_key_height = key_height;
		end
		else if (key3_en) begin
			cur_key = keys[11:8];
			key_y = yoffset - 2*key_height;
			cur_key_height = key_height;
		end
		else if (key4_en) begin
			cur_key = keys[7:4];
			key_y = yoffset - key_height;
			cur_key_height = key_height;
			if (num_hit == 2'd2) begin
				key_color = GREY;
			end
			else begin
				key_color = BLACK;
			end
		end
		else if (key5_en) begin
			cur_key = keys[3:0];
			key_y = yoffset;
			cur_key_height = height - yoffset;
			if (num_hit > 2'd0) begin
				key_color = GREY;
			end
			else begin
				key_color = BLACK;
			end
		end
		else begin
			cur_key = 4'b0000;
			key_y = 9'd0;
			cur_key_height = 9'd0;
			key_color = BLACK;
		end
	end

	// Output selecter
	always @(*) begin
		if (sc_en) begin
			x = sc_x;
			y = sc_y;
			color = BLACK;
		end
		else if (vlr_en) begin
			x = vlr_x;
			y = vlr_y;
			color = BLACK;
		end
		else if (hlr_en) begin
			x = hlr_x;
			y = hlr_y;
			color = BLACK;
		end
		else if (kr_en) begin
			x = kr_x;
			y = kr_y + key_y;
			color = key_color;
		end
		else if (hbr_en) begin
			x = hbr_x;
			y = hbr_y;
			color = GREEN;
		end
		else if (dr_en) begin
			x = dr_x;
			y = dr_y;
			color = {dr_color, dr_color, dr_color, 6'b111111}; // Draws red text on white background
		end
		else begin
			x = 9'd0;
			y = 9'd0;
			color = BLACK;
		end
	end
	
	always 

endmodule

module RenderControl (
	input clk, reset_n,
	input draw_en, sc_done, vlr_done, hlr_done, kr_done, hbr_done, dr_done,
	output reg done, sc_en, vlr_en, hlr_en, kr_en, key1_en, key2_en, key3_en, key4_en, key5_en, hbr_en, lds_en, dr_en
);

	reg [4:0] current_state, next_state; 
	localparam  S_WAIT 				= 5'd0,
					S_CLEAR        	= 5'd1,
					S_VLINES  			= 5'd2,
					S_HLINES        	= 5'd3,
					S_KEY1   			= 5'd4,
					S_KEY2   			= 5'd5,
					S_KEY3   			= 5'd6,
					S_KEY4   			= 5'd7,
					S_KEY5   			= 5'd8,
					S_KEY1R   			= 5'd9,
					S_KEY2R   			= 5'd10,
					S_KEY3R  			= 5'd11,
					S_KEY4R   			= 5'd12,
					S_KEY5R   			= 5'd13,
					S_HITBOX          = 5'd14,
					S_LD_SCORE			= 5'd15,
					S_SCORE				= 5'd16,
					S_WAIT 				= 5'd17,
					S_DONE				= 5'd18;

	// State Table
	always@(*)
	begin: state_table 
		case (current_state)
			S_WAIT: 		next_state = draw_en 	? S_CLEAR 	: 	S_WAIT;
			S_CLEAR: 	next_state = sc_done 	? S_VLINES 	: 	S_CLEAR;
			S_VLINES: 	next_state = vlr_done 	? S_HLINES 	: 	S_VLINES;
			S_HLINES: 	next_state = hlr_done 	? S_KEY1R 	: 	S_HLINES;
			S_KEY1R: 	next_state = S_KEY1
			S_KEY1: 		next_state = kr_done 	? S_KEY2R 	: 	S_KEY1;
			S_KEY2R: 	next_state = S_KEY2;
			S_KEY2: 		next_state = kr_done 	? S_KEY3R 	: 	S_KEY2;
			S_KEY3R: 	next_state = S_KEY3;
			S_KEY3: 		next_state = kr_done 	? S_KEY4R 	: 	S_KEY3;
			S_KEY4R: 	next_state = S_KEY4;
			S_KEY4: 		next_state = kr_done 	? S_KEY5R 	: 	S_KEY4;
			S_KEY5R: 	next_state = S_KEY5;
			S_KEY5: 		next_state = kr_done 	? S_HITBOX 	: 	S_KEY5;
			S_HITBOX: 	next_state = hbr_done 	? S_SCORE 	: 	S_HITBOX;
			S_LD_SCORE: next_state = S_SCORE;
			S_SCORE: 	next_state = dr_done 	? S_DONE 	: 	S_SCORE;
			S_DONE: 		next_state = S_DONE;
			default: 	next_state = S_WAIT;
		endcase
	end	

	// Signal Manager
	always @(*)
	begin: enable_signals
		// Reset all signals to low
		sc_en 	= 1'b0;
		vlr_en 	= 1'b0;
		hlr_en 	= 1'b0;
		kr_en 	= 1'b0;
		key1_en 	= 1'b0;
		key2_en 	= 1'b0;
		key3_en 	= 1'b0;
		key4_en 	= 1'b0;
		key5_en 	= 1'b0;
		hbr_en 	= 1'b0;
		lds_en   = 1'b0;
		dr_en 	= 1'b0;
		done 		= 1'b0;

		case (current_state)
			S_CLEAR: 	sc_en 	= 1'b1;
			S_VLINES: 	vlr_en 	= 1'b1;
			S_HLINES: 	hlr_en 	= 1'b1;
			S_KEY1: 		kr_en 	= 1'b1;
			S_KEY2: 		kr_en 	= 1'b1;
			S_KEY3: 		kr_en 	= 1'b1;
			S_KEY4: 		kr_en 	= 1'b1;
			S_KEY5: 		kr_en 	= 1'b1;
			S_KEY1R:		key1_en 	= 1'b1;
			S_KEY2R:		key2_en 	= 1'b1;
			S_KEY3R:		key3_en 	= 1'b1;
			S_KEY4R:		key4_en 	= 1'b1;
			S_KEY5R:		key5_en 	= 1'b1;
			S_HITBOX: 	hbr_en 	= 1'b1;
			S_LD_SCORE: lds_en 	= 1'b1;
			S_SCORE: 	dr_en 	= 1'b1;
			S_DONE: 		done 		= 1'b1;
		endcase
	end

	// Current State Manager
	always@(posedge clk)
	begin: state_FFs
	  if(!reset_n || !draw_en)
			current_state <= S_WAIT;
	  else
			current_state <= next_state;
	end	
						
endmodule 