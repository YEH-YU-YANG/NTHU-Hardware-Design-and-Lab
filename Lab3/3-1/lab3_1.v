`timescale 1ns / 1ps
module clock_divider #(parameter n = 25) (clk,clk_div);
    input clk;
    output clk_div;
    reg[n-1:0]num;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_1(
    input clk,
    input rst,
    input en,
    input speed,
    output reg[15:0] led
);

// add your design here
reg [3:0] state=0, next_state=0;

//directly use two clock in our mudule
wire clk_div25,clk_div27;
clock_divider #(25) div1(.clk(clk), .clk_div(clk_div25));
clock_divider #(27) div2(.clk(clk), .clk_div(clk_div27));
assign current_clk = speed ? clk_div25 :clk_div27;

always@(posedge current_clk,posedge rst) begin
    
    if(rst) begin
        led <= 15'b0;
        state <= 3'b000;
    end

    else begin
        state <= next_state;
    end

    case(state) 
        0: begin
            led <= 15'b0;
        end
        
        1: begin
            led[15] <= 1;
            led[11] <= 1;
            led[7] <= 1;
            led[3] <= 1;
        end
        2: begin
            led[14] <= 1;
            led[10] <= 1;
            led[6] <= 1;
            led[2] <= 1;
        end
        3: begin
            led[13] <= 1;
            led[9] <= 1;
            led[5] <= 1;
            led[1] <= 1;
        end
        4: begin
            led[12] <= 1;
            led[8] <= 1;
            led[4] <= 1;
            led[0] <= 1;
        end
        5: begin
            led <= 15'b0;
        end
    endcase
end

always @(*) begin
    if(en) 
        next_state = (state==3'b101) ? 3'b000 : state + 3'b001;
    else 
        next_state = state;
end


endmodule