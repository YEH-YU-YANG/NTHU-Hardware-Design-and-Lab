module lab6_2(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input hint,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output pass
    );
    
    // vga
    wire [16:0] pixel_addr;
    wire [11:0] data, pixel;
    wire [9:0] h_cnt, v_cnt;
    wire valid;
	assign {vgaRed, vgaGreen, vgaBlue} = (valid) ? (pixel) : (12'd0);

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

	blk_mem_gen_0 blk_mem_gen_0_inst(
    	.clka(clk_25MHz),
      	.wea(0),
      	.addra(pixel_addr),
      	.dina(data[11:0]),
      	.douta(pixel)
    ); 

    vga_controller   vga_inst(
      	.pclk(clk_25MHz),
      	.reset(rst_one_pulse),
      	.hsync(hsync),
      	.vsync(vsync),
      	.valid(valid),
      	.h_cnt(h_cnt),
      	.v_cnt(v_cnt)
    );

	mem_addr_gen m(
        .clk(clk_25MHz),
        .rst(rst_one_pulse),
        .hint(hint),
        .key_down(key_down),
        .last_change(last_change),
        .been_ready(been_ready),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr),
        .pass(pass)
    );

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

module mem_addr_gen(
   	input clk,
   	input rst,
   	input hint,
	input [50:0] key_down,
    input [8:0] last_change,
    input been_ready,
   	input [9:0] h_cnt,
   	input [9:0] v_cnt,
   	output reg [16:0] pixel_addr,
	output reg pass
);

	reg isPass;
	always@(*) begin
		isPass = 1;
		for(i=0;i<16;i=i+1) begin
			if(pointer[i]!=i) isPass=0;
			if(state[i]!=0) isPass=0;
		end
		pass = (isPass!=0);
	end

	parameter noInput = 5'b1111;
	parameter [8:0] LEFT_SHIFT_CODES = 9'b0_0001_0010; // left shift => 12
    parameter [8:0] KEY_CODES [0:15] = {
        9'b0_0001_0110, // 1 => 16
        9'b0_0001_1110, // 2 => 1E
        9'b0_0010_0110, // 3 => 26
        9'b0_0010_0101, // 4 => 25
        
		9'b0_0001_0101, // Q => 15
        9'b0_0001_1101, // W => 1D
        9'b0_0010_0100, // E => 24
        9'b0_0010_1101, // R => 2D
        
		9'b0_0001_1100, // A => 1C
        9'b0_0001_1011, // S => 1B
        9'b0_0010_0011, // D => 23
        9'b0_0010_1011, // F => 2B

		9'b0_0001_1010, // Z => 1A
        9'b0_0010_0010, // X => 22
        9'b0_0010_0001, // C => 21
        9'b0_0010_1010  // V => 2A
    };

	integer i;
	reg state [0:15],next_state [0:15];
	reg [3:0] pointer [0:15],next_pointer [0:15];
	reg [16:0] next_pixel_addr;

	always@(posedge clk,posedge rst) begin

		if(rst) begin
			
			{state[0] , state[1] , state[2] , state[3] } <= {1'd0 , 1'd0 , 1'd1, 1'd0};
			{state[4] , state[5] , state[6] , state[7] } <= {1'd0 , 1'd1 , 1'd1, 1'd0};
			{state[8] , state[9] , state[10], state[11]} <= {1'd1 , 1'd0 , 1'd1, 1'd0};
			{state[12], state[13], state[14], state[15]} <= {1'd1 , 1'd1 , 1'd1, 1'd1};
			
			for(i=0;i<=15;i=i+1) begin 
				pointer[i] <= i; 
			end

			pointer[2]  <= 11;
			pointer[11] <= 2;

			pointer[4] <= 9;
			pointer[9] <= 4;

			pointer[6] <= 13;
			pointer[13] <= 6;

			pointer[12] <= 14;
			pointer[14] <= 12;

			pixel_addr <= 17'd0;
		end

		else begin

			for(i=0;i<=15;i=i+1) begin 
				state[i] <= next_state[i]; 
			end
			for(i=0;i<=15;i=i+1) begin 
				pointer[i] <= next_pointer[i]; 
			end

			pixel_addr <= next_pixel_addr;
		end
	
	end 
	
	

	// Left,Up
	reg [9:0] Left [15:0];
	reg [9:0] Up [15:0];
	always@(*) begin
		
		Up[0] = 10'd0;
		Left[0] = 10'd0;
		
		Up[1] = 10'd0;
		Left[1] = 10'd160;
	
		Up[2] = 10'd0;
		Left[2] = 10'd320;
		
		Up[3] = 10'd0;
		Left[3] = 10'd480;
			
		Up[4] = 10'd120;
		Left[4] = 10'd0;
	
	
		Up[5] = 10'd120;
		Left[5] = 10'd160;
	
		Up[6] = 10'd120;
		Left[6] = 10'd320;
	
		Up[7] = 10'd120;
		Left[7] = 10'd480;
		
		Up[8] = 10'd240;
		Left[8] = 10'd0;
	
		Up[9] = 10'd240;
		Left[9] = 10'd160;
	
		Up[10] = 10'd240;
		Left[10] = 10'd320;

		Up[11] = 10'd240;
		Left[11] = 10'd480;
		
		Up[12] = 10'd360;
		Left[12] = 10'd0;

		Up[13] = 10'd360;
		Left[13] = 10'd160;
	
		Up[14] = 10'd360;
		Left[14] = 10'd320;

		Up[15] = 10'd360;
		Left[15] = 10'd480;
	end

	// U,L
    reg [9:0] L,U;
	always@(*) begin
		L = 10'd0;
        U = 10'd0;

		for(i=0;i<16;i=i+1) begin
			if(pointer[pos]==i) begin
				L=Left[i];
				U=Up[i];
			end
		end
	end

    reg [3:0] pos;
    always @(*) begin
        pos = 4'd0;

		if(v_cnt < 10'd120 && h_cnt < 10'd160)	    pos = 4'd0;
		else if(v_cnt < 10'd120 && h_cnt < 10'd320) pos = 4'd1;
		else if(v_cnt < 10'd120 && h_cnt < 10'd480) pos = 4'd2;
		else if(v_cnt < 10'd120 && h_cnt < 10'd640) pos = 4'd3;

		else if(v_cnt < 10'd240 && h_cnt < 10'd160) pos = 4'd4;
		else if(v_cnt < 10'd240 && h_cnt < 10'd320) pos = 4'd5;
		else if(v_cnt < 10'd240 && h_cnt < 10'd480) pos = 4'd6;
		else if(v_cnt < 10'd240 && h_cnt < 10'd640) pos = 4'd7;
        
		else if(v_cnt < 10'd360 && h_cnt < 10'd160) pos = 4'd8;
		else if(v_cnt < 10'd360 && h_cnt < 10'd320) pos = 4'd9;
		else if(v_cnt < 10'd360 && h_cnt < 10'd480) pos = 4'd10;
		else if(v_cnt < 10'd360 && h_cnt < 10'd640) pos = 4'd11;

		else if(v_cnt < 10'd480 && h_cnt < 10'd160) pos = 4'd12;
		else if(v_cnt < 10'd480 && h_cnt < 10'd320) pos = 4'd13;
		else if(v_cnt < 10'd480 && h_cnt < 10'd480) pos = 4'd14;
		else if(v_cnt < 10'd480 && h_cnt < 10'd640) pos = 4'd15;
    end

	// next_pointer
	always@(*) begin
		for(i = 0; i < 16; i = i+1) begin
            next_pointer[i] = pointer[i];
        end
		if(!lock && !pass && !hint && been_ready && key_down[last_change]) begin
			if(isKeyInput && isKeyInput_2) begin
				next_pointer[key_num] = pointer[key_num_2];
				next_pointer[key_num_2] = pointer[key_num];
			end
		end
	end

	//lock
	reg lock;
	always@(posedge clk) begin
		
		if(!lock && isShift && isKeyInput) lock <= 1;
		else if(lock && (isShift||isKeyInput)) lock <= 1;
		
		else if(!lock && isKeyInput && isKeyInput_2) lock <= 1;
		else if(lock && (isKeyInput || isKeyInput_2)) lock <= 1;

		else lock <= 0;
	end

	// next_state
    always @* begin
        for(i = 0; i < 16; i = i+1) begin
            next_state[i] = state[i];
        end
		if(!lock && !pass && !hint && been_ready && key_down[last_change]) begin
			if(isShift && isKeyInput) begin
				next_state[pointer[key_num]] = state[pointer[key_num]]-1'd1;
			end
		end
    end
    

	
	wire isShift;
	assign isShift = key_down[LEFT_SHIFT_CODES];
	
	// key_num、isKeyInput
	// key_num_2、isKeyInput_2
	reg isKeyInput;
	reg isKeyInput_2;
	reg [4:0] key_num;
	reg [4:0] key_num_2;
	always@(*) begin
		isKeyInput   = 0;
		isKeyInput_2 = 0;
		if(!isKeyInput)   key_num    = noInput;
		if(!isKeyInput_2) key_num_2  = noInput;

		for(i=0;i<16;i=i+1) begin
			if( (key_num==noInput) && key_down[KEY_CODES[i]] ) begin
				key_num = i;
				isKeyInput = 1;
			end
			if( (key_num!=noInput) && i!=key_num && key_down[KEY_CODES[i]]) begin
				key_num_2 = i;
				isKeyInput_2 = 1;
			end
		end
	end

	// next_pixel_addr
    always @* begin
        next_pixel_addr = 17'd0;
        if(hint) begin
            next_pixel_addr = (h_cnt>>1)+320*(v_cnt>>1);
		end else begin
            case(state[pointer[pos]])
                1'd0: next_pixel_addr = ((160*(px-x)+h_cnt)>>1) + 320*(((120*(py-y)+v_cnt)>>1));
				// rotate vertical mirrorly
				1'd1: next_pixel_addr = ((160*(px-x)+h_cnt)>>1) + 320*((U+(U+10'd120-(120*(py-y)+v_cnt)))>>1);
				
				// rotate degree of 180
                // 1'd1: next_pixel_addr = ((L+(L+10'd160-h_cnt))>>1)+320*((U+(U+10'd120-v_cnt))>>1);
            endcase
        end
	end

	//px,py
	reg [1:0] px,py;
	always@(*) begin
		case(pointer[pos])
			4'd0:  {px,py} = {2'd0,2'd0};
			4'd1:  {px,py} = {2'd1,2'd0};
			4'd2:  {px,py} = {2'd2,2'd0};
			4'd3:  {px,py} = {2'd3,2'd0};

			4'd4:  {px,py} = {2'd0,2'd1};
			4'd5:  {px,py} = {2'd1,2'd1};
			4'd6:  {px,py} = {2'd2,2'd1};
			4'd7:  {px,py} = {2'd3,2'd1};
			
			4'd8:  {px,py} = {2'd0,2'd2};
			4'd9:  {px,py} = {2'd1,2'd2};
			4'd10: {px,py} = {2'd2,2'd2};
			4'd11: {px,py} = {2'd3,2'd2};

			4'd12: {px,py} = {2'd0,2'd3};
			4'd13: {px,py} = {2'd1,2'd3};
			4'd14: {px,py} = {2'd2,2'd3};
			4'd15: {px,py} = {2'd3,2'd3};
		endcase
	end

	//x,y
	reg [1:0] x,y;
	always@(*) begin
		case(pos)
			4'd0:  {x,y} = {2'd0,2'd0};
			4'd1:  {x,y} = {2'd1,2'd0};
			4'd2:  {x,y} = {2'd2,2'd0};
			4'd3:  {x,y} = {2'd3,2'd0};

			4'd4:  {x,y} = {2'd0,2'd1};
			4'd5:  {x,y} = {2'd1,2'd1};
			4'd6:  {x,y} = {2'd2,2'd1};
			4'd7:  {x,y} = {2'd3,2'd1};
			
			4'd8:  {x,y} = {2'd0,2'd2};
			4'd9:  {x,y} = {2'd1,2'd2};
			4'd10: {x,y} = {2'd2,2'd2};
			4'd11: {x,y} = {2'd3,2'd2};

			4'd12: {x,y} = {2'd0,2'd3};
			4'd13: {x,y} = {2'd1,2'd3};
			4'd14: {x,y} = {2'd2,2'd3};
			4'd15: {x,y} = {2'd3,2'd3};
		endcase
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

