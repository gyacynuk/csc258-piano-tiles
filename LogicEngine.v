module LogicEngine(
	input clk, resetn, en, 
	input [3:0] key_pressed,
	input [123:0] song_in,
	output [8:0] yoffset, 
	output [19:0] keys, 
	output [1:0] num_hit, 
	output [9:0] score,
	output done, won_flag_out, lost_flag_out, cycle_done
);

	// Logic Control
	wire ld_song_en, status_en, checkw_en, checkl_en, update_en, done;
	LogicControl lc(
		.clk(clk),
		.resetn(resetn),
		.en(en),			
		.won_flag(won_flag),
		.lost_flag(lost_flag),
		.ld_song_en(ld_song_en),
		.status_en(status_en),
		.checkw_en(checkw_en),
		.checkl_en(checkl_en),
		.update_en(update_en),
		.done(done)
	);
	
	// Logic Datapath
	wire won_flag, lost_flag;
	assign won_flag_out = won_flag;
	assign lost_flag_out = lost_flag;
	LogicDataPath(
		.resetn(resetn),
		.ld_song_en(ld_song_en),
		.status_en(status_en),
		.checkw_en(checkw_en),
		.checkl_en(checkl_en),
		.update_en(update_en),
		.key_hit(key_hit),
		.song_in(song_in),
		.keys(keys),
		.score(score),
		.yoffset(yoffset),
		.num_hit(num_hit),
		.won_flag(won_flag),
		.lost_flag(lost_flag)
	);
	
	// Input Handler
	wire [3:0] key_hit;
	InputHandler ih(
		.clk(clk),
		.resetn(resetn),
		.key_pressed(key_pressed),
		.key_hit(key_hit)
	);

endmodule 


module LogicDataPath(
	input resetn,
	input ld_song_en, status_en, checkw_en, checkl_en, update_en
	input [3:0] key_hit,
	input [123:0] song_in,
	output reg [19:0] keys,
	output reg [9:0] score,
	output reg [8:0] yoffset,
	output reg [1:0] num_hit,
	output reg won_flag, lost_flag
);

	localparam [8:0] HEIGHT				= 9'd120;
	localparam [8:0] STARTING_OFFSET = 9'd90;
	localparam [8:0] HITBOX_TOP 		= 9'd100;
	localparam [8:0] HITBOX_BOTTOM 	= 9'd110;
	localparam [8:0] KEY_HEIGHT 		= 9'd30'

	reg [123:0] song;
	reg [11:0] song_counterl

	
	always @(*) begin
		if (!resetn) begin
			song = 124'd0;
			song_counter = 12'd20;
			score = 10'd0;
			keys = 20'b10000000000000000000;					// trying to avoid game instantly winning?
			yoffset = STARTING_OFFSET; 
			num_hit = 2'd0;
			won_flag = 1'b0;
			lost_flag = 1'b0;
		end
		
		else if (ld_song_en) begin
			song <= song_in;
		end
		
		else if (status_en) begin
			// Check missed key
			if (yoffset > HITBOX_BOTTOM && num_hit == 2'd0) begin
				lost_flag <= 1'b1;
			end
			// Key has not been missed, process input
			else begin
				// Check if bottom-most key is in the hitbox
				if (yoffset + KEY_HEIGHT > HITBOX_TOP && yoffset < HITBOX_BOTTOM) begin
					// Check if hit wrong key
					if (num_hit == 2'd0 && key_hit != 4'd0 && key_hit != keys[3:0]) begin
						lost_flag <= 1'b1;
					end
					// Check if hit correct key
					else if (num_hit == 2'd0 && key_hit != 4'd0 && key_hit == keys[3:0]) begin
						num_hit <= 2'd1;
						score <= score + 1'b1;
					end
				end
				// Check if second bottom-most key is in the hitbox
				else if (yoffset > HITBOX_TOP && yoffset - KEY_HEIGHT < HITBOX_BOTTOM) begin
					// Check if hit wrong key
					if (num_hit == 2'd1 && key_hit != 4'd0 && key_hit != keys[7:4]) begin
						lost_flag <= 1'b1;
					end
					// Check if hit correct key
					else if (num_hit == 2'd1 && key_hit != 4'd0 && key_hit == keys[7:4]) begin
						num_hit <= 2'd2;
						score <= score + 1'b1;
					end
				end
			end
		end
		
		else if (checkw_en) begin
			if (keys == 20'd0) begin
				won_flag <= 1'b1;
			end
		end
		
		else if (update_en) begin
			if (yoffset == HEIGHT) begin
				yoffset <= STARTING_OFFSET;
				song_counter <= song_counter + 3'b4;
				keys[3:0] 	<= keys[7:4];
				keys[7:4] 	<= keys[11:8];
				keys[11:8] 	<= keys[15:12];
				keys[15:12] <= keys[19:16];
				keys[19:16] <= song[song_counter + 2'd3 : song_counter]
				
				if (num_hit > 2'd0) begin
					num_hit <= num_hit - 1'b1;
				end
			end	
			else begin
				yoffset <= yoffset + 1'b1;
			end
		end
	end
	
endmodule 


module LogicControl(
	input clk, resetn, en, won_flag, lost_flag,
	output reg ld_song_en, status_en, checkw_en, checkl_en, update_en, done, done_cycle	
);

	reg [3:0] current_state, next_state; 
	localparam  S_LOAD_SONG 		= 4'd0,
					S_CHECK_STATUS   	= 4'd1, 	// Set lose or win flags
					S_CHECK_WON			= 4'd2,			
					S_CHECK_LOST     	= 4'd3,
					S_UPDATE  			= 4'd4,
					S_SLEEP        	= 4'd5,
					S_DONE_CYCLE		= 4'd6,
					S_GAMEOVER_W		= 4'd7,
					S_GAMEOVER_L		= 4'd8;

	// State Table
	always@(*)
	begin: state_table 
		case (current_state)
			S_LOAD_SONG: 		next_state = S_CHECK_STATUS;
			S_CHECK_STATUS: 	next_state = en ? S_CHECK_WON : S_CHECK_STATUS;		// Wait here until enable signal
			S_CHECK_WON: 		next_state = won_flag 	? S_GAMEOVER_W : 	S_CHECK_LOST;
			S_CHECK_LOST:		next_state = lost_flag	? S_GAMEOVER_L :	S_UPDATE;
			S_UPDATE:			next_state = S_SLEEP;
			S_SLEEP: 			next_state = wake_flag ? S_DONE_CYCLE : S_SLEEP;
			S_DONE_CYCLE: 		next_state = CHECK_STATUS;
			default: 			next_state = S_LOAD_SONG;
		endcase
	end	

	// Signal Manager
	always @(*)
	begin: enable_signals
		// Reset all signals to low
		ld_song_en	= 1'b0;
		status_en 	= 1'b0;
		checkw_en 	= 1'b0;
		checkl_en 	= 1'b0;
		update_en 	= 1'b0;
		sleep_en 	= 1'b0;
		done 			= 1'b0;
		done_cycle  = 1'b0;

		case (current_state)
			S_LOAD_SONG: 		ld_song_en 	= 1'b1;
			S_CHECK_STATUS: 	status_en 	= 1'b1;
			S_CHECK_WON: 		checkw_en 	= 1'b1;
			S_CHECK_LOST: 		checkl_en 	= 1'b1;
			S_UPDATE: 			update_en 	= 1'b1;
			S_SLEEP: 			sleep_en 	= 1'b1;
			S_DONE_CYCLE: 		done_cycle 	= 1'b1;
			S_GAMEOVER_W: 		done 			= 1'b1;
			S_GAMEOVER_L: 		done 			= 1'b1;
		endcase
	end

	// Current State Manager
	always@(posedge clk)
	begin: state_FFs
	  if(!reset_n || !en)			
			current_state <= S_LOAD_SONG;
	  else
			current_state <= next_state;
	end	
	
	// Sleeper
	localparam [25:0] SLEEP_CYCLES = 26'd1666666; // 30 fps
	reg sleep_en, wake_flag;
	reg [25:0] sleep_count;
	always @(posedge clk) begin
		if (!resetn) begin
			sleep_count <= 0'd26;
			wake_flag <= 1'b0;
		end
		else if (sleep_en) begin
			if (sleep_count == SLEEP_CYCLES) begin
				wake_flag <= 1'b1;
			end
			else begin
				sleep_counter <= sleep_counter + 1'b1;
			end
		end
		else begin
			sleep_count <= 0'd26;
			wake_flag <= 1'b0;
		end
	end
						
endmodule 

module InputHandler(
	input clk, resetn, clr,
	input [3:0] key_pressed,
	output reg [3:0] key_hit
);

	always @(posedge clk) begin
		if(!resetn || clr) begin
			key_hit <= 4b'0000;
		end
		else if (key_pressed != 4'b0000 && key_hit == 4'b0000) begin	// if no key has been proccessed yet
			key_hit <= key_pressed;
		end
	end

endmodule 