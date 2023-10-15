`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter_t;

`define DECREASE 1'b0
`define INCREASE 1'b1

// input signal
reg clk=1'b0;
reg rst_n=1'b0;
reg enable=1'b1;
reg flip=1'b0;
reg [3:0] max;
reg [3:0] min;

// output signal
wire [3:0]out;
wire direction;

// connect module
Parameterized_Ping_Pong_Counter pp(
    .clk(clk), 
    .rst_n(rst_n), 
    .enable(enable), 
    .flip(flip), 
    .max(max), 
    .min(min), 
    .direction(direction), 
    .out(out)
);

always #5 clk = ~clk;

always begin 
    #130 
    @(negedge clk) rst_n = ~rst_n;
    #10 
    @(negedge clk) rst_n = ~rst_n;
end

always begin
    #100
    if(out < max && out > min) begin
        #200
        @(negedge clk) flip=~flip;
        #10 
        @(negedge clk) flip=~flip;
        #30
        @(negedge clk) flip=~flip;
        #10 
        @(negedge clk) flip=~flip;
    end
end

// 測試enable=1'b0的時候，會不會hold current value
always begin
    #230 
    @(negedge clk) enable = ~enable;
    #20 
    @(negedge clk) enable = ~enable;
end

// reg [3:0] tmp;

initial begin

    ///// initial /////
    {min,max} = {4'd0,4'd4};    
    #10 
    @(negedge clk) rst_n = ~rst_n;
    ////////////////////

    ///// min < max ///// 
    #50
    @(negedge clk) {min,max} = {4'd3,4'd10};
    #300
    @(negedge clk) {min,max} = {4'd0,4'd15};
    ////////////////////
    
    ///// min > max /////
    #500
    @(negedge clk) {min,max} = {4'd7,4'd2};
    #500
    @(negedge clk) {min,max} = {4'd15,4'd9};
    ////////////////////

    ///// min == max /////
    #500
    @(negedge clk) {min,max} = {4'd7,4'd7};
    #500
    @(negedge clk) {min,max} = {4'd15,4'd15};
    #500
    @(negedge clk) {min,max} = {4'd0,4'd0};
    ////////////////////
    

    #500
    @(negedge clk) {min,max} = {4'd0,4'd13};

    #500
    repeat (20) begin
        @(negedge clk) {min,max} = {$random%16 , $random%16};
        #500;
    end
    

    #500
    $stop;
end




endmodule