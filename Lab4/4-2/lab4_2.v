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

module lab4_2 ( 
    input wire clk,
    input wire rst,
    input wire Digit_1,
    input wire Digit_2,
    input wire Digit_3,
    input wire stop,
    input wire start,
    input wire increase,
    input wire decrease,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg [15:0] led
); 


wire clk_div17;
clock_divider #(17) cd15(.clk(clk),.clk_div(clk_div17));

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

/* increase button */
wire increase_debounce,increase_one_pulse;
debounce dincrease(.clk(clk_div17) ,.pb(increase), .pb_debounced(increase_debounce));
one_pulse oincrease(.clk(clk_div17),.pb_in(increase_debounce),.pb_out(increase_one_pulse));

/* decrease button */
wire decrease_debounce,decrease_one_pulse;
debounce ddecrease(.clk(clk_div17) ,.pb(decrease), .pb_debounced(decrease_debounce));
one_pulse odecrease(.clk(clk_div17),.pb_in(decrease_debounce),.pb_out(decrease_one_pulse));

//////////// 7-segment signal ////////////
parameter UP    = 4'd10;
parameter DOWN  = 4'd11;
parameter DASH  = 4'd12;
parameter BIG_F = 4'd13;
parameter BIG_S = 4'd14;
///////////////////////////////////////////

/////////////// MAIN STATE ///////////////
parameter INITIAL=2'b00;
parameter COUNTING=2'b01;
parameter SUCCESS=2'b10;
parameter FAIL=2'b11;
//////////////////////////////////////////

////////////////// led ///////////////////
parameter ALL_LED_LIGHT = 16'b1111_1111_1111_1111;
parameter ALL_LED_DARK  = 16'b0000_0000_0000_0000;
/////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////// (Initial state)  ////////////////////////////////////////
reg [3:0] counting_direction,next_counting_direction;
reg [3:0] answer_digit_1, next_answer_digit_1;
reg [3:0] answer_digit_2, next_answer_digit_2;
reg [3:0] answer_digit_3, next_answer_digit_3;

// answer
reg [9:0] answer_decimal;
always@(*) answer_decimal = 10'd100*answer_digit_3 + 10'd10*answer_digit_2 + answer_digit_1;

// upper_bound_answer 、 lower_bound_answer
reg [9:0] upper_bound_answer,lower_bound_answer;
always@(*) begin
    upper_bound_answer = (answer_decimal > 10'd899) ? 10'd999 : answer_decimal + 10'd100;
    lower_bound_answer = (answer_decimal < 10'd100) ? 10'd0   : answer_decimal - 10'd100;
end

always@(posedge clk_div17,posedge rst) begin
    if(rst) begin
        answer_digit_1 <= 0;
        answer_digit_2 <= 0;
        answer_digit_3 <= 0;

    end
    else begin
        answer_digit_1 <= next_answer_digit_1;
        answer_digit_2 <= next_answer_digit_2;
        answer_digit_3 <= next_answer_digit_3;
    end
end
always@(*) begin
    if(state==INITIAL) begin
        /* answer digit 1*/
        if(Digit_1==1 && increase_one_pulse) next_answer_digit_1 = (answer_digit_1==4'd9) ? 4'd0 : answer_digit_1+1'b1;
        else if(Digit_1==1 && decrease_one_pulse) next_answer_digit_1 = (answer_digit_1==4'd0) ? 4'd9 : answer_digit_1-1'b1;
        else next_answer_digit_1 = answer_digit_1;

        /* answer digit 2*/
        if(Digit_2==1 && increase_one_pulse) next_answer_digit_2 = (answer_digit_2==4'd9) ? 4'd0 : answer_digit_2+1'b1;
        else if(Digit_2==1 && decrease_one_pulse) next_answer_digit_2 = (answer_digit_2==4'd0) ? 4'd9 : answer_digit_2-1'b1;
        else next_answer_digit_2 = answer_digit_2;
        
        /* answer digit 3*/
        if(Digit_3==1 && increase_one_pulse) next_answer_digit_3 = (answer_digit_3==4'd9) ? 4'd0 : answer_digit_3+1'b1;
        else if(Digit_3==1 && decrease_one_pulse) next_answer_digit_3 = (answer_digit_3==4'd0) ? 4'd9 : answer_digit_3-1'b1;
        else next_answer_digit_3 = answer_digit_3;
    end
    else begin
        next_answer_digit_1 = answer_digit_1;
        next_answer_digit_2 = answer_digit_2;
        next_answer_digit_3 = answer_digit_3;
    end
end

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


////////////////////////////////// (Counting state)  ////////////////////////////////////////
reg [9:0] BCD,next_BCD;
reg [3:0] units;
reg [3:0] tens;
reg [3:0] hundreds;
always @(*) begin
    hundreds = BCD / 100;
    tens = (BCD /10) % 10;
    units = BCD % 10;
end

// (BCD)
reg [26:0] counting_0_01_seconds_counter, next_counting_0_01_seconds_counter; 
always@(posedge clk) begin
    BCD <= next_BCD;
end
always@(*) begin
    if(state==INITIAL) begin
        next_BCD = (counting_direction==UP) ? 10'd0 : 10'd999;
    end
    else if(state==COUNTING && (counting_0_01_seconds_counter == 10**6-1'b1)) begin
        if(counting_direction==DOWN && BCD==10'd0) next_BCD = 0;
        else if(counting_direction==UP && BCD==10'd999) next_BCD = 999;
        else next_BCD = (counting_direction==UP) ? BCD + 1 : BCD - 1;
    end
    else begin
        next_BCD = BCD;
    end
end
//

// (counting_0_01_seconds_counter)
always @(posedge clk) begin 
    counting_0_01_seconds_counter <= next_counting_0_01_seconds_counter ; 
end
always @(*) begin
    if(state==INITIAL) begin
        next_counting_0_01_seconds_counter = 0;
    end
    else if(state==COUNTING) begin 
        if (counting_0_01_seconds_counter == 10**6-1'b1) next_counting_0_01_seconds_counter = 0;
        else next_counting_0_01_seconds_counter = counting_0_01_seconds_counter + 1'b1;
    end
    else begin
        next_counting_0_01_seconds_counter = counting_0_01_seconds_counter;
    end
end
//



// (counting_1_seconds_counter) 
reg [26:0]   counting_1_seconds_counter,next_counting_1_seconds_counter;
always @(posedge clk) begin 
    counting_1_seconds_counter <= next_counting_1_seconds_counter;
end
always @(*) begin
    if(state==INITIAL) begin
        next_counting_1_seconds_counter = 0;
    end
    else if(state==COUNTING) begin 
        if (counting_1_seconds_counter == 10**8-1'b1) begin
            next_counting_1_seconds_counter = 0;
        end
        else begin
            next_counting_1_seconds_counter = counting_1_seconds_counter +1;
        end
    end
    else begin
        next_counting_1_seconds_counter = counting_1_seconds_counter;
    end
end
//

// (counting_1_seconds) 
reg [1:0]  counting_1_seconds,next_counting_1_seconds;

always @(posedge clk) begin 
    counting_1_seconds <= next_counting_1_seconds ; 
end

always @(*) begin
    if(state==INITIAL) begin
        next_counting_1_seconds = 0;
    end
    else if(state==COUNTING && counting_1_seconds < 2'd3) begin 
        if (counting_1_seconds_counter == 10**8-1'b1) begin
            next_counting_1_seconds = counting_1_seconds + 1'b1;
        end
        else begin
            next_counting_1_seconds = counting_1_seconds;
        end
    end
    else begin
        next_counting_1_seconds = counting_1_seconds;
    end
end
//

// (counting led) 
reg[15:0] counting_led,next_counting_led;
always @(posedge clk) begin 
    counting_led <= next_counting_led ; 
end

always @(*) begin
    if(state==INITIAL) begin
        next_counting_led = ALL_LED_LIGHT;
    end
    else if(state==COUNTING) begin 
        next_counting_led = (counting_1_seconds < 2'd3) ? ALL_LED_LIGHT : ALL_LED_DARK;
    end
    else begin
        next_counting_led = counting_led;
    end
end
//

////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////// (Result state)  ////////////////////////////////////////
reg [15:0] result_led, next_result_led;
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
        next_result_led = ALL_LED_LIGHT; 
        next_result_round = 0;
    end
    else if((state==SUCCESS) && result_round < 3'd4) begin 
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
    else if((state==FAIL) && result_round < 3'd5) begin 
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
            if(start_one_pulse) next_state = COUNTING;
            else next_state = INITIAL;
        end

        COUNTING : begin
            if(stop_one_pulse && BCD >= lower_bound_answer && BCD <= upper_bound_answer) next_state = SUCCESS;
            else if(stop_one_pulse && !(BCD >= lower_bound_answer && BCD <= upper_bound_answer)) next_state = FAIL;
            else if(BCD==10'd999 && counting_direction==UP  ) next_state = FAIL;
            else if(BCD==10'd0   && counting_direction==DOWN) next_state = FAIL;
            else next_state = COUNTING;
        end

        FAIL : begin
            if(start_one_pulse) next_state = INITIAL;
            else next_state = FAIL;
        end

        SUCCESS : begin
            if(start_one_pulse) next_state = INITIAL;
            else next_state = SUCCESS;
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
                    next_value = answer_digit_2;
                    next_DIGIT = 4'b1101;
                end
                4'b1101: begin
                    next_value = answer_digit_3;
                    next_DIGIT = 4'b1011;
                end
                4'b1011: begin
                    next_value = counting_direction;
                    next_DIGIT = 4'b0111;
                end
                4'b0111: begin
                    next_value = answer_digit_1;
                    next_DIGIT = 4'b1110;
                end
                default: begin
                    next_value = answer_digit_1;
                    next_DIGIT = 4'b1110;
                end
            endcase
        end

        COUNTING:begin
            if(counting_1_seconds < 2'd3) begin
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
            else begin
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
        end

        FAIL:begin
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
                    next_value = BIG_F;
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

        SUCCESS:begin
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
                    next_value = BIG_S;
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
        BIG_F:   DISPLAY = 7'b000_1110;
        BIG_S:   DISPLAY = 7'b001_0010;
        default: DISPLAY = 7'b111_1111;
    endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////  (basay3 led)  /////////////////////////////////////
always@(*) begin
    case(state) 
        INITIAL : begin
            led = ALL_LED_LIGHT;
        end
        COUNTING : begin
            led = counting_led;
        end
        FAIL, SUCCESS: begin
            led = result_led;
        end 
    endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////

endmodule 