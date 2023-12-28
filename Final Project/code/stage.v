`define WALL_COLOR 12'hDCD 
`define BACK_GROUND_COLOR 12'h0FF 

module stage_top_control(
    input clk,
   	input rst,
    input valid,
   	input [9:0] x,
   	input [9:0] y,

    input [9:0] people_left_border,
    input [9:0] people_right_border,
    input [9:0] people_up_border,
    input [9:0] people_down_border,
    input [11:0] people_pixel,

    output reg [3:0] vgaR,
    output reg [3:0] vgaG,
    output reg [3:0] vgaB
);

    wire [11:0] stage1_rgb;
	stage1_rgb_gen m(.valid(valid), .x(x), .y(y), 
                     .people_left_border(people_left_border),.people_right_border(people_right_border),.people_up_border(people_up_border),.people_down_border(people_down_border), .people_pixel(people_pixel), 
                     .vgaR(stage1_rgb[11:8]),.vgaG(stage1_rgb[7:4]),.vgaB(stage1_rgb[3:0]));
 
    reg [4:0] state=1;
    // vga
    always@(*) begin
        
        case(state)
            1: {vgaR, vgaG, vgaB} = stage1_rgb;
            default {vgaR, vgaG, vgaB} = stage1_rgb;
        endcase
        
        if( people_left_border+1 < x && x < people_right_border && 
            people_up_border   < y && y < people_down_border  && people_pixel!=`BACK_GROUND_COLOR) begin
            {vgaR, vgaG, vgaB} = people_pixel;
        end
    
    end

endmodule

module stage1_rgb_gen(

    input valid,
   	input [9:0] x,
   	input [9:0] y,

    input [9:0] people_left_border,
    input [9:0] people_right_border,
    input [9:0] people_up_border,
    input [9:0] people_down_border,
    input [11:0] people_pixel,

    output reg [3:0] vgaR,
    output reg [3:0] vgaG,
    output reg [3:0] vgaB

);
    
    always @* begin
       
        if(!valid) {vgaR, vgaG, vgaB} = 12'd0;
        
        {vgaR, vgaG, vgaB} = 12'h000;

        // wall
        if(120<=x && x<=220 && 155<=y && y<=220) {vgaR, vgaG, vgaB} = `WALL_COLOR;
        if(220<=x && x<=250 && 15<=y && y<=75) {vgaR, vgaG, vgaB}   = `WALL_COLOR;
        if(290<=x && x<=320 && 15<=y && y<=75) {vgaR, vgaG, vgaB}   = `WALL_COLOR;
        if(320<=x && x<=350 && 150<=y && y<=185) {vgaR, vgaG, vgaB} = `WALL_COLOR;
        if(420<=x && x<=520 && 155<=y && y<=220) {vgaR, vgaG, vgaB} = `WALL_COLOR;
      
        // // floor2
        if(220<=x && x<=420 && 380<=y && y<=440) {vgaR, vgaG, vgaB} = 12'h853;
        if(310<=x && x<=340 && 440<=y && y<=460) {vgaR, vgaG, vgaB} = 12'h853;

        //floor1
        if(120<=x && x<=220 && 150<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h940;
        if(420<=x && x<=520 && 150<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h940;
        
        if(220<=x && x<=250 && 10<=y && y<=15) {vgaR, vgaG, vgaB} = 12'h940;
        if(290<=x && x<=320 && 10<=y && y<=15) {vgaR, vgaG, vgaB} = 12'h940;
        
        if(320<=x && x<=350 && 145<=y && y<=150) {vgaR, vgaG, vgaB} = 12'h940;
        if(320<=x && x<=350 && 185<=y && y<=220) begin
            // if(y%20==0) {vgaR, vgaG, vgaB} = 12'h520;
            {vgaR, vgaG, vgaB} = 12'h940;
        end
        if(220<=x && x<=320 && 75<=y && y<=220) begin
            // if(y%20==0) {vgaR, vgaG, vgaB} = 12'h520;
            {vgaR, vgaG, vgaB} = 12'h940;
        end
        if(350<=x && x<=420 && 10<=y && y<=220) {vgaR, vgaG, vgaB} = 12'h940;

        if(120<=x && x<=520 && 220<=y && y<=350) begin
            // if(y%20==0) {vgaR, vgaG, vgaB} = 12'h520;
            {vgaR, vgaG, vgaB} = 12'h940;
        end
        if(220<=x && x<=420 && 350<=y && y<=380) begin
            // if(y%20==0) {vgaR, vgaG, vgaB} = 12'h520;
            {vgaR, vgaG, vgaB} = 12'h940;
        end

        // door
        if(250<=x && x<=290 && 10<=y && y<=80) {vgaR, vgaG, vgaB} = 12'h000;
        

        //stair
        if(250<=x && x<=290 && 10<=y && y<=80) {vgaR, vgaG, vgaB} = 12'h000;


	end

endmodule
