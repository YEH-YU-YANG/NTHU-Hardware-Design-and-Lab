module top(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input [15:0] SW,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output hsync,
    output vsync
);
    


    // vga
    wire [9:0] h_cnt, v_cnt;
    wire valid;
    

    // keyboard
    wire [50:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    // clk
    wire clk_25MHz;  
    clock_divider #(2) cd25(.clk(clk),.clk_div(clk_25MHz));
  	
	wire clk_17;
    clock_divider #(17) cd17(.clk(clk),.clk_div(clk_17));
    
    wire clk_22;
    clock_divider #(22) cd22(.clk(clk),.clk_div(clk_22));
    

	/* rst button */
    wire rst_debounce,rst_one_pulse;
    debounce drst(.clk(clk_17) ,.pb(rst), .pb_debounced(rst_debounce));
    one_pulse orst(.clk(clk_17),.pb_in(rst_debounce),.pb_out(rst_one_pulse));

    /* --------------------------------- people --------------------------------- */

    wire [9:0] people_left_border;
    wire [9:0] people_right_border;
    wire [9:0] people_up_border;
    wire [9:0] people_down_border;
    wire [11:0] people_pixel;

    people_top_control p1(.clk(clk), .clk_25MHz(clk_25MHz), .rst(rst_one_pulse), .key_down(key_down), .last_change(last_change), .been_ready(been_ready),.x(h_cnt), .y(v_cnt), 
                          .people_left_border(people_left_border), .people_right_border(people_right_border), .people_up_border(people_up_border), .people_down_border(people_down_border),
                          .people_pixel(people_pixel));

    // new_people2_w40_h30 p6 (.clka(clk_25MHz),.wea(0),.addra(people_addr),.dina(garbage),.douta(people_pixel));


    /* -------------------------------------------------------------------------- */


    /* ----------------------------------- vga ---------------------------------- */
    vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst_one_pulse),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(h_cnt),.v_cnt(v_cnt));

    // wire [11:0] stage1_rgb;
	// stage1_rgb_gen m(.clk(clk_25MHz),.rst(rst_one_pulse), .valid(valid), .x(h_cnt), .y(v_cnt), 
    //                  .people_left_border(people_left_border),.people_right_border(people_right_border),.people_up_border(people_up_border),.people_down_border(people_down_border), .people_pixel(people_pixel), 
    //                  .vgaR(stage1_rgb[11:8]),.vgaG(stage1_rgb[7:4]),.vgaB(stage1_rgb[3:0]));

    stage_top_control m(.clk(clk_25MHz),.rst(rst_one_pulse), .valid(valid), .x(h_cnt), .y(v_cnt), 
                        .people_left_border(people_left_border),.people_right_border(people_right_border),.people_up_border(people_up_border),.people_down_border(people_down_border), .people_pixel(people_pixel), 
                        .vgaR(vgaRed),.vgaG(vgaGreen),.vgaB(vgaBlue));


    /* -------------------------------------------------------------------------- */


    // reg [4:0] state=1;
    // // vga
    // always@(*) begin
    //     case(state)
    //         1: {vgaRed, vgaGreen, vgaBlue} = stage1_rgb;
    //         default {vgaRed, vgaGreen, vgaBlue} = stage1_rgb;
    //     endcase
    // end
    
	KeyboardDecoder k(
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk_25MHz)
    );
endmodule







module division #(
    // the size of input and output ports of the division module is generic.
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] Res,
    output reg [WIDTH-1:0] Remainder
);

    
    // internal variables    
    reg [WIDTH-1:0] a1, b1;
    reg [WIDTH:0] p1;   
    integer i;

    always @ (A or B)
    begin
        // initialize the variables.
        a1 = A;
        b1 = B;
        p1 = 0;

        for (i = 0; i < WIDTH; i = i + 1) begin // start the for loop
            p1 = {p1[WIDTH-2:0], a1[WIDTH-1]};
            a1[WIDTH-1:1] = a1[WIDTH-2:0];
            p1 = p1 - b1;

            if (p1[WIDTH-1] == 1) begin
                a1[0] = 0;
                p1 = p1 + b1;
            end
            else
                a1[0] = 1;
        end

        Res = a1;
        Remainder = p1[WIDTH-1:0];
    end 
endmodule




module KeyboardDecoder(
	output reg [50:0] key_down,
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
    
    wire [50:0] key_decode = 1 << last_change;
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

module debounce (
	input wire clk,
	input wire pb, 
	output wire pb_debounced 
    );
	reg [3:0] shift_reg; 

	always @(posedge clk) begin
		shift_reg[3:1] <= shift_reg[2:0];
		shift_reg[0] <= pb;
	end

	assign pb_debounced = ((shift_reg == 4'b1111) ? 1'b1 : 1'b0);
endmodule

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

