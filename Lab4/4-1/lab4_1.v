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


module lab4_1 ( 
    input wire clk,
    input wire rst,
    input wire stop,
    input wire start,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg [9:0] led
); 

//////////// 7-segment signal ////////////
parameter UP    = 4'd10;
parameter DOWN  = 4'd11;
parameter DASH  = 4'd12;
parameter BIG_P = 4'd13;
parameter EMPTY = 4'd14;
///////////////////////////////////////////


/////////////// MAIN STATE ///////////////
parameter INITIAL=2'b00;
parameter PREPARE=2'b01;
parameter COUNTING=2'b10;
parameter RESULT=2'b11;
//////////////////////////////////////////


wire clk_div17;
clock_divider #(17) cd15(.clk(clk),.clk_div(clk_div17));

// wire clk_1s;
// exactly_clock_divider #(1) ecd1(.clk_in(clk),.clk_out(clk_1s));

// wire clk_0_01s;
// exactly_clock_divider #(100) ecd2(.clk_in(clk),.clk_out(clk_0_01s));

/* stop button */
wire stop_debounce,stop_one_pulse;
debounce dstop(.clk(clk_div17) ,.pb(stop), .pb_debounced(stop_debounce));
one_pulse ostop(.clk(clk_div17),.pb_in(stop_debounce),.pb_out(stop_one_pulse));

/* start button */
wire start_debounce,start_one_pulse;
debounce dstart(.clk(clk_div17) ,.pb(start), .pb_debounced(start_debounce));
one_pulse ostart(.clk(clk_div17),.pb_in(start_debounce),.pb_out(start_one_pulse));

/* direction button */
wire  direction_debounce,direction_one_pulse;
debounce ddirection(.clk(clk_div17) ,.pb(direction), .pb_debounced(direction_debounce));
one_pulse odirection(.clk(clk_div17),.pb_in(direction_debounce),.pb_out(direction_one_pulse));



///////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////
reg [1:0] state , next_state;
always@(posedge clk_div17,posedge rst) begin
    if(rst) begin
        // Asynchronous positive reset signal, reset the counter back to the INITIAL state
        state <= INITIAL;
    end
    else begin
        state <= next_state;
    end
end


////////////////////////////////// (Initial state)  ////////////////////////////////////////
reg [3:0] counting_direction,next_counting_direction;

always@(posedge clk_div17,posedge rst) begin

    if(rst) begin
        // After reset, the direction will be set as UP.
        counting_direction <= UP;    
    end
    else begin      
        counting_direction <= next_counting_direction;
    end

end

always@(*) begin
    case(state) 
        INITIAL : begin
            if(direction_one_pulse) next_counting_direction = (counting_direction==UP) ? DOWN : UP;
            else next_counting_direction = counting_direction;
        end
        default: 
            next_counting_direction = counting_direction;
    endcase
end
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////// (Prepare state)  ////////////////////////////////////////
reg [26:0] prepare_time_counter, next_prepare_time_counter; 
reg [1:0] prepare_round , next_prepare_round;

always @(posedge clk) begin 
        prepare_time_counter <= next_prepare_time_counter ; 
        prepare_round <= next_prepare_round;
end

always @(*) begin
    if(state==INITIAL) begin
        next_prepare_time_counter = 0;
        next_prepare_round = 0;
    end
    else if(state==PREPARE) begin 
        if (prepare_time_counter == 10**8-1'b1) begin 
            next_prepare_time_counter = 0;
            next_prepare_round = prepare_round + 1;
        end
        else begin
            next_prepare_time_counter = prepare_time_counter + 1'b1;
            next_prepare_round = prepare_round;
        end
    end
    else begin
        next_prepare_time_counter = prepare_time_counter;
        next_prepare_round = prepare_round;
    end
end
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////// (Counting state)  ////////////////////////////////////////
reg [9:0] BCD,next_BCD;
reg [3:0] units;
reg [3:0] tens;
reg [3:0] hundreds;
always @(*) begin
    if(BCD > 10'd99) begin
        hundreds = BCD / 100;
        tens = (BCD /10) % 10;
        units = BCD % 10;
    end
    else if(BCD > 10'd9) begin
        hundreds = 0;
        tens = (BCD /10) % 10;
        units = BCD % 10;
    end
    else begin
        hundreds = 0;
        tens = 0;
        units = BCD % 10;
    end
end

always@(posedge clk) begin
    BCD <= next_BCD;
end

reg [26:0] counting_time_counter, next_counting_time_counter; 
always@(*) begin
    if(state==PREPARE) begin
        next_BCD = (counting_direction==UP) ? 10'd0 : 10'd999;
    end
    else if(state==COUNTING && (counting_time_counter == 10**6-1'b1)) begin
        if(counting_direction==DOWN && BCD==10'd0) next_BCD = 0;
        else if(counting_direction==UP && BCD==10'd999) next_BCD = 999;
        else next_BCD = (counting_direction==UP) ? BCD + 1 : BCD - 1;
    end
    else begin
        next_BCD = BCD;
    end
end

always @(posedge clk) begin 
    counting_time_counter <= next_counting_time_counter ; 
end

always @(*) begin
    if(state==INITIAL) begin
        next_counting_time_counter = 0;
    end
    else if(state==COUNTING) begin 
        if (counting_time_counter == 10**6-1'b1) next_counting_time_counter = 0;
        else next_counting_time_counter = counting_time_counter + 1'b1;
    end
    else begin
        next_counting_time_counter = counting_time_counter;
    end
end
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////// (Result state)  ////////////////////////////////////////
reg [9:0] result_led, next_result_led;
reg [26:0] result_time_counter, next_result_time_counter; 
reg [2:0] result_round , next_result_round;

always @(posedge clk) begin 
        result_time_counter <= next_result_time_counter ; 
        result_round <= next_result_round;
        result_led <= next_result_led; 
end

always @(*) begin
    if(state==INITIAL) begin
        next_result_time_counter = 0;
        next_result_led = 10'b11_1111_1111; 
        next_result_round = 0;
    end
    else if(state==RESULT && result_round < 3'd4) begin 
        if (result_time_counter == 10**8-1'b1) begin 
            next_result_time_counter = 0;
            next_result_led = ~result_led; 
            next_result_round = result_round + 1;
        end
        else begin
            next_result_time_counter = result_time_counter + 1'b1;
            next_result_led = result_led;
            next_result_round = result_round;
        end
    end
    else begin
        next_result_time_counter = result_time_counter;
        next_result_led = result_led;
        next_result_round = result_round;
    end
end
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////// state transition /////////////////////////////////////////
always@(*) begin
    case(state) 
        INITIAL : begin
            if(start_one_pulse) next_state = PREPARE;
            else next_state = INITIAL;
        end

        PREPARE : begin
            if(prepare_round==2'd3) next_state = COUNTING;
            else next_state = PREPARE;
        end

        COUNTING : begin
            if(stop_one_pulse) next_state = RESULT;
            else if(BCD==10'd000 && counting_direction == DOWN) next_state = RESULT;
            else if(BCD==10'd999 && counting_direction == UP) next_state = RESULT;
            else next_state = COUNTING;
        end

        RESULT : begin
            if(start_one_pulse) next_state = INITIAL;
            else next_state = RESULT;
        end
    endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////  (basay3 7-segment)  /////////////////////////////////// 
reg [3:0] value, next_value, next_DIGIT;
always@(posedge clk_div17) begin
    value <= next_value;
    DIGIT <= next_DIGIT;
end

always@(*) begin
    case(state)
        INITIAL:begin
            case (DIGIT)
                4'b1110: begin
                    next_value = DASH;
                    next_DIGIT = 4'b1101;
                end
                4'b1101: begin
                    next_value = DASH;
                    next_DIGIT = 4'b1011;
                end
                4'b1011: begin
                    next_value = counting_direction;
                    next_DIGIT = 4'b0111;
                end
                4'b0111: begin
                    next_value = DASH;
                    next_DIGIT = 4'b1110;
                end
                default: begin
                    next_value = DASH;
                    next_DIGIT = 4'b1110;
                end
            endcase
        end
        PREPARE:begin
            case (DIGIT)
                4'b1110: begin
                    next_value = EMPTY;
                    next_DIGIT = 4'b1101;
                end
                4'b1101: begin
                    next_value = EMPTY;
                    next_DIGIT = 4'b1011;
                end
                4'b1011: begin
                    next_value = BIG_P;
                    next_DIGIT = 4'b0111;
                end
                4'b0111: begin
                    next_value = EMPTY;
                    next_DIGIT = 4'b1110;
                end
                default: begin
                    next_value = EMPTY;
                    next_DIGIT = 4'b1110;
                end
            endcase
        end
        COUNTING,RESULT:begin
            case (DIGIT)
                4'b1110: begin
                    next_value = tens;
                    next_DIGIT = 4'b1101;
                end
                4'b1101: begin
                    next_value = hundreds;
                    next_DIGIT = 4'b1011;
                end
                4'b1011: begin
                    next_value = counting_direction;
                    next_DIGIT = 4'b0111;
                end
                4'b0111: begin
                    next_value = units;
                    next_DIGIT = 4'b1110;
                end
                default: begin
                    next_value = units;
                    next_DIGIT = 4'b1110;
                end
            endcase
        end
    endcase
end

always @(*) begin
    case (value)        
        4'd0:    DISPLAY = 7'b100_0000;
        4'd1:    DISPLAY = 7'b111_1001;
        4'd2:    DISPLAY = 7'b010_0100;
        4'd3:    DISPLAY = 7'b011_0000;
        4'd4:    DISPLAY = 7'b001_1001;
        4'd5:    DISPLAY = 7'b001_0010;
        4'd6:    DISPLAY = 7'b000_0010;
        4'd7:    DISPLAY = 7'b111_1000;
        4'd8:    DISPLAY = 7'b000_0000;
        4'd9:    DISPLAY = 7'b001_0000;

        UP:      DISPLAY = 7'b101_1100;
        DOWN:    DISPLAY = 7'b110_0011; 
        DASH:    DISPLAY = 7'b011_1111;
        BIG_P:   DISPLAY = 7'b000_1100;
        EMPTY:   DISPLAY = 7'b111_1111;
        
        default: DISPLAY = 7'b111_1111;
    endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////  (basay3 led)  /////////////////////////////////////
parameter ALL_LED_LIGHT = 10'b11_1111_1111;
parameter ALL_LED_DARK  = 10'b00_0000_0000;

always@(*) begin
    case(state) 
        INITIAL : begin
            led = ALL_LED_LIGHT;
        end

        PREPARE : begin
            led = ALL_LED_DARK;
        end

        COUNTING : begin
            case(hundreds)
                4'd0: led = 10'b00_0000_0001;
                4'd1: led = 10'b00_0000_0010;
                4'd2: led = 10'b00_0000_0100;
                4'd3: led = 10'b00_0000_1000;
                4'd4: led = 10'b00_0001_0000;
                4'd5: led = 10'b00_0010_0000;
                4'd6: led = 10'b00_0100_0000;
                4'd7: led = 10'b00_1000_0000;
                4'd8: led = 10'b01_0000_0000;
                4'd9: led = 10'b10_0000_0000;
                default: led = ALL_LED_LIGHT;
            endcase
        end

        RESULT : begin
            led = result_led;
        end
    endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////
endmodule 

// module exactly_clock_divider #(
//     parameter target_frequency=1
// )(
//     input clk_in,
//     output reg clk_out
// );
// reg [26:0] counter=0, next_counter;
// reg [26:0] MAX=10**8/target_frequency/2;
// always @(posedge clk_in) begin
//     if (counter == MAX-1'b1) begin
//         counter <= 0;
//         clk_out <= ~clk_out;
//     end else begin
//         counter <= next_counter;
//         clk_out <= clk_out;
//     end
// end
// always @(*) begin
//     next_counter = counter + 1'b1;
// end
// endmodule