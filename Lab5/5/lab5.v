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

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
	parameter DASH=32'd10;
	parameter DARK=32'd11;

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
			DASH: display = 7'b011_1111; // 1010
			DARK: display = 7'b1111111;  // 1011
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule

module division(A,B,Res);

    //the size of input and output ports of the division module is generic.
    parameter WIDTH = 8;
    //input and output ports.
    input [WIDTH-1:0] A;
    input [WIDTH-1:0] B;
    output [WIDTH-1:0] Res;
    //internal variables    
    reg [WIDTH-1:0] Res = 0;
    reg [WIDTH-1:0] a1,b1;
    reg [WIDTH:0] p1;   
    integer i;

    always@ (A or B)
    begin
        //initialize the variables.
        a1 = A;
        b1 = B;
        p1= 0;
        for(i=0;i < WIDTH;i=i+1)    begin //start the for loop
            p1 = {p1[WIDTH-2:0],a1[WIDTH-1]};
            a1[WIDTH-1:1] = a1[WIDTH-2:0];
            p1 = p1-b1;
            if(p1[WIDTH-1] == 1)    begin
                a1[0] = 0;
                p1 = p1 + b1;   end
            else
                a1[0] = 1;
        end
        Res = a1;   
    end 

endmodule


module KeyboardDecoder(
	output reg [150:0] key_down,
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
    
    wire [150:0] key_decode = 1 << last_change;
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

module Lab5(
	output wire [6:0] display,
	output wire [3:0] digit,
	output wire [15:0] LED,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk,
	input wire btnL,
	input wire btnR
);

////////// (state) //////////
parameter IDLE        = 5'b0_0001;
parameter SET         = 5'b0_0010;
parameter PAYMENT     = 5'b0_0100;
parameter BUY         = 5'b0_1000;
parameter CHANGE      = 5'b1_0000;
parameter DECREASE_ITEM = 5'b1_1111;
//////////////////////////////

parameter ZERO  = 4'b0000;
parameter ONE   = 4'b0001;                                                
parameter TWO   = 4'b0010;                                               
parameter THREE = 4'b0011;                                           
parameter FOUR  = 4'b0100;                                            
parameter FIVE  = 4'b0101;                                           
parameter SIX   = 4'b0110;
parameter SEVEN = 4'b0111;
parameter EIGHT = 4'b1000;
parameter NINE  = 4'b1001;
parameter DASH  = 4'b1010;
parameter DARK  = 4'd11;

parameter ALL_LED_ON  = 16'b1111_1111_1111_1111;
parameter ALL_LED_OFF = 16'b0000_0000_0000_0000;

parameter SPACE = 9'b0_0010_1001;  // space => 29;
parameter ENTER = 9'b0_0101_1010;  // enter => 5A

parameter [8:0] KEY_CODES [0:19] = {
		9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101 // right_9 => 7D
};


wire clk_div17;
clock_divider #(17) clk17(.clk(clk),.clk_div(clk_div17));

/* rst(BTNC) button */
wire rst_debounce,rst_one_pulse;
debounce drst(.clk(clk_div17) ,.pb(rst), .pb_debounced(rst_debounce));
one_pulse orst(.clk(clk_div17),.pb_in(rst_debounce),.pb_out(rst_one_pulse));

/* btnL button */
wire btnL_debounce,btnL_one_pulse;
debounce dbtnL(.clk(clk_div17) ,.pb(btnL), .pb_debounced(btnL_debounce));
one_pulse obtnL(.clk(clk_div17),.pb_in(btnL_debounce),.pb_out(btnL_one_pulse));

/* btnR button */
wire btnR_debounce,btnR_one_pulse;
debounce dbtnR(.clk(clk_div17) ,.pb(btnR), .pb_debounced(btnR_debounce));
one_pulse obtnR(.clk(clk_div17),.pb_in(btnR_debounce),.pb_out(btnR_one_pulse));


reg [4:0]  state , next_state;

reg [15:0] idle_led,next_idle_led;
reg [15:0] idle_seven_segment , next_idle_seven_segment;

reg [15:0] set_led,next_set_led;
reg [15:0] set_seven_segment , next_set_seven_segment;

reg [15:0] payment_led,next_payment_led;
reg [15:0] payment_seven_segment , next_payment_seven_segment;

reg [15:0] buy_led,next_buy_led;
reg [15:0] buy_seven_segment , next_buy_seven_segment;

reg [15:0] change_led,next_change_led;
reg [15:0] change_seven_segment , next_change_seven_segment;

wire[15:0] seven_segment_nums;


assign LED = (state==IDLE)    ? idle_led    :
 			 (state==SET)     ? set_led     :
 			 (state==PAYMENT) ? payment_led :
			 (state==BUY)     ? buy_led     : 
							    change_led  ;

assign seven_segment_nums = (state==IDLE)    ? idle_seven_segment    :
							(state==SET)     ? set_seven_segment     :
							(state==PAYMENT) ? payment_seven_segment :
							(state==BUY)     ? buy_seven_segment     : 
							                   change_seven_segment  ;

SevenSegment basys3_7_segment(.display(display),.digit(digit),.nums(seven_segment_nums),.rst(rst_one_pulse),.clk(clk));


//////////////// (IDLE state) ////////////////
always@(posedge clk_div17) begin
	if(state==IDLE) begin
		idle_seven_segment <= { DASH,
								DASH,
								DASH,
								DASH};
	end
end

always@(posedge clk) begin
	if(state==IDLE) begin
		idle_led <= 16'b0000_0000_0000_0000;
	end
end
//////////////////////////////////////////////

//////////////// (SET state) ////////////////
reg modifyItem;
always@(*) begin
	if(state!=SET) modifyItem = 1;
	else if(!lock && state==SET && been_ready && key_down[SPACE]) modifyItem = ~modifyItem;
end

reg [3:0] item = NINE;
reg [7:0] price = {ONE,ZERO};

always@(posedge clk_div17) begin
	set_seven_segment <= { item,
	 					   DASH,
						   price};
end

always@(posedge clk) begin
	if(state==SET) begin
		set_led <= next_set_led;
	end
end
always@(*) begin
	if(state==SET)begin
		if(modifyItem) begin
			next_set_led = {8'b1111_1111,8'b0000_0000};
		end
		else begin
			next_set_led = {8'b0000_0000,8'b1111_1111};
		end
	end
	else begin
		next_set_led = set_led;
	end
end
//////////////////////////////////////////////

/////////////// (Payment state) //////////////

reg [3:0] payment_tens , payment_units;
reg [3:0] next_payment_tens , next_payment_units;
always@(*) begin
	if(state==PAYMENT) begin
		payment_tens = next_payment_tens;
		payment_units = next_payment_units;
	end
end

always@(posedge clk_div17) begin
	payment_seven_segment <= { DASH,
	  						   DASH,
							   payment_tens,
							   payment_units};
end

always@(posedge clk) begin
	payment_led <= 16'b0;
end

//////////////////////////////////////////////

///////////////// (Buy state) ////////////////
wire [7:0] payment_dec;
assign payment_dec = 4'd10*payment_tens + payment_units;

wire [7:0] price_dec;
assign price_dec = 4'd10*price[7:4] + price[3:0];

wire [7:0] quotient_of_payment_div_price;
wire [7:0] remainder_of_payment_div_price;

division payment_div_price(.A(payment_dec),.B(price_dec),.Res(quotient_of_payment_div_price));
assign remainder_of_payment_div_price = payment_dec - price_dec*buy_item_nums;

reg [3:0] buy_item_nums;
always@(*)begin
	if(quotient_of_payment_div_price > item) buy_item_nums = item;
	else buy_item_nums = quotient_of_payment_div_price[3:0];
end

wire [7:0] need_to_pay;
assign need_to_pay = price_dec*buy_item_nums;

wire [3:0] need_to_pay_tens , need_to_pay_units;
division need_to_pay_div_ten(.A(need_to_pay),.B(10),.Res(need_to_pay_tens));
assign need_to_pay_units = need_to_pay - 4'd10*need_to_pay_tens;

always@(*) begin
	if(state==BUY) begin
		if(buy_state_round%2) buy_seven_segment = { DARK,
		             								DARK,
													DARK,
													DARK};
		else buy_seven_segment = { buy_item_nums,
								   DASH,
								   need_to_pay_tens,
								   need_to_pay_units};
	end
end

always@(*)begin
	if(state==BUY) begin
		if(buy_state_round%2) buy_led = ALL_LED_OFF;
		else buy_led = ALL_LED_ON;
	end
end

reg [26:0] buy_state_counter , next_buy_state_counter;
reg [26:0] buy_state_round , next_buy_state_round;
reg [26:0] _0_5_s = 5*(10**7)-1'b1;
always@(posedge clk) begin
	buy_state_counter <= next_buy_state_counter;
end
always@(*) begin
	if(state==BUY)begin
		if(buy_state_counter == _0_5_s)next_buy_state_counter = 0;	
		else next_buy_state_counter = buy_state_counter + 1'b1;
	end
	else begin
		next_buy_state_counter = 0;
	end
end

always@(posedge clk) begin
	buy_state_round <= next_buy_state_round;
end
always@(*) begin
	if(state==BUY)begin
		if(buy_state_counter == _0_5_s) next_buy_state_round = buy_state_round + 1;	
		else next_buy_state_round = buy_state_round; 
	end
	else begin
		next_buy_state_round = 0;
	end
end

//////////////////////////////////////////////

/////////////// (Change state) //////////////
wire [3:0] remainder_of_payment_div_price_tens;
wire [3:0] remainder_of_payment_div_price_units;

division remainder_of_payment_div_price_div_ten(.A(remainder_of_payment_div_price),.B(10),.Res(remainder_of_payment_div_price_tens));
assign remainder_of_payment_div_price_units = remainder_of_payment_div_price-4'd10*remainder_of_payment_div_price_tens;

always@(*)begin
	if(buy_item_nums==0 || item==0) change_seven_segment = { ZERO,
															 DASH,
															 payment_tens,
															 payment_units}; 
	else change_seven_segment = { buy_item_nums,
								  DASH,
								  remainder_of_payment_div_price_tens,
								  remainder_of_payment_div_price_units}; 
end

always@(posedge clk) begin
	change_led <= ALL_LED_ON; 
end

reg [26:0] change_state_counter , next_change_state_counter;
reg [26:0] _1_s = 10**8-1'b1;
reg [26:0] change_state_round , next_change_state_round;

always@(posedge clk) begin
	change_state_counter <= next_change_state_counter;
end
always@(*) begin
	if(state==CHANGE)begin
		if(change_state_counter == _1_s) next_change_state_counter = 0;	
		else next_change_state_counter = change_state_counter + 1'b1;
	end
	else begin
		next_change_state_counter = 0;
	end
end

always@(posedge clk) begin
	change_state_round <= next_change_state_round;
end
always@(*) begin
	if(state==CHANGE)begin
		if(change_state_counter == _1_s) next_change_state_round = change_state_round + 1;	
		else next_change_state_round = change_state_round; 
	end
	else begin
		next_change_state_round = 0;
	end
end

//////////////////////////////////////////////


//////////////// (state transition) ////////////////

always@(posedge clk) begin
	if(rst_one_pulse) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end
always@(*) begin
	case(state)
		IDLE:begin
			if(btnL_one_pulse) next_state = SET;
			else if(btnR_one_pulse) next_state = PAYMENT;
			else next_state = IDLE;
		end
		SET:begin
			if(!lock && been_ready && key_down[ENTER]) next_state = IDLE;
			else if(btnR_one_pulse) next_state = PAYMENT;
			else next_state = SET;
		end
		PAYMENT:begin
			if( !lock && been_ready && key_down[ENTER] && (payment_dec>=price_dec && item!=0)) next_state = BUY;
			else if( !lock && been_ready && key_down[ENTER] && ((payment_dec< price_dec)||item==0) ) next_state = CHANGE;
			else next_state = PAYMENT;
		end
		BUY:begin
			if(buy_state_round==4'd6) next_state = CHANGE;
			else next_state = BUY;
		end
		CHANGE:begin
			if(change_state_round==2'd3) next_state = DECREASE_ITEM;
			else next_state = CHANGE;
		end
		DECREASE_ITEM:begin
			if(decrease_item==0) next_state = IDLE;
			else next_state = DECREASE_ITEM;
		end
		default: next_state = IDLE;
	endcase
end
//////////////////////////////////////////////////////

///////////////// (keyboard) /////////////////
reg [3:0] key_num;
wire [150:0] key_down;
wire [8:0] last_change;
wire been_ready;

KeyboardDecoder key_de (
	.key_down(key_down),
	.last_change(last_change),
	.key_valid(been_ready),
	.PS2_DATA(PS2_DATA),
	.PS2_CLK(PS2_CLK),
	.rst(rst),
	.clk(clk)
);


reg counter;
always@(posedge clk) begin
	if(key_down[last_change]) begin
		counter <= 1;
	end
	else begin
		counter <= 0;
	end
end

reg lock;
integer i;
always@(*) begin
	if(been_ready && key_down[last_change] == 1'b1) begin
		lock = 0;
		for(i=0;i<=150;i=i+1)begin
			if(key_down[i] && (i!=last_change)) lock = 1;
		end
	end
	if(counter==1) lock=1;
end

reg decrease_item;
always @ (posedge clk) begin
	
	if(state==IDLE) begin		
		next_payment_units <= 4'd0;
		next_payment_tens <= 4'd0;
		decrease_item <= 1;
	end
	if(state==DECREASE_ITEM) begin
		if(decrease_item) item <= item - buy_item_nums;
		decrease_item <= 0;
	end
	
	if (!lock && been_ready && key_down[last_change] == 1'b1) begin
		if (key_num != 4'b1111)begin
			case(state)
				SET:begin
					if(modifyItem) begin
						item <= key_num;
					end
					else begin
						price <= {price[3:0],key_num};
					end
				end
				PAYMENT:begin
					case(key_num)
						4'b0001:begin
							if(payment_units==4'd9)begin
								if(payment_tens==4'd9) begin
									next_payment_units <= 4'd9;
									next_payment_tens <= 4'd9;
								end
								else  begin
									next_payment_units <= 0; 
									next_payment_tens <= payment_tens+4'd1;
								end
							end
							else begin
								next_payment_units <= payment_units+4'd1;
								next_payment_tens <= payment_tens;
							end
						end
						4'b0010:begin
							if(payment_units >= 4'd5)begin
								if(payment_tens==4'd9) begin
									next_payment_units <= 4'd9;
									next_payment_tens <= 4'd9;
								end
								else  begin
									next_payment_units <= ((payment_units+4'd5)%4'd10); 
									next_payment_tens <= payment_tens+4'd1;
								end
							end
							else begin
								next_payment_units <= payment_units+4'd5;
								next_payment_tens <= payment_tens;
							end
						end
						4'b0011:begin
							if(payment_tens == 4'd9)begin
								next_payment_units <= 4'd9;
								next_payment_tens <= 4'd9;
							end
							else begin
								next_payment_units <= payment_units;
								next_payment_tens <= payment_tens+4'd1;
							end
						end
						4'b0100:begin
							if(payment_tens >= 4'd5)begin
								next_payment_units <= 4'd9;
								next_payment_tens <= 4'd9;
							end
							else begin
								next_payment_units <= payment_units;
								next_payment_tens <= payment_tens+4'd5;
							end
						end
						4'b0000:begin
							next_payment_units <= 4'd0;
							next_payment_tens <= 4'd0;
						end
					endcase
				end

			endcase
		end
	end
		

end

always @ (*) begin
	case (last_change)
		KEY_CODES[00] : key_num = 4'b0000;
		KEY_CODES[01] : key_num = 4'b0001;
		KEY_CODES[02] : key_num = 4'b0010;
		KEY_CODES[03] : key_num = 4'b0011;
		KEY_CODES[04] : key_num = 4'b0100;
		KEY_CODES[05] : key_num = 4'b0101;
		KEY_CODES[06] : key_num = 4'b0110;
		KEY_CODES[07] : key_num = 4'b0111;
		KEY_CODES[08] : key_num = 4'b1000;
		KEY_CODES[09] : key_num = 4'b1001;
		KEY_CODES[10] : key_num = 4'b0000;
		KEY_CODES[11] : key_num = 4'b0001;
		KEY_CODES[12] : key_num = 4'b0010;
		KEY_CODES[13] : key_num = 4'b0011;
		KEY_CODES[14] : key_num = 4'b0100;
		KEY_CODES[15] : key_num = 4'b0101;
		KEY_CODES[16] : key_num = 4'b0110;
		KEY_CODES[17] : key_num = 4'b0111;
		KEY_CODES[18] : key_num = 4'b1000;
		KEY_CODES[19] : key_num = 4'b1001;
		default		  : key_num = 4'b1111;
	endcase
end
//////////////////////////////////////////////

endmodule
