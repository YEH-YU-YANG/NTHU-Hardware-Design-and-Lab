`timescale 1ns/1ps
module Parameterized_Ping_Pong_Counter (
    input clk, 
    input rst_n, 
    input enable, 
    input flip, 
    input [3:0] max, 
    input [3:0] min, 
    output reg direction, 
    output reg [3:0] out
);


`define DECREASE 1'b0
`define INCREASE 1'b1

// Output signals can be reg or wire
// add your design here
reg [3:0] next_out;
reg next_direction;
reg hold_value;

///// hold value /////
///// ((max==min) && (min==out))  is (max!=min || min!=out) /////
always@* begin
    if(max === 4'bx || min === 4'bx || out === 4'bx) 
        hold_value = 1'b0;
    else 
        hold_value = (out > max || max <= min || out < min || (max == min && min == out));
end
//////////////////// 


///// sequential block /////
always @(posedge clk) begin
    
    if(!rst_n && !hold_value) begin
        out <= min;
        direction <= `INCREASE;
    end 
    else begin
        out <= next_out ;
        direction <= next_direction;
    end    
end
////////////////////


///// next_direction /////
always @(*) begin
    next_direction = direction;
    if(enable && !hold_value) begin
        if(flip) next_direction = ~direction;
        if(out == max) next_direction = `DECREASE;
        if(out == min) next_direction = `INCREASE;
    end
end
////////////////////


///// next_out /////
always @(*) begin
    next_out = out;
    if(enable && !hold_value) begin
        next_out = (next_direction == `INCREASE) ? out + 4'b0001 : out - 4'b0001;
    end
end
////////////////////

endmodule
