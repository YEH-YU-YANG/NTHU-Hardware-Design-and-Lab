`define LEFT_DIR 0
`define RIGHT_DIR 1
`define P 11
`define A 12
`define S 13

module top(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input cin,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output hsync,
    output vsync,
    output wire [6:0] display,
	output wire [3:0] digit,
    output wire key,
    output wire apple,
    output wire pass,
    output reg fail,
    output reg success,
    output wire LOCK
);
    
    // vga
    wire [9:0] x,y;
    wire valid;
    
    // keyboard
    wire [12:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    // clk
    wire clk_25MHz;  
    clock_divider #(2) cd25(.clk(clk),.clk_div(clk_25MHz));
  	
    // 問題在這
    // wire clk_22;  
    // clock_divider #(22) cd22(.clk(clk),.clk_div(clk_22));
    
    wire [2:0] stage_state;
    wire [2:0] chair_state;

    wire people_dir;
    wire [9:0] people_up;
    wire [9:0] people_left;
    // wire [11:0] true_people_pixel;
    // assign true_people_pixel = (apple) ? people_pixel^12'hAAA : people_pixel;

    wire [9:0] chair_up;
    wire [9:0] chair_left;

    wire [9:0] banana1_up;
    wire [9:0] banana1_left;

    wire [9:0] banana2_up;
    wire [9:0] banana2_left;

    wire banana1_fail;
    wire banana2_fail;
    
    always@(*) begin
        fail = (banana1_fail || banana2_fail);
    end

    always@(*) begin
        if( key && apple && pass && 220<=people_left && people_left<=420 && 380<=people_up && people_up<=440) success=1;
        else success = 0;
    end


    wire [15:0] password;

    /* --------------------------------- people --------------------------------- */


    people_top_control p1(.clk(clk), .rst(rst), 
                          .key_down(key_down), .last_change(last_change), .been_ready(been_ready),
                          .stage_state(stage_state), .chair_state(chair_state),
                          .x(x), .y(y), 
                          .chair_up(chair_up),.chair_left(chair_left),
                          .apple(apple), .fail(fail), .success(success),.cin(cin),
                          .people_left(people_left), .people_up(people_up),.dir(people_dir));

    /* -------------------------------------------------------------------------- */


    /* ----------------------------------- vga ---------------------------------- */

    vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(x),.v_cnt(y));

    stage_top_control m(.clk(clk), .clk_25MHz(clk_25MHz), .rst(rst), 
                        .valid(valid), .x(x), .y(y), 
                        .people_up(people_up),.people_left(people_left),  .people_dir(people_dir),
                        .chair_up(chair_up),.chair_left(chair_left),
                        .banana1_up(banana1_up), .banana1_left(banana1_left), 
                        .banana2_up(banana2_up), .banana2_left(banana2_left), 
                        .key_down(key_down), .last_change(last_change), .been_ready(been_ready),
                        .stage_state(stage_state), .chair_state(chair_state),
                        .fail(fail),.success(success),.cin(cin),.LOCK(LOCK),


                        .apple(apple),.key(key),.pass(pass),.password(password),
                        .vgaR(vgaRed),.vgaG(vgaGreen),.vgaB(vgaBlue)
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

    /* --------------------------------- banana --------------------------------- */
    // banana1_top_control b1(
    //     .clk(clk_22), .rst(rst),.stage_state(stage_state),
    //     .people_up(people_up), .people_left(people_left),
    //     .banana_up(banana1_up),.banana_left(banana1_left), .fail(banana1_fail)
    // );
    // banana2_top_control b2(
    //     .clk(clk_22), .rst(rst),.stage_state(stage_state),
    //     .people_up(people_up), .people_left(people_left),
    //     .banana_up(banana2_up),.banana_left(banana2_left), .fail(banana2_fail)
    // );
	/* -------------------------------------------------------------------------- */
   
    /* ------------------------ memory address generator ------------------------ */
    // mem_addr_gen m0(
    //     .clk(clk_22),
    //     .rst(rst),
    //     .x(x), .y(y), 
    //     .chair_up(chair_up),.chair_left(chair_left),
    //     .banana1_up(banana1_up), .banana1_left(banana1_left), 
    //     .banana2_up(banana2_up), .banana2_left(banana2_left),

    //     // .carbinet_addr(carbinet_addr),
    //     .key_addr(key_addr),
    //     .chair_addr(chair_addr),
    //     .banana1_addr(banana1_addr),
    //     .banana2_addr(banana2_addr),
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

    // reg [15:0] nums;
    // always@(*) begin
    //     nums[15:12] = 0;
    //     nums[11:8] = 0;
    //     nums[7:4] = 0;
    //     nums[3] = 0;
    //     nums[2:0] = stage_state;
    // end

    SevenSegment basys3_7_segment(.display(display),.digit(digit),.nums(password),.rst(rst),.clk(clk));
    
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
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
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
            10: display = 7'b011_1111;  //DASH
            `P: display = 7'b000_1100;  //DASH
            `A: display = 7'b000_1000;  //DASH
            `S: display = 7'b001_0010;  //DASH

			default : display = 7'b1111111;
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

`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

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

