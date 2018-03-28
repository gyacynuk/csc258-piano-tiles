`include "RenderingEngine.v"
`include "LogicEngine.v"
`include "SongLookupUnit.v"

module GameStateManager(
	input clk, resetn,
	output [8:0] x, y, color, 
	output draw_en
);

	// Logic Engine
	wire logic_en, logic_done, logic_done_cycle, won_flag_out, lost_flag_out;
	wire [3:0] key_pressed;
	wire [123:0] song_in;
	wire [8:0] yoffset;
	wire [19:0] keys;
	wire [1:0] num_hit;
	wire [9:0] score;
	LogicEngine le (
		.clk(clk),
		.resetn(resetn), 
		.en(logic_en), 
		.key_pressed(key_pressed), 
		.song_in(song_in), 
		// out
		.yoffset(yoffset),
		.keys(keys),
		.num_hit(num_hit),
		.score(score),
		.done(logic_done), 
		.won_flag_out(won_flag_out), 
		.lost_flag_out(lost_flag_out), 
		.cycle_done(logic_done_cycle)
	);
	
	// Rendering Engine
	wire render_en, render_done;
	assign draw_en = render_en;
	RenderingEngine re (
		.clk(clk),
		.resetn(resetn), 
		.draw_en(render_en), 
		.keys(keys),
		.yoffset(yoffset),
		.num_hit(num_hit),
		.score(score),
		.x(x),
		.y(y),
		.color(color),
		.done(render_done)
	);
	
	// Control
	GameStateControl (
		.clk(clk),
		.resetn(resetn),
		.logic_done_cycle(logic_done_cycle),
		.render_done(render_done),
		.logic_en(logic_en),
		.render_en(render_en)
	);

endmodule 

module GameStateControl(
	input clk, resetn,
	input logic_done_cycle, render_done,
	output reg logic_en, render_en;
);

	reg [3:0] current_state, next_state; 
	localparam  S_LOGIC				= 4'd0,
					S_RENDER				= 4'd1;

	// State Table
	always@(*)
	begin: state_table 
		case (current_state)
			S_LOGIC: 			next_state = logic_done_cycle 	? S_RENDER 	: S_LOGIC;
			S_RENDER: 			next_state = render_done 			? S_LOGIC 	: S_RENDER; 
			default: 			next_state = S_LOGIC;
		endcase
	end	

	// Signal Manager
	always @(*)
	begin: enable_signals
		// Reset all signals to low
		logic_en 	= 1'b0;
		render_en 	= 1'b0;

		case (current_state)
			S_LOGIC: 			logic_en 	= 1'b1;
			S_RENDER: 			render_en 	= 1'b1;
		endcase
	end

	// Current State Manager
	always@(posedge clk)
	begin: state_FFs
	  if(!reset_n)			
			current_state <= S_LOGIC;
	  else
			current_state <= next_state;
	end	
endmodule 

