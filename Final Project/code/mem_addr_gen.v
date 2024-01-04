  module mem_addr_gen(
    input clk,
    input rst,
    input [9:0] x,
    input [9:0] y,
    
    input [9:0] chair_left,
    input [9:0] chair_up,

    input [9:0] ghost1_up,
    input [9:0] ghost1_left,

    input [9:0] ghost2_up,
    input [9:0] ghost2_left,

    input [9:0] people_left,
    input [9:0] people_up,

    output reg [16:0] carbinet_addr,
    output reg [16:0] key_addr,
    output reg [16:0] chair_addr,
    output reg [16:0] ghost1_addr,
    output reg [16:0] ghost2_addr,
    output reg [16:0] apple_addr,
    output reg [16:0] people_addr
);

    always@(posedge clk) begin
        // if(330<=x && x<=400 && 45<=y && y<115) carbinet_addr <= ((x-330)>>1) + 35*((y - 45)>>1);
        // else carbinet_addr <= 0;
        
        if(360<=x && x<=380 && 35<=y && y<=55) key_addr <= (x-360)+20*(y-35);
        else key_addr <= 0;

        if(chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1) chair_addr <= ((x-chair_left)>>1)+20*((y-chair_up)>>1);
        else chair_addr <= 0;
        
        if(ghost1_left<=x && x<=ghost1_left+30-1 && ghost1_up<=y && y<=ghost1_up+30-1) ghost1_addr <= ((x-330)>>1) + 35*((y - 45)>>1);
        else ghost1_addr <= 0;

        if(ghost2_left<=x && x<=ghost2_left+30-1 && ghost2_up<=y && y<=ghost2_up+30-1) ghost2_addr <= ((x-330)>>1) + 35*((y - 45)>>1);
        else ghost2_addr <= 0;

        if(380<=x && x<=400 && 70<=y && y<=90) apple_addr <= ((x-330)>>1) + 35*((y - 45)>>1);
        else apple_addr <= 0;

        if(people_left<=x && x<=people_left+39 && people_up<=y && y<=people_up+39) people_addr <= (x - people_left) + 40*(y - people_up);
        else people_addr <=0;
    end

endmodule