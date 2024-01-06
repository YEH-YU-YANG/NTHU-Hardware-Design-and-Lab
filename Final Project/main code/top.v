`define DASH 0
`define P 7
`define A 8
`define S 9
`define F 10
`define I 11
`define L 12
`define G 13
`define O 14
`define D 15

`define WALL_COLOR   12'hDCD 
`define FLOOR_COLOR  12'h656
`define DOOR_COLOR   12'h000
`define BLUE_COLOR   12'h548
`define PRISON_COLOR 12'h112
// `define RED_COLOR 12'hE47

`define F1  9'b0_0000_0101 // LEFT_DIR  05 => 5  
`define F2  9'b0_0000_0110 // RIGHT_DIR 06 => 6  
`define F3  9'b0_0000_0100 // UP_DIR    04 => 4  
`define F4  9'b0_0000_1100 // DOWN_DIR  0C => 12 
`define F5  9'b0_0000_0011 // space 03 => 3 
`define F6  9'b0_0000_1011 // 0B => 11 
`define F9  9'b0_0000_0001 // 01 => 1 
`define F10 9'b0_0000_1001 // 09 => 9
`define KEY_W 9'b0_0001_1101  // 1D ->
`define KEY_A 9'b0_0001_1100  // 1C ->
`define KEY_S 9'b0_0001_1011  // 1B ->
`define KEY_D 9'b0_0010_0011  // 23 ->


`define LEFT_DIR 0
`define RIGHT_DIR 1
`define UP_DIR 2
`define DOWN_DIR 3

`define DASH 0
`define P 7
`define A 8
`define S 9
`define F 10
`define I 11
`define L 12
`define G 13
`define O 14
`define D 15

module top(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input CIN,

    input KEY_IN,
    input APPLE_IN,
    input HINT_PASS_IN,
    input COLOR_PASS_IN,
    input PASS_IN,
    input FAIL_IN,
    input SUCCESS_IN,

    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output hsync,
    output vsync,
    output wire [6:0] DISPLAY,
	output wire [3:0] DIGIT,

    output wire KEY_OUT,
    output wire APPLE_OUT,
    output wire HINT_PASS_OUT,
    output wire COLOR_PASS_OUT,
    output wire PASS_OUT,
    output reg FAIL_OUT,
    output reg SUCCESS_OUT,
    output wire MOVEMENT_LOCK
);
    



    // clk
    wire clk_25MHz;  
    clock_divider #(2) cd25(.clk(clk),.clk_div(clk_25MHz));

    // 問題在這
    // wire clk_22;  
    // clock_divider #(22) cd22(.clk(clk),.clk_div(clk_22));

    // vga
    wire [9:0] x,y;
    wire valid;
    
    // keyboard
    wire [12:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

  	
    wire [15:0] SEVEN_SEGMENT;

    /* --------------------------------- states --------------------------------- */
    wire [3:0] stage_state;
    wire [2:0] chair_state;
    /* -------------------------------------------------------------------------- */

    /* ------------------------------ people signal ----------------------------- */
    wire people_dir;
    wire [9:0] people_up;
    wire [9:0] people_left;
    /* -------------------------------------------------------------------------- */


    /* ------------------------------ chair signal ------------------------------ */
    wire [9:0] chair_up;
    wire [9:0] chair_left;
    /* -------------------------------------------------------------------------- */


    /* ------------------------------ ghost signal ----------------------------- */
    wire [9:0] ghost1_up;
    wire [9:0] ghost1_left;
    wire [9:0] ghost2_up;
    wire [9:0] ghost2_left;
    wire ghost1_fail;
    wire ghost2_fail;
    wire [1:0] ghost1_dir;
    /* -------------------------------------------------------------------------- */


    /* --------------------------- fail、success signal -------------------------- */
    always@(*) begin
        FAIL_OUT = (ghost1_fail || ghost2_fail || FAIL_IN);
    end

    always@(*) begin
        if( PASS_OUT && stage_state==0 && 220<=people_left && people_left<=420 && 380<=people_up && people_up<=440) SUCCESS_OUT=1;
        else if(SUCCESS_IN) SUCCESS_OUT = 1;
        else SUCCESS_OUT = 0;
    end
    /* -------------------------------------------------------------------------- */


    /* --------------------------------- people --------------------------------- */


    people_top_control p1(.clk(clk), .rst(rst), 
                          .key_down(key_down), .last_change(last_change), .been_ready(been_ready),
                          .stage_state(stage_state), .chair_state(chair_state),
                          .x(x), .y(y), 
                          .chair_up(chair_up),.chair_left(chair_left),
                          .FAIL(FAIL_OUT), .SUCCESS(SUCCESS_OUT),.CIN(CIN),
                          .people_left(people_left), .people_up(people_up),.dir(people_dir));

    /* -------------------------------------------------------------------------- */


    /* ----------------------------------- vga ---------------------------------- */

    vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(x),.v_cnt(y));

    stage_top_control m(.clk(clk), .clk_25MHz(clk_25MHz), .rst(rst), 
                        .valid(valid), .x(x), .y(y), 
                        .people_up(people_up),.people_left(people_left),  .people_dir(people_dir),
                        .chair_up(chair_up),.chair_left(chair_left),
                        .ghost1_up(ghost1_up), .ghost1_left(ghost1_left), .ghost1_dir(ghost1_dir),
                        .ghost2_up(ghost2_up), .ghost2_left(ghost2_left), 
                        .key_down(key_down), .last_change(last_change), .been_ready(been_ready),
                        .stage_state(stage_state), .chair_state(chair_state),
                        .FAIL(FAIL_OUT),.SUCCESS(SUCCESS_OUT),
                        .CIN(CIN), .KEY_IN(KEY_IN), .APPLE_IN(APPLE_IN), .HINT_PASS_IN(HINT_PASS_IN), .COLOR_PASS_IN(COLOR_PASS_IN), .PASS_IN(PASS_IN), 

                        .KEY_OUT(KEY_OUT), .APPLE_OUT(APPLE_OUT), .HINT_PASS_OUT(HINT_PASS_OUT), .COLOR_PASS_OUT(COLOR_PASS_OUT), .PASS_OUT(PASS_OUT), .LOCK(MOVEMENT_LOCK), 
                        .SEVEN_SEGMENT(SEVEN_SEGMENT),
                        .PIXEL({vgaRed,vgaGreen,vgaBlue})
    );

    /* -------------------------------------------------------------------------- */
    
    /* ---------------------------------- chair --------------------------------- */
    chair_top_control c0(
        .clk(clk), .rst(rst), .stage_state(stage_state), .chair_state(chair_state),
        .key_down(key_down), .last_change(last_change), .been_ready(been_ready),
        .people_up(people_up), .people_left(people_left),
        .chair_up(chair_up),.chair_left(chair_left)
    );
    /* -------------------------------------------------------------------------- */

    /* --------------------------------- ghost --------------------------------- */
    ghost1_top_control b1(
        .clk(clk), .rst(rst),.stage_state(stage_state),
        .people_up(people_up), .people_left(people_left),
        .chair_up(chair_up),.chair_left(chair_left),.chair_state(chair_state),
        .ghost_up(ghost1_up),.ghost_left(ghost1_left), .fail(ghost1_fail), .dir(ghost1_dir)
    );
    ghost2_top_control b2(
        .clk(clk), .rst(rst),.stage_state(stage_state),
        .people_up(people_up), .people_left(people_left),
        .ghost_up(ghost2_up),.ghost_left(ghost2_left), .fail(ghost2_fail)
    );
	/* -------------------------------------------------------------------------- */
   
    /* ------------------------ memory address generator ------------------------ */
    // mem_addr_gen m0(
    //     .clk(clk_22),
    //     .rst(rst),
    //     .x(x), .y(y), 
    //     .chair_up(chair_up),.chair_left(chair_left),
    //     .ghost1_up(ghost1_up), .ghost1_left(ghost1_left), 
    //     .ghost2_up(ghost2_up), .ghost2_left(ghost2_left),

    //     // .carbinet_addr(carbinet_addr),
    //     .key_addr(key_addr),
    //     .chair_addr(chair_addr),
    //     .ghost1_addr(ghost1_addr),
    //     .ghost2_addr(ghost2_addr),
    //     .apple_addr(apple_addr),
    //     .people_addr(people_addr)
    // );
    /* -------------------------------------------------------------------------- */
   
    KeyboardDecoder k(
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk_25MHz)
    );

    SevenSegment basys3_7_segment(.DISPLAY(DISPLAY),.DIGIT(DIGIT),.nums(SEVEN_SEGMENT),.rst(rst),.clk(clk));
    
endmodule

module SevenSegment(
	output reg [6:0] DISPLAY,
	output reg [3:0] DIGIT,
	input wire [15:0] nums,
	input wire rst,
	input wire clk

);
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		DIGIT <= 4'b1111;
    	end else begin
    		case (DIGIT)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					DIGIT <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						DIGIT <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						DIGIT <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						DIGIT <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						DIGIT <= 4'b1110;
					end				
    		endcase
    	end
    end

    always @ (*) begin
    	case (display_num)
            `DASH: DISPLAY = 7'b011_1111;  
			1 : DISPLAY = 7'b1111001;   //0001                                                
			2 : DISPLAY = 7'b0100100;   //0010                                                
			3 : DISPLAY = 7'b0110000;   //0011                                             
			4 : DISPLAY = 7'b0011001;   //0100                                               
			5 : DISPLAY = 7'b0010010;   //0101                                               
			6 : DISPLAY = 7'b0000010;   //0110

            `P: DISPLAY = 7'b000_1100;  //
            `A: DISPLAY = 7'b000_1000;  //
            `S: DISPLAY = 7'b001_0010;  //
            `F: DISPLAY = 7'b000_1110;  //
            `I: DISPLAY = 7'b111_1001;  //
            `L: DISPLAY = 7'b100_0111;  //
            `G: DISPLAY = 7'b000_0010;  //
            `O: DISPLAY = 7'b100_0000;  //
            `D: DISPLAY = 7'b010_0001;  //
			default : DISPLAY = 7'b1111111;
    	endcase
    end
    
endmodule

module KeyboardDecoder(
	output reg [12:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [12:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	one_pulse op (
		.pb_out(pulse_been_ready),
		.pb_in(been_ready),
		.clk(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule

module clock_divider #(
    parameter n = 27
    )(
    input wire  clk,
    output wire clk_div  
    );

    reg [n-1:0] num;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

// module debounce (
// 	input wire clk,
// 	input wire pb, 
// 	output wire pb_debounced 
//     );
// 	reg [3:0] shift_reg; 

// 	always @(posedge clk) begin
// 		shift_reg[3:1] <= shift_reg[2:0];
// 		shift_reg[0] <= pb;
// 	end

// 	assign pb_debounced = ((shift_reg == 4'b1111) ? 1'b1 : 1'b0);
// endmodule

module one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
    );

	reg pb_in_delay;

	always @(posedge clk) begin
		if (pb_in == 1'b1 && pb_in_delay == 1'b0) begin
			pb_out <= 1'b1;
		end else begin
			pb_out <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		pb_in_delay <= pb_in;
	end
endmodule

module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;

endmodule