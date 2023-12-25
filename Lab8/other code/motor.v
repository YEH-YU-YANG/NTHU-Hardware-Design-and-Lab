// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [2:0]mode,
    input stop,
    output [1:0]pwm,
    output reg [1:0]motorA,
    output reg [1:0]motorB
);

    reg [9:0] motorB_speed  , next_motorB_speed ;
    reg [9:0] motorA_speed , next_motorA_speed ;

    wire left_pwm, right_pwm;

    motor_pwm m0(
        .clk(clk), 
        .reset(rst), 
        .duty(motorB_speed), 
        .pmod_1(left_pwm)
    );
    motor_pwm m1(
        .clk(clk), 
        .reset(rst), 
        .duty(motorA_speed), 
        .pmod_1(right_pwm)
    );

    assign pwm = {left_pwm,right_pwm};

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    
    // car state
    parameter car_left    = 3'd2;
    parameter car_right   = 3'd5;
    parameter car_forward = 3'd6;
    parameter car_stop    = 3'd7;

    // speed state
    parameter speed_stop   = 10'd0;
    parameter speed_fast   = 10'd750;
    parameter speed_fast_2 = 10'd765;

    always@(posedge clk) begin
        if(rst) begin
            motorB_speed  <= 0;
            motorA_speed  <= 0;
        end
        else begin
            motorB_speed  <= next_motorB_speed ;
            motorA_speed  <= next_motorA_speed ;
        end
    end    

    always@(*) begin
        if(stop) begin 
            {next_motorB_speed, next_motorA_speed} = {speed_stop, speed_stop};
        end
        else begin
            case(mode)
                car_left    : { next_motorB_speed, next_motorA_speed } = { speed_stop   , speed_fast };
                car_right   : { next_motorB_speed, next_motorA_speed } = { speed_fast   , speed_stop };
                car_forward : { next_motorB_speed, next_motorA_speed } = { speed_fast_2 , speed_fast };
                car_stop    : { next_motorB_speed, next_motorA_speed } = { speed_stop   , speed_stop };
                default: begin
                    next_motorB_speed  = speed_stop;
                    next_motorA_speed  = speed_stop;
                end     
            endcase
        end
    end

    parameter motor_off  = 2'b00;
    parameter B_forward  = 2'b10;
    parameter B_backward = 2'b01;
    parameter A_forward  = 2'b01;
    parameter A_backward = 2'b10;

    always @(*) begin
        if(stop) begin 
            {motorB,motorA} = {motor_off , motor_off};
        end
        else begin
            case(mode)

                car_left    : { motorB, motorA } = { motor_off , A_forward };
                car_right   : { motorB, motorA } = { B_forward , motor_off };
                car_forward : { motorB, motorA } = { B_forward , A_forward };
                car_stop    : { motorB, motorA } = { motor_off , motor_off };
                default     : { motorB, motorA } = { motor_off , motor_off };

            endcase
        end
    end

endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if(count < count_duty) begin
                PWM <= 1'b1;
            end
            else begin
                PWM <= 1'b0;
            end

        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

