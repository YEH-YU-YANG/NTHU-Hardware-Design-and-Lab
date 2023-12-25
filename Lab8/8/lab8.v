module Lab8(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    output wire trig,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    output wire [6:0] display,
	output wire [3:0] digit,
    // You may modify or add more input/ouput yourself.
    output stop,
    output l_signal,
    output m_signal,
    output r_signal
);

    wire clk_div17;
    clock_divider #(17) clk17(.clk(clk),.clk_div(clk_div17));

    /* rst(BTNC) button */
    wire rst_debounce,rst_one_pulse;
    debounce drst(.clk(clk_div17) ,.pb(rst), .pb_debounced(rst_debounce));
    one_pulse orst(.clk(clk_div17),.pb_in(rst_debounce),.pb_out(rst_one_pulse));

    reg [15:0] nums;
    always@(*) begin
        nums[15:12] = IN3;
        nums[11:8] = IN4;
        nums[7:4] = IN1;
        nums[3:0] = IN2;
    end

    SevenSegment basys3_7_segment(.display(display),.digit(digit),.nums(nums),.rst(rst_one_pulse),.clk(clk));
    
    assign l_signal = left_track;
    assign m_signal = mid_track;
    assign r_signal = right_track;
    assign output_echo = echo;
    assign output_trig = trig;


    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    wire [2:0] state;
    wire  [19:0] distance;
    
    assign stop = (distance <= 21'd30) ? 1'b1 :1'b0;

    motor A(
        .clk(clk),
        .rst(rst_one_pulse),
        .mode(state),
        .stop(stop),
        .pwm({left_pwm, right_pwm}),
        .motorA({IN1, IN2}),
        .motorB({IN3, IN4})
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst_one_pulse), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );

    tracker_sensor C(
        .clk(clk),
        .reset(rst_one_pulse), 
        .left_track(left_track), 
        .right_track(right_track), 
        .mid_track(mid_track), 
        .state(state)
    );

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
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule