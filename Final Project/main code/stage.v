`define WALL_COLOR   12'hDCD 
`define FLOOR_COLOR  12'h656
`define DOOR_COLOR   12'h000
`define BLUE_COLOR   12'h548
`define PRISON_COLOR 12'h112
// `define RED_COLOR 12'hE47

`define F1  9'b0_0000_0101 // LEFT_DIR  05 => 5  
`define F2  9'b0_0000_0110 // RIGHT_DIR 06 => 6  
`define F3  9'b0_0000_0100 // UP_DIR    04 => 4  
`define F4  9'b0_0000_1100 // DOWN_DIR  0C => 12 
`define F5  9'b0_0000_0011 // space 03 => 3 
`define F6  9'b0_0000_1011 // 0B => 11 
`define F9  9'b0_0000_0001 // 01 => 1 
`define F10 9'b0_0000_1001 // 09 => 9

`define LEFT_DIR 0
`define RIGHT_DIR 1
`define UP_DIR 2
`define DOWN_DIR 3

`define DASH 0
`define P 7
`define A 8
`define S 9
`define F 10
`define I 11
`define L 12
`define G 13
`define O 14
`define D 15

module stage_top_control(
    input clk,
    input clk_25MHz,
   	input rst,

    input valid,
   	input [9:0] x,
   	input [9:0] y,

    input [9:0] people_left,
    input [9:0] people_up,
    input people_dir,

    input [9:0] chair_left,
    input [9:0] chair_up,

    input [9:0] ghost1_up,
    input [9:0] ghost1_left,
    input ghost1_dir,

    input [9:0] ghost2_up,
    input [9:0] ghost2_left,

    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,

    output reg [3:0] stage_state,
    input [2:0] chair_state,

    input FAIL,
    input SUCCESS,
    
    input CIN,
    input KEY_IN,
    input APPLE_IN,
    input HINT_PASS_IN,
    input COLOR_PASS_IN,
    input PASS_IN,
    // output reg hint_pass,
    // output reg color_pass,

    output wire KEY_OUT,
    output wire APPLE_OUT,
    output wire HINT_PASS_OUT,
    output wire COLOR_PASS_OUT,
    output wire PASS_OUT,
    // output wire CHAIR_BROKEN_OUT,
    output wire LOCK,

    output reg [15:0] SEVEN_SEGMENT,

    output reg [11:0] PIXEL

    // output reg [3:0] vgaR,
    // output reg [3:0] vgaG,
    // output reg [3:0] vgaB
);

    reg [3:0] vgaR;
    reg [3:0] vgaG;
    reg [3:0] vgaB;
    
    wire [11:0] fail_pixel;
    wire [11:0] success_pixel;


    always@(*) begin
        if(FAIL) begin
            PIXEL = {vgaR>>1,vgaG>>1,vgaB>>1};
            // if(220<=x && x<=430 && 195<=y && y<=285)  PIXEL = `WALL_COLOR;
            if(230<=x && x<=430 && 175<=y && y<=245 && fail_pixel!=12'h000)  PIXEL = fail_pixel;
        end
        else if(SUCCESS) begin
            PIXEL = {vgaR>>1,vgaG>>1,vgaB>>1};
            // if(220<=x && x<=430 && 195<=y && y<=285)  PIXEL = `WALL_COLOR;
            if(230<=x && x<=430 && 180<=y && y<=245 && success_pixel!=12'h000)  PIXEL = success_pixel;
        end
        else begin
            PIXEL = {vgaR,vgaG,vgaB};
        end
    end
    

    reg key, next_key;
    reg apple, next_apple;
    reg hint_pass;
    reg color_pass;

    assign KEY_OUT   = (KEY_IN  ||  key);
    assign APPLE_OUT = (APPLE_IN || apple);
    assign HINT_PASS_OUT = (HINT_PASS_IN || hint_pass);
    assign COLOR_PASS_OUT = (COLOR_PASS_IN || color_pass);
    assign PASS_OUT  = (PASS_IN  || (HINT_PASS_OUT && COLOR_PASS_OUT));

    wire [11:0] garbage;
    wire [11:0] hint_pixel;
    wire [11:0] carbinet_pixel;
    wire [11:0] key_pixel;
    wire [11:0] chair_pixel;
    wire [11:0] chair_broken_pixel;
    wire [11:0] ghost1_pixel;
    wire [11:0] ghost2_pixel;
    wire [11:0] apple_pixel;
    wire [11:0] people_pixel;
    wire [11:0] notation_pixel;
    wire [11:0] big_card_pixel;


    wire [11:0] arrow_1to2;
    wire [11:0] arrow_2to5;
    wire [11:0] arrow_2to1;
    wire [11:0] arrow_5to2;
    wire [11:0] arrow_0to1;
    wire [11:0] arrow_0to6;
    wire [11:0] arrow_6to0;
    wire [11:0] arrow_1to0;
    wire [11:0] arrow_0toEND;
    
    
    wire [9:0]ghost1_addr;
    assign ghost1_addr = (ghost1_dir==`LEFT_DIR) ? (ghost1_left+29-(x-ghost1_left)-ghost1_left)+30*(y-ghost1_up) : (x-ghost1_left)+30*(y-ghost1_up);
    
    wire [10:0] people_addr;
    assign people_addr = (people_dir==`RIGHT_DIR) ? (x-people_left)+40*(y-people_up) : (people_left+39-(x-people_left)-people_left)+40*(y-people_up);

    hint_w80h40     p2 (.clka(clk_25MHz), .wea(0), .addra( (x-130)+80*(y-60) ),                  .dina(garbage), .douta( hint_pixel     ));
    carbinet_w35h35 p3 (.clka(clk_25MHz), .wea(0), .addra( ((x-330)>>1) + 35*(y-45>>1)  ),       .dina(garbage), .douta( carbinet_pixel ));
    key_w20h20      p4 (.clka(clk_25MHz), .wea(0), .addra( (x-360)+20*(y-45) ),                  .dina(garbage), .douta( key_pixel      ));
    chair_w40h40    p5 (.clka(clk_25MHz), .wea(0), .addra( ((x-chair_left))+40*((y-chair_up)) ), .dina(garbage), .douta( chair_pixel    ));
    ghost_w30h30    p6 (.clka(clk_25MHz), .wea(0), .addra( ghost1_addr ),                        .dina(garbage), .douta( ghost1_pixel   ));
    ghost_w30h30    p7 (.clka(clk_25MHz), .wea(0), .addra( (x-ghost2_left)+30*(y-ghost2_up)),    .dina(garbage), .douta( ghost2_pixel   ));
	apple_w20h20    p8 (.clka(clk_25MHz), .wea(0), .addra( (x-380)+20*(y-70)),                   .dina(garbage), .douta( apple_pixel    ));   
    people_w40h40   p9 (.clka(clk_25MHz), .wea(0), .addra( people_addr ),                        .dina(garbage), .douta( people_pixel   ));
    notation_w10h30 p10(.clka(clk_25MHz), .wea(0), .addra( (x-390)+10*(y-175) ),                 .dina(garbage), .douta( notation_pixel ));
    card_w160h400   p11(.clka(clk_25MHz), .wea(0), .addra( (x-240)+160*(y-40) ),                 .dina(garbage), .douta( big_card_pixel ));
    
    fail_w200h70 g1(.clka(clk_25MHz), .wea(0), .addra( (x-230)+200*((y-175)) ), .dina(garbage), .douta( fail_pixel    ));
    good_w200h65 g2(.clka(clk_25MHz), .wea(0), .addra( (x-230)+200*((y-180)) ), .dina(garbage), .douta( success_pixel ));
   
    // (LEFT_DIR) 1 -> 2
    arrow_left_w40h24 ar1 (.clka(clk_25MHz),.wea(0),.addra( (x-100)+40*(y-356) ), .dina(garbage), .douta( arrow_1to2 ));
    // (LEFT_DIR) 2 -> 5
    arrow_left_w40h24 ar2 (.clka(clk_25MHz),.wea(0),.addra( (x-230)+40*(y-248) ), .dina(garbage), .douta( arrow_2to5 ));
    // (RIGHT_DIR) 2 -> 1
    arrow_left_w40h24 ar4 (.clka(clk_25MHz),.wea(0),.addra( (390-x)+40*(y-333) ), .dina(garbage), .douta( arrow_2to1 ));
    // (RIGHT_DIR) 5 -> 2
    arrow_left_w40h24 ar5 (.clka(clk_25MHz),.wea(0),.addra( (480-x)+40*(y-333) ), .dina(garbage), .douta( arrow_5to2 ));
    // (UP_DIR) 0 -> 1
    arrow_up_w24h40 ar7 (.clka(clk_25MHz),.wea(0),.addra( (x-373)+24*(y-45) ), .dina(garbage), .douta( arrow_0to1 ));
    // (UP_DIR) 0 -> 6
    arrow_up_w24h40 ar8 (.clka(clk_25MHz),.wea(0),.addra( (x-258)+24*(y-105) ), .dina(garbage), .douta( arrow_0to6 ));
    // (DOWN_DIR) 6 -> 0
    arrow_up_w24h40 ar9 (.clka(clk_25MHz),.wea(0),.addra( (x-258)+24*(420-y)), .dina(garbage), .douta( arrow_6to0 ));
    // (DOWN_DIR) 1 -> 0
    arrow_up_w24h40 ar10 (.clka(clk_25MHz),.wea(0),.addra( (x-243)+24*(420-y) ), .dina(garbage), .douta( arrow_1to0 ));
    // (DOWN_DIR) 0 -> END
    arrow_up_w24h40 ar1a (.clka(clk_25MHz),.wea(0),.addra( (x-313)+24*(360-y) ), .dina(garbage), .douta( arrow_0toEND ));

    

    /* ---------------------------- state transition ---------------------------- */
    reg [3:0] next_stage_state;
    always@(posedge clk) begin
        if(rst) begin
            stage_state <= 0;
        end
        else begin
            stage_state <= next_stage_state;
        end
    end

    always@(*) begin
        if(stage_state==0) begin
            if(331<=people_left+19 && people_left<=401 && 10<=people_up+19 && people_up<=11) next_stage_state = 1;
            else if(KEY_OUT && 231<=people_left && people_left<=271 && 10<=people_up+19 && people_up<=61 && key_down[`F5]) next_stage_state = 6;
            else if(310<=people_left+19 && people_left+19<=340 && 340<=people_up+19 && people_up+19<=370 && key_down[`F5]) next_stage_state = 7;
            else next_stage_state = 0;
        end

        else if(stage_state==1) begin
            if(211<=people_left && people_left<=261 && 401<=people_up && people_up<=421) next_stage_state = 0;
            else if(61<=people_left && people_left<=81 && 311<=people_up && people_up <=381) next_stage_state = 2;
            else if(130<=people_left+19 && people_left+19<=210 && 81<=people_up && people_up <=121 && been_ready && key_down[`F5]) next_stage_state = 3;
            else if(130<=people_left+19 && people_left+19<=210 && 250<=people_up+19 && people_up+19 <=290 && been_ready && key_down[`F5]) next_stage_state = 4;
            else next_stage_state = 1;
        end

        else if(stage_state==2) begin
            if(381<=people_left && people_left<=391 && 306<=people_up && people_up<=346) next_stage_state = 1;
            else if(201<=people_left && people_left<=221 && 221<=people_up && people_up<=261) next_stage_state = 5;
            else next_stage_state = 2;
        end
        

        else if(stage_state==3) begin
            if(been_ready && key_down[`F6]) next_stage_state = 1;
            else next_stage_state = 3;
        end

        else if(stage_state==4) begin
            if(been_ready && key_down[`F6]) next_stage_state = 1;
            else next_stage_state = 4;
        end

        else if(stage_state==5) begin
            if(460<=people_left && people_left<=540 && 281<=people_up && people_up<=346) next_stage_state = 2;
            if(370<=people_left && people_left<=440 && 220<=people_up+19 && people_up+19<=250 && been_ready && key_down[`F5]) next_stage_state = 8;
            else next_stage_state = 5;
        end
        else if(stage_state==6) begin
            if(270<=people_left && people_left<=301 && 421<=people_up && people_up<=441) next_stage_state = 0;
            else next_stage_state = 6;
        end
        else if(stage_state==7) begin
            if(been_ready && key_down[`F6]) next_stage_state = 0;
            else next_stage_state = 7;
        end
        else if(stage_state==8) begin
            if(been_ready && key_down[`F6]) next_stage_state = 5;
            else next_stage_state = 8;
        end
    end
    /* -------------------------------------------------------------------------- */


    /* ----------------------------------- key ---------------------------------- */
    always@(posedge clk) begin
        if(rst) begin
            key <= 0;
        end
        else begin
            if(key) key <= 1;
            else key <= next_key;
        end
    end
    always@(*) begin
        if(stage_state==2 && chair_state==2 && key_down[`F10] && 
        people_up < chair_up && chair_up<people_up+39 && people_up+39<=chair_up+39 && chair_left<=people_left+19 && people_left+19<=chair_left+39) next_key = 1;
        else next_key = 0;
    end
    /* -------------------------------------------------------------------------- */

    /* ---------------------------------- apple --------------------------------- */
    always@(posedge clk) begin
        if(rst) apple <= 0;
        else if(apple) apple <= 1;
        else apple <= next_apple;
    end

    always@(*) begin
        if(stage_state==5) begin
            if(360<=people_left+19 && people_left+19<=400 && 65<=people_up+19 && people_up+19<=95 && key_down[`F10]) begin
                next_apple = 1;
            end
            else begin
                next_apple = apple;
            end
        end
        else begin
            next_apple = apple;
        end
    end

    /* -------------------------------------------------------------------------- */

    /* -------------------------------- hint_pass -------------------------------- */
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
    always@(*) begin
        if(counter==1) lock=1;
        else lock = 0;
    end
    assign LOCK = lock;

    always@(posedge clk) begin
        if(rst) hint_pass <= 0;
        else if(hint_pass) hint_pass <= 1;
        else if(stage_state==6 && SEVEN_SEGMENT[15:12]==4'd5 && SEVEN_SEGMENT[11:8]==4'd3 && SEVEN_SEGMENT[7:4]==4'd4 && SEVEN_SEGMENT[3:0]==4'd6) hint_pass <= 1;
        else hint_pass <= 0;
    end

    always@(posedge clk) begin
        if(rst) color_pass <= 0;
        else if(color_pass) color_pass <= 1;
        else if(stage_state==7 && SEVEN_SEGMENT[15:12]==4'd1 && SEVEN_SEGMENT[11:8]==4'd2 && SEVEN_SEGMENT[7:4]==4'd2 && SEVEN_SEGMENT[3:0]==4'd2) color_pass <= 1;
        else color_pass <= 0;
    end


    
    reg [3:0] key_num;
    always@(posedge clk) begin
        if(rst) begin
            SEVEN_SEGMENT <= 0;
        end
        else begin
            
            if(FAIL) begin
                SEVEN_SEGMENT[15:12] <= `F; 
                SEVEN_SEGMENT[11:8] <= `A;
                SEVEN_SEGMENT[7:4] <= `I;
                SEVEN_SEGMENT[3:0] <= `L;
            end
            else if(SUCCESS) begin
                SEVEN_SEGMENT[15:12] <= `G; 
                SEVEN_SEGMENT[11:8] <= `O;
                SEVEN_SEGMENT[7:4] <= `O;
                SEVEN_SEGMENT[3:0] <= `D;
            end
            else begin
            
                if (!PASS_OUT && CIN && !lock && been_ready && key_down[last_change] && 
                   ( (stage_state==6 && 370<=people_left && people_left<=420 && 50<=people_up && people_up<=135) || stage_state==7)) begin
                    SEVEN_SEGMENT <= {SEVEN_SEGMENT[11:0],key_num};
                end
                else if(PASS_OUT) begin
                    SEVEN_SEGMENT[15:12] <= `P; 
                    SEVEN_SEGMENT[11:8] <= `A;
                    SEVEN_SEGMENT[7:4] <= `S;
                    SEVEN_SEGMENT[3:0] <= `S;
                end
                else if(!PASS_OUT && stage_state!=6 && stage_state!=7) begin
                    SEVEN_SEGMENT[15:12] <= `DASH; 
                    SEVEN_SEGMENT[11:8] <= `DASH;
                    SEVEN_SEGMENT[7:4] <= `DASH;
                    SEVEN_SEGMENT[3:0] <= `DASH;
                end
            end
            
        end
    end



    always@(*) begin
        case (last_change)
            `F1 : key_num = 4'b0001;
            `F2 : key_num = 4'b0010;
            `F3 : key_num = 4'b0011;
            `F4 : key_num = 4'b0100;
            `F5 : key_num = 4'b0101;
            `F6 : key_num = 4'b0110;
            default : key_num = 4'b0000;
        endcase
    end
    /* -------------------------------------------------------------------------- */

    /* ------------------------------- vga output ------------------------------- */

    always@(*) begin
        if(!valid) {vgaR, vgaG, vgaB} = 12'h000;
        else begin   
            case(stage_state)
                0:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;            
                    
                    // floor1
                    if(420<=x && x<=520 && 150<=y && y<=155) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=250 && 10<=y && y<=15)   {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(290<=x && x<=320 && 10<=y && y<=15)   {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(320<=x && x<=350 && 145<=y && y<=150) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(320<=x && x<=350 && 185<=y && y<=220) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=320 && 75<=y && y<=220)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(350<=x && x<=420 && 10<=y && y<=220)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=520 && 220<=y && y<=350) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=420 && 350<=y && y<=380) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                
                    // floor2
                    if(220<=x && x<=420 && 380<=y && y<=480) {vgaR, vgaG, vgaB} = 12'hE47;
                    // if(310<=x && x<=340 && 440<=y && y<=460) {vgaR, vgaG, vgaB} = 12'hE47;

                    
                    

                    if(270<=x && x<=420) if(y==10) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==20) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==30) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==40) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==50) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==60) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==70) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==80) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==90) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==100) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==110) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==120) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==130) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==140) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==150) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==160) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==170) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==180) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==190) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==200) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==210) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==220) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==230) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==240) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==250) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==260) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==270) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==280) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==290) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==300) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==310) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==320) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==330) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==340) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==350) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==360) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==370) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==380) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==390) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==400) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==410) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==420) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==430) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==440) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==450) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==460) {vgaR, vgaG, vgaB} = 12'h767;

                    if(270<=x && x<=420) if(y==470) {vgaR, vgaG, vgaB} = 12'h767;

                    if(10<=y && y<=10+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(10+10<y && y<=10+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(20<=y && y<=20+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(20+10<y && y<=20+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(30<=y && y<=30+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(30+10<y && y<=30+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(40<=y && y<=40+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(40+10<y && y<=40+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(50<=y && y<=50+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(50+10<y && y<=50+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(60<=y && y<=60+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(60+10<y && y<=60+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(70<=y && y<=70+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(70+10<y && y<=70+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(80<=y && y<=80+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(80+10<y && y<=80+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(90<=y && y<=90+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(90+10<y && y<=90+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(100<=y && y<=100+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(100+10<y && y<=100+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(110<=y && y<=110+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(110+10<y && y<=110+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(120<=y && y<=120+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(120+10<y && y<=120+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(130<=y && y<=130+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(130+10<y && y<=130+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(140<=y && y<=140+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(140+10<y && y<=140+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(150<=y && y<=150+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(150+10<y && y<=150+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(160<=y && y<=160+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(160+10<y && y<=160+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(170<=y && y<=170+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(170+10<y && y<=170+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(180<=y && y<=180+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(180+10<y && y<=180+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(190<=y && y<=190+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(190+10<y && y<=190+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(200<=y && y<=200+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(200+10<y && y<=200+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(210<=y && y<=210+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(210+10<y && y<=210+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(220<=y && y<=220+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(220+10<y && y<=220+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(230<=y && y<=230+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(230+10<y && y<=230+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(240<=y && y<=240+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(240+10<y && y<=240+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(250<=y && y<=250+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(250+10<y && y<=250+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(260<=y && y<=260+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(260+10<y && y<=260+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(270<=y && y<=270+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(270+10<y && y<=270+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(280<=y && y<=280+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(280+10<y && y<=280+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(290<=y && y<=290+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(290+10<y && y<=290+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(300<=y && y<=300+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(300+10<y && y<=300+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(310<=y && y<=310+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(310+10<y && y<=310+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(320<=y && y<=320+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(320+10<y && y<=320+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(330<=y && y<=330+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(330+10<y && y<=330+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(340<=y && y<=340+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(340+10<y && y<=340+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(350<=y && y<=350+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(350+10<y && y<=350+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(360<=y && y<=360+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(360+10<y && y<=360+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(370<=y && y<=370+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(370+10<y && y<=370+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(380<=y && y<=380+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(380+10<y && y<=380+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(390<=y && y<=390+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(390+10<y && y<=390+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(400<=y && y<=400+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(400+10<y && y<=400+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(410<=y && y<=410+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(410+10<y && y<=410+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(420<=y && y<=420+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(420+10<y && y<=420+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(430<=y && y<=430+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(430+10<y && y<=430+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(440<=y && y<=440+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(440+10<y && y<=440+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(450<=y && y<=450+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(450+10<y && y<=450+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(460<=y && y<=460+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(460+10<y && y<=460+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==520) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(470<=y && y<=470+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==510) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    // black block
                    if(320<=x && x<=350 && 10<=y && y<=145)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(420<=x && x<=520 && 10<=y && y<=150)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(420<=x && x<=520 && 350<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(340<=x && x<=420 && 440<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(220<=x && x<=310 && 440<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;

                    // if(220<=x && x<=310 && 350<=y && y<=380)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(!PASS_OUT && !COLOR_PASS_OUT && 310<=x && x<=340 && 370<=y && y<=380)   {vgaR, vgaG, vgaB} = 12'h000;
                    // if(340<=x && x<=420 && 350<=y && y<=380)   {vgaR, vgaG, vgaB} = 12'h000;



                    // floor
                    if(420<=x && x<=520 && 150<=y && y<=155)   {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=320 && 10<=y && y<=15)   {vgaR, vgaG, vgaB} = `FLOOR_COLOR;


                    // wall
                    if(220<=x && x<=250 && 15<=y && y<=75)   {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(220<=x && x<=250 && y==75)   {vgaR, vgaG, vgaB} = 12'h000;

                    if(290<=x && x<=320 && 15<=y && y<=75)   {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(290<=x && x<=320 && y==75)   {vgaR, vgaG, vgaB} = 12'h000;

                    if(320<=x && x<=350 && 150<=y && y<=185) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(320<=x && x<=350 && y==185) {vgaR, vgaG, vgaB} = 12'h000;
                    
                    if(420<=x && x<=520 && 155<=y && y<=220) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(420<=x && x<=520 && y==220) {vgaR, vgaG, vgaB} = 12'h000;
                


                    // door
                    if(250<=x && x<=290 && 10<=y && y<=80) {vgaR, vgaG, vgaB} = `DOOR_COLOR;
                    // 門把
                    if(255<=x && x<=260 && 35<=y && y<=40) {vgaR, vgaG, vgaB} = 12'hFFF;

                    // arrow 0 to 1
                    if(373<=x && x<=397 && 45<=y && y<=85 && arrow_0to1!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_0to1;
                    // arrow 0 to 6
                    if(258<=x && x<=282 && 105<=y && y<=145 && arrow_0to6!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_0to6;
                    // arrow 0 to 6
                    if(313<=x && x<=337 && 320<=y && y<=360 && arrow_0toEND!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_0toEND;

                    // chair
                    if(stage_state==chair_state && chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1 && chair_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = chair_pixel;
                    end

                    // people                    
                    if( people_left+1 < x && x < people_left + 40 - 1 && 
                        people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = people_pixel;
                    end
                end
                1:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;

                    // floor
                    if(130<=x && x<=280 && 50<=y && y<=400) {vgaR, vgaG, vgaB} = 12'h656;
                    if(230<=x && x<=280 && 400<=y && y<=440) {vgaR, vgaG, vgaB} = 12'h656;
                    if(80<=x && x<=130 && 285<=y && y<=400) {vgaR, vgaG, vgaB} = 12'h656;
                    
                    // hint field
                    if(130<=x && x<=210 && 250<=y && y<=290) {vgaR, vgaG, vgaB} = 12'h767;

                    // horizental floor line
                    if(80<=x && x<=280) begin            
                        if (y==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if (y==440) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    // vertical line
                    if(110<=y && y<=110+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(110+10<y && y<=110+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(140<=y && y<=140+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(140+10<y && y<=140+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(170<=y && y<=170+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(170+10<y && y<=170+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(200<=y && y<=200+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(200+10<y && y<=200+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(230<=y && y<=230+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(230+10<y && y<=230+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(260<=y && y<=260+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(260+10<y && y<=260+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(290<=y && y<=290+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(290+10<y && y<=290+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(320<=y && y<=320+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(320+10<y && y<=320+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(350<=y && y<=350+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(350+10<y && y<=350+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(380<=y && y<=380+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(380+10<y && y<=380+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(410<=y && y<=410+10) begin
                        if(x==90) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==110) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==130) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==150) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==170) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==190) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(410+10<y && y<=410+20) begin
                        if(x==80) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==100) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==120) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==140) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==160) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==180) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    // floor
                    if(80<=x && x<=130 && 330<=y && y<=335) {vgaR, vgaG, vgaB} = 12'h656;

                    // LINE
                    if(130<=x && x<=280 && y==105) {vgaR, vgaG, vgaB} = 12'h545;
                    if(80<=x && x<=130 && y==335) {vgaR, vgaG, vgaB} = 12'h545;

                    // wall
                    if(130<=x && x<=280 && 55<=y && y<=100) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(80<=x && x<=130 && 290<=y && y<=330) {vgaR, vgaG, vgaB} = `WALL_COLOR;

                    // black block
                    if(80<=x && x<=230 && 400<=y && y<=440) {vgaR, vgaG, vgaB} = 12'h000;
                    if(80<=x && x<=130 && 50<=y && y<=285) {vgaR, vgaG, vgaB} = 12'h000;

                    // hint
                    if(130<=x && x<=210 && 60<=y && y<=100 && hint_pixel!=12'h000) {vgaR, vgaG, vgaB} = hint_pixel;


                    if(people_up+39 < 260) begin
                        if( people_left+2<x && x<people_left+39 && 
                            people_up<y && y<people_up+39  && people_pixel!=12'h000) begin
                            {vgaR, vgaG, vgaB} = people_pixel;
                        end                
                    end

                    // prison
                    if(130<=x && x<=230) begin
                        if(160<=y && y<=163) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(y==164) {vgaR, vgaG, vgaB} = 12'h333;
                        if(165<=y && y<=168) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(245<=y && y<=248) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(y==249) {vgaR, vgaG, vgaB} = 12'h333;
                        if(250<=y && y<=253) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    end
                    if(160<=y && y<=250) begin
                        if(133<=x && x<=134) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(138<=x && x<=139) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        
                        if(143<=x && x<=144) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(148<=x && x<=149) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(153<=x && x<=154) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(158<=x && x<=159) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(163<=x && x<=164) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(168<=x && x<=169) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(173<=x && x<=174) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(178<=x && x<=179) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        
                        if(183<=x && x<=184) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(188<=x && x<=189) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(193<=x && x<=194) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(198<=x && x<=199) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(203<=x && x<=204) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(208<=x && x<=209) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(213<=x && x<=214) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(218<=x && x<=219) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                        if(223<=x && x<=224) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                        if(228<=x && x<=229) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                    end

                    // arrow 1 to 0
                    if(243<=x && x<=267 && 380<=y && y<=420 && arrow_1to0!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_1to0;
                    // arrow 1 to 2
                    if(100<=x && x<=140 && 356<=y && y<=380 && arrow_1to2!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_1to2;
                    // chair
                    if(stage_state==chair_state && chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1 && chair_pixel!=12'h000) {vgaR, vgaG, vgaB} = chair_pixel;


                    // people
                    if(260<=people_up+39) begin
                        if( people_left+1 < x && x < people_left + 40 - 1 && 
                            people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
                            {vgaR, vgaG, vgaB} = people_pixel;
                        end             
                    end
                end
                2:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;

                    // floor1
                    if(260<=x && x<=400 && 10<=y && y<=365)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(220<=x && x<=260 && 165<=y && y<=280) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(400<=x && x<=410 && 250<=y && y<=365) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    
                    
                    if(220<=x && x<=410) if(y==85) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==95) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==105) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==115) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==125) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==135) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==145) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==155) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==165) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==175) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==185) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==195) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==205) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==215) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==225) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==235) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==245) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==255) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==265) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==275) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==285) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==295) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==305) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==315) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==325) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==335) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==345) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=410) if(y==355) {vgaR, vgaG, vgaB} = 12'h767;

                    if(85<=y && y<=85+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(85+10<y && y<=85+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(115<=y && y<=115+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(115+10<y && y<=115+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(145<=y && y<=145+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(145+10<y && y<=145+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(175<=y && y<=175+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(175+10<y && y<=175+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(205<=y && y<=205+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(205+10<y && y<=205+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(235<=y && y<=235+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(235+10<y && y<=235+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(265<=y && y<=265+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(265+10<y && y<=265+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(295<=y && y<=295+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(295+10<y && y<=295+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(325<=y && y<=325+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(325+10<y && y<=325+20) begin
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(355<=y && y<=355+10) begin
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                
                    // wall
                    if(260<=x && x<=400 && 15<=y && y<=85) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(220<=x && x<=260 && 170<=y && y<=240) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(400<=x && x<=410 && 255<=y && y<=325) {vgaR, vgaG, vgaB} = `WALL_COLOR;

                    // LINE
                    if(260<=x && x<=400 && (y==85 || y==86)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(400<=x && x<=410 && (y==325 || y==326)) {vgaR, vgaG, vgaB} = 12'h545;

                    // black block
                    if(220<=x && x<=260 && 10<=y && y<=175) {vgaR, vgaG, vgaB} = 12'h000;
                    if(220<=x && x<=260 && 280<=y && y<=365) {vgaR, vgaG, vgaB} = 12'h000;
                    if(400<=x && x<=410 && 10<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;

                    // arrow 2 to 1
                    if(350<=x && x<=390 && 333<=y && y<=357 && arrow_2to1!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_2to1;
                    // arrow 2 to 5
                    if(230<=x && x<=270 && 248<=y && y<=272 && arrow_2to5!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_2to5;

                    // carpet
                    // if(260<x && x<=400 && 116<=y && y<=197) {vgaR, vgaG, vgaB} = carpet_pixel;

                    // carbinet  
                    if(330<=x && x<=400 && 45<=y && y<115) {vgaR, vgaG, vgaB} = carbinet_pixel;  

                    
                    // key
                    if(!KEY_OUT && 360<=x && x<=380 && 45<=y && y<=65 && key_pixel!=12'h000) {vgaR, vgaG, vgaB} = key_pixel;  

                    // chair
                    if(stage_state==chair_state && chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1 && chair_pixel!=12'h000) {vgaR, vgaG, vgaB} = chair_pixel;
                    
                    // people
                    if( people_left+1 < x && x < people_left + 40 - 1 && 
                        people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = people_pixel;
                    end
                end
                3:  begin
                    {vgaR, vgaG, vgaB} = `WALL_COLOR;
                
                    if(60<=x && x<=180 && 90<=y && y<=120) {vgaR, vgaG, vgaB} = `BLUE_COLOR; // define BLUE_LINE_COLOR
                    if(200<=x && x<=320 && 90<=y && y<=120) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(340<=x && x<=460 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=180 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(245<=x && x<=320 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(510<=x && x<=570 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=180 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(510<=x && x<=600 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=90 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(120<=x && x<=150 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(165<=x && x<=180 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(200<=x && x<=230 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(260<=x && x<=290 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(300<=x && x<=320 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(340<=x && x<=370 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(400<=x && x<=430 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(440<=x && x<=460 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(480<=x && x<=510 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(570<=x && x<=600 && 90<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(200<=x && x<=320 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                end
                4:  begin
                     {vgaR, vgaG, vgaB} = `WALL_COLOR;

                    // blue line
                    if(60<=x && x<=180 && 90<=y && y<=120) {vgaR, vgaG, vgaB} = `BLUE_COLOR; // define BLUE_COLOR
                    if(200<=x && x<=320 && 90<=y && y<=120) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(340<=x && x<=460 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=180 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(245<=x && x<=320 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(510<=x && x<=570 && 240<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=180 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(510<=x && x<=600 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(60<=x && x<=90 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(120<=x && x<=150 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(165<=x && x<=180 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(200<=x && x<=230 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(260<=x && x<=290 && 270<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(300<=x && x<=320 && 120<=y && y<=390) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(340<=x && x<=370 && 120<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(400<=x && x<=430 && 120<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(440<=x && x<=460 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(480<=x && x<=510 && 90<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(570<=x && x<=600 && 90<=y && y<=270) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    if(200<=x && x<=320 && 390<=y && y<=420) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    
                    // BlACK line
                    if(0<=x && x<=20 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(60<=x && x<=90 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(120<=x && x<=150 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(200<=x && x<=230 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(260<=x && x<=290 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(340<=x && x<=370 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(400<=x && x<=430 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                    if(465<=x && x<=490 && 0<=y && y<490) {vgaR, vgaG, vgaB} = `PRISON_COLOR;

                    if(510<=x && x<=540 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(570<=x && x<=600 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                    if(630<=x && x<640 && 0<=y && y<480) {vgaR, vgaG, vgaB} = `PRISON_COLOR;
                end
                5:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;

                    // floor
                    if(200<=x && x<=250 && 85<=y && y<=220)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(250<=x && x<=300 && 10<=y && y<=250)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(300<=x && x<=400 && 10<=y && y<=95)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(300<=x && x<=350 && 155<=y && y<=365)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(250<=x && x<=500 && 250<=y && y<=365)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(350<=x && x<=470 && 365<=y && y<=420)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(370<=x && x<=420 && 155<=y && y<=250)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(400<=x && x<=470 && 160<=y && y<=210)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                
                    

                    if(200<=x && x<=500) if(y==10) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==20) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==30) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==40) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==50) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==60) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==70) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==80) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==90) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==100) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==110) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==120) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==130) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==140) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==150) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==160) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==170) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==180) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==190) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==200) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==210) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==220) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==230) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==240) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==250) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==260) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==270) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==280) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==290) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==300) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==310) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==320) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==330) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==340) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==350) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==360) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==370) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==380) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==390) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==400) {vgaR, vgaG, vgaB} = 12'h767;

                    if(200<=x && x<=500) if(y==410) {vgaR, vgaG, vgaB} = 12'h767;

                    if(10<=y && y<=10+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(10+10<y && y<=10+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(40<=y && y<=40+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(40+10<y && y<=40+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(70<=y && y<=70+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(70+10<y && y<=70+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(100<=y && y<=100+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(100+10<y && y<=100+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(130<=y && y<=130+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(130+10<y && y<=130+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(160<=y && y<=160+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(160+10<y && y<=160+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(190<=y && y<=190+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(190+10<y && y<=190+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(220<=y && y<=220+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(220+10<y && y<=220+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(250<=y && y<=250+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(250+10<y && y<=250+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(280<=y && y<=280+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(280+10<y && y<=280+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(310<=y && y<=310+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(310+10<y && y<=310+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(340<=y && y<=340+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(340+10<y && y<=340+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(370<=y && y<=370+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end
                    if(370+10<y && y<=370+20) begin
                        if(x==200) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==220) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==240) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==260) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==440) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==460) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==480) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==500) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    if(400<=y && y<=400+10) begin
                        if(x==210) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==230) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==250) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==430) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==450) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==470) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==490) {vgaR, vgaG, vgaB} = 12'h767;
                    end

                    // wall
                    if(200<=x && x<=250 && 90<=y && y<=120)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(250<=x && x<=400 && 15<=y && y<=65)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(300<=x && x<=350 && 160<=y && y<=210)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(350<=x && x<=370 && 255<=y && y<=325)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(420<=x && x<=500 && 255<=y && y<=325)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    
                    // LINE
                    if(200<=x && x<=250 && (y==120||y==121)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(250<=x && x<=400 && (y==65||y==66))  {vgaR, vgaG, vgaB} = 12'h545;
                    if(300<=x && x<=350 && (y==210||y==211)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(350<=x && x<=370 && (y==325||y==326)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(420<=x && x<=500 && (y==325||y==326)) {vgaR, vgaG, vgaB} = 12'h545;

                    // tp to 8
                    if(370<=x && x<=420 && 220<=y && y<=250)  {vgaR, vgaG, vgaB} = 12'h878;

                    // black block 
                    if(200<=x && x<=250 && 10<=y && y<=85) {vgaR, vgaG, vgaB} = 12'h000;
                    if(200<=x && x<=250 && 220<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(250<=x && x<=350 && 365<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(470<=x && x<=500 && 365<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(250<=x && x<=300 && 255<=y && y<=325) {vgaR, vgaG, vgaB} = 12'h000;

                    if(300<=x && x<=350 && 95<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h000;
                    if(350<=x && x<=370 && 95<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;
                    if(370<=x && x<=400 && 95<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h000;

                    if(400<=x && x<=500 && 10<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h000;
                    if(420<=x && x<=500 && 155<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;




                    // notation
                    if(390<=x && x<=400 && 175<=y && y<=205 && notation_pixel!=12'h000)  {vgaR, vgaG, vgaB} = notation_pixel;

                    // arrow 5 to 2
                    if(445<=x && x<=480 && 333<=y && y<=357 && arrow_5to2!=12'hFFF)  {vgaR, vgaG, vgaB} = arrow_5to2;
                    
                    // ghost1
                    if(ghost1_left<x && x<=ghost1_left+30 && ghost1_up<=y && y<=ghost1_up+30-1 && ghost1_pixel!=12'h000) {vgaR, vgaG, vgaB} = ghost1_pixel;

                    // ghost2
                    if(ghost2_left<x && x<=ghost2_left+30 && ghost2_up<=y && y<=ghost2_up+30-1 && ghost2_pixel!=12'h000) {vgaR, vgaG, vgaB} = ghost2_pixel;
                    
                    // chair
                    if(stage_state==chair_state && chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1 && chair_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = chair_pixel;
                    end

                    //apple
                    if(!APPLE_OUT && 380<x && x<=400 && 70<=y && y<=90 && apple_pixel!=12'h000) {vgaR, vgaG, vgaB} = apple_pixel;

                    // people
                    if( people_left < x && x <=people_left+39 && people_up<y && y<people_up+39  && people_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = people_pixel;
                    end
                end
                6:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;
                    if ((
                        (x==people_left+11 && y==people_up-40) || 
                        (x==people_left+12 && y==people_up-40) || 
                        (x==people_left+13 && y==people_up-40) || 
                        (x==people_left+14 && y==people_up-40) || 
                        (x==people_left+15 && y==people_up-40) || 
                        (x==people_left+16 && y==people_up-40) || 
                        (x==people_left+17 && y==people_up-40) || 
                        (x==people_left+18 && y==people_up-40) || 
                        (x==people_left+19 && y==people_up-40) || 
                        (x==people_left+20 && y==people_up-40) || 
                        (x==people_left+21 && y==people_up-40) || 
                        (x==people_left+22 && y==people_up-40) || 
                        (x==people_left+23 && y==people_up-40) || 
                        (x==people_left+24 && y==people_up-40) || 
                        (x==people_left+25 && y==people_up-40) || 
                        (x==people_left+26 && y==people_up-40) || 
                        (x==people_left+27 && y==people_up-40) || 
                        (x==people_left+6 && y==people_up-39) || 
                        (x==people_left+7 && y==people_up-39) || 
                        (x==people_left+8 && y==people_up-39) || 
                        (x==people_left+9 && y==people_up-39) || 
                        (x==people_left+10 && y==people_up-39) || 
                        (x==people_left+11 && y==people_up-39) || 
                        (x==people_left+12 && y==people_up-39) || 
                        (x==people_left+13 && y==people_up-39) || 
                        (x==people_left+14 && y==people_up-39) || 
                        (x==people_left+15 && y==people_up-39) || 
                        (x==people_left+16 && y==people_up-39) || 
                        (x==people_left+17 && y==people_up-39) || 
                        (x==people_left+18 && y==people_up-39) || 
                        (x==people_left+19 && y==people_up-39) || 
                        (x==people_left+20 && y==people_up-39) || 
                        (x==people_left+21 && y==people_up-39) || 
                        (x==people_left+22 && y==people_up-39) || 
                        (x==people_left+23 && y==people_up-39) || 
                        (x==people_left+24 && y==people_up-39) || 
                        (x==people_left+25 && y==people_up-39) || 
                        (x==people_left+26 && y==people_up-39) || 
                        (x==people_left+27 && y==people_up-39) || 
                        (x==people_left+28 && y==people_up-39) || 
                        (x==people_left+29 && y==people_up-39) || 
                        (x==people_left+30 && y==people_up-39) || 
                        (x==people_left+31 && y==people_up-39) || 
                        (x==people_left+32 && y==people_up-39) || 
                        (x==people_left+2 && y==people_up-38) || 
                        (x==people_left+3 && y==people_up-38) || 
                        (x==people_left+4 && y==people_up-38) || 
                        (x==people_left+5 && y==people_up-38) || 
                        (x==people_left+6 && y==people_up-38) || 
                        (x==people_left+7 && y==people_up-38) || 
                        (x==people_left+8 && y==people_up-38) || 
                        (x==people_left+9 && y==people_up-38) || 
                        (x==people_left+10 && y==people_up-38) || 
                        (x==people_left+11 && y==people_up-38) || 
                        (x==people_left+12 && y==people_up-38) || 
                        (x==people_left+13 && y==people_up-38) || 
                        (x==people_left+14 && y==people_up-38) || 
                        (x==people_left+15 && y==people_up-38) || 
                        (x==people_left+16 && y==people_up-38) || 
                        (x==people_left+17 && y==people_up-38) || 
                        (x==people_left+18 && y==people_up-38) || 
                        (x==people_left+19 && y==people_up-38) || 
                        (x==people_left+20 && y==people_up-38) || 
                        (x==people_left+21 && y==people_up-38) || 
                        (x==people_left+22 && y==people_up-38) || 
                        (x==people_left+23 && y==people_up-38) || 
                        (x==people_left+24 && y==people_up-38) || 
                        (x==people_left+25 && y==people_up-38) || 
                        (x==people_left+26 && y==people_up-38) || 
                        (x==people_left+27 && y==people_up-38) || 
                        (x==people_left+28 && y==people_up-38) || 
                        (x==people_left+29 && y==people_up-38) || 
                        (x==people_left+30 && y==people_up-38) || 
                        (x==people_left+31 && y==people_up-38) || 
                        (x==people_left+32 && y==people_up-38) || 
                        (x==people_left+33 && y==people_up-38) || 
                        (x==people_left+34 && y==people_up-38) || 
                        (x==people_left+35 && y==people_up-38) || 
                        (x==people_left+36 && y==people_up-38) || 
                        (x==people_left-1 && y==people_up-37) || 
                        (x==people_left+0 && y==people_up-37) || 
                        (x==people_left+1 && y==people_up-37) || 
                        (x==people_left+2 && y==people_up-37) || 
                        (x==people_left+3 && y==people_up-37) || 
                        (x==people_left+4 && y==people_up-37) || 
                        (x==people_left+5 && y==people_up-37) || 
                        (x==people_left+6 && y==people_up-37) || 
                        (x==people_left+7 && y==people_up-37) || 
                        (x==people_left+8 && y==people_up-37) || 
                        (x==people_left+9 && y==people_up-37) || 
                        (x==people_left+10 && y==people_up-37) || 
                        (x==people_left+11 && y==people_up-37) || 
                        (x==people_left+12 && y==people_up-37) || 
                        (x==people_left+13 && y==people_up-37) || 
                        (x==people_left+14 && y==people_up-37) || 
                        (x==people_left+15 && y==people_up-37) || 
                        (x==people_left+16 && y==people_up-37) || 
                        (x==people_left+17 && y==people_up-37) || 
                        (x==people_left+18 && y==people_up-37) || 
                        (x==people_left+19 && y==people_up-37) || 
                        (x==people_left+20 && y==people_up-37) || 
                        (x==people_left+21 && y==people_up-37) || 
                        (x==people_left+22 && y==people_up-37) || 
                        (x==people_left+23 && y==people_up-37) || 
                        (x==people_left+24 && y==people_up-37) || 
                        (x==people_left+25 && y==people_up-37) || 
                        (x==people_left+26 && y==people_up-37) || 
                        (x==people_left+27 && y==people_up-37) || 
                        (x==people_left+28 && y==people_up-37) || 
                        (x==people_left+29 && y==people_up-37) || 
                        (x==people_left+30 && y==people_up-37) || 
                        (x==people_left+31 && y==people_up-37) || 
                        (x==people_left+32 && y==people_up-37) || 
                        (x==people_left+33 && y==people_up-37) || 
                        (x==people_left+34 && y==people_up-37) || 
                        (x==people_left+35 && y==people_up-37) || 
                        (x==people_left+36 && y==people_up-37) || 
                        (x==people_left+37 && y==people_up-37) || 
                        (x==people_left+38 && y==people_up-37) || 
                        (x==people_left+39 && y==people_up-37) || 
                        (x==people_left-4 && y==people_up-36) || 
                        (x==people_left-3 && y==people_up-36) || 
                        (x==people_left-2 && y==people_up-36) || 
                        (x==people_left-1 && y==people_up-36) || 
                        (x==people_left+0 && y==people_up-36) || 
                        (x==people_left+1 && y==people_up-36) || 
                        (x==people_left+2 && y==people_up-36) || 
                        (x==people_left+3 && y==people_up-36) || 
                        (x==people_left+4 && y==people_up-36) || 
                        (x==people_left+5 && y==people_up-36) || 
                        (x==people_left+6 && y==people_up-36) || 
                        (x==people_left+7 && y==people_up-36) || 
                        (x==people_left+8 && y==people_up-36) || 
                        (x==people_left+9 && y==people_up-36) || 
                        (x==people_left+10 && y==people_up-36) || 
                        (x==people_left+11 && y==people_up-36) || 
                        (x==people_left+12 && y==people_up-36) || 
                        (x==people_left+13 && y==people_up-36) || 
                        (x==people_left+14 && y==people_up-36) || 
                        (x==people_left+15 && y==people_up-36) || 
                        (x==people_left+16 && y==people_up-36) || 
                        (x==people_left+17 && y==people_up-36) || 
                        (x==people_left+18 && y==people_up-36) || 
                        (x==people_left+19 && y==people_up-36) || 
                        (x==people_left+20 && y==people_up-36) || 
                        (x==people_left+21 && y==people_up-36) || 
                        (x==people_left+22 && y==people_up-36) || 
                        (x==people_left+23 && y==people_up-36) || 
                        (x==people_left+24 && y==people_up-36) || 
                        (x==people_left+25 && y==people_up-36) || 
                        (x==people_left+26 && y==people_up-36) || 
                        (x==people_left+27 && y==people_up-36) || 
                        (x==people_left+28 && y==people_up-36) || 
                        (x==people_left+29 && y==people_up-36) || 
                        (x==people_left+30 && y==people_up-36) || 
                        (x==people_left+31 && y==people_up-36) || 
                        (x==people_left+32 && y==people_up-36) || 
                        (x==people_left+33 && y==people_up-36) || 
                        (x==people_left+34 && y==people_up-36) || 
                        (x==people_left+35 && y==people_up-36) || 
                        (x==people_left+36 && y==people_up-36) || 
                        (x==people_left+37 && y==people_up-36) || 
                        (x==people_left+38 && y==people_up-36) || 
                        (x==people_left+39 && y==people_up-36) || 
                        (x==people_left+40 && y==people_up-36) || 
                        (x==people_left+41 && y==people_up-36) || 
                        (x==people_left+42 && y==people_up-36) || 
                        (x==people_left-6 && y==people_up-35) || 
                        (x==people_left-5 && y==people_up-35) || 
                        (x==people_left-4 && y==people_up-35) || 
                        (x==people_left-3 && y==people_up-35) || 
                        (x==people_left-2 && y==people_up-35) || 
                        (x==people_left-1 && y==people_up-35) || 
                        (x==people_left+0 && y==people_up-35) || 
                        (x==people_left+1 && y==people_up-35) || 
                        (x==people_left+2 && y==people_up-35) || 
                        (x==people_left+3 && y==people_up-35) || 
                        (x==people_left+4 && y==people_up-35) || 
                        (x==people_left+5 && y==people_up-35) || 
                        (x==people_left+6 && y==people_up-35) || 
                        (x==people_left+7 && y==people_up-35) || 
                        (x==people_left+8 && y==people_up-35) || 
                        (x==people_left+9 && y==people_up-35) || 
                        (x==people_left+10 && y==people_up-35) || 
                        (x==people_left+11 && y==people_up-35) || 
                        (x==people_left+12 && y==people_up-35) || 
                        (x==people_left+13 && y==people_up-35) || 
                        (x==people_left+14 && y==people_up-35) || 
                        (x==people_left+15 && y==people_up-35) || 
                        (x==people_left+16 && y==people_up-35) || 
                        (x==people_left+17 && y==people_up-35) || 
                        (x==people_left+18 && y==people_up-35) || 
                        (x==people_left+19 && y==people_up-35) || 
                        (x==people_left+20 && y==people_up-35) || 
                        (x==people_left+21 && y==people_up-35) || 
                        (x==people_left+22 && y==people_up-35) || 
                        (x==people_left+23 && y==people_up-35) || 
                        (x==people_left+24 && y==people_up-35) || 
                        (x==people_left+25 && y==people_up-35) || 
                        (x==people_left+26 && y==people_up-35) || 
                        (x==people_left+27 && y==people_up-35) || 
                        (x==people_left+28 && y==people_up-35) || 
                        (x==people_left+29 && y==people_up-35) || 
                        (x==people_left+30 && y==people_up-35) || 
                        (x==people_left+31 && y==people_up-35) || 
                        (x==people_left+32 && y==people_up-35) || 
                        (x==people_left+33 && y==people_up-35) || 
                        (x==people_left+34 && y==people_up-35) || 
                        (x==people_left+35 && y==people_up-35) || 
                        (x==people_left+36 && y==people_up-35) || 
                        (x==people_left+37 && y==people_up-35) || 
                        (x==people_left+38 && y==people_up-35) || 
                        (x==people_left+39 && y==people_up-35) || 
                        (x==people_left+40 && y==people_up-35) || 
                        (x==people_left+41 && y==people_up-35) || 
                        (x==people_left+42 && y==people_up-35) || 
                        (x==people_left+43 && y==people_up-35) || 
                        (x==people_left+44 && y==people_up-35) || 
                        (x==people_left-8 && y==people_up-34) || 
                        (x==people_left-7 && y==people_up-34) || 
                        (x==people_left-6 && y==people_up-34) || 
                        (x==people_left-5 && y==people_up-34) || 
                        (x==people_left-4 && y==people_up-34) || 
                        (x==people_left-3 && y==people_up-34) || 
                        (x==people_left-2 && y==people_up-34) || 
                        (x==people_left-1 && y==people_up-34) || 
                        (x==people_left+0 && y==people_up-34) || 
                        (x==people_left+1 && y==people_up-34) || 
                        (x==people_left+2 && y==people_up-34) || 
                        (x==people_left+3 && y==people_up-34) || 
                        (x==people_left+4 && y==people_up-34) || 
                        (x==people_left+5 && y==people_up-34) || 
                        (x==people_left+6 && y==people_up-34) || 
                        (x==people_left+7 && y==people_up-34) || 
                        (x==people_left+8 && y==people_up-34) || 
                        (x==people_left+9 && y==people_up-34) || 
                        (x==people_left+10 && y==people_up-34) || 
                        (x==people_left+11 && y==people_up-34) || 
                        (x==people_left+12 && y==people_up-34) || 
                        (x==people_left+13 && y==people_up-34) || 
                        (x==people_left+14 && y==people_up-34) || 
                        (x==people_left+15 && y==people_up-34) || 
                        (x==people_left+16 && y==people_up-34) || 
                        (x==people_left+17 && y==people_up-34) || 
                        (x==people_left+18 && y==people_up-34) || 
                        (x==people_left+19 && y==people_up-34) || 
                        (x==people_left+20 && y==people_up-34) || 
                        (x==people_left+21 && y==people_up-34) || 
                        (x==people_left+22 && y==people_up-34) || 
                        (x==people_left+23 && y==people_up-34) || 
                        (x==people_left+24 && y==people_up-34) || 
                        (x==people_left+25 && y==people_up-34) || 
                        (x==people_left+26 && y==people_up-34) || 
                        (x==people_left+27 && y==people_up-34) || 
                        (x==people_left+28 && y==people_up-34) || 
                        (x==people_left+29 && y==people_up-34) || 
                        (x==people_left+30 && y==people_up-34) || 
                        (x==people_left+31 && y==people_up-34) || 
                        (x==people_left+32 && y==people_up-34) || 
                        (x==people_left+33 && y==people_up-34) || 
                        (x==people_left+34 && y==people_up-34) || 
                        (x==people_left+35 && y==people_up-34) || 
                        (x==people_left+36 && y==people_up-34) || 
                        (x==people_left+37 && y==people_up-34) || 
                        (x==people_left+38 && y==people_up-34) || 
                        (x==people_left+39 && y==people_up-34) || 
                        (x==people_left+40 && y==people_up-34) || 
                        (x==people_left+41 && y==people_up-34) || 
                        (x==people_left+42 && y==people_up-34) || 
                        (x==people_left+43 && y==people_up-34) || 
                        (x==people_left+44 && y==people_up-34) || 
                        (x==people_left+45 && y==people_up-34) || 
                        (x==people_left+46 && y==people_up-34) || 
                        (x==people_left-10 && y==people_up-33) || 
                        (x==people_left-9 && y==people_up-33) || 
                        (x==people_left-8 && y==people_up-33) || 
                        (x==people_left-7 && y==people_up-33) || 
                        (x==people_left-6 && y==people_up-33) || 
                        (x==people_left-5 && y==people_up-33) || 
                        (x==people_left-4 && y==people_up-33) || 
                        (x==people_left-3 && y==people_up-33) || 
                        (x==people_left-2 && y==people_up-33) || 
                        (x==people_left-1 && y==people_up-33) || 
                        (x==people_left+0 && y==people_up-33) || 
                        (x==people_left+1 && y==people_up-33) || 
                        (x==people_left+2 && y==people_up-33) || 
                        (x==people_left+3 && y==people_up-33) || 
                        (x==people_left+4 && y==people_up-33) || 
                        (x==people_left+5 && y==people_up-33) || 
                        (x==people_left+6 && y==people_up-33) || 
                        (x==people_left+7 && y==people_up-33) || 
                        (x==people_left+8 && y==people_up-33) || 
                        (x==people_left+9 && y==people_up-33) || 
                        (x==people_left+10 && y==people_up-33) || 
                        (x==people_left+11 && y==people_up-33) || 
                        (x==people_left+12 && y==people_up-33) || 
                        (x==people_left+13 && y==people_up-33) || 
                        (x==people_left+14 && y==people_up-33) || 
                        (x==people_left+15 && y==people_up-33) || 
                        (x==people_left+16 && y==people_up-33) || 
                        (x==people_left+17 && y==people_up-33) || 
                        (x==people_left+18 && y==people_up-33) || 
                        (x==people_left+19 && y==people_up-33) || 
                        (x==people_left+20 && y==people_up-33) || 
                        (x==people_left+21 && y==people_up-33) || 
                        (x==people_left+22 && y==people_up-33) || 
                        (x==people_left+23 && y==people_up-33) || 
                        (x==people_left+24 && y==people_up-33) || 
                        (x==people_left+25 && y==people_up-33) || 
                        (x==people_left+26 && y==people_up-33) || 
                        (x==people_left+27 && y==people_up-33) || 
                        (x==people_left+28 && y==people_up-33) || 
                        (x==people_left+29 && y==people_up-33) || 
                        (x==people_left+30 && y==people_up-33) || 
                        (x==people_left+31 && y==people_up-33) || 
                        (x==people_left+32 && y==people_up-33) || 
                        (x==people_left+33 && y==people_up-33) || 
                        (x==people_left+34 && y==people_up-33) || 
                        (x==people_left+35 && y==people_up-33) || 
                        (x==people_left+36 && y==people_up-33) || 
                        (x==people_left+37 && y==people_up-33) || 
                        (x==people_left+38 && y==people_up-33) || 
                        (x==people_left+39 && y==people_up-33) || 
                        (x==people_left+40 && y==people_up-33) || 
                        (x==people_left+41 && y==people_up-33) || 
                        (x==people_left+42 && y==people_up-33) || 
                        (x==people_left+43 && y==people_up-33) || 
                        (x==people_left+44 && y==people_up-33) || 
                        (x==people_left+45 && y==people_up-33) || 
                        (x==people_left+46 && y==people_up-33) || 
                        (x==people_left+47 && y==people_up-33) || 
                        (x==people_left+48 && y==people_up-33) || 
                        (x==people_left-12 && y==people_up-32) || 
                        (x==people_left-11 && y==people_up-32) || 
                        (x==people_left-10 && y==people_up-32) || 
                        (x==people_left-9 && y==people_up-32) || 
                        (x==people_left-8 && y==people_up-32) || 
                        (x==people_left-7 && y==people_up-32) || 
                        (x==people_left-6 && y==people_up-32) || 
                        (x==people_left-5 && y==people_up-32) || 
                        (x==people_left-4 && y==people_up-32) || 
                        (x==people_left-3 && y==people_up-32) || 
                        (x==people_left-2 && y==people_up-32) || 
                        (x==people_left-1 && y==people_up-32) || 
                        (x==people_left+0 && y==people_up-32) || 
                        (x==people_left+1 && y==people_up-32) || 
                        (x==people_left+2 && y==people_up-32) || 
                        (x==people_left+3 && y==people_up-32) || 
                        (x==people_left+4 && y==people_up-32) || 
                        (x==people_left+5 && y==people_up-32) || 
                        (x==people_left+6 && y==people_up-32) || 
                        (x==people_left+7 && y==people_up-32) || 
                        (x==people_left+8 && y==people_up-32) || 
                        (x==people_left+9 && y==people_up-32) || 
                        (x==people_left+10 && y==people_up-32) || 
                        (x==people_left+11 && y==people_up-32) || 
                        (x==people_left+12 && y==people_up-32) || 
                        (x==people_left+13 && y==people_up-32) || 
                        (x==people_left+14 && y==people_up-32) || 
                        (x==people_left+15 && y==people_up-32) || 
                        (x==people_left+16 && y==people_up-32) || 
                        (x==people_left+17 && y==people_up-32) || 
                        (x==people_left+18 && y==people_up-32) || 
                        (x==people_left+19 && y==people_up-32) || 
                        (x==people_left+20 && y==people_up-32) || 
                        (x==people_left+21 && y==people_up-32) || 
                        (x==people_left+22 && y==people_up-32) || 
                        (x==people_left+23 && y==people_up-32) || 
                        (x==people_left+24 && y==people_up-32) || 
                        (x==people_left+25 && y==people_up-32) || 
                        (x==people_left+26 && y==people_up-32) || 
                        (x==people_left+27 && y==people_up-32) || 
                        (x==people_left+28 && y==people_up-32) || 
                        (x==people_left+29 && y==people_up-32) || 
                        (x==people_left+30 && y==people_up-32) || 
                        (x==people_left+31 && y==people_up-32) || 
                        (x==people_left+32 && y==people_up-32) || 
                        (x==people_left+33 && y==people_up-32) || 
                        (x==people_left+34 && y==people_up-32) || 
                        (x==people_left+35 && y==people_up-32) || 
                        (x==people_left+36 && y==people_up-32) || 
                        (x==people_left+37 && y==people_up-32) || 
                        (x==people_left+38 && y==people_up-32) || 
                        (x==people_left+39 && y==people_up-32) || 
                        (x==people_left+40 && y==people_up-32) || 
                        (x==people_left+41 && y==people_up-32) || 
                        (x==people_left+42 && y==people_up-32) || 
                        (x==people_left+43 && y==people_up-32) || 
                        (x==people_left+44 && y==people_up-32) || 
                        (x==people_left+45 && y==people_up-32) || 
                        (x==people_left+46 && y==people_up-32) || 
                        (x==people_left+47 && y==people_up-32) || 
                        (x==people_left+48 && y==people_up-32) || 
                        (x==people_left+49 && y==people_up-32) || 
                        (x==people_left+50 && y==people_up-32) || 
                        (x==people_left-13 && y==people_up-31) || 
                        (x==people_left-12 && y==people_up-31) || 
                        (x==people_left-11 && y==people_up-31) || 
                        (x==people_left-10 && y==people_up-31) || 
                        (x==people_left-9 && y==people_up-31) || 
                        (x==people_left-8 && y==people_up-31) || 
                        (x==people_left-7 && y==people_up-31) || 
                        (x==people_left-6 && y==people_up-31) || 
                        (x==people_left-5 && y==people_up-31) || 
                        (x==people_left-4 && y==people_up-31) || 
                        (x==people_left-3 && y==people_up-31) || 
                        (x==people_left-2 && y==people_up-31) || 
                        (x==people_left-1 && y==people_up-31) || 
                        (x==people_left+0 && y==people_up-31) || 
                        (x==people_left+1 && y==people_up-31) || 
                        (x==people_left+2 && y==people_up-31) || 
                        (x==people_left+3 && y==people_up-31) || 
                        (x==people_left+4 && y==people_up-31) || 
                        (x==people_left+5 && y==people_up-31) || 
                        (x==people_left+6 && y==people_up-31) || 
                        (x==people_left+7 && y==people_up-31) || 
                        (x==people_left+8 && y==people_up-31) || 
                        (x==people_left+9 && y==people_up-31) || 
                        (x==people_left+10 && y==people_up-31) || 
                        (x==people_left+11 && y==people_up-31) || 
                        (x==people_left+12 && y==people_up-31) || 
                        (x==people_left+13 && y==people_up-31) || 
                        (x==people_left+14 && y==people_up-31) || 
                        (x==people_left+15 && y==people_up-31) || 
                        (x==people_left+16 && y==people_up-31) || 
                        (x==people_left+17 && y==people_up-31) || 
                        (x==people_left+18 && y==people_up-31) || 
                        (x==people_left+19 && y==people_up-31) || 
                        (x==people_left+20 && y==people_up-31) || 
                        (x==people_left+21 && y==people_up-31) || 
                        (x==people_left+22 && y==people_up-31) || 
                        (x==people_left+23 && y==people_up-31) || 
                        (x==people_left+24 && y==people_up-31) || 
                        (x==people_left+25 && y==people_up-31) || 
                        (x==people_left+26 && y==people_up-31) || 
                        (x==people_left+27 && y==people_up-31) || 
                        (x==people_left+28 && y==people_up-31) || 
                        (x==people_left+29 && y==people_up-31) || 
                        (x==people_left+30 && y==people_up-31) || 
                        (x==people_left+31 && y==people_up-31) || 
                        (x==people_left+32 && y==people_up-31) || 
                        (x==people_left+33 && y==people_up-31) || 
                        (x==people_left+34 && y==people_up-31) || 
                        (x==people_left+35 && y==people_up-31) || 
                        (x==people_left+36 && y==people_up-31) || 
                        (x==people_left+37 && y==people_up-31) || 
                        (x==people_left+38 && y==people_up-31) || 
                        (x==people_left+39 && y==people_up-31) || 
                        (x==people_left+40 && y==people_up-31) || 
                        (x==people_left+41 && y==people_up-31) || 
                        (x==people_left+42 && y==people_up-31) || 
                        (x==people_left+43 && y==people_up-31) || 
                        (x==people_left+44 && y==people_up-31) || 
                        (x==people_left+45 && y==people_up-31) || 
                        (x==people_left+46 && y==people_up-31) || 
                        (x==people_left+47 && y==people_up-31) || 
                        (x==people_left+48 && y==people_up-31) || 
                        (x==people_left+49 && y==people_up-31) || 
                        (x==people_left+50 && y==people_up-31) || 
                        (x==people_left+51 && y==people_up-31) || 
                        (x==people_left-15 && y==people_up-30) || 
                        (x==people_left-14 && y==people_up-30) || 
                        (x==people_left-13 && y==people_up-30) || 
                        (x==people_left-12 && y==people_up-30) || 
                        (x==people_left-11 && y==people_up-30) || 
                        (x==people_left-10 && y==people_up-30) || 
                        (x==people_left-9 && y==people_up-30) || 
                        (x==people_left-8 && y==people_up-30) || 
                        (x==people_left-7 && y==people_up-30) || 
                        (x==people_left-6 && y==people_up-30) || 
                        (x==people_left-5 && y==people_up-30) || 
                        (x==people_left-4 && y==people_up-30) || 
                        (x==people_left-3 && y==people_up-30) || 
                        (x==people_left-2 && y==people_up-30) || 
                        (x==people_left-1 && y==people_up-30) || 
                        (x==people_left+0 && y==people_up-30) || 
                        (x==people_left+1 && y==people_up-30) || 
                        (x==people_left+2 && y==people_up-30) || 
                        (x==people_left+3 && y==people_up-30) || 
                        (x==people_left+4 && y==people_up-30) || 
                        (x==people_left+5 && y==people_up-30) || 
                        (x==people_left+6 && y==people_up-30) || 
                        (x==people_left+7 && y==people_up-30) || 
                        (x==people_left+8 && y==people_up-30) || 
                        (x==people_left+9 && y==people_up-30) || 
                        (x==people_left+10 && y==people_up-30) || 
                        (x==people_left+11 && y==people_up-30) || 
                        (x==people_left+12 && y==people_up-30) || 
                        (x==people_left+13 && y==people_up-30) || 
                        (x==people_left+14 && y==people_up-30) || 
                        (x==people_left+15 && y==people_up-30) || 
                        (x==people_left+16 && y==people_up-30) || 
                        (x==people_left+17 && y==people_up-30) || 
                        (x==people_left+18 && y==people_up-30) || 
                        (x==people_left+19 && y==people_up-30) || 
                        (x==people_left+20 && y==people_up-30) || 
                        (x==people_left+21 && y==people_up-30) || 
                        (x==people_left+22 && y==people_up-30) || 
                        (x==people_left+23 && y==people_up-30) || 
                        (x==people_left+24 && y==people_up-30) || 
                        (x==people_left+25 && y==people_up-30) || 
                        (x==people_left+26 && y==people_up-30) || 
                        (x==people_left+27 && y==people_up-30) || 
                        (x==people_left+28 && y==people_up-30) || 
                        (x==people_left+29 && y==people_up-30) || 
                        (x==people_left+30 && y==people_up-30) || 
                        (x==people_left+31 && y==people_up-30) || 
                        (x==people_left+32 && y==people_up-30) || 
                        (x==people_left+33 && y==people_up-30) || 
                        (x==people_left+34 && y==people_up-30) || 
                        (x==people_left+35 && y==people_up-30) || 
                        (x==people_left+36 && y==people_up-30) || 
                        (x==people_left+37 && y==people_up-30) || 
                        (x==people_left+38 && y==people_up-30) || 
                        (x==people_left+39 && y==people_up-30) || 
                        (x==people_left+40 && y==people_up-30) || 
                        (x==people_left+41 && y==people_up-30) || 
                        (x==people_left+42 && y==people_up-30) || 
                        (x==people_left+43 && y==people_up-30) || 
                        (x==people_left+44 && y==people_up-30) || 
                        (x==people_left+45 && y==people_up-30) || 
                        (x==people_left+46 && y==people_up-30) || 
                        (x==people_left+47 && y==people_up-30) || 
                        (x==people_left+48 && y==people_up-30) || 
                        (x==people_left+49 && y==people_up-30) || 
                        (x==people_left+50 && y==people_up-30) || 
                        (x==people_left+51 && y==people_up-30) || 
                        (x==people_left+52 && y==people_up-30) || 
                        (x==people_left+53 && y==people_up-30) || 
                        (x==people_left-16 && y==people_up-29) || 
                        (x==people_left-15 && y==people_up-29) || 
                        (x==people_left-14 && y==people_up-29) || 
                        (x==people_left-13 && y==people_up-29) || 
                        (x==people_left-12 && y==people_up-29) || 
                        (x==people_left-11 && y==people_up-29) || 
                        (x==people_left-10 && y==people_up-29) || 
                        (x==people_left-9 && y==people_up-29) || 
                        (x==people_left-8 && y==people_up-29) || 
                        (x==people_left-7 && y==people_up-29) || 
                        (x==people_left-6 && y==people_up-29) || 
                        (x==people_left-5 && y==people_up-29) || 
                        (x==people_left-4 && y==people_up-29) || 
                        (x==people_left-3 && y==people_up-29) || 
                        (x==people_left-2 && y==people_up-29) || 
                        (x==people_left-1 && y==people_up-29) || 
                        (x==people_left+0 && y==people_up-29) || 
                        (x==people_left+1 && y==people_up-29) || 
                        (x==people_left+2 && y==people_up-29) || 
                        (x==people_left+3 && y==people_up-29) || 
                        (x==people_left+4 && y==people_up-29) || 
                        (x==people_left+5 && y==people_up-29) || 
                        (x==people_left+6 && y==people_up-29) || 
                        (x==people_left+7 && y==people_up-29) || 
                        (x==people_left+8 && y==people_up-29) || 
                        (x==people_left+9 && y==people_up-29) || 
                        (x==people_left+10 && y==people_up-29) || 
                        (x==people_left+11 && y==people_up-29) || 
                        (x==people_left+12 && y==people_up-29) || 
                        (x==people_left+13 && y==people_up-29) || 
                        (x==people_left+14 && y==people_up-29) || 
                        (x==people_left+15 && y==people_up-29) || 
                        (x==people_left+16 && y==people_up-29) || 
                        (x==people_left+17 && y==people_up-29) || 
                        (x==people_left+18 && y==people_up-29) || 
                        (x==people_left+19 && y==people_up-29) || 
                        (x==people_left+20 && y==people_up-29) || 
                        (x==people_left+21 && y==people_up-29) || 
                        (x==people_left+22 && y==people_up-29) || 
                        (x==people_left+23 && y==people_up-29) || 
                        (x==people_left+24 && y==people_up-29) || 
                        (x==people_left+25 && y==people_up-29) || 
                        (x==people_left+26 && y==people_up-29) || 
                        (x==people_left+27 && y==people_up-29) || 
                        (x==people_left+28 && y==people_up-29) || 
                        (x==people_left+29 && y==people_up-29) || 
                        (x==people_left+30 && y==people_up-29) || 
                        (x==people_left+31 && y==people_up-29) || 
                        (x==people_left+32 && y==people_up-29) || 
                        (x==people_left+33 && y==people_up-29) || 
                        (x==people_left+34 && y==people_up-29) || 
                        (x==people_left+35 && y==people_up-29) || 
                        (x==people_left+36 && y==people_up-29) || 
                        (x==people_left+37 && y==people_up-29) || 
                        (x==people_left+38 && y==people_up-29) || 
                        (x==people_left+39 && y==people_up-29) || 
                        (x==people_left+40 && y==people_up-29) || 
                        (x==people_left+41 && y==people_up-29) || 
                        (x==people_left+42 && y==people_up-29) || 
                        (x==people_left+43 && y==people_up-29) || 
                        (x==people_left+44 && y==people_up-29) || 
                        (x==people_left+45 && y==people_up-29) || 
                        (x==people_left+46 && y==people_up-29) || 
                        (x==people_left+47 && y==people_up-29) || 
                        (x==people_left+48 && y==people_up-29) || 
                        (x==people_left+49 && y==people_up-29) || 
                        (x==people_left+50 && y==people_up-29) || 
                        (x==people_left+51 && y==people_up-29) || 
                        (x==people_left+52 && y==people_up-29) || 
                        (x==people_left+53 && y==people_up-29) || 
                        (x==people_left+54 && y==people_up-29) || 
                        (x==people_left-17 && y==people_up-28) || 
                        (x==people_left-16 && y==people_up-28) || 
                        (x==people_left-15 && y==people_up-28) || 
                        (x==people_left-14 && y==people_up-28) || 
                        (x==people_left-13 && y==people_up-28) || 
                        (x==people_left-12 && y==people_up-28) || 
                        (x==people_left-11 && y==people_up-28) || 
                        (x==people_left-10 && y==people_up-28) || 
                        (x==people_left-9 && y==people_up-28) || 
                        (x==people_left-8 && y==people_up-28) || 
                        (x==people_left-7 && y==people_up-28) || 
                        (x==people_left-6 && y==people_up-28) || 
                        (x==people_left-5 && y==people_up-28) || 
                        (x==people_left-4 && y==people_up-28) || 
                        (x==people_left-3 && y==people_up-28) || 
                        (x==people_left-2 && y==people_up-28) || 
                        (x==people_left-1 && y==people_up-28) || 
                        (x==people_left+0 && y==people_up-28) || 
                        (x==people_left+1 && y==people_up-28) || 
                        (x==people_left+2 && y==people_up-28) || 
                        (x==people_left+3 && y==people_up-28) || 
                        (x==people_left+4 && y==people_up-28) || 
                        (x==people_left+5 && y==people_up-28) || 
                        (x==people_left+6 && y==people_up-28) || 
                        (x==people_left+7 && y==people_up-28) || 
                        (x==people_left+8 && y==people_up-28) || 
                        (x==people_left+9 && y==people_up-28) || 
                        (x==people_left+10 && y==people_up-28) || 
                        (x==people_left+11 && y==people_up-28) || 
                        (x==people_left+12 && y==people_up-28) || 
                        (x==people_left+13 && y==people_up-28) || 
                        (x==people_left+14 && y==people_up-28) || 
                        (x==people_left+15 && y==people_up-28) || 
                        (x==people_left+16 && y==people_up-28) || 
                        (x==people_left+17 && y==people_up-28) || 
                        (x==people_left+18 && y==people_up-28) || 
                        (x==people_left+19 && y==people_up-28) || 
                        (x==people_left+20 && y==people_up-28) || 
                        (x==people_left+21 && y==people_up-28) || 
                        (x==people_left+22 && y==people_up-28) || 
                        (x==people_left+23 && y==people_up-28) || 
                        (x==people_left+24 && y==people_up-28) || 
                        (x==people_left+25 && y==people_up-28) || 
                        (x==people_left+26 && y==people_up-28) || 
                        (x==people_left+27 && y==people_up-28) || 
                        (x==people_left+28 && y==people_up-28) || 
                        (x==people_left+29 && y==people_up-28) || 
                        (x==people_left+30 && y==people_up-28) || 
                        (x==people_left+31 && y==people_up-28) || 
                        (x==people_left+32 && y==people_up-28) || 
                        (x==people_left+33 && y==people_up-28) || 
                        (x==people_left+34 && y==people_up-28) || 
                        (x==people_left+35 && y==people_up-28) || 
                        (x==people_left+36 && y==people_up-28) || 
                        (x==people_left+37 && y==people_up-28) || 
                        (x==people_left+38 && y==people_up-28) || 
                        (x==people_left+39 && y==people_up-28) || 
                        (x==people_left+40 && y==people_up-28) || 
                        (x==people_left+41 && y==people_up-28) || 
                        (x==people_left+42 && y==people_up-28) || 
                        (x==people_left+43 && y==people_up-28) || 
                        (x==people_left+44 && y==people_up-28) || 
                        (x==people_left+45 && y==people_up-28) || 
                        (x==people_left+46 && y==people_up-28) || 
                        (x==people_left+47 && y==people_up-28) || 
                        (x==people_left+48 && y==people_up-28) || 
                        (x==people_left+49 && y==people_up-28) || 
                        (x==people_left+50 && y==people_up-28) || 
                        (x==people_left+51 && y==people_up-28) || 
                        (x==people_left+52 && y==people_up-28) || 
                        (x==people_left+53 && y==people_up-28) || 
                        (x==people_left+54 && y==people_up-28) || 
                        (x==people_left+55 && y==people_up-28) || 
                        (x==people_left-19 && y==people_up-27) || 
                        (x==people_left-18 && y==people_up-27) || 
                        (x==people_left-17 && y==people_up-27) || 
                        (x==people_left-16 && y==people_up-27) || 
                        (x==people_left-15 && y==people_up-27) || 
                        (x==people_left-14 && y==people_up-27) || 
                        (x==people_left-13 && y==people_up-27) || 
                        (x==people_left-12 && y==people_up-27) || 
                        (x==people_left-11 && y==people_up-27) || 
                        (x==people_left-10 && y==people_up-27) || 
                        (x==people_left-9 && y==people_up-27) || 
                        (x==people_left-8 && y==people_up-27) || 
                        (x==people_left-7 && y==people_up-27) || 
                        (x==people_left-6 && y==people_up-27) || 
                        (x==people_left-5 && y==people_up-27) || 
                        (x==people_left-4 && y==people_up-27) || 
                        (x==people_left-3 && y==people_up-27) || 
                        (x==people_left-2 && y==people_up-27) || 
                        (x==people_left-1 && y==people_up-27) || 
                        (x==people_left+0 && y==people_up-27) || 
                        (x==people_left+1 && y==people_up-27) || 
                        (x==people_left+2 && y==people_up-27) || 
                        (x==people_left+3 && y==people_up-27) || 
                        (x==people_left+4 && y==people_up-27) || 
                        (x==people_left+5 && y==people_up-27) || 
                        (x==people_left+6 && y==people_up-27) || 
                        (x==people_left+7 && y==people_up-27) || 
                        (x==people_left+8 && y==people_up-27) || 
                        (x==people_left+9 && y==people_up-27) || 
                        (x==people_left+10 && y==people_up-27) || 
                        (x==people_left+11 && y==people_up-27) || 
                        (x==people_left+12 && y==people_up-27) || 
                        (x==people_left+13 && y==people_up-27) || 
                        (x==people_left+14 && y==people_up-27) || 
                        (x==people_left+15 && y==people_up-27) || 
                        (x==people_left+16 && y==people_up-27) || 
                        (x==people_left+17 && y==people_up-27) || 
                        (x==people_left+18 && y==people_up-27) || 
                        (x==people_left+19 && y==people_up-27) || 
                        (x==people_left+20 && y==people_up-27) || 
                        (x==people_left+21 && y==people_up-27) || 
                        (x==people_left+22 && y==people_up-27) || 
                        (x==people_left+23 && y==people_up-27) || 
                        (x==people_left+24 && y==people_up-27) || 
                        (x==people_left+25 && y==people_up-27) || 
                        (x==people_left+26 && y==people_up-27) || 
                        (x==people_left+27 && y==people_up-27) || 
                        (x==people_left+28 && y==people_up-27) || 
                        (x==people_left+29 && y==people_up-27) || 
                        (x==people_left+30 && y==people_up-27) || 
                        (x==people_left+31 && y==people_up-27) || 
                        (x==people_left+32 && y==people_up-27) || 
                        (x==people_left+33 && y==people_up-27) || 
                        (x==people_left+34 && y==people_up-27) || 
                        (x==people_left+35 && y==people_up-27) || 
                        (x==people_left+36 && y==people_up-27) || 
                        (x==people_left+37 && y==people_up-27) || 
                        (x==people_left+38 && y==people_up-27) || 
                        (x==people_left+39 && y==people_up-27) || 
                        (x==people_left+40 && y==people_up-27) || 
                        (x==people_left+41 && y==people_up-27) || 
                        (x==people_left+42 && y==people_up-27) || 
                        (x==people_left+43 && y==people_up-27) || 
                        (x==people_left+44 && y==people_up-27) || 
                        (x==people_left+45 && y==people_up-27) || 
                        (x==people_left+46 && y==people_up-27) || 
                        (x==people_left+47 && y==people_up-27) || 
                        (x==people_left+48 && y==people_up-27) || 
                        (x==people_left+49 && y==people_up-27) || 
                        (x==people_left+50 && y==people_up-27) || 
                        (x==people_left+51 && y==people_up-27) || 
                        (x==people_left+52 && y==people_up-27) || 
                        (x==people_left+53 && y==people_up-27) || 
                        (x==people_left+54 && y==people_up-27) || 
                        (x==people_left+55 && y==people_up-27) || 
                        (x==people_left+56 && y==people_up-27) || 
                        (x==people_left+57 && y==people_up-27) || 
                        (x==people_left-20 && y==people_up-26) || 
                        (x==people_left-19 && y==people_up-26) || 
                        (x==people_left-18 && y==people_up-26) || 
                        (x==people_left-17 && y==people_up-26) || 
                        (x==people_left-16 && y==people_up-26) || 
                        (x==people_left-15 && y==people_up-26) || 
                        (x==people_left-14 && y==people_up-26) || 
                        (x==people_left-13 && y==people_up-26) || 
                        (x==people_left-12 && y==people_up-26) || 
                        (x==people_left-11 && y==people_up-26) || 
                        (x==people_left-10 && y==people_up-26) || 
                        (x==people_left-9 && y==people_up-26) || 
                        (x==people_left-8 && y==people_up-26) || 
                        (x==people_left-7 && y==people_up-26) || 
                        (x==people_left-6 && y==people_up-26) || 
                        (x==people_left-5 && y==people_up-26) || 
                        (x==people_left-4 && y==people_up-26) || 
                        (x==people_left-3 && y==people_up-26) || 
                        (x==people_left-2 && y==people_up-26) || 
                        (x==people_left-1 && y==people_up-26) || 
                        (x==people_left+0 && y==people_up-26) || 
                        (x==people_left+1 && y==people_up-26) || 
                        (x==people_left+2 && y==people_up-26) || 
                        (x==people_left+3 && y==people_up-26) || 
                        (x==people_left+4 && y==people_up-26) || 
                        (x==people_left+5 && y==people_up-26) || 
                        (x==people_left+6 && y==people_up-26) || 
                        (x==people_left+7 && y==people_up-26) || 
                        (x==people_left+8 && y==people_up-26) || 
                        (x==people_left+9 && y==people_up-26) || 
                        (x==people_left+10 && y==people_up-26) || 
                        (x==people_left+11 && y==people_up-26) || 
                        (x==people_left+12 && y==people_up-26) || 
                        (x==people_left+13 && y==people_up-26) || 
                        (x==people_left+14 && y==people_up-26) || 
                        (x==people_left+15 && y==people_up-26) || 
                        (x==people_left+16 && y==people_up-26) || 
                        (x==people_left+17 && y==people_up-26) || 
                        (x==people_left+18 && y==people_up-26) || 
                        (x==people_left+19 && y==people_up-26) || 
                        (x==people_left+20 && y==people_up-26) || 
                        (x==people_left+21 && y==people_up-26) || 
                        (x==people_left+22 && y==people_up-26) || 
                        (x==people_left+23 && y==people_up-26) || 
                        (x==people_left+24 && y==people_up-26) || 
                        (x==people_left+25 && y==people_up-26) || 
                        (x==people_left+26 && y==people_up-26) || 
                        (x==people_left+27 && y==people_up-26) || 
                        (x==people_left+28 && y==people_up-26) || 
                        (x==people_left+29 && y==people_up-26) || 
                        (x==people_left+30 && y==people_up-26) || 
                        (x==people_left+31 && y==people_up-26) || 
                        (x==people_left+32 && y==people_up-26) || 
                        (x==people_left+33 && y==people_up-26) || 
                        (x==people_left+34 && y==people_up-26) || 
                        (x==people_left+35 && y==people_up-26) || 
                        (x==people_left+36 && y==people_up-26) || 
                        (x==people_left+37 && y==people_up-26) || 
                        (x==people_left+38 && y==people_up-26) || 
                        (x==people_left+39 && y==people_up-26) || 
                        (x==people_left+40 && y==people_up-26) || 
                        (x==people_left+41 && y==people_up-26) || 
                        (x==people_left+42 && y==people_up-26) || 
                        (x==people_left+43 && y==people_up-26) || 
                        (x==people_left+44 && y==people_up-26) || 
                        (x==people_left+45 && y==people_up-26) || 
                        (x==people_left+46 && y==people_up-26) || 
                        (x==people_left+47 && y==people_up-26) || 
                        (x==people_left+48 && y==people_up-26) || 
                        (x==people_left+49 && y==people_up-26) || 
                        (x==people_left+50 && y==people_up-26) || 
                        (x==people_left+51 && y==people_up-26) || 
                        (x==people_left+52 && y==people_up-26) || 
                        (x==people_left+53 && y==people_up-26) || 
                        (x==people_left+54 && y==people_up-26) || 
                        (x==people_left+55 && y==people_up-26) || 
                        (x==people_left+56 && y==people_up-26) || 
                        (x==people_left+57 && y==people_up-26) || 
                        (x==people_left+58 && y==people_up-26) || 
                        (x==people_left-21 && y==people_up-25) || 
                        (x==people_left-20 && y==people_up-25) || 
                        (x==people_left-19 && y==people_up-25) || 
                        (x==people_left-18 && y==people_up-25) || 
                        (x==people_left-17 && y==people_up-25) || 
                        (x==people_left-16 && y==people_up-25) || 
                        (x==people_left-15 && y==people_up-25) || 
                        (x==people_left-14 && y==people_up-25) || 
                        (x==people_left-13 && y==people_up-25) || 
                        (x==people_left-12 && y==people_up-25) || 
                        (x==people_left-11 && y==people_up-25) || 
                        (x==people_left-10 && y==people_up-25) || 
                        (x==people_left-9 && y==people_up-25) || 
                        (x==people_left-8 && y==people_up-25) || 
                        (x==people_left-7 && y==people_up-25) || 
                        (x==people_left-6 && y==people_up-25) || 
                        (x==people_left-5 && y==people_up-25) || 
                        (x==people_left-4 && y==people_up-25) || 
                        (x==people_left-3 && y==people_up-25) || 
                        (x==people_left-2 && y==people_up-25) || 
                        (x==people_left-1 && y==people_up-25) || 
                        (x==people_left+0 && y==people_up-25) || 
                        (x==people_left+1 && y==people_up-25) || 
                        (x==people_left+2 && y==people_up-25) || 
                        (x==people_left+3 && y==people_up-25) || 
                        (x==people_left+4 && y==people_up-25) || 
                        (x==people_left+5 && y==people_up-25) || 
                        (x==people_left+6 && y==people_up-25) || 
                        (x==people_left+7 && y==people_up-25) || 
                        (x==people_left+8 && y==people_up-25) || 
                        (x==people_left+9 && y==people_up-25) || 
                        (x==people_left+10 && y==people_up-25) || 
                        (x==people_left+11 && y==people_up-25) || 
                        (x==people_left+12 && y==people_up-25) || 
                        (x==people_left+13 && y==people_up-25) || 
                        (x==people_left+14 && y==people_up-25) || 
                        (x==people_left+15 && y==people_up-25) || 
                        (x==people_left+16 && y==people_up-25) || 
                        (x==people_left+17 && y==people_up-25) || 
                        (x==people_left+18 && y==people_up-25) || 
                        (x==people_left+19 && y==people_up-25) || 
                        (x==people_left+20 && y==people_up-25) || 
                        (x==people_left+21 && y==people_up-25) || 
                        (x==people_left+22 && y==people_up-25) || 
                        (x==people_left+23 && y==people_up-25) || 
                        (x==people_left+24 && y==people_up-25) || 
                        (x==people_left+25 && y==people_up-25) || 
                        (x==people_left+26 && y==people_up-25) || 
                        (x==people_left+27 && y==people_up-25) || 
                        (x==people_left+28 && y==people_up-25) || 
                        (x==people_left+29 && y==people_up-25) || 
                        (x==people_left+30 && y==people_up-25) || 
                        (x==people_left+31 && y==people_up-25) || 
                        (x==people_left+32 && y==people_up-25) || 
                        (x==people_left+33 && y==people_up-25) || 
                        (x==people_left+34 && y==people_up-25) || 
                        (x==people_left+35 && y==people_up-25) || 
                        (x==people_left+36 && y==people_up-25) || 
                        (x==people_left+37 && y==people_up-25) || 
                        (x==people_left+38 && y==people_up-25) || 
                        (x==people_left+39 && y==people_up-25) || 
                        (x==people_left+40 && y==people_up-25) || 
                        (x==people_left+41 && y==people_up-25) || 
                        (x==people_left+42 && y==people_up-25) || 
                        (x==people_left+43 && y==people_up-25) || 
                        (x==people_left+44 && y==people_up-25) || 
                        (x==people_left+45 && y==people_up-25) || 
                        (x==people_left+46 && y==people_up-25) || 
                        (x==people_left+47 && y==people_up-25) || 
                        (x==people_left+48 && y==people_up-25) || 
                        (x==people_left+49 && y==people_up-25) || 
                        (x==people_left+50 && y==people_up-25) || 
                        (x==people_left+51 && y==people_up-25) || 
                        (x==people_left+52 && y==people_up-25) || 
                        (x==people_left+53 && y==people_up-25) || 
                        (x==people_left+54 && y==people_up-25) || 
                        (x==people_left+55 && y==people_up-25) || 
                        (x==people_left+56 && y==people_up-25) || 
                        (x==people_left+57 && y==people_up-25) || 
                        (x==people_left+58 && y==people_up-25) || 
                        (x==people_left+59 && y==people_up-25) || 
                        (x==people_left-22 && y==people_up-24) || 
                        (x==people_left-21 && y==people_up-24) || 
                        (x==people_left-20 && y==people_up-24) || 
                        (x==people_left-19 && y==people_up-24) || 
                        (x==people_left-18 && y==people_up-24) || 
                        (x==people_left-17 && y==people_up-24) || 
                        (x==people_left-16 && y==people_up-24) || 
                        (x==people_left-15 && y==people_up-24) || 
                        (x==people_left-14 && y==people_up-24) || 
                        (x==people_left-13 && y==people_up-24) || 
                        (x==people_left-12 && y==people_up-24) || 
                        (x==people_left-11 && y==people_up-24) || 
                        (x==people_left-10 && y==people_up-24) || 
                        (x==people_left-9 && y==people_up-24) || 
                        (x==people_left-8 && y==people_up-24) || 
                        (x==people_left-7 && y==people_up-24) || 
                        (x==people_left-6 && y==people_up-24) || 
                        (x==people_left-5 && y==people_up-24) || 
                        (x==people_left-4 && y==people_up-24) || 
                        (x==people_left-3 && y==people_up-24) || 
                        (x==people_left-2 && y==people_up-24) || 
                        (x==people_left-1 && y==people_up-24) || 
                        (x==people_left+0 && y==people_up-24) || 
                        (x==people_left+1 && y==people_up-24) || 
                        (x==people_left+2 && y==people_up-24) || 
                        (x==people_left+3 && y==people_up-24) || 
                        (x==people_left+4 && y==people_up-24) || 
                        (x==people_left+5 && y==people_up-24) || 
                        (x==people_left+6 && y==people_up-24) || 
                        (x==people_left+7 && y==people_up-24) || 
                        (x==people_left+8 && y==people_up-24) || 
                        (x==people_left+9 && y==people_up-24) || 
                        (x==people_left+10 && y==people_up-24) || 
                        (x==people_left+11 && y==people_up-24) || 
                        (x==people_left+12 && y==people_up-24) || 
                        (x==people_left+13 && y==people_up-24) || 
                        (x==people_left+14 && y==people_up-24) || 
                        (x==people_left+15 && y==people_up-24) || 
                        (x==people_left+16 && y==people_up-24) || 
                        (x==people_left+17 && y==people_up-24) || 
                        (x==people_left+18 && y==people_up-24) || 
                        (x==people_left+19 && y==people_up-24) || 
                        (x==people_left+20 && y==people_up-24) || 
                        (x==people_left+21 && y==people_up-24) || 
                        (x==people_left+22 && y==people_up-24) || 
                        (x==people_left+23 && y==people_up-24) || 
                        (x==people_left+24 && y==people_up-24) || 
                        (x==people_left+25 && y==people_up-24) || 
                        (x==people_left+26 && y==people_up-24) || 
                        (x==people_left+27 && y==people_up-24) || 
                        (x==people_left+28 && y==people_up-24) || 
                        (x==people_left+29 && y==people_up-24) || 
                        (x==people_left+30 && y==people_up-24) || 
                        (x==people_left+31 && y==people_up-24) || 
                        (x==people_left+32 && y==people_up-24) || 
                        (x==people_left+33 && y==people_up-24) || 
                        (x==people_left+34 && y==people_up-24) || 
                        (x==people_left+35 && y==people_up-24) || 
                        (x==people_left+36 && y==people_up-24) || 
                        (x==people_left+37 && y==people_up-24) || 
                        (x==people_left+38 && y==people_up-24) || 
                        (x==people_left+39 && y==people_up-24) || 
                        (x==people_left+40 && y==people_up-24) || 
                        (x==people_left+41 && y==people_up-24) || 
                        (x==people_left+42 && y==people_up-24) || 
                        (x==people_left+43 && y==people_up-24) || 
                        (x==people_left+44 && y==people_up-24) || 
                        (x==people_left+45 && y==people_up-24) || 
                        (x==people_left+46 && y==people_up-24) || 
                        (x==people_left+47 && y==people_up-24) || 
                        (x==people_left+48 && y==people_up-24) || 
                        (x==people_left+49 && y==people_up-24) || 
                        (x==people_left+50 && y==people_up-24) || 
                        (x==people_left+51 && y==people_up-24) || 
                        (x==people_left+52 && y==people_up-24) || 
                        (x==people_left+53 && y==people_up-24) || 
                        (x==people_left+54 && y==people_up-24) || 
                        (x==people_left+55 && y==people_up-24) || 
                        (x==people_left+56 && y==people_up-24) || 
                        (x==people_left+57 && y==people_up-24) || 
                        (x==people_left+58 && y==people_up-24) || 
                        (x==people_left+59 && y==people_up-24) || 
                        (x==people_left+60 && y==people_up-24) || 
                        (x==people_left-23 && y==people_up-23) || 
                        (x==people_left-22 && y==people_up-23) || 
                        (x==people_left-21 && y==people_up-23) || 
                        (x==people_left-20 && y==people_up-23) || 
                        (x==people_left-19 && y==people_up-23) || 
                        (x==people_left-18 && y==people_up-23) || 
                        (x==people_left-17 && y==people_up-23) || 
                        (x==people_left-16 && y==people_up-23) || 
                        (x==people_left-15 && y==people_up-23) || 
                        (x==people_left-14 && y==people_up-23) || 
                        (x==people_left-13 && y==people_up-23) || 
                        (x==people_left-12 && y==people_up-23) || 
                        (x==people_left-11 && y==people_up-23) || 
                        (x==people_left-10 && y==people_up-23) || 
                        (x==people_left-9 && y==people_up-23) || 
                        (x==people_left-8 && y==people_up-23) || 
                        (x==people_left-7 && y==people_up-23) || 
                        (x==people_left-6 && y==people_up-23) || 
                        (x==people_left-5 && y==people_up-23) || 
                        (x==people_left-4 && y==people_up-23) || 
                        (x==people_left-3 && y==people_up-23) || 
                        (x==people_left-2 && y==people_up-23) || 
                        (x==people_left-1 && y==people_up-23) || 
                        (x==people_left+0 && y==people_up-23) || 
                        (x==people_left+1 && y==people_up-23) || 
                        (x==people_left+2 && y==people_up-23) || 
                        (x==people_left+3 && y==people_up-23) || 
                        (x==people_left+4 && y==people_up-23) || 
                        (x==people_left+5 && y==people_up-23) || 
                        (x==people_left+6 && y==people_up-23) || 
                        (x==people_left+7 && y==people_up-23) || 
                        (x==people_left+8 && y==people_up-23) || 
                        (x==people_left+9 && y==people_up-23) || 
                        (x==people_left+10 && y==people_up-23) || 
                        (x==people_left+11 && y==people_up-23) || 
                        (x==people_left+12 && y==people_up-23) || 
                        (x==people_left+13 && y==people_up-23) || 
                        (x==people_left+14 && y==people_up-23) || 
                        (x==people_left+15 && y==people_up-23) || 
                        (x==people_left+16 && y==people_up-23) || 
                        (x==people_left+17 && y==people_up-23) || 
                        (x==people_left+18 && y==people_up-23) || 
                        (x==people_left+19 && y==people_up-23) || 
                        (x==people_left+20 && y==people_up-23) || 
                        (x==people_left+21 && y==people_up-23) || 
                        (x==people_left+22 && y==people_up-23) || 
                        (x==people_left+23 && y==people_up-23) || 
                        (x==people_left+24 && y==people_up-23) || 
                        (x==people_left+25 && y==people_up-23) || 
                        (x==people_left+26 && y==people_up-23) || 
                        (x==people_left+27 && y==people_up-23) || 
                        (x==people_left+28 && y==people_up-23) || 
                        (x==people_left+29 && y==people_up-23) || 
                        (x==people_left+30 && y==people_up-23) || 
                        (x==people_left+31 && y==people_up-23) || 
                        (x==people_left+32 && y==people_up-23) || 
                        (x==people_left+33 && y==people_up-23) || 
                        (x==people_left+34 && y==people_up-23) || 
                        (x==people_left+35 && y==people_up-23) || 
                        (x==people_left+36 && y==people_up-23) || 
                        (x==people_left+37 && y==people_up-23) || 
                        (x==people_left+38 && y==people_up-23) || 
                        (x==people_left+39 && y==people_up-23) || 
                        (x==people_left+40 && y==people_up-23) || 
                        (x==people_left+41 && y==people_up-23) || 
                        (x==people_left+42 && y==people_up-23) || 
                        (x==people_left+43 && y==people_up-23) || 
                        (x==people_left+44 && y==people_up-23) || 
                        (x==people_left+45 && y==people_up-23) || 
                        (x==people_left+46 && y==people_up-23) || 
                        (x==people_left+47 && y==people_up-23) || 
                        (x==people_left+48 && y==people_up-23) || 
                        (x==people_left+49 && y==people_up-23) || 
                        (x==people_left+50 && y==people_up-23) || 
                        (x==people_left+51 && y==people_up-23) || 
                        (x==people_left+52 && y==people_up-23) || 
                        (x==people_left+53 && y==people_up-23) || 
                        (x==people_left+54 && y==people_up-23) || 
                        (x==people_left+55 && y==people_up-23) || 
                        (x==people_left+56 && y==people_up-23) || 
                        (x==people_left+57 && y==people_up-23) || 
                        (x==people_left+58 && y==people_up-23) || 
                        (x==people_left+59 && y==people_up-23) || 
                        (x==people_left+60 && y==people_up-23) || 
                        (x==people_left+61 && y==people_up-23) || 
                        (x==people_left-24 && y==people_up-22) || 
                        (x==people_left-23 && y==people_up-22) || 
                        (x==people_left-22 && y==people_up-22) || 
                        (x==people_left-21 && y==people_up-22) || 
                        (x==people_left-20 && y==people_up-22) || 
                        (x==people_left-19 && y==people_up-22) || 
                        (x==people_left-18 && y==people_up-22) || 
                        (x==people_left-17 && y==people_up-22) || 
                        (x==people_left-16 && y==people_up-22) || 
                        (x==people_left-15 && y==people_up-22) || 
                        (x==people_left-14 && y==people_up-22) || 
                        (x==people_left-13 && y==people_up-22) || 
                        (x==people_left-12 && y==people_up-22) || 
                        (x==people_left-11 && y==people_up-22) || 
                        (x==people_left-10 && y==people_up-22) || 
                        (x==people_left-9 && y==people_up-22) || 
                        (x==people_left-8 && y==people_up-22) || 
                        (x==people_left-7 && y==people_up-22) || 
                        (x==people_left-6 && y==people_up-22) || 
                        (x==people_left-5 && y==people_up-22) || 
                        (x==people_left-4 && y==people_up-22) || 
                        (x==people_left-3 && y==people_up-22) || 
                        (x==people_left-2 && y==people_up-22) || 
                        (x==people_left-1 && y==people_up-22) || 
                        (x==people_left+0 && y==people_up-22) || 
                        (x==people_left+1 && y==people_up-22) || 
                        (x==people_left+2 && y==people_up-22) || 
                        (x==people_left+3 && y==people_up-22) || 
                        (x==people_left+4 && y==people_up-22) || 
                        (x==people_left+5 && y==people_up-22) || 
                        (x==people_left+6 && y==people_up-22) || 
                        (x==people_left+7 && y==people_up-22) || 
                        (x==people_left+8 && y==people_up-22) || 
                        (x==people_left+9 && y==people_up-22) || 
                        (x==people_left+10 && y==people_up-22) || 
                        (x==people_left+11 && y==people_up-22) || 
                        (x==people_left+12 && y==people_up-22) || 
                        (x==people_left+13 && y==people_up-22) || 
                        (x==people_left+14 && y==people_up-22) || 
                        (x==people_left+15 && y==people_up-22) || 
                        (x==people_left+16 && y==people_up-22) || 
                        (x==people_left+17 && y==people_up-22) || 
                        (x==people_left+18 && y==people_up-22) || 
                        (x==people_left+19 && y==people_up-22) || 
                        (x==people_left+20 && y==people_up-22) || 
                        (x==people_left+21 && y==people_up-22) || 
                        (x==people_left+22 && y==people_up-22) || 
                        (x==people_left+23 && y==people_up-22) || 
                        (x==people_left+24 && y==people_up-22) || 
                        (x==people_left+25 && y==people_up-22) || 
                        (x==people_left+26 && y==people_up-22) || 
                        (x==people_left+27 && y==people_up-22) || 
                        (x==people_left+28 && y==people_up-22) || 
                        (x==people_left+29 && y==people_up-22) || 
                        (x==people_left+30 && y==people_up-22) || 
                        (x==people_left+31 && y==people_up-22) || 
                        (x==people_left+32 && y==people_up-22) || 
                        (x==people_left+33 && y==people_up-22) || 
                        (x==people_left+34 && y==people_up-22) || 
                        (x==people_left+35 && y==people_up-22) || 
                        (x==people_left+36 && y==people_up-22) || 
                        (x==people_left+37 && y==people_up-22) || 
                        (x==people_left+38 && y==people_up-22) || 
                        (x==people_left+39 && y==people_up-22) || 
                        (x==people_left+40 && y==people_up-22) || 
                        (x==people_left+41 && y==people_up-22) || 
                        (x==people_left+42 && y==people_up-22) || 
                        (x==people_left+43 && y==people_up-22) || 
                        (x==people_left+44 && y==people_up-22) || 
                        (x==people_left+45 && y==people_up-22) || 
                        (x==people_left+46 && y==people_up-22) || 
                        (x==people_left+47 && y==people_up-22) || 
                        (x==people_left+48 && y==people_up-22) || 
                        (x==people_left+49 && y==people_up-22) || 
                        (x==people_left+50 && y==people_up-22) || 
                        (x==people_left+51 && y==people_up-22) || 
                        (x==people_left+52 && y==people_up-22) || 
                        (x==people_left+53 && y==people_up-22) || 
                        (x==people_left+54 && y==people_up-22) || 
                        (x==people_left+55 && y==people_up-22) || 
                        (x==people_left+56 && y==people_up-22) || 
                        (x==people_left+57 && y==people_up-22) || 
                        (x==people_left+58 && y==people_up-22) || 
                        (x==people_left+59 && y==people_up-22) || 
                        (x==people_left+60 && y==people_up-22) || 
                        (x==people_left+61 && y==people_up-22) || 
                        (x==people_left+62 && y==people_up-22) || 
                        (x==people_left-25 && y==people_up-21) || 
                        (x==people_left-24 && y==people_up-21) || 
                        (x==people_left-23 && y==people_up-21) || 
                        (x==people_left-22 && y==people_up-21) || 
                        (x==people_left-21 && y==people_up-21) || 
                        (x==people_left-20 && y==people_up-21) || 
                        (x==people_left-19 && y==people_up-21) || 
                        (x==people_left-18 && y==people_up-21) || 
                        (x==people_left-17 && y==people_up-21) || 
                        (x==people_left-16 && y==people_up-21) || 
                        (x==people_left-15 && y==people_up-21) || 
                        (x==people_left-14 && y==people_up-21) || 
                        (x==people_left-13 && y==people_up-21) || 
                        (x==people_left-12 && y==people_up-21) || 
                        (x==people_left-11 && y==people_up-21) || 
                        (x==people_left-10 && y==people_up-21) || 
                        (x==people_left-9 && y==people_up-21) || 
                        (x==people_left-8 && y==people_up-21) || 
                        (x==people_left-7 && y==people_up-21) || 
                        (x==people_left-6 && y==people_up-21) || 
                        (x==people_left-5 && y==people_up-21) || 
                        (x==people_left-4 && y==people_up-21) || 
                        (x==people_left-3 && y==people_up-21) || 
                        (x==people_left-2 && y==people_up-21) || 
                        (x==people_left-1 && y==people_up-21) || 
                        (x==people_left+0 && y==people_up-21) || 
                        (x==people_left+1 && y==people_up-21) || 
                        (x==people_left+2 && y==people_up-21) || 
                        (x==people_left+3 && y==people_up-21) || 
                        (x==people_left+4 && y==people_up-21) || 
                        (x==people_left+5 && y==people_up-21) || 
                        (x==people_left+6 && y==people_up-21) || 
                        (x==people_left+7 && y==people_up-21) || 
                        (x==people_left+8 && y==people_up-21) || 
                        (x==people_left+9 && y==people_up-21) || 
                        (x==people_left+10 && y==people_up-21) || 
                        (x==people_left+11 && y==people_up-21) || 
                        (x==people_left+12 && y==people_up-21) || 
                        (x==people_left+13 && y==people_up-21) || 
                        (x==people_left+14 && y==people_up-21) || 
                        (x==people_left+15 && y==people_up-21) || 
                        (x==people_left+16 && y==people_up-21) || 
                        (x==people_left+17 && y==people_up-21) || 
                        (x==people_left+18 && y==people_up-21) || 
                        (x==people_left+19 && y==people_up-21) || 
                        (x==people_left+20 && y==people_up-21) || 
                        (x==people_left+21 && y==people_up-21) || 
                        (x==people_left+22 && y==people_up-21) || 
                        (x==people_left+23 && y==people_up-21) || 
                        (x==people_left+24 && y==people_up-21) || 
                        (x==people_left+25 && y==people_up-21) || 
                        (x==people_left+26 && y==people_up-21) || 
                        (x==people_left+27 && y==people_up-21) || 
                        (x==people_left+28 && y==people_up-21) || 
                        (x==people_left+29 && y==people_up-21) || 
                        (x==people_left+30 && y==people_up-21) || 
                        (x==people_left+31 && y==people_up-21) || 
                        (x==people_left+32 && y==people_up-21) || 
                        (x==people_left+33 && y==people_up-21) || 
                        (x==people_left+34 && y==people_up-21) || 
                        (x==people_left+35 && y==people_up-21) || 
                        (x==people_left+36 && y==people_up-21) || 
                        (x==people_left+37 && y==people_up-21) || 
                        (x==people_left+38 && y==people_up-21) || 
                        (x==people_left+39 && y==people_up-21) || 
                        (x==people_left+40 && y==people_up-21) || 
                        (x==people_left+41 && y==people_up-21) || 
                        (x==people_left+42 && y==people_up-21) || 
                        (x==people_left+43 && y==people_up-21) || 
                        (x==people_left+44 && y==people_up-21) || 
                        (x==people_left+45 && y==people_up-21) || 
                        (x==people_left+46 && y==people_up-21) || 
                        (x==people_left+47 && y==people_up-21) || 
                        (x==people_left+48 && y==people_up-21) || 
                        (x==people_left+49 && y==people_up-21) || 
                        (x==people_left+50 && y==people_up-21) || 
                        (x==people_left+51 && y==people_up-21) || 
                        (x==people_left+52 && y==people_up-21) || 
                        (x==people_left+53 && y==people_up-21) || 
                        (x==people_left+54 && y==people_up-21) || 
                        (x==people_left+55 && y==people_up-21) || 
                        (x==people_left+56 && y==people_up-21) || 
                        (x==people_left+57 && y==people_up-21) || 
                        (x==people_left+58 && y==people_up-21) || 
                        (x==people_left+59 && y==people_up-21) || 
                        (x==people_left+60 && y==people_up-21) || 
                        (x==people_left+61 && y==people_up-21) || 
                        (x==people_left+62 && y==people_up-21) || 
                        (x==people_left+63 && y==people_up-21) || 
                        (x==people_left-26 && y==people_up-20) || 
                        (x==people_left-25 && y==people_up-20) || 
                        (x==people_left-24 && y==people_up-20) || 
                        (x==people_left-23 && y==people_up-20) || 
                        (x==people_left-22 && y==people_up-20) || 
                        (x==people_left-21 && y==people_up-20) || 
                        (x==people_left-20 && y==people_up-20) || 
                        (x==people_left-19 && y==people_up-20) || 
                        (x==people_left-18 && y==people_up-20) || 
                        (x==people_left-17 && y==people_up-20) || 
                        (x==people_left-16 && y==people_up-20) || 
                        (x==people_left-15 && y==people_up-20) || 
                        (x==people_left-14 && y==people_up-20) || 
                        (x==people_left-13 && y==people_up-20) || 
                        (x==people_left-12 && y==people_up-20) || 
                        (x==people_left-11 && y==people_up-20) || 
                        (x==people_left-10 && y==people_up-20) || 
                        (x==people_left-9 && y==people_up-20) || 
                        (x==people_left-8 && y==people_up-20) || 
                        (x==people_left-7 && y==people_up-20) || 
                        (x==people_left-6 && y==people_up-20) || 
                        (x==people_left-5 && y==people_up-20) || 
                        (x==people_left-4 && y==people_up-20) || 
                        (x==people_left-3 && y==people_up-20) || 
                        (x==people_left-2 && y==people_up-20) || 
                        (x==people_left-1 && y==people_up-20) || 
                        (x==people_left+0 && y==people_up-20) || 
                        (x==people_left+1 && y==people_up-20) || 
                        (x==people_left+2 && y==people_up-20) || 
                        (x==people_left+3 && y==people_up-20) || 
                        (x==people_left+4 && y==people_up-20) || 
                        (x==people_left+5 && y==people_up-20) || 
                        (x==people_left+6 && y==people_up-20) || 
                        (x==people_left+7 && y==people_up-20) || 
                        (x==people_left+8 && y==people_up-20) || 
                        (x==people_left+9 && y==people_up-20) || 
                        (x==people_left+10 && y==people_up-20) || 
                        (x==people_left+11 && y==people_up-20) || 
                        (x==people_left+12 && y==people_up-20) || 
                        (x==people_left+13 && y==people_up-20) || 
                        (x==people_left+14 && y==people_up-20) || 
                        (x==people_left+15 && y==people_up-20) || 
                        (x==people_left+16 && y==people_up-20) || 
                        (x==people_left+17 && y==people_up-20) || 
                        (x==people_left+18 && y==people_up-20) || 
                        (x==people_left+19 && y==people_up-20) || 
                        (x==people_left+20 && y==people_up-20) || 
                        (x==people_left+21 && y==people_up-20) || 
                        (x==people_left+22 && y==people_up-20) || 
                        (x==people_left+23 && y==people_up-20) || 
                        (x==people_left+24 && y==people_up-20) || 
                        (x==people_left+25 && y==people_up-20) || 
                        (x==people_left+26 && y==people_up-20) || 
                        (x==people_left+27 && y==people_up-20) || 
                        (x==people_left+28 && y==people_up-20) || 
                        (x==people_left+29 && y==people_up-20) || 
                        (x==people_left+30 && y==people_up-20) || 
                        (x==people_left+31 && y==people_up-20) || 
                        (x==people_left+32 && y==people_up-20) || 
                        (x==people_left+33 && y==people_up-20) || 
                        (x==people_left+34 && y==people_up-20) || 
                        (x==people_left+35 && y==people_up-20) || 
                        (x==people_left+36 && y==people_up-20) || 
                        (x==people_left+37 && y==people_up-20) || 
                        (x==people_left+38 && y==people_up-20) || 
                        (x==people_left+39 && y==people_up-20) || 
                        (x==people_left+40 && y==people_up-20) || 
                        (x==people_left+41 && y==people_up-20) || 
                        (x==people_left+42 && y==people_up-20) || 
                        (x==people_left+43 && y==people_up-20) || 
                        (x==people_left+44 && y==people_up-20) || 
                        (x==people_left+45 && y==people_up-20) || 
                        (x==people_left+46 && y==people_up-20) || 
                        (x==people_left+47 && y==people_up-20) || 
                        (x==people_left+48 && y==people_up-20) || 
                        (x==people_left+49 && y==people_up-20) || 
                        (x==people_left+50 && y==people_up-20) || 
                        (x==people_left+51 && y==people_up-20) || 
                        (x==people_left+52 && y==people_up-20) || 
                        (x==people_left+53 && y==people_up-20) || 
                        (x==people_left+54 && y==people_up-20) || 
                        (x==people_left+55 && y==people_up-20) || 
                        (x==people_left+56 && y==people_up-20) || 
                        (x==people_left+57 && y==people_up-20) || 
                        (x==people_left+58 && y==people_up-20) || 
                        (x==people_left+59 && y==people_up-20) || 
                        (x==people_left+60 && y==people_up-20) || 
                        (x==people_left+61 && y==people_up-20) || 
                        (x==people_left+62 && y==people_up-20) || 
                        (x==people_left+63 && y==people_up-20) || 
                        (x==people_left+64 && y==people_up-20) || 
                        (x==people_left-27 && y==people_up-19) || 
                        (x==people_left-26 && y==people_up-19) || 
                        (x==people_left-25 && y==people_up-19) || 
                        (x==people_left-24 && y==people_up-19) || 
                        (x==people_left-23 && y==people_up-19) || 
                        (x==people_left-22 && y==people_up-19) || 
                        (x==people_left-21 && y==people_up-19) || 
                        (x==people_left-20 && y==people_up-19) || 
                        (x==people_left-19 && y==people_up-19) || 
                        (x==people_left-18 && y==people_up-19) || 
                        (x==people_left-17 && y==people_up-19) || 
                        (x==people_left-16 && y==people_up-19) || 
                        (x==people_left-15 && y==people_up-19) || 
                        (x==people_left-14 && y==people_up-19) || 
                        (x==people_left-13 && y==people_up-19) || 
                        (x==people_left-12 && y==people_up-19) || 
                        (x==people_left-11 && y==people_up-19) || 
                        (x==people_left-10 && y==people_up-19) || 
                        (x==people_left-9 && y==people_up-19) || 
                        (x==people_left-8 && y==people_up-19) || 
                        (x==people_left-7 && y==people_up-19) || 
                        (x==people_left-6 && y==people_up-19) || 
                        (x==people_left-5 && y==people_up-19) || 
                        (x==people_left-4 && y==people_up-19) || 
                        (x==people_left-3 && y==people_up-19) || 
                        (x==people_left-2 && y==people_up-19) || 
                        (x==people_left-1 && y==people_up-19) || 
                        (x==people_left+0 && y==people_up-19) || 
                        (x==people_left+1 && y==people_up-19) || 
                        (x==people_left+2 && y==people_up-19) || 
                        (x==people_left+3 && y==people_up-19) || 
                        (x==people_left+4 && y==people_up-19) || 
                        (x==people_left+5 && y==people_up-19) || 
                        (x==people_left+6 && y==people_up-19) || 
                        (x==people_left+7 && y==people_up-19) || 
                        (x==people_left+8 && y==people_up-19) || 
                        (x==people_left+9 && y==people_up-19) || 
                        (x==people_left+10 && y==people_up-19) || 
                        (x==people_left+11 && y==people_up-19) || 
                        (x==people_left+12 && y==people_up-19) || 
                        (x==people_left+13 && y==people_up-19) || 
                        (x==people_left+14 && y==people_up-19) || 
                        (x==people_left+15 && y==people_up-19) || 
                        (x==people_left+16 && y==people_up-19) || 
                        (x==people_left+17 && y==people_up-19) || 
                        (x==people_left+18 && y==people_up-19) || 
                        (x==people_left+19 && y==people_up-19) || 
                        (x==people_left+20 && y==people_up-19) || 
                        (x==people_left+21 && y==people_up-19) || 
                        (x==people_left+22 && y==people_up-19) || 
                        (x==people_left+23 && y==people_up-19) || 
                        (x==people_left+24 && y==people_up-19) || 
                        (x==people_left+25 && y==people_up-19) || 
                        (x==people_left+26 && y==people_up-19) || 
                        (x==people_left+27 && y==people_up-19) || 
                        (x==people_left+28 && y==people_up-19) || 
                        (x==people_left+29 && y==people_up-19) || 
                        (x==people_left+30 && y==people_up-19) || 
                        (x==people_left+31 && y==people_up-19) || 
                        (x==people_left+32 && y==people_up-19) || 
                        (x==people_left+33 && y==people_up-19) || 
                        (x==people_left+34 && y==people_up-19) || 
                        (x==people_left+35 && y==people_up-19) || 
                        (x==people_left+36 && y==people_up-19) || 
                        (x==people_left+37 && y==people_up-19) || 
                        (x==people_left+38 && y==people_up-19) || 
                        (x==people_left+39 && y==people_up-19) || 
                        (x==people_left+40 && y==people_up-19) || 
                        (x==people_left+41 && y==people_up-19) || 
                        (x==people_left+42 && y==people_up-19) || 
                        (x==people_left+43 && y==people_up-19) || 
                        (x==people_left+44 && y==people_up-19) || 
                        (x==people_left+45 && y==people_up-19) || 
                        (x==people_left+46 && y==people_up-19) || 
                        (x==people_left+47 && y==people_up-19) || 
                        (x==people_left+48 && y==people_up-19) || 
                        (x==people_left+49 && y==people_up-19) || 
                        (x==people_left+50 && y==people_up-19) || 
                        (x==people_left+51 && y==people_up-19) || 
                        (x==people_left+52 && y==people_up-19) || 
                        (x==people_left+53 && y==people_up-19) || 
                        (x==people_left+54 && y==people_up-19) || 
                        (x==people_left+55 && y==people_up-19) || 
                        (x==people_left+56 && y==people_up-19) || 
                        (x==people_left+57 && y==people_up-19) || 
                        (x==people_left+58 && y==people_up-19) || 
                        (x==people_left+59 && y==people_up-19) || 
                        (x==people_left+60 && y==people_up-19) || 
                        (x==people_left+61 && y==people_up-19) || 
                        (x==people_left+62 && y==people_up-19) || 
                        (x==people_left+63 && y==people_up-19) || 
                        (x==people_left+64 && y==people_up-19) || 
                        (x==people_left+65 && y==people_up-19) || 
                        (x==people_left-27 && y==people_up-18) || 
                        (x==people_left-26 && y==people_up-18) || 
                        (x==people_left-25 && y==people_up-18) || 
                        (x==people_left-24 && y==people_up-18) || 
                        (x==people_left-23 && y==people_up-18) || 
                        (x==people_left-22 && y==people_up-18) || 
                        (x==people_left-21 && y==people_up-18) || 
                        (x==people_left-20 && y==people_up-18) || 
                        (x==people_left-19 && y==people_up-18) || 
                        (x==people_left-18 && y==people_up-18) || 
                        (x==people_left-17 && y==people_up-18) || 
                        (x==people_left-16 && y==people_up-18) || 
                        (x==people_left-15 && y==people_up-18) || 
                        (x==people_left-14 && y==people_up-18) || 
                        (x==people_left-13 && y==people_up-18) || 
                        (x==people_left-12 && y==people_up-18) || 
                        (x==people_left-11 && y==people_up-18) || 
                        (x==people_left-10 && y==people_up-18) || 
                        (x==people_left-9 && y==people_up-18) || 
                        (x==people_left-8 && y==people_up-18) || 
                        (x==people_left-7 && y==people_up-18) || 
                        (x==people_left-6 && y==people_up-18) || 
                        (x==people_left-5 && y==people_up-18) || 
                        (x==people_left-4 && y==people_up-18) || 
                        (x==people_left-3 && y==people_up-18) || 
                        (x==people_left-2 && y==people_up-18) || 
                        (x==people_left-1 && y==people_up-18) || 
                        (x==people_left+0 && y==people_up-18) || 
                        (x==people_left+1 && y==people_up-18) || 
                        (x==people_left+2 && y==people_up-18) || 
                        (x==people_left+3 && y==people_up-18) || 
                        (x==people_left+4 && y==people_up-18) || 
                        (x==people_left+5 && y==people_up-18) || 
                        (x==people_left+6 && y==people_up-18) || 
                        (x==people_left+7 && y==people_up-18) || 
                        (x==people_left+8 && y==people_up-18) || 
                        (x==people_left+9 && y==people_up-18) || 
                        (x==people_left+10 && y==people_up-18) || 
                        (x==people_left+11 && y==people_up-18) || 
                        (x==people_left+12 && y==people_up-18) || 
                        (x==people_left+13 && y==people_up-18) || 
                        (x==people_left+14 && y==people_up-18) || 
                        (x==people_left+15 && y==people_up-18) || 
                        (x==people_left+16 && y==people_up-18) || 
                        (x==people_left+17 && y==people_up-18) || 
                        (x==people_left+18 && y==people_up-18) || 
                        (x==people_left+19 && y==people_up-18) || 
                        (x==people_left+20 && y==people_up-18) || 
                        (x==people_left+21 && y==people_up-18) || 
                        (x==people_left+22 && y==people_up-18) || 
                        (x==people_left+23 && y==people_up-18) || 
                        (x==people_left+24 && y==people_up-18) || 
                        (x==people_left+25 && y==people_up-18) || 
                        (x==people_left+26 && y==people_up-18) || 
                        (x==people_left+27 && y==people_up-18) || 
                        (x==people_left+28 && y==people_up-18) || 
                        (x==people_left+29 && y==people_up-18) || 
                        (x==people_left+30 && y==people_up-18) || 
                        (x==people_left+31 && y==people_up-18) || 
                        (x==people_left+32 && y==people_up-18) || 
                        (x==people_left+33 && y==people_up-18) || 
                        (x==people_left+34 && y==people_up-18) || 
                        (x==people_left+35 && y==people_up-18) || 
                        (x==people_left+36 && y==people_up-18) || 
                        (x==people_left+37 && y==people_up-18) || 
                        (x==people_left+38 && y==people_up-18) || 
                        (x==people_left+39 && y==people_up-18) || 
                        (x==people_left+40 && y==people_up-18) || 
                        (x==people_left+41 && y==people_up-18) || 
                        (x==people_left+42 && y==people_up-18) || 
                        (x==people_left+43 && y==people_up-18) || 
                        (x==people_left+44 && y==people_up-18) || 
                        (x==people_left+45 && y==people_up-18) || 
                        (x==people_left+46 && y==people_up-18) || 
                        (x==people_left+47 && y==people_up-18) || 
                        (x==people_left+48 && y==people_up-18) || 
                        (x==people_left+49 && y==people_up-18) || 
                        (x==people_left+50 && y==people_up-18) || 
                        (x==people_left+51 && y==people_up-18) || 
                        (x==people_left+52 && y==people_up-18) || 
                        (x==people_left+53 && y==people_up-18) || 
                        (x==people_left+54 && y==people_up-18) || 
                        (x==people_left+55 && y==people_up-18) || 
                        (x==people_left+56 && y==people_up-18) || 
                        (x==people_left+57 && y==people_up-18) || 
                        (x==people_left+58 && y==people_up-18) || 
                        (x==people_left+59 && y==people_up-18) || 
                        (x==people_left+60 && y==people_up-18) || 
                        (x==people_left+61 && y==people_up-18) || 
                        (x==people_left+62 && y==people_up-18) || 
                        (x==people_left+63 && y==people_up-18) || 
                        (x==people_left+64 && y==people_up-18) || 
                        (x==people_left+65 && y==people_up-18) || 
                        (x==people_left-28 && y==people_up-17) || 
                        (x==people_left-27 && y==people_up-17) || 
                        (x==people_left-26 && y==people_up-17) || 
                        (x==people_left-25 && y==people_up-17) || 
                        (x==people_left-24 && y==people_up-17) || 
                        (x==people_left-23 && y==people_up-17) || 
                        (x==people_left-22 && y==people_up-17) || 
                        (x==people_left-21 && y==people_up-17) || 
                        (x==people_left-20 && y==people_up-17) || 
                        (x==people_left-19 && y==people_up-17) || 
                        (x==people_left-18 && y==people_up-17) || 
                        (x==people_left-17 && y==people_up-17) || 
                        (x==people_left-16 && y==people_up-17) || 
                        (x==people_left-15 && y==people_up-17) || 
                        (x==people_left-14 && y==people_up-17) || 
                        (x==people_left-13 && y==people_up-17) || 
                        (x==people_left-12 && y==people_up-17) || 
                        (x==people_left-11 && y==people_up-17) || 
                        (x==people_left-10 && y==people_up-17) || 
                        (x==people_left-9 && y==people_up-17) || 
                        (x==people_left-8 && y==people_up-17) || 
                        (x==people_left-7 && y==people_up-17) || 
                        (x==people_left-6 && y==people_up-17) || 
                        (x==people_left-5 && y==people_up-17) || 
                        (x==people_left-4 && y==people_up-17) || 
                        (x==people_left-3 && y==people_up-17) || 
                        (x==people_left-2 && y==people_up-17) || 
                        (x==people_left-1 && y==people_up-17) || 
                        (x==people_left+0 && y==people_up-17) || 
                        (x==people_left+1 && y==people_up-17) || 
                        (x==people_left+2 && y==people_up-17) || 
                        (x==people_left+3 && y==people_up-17) || 
                        (x==people_left+4 && y==people_up-17) || 
                        (x==people_left+5 && y==people_up-17) || 
                        (x==people_left+6 && y==people_up-17) || 
                        (x==people_left+7 && y==people_up-17) || 
                        (x==people_left+8 && y==people_up-17) || 
                        (x==people_left+9 && y==people_up-17) || 
                        (x==people_left+10 && y==people_up-17) || 
                        (x==people_left+11 && y==people_up-17) || 
                        (x==people_left+12 && y==people_up-17) || 
                        (x==people_left+13 && y==people_up-17) || 
                        (x==people_left+14 && y==people_up-17) || 
                        (x==people_left+15 && y==people_up-17) || 
                        (x==people_left+16 && y==people_up-17) || 
                        (x==people_left+17 && y==people_up-17) || 
                        (x==people_left+18 && y==people_up-17) || 
                        (x==people_left+19 && y==people_up-17) || 
                        (x==people_left+20 && y==people_up-17) || 
                        (x==people_left+21 && y==people_up-17) || 
                        (x==people_left+22 && y==people_up-17) || 
                        (x==people_left+23 && y==people_up-17) || 
                        (x==people_left+24 && y==people_up-17) || 
                        (x==people_left+25 && y==people_up-17) || 
                        (x==people_left+26 && y==people_up-17) || 
                        (x==people_left+27 && y==people_up-17) || 
                        (x==people_left+28 && y==people_up-17) || 
                        (x==people_left+29 && y==people_up-17) || 
                        (x==people_left+30 && y==people_up-17) || 
                        (x==people_left+31 && y==people_up-17) || 
                        (x==people_left+32 && y==people_up-17) || 
                        (x==people_left+33 && y==people_up-17) || 
                        (x==people_left+34 && y==people_up-17) || 
                        (x==people_left+35 && y==people_up-17) || 
                        (x==people_left+36 && y==people_up-17) || 
                        (x==people_left+37 && y==people_up-17) || 
                        (x==people_left+38 && y==people_up-17) || 
                        (x==people_left+39 && y==people_up-17) || 
                        (x==people_left+40 && y==people_up-17) || 
                        (x==people_left+41 && y==people_up-17) || 
                        (x==people_left+42 && y==people_up-17) || 
                        (x==people_left+43 && y==people_up-17) || 
                        (x==people_left+44 && y==people_up-17) || 
                        (x==people_left+45 && y==people_up-17) || 
                        (x==people_left+46 && y==people_up-17) || 
                        (x==people_left+47 && y==people_up-17) || 
                        (x==people_left+48 && y==people_up-17) || 
                        (x==people_left+49 && y==people_up-17) || 
                        (x==people_left+50 && y==people_up-17) || 
                        (x==people_left+51 && y==people_up-17) || 
                        (x==people_left+52 && y==people_up-17) || 
                        (x==people_left+53 && y==people_up-17) || 
                        (x==people_left+54 && y==people_up-17) || 
                        (x==people_left+55 && y==people_up-17) || 
                        (x==people_left+56 && y==people_up-17) || 
                        (x==people_left+57 && y==people_up-17) || 
                        (x==people_left+58 && y==people_up-17) || 
                        (x==people_left+59 && y==people_up-17) || 
                        (x==people_left+60 && y==people_up-17) || 
                        (x==people_left+61 && y==people_up-17) || 
                        (x==people_left+62 && y==people_up-17) || 
                        (x==people_left+63 && y==people_up-17) || 
                        (x==people_left+64 && y==people_up-17) || 
                        (x==people_left+65 && y==people_up-17) || 
                        (x==people_left+66 && y==people_up-17) || 
                        (x==people_left-29 && y==people_up-16) || 
                        (x==people_left-28 && y==people_up-16) || 
                        (x==people_left-27 && y==people_up-16) || 
                        (x==people_left-26 && y==people_up-16) || 
                        (x==people_left-25 && y==people_up-16) || 
                        (x==people_left-24 && y==people_up-16) || 
                        (x==people_left-23 && y==people_up-16) || 
                        (x==people_left-22 && y==people_up-16) || 
                        (x==people_left-21 && y==people_up-16) || 
                        (x==people_left-20 && y==people_up-16) || 
                        (x==people_left-19 && y==people_up-16) || 
                        (x==people_left-18 && y==people_up-16) || 
                        (x==people_left-17 && y==people_up-16) || 
                        (x==people_left-16 && y==people_up-16) || 
                        (x==people_left-15 && y==people_up-16) || 
                        (x==people_left-14 && y==people_up-16) || 
                        (x==people_left-13 && y==people_up-16) || 
                        (x==people_left-12 && y==people_up-16) || 
                        (x==people_left-11 && y==people_up-16) || 
                        (x==people_left-10 && y==people_up-16) || 
                        (x==people_left-9 && y==people_up-16) || 
                        (x==people_left-8 && y==people_up-16) || 
                        (x==people_left-7 && y==people_up-16) || 
                        (x==people_left-6 && y==people_up-16) || 
                        (x==people_left-5 && y==people_up-16) || 
                        (x==people_left-4 && y==people_up-16) || 
                        (x==people_left-3 && y==people_up-16) || 
                        (x==people_left-2 && y==people_up-16) || 
                        (x==people_left-1 && y==people_up-16) || 
                        (x==people_left+0 && y==people_up-16) || 
                        (x==people_left+1 && y==people_up-16) || 
                        (x==people_left+2 && y==people_up-16) || 
                        (x==people_left+3 && y==people_up-16) || 
                        (x==people_left+4 && y==people_up-16) || 
                        (x==people_left+5 && y==people_up-16) || 
                        (x==people_left+6 && y==people_up-16) || 
                        (x==people_left+7 && y==people_up-16) || 
                        (x==people_left+8 && y==people_up-16) || 
                        (x==people_left+9 && y==people_up-16) || 
                        (x==people_left+10 && y==people_up-16) || 
                        (x==people_left+11 && y==people_up-16) || 
                        (x==people_left+12 && y==people_up-16) || 
                        (x==people_left+13 && y==people_up-16) || 
                        (x==people_left+14 && y==people_up-16) || 
                        (x==people_left+15 && y==people_up-16) || 
                        (x==people_left+16 && y==people_up-16) || 
                        (x==people_left+17 && y==people_up-16) || 
                        (x==people_left+18 && y==people_up-16) || 
                        (x==people_left+19 && y==people_up-16) || 
                        (x==people_left+20 && y==people_up-16) || 
                        (x==people_left+21 && y==people_up-16) || 
                        (x==people_left+22 && y==people_up-16) || 
                        (x==people_left+23 && y==people_up-16) || 
                        (x==people_left+24 && y==people_up-16) || 
                        (x==people_left+25 && y==people_up-16) || 
                        (x==people_left+26 && y==people_up-16) || 
                        (x==people_left+27 && y==people_up-16) || 
                        (x==people_left+28 && y==people_up-16) || 
                        (x==people_left+29 && y==people_up-16) || 
                        (x==people_left+30 && y==people_up-16) || 
                        (x==people_left+31 && y==people_up-16) || 
                        (x==people_left+32 && y==people_up-16) || 
                        (x==people_left+33 && y==people_up-16) || 
                        (x==people_left+34 && y==people_up-16) || 
                        (x==people_left+35 && y==people_up-16) || 
                        (x==people_left+36 && y==people_up-16) || 
                        (x==people_left+37 && y==people_up-16) || 
                        (x==people_left+38 && y==people_up-16) || 
                        (x==people_left+39 && y==people_up-16) || 
                        (x==people_left+40 && y==people_up-16) || 
                        (x==people_left+41 && y==people_up-16) || 
                        (x==people_left+42 && y==people_up-16) || 
                        (x==people_left+43 && y==people_up-16) || 
                        (x==people_left+44 && y==people_up-16) || 
                        (x==people_left+45 && y==people_up-16) || 
                        (x==people_left+46 && y==people_up-16) || 
                        (x==people_left+47 && y==people_up-16) || 
                        (x==people_left+48 && y==people_up-16) || 
                        (x==people_left+49 && y==people_up-16) || 
                        (x==people_left+50 && y==people_up-16) || 
                        (x==people_left+51 && y==people_up-16) || 
                        (x==people_left+52 && y==people_up-16) || 
                        (x==people_left+53 && y==people_up-16) || 
                        (x==people_left+54 && y==people_up-16) || 
                        (x==people_left+55 && y==people_up-16) || 
                        (x==people_left+56 && y==people_up-16) || 
                        (x==people_left+57 && y==people_up-16) || 
                        (x==people_left+58 && y==people_up-16) || 
                        (x==people_left+59 && y==people_up-16) || 
                        (x==people_left+60 && y==people_up-16) || 
                        (x==people_left+61 && y==people_up-16) || 
                        (x==people_left+62 && y==people_up-16) || 
                        (x==people_left+63 && y==people_up-16) || 
                        (x==people_left+64 && y==people_up-16) || 
                        (x==people_left+65 && y==people_up-16) || 
                        (x==people_left+66 && y==people_up-16) || 
                        (x==people_left+67 && y==people_up-16) || 
                        (x==people_left-30 && y==people_up-15) || 
                        (x==people_left-29 && y==people_up-15) || 
                        (x==people_left-28 && y==people_up-15) || 
                        (x==people_left-27 && y==people_up-15) || 
                        (x==people_left-26 && y==people_up-15) || 
                        (x==people_left-25 && y==people_up-15) || 
                        (x==people_left-24 && y==people_up-15) || 
                        (x==people_left-23 && y==people_up-15) || 
                        (x==people_left-22 && y==people_up-15) || 
                        (x==people_left-21 && y==people_up-15) || 
                        (x==people_left-20 && y==people_up-15) || 
                        (x==people_left-19 && y==people_up-15) || 
                        (x==people_left-18 && y==people_up-15) || 
                        (x==people_left-17 && y==people_up-15) || 
                        (x==people_left-16 && y==people_up-15) || 
                        (x==people_left-15 && y==people_up-15) || 
                        (x==people_left-14 && y==people_up-15) || 
                        (x==people_left-13 && y==people_up-15) || 
                        (x==people_left-12 && y==people_up-15) || 
                        (x==people_left-11 && y==people_up-15) || 
                        (x==people_left-10 && y==people_up-15) || 
                        (x==people_left-9 && y==people_up-15) || 
                        (x==people_left-8 && y==people_up-15) || 
                        (x==people_left-7 && y==people_up-15) || 
                        (x==people_left-6 && y==people_up-15) || 
                        (x==people_left-5 && y==people_up-15) || 
                        (x==people_left-4 && y==people_up-15) || 
                        (x==people_left-3 && y==people_up-15) || 
                        (x==people_left-2 && y==people_up-15) || 
                        (x==people_left-1 && y==people_up-15) || 
                        (x==people_left+0 && y==people_up-15) || 
                        (x==people_left+1 && y==people_up-15) || 
                        (x==people_left+2 && y==people_up-15) || 
                        (x==people_left+3 && y==people_up-15) || 
                        (x==people_left+4 && y==people_up-15) || 
                        (x==people_left+5 && y==people_up-15) || 
                        (x==people_left+6 && y==people_up-15) || 
                        (x==people_left+7 && y==people_up-15) || 
                        (x==people_left+8 && y==people_up-15) || 
                        (x==people_left+9 && y==people_up-15) || 
                        (x==people_left+10 && y==people_up-15) || 
                        (x==people_left+11 && y==people_up-15) || 
                        (x==people_left+12 && y==people_up-15) || 
                        (x==people_left+13 && y==people_up-15) || 
                        (x==people_left+14 && y==people_up-15) || 
                        (x==people_left+15 && y==people_up-15) || 
                        (x==people_left+16 && y==people_up-15) || 
                        (x==people_left+17 && y==people_up-15) || 
                        (x==people_left+18 && y==people_up-15) || 
                        (x==people_left+19 && y==people_up-15) || 
                        (x==people_left+20 && y==people_up-15) || 
                        (x==people_left+21 && y==people_up-15) || 
                        (x==people_left+22 && y==people_up-15) || 
                        (x==people_left+23 && y==people_up-15) || 
                        (x==people_left+24 && y==people_up-15) || 
                        (x==people_left+25 && y==people_up-15) || 
                        (x==people_left+26 && y==people_up-15) || 
                        (x==people_left+27 && y==people_up-15) || 
                        (x==people_left+28 && y==people_up-15) || 
                        (x==people_left+29 && y==people_up-15) || 
                        (x==people_left+30 && y==people_up-15) || 
                        (x==people_left+31 && y==people_up-15) || 
                        (x==people_left+32 && y==people_up-15) || 
                        (x==people_left+33 && y==people_up-15) || 
                        (x==people_left+34 && y==people_up-15) || 
                        (x==people_left+35 && y==people_up-15) || 
                        (x==people_left+36 && y==people_up-15) || 
                        (x==people_left+37 && y==people_up-15) || 
                        (x==people_left+38 && y==people_up-15) || 
                        (x==people_left+39 && y==people_up-15) || 
                        (x==people_left+40 && y==people_up-15) || 
                        (x==people_left+41 && y==people_up-15) || 
                        (x==people_left+42 && y==people_up-15) || 
                        (x==people_left+43 && y==people_up-15) || 
                        (x==people_left+44 && y==people_up-15) || 
                        (x==people_left+45 && y==people_up-15) || 
                        (x==people_left+46 && y==people_up-15) || 
                        (x==people_left+47 && y==people_up-15) || 
                        (x==people_left+48 && y==people_up-15) || 
                        (x==people_left+49 && y==people_up-15) || 
                        (x==people_left+50 && y==people_up-15) || 
                        (x==people_left+51 && y==people_up-15) || 
                        (x==people_left+52 && y==people_up-15) || 
                        (x==people_left+53 && y==people_up-15) || 
                        (x==people_left+54 && y==people_up-15) || 
                        (x==people_left+55 && y==people_up-15) || 
                        (x==people_left+56 && y==people_up-15) || 
                        (x==people_left+57 && y==people_up-15) || 
                        (x==people_left+58 && y==people_up-15) || 
                        (x==people_left+59 && y==people_up-15) || 
                        (x==people_left+60 && y==people_up-15) || 
                        (x==people_left+61 && y==people_up-15) || 
                        (x==people_left+62 && y==people_up-15) || 
                        (x==people_left+63 && y==people_up-15) || 
                        (x==people_left+64 && y==people_up-15) || 
                        (x==people_left+65 && y==people_up-15) || 
                        (x==people_left+66 && y==people_up-15) || 
                        (x==people_left+67 && y==people_up-15) || 
                        (x==people_left+68 && y==people_up-15) || 
                        (x==people_left-30 && y==people_up-14) || 
                        (x==people_left-29 && y==people_up-14) || 
                        (x==people_left-28 && y==people_up-14) || 
                        (x==people_left-27 && y==people_up-14) || 
                        (x==people_left-26 && y==people_up-14) || 
                        (x==people_left-25 && y==people_up-14) || 
                        (x==people_left-24 && y==people_up-14) || 
                        (x==people_left-23 && y==people_up-14) || 
                        (x==people_left-22 && y==people_up-14) || 
                        (x==people_left-21 && y==people_up-14) || 
                        (x==people_left-20 && y==people_up-14) || 
                        (x==people_left-19 && y==people_up-14) || 
                        (x==people_left-18 && y==people_up-14) || 
                        (x==people_left-17 && y==people_up-14) || 
                        (x==people_left-16 && y==people_up-14) || 
                        (x==people_left-15 && y==people_up-14) || 
                        (x==people_left-14 && y==people_up-14) || 
                        (x==people_left-13 && y==people_up-14) || 
                        (x==people_left-12 && y==people_up-14) || 
                        (x==people_left-11 && y==people_up-14) || 
                        (x==people_left-10 && y==people_up-14) || 
                        (x==people_left-9 && y==people_up-14) || 
                        (x==people_left-8 && y==people_up-14) || 
                        (x==people_left-7 && y==people_up-14) || 
                        (x==people_left-6 && y==people_up-14) || 
                        (x==people_left-5 && y==people_up-14) || 
                        (x==people_left-4 && y==people_up-14) || 
                        (x==people_left-3 && y==people_up-14) || 
                        (x==people_left-2 && y==people_up-14) || 
                        (x==people_left-1 && y==people_up-14) || 
                        (x==people_left+0 && y==people_up-14) || 
                        (x==people_left+1 && y==people_up-14) || 
                        (x==people_left+2 && y==people_up-14) || 
                        (x==people_left+3 && y==people_up-14) || 
                        (x==people_left+4 && y==people_up-14) || 
                        (x==people_left+5 && y==people_up-14) || 
                        (x==people_left+6 && y==people_up-14) || 
                        (x==people_left+7 && y==people_up-14) || 
                        (x==people_left+8 && y==people_up-14) || 
                        (x==people_left+9 && y==people_up-14) || 
                        (x==people_left+10 && y==people_up-14) || 
                        (x==people_left+11 && y==people_up-14) || 
                        (x==people_left+12 && y==people_up-14) || 
                        (x==people_left+13 && y==people_up-14) || 
                        (x==people_left+14 && y==people_up-14) || 
                        (x==people_left+15 && y==people_up-14) || 
                        (x==people_left+16 && y==people_up-14) || 
                        (x==people_left+17 && y==people_up-14) || 
                        (x==people_left+18 && y==people_up-14) || 
                        (x==people_left+19 && y==people_up-14) || 
                        (x==people_left+20 && y==people_up-14) || 
                        (x==people_left+21 && y==people_up-14) || 
                        (x==people_left+22 && y==people_up-14) || 
                        (x==people_left+23 && y==people_up-14) || 
                        (x==people_left+24 && y==people_up-14) || 
                        (x==people_left+25 && y==people_up-14) || 
                        (x==people_left+26 && y==people_up-14) || 
                        (x==people_left+27 && y==people_up-14) || 
                        (x==people_left+28 && y==people_up-14) || 
                        (x==people_left+29 && y==people_up-14) || 
                        (x==people_left+30 && y==people_up-14) || 
                        (x==people_left+31 && y==people_up-14) || 
                        (x==people_left+32 && y==people_up-14) || 
                        (x==people_left+33 && y==people_up-14) || 
                        (x==people_left+34 && y==people_up-14) || 
                        (x==people_left+35 && y==people_up-14) || 
                        (x==people_left+36 && y==people_up-14) || 
                        (x==people_left+37 && y==people_up-14) || 
                        (x==people_left+38 && y==people_up-14) || 
                        (x==people_left+39 && y==people_up-14) || 
                        (x==people_left+40 && y==people_up-14) || 
                        (x==people_left+41 && y==people_up-14) || 
                        (x==people_left+42 && y==people_up-14) || 
                        (x==people_left+43 && y==people_up-14) || 
                        (x==people_left+44 && y==people_up-14) || 
                        (x==people_left+45 && y==people_up-14) || 
                        (x==people_left+46 && y==people_up-14) || 
                        (x==people_left+47 && y==people_up-14) || 
                        (x==people_left+48 && y==people_up-14) || 
                        (x==people_left+49 && y==people_up-14) || 
                        (x==people_left+50 && y==people_up-14) || 
                        (x==people_left+51 && y==people_up-14) || 
                        (x==people_left+52 && y==people_up-14) || 
                        (x==people_left+53 && y==people_up-14) || 
                        (x==people_left+54 && y==people_up-14) || 
                        (x==people_left+55 && y==people_up-14) || 
                        (x==people_left+56 && y==people_up-14) || 
                        (x==people_left+57 && y==people_up-14) || 
                        (x==people_left+58 && y==people_up-14) || 
                        (x==people_left+59 && y==people_up-14) || 
                        (x==people_left+60 && y==people_up-14) || 
                        (x==people_left+61 && y==people_up-14) || 
                        (x==people_left+62 && y==people_up-14) || 
                        (x==people_left+63 && y==people_up-14) || 
                        (x==people_left+64 && y==people_up-14) || 
                        (x==people_left+65 && y==people_up-14) || 
                        (x==people_left+66 && y==people_up-14) || 
                        (x==people_left+67 && y==people_up-14) || 
                        (x==people_left+68 && y==people_up-14) || 
                        (x==people_left-31 && y==people_up-13) || 
                        (x==people_left-30 && y==people_up-13) || 
                        (x==people_left-29 && y==people_up-13) || 
                        (x==people_left-28 && y==people_up-13) || 
                        (x==people_left-27 && y==people_up-13) || 
                        (x==people_left-26 && y==people_up-13) || 
                        (x==people_left-25 && y==people_up-13) || 
                        (x==people_left-24 && y==people_up-13) || 
                        (x==people_left-23 && y==people_up-13) || 
                        (x==people_left-22 && y==people_up-13) || 
                        (x==people_left-21 && y==people_up-13) || 
                        (x==people_left-20 && y==people_up-13) || 
                        (x==people_left-19 && y==people_up-13) || 
                        (x==people_left-18 && y==people_up-13) || 
                        (x==people_left-17 && y==people_up-13) || 
                        (x==people_left-16 && y==people_up-13) || 
                        (x==people_left-15 && y==people_up-13) || 
                        (x==people_left-14 && y==people_up-13) || 
                        (x==people_left-13 && y==people_up-13) || 
                        (x==people_left-12 && y==people_up-13) || 
                        (x==people_left-11 && y==people_up-13) || 
                        (x==people_left-10 && y==people_up-13) || 
                        (x==people_left-9 && y==people_up-13) || 
                        (x==people_left-8 && y==people_up-13) || 
                        (x==people_left-7 && y==people_up-13) || 
                        (x==people_left-6 && y==people_up-13) || 
                        (x==people_left-5 && y==people_up-13) || 
                        (x==people_left-4 && y==people_up-13) || 
                        (x==people_left-3 && y==people_up-13) || 
                        (x==people_left-2 && y==people_up-13) || 
                        (x==people_left-1 && y==people_up-13) || 
                        (x==people_left+0 && y==people_up-13) || 
                        (x==people_left+1 && y==people_up-13) || 
                        (x==people_left+2 && y==people_up-13) || 
                        (x==people_left+3 && y==people_up-13) || 
                        (x==people_left+4 && y==people_up-13) || 
                        (x==people_left+5 && y==people_up-13) || 
                        (x==people_left+6 && y==people_up-13) || 
                        (x==people_left+7 && y==people_up-13) || 
                        (x==people_left+8 && y==people_up-13) || 
                        (x==people_left+9 && y==people_up-13) || 
                        (x==people_left+10 && y==people_up-13) || 
                        (x==people_left+11 && y==people_up-13) || 
                        (x==people_left+12 && y==people_up-13) || 
                        (x==people_left+13 && y==people_up-13) || 
                        (x==people_left+14 && y==people_up-13) || 
                        (x==people_left+15 && y==people_up-13) || 
                        (x==people_left+16 && y==people_up-13) || 
                        (x==people_left+17 && y==people_up-13) || 
                        (x==people_left+18 && y==people_up-13) || 
                        (x==people_left+19 && y==people_up-13) || 
                        (x==people_left+20 && y==people_up-13) || 
                        (x==people_left+21 && y==people_up-13) || 
                        (x==people_left+22 && y==people_up-13) || 
                        (x==people_left+23 && y==people_up-13) || 
                        (x==people_left+24 && y==people_up-13) || 
                        (x==people_left+25 && y==people_up-13) || 
                        (x==people_left+26 && y==people_up-13) || 
                        (x==people_left+27 && y==people_up-13) || 
                        (x==people_left+28 && y==people_up-13) || 
                        (x==people_left+29 && y==people_up-13) || 
                        (x==people_left+30 && y==people_up-13) || 
                        (x==people_left+31 && y==people_up-13) || 
                        (x==people_left+32 && y==people_up-13) || 
                        (x==people_left+33 && y==people_up-13) || 
                        (x==people_left+34 && y==people_up-13) || 
                        (x==people_left+35 && y==people_up-13) || 
                        (x==people_left+36 && y==people_up-13) || 
                        (x==people_left+37 && y==people_up-13) || 
                        (x==people_left+38 && y==people_up-13) || 
                        (x==people_left+39 && y==people_up-13) || 
                        (x==people_left+40 && y==people_up-13) || 
                        (x==people_left+41 && y==people_up-13) || 
                        (x==people_left+42 && y==people_up-13) || 
                        (x==people_left+43 && y==people_up-13) || 
                        (x==people_left+44 && y==people_up-13) || 
                        (x==people_left+45 && y==people_up-13) || 
                        (x==people_left+46 && y==people_up-13) || 
                        (x==people_left+47 && y==people_up-13) || 
                        (x==people_left+48 && y==people_up-13) || 
                        (x==people_left+49 && y==people_up-13) || 
                        (x==people_left+50 && y==people_up-13) || 
                        (x==people_left+51 && y==people_up-13) || 
                        (x==people_left+52 && y==people_up-13) || 
                        (x==people_left+53 && y==people_up-13) || 
                        (x==people_left+54 && y==people_up-13) || 
                        (x==people_left+55 && y==people_up-13) || 
                        (x==people_left+56 && y==people_up-13) || 
                        (x==people_left+57 && y==people_up-13) || 
                        (x==people_left+58 && y==people_up-13) || 
                        (x==people_left+59 && y==people_up-13) || 
                        (x==people_left+60 && y==people_up-13) || 
                        (x==people_left+61 && y==people_up-13) || 
                        (x==people_left+62 && y==people_up-13) || 
                        (x==people_left+63 && y==people_up-13) || 
                        (x==people_left+64 && y==people_up-13) || 
                        (x==people_left+65 && y==people_up-13) || 
                        (x==people_left+66 && y==people_up-13) || 
                        (x==people_left+67 && y==people_up-13) || 
                        (x==people_left+68 && y==people_up-13) || 
                        (x==people_left+69 && y==people_up-13) || 
                        (x==people_left-32 && y==people_up-12) || 
                        (x==people_left-31 && y==people_up-12) || 
                        (x==people_left-30 && y==people_up-12) || 
                        (x==people_left-29 && y==people_up-12) || 
                        (x==people_left-28 && y==people_up-12) || 
                        (x==people_left-27 && y==people_up-12) || 
                        (x==people_left-26 && y==people_up-12) || 
                        (x==people_left-25 && y==people_up-12) || 
                        (x==people_left-24 && y==people_up-12) || 
                        (x==people_left-23 && y==people_up-12) || 
                        (x==people_left-22 && y==people_up-12) || 
                        (x==people_left-21 && y==people_up-12) || 
                        (x==people_left-20 && y==people_up-12) || 
                        (x==people_left-19 && y==people_up-12) || 
                        (x==people_left-18 && y==people_up-12) || 
                        (x==people_left-17 && y==people_up-12) || 
                        (x==people_left-16 && y==people_up-12) || 
                        (x==people_left-15 && y==people_up-12) || 
                        (x==people_left-14 && y==people_up-12) || 
                        (x==people_left-13 && y==people_up-12) || 
                        (x==people_left-12 && y==people_up-12) || 
                        (x==people_left-11 && y==people_up-12) || 
                        (x==people_left-10 && y==people_up-12) || 
                        (x==people_left-9 && y==people_up-12) || 
                        (x==people_left-8 && y==people_up-12) || 
                        (x==people_left-7 && y==people_up-12) || 
                        (x==people_left-6 && y==people_up-12) || 
                        (x==people_left-5 && y==people_up-12) || 
                        (x==people_left-4 && y==people_up-12) || 
                        (x==people_left-3 && y==people_up-12) || 
                        (x==people_left-2 && y==people_up-12) || 
                        (x==people_left-1 && y==people_up-12) || 
                        (x==people_left+0 && y==people_up-12) || 
                        (x==people_left+1 && y==people_up-12) || 
                        (x==people_left+2 && y==people_up-12) || 
                        (x==people_left+3 && y==people_up-12) || 
                        (x==people_left+4 && y==people_up-12) || 
                        (x==people_left+5 && y==people_up-12) || 
                        (x==people_left+6 && y==people_up-12) || 
                        (x==people_left+7 && y==people_up-12) || 
                        (x==people_left+8 && y==people_up-12) || 
                        (x==people_left+9 && y==people_up-12) || 
                        (x==people_left+10 && y==people_up-12) || 
                        (x==people_left+11 && y==people_up-12) || 
                        (x==people_left+12 && y==people_up-12) || 
                        (x==people_left+13 && y==people_up-12) || 
                        (x==people_left+14 && y==people_up-12) || 
                        (x==people_left+15 && y==people_up-12) || 
                        (x==people_left+16 && y==people_up-12) || 
                        (x==people_left+17 && y==people_up-12) || 
                        (x==people_left+18 && y==people_up-12) || 
                        (x==people_left+19 && y==people_up-12) || 
                        (x==people_left+20 && y==people_up-12) || 
                        (x==people_left+21 && y==people_up-12) || 
                        (x==people_left+22 && y==people_up-12) || 
                        (x==people_left+23 && y==people_up-12) || 
                        (x==people_left+24 && y==people_up-12) || 
                        (x==people_left+25 && y==people_up-12) || 
                        (x==people_left+26 && y==people_up-12) || 
                        (x==people_left+27 && y==people_up-12) || 
                        (x==people_left+28 && y==people_up-12) || 
                        (x==people_left+29 && y==people_up-12) || 
                        (x==people_left+30 && y==people_up-12) || 
                        (x==people_left+31 && y==people_up-12) || 
                        (x==people_left+32 && y==people_up-12) || 
                        (x==people_left+33 && y==people_up-12) || 
                        (x==people_left+34 && y==people_up-12) || 
                        (x==people_left+35 && y==people_up-12) || 
                        (x==people_left+36 && y==people_up-12) || 
                        (x==people_left+37 && y==people_up-12) || 
                        (x==people_left+38 && y==people_up-12) || 
                        (x==people_left+39 && y==people_up-12) || 
                        (x==people_left+40 && y==people_up-12) || 
                        (x==people_left+41 && y==people_up-12) || 
                        (x==people_left+42 && y==people_up-12) || 
                        (x==people_left+43 && y==people_up-12) || 
                        (x==people_left+44 && y==people_up-12) || 
                        (x==people_left+45 && y==people_up-12) || 
                        (x==people_left+46 && y==people_up-12) || 
                        (x==people_left+47 && y==people_up-12) || 
                        (x==people_left+48 && y==people_up-12) || 
                        (x==people_left+49 && y==people_up-12) || 
                        (x==people_left+50 && y==people_up-12) || 
                        (x==people_left+51 && y==people_up-12) || 
                        (x==people_left+52 && y==people_up-12) || 
                        (x==people_left+53 && y==people_up-12) || 
                        (x==people_left+54 && y==people_up-12) || 
                        (x==people_left+55 && y==people_up-12) || 
                        (x==people_left+56 && y==people_up-12) || 
                        (x==people_left+57 && y==people_up-12) || 
                        (x==people_left+58 && y==people_up-12) || 
                        (x==people_left+59 && y==people_up-12) || 
                        (x==people_left+60 && y==people_up-12) || 
                        (x==people_left+61 && y==people_up-12) || 
                        (x==people_left+62 && y==people_up-12) || 
                        (x==people_left+63 && y==people_up-12) || 
                        (x==people_left+64 && y==people_up-12) || 
                        (x==people_left+65 && y==people_up-12) || 
                        (x==people_left+66 && y==people_up-12) || 
                        (x==people_left+67 && y==people_up-12) || 
                        (x==people_left+68 && y==people_up-12) || 
                        (x==people_left+69 && y==people_up-12) || 
                        (x==people_left+70 && y==people_up-12) || 
                        (x==people_left-32 && y==people_up-11) || 
                        (x==people_left-31 && y==people_up-11) || 
                        (x==people_left-30 && y==people_up-11) || 
                        (x==people_left-29 && y==people_up-11) || 
                        (x==people_left-28 && y==people_up-11) || 
                        (x==people_left-27 && y==people_up-11) || 
                        (x==people_left-26 && y==people_up-11) || 
                        (x==people_left-25 && y==people_up-11) || 
                        (x==people_left-24 && y==people_up-11) || 
                        (x==people_left-23 && y==people_up-11) || 
                        (x==people_left-22 && y==people_up-11) || 
                        (x==people_left-21 && y==people_up-11) || 
                        (x==people_left-20 && y==people_up-11) || 
                        (x==people_left-19 && y==people_up-11) || 
                        (x==people_left-18 && y==people_up-11) || 
                        (x==people_left-17 && y==people_up-11) || 
                        (x==people_left-16 && y==people_up-11) || 
                        (x==people_left-15 && y==people_up-11) || 
                        (x==people_left-14 && y==people_up-11) || 
                        (x==people_left-13 && y==people_up-11) || 
                        (x==people_left-12 && y==people_up-11) || 
                        (x==people_left-11 && y==people_up-11) || 
                        (x==people_left-10 && y==people_up-11) || 
                        (x==people_left-9 && y==people_up-11) || 
                        (x==people_left-8 && y==people_up-11) || 
                        (x==people_left-7 && y==people_up-11) || 
                        (x==people_left-6 && y==people_up-11) || 
                        (x==people_left-5 && y==people_up-11) || 
                        (x==people_left-4 && y==people_up-11) || 
                        (x==people_left-3 && y==people_up-11) || 
                        (x==people_left-2 && y==people_up-11) || 
                        (x==people_left-1 && y==people_up-11) || 
                        (x==people_left+0 && y==people_up-11) || 
                        (x==people_left+1 && y==people_up-11) || 
                        (x==people_left+2 && y==people_up-11) || 
                        (x==people_left+3 && y==people_up-11) || 
                        (x==people_left+4 && y==people_up-11) || 
                        (x==people_left+5 && y==people_up-11) || 
                        (x==people_left+6 && y==people_up-11) || 
                        (x==people_left+7 && y==people_up-11) || 
                        (x==people_left+8 && y==people_up-11) || 
                        (x==people_left+9 && y==people_up-11) || 
                        (x==people_left+10 && y==people_up-11) || 
                        (x==people_left+11 && y==people_up-11) || 
                        (x==people_left+12 && y==people_up-11) || 
                        (x==people_left+13 && y==people_up-11) || 
                        (x==people_left+14 && y==people_up-11) || 
                        (x==people_left+15 && y==people_up-11) || 
                        (x==people_left+16 && y==people_up-11) || 
                        (x==people_left+17 && y==people_up-11) || 
                        (x==people_left+18 && y==people_up-11) || 
                        (x==people_left+19 && y==people_up-11) || 
                        (x==people_left+20 && y==people_up-11) || 
                        (x==people_left+21 && y==people_up-11) || 
                        (x==people_left+22 && y==people_up-11) || 
                        (x==people_left+23 && y==people_up-11) || 
                        (x==people_left+24 && y==people_up-11) || 
                        (x==people_left+25 && y==people_up-11) || 
                        (x==people_left+26 && y==people_up-11) || 
                        (x==people_left+27 && y==people_up-11) || 
                        (x==people_left+28 && y==people_up-11) || 
                        (x==people_left+29 && y==people_up-11) || 
                        (x==people_left+30 && y==people_up-11) || 
                        (x==people_left+31 && y==people_up-11) || 
                        (x==people_left+32 && y==people_up-11) || 
                        (x==people_left+33 && y==people_up-11) || 
                        (x==people_left+34 && y==people_up-11) || 
                        (x==people_left+35 && y==people_up-11) || 
                        (x==people_left+36 && y==people_up-11) || 
                        (x==people_left+37 && y==people_up-11) || 
                        (x==people_left+38 && y==people_up-11) || 
                        (x==people_left+39 && y==people_up-11) || 
                        (x==people_left+40 && y==people_up-11) || 
                        (x==people_left+41 && y==people_up-11) || 
                        (x==people_left+42 && y==people_up-11) || 
                        (x==people_left+43 && y==people_up-11) || 
                        (x==people_left+44 && y==people_up-11) || 
                        (x==people_left+45 && y==people_up-11) || 
                        (x==people_left+46 && y==people_up-11) || 
                        (x==people_left+47 && y==people_up-11) || 
                        (x==people_left+48 && y==people_up-11) || 
                        (x==people_left+49 && y==people_up-11) || 
                        (x==people_left+50 && y==people_up-11) || 
                        (x==people_left+51 && y==people_up-11) || 
                        (x==people_left+52 && y==people_up-11) || 
                        (x==people_left+53 && y==people_up-11) || 
                        (x==people_left+54 && y==people_up-11) || 
                        (x==people_left+55 && y==people_up-11) || 
                        (x==people_left+56 && y==people_up-11) || 
                        (x==people_left+57 && y==people_up-11) || 
                        (x==people_left+58 && y==people_up-11) || 
                        (x==people_left+59 && y==people_up-11) || 
                        (x==people_left+60 && y==people_up-11) || 
                        (x==people_left+61 && y==people_up-11) || 
                        (x==people_left+62 && y==people_up-11) || 
                        (x==people_left+63 && y==people_up-11) || 
                        (x==people_left+64 && y==people_up-11) || 
                        (x==people_left+65 && y==people_up-11) || 
                        (x==people_left+66 && y==people_up-11) || 
                        (x==people_left+67 && y==people_up-11) || 
                        (x==people_left+68 && y==people_up-11) || 
                        (x==people_left+69 && y==people_up-11) || 
                        (x==people_left+70 && y==people_up-11) || 
                        (x==people_left-33 && y==people_up-10) || 
                        (x==people_left-32 && y==people_up-10) || 
                        (x==people_left-31 && y==people_up-10) || 
                        (x==people_left-30 && y==people_up-10) || 
                        (x==people_left-29 && y==people_up-10) || 
                        (x==people_left-28 && y==people_up-10) || 
                        (x==people_left-27 && y==people_up-10) || 
                        (x==people_left-26 && y==people_up-10) || 
                        (x==people_left-25 && y==people_up-10) || 
                        (x==people_left-24 && y==people_up-10) || 
                        (x==people_left-23 && y==people_up-10) || 
                        (x==people_left-22 && y==people_up-10) || 
                        (x==people_left-21 && y==people_up-10) || 
                        (x==people_left-20 && y==people_up-10) || 
                        (x==people_left-19 && y==people_up-10) || 
                        (x==people_left-18 && y==people_up-10) || 
                        (x==people_left-17 && y==people_up-10) || 
                        (x==people_left-16 && y==people_up-10) || 
                        (x==people_left-15 && y==people_up-10) || 
                        (x==people_left-14 && y==people_up-10) || 
                        (x==people_left-13 && y==people_up-10) || 
                        (x==people_left-12 && y==people_up-10) || 
                        (x==people_left-11 && y==people_up-10) || 
                        (x==people_left-10 && y==people_up-10) || 
                        (x==people_left-9 && y==people_up-10) || 
                        (x==people_left-8 && y==people_up-10) || 
                        (x==people_left-7 && y==people_up-10) || 
                        (x==people_left-6 && y==people_up-10) || 
                        (x==people_left-5 && y==people_up-10) || 
                        (x==people_left-4 && y==people_up-10) || 
                        (x==people_left-3 && y==people_up-10) || 
                        (x==people_left-2 && y==people_up-10) || 
                        (x==people_left-1 && y==people_up-10) || 
                        (x==people_left+0 && y==people_up-10) || 
                        (x==people_left+1 && y==people_up-10) || 
                        (x==people_left+2 && y==people_up-10) || 
                        (x==people_left+3 && y==people_up-10) || 
                        (x==people_left+4 && y==people_up-10) || 
                        (x==people_left+5 && y==people_up-10) || 
                        (x==people_left+6 && y==people_up-10) || 
                        (x==people_left+7 && y==people_up-10) || 
                        (x==people_left+8 && y==people_up-10) || 
                        (x==people_left+9 && y==people_up-10) || 
                        (x==people_left+10 && y==people_up-10) || 
                        (x==people_left+11 && y==people_up-10) || 
                        (x==people_left+12 && y==people_up-10) || 
                        (x==people_left+13 && y==people_up-10) || 
                        (x==people_left+14 && y==people_up-10) || 
                        (x==people_left+15 && y==people_up-10) || 
                        (x==people_left+16 && y==people_up-10) || 
                        (x==people_left+17 && y==people_up-10) || 
                        (x==people_left+18 && y==people_up-10) || 
                        (x==people_left+19 && y==people_up-10) || 
                        (x==people_left+20 && y==people_up-10) || 
                        (x==people_left+21 && y==people_up-10) || 
                        (x==people_left+22 && y==people_up-10) || 
                        (x==people_left+23 && y==people_up-10) || 
                        (x==people_left+24 && y==people_up-10) || 
                        (x==people_left+25 && y==people_up-10) || 
                        (x==people_left+26 && y==people_up-10) || 
                        (x==people_left+27 && y==people_up-10) || 
                        (x==people_left+28 && y==people_up-10) || 
                        (x==people_left+29 && y==people_up-10) || 
                        (x==people_left+30 && y==people_up-10) || 
                        (x==people_left+31 && y==people_up-10) || 
                        (x==people_left+32 && y==people_up-10) || 
                        (x==people_left+33 && y==people_up-10) || 
                        (x==people_left+34 && y==people_up-10) || 
                        (x==people_left+35 && y==people_up-10) || 
                        (x==people_left+36 && y==people_up-10) || 
                        (x==people_left+37 && y==people_up-10) || 
                        (x==people_left+38 && y==people_up-10) || 
                        (x==people_left+39 && y==people_up-10) || 
                        (x==people_left+40 && y==people_up-10) || 
                        (x==people_left+41 && y==people_up-10) || 
                        (x==people_left+42 && y==people_up-10) || 
                        (x==people_left+43 && y==people_up-10) || 
                        (x==people_left+44 && y==people_up-10) || 
                        (x==people_left+45 && y==people_up-10) || 
                        (x==people_left+46 && y==people_up-10) || 
                        (x==people_left+47 && y==people_up-10) || 
                        (x==people_left+48 && y==people_up-10) || 
                        (x==people_left+49 && y==people_up-10) || 
                        (x==people_left+50 && y==people_up-10) || 
                        (x==people_left+51 && y==people_up-10) || 
                        (x==people_left+52 && y==people_up-10) || 
                        (x==people_left+53 && y==people_up-10) || 
                        (x==people_left+54 && y==people_up-10) || 
                        (x==people_left+55 && y==people_up-10) || 
                        (x==people_left+56 && y==people_up-10) || 
                        (x==people_left+57 && y==people_up-10) || 
                        (x==people_left+58 && y==people_up-10) || 
                        (x==people_left+59 && y==people_up-10) || 
                        (x==people_left+60 && y==people_up-10) || 
                        (x==people_left+61 && y==people_up-10) || 
                        (x==people_left+62 && y==people_up-10) || 
                        (x==people_left+63 && y==people_up-10) || 
                        (x==people_left+64 && y==people_up-10) || 
                        (x==people_left+65 && y==people_up-10) || 
                        (x==people_left+66 && y==people_up-10) || 
                        (x==people_left+67 && y==people_up-10) || 
                        (x==people_left+68 && y==people_up-10) || 
                        (x==people_left+69 && y==people_up-10) || 
                        (x==people_left+70 && y==people_up-10) || 
                        (x==people_left+71 && y==people_up-10) || 
                        (x==people_left-33 && y==people_up-9) || 
                        (x==people_left-32 && y==people_up-9) || 
                        (x==people_left-31 && y==people_up-9) || 
                        (x==people_left-30 && y==people_up-9) || 
                        (x==people_left-29 && y==people_up-9) || 
                        (x==people_left-28 && y==people_up-9) || 
                        (x==people_left-27 && y==people_up-9) || 
                        (x==people_left-26 && y==people_up-9) || 
                        (x==people_left-25 && y==people_up-9) || 
                        (x==people_left-24 && y==people_up-9) || 
                        (x==people_left-23 && y==people_up-9) || 
                        (x==people_left-22 && y==people_up-9) || 
                        (x==people_left-21 && y==people_up-9) || 
                        (x==people_left-20 && y==people_up-9) || 
                        (x==people_left-19 && y==people_up-9) || 
                        (x==people_left-18 && y==people_up-9) || 
                        (x==people_left-17 && y==people_up-9) || 
                        (x==people_left-16 && y==people_up-9) || 
                        (x==people_left-15 && y==people_up-9) || 
                        (x==people_left-14 && y==people_up-9) || 
                        (x==people_left-13 && y==people_up-9) || 
                        (x==people_left-12 && y==people_up-9) || 
                        (x==people_left-11 && y==people_up-9) || 
                        (x==people_left-10 && y==people_up-9) || 
                        (x==people_left-9 && y==people_up-9) || 
                        (x==people_left-8 && y==people_up-9) || 
                        (x==people_left-7 && y==people_up-9) || 
                        (x==people_left-6 && y==people_up-9) || 
                        (x==people_left-5 && y==people_up-9) || 
                        (x==people_left-4 && y==people_up-9) || 
                        (x==people_left-3 && y==people_up-9) || 
                        (x==people_left-2 && y==people_up-9) || 
                        (x==people_left-1 && y==people_up-9) || 
                        (x==people_left+0 && y==people_up-9) || 
                        (x==people_left+1 && y==people_up-9) || 
                        (x==people_left+2 && y==people_up-9) || 
                        (x==people_left+3 && y==people_up-9) || 
                        (x==people_left+4 && y==people_up-9) || 
                        (x==people_left+5 && y==people_up-9) || 
                        (x==people_left+6 && y==people_up-9) || 
                        (x==people_left+7 && y==people_up-9) || 
                        (x==people_left+8 && y==people_up-9) || 
                        (x==people_left+9 && y==people_up-9) || 
                        (x==people_left+10 && y==people_up-9) || 
                        (x==people_left+11 && y==people_up-9) || 
                        (x==people_left+12 && y==people_up-9) || 
                        (x==people_left+13 && y==people_up-9) || 
                        (x==people_left+14 && y==people_up-9) || 
                        (x==people_left+15 && y==people_up-9) || 
                        (x==people_left+16 && y==people_up-9) || 
                        (x==people_left+17 && y==people_up-9) || 
                        (x==people_left+18 && y==people_up-9) || 
                        (x==people_left+19 && y==people_up-9) || 
                        (x==people_left+20 && y==people_up-9) || 
                        (x==people_left+21 && y==people_up-9) || 
                        (x==people_left+22 && y==people_up-9) || 
                        (x==people_left+23 && y==people_up-9) || 
                        (x==people_left+24 && y==people_up-9) || 
                        (x==people_left+25 && y==people_up-9) || 
                        (x==people_left+26 && y==people_up-9) || 
                        (x==people_left+27 && y==people_up-9) || 
                        (x==people_left+28 && y==people_up-9) || 
                        (x==people_left+29 && y==people_up-9) || 
                        (x==people_left+30 && y==people_up-9) || 
                        (x==people_left+31 && y==people_up-9) || 
                        (x==people_left+32 && y==people_up-9) || 
                        (x==people_left+33 && y==people_up-9) || 
                        (x==people_left+34 && y==people_up-9) || 
                        (x==people_left+35 && y==people_up-9) || 
                        (x==people_left+36 && y==people_up-9) || 
                        (x==people_left+37 && y==people_up-9) || 
                        (x==people_left+38 && y==people_up-9) || 
                        (x==people_left+39 && y==people_up-9) || 
                        (x==people_left+40 && y==people_up-9) || 
                        (x==people_left+41 && y==people_up-9) || 
                        (x==people_left+42 && y==people_up-9) || 
                        (x==people_left+43 && y==people_up-9) || 
                        (x==people_left+44 && y==people_up-9) || 
                        (x==people_left+45 && y==people_up-9) || 
                        (x==people_left+46 && y==people_up-9) || 
                        (x==people_left+47 && y==people_up-9) || 
                        (x==people_left+48 && y==people_up-9) || 
                        (x==people_left+49 && y==people_up-9) || 
                        (x==people_left+50 && y==people_up-9) || 
                        (x==people_left+51 && y==people_up-9) || 
                        (x==people_left+52 && y==people_up-9) || 
                        (x==people_left+53 && y==people_up-9) || 
                        (x==people_left+54 && y==people_up-9) || 
                        (x==people_left+55 && y==people_up-9) || 
                        (x==people_left+56 && y==people_up-9) || 
                        (x==people_left+57 && y==people_up-9) || 
                        (x==people_left+58 && y==people_up-9) || 
                        (x==people_left+59 && y==people_up-9) || 
                        (x==people_left+60 && y==people_up-9) || 
                        (x==people_left+61 && y==people_up-9) || 
                        (x==people_left+62 && y==people_up-9) || 
                        (x==people_left+63 && y==people_up-9) || 
                        (x==people_left+64 && y==people_up-9) || 
                        (x==people_left+65 && y==people_up-9) || 
                        (x==people_left+66 && y==people_up-9) || 
                        (x==people_left+67 && y==people_up-9) || 
                        (x==people_left+68 && y==people_up-9) || 
                        (x==people_left+69 && y==people_up-9) || 
                        (x==people_left+70 && y==people_up-9) || 
                        (x==people_left+71 && y==people_up-9) || 
                        (x==people_left-34 && y==people_up-8) || 
                        (x==people_left-33 && y==people_up-8) || 
                        (x==people_left-32 && y==people_up-8) || 
                        (x==people_left-31 && y==people_up-8) || 
                        (x==people_left-30 && y==people_up-8) || 
                        (x==people_left-29 && y==people_up-8) || 
                        (x==people_left-28 && y==people_up-8) || 
                        (x==people_left-27 && y==people_up-8) || 
                        (x==people_left-26 && y==people_up-8) || 
                        (x==people_left-25 && y==people_up-8) || 
                        (x==people_left-24 && y==people_up-8) || 
                        (x==people_left-23 && y==people_up-8) || 
                        (x==people_left-22 && y==people_up-8) || 
                        (x==people_left-21 && y==people_up-8) || 
                        (x==people_left-20 && y==people_up-8) || 
                        (x==people_left-19 && y==people_up-8) || 
                        (x==people_left-18 && y==people_up-8) || 
                        (x==people_left-17 && y==people_up-8) || 
                        (x==people_left-16 && y==people_up-8) || 
                        (x==people_left-15 && y==people_up-8) || 
                        (x==people_left-14 && y==people_up-8) || 
                        (x==people_left-13 && y==people_up-8) || 
                        (x==people_left-12 && y==people_up-8) || 
                        (x==people_left-11 && y==people_up-8) || 
                        (x==people_left-10 && y==people_up-8) || 
                        (x==people_left-9 && y==people_up-8) || 
                        (x==people_left-8 && y==people_up-8) || 
                        (x==people_left-7 && y==people_up-8) || 
                        (x==people_left-6 && y==people_up-8) || 
                        (x==people_left-5 && y==people_up-8) || 
                        (x==people_left-4 && y==people_up-8) || 
                        (x==people_left-3 && y==people_up-8) || 
                        (x==people_left-2 && y==people_up-8) || 
                        (x==people_left-1 && y==people_up-8) || 
                        (x==people_left+0 && y==people_up-8) || 
                        (x==people_left+1 && y==people_up-8) || 
                        (x==people_left+2 && y==people_up-8) || 
                        (x==people_left+3 && y==people_up-8) || 
                        (x==people_left+4 && y==people_up-8) || 
                        (x==people_left+5 && y==people_up-8) || 
                        (x==people_left+6 && y==people_up-8) || 
                        (x==people_left+7 && y==people_up-8) || 
                        (x==people_left+8 && y==people_up-8) || 
                        (x==people_left+9 && y==people_up-8) || 
                        (x==people_left+10 && y==people_up-8) || 
                        (x==people_left+11 && y==people_up-8) || 
                        (x==people_left+12 && y==people_up-8) || 
                        (x==people_left+13 && y==people_up-8) || 
                        (x==people_left+14 && y==people_up-8) || 
                        (x==people_left+15 && y==people_up-8) || 
                        (x==people_left+16 && y==people_up-8) || 
                        (x==people_left+17 && y==people_up-8) || 
                        (x==people_left+18 && y==people_up-8) || 
                        (x==people_left+19 && y==people_up-8) || 
                        (x==people_left+20 && y==people_up-8) || 
                        (x==people_left+21 && y==people_up-8) || 
                        (x==people_left+22 && y==people_up-8) || 
                        (x==people_left+23 && y==people_up-8) || 
                        (x==people_left+24 && y==people_up-8) || 
                        (x==people_left+25 && y==people_up-8) || 
                        (x==people_left+26 && y==people_up-8) || 
                        (x==people_left+27 && y==people_up-8) || 
                        (x==people_left+28 && y==people_up-8) || 
                        (x==people_left+29 && y==people_up-8) || 
                        (x==people_left+30 && y==people_up-8) || 
                        (x==people_left+31 && y==people_up-8) || 
                        (x==people_left+32 && y==people_up-8) || 
                        (x==people_left+33 && y==people_up-8) || 
                        (x==people_left+34 && y==people_up-8) || 
                        (x==people_left+35 && y==people_up-8) || 
                        (x==people_left+36 && y==people_up-8) || 
                        (x==people_left+37 && y==people_up-8) || 
                        (x==people_left+38 && y==people_up-8) || 
                        (x==people_left+39 && y==people_up-8) || 
                        (x==people_left+40 && y==people_up-8) || 
                        (x==people_left+41 && y==people_up-8) || 
                        (x==people_left+42 && y==people_up-8) || 
                        (x==people_left+43 && y==people_up-8) || 
                        (x==people_left+44 && y==people_up-8) || 
                        (x==people_left+45 && y==people_up-8) || 
                        (x==people_left+46 && y==people_up-8) || 
                        (x==people_left+47 && y==people_up-8) || 
                        (x==people_left+48 && y==people_up-8) || 
                        (x==people_left+49 && y==people_up-8) || 
                        (x==people_left+50 && y==people_up-8) || 
                        (x==people_left+51 && y==people_up-8) || 
                        (x==people_left+52 && y==people_up-8) || 
                        (x==people_left+53 && y==people_up-8) || 
                        (x==people_left+54 && y==people_up-8) || 
                        (x==people_left+55 && y==people_up-8) || 
                        (x==people_left+56 && y==people_up-8) || 
                        (x==people_left+57 && y==people_up-8) || 
                        (x==people_left+58 && y==people_up-8) || 
                        (x==people_left+59 && y==people_up-8) || 
                        (x==people_left+60 && y==people_up-8) || 
                        (x==people_left+61 && y==people_up-8) || 
                        (x==people_left+62 && y==people_up-8) || 
                        (x==people_left+63 && y==people_up-8) || 
                        (x==people_left+64 && y==people_up-8) || 
                        (x==people_left+65 && y==people_up-8) || 
                        (x==people_left+66 && y==people_up-8) || 
                        (x==people_left+67 && y==people_up-8) || 
                        (x==people_left+68 && y==people_up-8) || 
                        (x==people_left+69 && y==people_up-8) || 
                        (x==people_left+70 && y==people_up-8) || 
                        (x==people_left+71 && y==people_up-8) || 
                        (x==people_left+72 && y==people_up-8) || 
                        (x==people_left-34 && y==people_up-7) || 
                        (x==people_left-33 && y==people_up-7) || 
                        (x==people_left-32 && y==people_up-7) || 
                        (x==people_left-31 && y==people_up-7) || 
                        (x==people_left-30 && y==people_up-7) || 
                        (x==people_left-29 && y==people_up-7) || 
                        (x==people_left-28 && y==people_up-7) || 
                        (x==people_left-27 && y==people_up-7) || 
                        (x==people_left-26 && y==people_up-7) || 
                        (x==people_left-25 && y==people_up-7) || 
                        (x==people_left-24 && y==people_up-7) || 
                        (x==people_left-23 && y==people_up-7) || 
                        (x==people_left-22 && y==people_up-7) || 
                        (x==people_left-21 && y==people_up-7) || 
                        (x==people_left-20 && y==people_up-7) || 
                        (x==people_left-19 && y==people_up-7) || 
                        (x==people_left-18 && y==people_up-7) || 
                        (x==people_left-17 && y==people_up-7) || 
                        (x==people_left-16 && y==people_up-7) || 
                        (x==people_left-15 && y==people_up-7) || 
                        (x==people_left-14 && y==people_up-7) || 
                        (x==people_left-13 && y==people_up-7) || 
                        (x==people_left-12 && y==people_up-7) || 
                        (x==people_left-11 && y==people_up-7) || 
                        (x==people_left-10 && y==people_up-7) || 
                        (x==people_left-9 && y==people_up-7) || 
                        (x==people_left-8 && y==people_up-7) || 
                        (x==people_left-7 && y==people_up-7) || 
                        (x==people_left-6 && y==people_up-7) || 
                        (x==people_left-5 && y==people_up-7) || 
                        (x==people_left-4 && y==people_up-7) || 
                        (x==people_left-3 && y==people_up-7) || 
                        (x==people_left-2 && y==people_up-7) || 
                        (x==people_left-1 && y==people_up-7) || 
                        (x==people_left+0 && y==people_up-7) || 
                        (x==people_left+1 && y==people_up-7) || 
                        (x==people_left+2 && y==people_up-7) || 
                        (x==people_left+3 && y==people_up-7) || 
                        (x==people_left+4 && y==people_up-7) || 
                        (x==people_left+5 && y==people_up-7) || 
                        (x==people_left+6 && y==people_up-7) || 
                        (x==people_left+7 && y==people_up-7) || 
                        (x==people_left+8 && y==people_up-7) || 
                        (x==people_left+9 && y==people_up-7) || 
                        (x==people_left+10 && y==people_up-7) || 
                        (x==people_left+11 && y==people_up-7) || 
                        (x==people_left+12 && y==people_up-7) || 
                        (x==people_left+13 && y==people_up-7) || 
                        (x==people_left+14 && y==people_up-7) || 
                        (x==people_left+15 && y==people_up-7) || 
                        (x==people_left+16 && y==people_up-7) || 
                        (x==people_left+17 && y==people_up-7) || 
                        (x==people_left+18 && y==people_up-7) || 
                        (x==people_left+19 && y==people_up-7) || 
                        (x==people_left+20 && y==people_up-7) || 
                        (x==people_left+21 && y==people_up-7) || 
                        (x==people_left+22 && y==people_up-7) || 
                        (x==people_left+23 && y==people_up-7) || 
                        (x==people_left+24 && y==people_up-7) || 
                        (x==people_left+25 && y==people_up-7) || 
                        (x==people_left+26 && y==people_up-7) || 
                        (x==people_left+27 && y==people_up-7) || 
                        (x==people_left+28 && y==people_up-7) || 
                        (x==people_left+29 && y==people_up-7) || 
                        (x==people_left+30 && y==people_up-7) || 
                        (x==people_left+31 && y==people_up-7) || 
                        (x==people_left+32 && y==people_up-7) || 
                        (x==people_left+33 && y==people_up-7) || 
                        (x==people_left+34 && y==people_up-7) || 
                        (x==people_left+35 && y==people_up-7) || 
                        (x==people_left+36 && y==people_up-7) || 
                        (x==people_left+37 && y==people_up-7) || 
                        (x==people_left+38 && y==people_up-7) || 
                        (x==people_left+39 && y==people_up-7) || 
                        (x==people_left+40 && y==people_up-7) || 
                        (x==people_left+41 && y==people_up-7) || 
                        (x==people_left+42 && y==people_up-7) || 
                        (x==people_left+43 && y==people_up-7) || 
                        (x==people_left+44 && y==people_up-7) || 
                        (x==people_left+45 && y==people_up-7) || 
                        (x==people_left+46 && y==people_up-7) || 
                        (x==people_left+47 && y==people_up-7) || 
                        (x==people_left+48 && y==people_up-7) || 
                        (x==people_left+49 && y==people_up-7) || 
                        (x==people_left+50 && y==people_up-7) || 
                        (x==people_left+51 && y==people_up-7) || 
                        (x==people_left+52 && y==people_up-7) || 
                        (x==people_left+53 && y==people_up-7) || 
                        (x==people_left+54 && y==people_up-7) || 
                        (x==people_left+55 && y==people_up-7) || 
                        (x==people_left+56 && y==people_up-7) || 
                        (x==people_left+57 && y==people_up-7) || 
                        (x==people_left+58 && y==people_up-7) || 
                        (x==people_left+59 && y==people_up-7) || 
                        (x==people_left+60 && y==people_up-7) || 
                        (x==people_left+61 && y==people_up-7) || 
                        (x==people_left+62 && y==people_up-7) || 
                        (x==people_left+63 && y==people_up-7) || 
                        (x==people_left+64 && y==people_up-7) || 
                        (x==people_left+65 && y==people_up-7) || 
                        (x==people_left+66 && y==people_up-7) || 
                        (x==people_left+67 && y==people_up-7) || 
                        (x==people_left+68 && y==people_up-7) || 
                        (x==people_left+69 && y==people_up-7) || 
                        (x==people_left+70 && y==people_up-7) || 
                        (x==people_left+71 && y==people_up-7) || 
                        (x==people_left+72 && y==people_up-7) || 
                        (x==people_left-35 && y==people_up-6) || 
                        (x==people_left-34 && y==people_up-6) || 
                        (x==people_left-33 && y==people_up-6) || 
                        (x==people_left-32 && y==people_up-6) || 
                        (x==people_left-31 && y==people_up-6) || 
                        (x==people_left-30 && y==people_up-6) || 
                        (x==people_left-29 && y==people_up-6) || 
                        (x==people_left-28 && y==people_up-6) || 
                        (x==people_left-27 && y==people_up-6) || 
                        (x==people_left-26 && y==people_up-6) || 
                        (x==people_left-25 && y==people_up-6) || 
                        (x==people_left-24 && y==people_up-6) || 
                        (x==people_left-23 && y==people_up-6) || 
                        (x==people_left-22 && y==people_up-6) || 
                        (x==people_left-21 && y==people_up-6) || 
                        (x==people_left-20 && y==people_up-6) || 
                        (x==people_left-19 && y==people_up-6) || 
                        (x==people_left-18 && y==people_up-6) || 
                        (x==people_left-17 && y==people_up-6) || 
                        (x==people_left-16 && y==people_up-6) || 
                        (x==people_left-15 && y==people_up-6) || 
                        (x==people_left-14 && y==people_up-6) || 
                        (x==people_left-13 && y==people_up-6) || 
                        (x==people_left-12 && y==people_up-6) || 
                        (x==people_left-11 && y==people_up-6) || 
                        (x==people_left-10 && y==people_up-6) || 
                        (x==people_left-9 && y==people_up-6) || 
                        (x==people_left-8 && y==people_up-6) || 
                        (x==people_left-7 && y==people_up-6) || 
                        (x==people_left-6 && y==people_up-6) || 
                        (x==people_left-5 && y==people_up-6) || 
                        (x==people_left-4 && y==people_up-6) || 
                        (x==people_left-3 && y==people_up-6) || 
                        (x==people_left-2 && y==people_up-6) || 
                        (x==people_left-1 && y==people_up-6) || 
                        (x==people_left+0 && y==people_up-6) || 
                        (x==people_left+1 && y==people_up-6) || 
                        (x==people_left+2 && y==people_up-6) || 
                        (x==people_left+3 && y==people_up-6) || 
                        (x==people_left+4 && y==people_up-6) || 
                        (x==people_left+5 && y==people_up-6) || 
                        (x==people_left+6 && y==people_up-6) || 
                        (x==people_left+7 && y==people_up-6) || 
                        (x==people_left+8 && y==people_up-6) || 
                        (x==people_left+9 && y==people_up-6) || 
                        (x==people_left+10 && y==people_up-6) || 
                        (x==people_left+11 && y==people_up-6) || 
                        (x==people_left+12 && y==people_up-6) || 
                        (x==people_left+13 && y==people_up-6) || 
                        (x==people_left+14 && y==people_up-6) || 
                        (x==people_left+15 && y==people_up-6) || 
                        (x==people_left+16 && y==people_up-6) || 
                        (x==people_left+17 && y==people_up-6) || 
                        (x==people_left+18 && y==people_up-6) || 
                        (x==people_left+19 && y==people_up-6) || 
                        (x==people_left+20 && y==people_up-6) || 
                        (x==people_left+21 && y==people_up-6) || 
                        (x==people_left+22 && y==people_up-6) || 
                        (x==people_left+23 && y==people_up-6) || 
                        (x==people_left+24 && y==people_up-6) || 
                        (x==people_left+25 && y==people_up-6) || 
                        (x==people_left+26 && y==people_up-6) || 
                        (x==people_left+27 && y==people_up-6) || 
                        (x==people_left+28 && y==people_up-6) || 
                        (x==people_left+29 && y==people_up-6) || 
                        (x==people_left+30 && y==people_up-6) || 
                        (x==people_left+31 && y==people_up-6) || 
                        (x==people_left+32 && y==people_up-6) || 
                        (x==people_left+33 && y==people_up-6) || 
                        (x==people_left+34 && y==people_up-6) || 
                        (x==people_left+35 && y==people_up-6) || 
                        (x==people_left+36 && y==people_up-6) || 
                        (x==people_left+37 && y==people_up-6) || 
                        (x==people_left+38 && y==people_up-6) || 
                        (x==people_left+39 && y==people_up-6) || 
                        (x==people_left+40 && y==people_up-6) || 
                        (x==people_left+41 && y==people_up-6) || 
                        (x==people_left+42 && y==people_up-6) || 
                        (x==people_left+43 && y==people_up-6) || 
                        (x==people_left+44 && y==people_up-6) || 
                        (x==people_left+45 && y==people_up-6) || 
                        (x==people_left+46 && y==people_up-6) || 
                        (x==people_left+47 && y==people_up-6) || 
                        (x==people_left+48 && y==people_up-6) || 
                        (x==people_left+49 && y==people_up-6) || 
                        (x==people_left+50 && y==people_up-6) || 
                        (x==people_left+51 && y==people_up-6) || 
                        (x==people_left+52 && y==people_up-6) || 
                        (x==people_left+53 && y==people_up-6) || 
                        (x==people_left+54 && y==people_up-6) || 
                        (x==people_left+55 && y==people_up-6) || 
                        (x==people_left+56 && y==people_up-6) || 
                        (x==people_left+57 && y==people_up-6) || 
                        (x==people_left+58 && y==people_up-6) || 
                        (x==people_left+59 && y==people_up-6) || 
                        (x==people_left+60 && y==people_up-6) || 
                        (x==people_left+61 && y==people_up-6) || 
                        (x==people_left+62 && y==people_up-6) || 
                        (x==people_left+63 && y==people_up-6) || 
                        (x==people_left+64 && y==people_up-6) || 
                        (x==people_left+65 && y==people_up-6) || 
                        (x==people_left+66 && y==people_up-6) || 
                        (x==people_left+67 && y==people_up-6) || 
                        (x==people_left+68 && y==people_up-6) || 
                        (x==people_left+69 && y==people_up-6) || 
                        (x==people_left+70 && y==people_up-6) || 
                        (x==people_left+71 && y==people_up-6) || 
                        (x==people_left+72 && y==people_up-6) || 
                        (x==people_left+73 && y==people_up-6) || 
                        (x==people_left-35 && y==people_up-5) || 
                        (x==people_left-34 && y==people_up-5) || 
                        (x==people_left-33 && y==people_up-5) || 
                        (x==people_left-32 && y==people_up-5) || 
                        (x==people_left-31 && y==people_up-5) || 
                        (x==people_left-30 && y==people_up-5) || 
                        (x==people_left-29 && y==people_up-5) || 
                        (x==people_left-28 && y==people_up-5) || 
                        (x==people_left-27 && y==people_up-5) || 
                        (x==people_left-26 && y==people_up-5) || 
                        (x==people_left-25 && y==people_up-5) || 
                        (x==people_left-24 && y==people_up-5) || 
                        (x==people_left-23 && y==people_up-5) || 
                        (x==people_left-22 && y==people_up-5) || 
                        (x==people_left-21 && y==people_up-5) || 
                        (x==people_left-20 && y==people_up-5) || 
                        (x==people_left-19 && y==people_up-5) || 
                        (x==people_left-18 && y==people_up-5) || 
                        (x==people_left-17 && y==people_up-5) || 
                        (x==people_left-16 && y==people_up-5) || 
                        (x==people_left-15 && y==people_up-5) || 
                        (x==people_left-14 && y==people_up-5) || 
                        (x==people_left-13 && y==people_up-5) || 
                        (x==people_left-12 && y==people_up-5) || 
                        (x==people_left-11 && y==people_up-5) || 
                        (x==people_left-10 && y==people_up-5) || 
                        (x==people_left-9 && y==people_up-5) || 
                        (x==people_left-8 && y==people_up-5) || 
                        (x==people_left-7 && y==people_up-5) || 
                        (x==people_left-6 && y==people_up-5) || 
                        (x==people_left-5 && y==people_up-5) || 
                        (x==people_left-4 && y==people_up-5) || 
                        (x==people_left-3 && y==people_up-5) || 
                        (x==people_left-2 && y==people_up-5) || 
                        (x==people_left-1 && y==people_up-5) || 
                        (x==people_left+0 && y==people_up-5) || 
                        (x==people_left+1 && y==people_up-5) || 
                        (x==people_left+2 && y==people_up-5) || 
                        (x==people_left+3 && y==people_up-5) || 
                        (x==people_left+4 && y==people_up-5) || 
                        (x==people_left+5 && y==people_up-5) || 
                        (x==people_left+6 && y==people_up-5) || 
                        (x==people_left+7 && y==people_up-5) || 
                        (x==people_left+8 && y==people_up-5) || 
                        (x==people_left+9 && y==people_up-5) || 
                        (x==people_left+10 && y==people_up-5) || 
                        (x==people_left+11 && y==people_up-5) || 
                        (x==people_left+12 && y==people_up-5) || 
                        (x==people_left+13 && y==people_up-5) || 
                        (x==people_left+14 && y==people_up-5) || 
                        (x==people_left+15 && y==people_up-5) || 
                        (x==people_left+16 && y==people_up-5) || 
                        (x==people_left+17 && y==people_up-5) || 
                        (x==people_left+18 && y==people_up-5) || 
                        (x==people_left+19 && y==people_up-5) || 
                        (x==people_left+20 && y==people_up-5) || 
                        (x==people_left+21 && y==people_up-5) || 
                        (x==people_left+22 && y==people_up-5) || 
                        (x==people_left+23 && y==people_up-5) || 
                        (x==people_left+24 && y==people_up-5) || 
                        (x==people_left+25 && y==people_up-5) || 
                        (x==people_left+26 && y==people_up-5) || 
                        (x==people_left+27 && y==people_up-5) || 
                        (x==people_left+28 && y==people_up-5) || 
                        (x==people_left+29 && y==people_up-5) || 
                        (x==people_left+30 && y==people_up-5) || 
                        (x==people_left+31 && y==people_up-5) || 
                        (x==people_left+32 && y==people_up-5) || 
                        (x==people_left+33 && y==people_up-5) || 
                        (x==people_left+34 && y==people_up-5) || 
                        (x==people_left+35 && y==people_up-5) || 
                        (x==people_left+36 && y==people_up-5) || 
                        (x==people_left+37 && y==people_up-5) || 
                        (x==people_left+38 && y==people_up-5) || 
                        (x==people_left+39 && y==people_up-5) || 
                        (x==people_left+40 && y==people_up-5) || 
                        (x==people_left+41 && y==people_up-5) || 
                        (x==people_left+42 && y==people_up-5) || 
                        (x==people_left+43 && y==people_up-5) || 
                        (x==people_left+44 && y==people_up-5) || 
                        (x==people_left+45 && y==people_up-5) || 
                        (x==people_left+46 && y==people_up-5) || 
                        (x==people_left+47 && y==people_up-5) || 
                        (x==people_left+48 && y==people_up-5) || 
                        (x==people_left+49 && y==people_up-5) || 
                        (x==people_left+50 && y==people_up-5) || 
                        (x==people_left+51 && y==people_up-5) || 
                        (x==people_left+52 && y==people_up-5) || 
                        (x==people_left+53 && y==people_up-5) || 
                        (x==people_left+54 && y==people_up-5) || 
                        (x==people_left+55 && y==people_up-5) || 
                        (x==people_left+56 && y==people_up-5) || 
                        (x==people_left+57 && y==people_up-5) || 
                        (x==people_left+58 && y==people_up-5) || 
                        (x==people_left+59 && y==people_up-5) || 
                        (x==people_left+60 && y==people_up-5) || 
                        (x==people_left+61 && y==people_up-5) || 
                        (x==people_left+62 && y==people_up-5) || 
                        (x==people_left+63 && y==people_up-5) || 
                        (x==people_left+64 && y==people_up-5) || 
                        (x==people_left+65 && y==people_up-5) || 
                        (x==people_left+66 && y==people_up-5) || 
                        (x==people_left+67 && y==people_up-5) || 
                        (x==people_left+68 && y==people_up-5) || 
                        (x==people_left+69 && y==people_up-5) || 
                        (x==people_left+70 && y==people_up-5) || 
                        (x==people_left+71 && y==people_up-5) || 
                        (x==people_left+72 && y==people_up-5) || 
                        (x==people_left+73 && y==people_up-5) || 
                        (x==people_left-36 && y==people_up-4) || 
                        (x==people_left-35 && y==people_up-4) || 
                        (x==people_left-34 && y==people_up-4) || 
                        (x==people_left-33 && y==people_up-4) || 
                        (x==people_left-32 && y==people_up-4) || 
                        (x==people_left-31 && y==people_up-4) || 
                        (x==people_left-30 && y==people_up-4) || 
                        (x==people_left-29 && y==people_up-4) || 
                        (x==people_left-28 && y==people_up-4) || 
                        (x==people_left-27 && y==people_up-4) || 
                        (x==people_left-26 && y==people_up-4) || 
                        (x==people_left-25 && y==people_up-4) || 
                        (x==people_left-24 && y==people_up-4) || 
                        (x==people_left-23 && y==people_up-4) || 
                        (x==people_left-22 && y==people_up-4) || 
                        (x==people_left-21 && y==people_up-4) || 
                        (x==people_left-20 && y==people_up-4) || 
                        (x==people_left-19 && y==people_up-4) || 
                        (x==people_left-18 && y==people_up-4) || 
                        (x==people_left-17 && y==people_up-4) || 
                        (x==people_left-16 && y==people_up-4) || 
                        (x==people_left-15 && y==people_up-4) || 
                        (x==people_left-14 && y==people_up-4) || 
                        (x==people_left-13 && y==people_up-4) || 
                        (x==people_left-12 && y==people_up-4) || 
                        (x==people_left-11 && y==people_up-4) || 
                        (x==people_left-10 && y==people_up-4) || 
                        (x==people_left-9 && y==people_up-4) || 
                        (x==people_left-8 && y==people_up-4) || 
                        (x==people_left-7 && y==people_up-4) || 
                        (x==people_left-6 && y==people_up-4) || 
                        (x==people_left-5 && y==people_up-4) || 
                        (x==people_left-4 && y==people_up-4) || 
                        (x==people_left-3 && y==people_up-4) || 
                        (x==people_left-2 && y==people_up-4) || 
                        (x==people_left-1 && y==people_up-4) || 
                        (x==people_left+0 && y==people_up-4) || 
                        (x==people_left+1 && y==people_up-4) || 
                        (x==people_left+2 && y==people_up-4) || 
                        (x==people_left+3 && y==people_up-4) || 
                        (x==people_left+4 && y==people_up-4) || 
                        (x==people_left+5 && y==people_up-4) || 
                        (x==people_left+6 && y==people_up-4) || 
                        (x==people_left+7 && y==people_up-4) || 
                        (x==people_left+8 && y==people_up-4) || 
                        (x==people_left+9 && y==people_up-4) || 
                        (x==people_left+10 && y==people_up-4) || 
                        (x==people_left+11 && y==people_up-4) || 
                        (x==people_left+12 && y==people_up-4) || 
                        (x==people_left+13 && y==people_up-4) || 
                        (x==people_left+14 && y==people_up-4) || 
                        (x==people_left+15 && y==people_up-4) || 
                        (x==people_left+16 && y==people_up-4) || 
                        (x==people_left+17 && y==people_up-4) || 
                        (x==people_left+18 && y==people_up-4) || 
                        (x==people_left+19 && y==people_up-4) || 
                        (x==people_left+20 && y==people_up-4) || 
                        (x==people_left+21 && y==people_up-4) || 
                        (x==people_left+22 && y==people_up-4) || 
                        (x==people_left+23 && y==people_up-4) || 
                        (x==people_left+24 && y==people_up-4) || 
                        (x==people_left+25 && y==people_up-4) || 
                        (x==people_left+26 && y==people_up-4) || 
                        (x==people_left+27 && y==people_up-4) || 
                        (x==people_left+28 && y==people_up-4) || 
                        (x==people_left+29 && y==people_up-4) || 
                        (x==people_left+30 && y==people_up-4) || 
                        (x==people_left+31 && y==people_up-4) || 
                        (x==people_left+32 && y==people_up-4) || 
                        (x==people_left+33 && y==people_up-4) || 
                        (x==people_left+34 && y==people_up-4) || 
                        (x==people_left+35 && y==people_up-4) || 
                        (x==people_left+36 && y==people_up-4) || 
                        (x==people_left+37 && y==people_up-4) || 
                        (x==people_left+38 && y==people_up-4) || 
                        (x==people_left+39 && y==people_up-4) || 
                        (x==people_left+40 && y==people_up-4) || 
                        (x==people_left+41 && y==people_up-4) || 
                        (x==people_left+42 && y==people_up-4) || 
                        (x==people_left+43 && y==people_up-4) || 
                        (x==people_left+44 && y==people_up-4) || 
                        (x==people_left+45 && y==people_up-4) || 
                        (x==people_left+46 && y==people_up-4) || 
                        (x==people_left+47 && y==people_up-4) || 
                        (x==people_left+48 && y==people_up-4) || 
                        (x==people_left+49 && y==people_up-4) || 
                        (x==people_left+50 && y==people_up-4) || 
                        (x==people_left+51 && y==people_up-4) || 
                        (x==people_left+52 && y==people_up-4) || 
                        (x==people_left+53 && y==people_up-4) || 
                        (x==people_left+54 && y==people_up-4) || 
                        (x==people_left+55 && y==people_up-4) || 
                        (x==people_left+56 && y==people_up-4) || 
                        (x==people_left+57 && y==people_up-4) || 
                        (x==people_left+58 && y==people_up-4) || 
                        (x==people_left+59 && y==people_up-4) || 
                        (x==people_left+60 && y==people_up-4) || 
                        (x==people_left+61 && y==people_up-4) || 
                        (x==people_left+62 && y==people_up-4) || 
                        (x==people_left+63 && y==people_up-4) || 
                        (x==people_left+64 && y==people_up-4) || 
                        (x==people_left+65 && y==people_up-4) || 
                        (x==people_left+66 && y==people_up-4) || 
                        (x==people_left+67 && y==people_up-4) || 
                        (x==people_left+68 && y==people_up-4) || 
                        (x==people_left+69 && y==people_up-4) || 
                        (x==people_left+70 && y==people_up-4) || 
                        (x==people_left+71 && y==people_up-4) || 
                        (x==people_left+72 && y==people_up-4) || 
                        (x==people_left+73 && y==people_up-4) || 
                        (x==people_left+74 && y==people_up-4) || 
                        (x==people_left-36 && y==people_up-3) || 
                        (x==people_left-35 && y==people_up-3) || 
                        (x==people_left-34 && y==people_up-3) || 
                        (x==people_left-33 && y==people_up-3) || 
                        (x==people_left-32 && y==people_up-3) || 
                        (x==people_left-31 && y==people_up-3) || 
                        (x==people_left-30 && y==people_up-3) || 
                        (x==people_left-29 && y==people_up-3) || 
                        (x==people_left-28 && y==people_up-3) || 
                        (x==people_left-27 && y==people_up-3) || 
                        (x==people_left-26 && y==people_up-3) || 
                        (x==people_left-25 && y==people_up-3) || 
                        (x==people_left-24 && y==people_up-3) || 
                        (x==people_left-23 && y==people_up-3) || 
                        (x==people_left-22 && y==people_up-3) || 
                        (x==people_left-21 && y==people_up-3) || 
                        (x==people_left-20 && y==people_up-3) || 
                        (x==people_left-19 && y==people_up-3) || 
                        (x==people_left-18 && y==people_up-3) || 
                        (x==people_left-17 && y==people_up-3) || 
                        (x==people_left-16 && y==people_up-3) || 
                        (x==people_left-15 && y==people_up-3) || 
                        (x==people_left-14 && y==people_up-3) || 
                        (x==people_left-13 && y==people_up-3) || 
                        (x==people_left-12 && y==people_up-3) || 
                        (x==people_left-11 && y==people_up-3) || 
                        (x==people_left-10 && y==people_up-3) || 
                        (x==people_left-9 && y==people_up-3) || 
                        (x==people_left-8 && y==people_up-3) || 
                        (x==people_left-7 && y==people_up-3) || 
                        (x==people_left-6 && y==people_up-3) || 
                        (x==people_left-5 && y==people_up-3) || 
                        (x==people_left-4 && y==people_up-3) || 
                        (x==people_left-3 && y==people_up-3) || 
                        (x==people_left-2 && y==people_up-3) || 
                        (x==people_left-1 && y==people_up-3) || 
                        (x==people_left+0 && y==people_up-3) || 
                        (x==people_left+1 && y==people_up-3) || 
                        (x==people_left+2 && y==people_up-3) || 
                        (x==people_left+3 && y==people_up-3) || 
                        (x==people_left+4 && y==people_up-3) || 
                        (x==people_left+5 && y==people_up-3) || 
                        (x==people_left+6 && y==people_up-3) || 
                        (x==people_left+7 && y==people_up-3) || 
                        (x==people_left+8 && y==people_up-3) || 
                        (x==people_left+9 && y==people_up-3) || 
                        (x==people_left+10 && y==people_up-3) || 
                        (x==people_left+11 && y==people_up-3) || 
                        (x==people_left+12 && y==people_up-3) || 
                        (x==people_left+13 && y==people_up-3) || 
                        (x==people_left+14 && y==people_up-3) || 
                        (x==people_left+15 && y==people_up-3) || 
                        (x==people_left+16 && y==people_up-3) || 
                        (x==people_left+17 && y==people_up-3) || 
                        (x==people_left+18 && y==people_up-3) || 
                        (x==people_left+19 && y==people_up-3) || 
                        (x==people_left+20 && y==people_up-3) || 
                        (x==people_left+21 && y==people_up-3) || 
                        (x==people_left+22 && y==people_up-3) || 
                        (x==people_left+23 && y==people_up-3) || 
                        (x==people_left+24 && y==people_up-3) || 
                        (x==people_left+25 && y==people_up-3) || 
                        (x==people_left+26 && y==people_up-3) || 
                        (x==people_left+27 && y==people_up-3) || 
                        (x==people_left+28 && y==people_up-3) || 
                        (x==people_left+29 && y==people_up-3) || 
                        (x==people_left+30 && y==people_up-3) || 
                        (x==people_left+31 && y==people_up-3) || 
                        (x==people_left+32 && y==people_up-3) || 
                        (x==people_left+33 && y==people_up-3) || 
                        (x==people_left+34 && y==people_up-3) || 
                        (x==people_left+35 && y==people_up-3) || 
                        (x==people_left+36 && y==people_up-3) || 
                        (x==people_left+37 && y==people_up-3) || 
                        (x==people_left+38 && y==people_up-3) || 
                        (x==people_left+39 && y==people_up-3) || 
                        (x==people_left+40 && y==people_up-3) || 
                        (x==people_left+41 && y==people_up-3) || 
                        (x==people_left+42 && y==people_up-3) || 
                        (x==people_left+43 && y==people_up-3) || 
                        (x==people_left+44 && y==people_up-3) || 
                        (x==people_left+45 && y==people_up-3) || 
                        (x==people_left+46 && y==people_up-3) || 
                        (x==people_left+47 && y==people_up-3) || 
                        (x==people_left+48 && y==people_up-3) || 
                        (x==people_left+49 && y==people_up-3) || 
                        (x==people_left+50 && y==people_up-3) || 
                        (x==people_left+51 && y==people_up-3) || 
                        (x==people_left+52 && y==people_up-3) || 
                        (x==people_left+53 && y==people_up-3) || 
                        (x==people_left+54 && y==people_up-3) || 
                        (x==people_left+55 && y==people_up-3) || 
                        (x==people_left+56 && y==people_up-3) || 
                        (x==people_left+57 && y==people_up-3) || 
                        (x==people_left+58 && y==people_up-3) || 
                        (x==people_left+59 && y==people_up-3) || 
                        (x==people_left+60 && y==people_up-3) || 
                        (x==people_left+61 && y==people_up-3) || 
                        (x==people_left+62 && y==people_up-3) || 
                        (x==people_left+63 && y==people_up-3) || 
                        (x==people_left+64 && y==people_up-3) || 
                        (x==people_left+65 && y==people_up-3) || 
                        (x==people_left+66 && y==people_up-3) || 
                        (x==people_left+67 && y==people_up-3) || 
                        (x==people_left+68 && y==people_up-3) || 
                        (x==people_left+69 && y==people_up-3) || 
                        (x==people_left+70 && y==people_up-3) || 
                        (x==people_left+71 && y==people_up-3) || 
                        (x==people_left+72 && y==people_up-3) || 
                        (x==people_left+73 && y==people_up-3) || 
                        (x==people_left+74 && y==people_up-3) || 
                        (x==people_left-36 && y==people_up-2) || 
                        (x==people_left-35 && y==people_up-2) || 
                        (x==people_left-34 && y==people_up-2) || 
                        (x==people_left-33 && y==people_up-2) || 
                        (x==people_left-32 && y==people_up-2) || 
                        (x==people_left-31 && y==people_up-2) || 
                        (x==people_left-30 && y==people_up-2) || 
                        (x==people_left-29 && y==people_up-2) || 
                        (x==people_left-28 && y==people_up-2) || 
                        (x==people_left-27 && y==people_up-2) || 
                        (x==people_left-26 && y==people_up-2) || 
                        (x==people_left-25 && y==people_up-2) || 
                        (x==people_left-24 && y==people_up-2) || 
                        (x==people_left-23 && y==people_up-2) || 
                        (x==people_left-22 && y==people_up-2) || 
                        (x==people_left-21 && y==people_up-2) || 
                        (x==people_left-20 && y==people_up-2) || 
                        (x==people_left-19 && y==people_up-2) || 
                        (x==people_left-18 && y==people_up-2) || 
                        (x==people_left-17 && y==people_up-2) || 
                        (x==people_left-16 && y==people_up-2) || 
                        (x==people_left-15 && y==people_up-2) || 
                        (x==people_left-14 && y==people_up-2) || 
                        (x==people_left-13 && y==people_up-2) || 
                        (x==people_left-12 && y==people_up-2) || 
                        (x==people_left-11 && y==people_up-2) || 
                        (x==people_left-10 && y==people_up-2) || 
                        (x==people_left-9 && y==people_up-2) || 
                        (x==people_left-8 && y==people_up-2) || 
                        (x==people_left-7 && y==people_up-2) || 
                        (x==people_left-6 && y==people_up-2) || 
                        (x==people_left-5 && y==people_up-2) || 
                        (x==people_left-4 && y==people_up-2) || 
                        (x==people_left-3 && y==people_up-2) || 
                        (x==people_left-2 && y==people_up-2) || 
                        (x==people_left-1 && y==people_up-2) || 
                        (x==people_left+0 && y==people_up-2) || 
                        (x==people_left+1 && y==people_up-2) || 
                        (x==people_left+2 && y==people_up-2) || 
                        (x==people_left+3 && y==people_up-2) || 
                        (x==people_left+4 && y==people_up-2) || 
                        (x==people_left+5 && y==people_up-2) || 
                        (x==people_left+6 && y==people_up-2) || 
                        (x==people_left+7 && y==people_up-2) || 
                        (x==people_left+8 && y==people_up-2) || 
                        (x==people_left+9 && y==people_up-2) || 
                        (x==people_left+10 && y==people_up-2) || 
                        (x==people_left+11 && y==people_up-2) || 
                        (x==people_left+12 && y==people_up-2) || 
                        (x==people_left+13 && y==people_up-2) || 
                        (x==people_left+14 && y==people_up-2) || 
                        (x==people_left+15 && y==people_up-2) || 
                        (x==people_left+16 && y==people_up-2) || 
                        (x==people_left+17 && y==people_up-2) || 
                        (x==people_left+18 && y==people_up-2) || 
                        (x==people_left+19 && y==people_up-2) || 
                        (x==people_left+20 && y==people_up-2) || 
                        (x==people_left+21 && y==people_up-2) || 
                        (x==people_left+22 && y==people_up-2) || 
                        (x==people_left+23 && y==people_up-2) || 
                        (x==people_left+24 && y==people_up-2) || 
                        (x==people_left+25 && y==people_up-2) || 
                        (x==people_left+26 && y==people_up-2) || 
                        (x==people_left+27 && y==people_up-2) || 
                        (x==people_left+28 && y==people_up-2) || 
                        (x==people_left+29 && y==people_up-2) || 
                        (x==people_left+30 && y==people_up-2) || 
                        (x==people_left+31 && y==people_up-2) || 
                        (x==people_left+32 && y==people_up-2) || 
                        (x==people_left+33 && y==people_up-2) || 
                        (x==people_left+34 && y==people_up-2) || 
                        (x==people_left+35 && y==people_up-2) || 
                        (x==people_left+36 && y==people_up-2) || 
                        (x==people_left+37 && y==people_up-2) || 
                        (x==people_left+38 && y==people_up-2) || 
                        (x==people_left+39 && y==people_up-2) || 
                        (x==people_left+40 && y==people_up-2) || 
                        (x==people_left+41 && y==people_up-2) || 
                        (x==people_left+42 && y==people_up-2) || 
                        (x==people_left+43 && y==people_up-2) || 
                        (x==people_left+44 && y==people_up-2) || 
                        (x==people_left+45 && y==people_up-2) || 
                        (x==people_left+46 && y==people_up-2) || 
                        (x==people_left+47 && y==people_up-2) || 
                        (x==people_left+48 && y==people_up-2) || 
                        (x==people_left+49 && y==people_up-2) || 
                        (x==people_left+50 && y==people_up-2) || 
                        (x==people_left+51 && y==people_up-2) || 
                        (x==people_left+52 && y==people_up-2) || 
                        (x==people_left+53 && y==people_up-2) || 
                        (x==people_left+54 && y==people_up-2) || 
                        (x==people_left+55 && y==people_up-2) || 
                        (x==people_left+56 && y==people_up-2) || 
                        (x==people_left+57 && y==people_up-2) || 
                        (x==people_left+58 && y==people_up-2) || 
                        (x==people_left+59 && y==people_up-2) || 
                        (x==people_left+60 && y==people_up-2) || 
                        (x==people_left+61 && y==people_up-2) || 
                        (x==people_left+62 && y==people_up-2) || 
                        (x==people_left+63 && y==people_up-2) || 
                        (x==people_left+64 && y==people_up-2) || 
                        (x==people_left+65 && y==people_up-2) || 
                        (x==people_left+66 && y==people_up-2) || 
                        (x==people_left+67 && y==people_up-2) || 
                        (x==people_left+68 && y==people_up-2) || 
                        (x==people_left+69 && y==people_up-2) || 
                        (x==people_left+70 && y==people_up-2) || 
                        (x==people_left+71 && y==people_up-2) || 
                        (x==people_left+72 && y==people_up-2) || 
                        (x==people_left+73 && y==people_up-2) || 
                        (x==people_left+74 && y==people_up-2) || 
                        (x==people_left-37 && y==people_up-1) || 
                        (x==people_left-36 && y==people_up-1) || 
                        (x==people_left-35 && y==people_up-1) || 
                        (x==people_left-34 && y==people_up-1) || 
                        (x==people_left-33 && y==people_up-1) || 
                        (x==people_left-32 && y==people_up-1) || 
                        (x==people_left-31 && y==people_up-1) || 
                        (x==people_left-30 && y==people_up-1) || 
                        (x==people_left-29 && y==people_up-1) || 
                        (x==people_left-28 && y==people_up-1) || 
                        (x==people_left-27 && y==people_up-1) || 
                        (x==people_left-26 && y==people_up-1) || 
                        (x==people_left-25 && y==people_up-1) || 
                        (x==people_left-24 && y==people_up-1) || 
                        (x==people_left-23 && y==people_up-1) || 
                        (x==people_left-22 && y==people_up-1) || 
                        (x==people_left-21 && y==people_up-1) || 
                        (x==people_left-20 && y==people_up-1) || 
                        (x==people_left-19 && y==people_up-1) || 
                        (x==people_left-18 && y==people_up-1) || 
                        (x==people_left-17 && y==people_up-1) || 
                        (x==people_left-16 && y==people_up-1) || 
                        (x==people_left-15 && y==people_up-1) || 
                        (x==people_left-14 && y==people_up-1) || 
                        (x==people_left-13 && y==people_up-1) || 
                        (x==people_left-12 && y==people_up-1) || 
                        (x==people_left-11 && y==people_up-1) || 
                        (x==people_left-10 && y==people_up-1) || 
                        (x==people_left-9 && y==people_up-1) || 
                        (x==people_left-8 && y==people_up-1) || 
                        (x==people_left-7 && y==people_up-1) || 
                        (x==people_left-6 && y==people_up-1) || 
                        (x==people_left-5 && y==people_up-1) || 
                        (x==people_left-4 && y==people_up-1) || 
                        (x==people_left-3 && y==people_up-1) || 
                        (x==people_left-2 && y==people_up-1) || 
                        (x==people_left-1 && y==people_up-1) || 
                        (x==people_left+0 && y==people_up-1) || 
                        (x==people_left+1 && y==people_up-1) || 
                        (x==people_left+2 && y==people_up-1) || 
                        (x==people_left+3 && y==people_up-1) || 
                        (x==people_left+4 && y==people_up-1) || 
                        (x==people_left+5 && y==people_up-1) || 
                        (x==people_left+6 && y==people_up-1) || 
                        (x==people_left+7 && y==people_up-1) || 
                        (x==people_left+8 && y==people_up-1) || 
                        (x==people_left+9 && y==people_up-1) || 
                        (x==people_left+10 && y==people_up-1) || 
                        (x==people_left+11 && y==people_up-1) || 
                        (x==people_left+12 && y==people_up-1) || 
                        (x==people_left+13 && y==people_up-1) || 
                        (x==people_left+14 && y==people_up-1) || 
                        (x==people_left+15 && y==people_up-1) || 
                        (x==people_left+16 && y==people_up-1) || 
                        (x==people_left+17 && y==people_up-1) || 
                        (x==people_left+18 && y==people_up-1) || 
                        (x==people_left+19 && y==people_up-1) || 
                        (x==people_left+20 && y==people_up-1) || 
                        (x==people_left+21 && y==people_up-1) || 
                        (x==people_left+22 && y==people_up-1) || 
                        (x==people_left+23 && y==people_up-1) || 
                        (x==people_left+24 && y==people_up-1) || 
                        (x==people_left+25 && y==people_up-1) || 
                        (x==people_left+26 && y==people_up-1) || 
                        (x==people_left+27 && y==people_up-1) || 
                        (x==people_left+28 && y==people_up-1) || 
                        (x==people_left+29 && y==people_up-1) || 
                        (x==people_left+30 && y==people_up-1) || 
                        (x==people_left+31 && y==people_up-1) || 
                        (x==people_left+32 && y==people_up-1) || 
                        (x==people_left+33 && y==people_up-1) || 
                        (x==people_left+34 && y==people_up-1) || 
                        (x==people_left+35 && y==people_up-1) || 
                        (x==people_left+36 && y==people_up-1) || 
                        (x==people_left+37 && y==people_up-1) || 
                        (x==people_left+38 && y==people_up-1) || 
                        (x==people_left+39 && y==people_up-1) || 
                        (x==people_left+40 && y==people_up-1) || 
                        (x==people_left+41 && y==people_up-1) || 
                        (x==people_left+42 && y==people_up-1) || 
                        (x==people_left+43 && y==people_up-1) || 
                        (x==people_left+44 && y==people_up-1) || 
                        (x==people_left+45 && y==people_up-1) || 
                        (x==people_left+46 && y==people_up-1) || 
                        (x==people_left+47 && y==people_up-1) || 
                        (x==people_left+48 && y==people_up-1) || 
                        (x==people_left+49 && y==people_up-1) || 
                        (x==people_left+50 && y==people_up-1) || 
                        (x==people_left+51 && y==people_up-1) || 
                        (x==people_left+52 && y==people_up-1) || 
                        (x==people_left+53 && y==people_up-1) || 
                        (x==people_left+54 && y==people_up-1) || 
                        (x==people_left+55 && y==people_up-1) || 
                        (x==people_left+56 && y==people_up-1) || 
                        (x==people_left+57 && y==people_up-1) || 
                        (x==people_left+58 && y==people_up-1) || 
                        (x==people_left+59 && y==people_up-1) || 
                        (x==people_left+60 && y==people_up-1) || 
                        (x==people_left+61 && y==people_up-1) || 
                        (x==people_left+62 && y==people_up-1) || 
                        (x==people_left+63 && y==people_up-1) || 
                        (x==people_left+64 && y==people_up-1) || 
                        (x==people_left+65 && y==people_up-1) || 
                        (x==people_left+66 && y==people_up-1) || 
                        (x==people_left+67 && y==people_up-1) || 
                        (x==people_left+68 && y==people_up-1) || 
                        (x==people_left+69 && y==people_up-1) || 
                        (x==people_left+70 && y==people_up-1) || 
                        (x==people_left+71 && y==people_up-1) || 
                        (x==people_left+72 && y==people_up-1) || 
                        (x==people_left+73 && y==people_up-1) || 
                        (x==people_left+74 && y==people_up-1) || 
                        (x==people_left+75 && y==people_up-1) || 
                        (x==people_left-37 && y==people_up+0) || 
                        (x==people_left-36 && y==people_up+0) || 
                        (x==people_left-35 && y==people_up+0) || 
                        (x==people_left-34 && y==people_up+0) || 
                        (x==people_left-33 && y==people_up+0) || 
                        (x==people_left-32 && y==people_up+0) || 
                        (x==people_left-31 && y==people_up+0) || 
                        (x==people_left-30 && y==people_up+0) || 
                        (x==people_left-29 && y==people_up+0) || 
                        (x==people_left-28 && y==people_up+0) || 
                        (x==people_left-27 && y==people_up+0) || 
                        (x==people_left-26 && y==people_up+0) || 
                        (x==people_left-25 && y==people_up+0) || 
                        (x==people_left-24 && y==people_up+0) || 
                        (x==people_left-23 && y==people_up+0) || 
                        (x==people_left-22 && y==people_up+0) || 
                        (x==people_left-21 && y==people_up+0) || 
                        (x==people_left-20 && y==people_up+0) || 
                        (x==people_left-19 && y==people_up+0) || 
                        (x==people_left-18 && y==people_up+0) || 
                        (x==people_left-17 && y==people_up+0) || 
                        (x==people_left-16 && y==people_up+0) || 
                        (x==people_left-15 && y==people_up+0) || 
                        (x==people_left-14 && y==people_up+0) || 
                        (x==people_left-13 && y==people_up+0) || 
                        (x==people_left-12 && y==people_up+0) || 
                        (x==people_left-11 && y==people_up+0) || 
                        (x==people_left-10 && y==people_up+0) || 
                        (x==people_left-9 && y==people_up+0) || 
                        (x==people_left-8 && y==people_up+0) || 
                        (x==people_left-7 && y==people_up+0) || 
                        (x==people_left-6 && y==people_up+0) || 
                        (x==people_left-5 && y==people_up+0) || 
                        (x==people_left-4 && y==people_up+0) || 
                        (x==people_left-3 && y==people_up+0) || 
                        (x==people_left-2 && y==people_up+0) || 
                        (x==people_left-1 && y==people_up+0) || 
                        (x==people_left+0 && y==people_up+0) || 
                        (x==people_left+1 && y==people_up+0) || 
                        (x==people_left+2 && y==people_up+0) || 
                        (x==people_left+3 && y==people_up+0) || 
                        (x==people_left+4 && y==people_up+0) || 
                        (x==people_left+5 && y==people_up+0) || 
                        (x==people_left+6 && y==people_up+0) || 
                        (x==people_left+7 && y==people_up+0) || 
                        (x==people_left+8 && y==people_up+0) || 
                        (x==people_left+9 && y==people_up+0) || 
                        (x==people_left+10 && y==people_up+0) || 
                        (x==people_left+11 && y==people_up+0) || 
                        (x==people_left+12 && y==people_up+0) || 
                        (x==people_left+13 && y==people_up+0) || 
                        (x==people_left+14 && y==people_up+0) || 
                        (x==people_left+15 && y==people_up+0) || 
                        (x==people_left+16 && y==people_up+0) || 
                        (x==people_left+17 && y==people_up+0) || 
                        (x==people_left+18 && y==people_up+0) || 
                        (x==people_left+19 && y==people_up+0) || 
                        (x==people_left+20 && y==people_up+0) || 
                        (x==people_left+21 && y==people_up+0) || 
                        (x==people_left+22 && y==people_up+0) || 
                        (x==people_left+23 && y==people_up+0) || 
                        (x==people_left+24 && y==people_up+0) || 
                        (x==people_left+25 && y==people_up+0) || 
                        (x==people_left+26 && y==people_up+0) || 
                        (x==people_left+27 && y==people_up+0) || 
                        (x==people_left+28 && y==people_up+0) || 
                        (x==people_left+29 && y==people_up+0) || 
                        (x==people_left+30 && y==people_up+0) || 
                        (x==people_left+31 && y==people_up+0) || 
                        (x==people_left+32 && y==people_up+0) || 
                        (x==people_left+33 && y==people_up+0) || 
                        (x==people_left+34 && y==people_up+0) || 
                        (x==people_left+35 && y==people_up+0) || 
                        (x==people_left+36 && y==people_up+0) || 
                        (x==people_left+37 && y==people_up+0) || 
                        (x==people_left+38 && y==people_up+0) || 
                        (x==people_left+39 && y==people_up+0) || 
                        (x==people_left+40 && y==people_up+0) || 
                        (x==people_left+41 && y==people_up+0) || 
                        (x==people_left+42 && y==people_up+0) || 
                        (x==people_left+43 && y==people_up+0) || 
                        (x==people_left+44 && y==people_up+0) || 
                        (x==people_left+45 && y==people_up+0) || 
                        (x==people_left+46 && y==people_up+0) || 
                        (x==people_left+47 && y==people_up+0) || 
                        (x==people_left+48 && y==people_up+0) || 
                        (x==people_left+49 && y==people_up+0) || 
                        (x==people_left+50 && y==people_up+0) || 
                        (x==people_left+51 && y==people_up+0) || 
                        (x==people_left+52 && y==people_up+0) || 
                        (x==people_left+53 && y==people_up+0) || 
                        (x==people_left+54 && y==people_up+0) || 
                        (x==people_left+55 && y==people_up+0) || 
                        (x==people_left+56 && y==people_up+0) || 
                        (x==people_left+57 && y==people_up+0) || 
                        (x==people_left+58 && y==people_up+0) || 
                        (x==people_left+59 && y==people_up+0) || 
                        (x==people_left+60 && y==people_up+0) || 
                        (x==people_left+61 && y==people_up+0) || 
                        (x==people_left+62 && y==people_up+0) || 
                        (x==people_left+63 && y==people_up+0) || 
                        (x==people_left+64 && y==people_up+0) || 
                        (x==people_left+65 && y==people_up+0) || 
                        (x==people_left+66 && y==people_up+0) || 
                        (x==people_left+67 && y==people_up+0) || 
                        (x==people_left+68 && y==people_up+0) || 
                        (x==people_left+69 && y==people_up+0) || 
                        (x==people_left+70 && y==people_up+0) || 
                        (x==people_left+71 && y==people_up+0) || 
                        (x==people_left+72 && y==people_up+0) || 
                        (x==people_left+73 && y==people_up+0) || 
                        (x==people_left+74 && y==people_up+0) || 
                        (x==people_left+75 && y==people_up+0) || 
                        (x==people_left-37 && y==people_up+1) || 
                        (x==people_left-36 && y==people_up+1) || 
                        (x==people_left-35 && y==people_up+1) || 
                        (x==people_left-34 && y==people_up+1) || 
                        (x==people_left-33 && y==people_up+1) || 
                        (x==people_left-32 && y==people_up+1) || 
                        (x==people_left-31 && y==people_up+1) || 
                        (x==people_left-30 && y==people_up+1) || 
                        (x==people_left-29 && y==people_up+1) || 
                        (x==people_left-28 && y==people_up+1) || 
                        (x==people_left-27 && y==people_up+1) || 
                        (x==people_left-26 && y==people_up+1) || 
                        (x==people_left-25 && y==people_up+1) || 
                        (x==people_left-24 && y==people_up+1) || 
                        (x==people_left-23 && y==people_up+1) || 
                        (x==people_left-22 && y==people_up+1) || 
                        (x==people_left-21 && y==people_up+1) || 
                        (x==people_left-20 && y==people_up+1) || 
                        (x==people_left-19 && y==people_up+1) || 
                        (x==people_left-18 && y==people_up+1) || 
                        (x==people_left-17 && y==people_up+1) || 
                        (x==people_left-16 && y==people_up+1) || 
                        (x==people_left-15 && y==people_up+1) || 
                        (x==people_left-14 && y==people_up+1) || 
                        (x==people_left-13 && y==people_up+1) || 
                        (x==people_left-12 && y==people_up+1) || 
                        (x==people_left-11 && y==people_up+1) || 
                        (x==people_left-10 && y==people_up+1) || 
                        (x==people_left-9 && y==people_up+1) || 
                        (x==people_left-8 && y==people_up+1) || 
                        (x==people_left-7 && y==people_up+1) || 
                        (x==people_left-6 && y==people_up+1) || 
                        (x==people_left-5 && y==people_up+1) || 
                        (x==people_left-4 && y==people_up+1) || 
                        (x==people_left-3 && y==people_up+1) || 
                        (x==people_left-2 && y==people_up+1) || 
                        (x==people_left-1 && y==people_up+1) || 
                        (x==people_left+0 && y==people_up+1) || 
                        (x==people_left+1 && y==people_up+1) || 
                        (x==people_left+2 && y==people_up+1) || 
                        (x==people_left+3 && y==people_up+1) || 
                        (x==people_left+4 && y==people_up+1) || 
                        (x==people_left+5 && y==people_up+1) || 
                        (x==people_left+6 && y==people_up+1) || 
                        (x==people_left+7 && y==people_up+1) || 
                        (x==people_left+8 && y==people_up+1) || 
                        (x==people_left+9 && y==people_up+1) || 
                        (x==people_left+10 && y==people_up+1) || 
                        (x==people_left+11 && y==people_up+1) || 
                        (x==people_left+12 && y==people_up+1) || 
                        (x==people_left+13 && y==people_up+1) || 
                        (x==people_left+14 && y==people_up+1) || 
                        (x==people_left+15 && y==people_up+1) || 
                        (x==people_left+16 && y==people_up+1) || 
                        (x==people_left+17 && y==people_up+1) || 
                        (x==people_left+18 && y==people_up+1) || 
                        (x==people_left+19 && y==people_up+1) || 
                        (x==people_left+20 && y==people_up+1) || 
                        (x==people_left+21 && y==people_up+1) || 
                        (x==people_left+22 && y==people_up+1) || 
                        (x==people_left+23 && y==people_up+1) || 
                        (x==people_left+24 && y==people_up+1) || 
                        (x==people_left+25 && y==people_up+1) || 
                        (x==people_left+26 && y==people_up+1) || 
                        (x==people_left+27 && y==people_up+1) || 
                        (x==people_left+28 && y==people_up+1) || 
                        (x==people_left+29 && y==people_up+1) || 
                        (x==people_left+30 && y==people_up+1) || 
                        (x==people_left+31 && y==people_up+1) || 
                        (x==people_left+32 && y==people_up+1) || 
                        (x==people_left+33 && y==people_up+1) || 
                        (x==people_left+34 && y==people_up+1) || 
                        (x==people_left+35 && y==people_up+1) || 
                        (x==people_left+36 && y==people_up+1) || 
                        (x==people_left+37 && y==people_up+1) || 
                        (x==people_left+38 && y==people_up+1) || 
                        (x==people_left+39 && y==people_up+1) || 
                        (x==people_left+40 && y==people_up+1) || 
                        (x==people_left+41 && y==people_up+1) || 
                        (x==people_left+42 && y==people_up+1) || 
                        (x==people_left+43 && y==people_up+1) || 
                        (x==people_left+44 && y==people_up+1) || 
                        (x==people_left+45 && y==people_up+1) || 
                        (x==people_left+46 && y==people_up+1) || 
                        (x==people_left+47 && y==people_up+1) || 
                        (x==people_left+48 && y==people_up+1) || 
                        (x==people_left+49 && y==people_up+1) || 
                        (x==people_left+50 && y==people_up+1) || 
                        (x==people_left+51 && y==people_up+1) || 
                        (x==people_left+52 && y==people_up+1) || 
                        (x==people_left+53 && y==people_up+1) || 
                        (x==people_left+54 && y==people_up+1) || 
                        (x==people_left+55 && y==people_up+1) || 
                        (x==people_left+56 && y==people_up+1) || 
                        (x==people_left+57 && y==people_up+1) || 
                        (x==people_left+58 && y==people_up+1) || 
                        (x==people_left+59 && y==people_up+1) || 
                        (x==people_left+60 && y==people_up+1) || 
                        (x==people_left+61 && y==people_up+1) || 
                        (x==people_left+62 && y==people_up+1) || 
                        (x==people_left+63 && y==people_up+1) || 
                        (x==people_left+64 && y==people_up+1) || 
                        (x==people_left+65 && y==people_up+1) || 
                        (x==people_left+66 && y==people_up+1) || 
                        (x==people_left+67 && y==people_up+1) || 
                        (x==people_left+68 && y==people_up+1) || 
                        (x==people_left+69 && y==people_up+1) || 
                        (x==people_left+70 && y==people_up+1) || 
                        (x==people_left+71 && y==people_up+1) || 
                        (x==people_left+72 && y==people_up+1) || 
                        (x==people_left+73 && y==people_up+1) || 
                        (x==people_left+74 && y==people_up+1) || 
                        (x==people_left+75 && y==people_up+1) || 
                        (x==people_left-38 && y==people_up+2) || 
                        (x==people_left-37 && y==people_up+2) || 
                        (x==people_left-36 && y==people_up+2) || 
                        (x==people_left-35 && y==people_up+2) || 
                        (x==people_left-34 && y==people_up+2) || 
                        (x==people_left-33 && y==people_up+2) || 
                        (x==people_left-32 && y==people_up+2) || 
                        (x==people_left-31 && y==people_up+2) || 
                        (x==people_left-30 && y==people_up+2) || 
                        (x==people_left-29 && y==people_up+2) || 
                        (x==people_left-28 && y==people_up+2) || 
                        (x==people_left-27 && y==people_up+2) || 
                        (x==people_left-26 && y==people_up+2) || 
                        (x==people_left-25 && y==people_up+2) || 
                        (x==people_left-24 && y==people_up+2) || 
                        (x==people_left-23 && y==people_up+2) || 
                        (x==people_left-22 && y==people_up+2) || 
                        (x==people_left-21 && y==people_up+2) || 
                        (x==people_left-20 && y==people_up+2) || 
                        (x==people_left-19 && y==people_up+2) || 
                        (x==people_left-18 && y==people_up+2) || 
                        (x==people_left-17 && y==people_up+2) || 
                        (x==people_left-16 && y==people_up+2) || 
                        (x==people_left-15 && y==people_up+2) || 
                        (x==people_left-14 && y==people_up+2) || 
                        (x==people_left-13 && y==people_up+2) || 
                        (x==people_left-12 && y==people_up+2) || 
                        (x==people_left-11 && y==people_up+2) || 
                        (x==people_left-10 && y==people_up+2) || 
                        (x==people_left-9 && y==people_up+2) || 
                        (x==people_left-8 && y==people_up+2) || 
                        (x==people_left-7 && y==people_up+2) || 
                        (x==people_left-6 && y==people_up+2) || 
                        (x==people_left-5 && y==people_up+2) || 
                        (x==people_left-4 && y==people_up+2) || 
                        (x==people_left-3 && y==people_up+2) || 
                        (x==people_left-2 && y==people_up+2) || 
                        (x==people_left-1 && y==people_up+2) || 
                        (x==people_left+0 && y==people_up+2) || 
                        (x==people_left+1 && y==people_up+2) || 
                        (x==people_left+2 && y==people_up+2) || 
                        (x==people_left+3 && y==people_up+2) || 
                        (x==people_left+4 && y==people_up+2) || 
                        (x==people_left+5 && y==people_up+2) || 
                        (x==people_left+6 && y==people_up+2) || 
                        (x==people_left+7 && y==people_up+2) || 
                        (x==people_left+8 && y==people_up+2) || 
                        (x==people_left+9 && y==people_up+2) || 
                        (x==people_left+10 && y==people_up+2) || 
                        (x==people_left+11 && y==people_up+2) || 
                        (x==people_left+12 && y==people_up+2) || 
                        (x==people_left+13 && y==people_up+2) || 
                        (x==people_left+14 && y==people_up+2) || 
                        (x==people_left+15 && y==people_up+2) || 
                        (x==people_left+16 && y==people_up+2) || 
                        (x==people_left+17 && y==people_up+2) || 
                        (x==people_left+18 && y==people_up+2) || 
                        (x==people_left+19 && y==people_up+2) || 
                        (x==people_left+20 && y==people_up+2) || 
                        (x==people_left+21 && y==people_up+2) || 
                        (x==people_left+22 && y==people_up+2) || 
                        (x==people_left+23 && y==people_up+2) || 
                        (x==people_left+24 && y==people_up+2) || 
                        (x==people_left+25 && y==people_up+2) || 
                        (x==people_left+26 && y==people_up+2) || 
                        (x==people_left+27 && y==people_up+2) || 
                        (x==people_left+28 && y==people_up+2) || 
                        (x==people_left+29 && y==people_up+2) || 
                        (x==people_left+30 && y==people_up+2) || 
                        (x==people_left+31 && y==people_up+2) || 
                        (x==people_left+32 && y==people_up+2) || 
                        (x==people_left+33 && y==people_up+2) || 
                        (x==people_left+34 && y==people_up+2) || 
                        (x==people_left+35 && y==people_up+2) || 
                        (x==people_left+36 && y==people_up+2) || 
                        (x==people_left+37 && y==people_up+2) || 
                        (x==people_left+38 && y==people_up+2) || 
                        (x==people_left+39 && y==people_up+2) || 
                        (x==people_left+40 && y==people_up+2) || 
                        (x==people_left+41 && y==people_up+2) || 
                        (x==people_left+42 && y==people_up+2) || 
                        (x==people_left+43 && y==people_up+2) || 
                        (x==people_left+44 && y==people_up+2) || 
                        (x==people_left+45 && y==people_up+2) || 
                        (x==people_left+46 && y==people_up+2) || 
                        (x==people_left+47 && y==people_up+2) || 
                        (x==people_left+48 && y==people_up+2) || 
                        (x==people_left+49 && y==people_up+2) || 
                        (x==people_left+50 && y==people_up+2) || 
                        (x==people_left+51 && y==people_up+2) || 
                        (x==people_left+52 && y==people_up+2) || 
                        (x==people_left+53 && y==people_up+2) || 
                        (x==people_left+54 && y==people_up+2) || 
                        (x==people_left+55 && y==people_up+2) || 
                        (x==people_left+56 && y==people_up+2) || 
                        (x==people_left+57 && y==people_up+2) || 
                        (x==people_left+58 && y==people_up+2) || 
                        (x==people_left+59 && y==people_up+2) || 
                        (x==people_left+60 && y==people_up+2) || 
                        (x==people_left+61 && y==people_up+2) || 
                        (x==people_left+62 && y==people_up+2) || 
                        (x==people_left+63 && y==people_up+2) || 
                        (x==people_left+64 && y==people_up+2) || 
                        (x==people_left+65 && y==people_up+2) || 
                        (x==people_left+66 && y==people_up+2) || 
                        (x==people_left+67 && y==people_up+2) || 
                        (x==people_left+68 && y==people_up+2) || 
                        (x==people_left+69 && y==people_up+2) || 
                        (x==people_left+70 && y==people_up+2) || 
                        (x==people_left+71 && y==people_up+2) || 
                        (x==people_left+72 && y==people_up+2) || 
                        (x==people_left+73 && y==people_up+2) || 
                        (x==people_left+74 && y==people_up+2) || 
                        (x==people_left+75 && y==people_up+2) || 
                        (x==people_left+76 && y==people_up+2) || 
                        (x==people_left-38 && y==people_up+3) || 
                        (x==people_left-37 && y==people_up+3) || 
                        (x==people_left-36 && y==people_up+3) || 
                        (x==people_left-35 && y==people_up+3) || 
                        (x==people_left-34 && y==people_up+3) || 
                        (x==people_left-33 && y==people_up+3) || 
                        (x==people_left-32 && y==people_up+3) || 
                        (x==people_left-31 && y==people_up+3) || 
                        (x==people_left-30 && y==people_up+3) || 
                        (x==people_left-29 && y==people_up+3) || 
                        (x==people_left-28 && y==people_up+3) || 
                        (x==people_left-27 && y==people_up+3) || 
                        (x==people_left-26 && y==people_up+3) || 
                        (x==people_left-25 && y==people_up+3) || 
                        (x==people_left-24 && y==people_up+3) || 
                        (x==people_left-23 && y==people_up+3) || 
                        (x==people_left-22 && y==people_up+3) || 
                        (x==people_left-21 && y==people_up+3) || 
                        (x==people_left-20 && y==people_up+3) || 
                        (x==people_left-19 && y==people_up+3) || 
                        (x==people_left-18 && y==people_up+3) || 
                        (x==people_left-17 && y==people_up+3) || 
                        (x==people_left-16 && y==people_up+3) || 
                        (x==people_left-15 && y==people_up+3) || 
                        (x==people_left-14 && y==people_up+3) || 
                        (x==people_left-13 && y==people_up+3) || 
                        (x==people_left-12 && y==people_up+3) || 
                        (x==people_left-11 && y==people_up+3) || 
                        (x==people_left-10 && y==people_up+3) || 
                        (x==people_left-9 && y==people_up+3) || 
                        (x==people_left-8 && y==people_up+3) || 
                        (x==people_left-7 && y==people_up+3) || 
                        (x==people_left-6 && y==people_up+3) || 
                        (x==people_left-5 && y==people_up+3) || 
                        (x==people_left-4 && y==people_up+3) || 
                        (x==people_left-3 && y==people_up+3) || 
                        (x==people_left-2 && y==people_up+3) || 
                        (x==people_left-1 && y==people_up+3) || 
                        (x==people_left+0 && y==people_up+3) || 
                        (x==people_left+1 && y==people_up+3) || 
                        (x==people_left+2 && y==people_up+3) || 
                        (x==people_left+3 && y==people_up+3) || 
                        (x==people_left+4 && y==people_up+3) || 
                        (x==people_left+5 && y==people_up+3) || 
                        (x==people_left+6 && y==people_up+3) || 
                        (x==people_left+7 && y==people_up+3) || 
                        (x==people_left+8 && y==people_up+3) || 
                        (x==people_left+9 && y==people_up+3) || 
                        (x==people_left+10 && y==people_up+3) || 
                        (x==people_left+11 && y==people_up+3) || 
                        (x==people_left+12 && y==people_up+3) || 
                        (x==people_left+13 && y==people_up+3) || 
                        (x==people_left+14 && y==people_up+3) || 
                        (x==people_left+15 && y==people_up+3) || 
                        (x==people_left+16 && y==people_up+3) || 
                        (x==people_left+17 && y==people_up+3) || 
                        (x==people_left+18 && y==people_up+3) || 
                        (x==people_left+19 && y==people_up+3) || 
                        (x==people_left+20 && y==people_up+3) || 
                        (x==people_left+21 && y==people_up+3) || 
                        (x==people_left+22 && y==people_up+3) || 
                        (x==people_left+23 && y==people_up+3) || 
                        (x==people_left+24 && y==people_up+3) || 
                        (x==people_left+25 && y==people_up+3) || 
                        (x==people_left+26 && y==people_up+3) || 
                        (x==people_left+27 && y==people_up+3) || 
                        (x==people_left+28 && y==people_up+3) || 
                        (x==people_left+29 && y==people_up+3) || 
                        (x==people_left+30 && y==people_up+3) || 
                        (x==people_left+31 && y==people_up+3) || 
                        (x==people_left+32 && y==people_up+3) || 
                        (x==people_left+33 && y==people_up+3) || 
                        (x==people_left+34 && y==people_up+3) || 
                        (x==people_left+35 && y==people_up+3) || 
                        (x==people_left+36 && y==people_up+3) || 
                        (x==people_left+37 && y==people_up+3) || 
                        (x==people_left+38 && y==people_up+3) || 
                        (x==people_left+39 && y==people_up+3) || 
                        (x==people_left+40 && y==people_up+3) || 
                        (x==people_left+41 && y==people_up+3) || 
                        (x==people_left+42 && y==people_up+3) || 
                        (x==people_left+43 && y==people_up+3) || 
                        (x==people_left+44 && y==people_up+3) || 
                        (x==people_left+45 && y==people_up+3) || 
                        (x==people_left+46 && y==people_up+3) || 
                        (x==people_left+47 && y==people_up+3) || 
                        (x==people_left+48 && y==people_up+3) || 
                        (x==people_left+49 && y==people_up+3) || 
                        (x==people_left+50 && y==people_up+3) || 
                        (x==people_left+51 && y==people_up+3) || 
                        (x==people_left+52 && y==people_up+3) || 
                        (x==people_left+53 && y==people_up+3) || 
                        (x==people_left+54 && y==people_up+3) || 
                        (x==people_left+55 && y==people_up+3) || 
                        (x==people_left+56 && y==people_up+3) || 
                        (x==people_left+57 && y==people_up+3) || 
                        (x==people_left+58 && y==people_up+3) || 
                        (x==people_left+59 && y==people_up+3) || 
                        (x==people_left+60 && y==people_up+3) || 
                        (x==people_left+61 && y==people_up+3) || 
                        (x==people_left+62 && y==people_up+3) || 
                        (x==people_left+63 && y==people_up+3) || 
                        (x==people_left+64 && y==people_up+3) || 
                        (x==people_left+65 && y==people_up+3) || 
                        (x==people_left+66 && y==people_up+3) || 
                        (x==people_left+67 && y==people_up+3) || 
                        (x==people_left+68 && y==people_up+3) || 
                        (x==people_left+69 && y==people_up+3) || 
                        (x==people_left+70 && y==people_up+3) || 
                        (x==people_left+71 && y==people_up+3) || 
                        (x==people_left+72 && y==people_up+3) || 
                        (x==people_left+73 && y==people_up+3) || 
                        (x==people_left+74 && y==people_up+3) || 
                        (x==people_left+75 && y==people_up+3) || 
                        (x==people_left+76 && y==people_up+3) || 
                        (x==people_left-38 && y==people_up+4) || 
                        (x==people_left-37 && y==people_up+4) || 
                        (x==people_left-36 && y==people_up+4) || 
                        (x==people_left-35 && y==people_up+4) || 
                        (x==people_left-34 && y==people_up+4) || 
                        (x==people_left-33 && y==people_up+4) || 
                        (x==people_left-32 && y==people_up+4) || 
                        (x==people_left-31 && y==people_up+4) || 
                        (x==people_left-30 && y==people_up+4) || 
                        (x==people_left-29 && y==people_up+4) || 
                        (x==people_left-28 && y==people_up+4) || 
                        (x==people_left-27 && y==people_up+4) || 
                        (x==people_left-26 && y==people_up+4) || 
                        (x==people_left-25 && y==people_up+4) || 
                        (x==people_left-24 && y==people_up+4) || 
                        (x==people_left-23 && y==people_up+4) || 
                        (x==people_left-22 && y==people_up+4) || 
                        (x==people_left-21 && y==people_up+4) || 
                        (x==people_left-20 && y==people_up+4) || 
                        (x==people_left-19 && y==people_up+4) || 
                        (x==people_left-18 && y==people_up+4) || 
                        (x==people_left-17 && y==people_up+4) || 
                        (x==people_left-16 && y==people_up+4) || 
                        (x==people_left-15 && y==people_up+4) || 
                        (x==people_left-14 && y==people_up+4) || 
                        (x==people_left-13 && y==people_up+4) || 
                        (x==people_left-12 && y==people_up+4) || 
                        (x==people_left-11 && y==people_up+4) || 
                        (x==people_left-10 && y==people_up+4) || 
                        (x==people_left-9 && y==people_up+4) || 
                        (x==people_left-8 && y==people_up+4) || 
                        (x==people_left-7 && y==people_up+4) || 
                        (x==people_left-6 && y==people_up+4) || 
                        (x==people_left-5 && y==people_up+4) || 
                        (x==people_left-4 && y==people_up+4) || 
                        (x==people_left-3 && y==people_up+4) || 
                        (x==people_left-2 && y==people_up+4) || 
                        (x==people_left-1 && y==people_up+4) || 
                        (x==people_left+0 && y==people_up+4) || 
                        (x==people_left+1 && y==people_up+4) || 
                        (x==people_left+2 && y==people_up+4) || 
                        (x==people_left+3 && y==people_up+4) || 
                        (x==people_left+4 && y==people_up+4) || 
                        (x==people_left+5 && y==people_up+4) || 
                        (x==people_left+6 && y==people_up+4) || 
                        (x==people_left+7 && y==people_up+4) || 
                        (x==people_left+8 && y==people_up+4) || 
                        (x==people_left+9 && y==people_up+4) || 
                        (x==people_left+10 && y==people_up+4) || 
                        (x==people_left+11 && y==people_up+4) || 
                        (x==people_left+12 && y==people_up+4) || 
                        (x==people_left+13 && y==people_up+4) || 
                        (x==people_left+14 && y==people_up+4) || 
                        (x==people_left+15 && y==people_up+4) || 
                        (x==people_left+16 && y==people_up+4) || 
                        (x==people_left+17 && y==people_up+4) || 
                        (x==people_left+18 && y==people_up+4) || 
                        (x==people_left+19 && y==people_up+4) || 
                        (x==people_left+20 && y==people_up+4) || 
                        (x==people_left+21 && y==people_up+4) || 
                        (x==people_left+22 && y==people_up+4) || 
                        (x==people_left+23 && y==people_up+4) || 
                        (x==people_left+24 && y==people_up+4) || 
                        (x==people_left+25 && y==people_up+4) || 
                        (x==people_left+26 && y==people_up+4) || 
                        (x==people_left+27 && y==people_up+4) || 
                        (x==people_left+28 && y==people_up+4) || 
                        (x==people_left+29 && y==people_up+4) || 
                        (x==people_left+30 && y==people_up+4) || 
                        (x==people_left+31 && y==people_up+4) || 
                        (x==people_left+32 && y==people_up+4) || 
                        (x==people_left+33 && y==people_up+4) || 
                        (x==people_left+34 && y==people_up+4) || 
                        (x==people_left+35 && y==people_up+4) || 
                        (x==people_left+36 && y==people_up+4) || 
                        (x==people_left+37 && y==people_up+4) || 
                        (x==people_left+38 && y==people_up+4) || 
                        (x==people_left+39 && y==people_up+4) || 
                        (x==people_left+40 && y==people_up+4) || 
                        (x==people_left+41 && y==people_up+4) || 
                        (x==people_left+42 && y==people_up+4) || 
                        (x==people_left+43 && y==people_up+4) || 
                        (x==people_left+44 && y==people_up+4) || 
                        (x==people_left+45 && y==people_up+4) || 
                        (x==people_left+46 && y==people_up+4) || 
                        (x==people_left+47 && y==people_up+4) || 
                        (x==people_left+48 && y==people_up+4) || 
                        (x==people_left+49 && y==people_up+4) || 
                        (x==people_left+50 && y==people_up+4) || 
                        (x==people_left+51 && y==people_up+4) || 
                        (x==people_left+52 && y==people_up+4) || 
                        (x==people_left+53 && y==people_up+4) || 
                        (x==people_left+54 && y==people_up+4) || 
                        (x==people_left+55 && y==people_up+4) || 
                        (x==people_left+56 && y==people_up+4) || 
                        (x==people_left+57 && y==people_up+4) || 
                        (x==people_left+58 && y==people_up+4) || 
                        (x==people_left+59 && y==people_up+4) || 
                        (x==people_left+60 && y==people_up+4) || 
                        (x==people_left+61 && y==people_up+4) || 
                        (x==people_left+62 && y==people_up+4) || 
                        (x==people_left+63 && y==people_up+4) || 
                        (x==people_left+64 && y==people_up+4) || 
                        (x==people_left+65 && y==people_up+4) || 
                        (x==people_left+66 && y==people_up+4) || 
                        (x==people_left+67 && y==people_up+4) || 
                        (x==people_left+68 && y==people_up+4) || 
                        (x==people_left+69 && y==people_up+4) || 
                        (x==people_left+70 && y==people_up+4) || 
                        (x==people_left+71 && y==people_up+4) || 
                        (x==people_left+72 && y==people_up+4) || 
                        (x==people_left+73 && y==people_up+4) || 
                        (x==people_left+74 && y==people_up+4) || 
                        (x==people_left+75 && y==people_up+4) || 
                        (x==people_left+76 && y==people_up+4) || 
                        (x==people_left-38 && y==people_up+5) || 
                        (x==people_left-37 && y==people_up+5) || 
                        (x==people_left-36 && y==people_up+5) || 
                        (x==people_left-35 && y==people_up+5) || 
                        (x==people_left-34 && y==people_up+5) || 
                        (x==people_left-33 && y==people_up+5) || 
                        (x==people_left-32 && y==people_up+5) || 
                        (x==people_left-31 && y==people_up+5) || 
                        (x==people_left-30 && y==people_up+5) || 
                        (x==people_left-29 && y==people_up+5) || 
                        (x==people_left-28 && y==people_up+5) || 
                        (x==people_left-27 && y==people_up+5) || 
                        (x==people_left-26 && y==people_up+5) || 
                        (x==people_left-25 && y==people_up+5) || 
                        (x==people_left-24 && y==people_up+5) || 
                        (x==people_left-23 && y==people_up+5) || 
                        (x==people_left-22 && y==people_up+5) || 
                        (x==people_left-21 && y==people_up+5) || 
                        (x==people_left-20 && y==people_up+5) || 
                        (x==people_left-19 && y==people_up+5) || 
                        (x==people_left-18 && y==people_up+5) || 
                        (x==people_left-17 && y==people_up+5) || 
                        (x==people_left-16 && y==people_up+5) || 
                        (x==people_left-15 && y==people_up+5) || 
                        (x==people_left-14 && y==people_up+5) || 
                        (x==people_left-13 && y==people_up+5) || 
                        (x==people_left-12 && y==people_up+5) || 
                        (x==people_left-11 && y==people_up+5) || 
                        (x==people_left-10 && y==people_up+5) || 
                        (x==people_left-9 && y==people_up+5) || 
                        (x==people_left-8 && y==people_up+5) || 
                        (x==people_left-7 && y==people_up+5) || 
                        (x==people_left-6 && y==people_up+5) || 
                        (x==people_left-5 && y==people_up+5) || 
                        (x==people_left-4 && y==people_up+5) || 
                        (x==people_left-3 && y==people_up+5) || 
                        (x==people_left-2 && y==people_up+5) || 
                        (x==people_left-1 && y==people_up+5) || 
                        (x==people_left+0 && y==people_up+5) || 
                        (x==people_left+1 && y==people_up+5) || 
                        (x==people_left+2 && y==people_up+5) || 
                        (x==people_left+3 && y==people_up+5) || 
                        (x==people_left+4 && y==people_up+5) || 
                        (x==people_left+5 && y==people_up+5) || 
                        (x==people_left+6 && y==people_up+5) || 
                        (x==people_left+7 && y==people_up+5) || 
                        (x==people_left+8 && y==people_up+5) || 
                        (x==people_left+9 && y==people_up+5) || 
                        (x==people_left+10 && y==people_up+5) || 
                        (x==people_left+11 && y==people_up+5) || 
                        (x==people_left+12 && y==people_up+5) || 
                        (x==people_left+13 && y==people_up+5) || 
                        (x==people_left+14 && y==people_up+5) || 
                        (x==people_left+15 && y==people_up+5) || 
                        (x==people_left+16 && y==people_up+5) || 
                        (x==people_left+17 && y==people_up+5) || 
                        (x==people_left+18 && y==people_up+5) || 
                        (x==people_left+19 && y==people_up+5) || 
                        (x==people_left+20 && y==people_up+5) || 
                        (x==people_left+21 && y==people_up+5) || 
                        (x==people_left+22 && y==people_up+5) || 
                        (x==people_left+23 && y==people_up+5) || 
                        (x==people_left+24 && y==people_up+5) || 
                        (x==people_left+25 && y==people_up+5) || 
                        (x==people_left+26 && y==people_up+5) || 
                        (x==people_left+27 && y==people_up+5) || 
                        (x==people_left+28 && y==people_up+5) || 
                        (x==people_left+29 && y==people_up+5) || 
                        (x==people_left+30 && y==people_up+5) || 
                        (x==people_left+31 && y==people_up+5) || 
                        (x==people_left+32 && y==people_up+5) || 
                        (x==people_left+33 && y==people_up+5) || 
                        (x==people_left+34 && y==people_up+5) || 
                        (x==people_left+35 && y==people_up+5) || 
                        (x==people_left+36 && y==people_up+5) || 
                        (x==people_left+37 && y==people_up+5) || 
                        (x==people_left+38 && y==people_up+5) || 
                        (x==people_left+39 && y==people_up+5) || 
                        (x==people_left+40 && y==people_up+5) || 
                        (x==people_left+41 && y==people_up+5) || 
                        (x==people_left+42 && y==people_up+5) || 
                        (x==people_left+43 && y==people_up+5) || 
                        (x==people_left+44 && y==people_up+5) || 
                        (x==people_left+45 && y==people_up+5) || 
                        (x==people_left+46 && y==people_up+5) || 
                        (x==people_left+47 && y==people_up+5) || 
                        (x==people_left+48 && y==people_up+5) || 
                        (x==people_left+49 && y==people_up+5) || 
                        (x==people_left+50 && y==people_up+5) || 
                        (x==people_left+51 && y==people_up+5) || 
                        (x==people_left+52 && y==people_up+5) || 
                        (x==people_left+53 && y==people_up+5) || 
                        (x==people_left+54 && y==people_up+5) || 
                        (x==people_left+55 && y==people_up+5) || 
                        (x==people_left+56 && y==people_up+5) || 
                        (x==people_left+57 && y==people_up+5) || 
                        (x==people_left+58 && y==people_up+5) || 
                        (x==people_left+59 && y==people_up+5) || 
                        (x==people_left+60 && y==people_up+5) || 
                        (x==people_left+61 && y==people_up+5) || 
                        (x==people_left+62 && y==people_up+5) || 
                        (x==people_left+63 && y==people_up+5) || 
                        (x==people_left+64 && y==people_up+5) || 
                        (x==people_left+65 && y==people_up+5) || 
                        (x==people_left+66 && y==people_up+5) || 
                        (x==people_left+67 && y==people_up+5) || 
                        (x==people_left+68 && y==people_up+5) || 
                        (x==people_left+69 && y==people_up+5) || 
                        (x==people_left+70 && y==people_up+5) || 
                        (x==people_left+71 && y==people_up+5) || 
                        (x==people_left+72 && y==people_up+5) || 
                        (x==people_left+73 && y==people_up+5) || 
                        (x==people_left+74 && y==people_up+5) || 
                        (x==people_left+75 && y==people_up+5) || 
                        (x==people_left+76 && y==people_up+5) || 
                        (x==people_left-39 && y==people_up+6) || 
                        (x==people_left-38 && y==people_up+6) || 
                        (x==people_left-37 && y==people_up+6) || 
                        (x==people_left-36 && y==people_up+6) || 
                        (x==people_left-35 && y==people_up+6) || 
                        (x==people_left-34 && y==people_up+6) || 
                        (x==people_left-33 && y==people_up+6) || 
                        (x==people_left-32 && y==people_up+6) || 
                        (x==people_left-31 && y==people_up+6) || 
                        (x==people_left-30 && y==people_up+6) || 
                        (x==people_left-29 && y==people_up+6) || 
                        (x==people_left-28 && y==people_up+6) || 
                        (x==people_left-27 && y==people_up+6) || 
                        (x==people_left-26 && y==people_up+6) || 
                        (x==people_left-25 && y==people_up+6) || 
                        (x==people_left-24 && y==people_up+6) || 
                        (x==people_left-23 && y==people_up+6) || 
                        (x==people_left-22 && y==people_up+6) || 
                        (x==people_left-21 && y==people_up+6) || 
                        (x==people_left-20 && y==people_up+6) || 
                        (x==people_left-19 && y==people_up+6) || 
                        (x==people_left-18 && y==people_up+6) || 
                        (x==people_left-17 && y==people_up+6) || 
                        (x==people_left-16 && y==people_up+6) || 
                        (x==people_left-15 && y==people_up+6) || 
                        (x==people_left-14 && y==people_up+6) || 
                        (x==people_left-13 && y==people_up+6) || 
                        (x==people_left-12 && y==people_up+6) || 
                        (x==people_left-11 && y==people_up+6) || 
                        (x==people_left-10 && y==people_up+6) || 
                        (x==people_left-9 && y==people_up+6) || 
                        (x==people_left-8 && y==people_up+6) || 
                        (x==people_left-7 && y==people_up+6) || 
                        (x==people_left-6 && y==people_up+6) || 
                        (x==people_left-5 && y==people_up+6) || 
                        (x==people_left-4 && y==people_up+6) || 
                        (x==people_left-3 && y==people_up+6) || 
                        (x==people_left-2 && y==people_up+6) || 
                        (x==people_left-1 && y==people_up+6) || 
                        (x==people_left+0 && y==people_up+6) || 
                        (x==people_left+1 && y==people_up+6) || 
                        (x==people_left+2 && y==people_up+6) || 
                        (x==people_left+3 && y==people_up+6) || 
                        (x==people_left+4 && y==people_up+6) || 
                        (x==people_left+5 && y==people_up+6) || 
                        (x==people_left+6 && y==people_up+6) || 
                        (x==people_left+7 && y==people_up+6) || 
                        (x==people_left+8 && y==people_up+6) || 
                        (x==people_left+9 && y==people_up+6) || 
                        (x==people_left+10 && y==people_up+6) || 
                        (x==people_left+11 && y==people_up+6) || 
                        (x==people_left+12 && y==people_up+6) || 
                        (x==people_left+13 && y==people_up+6) || 
                        (x==people_left+14 && y==people_up+6) || 
                        (x==people_left+15 && y==people_up+6) || 
                        (x==people_left+16 && y==people_up+6) || 
                        (x==people_left+17 && y==people_up+6) || 
                        (x==people_left+18 && y==people_up+6) || 
                        (x==people_left+19 && y==people_up+6) || 
                        (x==people_left+20 && y==people_up+6) || 
                        (x==people_left+21 && y==people_up+6) || 
                        (x==people_left+22 && y==people_up+6) || 
                        (x==people_left+23 && y==people_up+6) || 
                        (x==people_left+24 && y==people_up+6) || 
                        (x==people_left+25 && y==people_up+6) || 
                        (x==people_left+26 && y==people_up+6) || 
                        (x==people_left+27 && y==people_up+6) || 
                        (x==people_left+28 && y==people_up+6) || 
                        (x==people_left+29 && y==people_up+6) || 
                        (x==people_left+30 && y==people_up+6) || 
                        (x==people_left+31 && y==people_up+6) || 
                        (x==people_left+32 && y==people_up+6) || 
                        (x==people_left+33 && y==people_up+6) || 
                        (x==people_left+34 && y==people_up+6) || 
                        (x==people_left+35 && y==people_up+6) || 
                        (x==people_left+36 && y==people_up+6) || 
                        (x==people_left+37 && y==people_up+6) || 
                        (x==people_left+38 && y==people_up+6) || 
                        (x==people_left+39 && y==people_up+6) || 
                        (x==people_left+40 && y==people_up+6) || 
                        (x==people_left+41 && y==people_up+6) || 
                        (x==people_left+42 && y==people_up+6) || 
                        (x==people_left+43 && y==people_up+6) || 
                        (x==people_left+44 && y==people_up+6) || 
                        (x==people_left+45 && y==people_up+6) || 
                        (x==people_left+46 && y==people_up+6) || 
                        (x==people_left+47 && y==people_up+6) || 
                        (x==people_left+48 && y==people_up+6) || 
                        (x==people_left+49 && y==people_up+6) || 
                        (x==people_left+50 && y==people_up+6) || 
                        (x==people_left+51 && y==people_up+6) || 
                        (x==people_left+52 && y==people_up+6) || 
                        (x==people_left+53 && y==people_up+6) || 
                        (x==people_left+54 && y==people_up+6) || 
                        (x==people_left+55 && y==people_up+6) || 
                        (x==people_left+56 && y==people_up+6) || 
                        (x==people_left+57 && y==people_up+6) || 
                        (x==people_left+58 && y==people_up+6) || 
                        (x==people_left+59 && y==people_up+6) || 
                        (x==people_left+60 && y==people_up+6) || 
                        (x==people_left+61 && y==people_up+6) || 
                        (x==people_left+62 && y==people_up+6) || 
                        (x==people_left+63 && y==people_up+6) || 
                        (x==people_left+64 && y==people_up+6) || 
                        (x==people_left+65 && y==people_up+6) || 
                        (x==people_left+66 && y==people_up+6) || 
                        (x==people_left+67 && y==people_up+6) || 
                        (x==people_left+68 && y==people_up+6) || 
                        (x==people_left+69 && y==people_up+6) || 
                        (x==people_left+70 && y==people_up+6) || 
                        (x==people_left+71 && y==people_up+6) || 
                        (x==people_left+72 && y==people_up+6) || 
                        (x==people_left+73 && y==people_up+6) || 
                        (x==people_left+74 && y==people_up+6) || 
                        (x==people_left+75 && y==people_up+6) || 
                        (x==people_left+76 && y==people_up+6) || 
                        (x==people_left+77 && y==people_up+6) || 
                        (x==people_left-39 && y==people_up+7) || 
                        (x==people_left-38 && y==people_up+7) || 
                        (x==people_left-37 && y==people_up+7) || 
                        (x==people_left-36 && y==people_up+7) || 
                        (x==people_left-35 && y==people_up+7) || 
                        (x==people_left-34 && y==people_up+7) || 
                        (x==people_left-33 && y==people_up+7) || 
                        (x==people_left-32 && y==people_up+7) || 
                        (x==people_left-31 && y==people_up+7) || 
                        (x==people_left-30 && y==people_up+7) || 
                        (x==people_left-29 && y==people_up+7) || 
                        (x==people_left-28 && y==people_up+7) || 
                        (x==people_left-27 && y==people_up+7) || 
                        (x==people_left-26 && y==people_up+7) || 
                        (x==people_left-25 && y==people_up+7) || 
                        (x==people_left-24 && y==people_up+7) || 
                        (x==people_left-23 && y==people_up+7) || 
                        (x==people_left-22 && y==people_up+7) || 
                        (x==people_left-21 && y==people_up+7) || 
                        (x==people_left-20 && y==people_up+7) || 
                        (x==people_left-19 && y==people_up+7) || 
                        (x==people_left-18 && y==people_up+7) || 
                        (x==people_left-17 && y==people_up+7) || 
                        (x==people_left-16 && y==people_up+7) || 
                        (x==people_left-15 && y==people_up+7) || 
                        (x==people_left-14 && y==people_up+7) || 
                        (x==people_left-13 && y==people_up+7) || 
                        (x==people_left-12 && y==people_up+7) || 
                        (x==people_left-11 && y==people_up+7) || 
                        (x==people_left-10 && y==people_up+7) || 
                        (x==people_left-9 && y==people_up+7) || 
                        (x==people_left-8 && y==people_up+7) || 
                        (x==people_left-7 && y==people_up+7) || 
                        (x==people_left-6 && y==people_up+7) || 
                        (x==people_left-5 && y==people_up+7) || 
                        (x==people_left-4 && y==people_up+7) || 
                        (x==people_left-3 && y==people_up+7) || 
                        (x==people_left-2 && y==people_up+7) || 
                        (x==people_left-1 && y==people_up+7) || 
                        (x==people_left+0 && y==people_up+7) || 
                        (x==people_left+1 && y==people_up+7) || 
                        (x==people_left+2 && y==people_up+7) || 
                        (x==people_left+3 && y==people_up+7) || 
                        (x==people_left+4 && y==people_up+7) || 
                        (x==people_left+5 && y==people_up+7) || 
                        (x==people_left+6 && y==people_up+7) || 
                        (x==people_left+7 && y==people_up+7) || 
                        (x==people_left+8 && y==people_up+7) || 
                        (x==people_left+9 && y==people_up+7) || 
                        (x==people_left+10 && y==people_up+7) || 
                        (x==people_left+11 && y==people_up+7) || 
                        (x==people_left+12 && y==people_up+7) || 
                        (x==people_left+13 && y==people_up+7) || 
                        (x==people_left+14 && y==people_up+7) || 
                        (x==people_left+15 && y==people_up+7) || 
                        (x==people_left+16 && y==people_up+7) || 
                        (x==people_left+17 && y==people_up+7) || 
                        (x==people_left+18 && y==people_up+7) || 
                        (x==people_left+19 && y==people_up+7) || 
                        (x==people_left+20 && y==people_up+7) || 
                        (x==people_left+21 && y==people_up+7) || 
                        (x==people_left+22 && y==people_up+7) || 
                        (x==people_left+23 && y==people_up+7) || 
                        (x==people_left+24 && y==people_up+7) || 
                        (x==people_left+25 && y==people_up+7) || 
                        (x==people_left+26 && y==people_up+7) || 
                        (x==people_left+27 && y==people_up+7) || 
                        (x==people_left+28 && y==people_up+7) || 
                        (x==people_left+29 && y==people_up+7) || 
                        (x==people_left+30 && y==people_up+7) || 
                        (x==people_left+31 && y==people_up+7) || 
                        (x==people_left+32 && y==people_up+7) || 
                        (x==people_left+33 && y==people_up+7) || 
                        (x==people_left+34 && y==people_up+7) || 
                        (x==people_left+35 && y==people_up+7) || 
                        (x==people_left+36 && y==people_up+7) || 
                        (x==people_left+37 && y==people_up+7) || 
                        (x==people_left+38 && y==people_up+7) || 
                        (x==people_left+39 && y==people_up+7) || 
                        (x==people_left+40 && y==people_up+7) || 
                        (x==people_left+41 && y==people_up+7) || 
                        (x==people_left+42 && y==people_up+7) || 
                        (x==people_left+43 && y==people_up+7) || 
                        (x==people_left+44 && y==people_up+7) || 
                        (x==people_left+45 && y==people_up+7) || 
                        (x==people_left+46 && y==people_up+7) || 
                        (x==people_left+47 && y==people_up+7) || 
                        (x==people_left+48 && y==people_up+7) || 
                        (x==people_left+49 && y==people_up+7) || 
                        (x==people_left+50 && y==people_up+7) || 
                        (x==people_left+51 && y==people_up+7) || 
                        (x==people_left+52 && y==people_up+7) || 
                        (x==people_left+53 && y==people_up+7) || 
                        (x==people_left+54 && y==people_up+7) || 
                        (x==people_left+55 && y==people_up+7) || 
                        (x==people_left+56 && y==people_up+7) || 
                        (x==people_left+57 && y==people_up+7) || 
                        (x==people_left+58 && y==people_up+7) || 
                        (x==people_left+59 && y==people_up+7) || 
                        (x==people_left+60 && y==people_up+7) || 
                        (x==people_left+61 && y==people_up+7) || 
                        (x==people_left+62 && y==people_up+7) || 
                        (x==people_left+63 && y==people_up+7) || 
                        (x==people_left+64 && y==people_up+7) || 
                        (x==people_left+65 && y==people_up+7) || 
                        (x==people_left+66 && y==people_up+7) || 
                        (x==people_left+67 && y==people_up+7) || 
                        (x==people_left+68 && y==people_up+7) || 
                        (x==people_left+69 && y==people_up+7) || 
                        (x==people_left+70 && y==people_up+7) || 
                        (x==people_left+71 && y==people_up+7) || 
                        (x==people_left+72 && y==people_up+7) || 
                        (x==people_left+73 && y==people_up+7) || 
                        (x==people_left+74 && y==people_up+7) || 
                        (x==people_left+75 && y==people_up+7) || 
                        (x==people_left+76 && y==people_up+7) || 
                        (x==people_left+77 && y==people_up+7) || 
                        (x==people_left-39 && y==people_up+8) || 
                        (x==people_left-38 && y==people_up+8) || 
                        (x==people_left-37 && y==people_up+8) || 
                        (x==people_left-36 && y==people_up+8) || 
                        (x==people_left-35 && y==people_up+8) || 
                        (x==people_left-34 && y==people_up+8) || 
                        (x==people_left-33 && y==people_up+8) || 
                        (x==people_left-32 && y==people_up+8) || 
                        (x==people_left-31 && y==people_up+8) || 
                        (x==people_left-30 && y==people_up+8) || 
                        (x==people_left-29 && y==people_up+8) || 
                        (x==people_left-28 && y==people_up+8) || 
                        (x==people_left-27 && y==people_up+8) || 
                        (x==people_left-26 && y==people_up+8) || 
                        (x==people_left-25 && y==people_up+8) || 
                        (x==people_left-24 && y==people_up+8) || 
                        (x==people_left-23 && y==people_up+8) || 
                        (x==people_left-22 && y==people_up+8) || 
                        (x==people_left-21 && y==people_up+8) || 
                        (x==people_left-20 && y==people_up+8) || 
                        (x==people_left-19 && y==people_up+8) || 
                        (x==people_left-18 && y==people_up+8) || 
                        (x==people_left-17 && y==people_up+8) || 
                        (x==people_left-16 && y==people_up+8) || 
                        (x==people_left-15 && y==people_up+8) || 
                        (x==people_left-14 && y==people_up+8) || 
                        (x==people_left-13 && y==people_up+8) || 
                        (x==people_left-12 && y==people_up+8) || 
                        (x==people_left-11 && y==people_up+8) || 
                        (x==people_left-10 && y==people_up+8) || 
                        (x==people_left-9 && y==people_up+8) || 
                        (x==people_left-8 && y==people_up+8) || 
                        (x==people_left-7 && y==people_up+8) || 
                        (x==people_left-6 && y==people_up+8) || 
                        (x==people_left-5 && y==people_up+8) || 
                        (x==people_left-4 && y==people_up+8) || 
                        (x==people_left-3 && y==people_up+8) || 
                        (x==people_left-2 && y==people_up+8) || 
                        (x==people_left-1 && y==people_up+8) || 
                        (x==people_left+0 && y==people_up+8) || 
                        (x==people_left+1 && y==people_up+8) || 
                        (x==people_left+2 && y==people_up+8) || 
                        (x==people_left+3 && y==people_up+8) || 
                        (x==people_left+4 && y==people_up+8) || 
                        (x==people_left+5 && y==people_up+8) || 
                        (x==people_left+6 && y==people_up+8) || 
                        (x==people_left+7 && y==people_up+8) || 
                        (x==people_left+8 && y==people_up+8) || 
                        (x==people_left+9 && y==people_up+8) || 
                        (x==people_left+10 && y==people_up+8) || 
                        (x==people_left+11 && y==people_up+8) || 
                        (x==people_left+12 && y==people_up+8) || 
                        (x==people_left+13 && y==people_up+8) || 
                        (x==people_left+14 && y==people_up+8) || 
                        (x==people_left+15 && y==people_up+8) || 
                        (x==people_left+16 && y==people_up+8) || 
                        (x==people_left+17 && y==people_up+8) || 
                        (x==people_left+18 && y==people_up+8) || 
                        (x==people_left+19 && y==people_up+8) || 
                        (x==people_left+20 && y==people_up+8) || 
                        (x==people_left+21 && y==people_up+8) || 
                        (x==people_left+22 && y==people_up+8) || 
                        (x==people_left+23 && y==people_up+8) || 
                        (x==people_left+24 && y==people_up+8) || 
                        (x==people_left+25 && y==people_up+8) || 
                        (x==people_left+26 && y==people_up+8) || 
                        (x==people_left+27 && y==people_up+8) || 
                        (x==people_left+28 && y==people_up+8) || 
                        (x==people_left+29 && y==people_up+8) || 
                        (x==people_left+30 && y==people_up+8) || 
                        (x==people_left+31 && y==people_up+8) || 
                        (x==people_left+32 && y==people_up+8) || 
                        (x==people_left+33 && y==people_up+8) || 
                        (x==people_left+34 && y==people_up+8) || 
                        (x==people_left+35 && y==people_up+8) || 
                        (x==people_left+36 && y==people_up+8) || 
                        (x==people_left+37 && y==people_up+8) || 
                        (x==people_left+38 && y==people_up+8) || 
                        (x==people_left+39 && y==people_up+8) || 
                        (x==people_left+40 && y==people_up+8) || 
                        (x==people_left+41 && y==people_up+8) || 
                        (x==people_left+42 && y==people_up+8) || 
                        (x==people_left+43 && y==people_up+8) || 
                        (x==people_left+44 && y==people_up+8) || 
                        (x==people_left+45 && y==people_up+8) || 
                        (x==people_left+46 && y==people_up+8) || 
                        (x==people_left+47 && y==people_up+8) || 
                        (x==people_left+48 && y==people_up+8) || 
                        (x==people_left+49 && y==people_up+8) || 
                        (x==people_left+50 && y==people_up+8) || 
                        (x==people_left+51 && y==people_up+8) || 
                        (x==people_left+52 && y==people_up+8) || 
                        (x==people_left+53 && y==people_up+8) || 
                        (x==people_left+54 && y==people_up+8) || 
                        (x==people_left+55 && y==people_up+8) || 
                        (x==people_left+56 && y==people_up+8) || 
                        (x==people_left+57 && y==people_up+8) || 
                        (x==people_left+58 && y==people_up+8) || 
                        (x==people_left+59 && y==people_up+8) || 
                        (x==people_left+60 && y==people_up+8) || 
                        (x==people_left+61 && y==people_up+8) || 
                        (x==people_left+62 && y==people_up+8) || 
                        (x==people_left+63 && y==people_up+8) || 
                        (x==people_left+64 && y==people_up+8) || 
                        (x==people_left+65 && y==people_up+8) || 
                        (x==people_left+66 && y==people_up+8) || 
                        (x==people_left+67 && y==people_up+8) || 
                        (x==people_left+68 && y==people_up+8) || 
                        (x==people_left+69 && y==people_up+8) || 
                        (x==people_left+70 && y==people_up+8) || 
                        (x==people_left+71 && y==people_up+8) || 
                        (x==people_left+72 && y==people_up+8) || 
                        (x==people_left+73 && y==people_up+8) || 
                        (x==people_left+74 && y==people_up+8) || 
                        (x==people_left+75 && y==people_up+8) || 
                        (x==people_left+76 && y==people_up+8) || 
                        (x==people_left+77 && y==people_up+8) || 
                        (x==people_left-39 && y==people_up+9) || 
                        (x==people_left-38 && y==people_up+9) || 
                        (x==people_left-37 && y==people_up+9) || 
                        (x==people_left-36 && y==people_up+9) || 
                        (x==people_left-35 && y==people_up+9) || 
                        (x==people_left-34 && y==people_up+9) || 
                        (x==people_left-33 && y==people_up+9) || 
                        (x==people_left-32 && y==people_up+9) || 
                        (x==people_left-31 && y==people_up+9) || 
                        (x==people_left-30 && y==people_up+9) || 
                        (x==people_left-29 && y==people_up+9) || 
                        (x==people_left-28 && y==people_up+9) || 
                        (x==people_left-27 && y==people_up+9) || 
                        (x==people_left-26 && y==people_up+9) || 
                        (x==people_left-25 && y==people_up+9) || 
                        (x==people_left-24 && y==people_up+9) || 
                        (x==people_left-23 && y==people_up+9) || 
                        (x==people_left-22 && y==people_up+9) || 
                        (x==people_left-21 && y==people_up+9) || 
                        (x==people_left-20 && y==people_up+9) || 
                        (x==people_left-19 && y==people_up+9) || 
                        (x==people_left-18 && y==people_up+9) || 
                        (x==people_left-17 && y==people_up+9) || 
                        (x==people_left-16 && y==people_up+9) || 
                        (x==people_left-15 && y==people_up+9) || 
                        (x==people_left-14 && y==people_up+9) || 
                        (x==people_left-13 && y==people_up+9) || 
                        (x==people_left-12 && y==people_up+9) || 
                        (x==people_left-11 && y==people_up+9) || 
                        (x==people_left-10 && y==people_up+9) || 
                        (x==people_left-9 && y==people_up+9) || 
                        (x==people_left-8 && y==people_up+9) || 
                        (x==people_left-7 && y==people_up+9) || 
                        (x==people_left-6 && y==people_up+9) || 
                        (x==people_left-5 && y==people_up+9) || 
                        (x==people_left-4 && y==people_up+9) || 
                        (x==people_left-3 && y==people_up+9) || 
                        (x==people_left-2 && y==people_up+9) || 
                        (x==people_left-1 && y==people_up+9) || 
                        (x==people_left+0 && y==people_up+9) || 
                        (x==people_left+1 && y==people_up+9) || 
                        (x==people_left+2 && y==people_up+9) || 
                        (x==people_left+3 && y==people_up+9) || 
                        (x==people_left+4 && y==people_up+9) || 
                        (x==people_left+5 && y==people_up+9) || 
                        (x==people_left+6 && y==people_up+9) || 
                        (x==people_left+7 && y==people_up+9) || 
                        (x==people_left+8 && y==people_up+9) || 
                        (x==people_left+9 && y==people_up+9) || 
                        (x==people_left+10 && y==people_up+9) || 
                        (x==people_left+11 && y==people_up+9) || 
                        (x==people_left+12 && y==people_up+9) || 
                        (x==people_left+13 && y==people_up+9) || 
                        (x==people_left+14 && y==people_up+9) || 
                        (x==people_left+15 && y==people_up+9) || 
                        (x==people_left+16 && y==people_up+9) || 
                        (x==people_left+17 && y==people_up+9) || 
                        (x==people_left+18 && y==people_up+9) || 
                        (x==people_left+19 && y==people_up+9) || 
                        (x==people_left+20 && y==people_up+9) || 
                        (x==people_left+21 && y==people_up+9) || 
                        (x==people_left+22 && y==people_up+9) || 
                        (x==people_left+23 && y==people_up+9) || 
                        (x==people_left+24 && y==people_up+9) || 
                        (x==people_left+25 && y==people_up+9) || 
                        (x==people_left+26 && y==people_up+9) || 
                        (x==people_left+27 && y==people_up+9) || 
                        (x==people_left+28 && y==people_up+9) || 
                        (x==people_left+29 && y==people_up+9) || 
                        (x==people_left+30 && y==people_up+9) || 
                        (x==people_left+31 && y==people_up+9) || 
                        (x==people_left+32 && y==people_up+9) || 
                        (x==people_left+33 && y==people_up+9) || 
                        (x==people_left+34 && y==people_up+9) || 
                        (x==people_left+35 && y==people_up+9) || 
                        (x==people_left+36 && y==people_up+9) || 
                        (x==people_left+37 && y==people_up+9) || 
                        (x==people_left+38 && y==people_up+9) || 
                        (x==people_left+39 && y==people_up+9) || 
                        (x==people_left+40 && y==people_up+9) || 
                        (x==people_left+41 && y==people_up+9) || 
                        (x==people_left+42 && y==people_up+9) || 
                        (x==people_left+43 && y==people_up+9) || 
                        (x==people_left+44 && y==people_up+9) || 
                        (x==people_left+45 && y==people_up+9) || 
                        (x==people_left+46 && y==people_up+9) || 
                        (x==people_left+47 && y==people_up+9) || 
                        (x==people_left+48 && y==people_up+9) || 
                        (x==people_left+49 && y==people_up+9) || 
                        (x==people_left+50 && y==people_up+9) || 
                        (x==people_left+51 && y==people_up+9) || 
                        (x==people_left+52 && y==people_up+9) || 
                        (x==people_left+53 && y==people_up+9) || 
                        (x==people_left+54 && y==people_up+9) || 
                        (x==people_left+55 && y==people_up+9) || 
                        (x==people_left+56 && y==people_up+9) || 
                        (x==people_left+57 && y==people_up+9) || 
                        (x==people_left+58 && y==people_up+9) || 
                        (x==people_left+59 && y==people_up+9) || 
                        (x==people_left+60 && y==people_up+9) || 
                        (x==people_left+61 && y==people_up+9) || 
                        (x==people_left+62 && y==people_up+9) || 
                        (x==people_left+63 && y==people_up+9) || 
                        (x==people_left+64 && y==people_up+9) || 
                        (x==people_left+65 && y==people_up+9) || 
                        (x==people_left+66 && y==people_up+9) || 
                        (x==people_left+67 && y==people_up+9) || 
                        (x==people_left+68 && y==people_up+9) || 
                        (x==people_left+69 && y==people_up+9) || 
                        (x==people_left+70 && y==people_up+9) || 
                        (x==people_left+71 && y==people_up+9) || 
                        (x==people_left+72 && y==people_up+9) || 
                        (x==people_left+73 && y==people_up+9) || 
                        (x==people_left+74 && y==people_up+9) || 
                        (x==people_left+75 && y==people_up+9) || 
                        (x==people_left+76 && y==people_up+9) || 
                        (x==people_left+77 && y==people_up+9) || 
                        (x==people_left-39 && y==people_up+10) || 
                        (x==people_left-38 && y==people_up+10) || 
                        (x==people_left-37 && y==people_up+10) || 
                        (x==people_left-36 && y==people_up+10) || 
                        (x==people_left-35 && y==people_up+10) || 
                        (x==people_left-34 && y==people_up+10) || 
                        (x==people_left-33 && y==people_up+10) || 
                        (x==people_left-32 && y==people_up+10) || 
                        (x==people_left-31 && y==people_up+10) || 
                        (x==people_left-30 && y==people_up+10) || 
                        (x==people_left-29 && y==people_up+10) || 
                        (x==people_left-28 && y==people_up+10) || 
                        (x==people_left-27 && y==people_up+10) || 
                        (x==people_left-26 && y==people_up+10) || 
                        (x==people_left-25 && y==people_up+10) || 
                        (x==people_left-24 && y==people_up+10) || 
                        (x==people_left-23 && y==people_up+10) || 
                        (x==people_left-22 && y==people_up+10) || 
                        (x==people_left-21 && y==people_up+10) || 
                        (x==people_left-20 && y==people_up+10) || 
                        (x==people_left-19 && y==people_up+10) || 
                        (x==people_left-18 && y==people_up+10) || 
                        (x==people_left-17 && y==people_up+10) || 
                        (x==people_left-16 && y==people_up+10) || 
                        (x==people_left-15 && y==people_up+10) || 
                        (x==people_left-14 && y==people_up+10) || 
                        (x==people_left-13 && y==people_up+10) || 
                        (x==people_left-12 && y==people_up+10) || 
                        (x==people_left-11 && y==people_up+10) || 
                        (x==people_left-10 && y==people_up+10) || 
                        (x==people_left-9 && y==people_up+10) || 
                        (x==people_left-8 && y==people_up+10) || 
                        (x==people_left-7 && y==people_up+10) || 
                        (x==people_left-6 && y==people_up+10) || 
                        (x==people_left-5 && y==people_up+10) || 
                        (x==people_left-4 && y==people_up+10) || 
                        (x==people_left-3 && y==people_up+10) || 
                        (x==people_left-2 && y==people_up+10) || 
                        (x==people_left-1 && y==people_up+10) || 
                        (x==people_left+0 && y==people_up+10) || 
                        (x==people_left+1 && y==people_up+10) || 
                        (x==people_left+2 && y==people_up+10) || 
                        (x==people_left+3 && y==people_up+10) || 
                        (x==people_left+4 && y==people_up+10) || 
                        (x==people_left+5 && y==people_up+10) || 
                        (x==people_left+6 && y==people_up+10) || 
                        (x==people_left+7 && y==people_up+10) || 
                        (x==people_left+8 && y==people_up+10) || 
                        (x==people_left+9 && y==people_up+10) || 
                        (x==people_left+10 && y==people_up+10) || 
                        (x==people_left+11 && y==people_up+10) || 
                        (x==people_left+12 && y==people_up+10) || 
                        (x==people_left+13 && y==people_up+10) || 
                        (x==people_left+14 && y==people_up+10) || 
                        (x==people_left+15 && y==people_up+10) || 
                        (x==people_left+16 && y==people_up+10) || 
                        (x==people_left+17 && y==people_up+10) || 
                        (x==people_left+18 && y==people_up+10) || 
                        (x==people_left+19 && y==people_up+10) || 
                        (x==people_left+20 && y==people_up+10) || 
                        (x==people_left+21 && y==people_up+10) || 
                        (x==people_left+22 && y==people_up+10) || 
                        (x==people_left+23 && y==people_up+10) || 
                        (x==people_left+24 && y==people_up+10) || 
                        (x==people_left+25 && y==people_up+10) || 
                        (x==people_left+26 && y==people_up+10) || 
                        (x==people_left+27 && y==people_up+10) || 
                        (x==people_left+28 && y==people_up+10) || 
                        (x==people_left+29 && y==people_up+10) || 
                        (x==people_left+30 && y==people_up+10) || 
                        (x==people_left+31 && y==people_up+10) || 
                        (x==people_left+32 && y==people_up+10) || 
                        (x==people_left+33 && y==people_up+10) || 
                        (x==people_left+34 && y==people_up+10) || 
                        (x==people_left+35 && y==people_up+10) || 
                        (x==people_left+36 && y==people_up+10) || 
                        (x==people_left+37 && y==people_up+10) || 
                        (x==people_left+38 && y==people_up+10) || 
                        (x==people_left+39 && y==people_up+10) || 
                        (x==people_left+40 && y==people_up+10) || 
                        (x==people_left+41 && y==people_up+10) || 
                        (x==people_left+42 && y==people_up+10) || 
                        (x==people_left+43 && y==people_up+10) || 
                        (x==people_left+44 && y==people_up+10) || 
                        (x==people_left+45 && y==people_up+10) || 
                        (x==people_left+46 && y==people_up+10) || 
                        (x==people_left+47 && y==people_up+10) || 
                        (x==people_left+48 && y==people_up+10) || 
                        (x==people_left+49 && y==people_up+10) || 
                        (x==people_left+50 && y==people_up+10) || 
                        (x==people_left+51 && y==people_up+10) || 
                        (x==people_left+52 && y==people_up+10) || 
                        (x==people_left+53 && y==people_up+10) || 
                        (x==people_left+54 && y==people_up+10) || 
                        (x==people_left+55 && y==people_up+10) || 
                        (x==people_left+56 && y==people_up+10) || 
                        (x==people_left+57 && y==people_up+10) || 
                        (x==people_left+58 && y==people_up+10) || 
                        (x==people_left+59 && y==people_up+10) || 
                        (x==people_left+60 && y==people_up+10) || 
                        (x==people_left+61 && y==people_up+10) || 
                        (x==people_left+62 && y==people_up+10) || 
                        (x==people_left+63 && y==people_up+10) || 
                        (x==people_left+64 && y==people_up+10) || 
                        (x==people_left+65 && y==people_up+10) || 
                        (x==people_left+66 && y==people_up+10) || 
                        (x==people_left+67 && y==people_up+10) || 
                        (x==people_left+68 && y==people_up+10) || 
                        (x==people_left+69 && y==people_up+10) || 
                        (x==people_left+70 && y==people_up+10) || 
                        (x==people_left+71 && y==people_up+10) || 
                        (x==people_left+72 && y==people_up+10) || 
                        (x==people_left+73 && y==people_up+10) || 
                        (x==people_left+74 && y==people_up+10) || 
                        (x==people_left+75 && y==people_up+10) || 
                        (x==people_left+76 && y==people_up+10) || 
                        (x==people_left+77 && y==people_up+10) || 
                        (x==people_left-40 && y==people_up+11) || 
                        (x==people_left-39 && y==people_up+11) || 
                        (x==people_left-38 && y==people_up+11) || 
                        (x==people_left-37 && y==people_up+11) || 
                        (x==people_left-36 && y==people_up+11) || 
                        (x==people_left-35 && y==people_up+11) || 
                        (x==people_left-34 && y==people_up+11) || 
                        (x==people_left-33 && y==people_up+11) || 
                        (x==people_left-32 && y==people_up+11) || 
                        (x==people_left-31 && y==people_up+11) || 
                        (x==people_left-30 && y==people_up+11) || 
                        (x==people_left-29 && y==people_up+11) || 
                        (x==people_left-28 && y==people_up+11) || 
                        (x==people_left-27 && y==people_up+11) || 
                        (x==people_left-26 && y==people_up+11) || 
                        (x==people_left-25 && y==people_up+11) || 
                        (x==people_left-24 && y==people_up+11) || 
                        (x==people_left-23 && y==people_up+11) || 
                        (x==people_left-22 && y==people_up+11) || 
                        (x==people_left-21 && y==people_up+11) || 
                        (x==people_left-20 && y==people_up+11) || 
                        (x==people_left-19 && y==people_up+11) || 
                        (x==people_left-18 && y==people_up+11) || 
                        (x==people_left-17 && y==people_up+11) || 
                        (x==people_left-16 && y==people_up+11) || 
                        (x==people_left-15 && y==people_up+11) || 
                        (x==people_left-14 && y==people_up+11) || 
                        (x==people_left-13 && y==people_up+11) || 
                        (x==people_left-12 && y==people_up+11) || 
                        (x==people_left-11 && y==people_up+11) || 
                        (x==people_left-10 && y==people_up+11) || 
                        (x==people_left-9 && y==people_up+11) || 
                        (x==people_left-8 && y==people_up+11) || 
                        (x==people_left-7 && y==people_up+11) || 
                        (x==people_left-6 && y==people_up+11) || 
                        (x==people_left-5 && y==people_up+11) || 
                        (x==people_left-4 && y==people_up+11) || 
                        (x==people_left-3 && y==people_up+11) || 
                        (x==people_left-2 && y==people_up+11) || 
                        (x==people_left-1 && y==people_up+11) || 
                        (x==people_left+0 && y==people_up+11) || 
                        (x==people_left+1 && y==people_up+11) || 
                        (x==people_left+2 && y==people_up+11) || 
                        (x==people_left+3 && y==people_up+11) || 
                        (x==people_left+4 && y==people_up+11) || 
                        (x==people_left+5 && y==people_up+11) || 
                        (x==people_left+6 && y==people_up+11) || 
                        (x==people_left+7 && y==people_up+11) || 
                        (x==people_left+8 && y==people_up+11) || 
                        (x==people_left+9 && y==people_up+11) || 
                        (x==people_left+10 && y==people_up+11) || 
                        (x==people_left+11 && y==people_up+11) || 
                        (x==people_left+12 && y==people_up+11) || 
                        (x==people_left+13 && y==people_up+11) || 
                        (x==people_left+14 && y==people_up+11) || 
                        (x==people_left+15 && y==people_up+11) || 
                        (x==people_left+16 && y==people_up+11) || 
                        (x==people_left+17 && y==people_up+11) || 
                        (x==people_left+18 && y==people_up+11) || 
                        (x==people_left+19 && y==people_up+11) || 
                        (x==people_left+20 && y==people_up+11) || 
                        (x==people_left+21 && y==people_up+11) || 
                        (x==people_left+22 && y==people_up+11) || 
                        (x==people_left+23 && y==people_up+11) || 
                        (x==people_left+24 && y==people_up+11) || 
                        (x==people_left+25 && y==people_up+11) || 
                        (x==people_left+26 && y==people_up+11) || 
                        (x==people_left+27 && y==people_up+11) || 
                        (x==people_left+28 && y==people_up+11) || 
                        (x==people_left+29 && y==people_up+11) || 
                        (x==people_left+30 && y==people_up+11) || 
                        (x==people_left+31 && y==people_up+11) || 
                        (x==people_left+32 && y==people_up+11) || 
                        (x==people_left+33 && y==people_up+11) || 
                        (x==people_left+34 && y==people_up+11) || 
                        (x==people_left+35 && y==people_up+11) || 
                        (x==people_left+36 && y==people_up+11) || 
                        (x==people_left+37 && y==people_up+11) || 
                        (x==people_left+38 && y==people_up+11) || 
                        (x==people_left+39 && y==people_up+11) || 
                        (x==people_left+40 && y==people_up+11) || 
                        (x==people_left+41 && y==people_up+11) || 
                        (x==people_left+42 && y==people_up+11) || 
                        (x==people_left+43 && y==people_up+11) || 
                        (x==people_left+44 && y==people_up+11) || 
                        (x==people_left+45 && y==people_up+11) || 
                        (x==people_left+46 && y==people_up+11) || 
                        (x==people_left+47 && y==people_up+11) || 
                        (x==people_left+48 && y==people_up+11) || 
                        (x==people_left+49 && y==people_up+11) || 
                        (x==people_left+50 && y==people_up+11) || 
                        (x==people_left+51 && y==people_up+11) || 
                        (x==people_left+52 && y==people_up+11) || 
                        (x==people_left+53 && y==people_up+11) || 
                        (x==people_left+54 && y==people_up+11) || 
                        (x==people_left+55 && y==people_up+11) || 
                        (x==people_left+56 && y==people_up+11) || 
                        (x==people_left+57 && y==people_up+11) || 
                        (x==people_left+58 && y==people_up+11) || 
                        (x==people_left+59 && y==people_up+11) || 
                        (x==people_left+60 && y==people_up+11) || 
                        (x==people_left+61 && y==people_up+11) || 
                        (x==people_left+62 && y==people_up+11) || 
                        (x==people_left+63 && y==people_up+11) || 
                        (x==people_left+64 && y==people_up+11) || 
                        (x==people_left+65 && y==people_up+11) || 
                        (x==people_left+66 && y==people_up+11) || 
                        (x==people_left+67 && y==people_up+11) || 
                        (x==people_left+68 && y==people_up+11) || 
                        (x==people_left+69 && y==people_up+11) || 
                        (x==people_left+70 && y==people_up+11) || 
                        (x==people_left+71 && y==people_up+11) || 
                        (x==people_left+72 && y==people_up+11) || 
                        (x==people_left+73 && y==people_up+11) || 
                        (x==people_left+74 && y==people_up+11) || 
                        (x==people_left+75 && y==people_up+11) || 
                        (x==people_left+76 && y==people_up+11) || 
                        (x==people_left+77 && y==people_up+11) || 
                        (x==people_left+78 && y==people_up+11) || 
                        (x==people_left-40 && y==people_up+12) || 
                        (x==people_left-39 && y==people_up+12) || 
                        (x==people_left-38 && y==people_up+12) || 
                        (x==people_left-37 && y==people_up+12) || 
                        (x==people_left-36 && y==people_up+12) || 
                        (x==people_left-35 && y==people_up+12) || 
                        (x==people_left-34 && y==people_up+12) || 
                        (x==people_left-33 && y==people_up+12) || 
                        (x==people_left-32 && y==people_up+12) || 
                        (x==people_left-31 && y==people_up+12) || 
                        (x==people_left-30 && y==people_up+12) || 
                        (x==people_left-29 && y==people_up+12) || 
                        (x==people_left-28 && y==people_up+12) || 
                        (x==people_left-27 && y==people_up+12) || 
                        (x==people_left-26 && y==people_up+12) || 
                        (x==people_left-25 && y==people_up+12) || 
                        (x==people_left-24 && y==people_up+12) || 
                        (x==people_left-23 && y==people_up+12) || 
                        (x==people_left-22 && y==people_up+12) || 
                        (x==people_left-21 && y==people_up+12) || 
                        (x==people_left-20 && y==people_up+12) || 
                        (x==people_left-19 && y==people_up+12) || 
                        (x==people_left-18 && y==people_up+12) || 
                        (x==people_left-17 && y==people_up+12) || 
                        (x==people_left-16 && y==people_up+12) || 
                        (x==people_left-15 && y==people_up+12) || 
                        (x==people_left-14 && y==people_up+12) || 
                        (x==people_left-13 && y==people_up+12) || 
                        (x==people_left-12 && y==people_up+12) || 
                        (x==people_left-11 && y==people_up+12) || 
                        (x==people_left-10 && y==people_up+12) || 
                        (x==people_left-9 && y==people_up+12) || 
                        (x==people_left-8 && y==people_up+12) || 
                        (x==people_left-7 && y==people_up+12) || 
                        (x==people_left-6 && y==people_up+12) || 
                        (x==people_left-5 && y==people_up+12) || 
                        (x==people_left-4 && y==people_up+12) || 
                        (x==people_left-3 && y==people_up+12) || 
                        (x==people_left-2 && y==people_up+12) || 
                        (x==people_left-1 && y==people_up+12) || 
                        (x==people_left+0 && y==people_up+12) || 
                        (x==people_left+1 && y==people_up+12) || 
                        (x==people_left+2 && y==people_up+12) || 
                        (x==people_left+3 && y==people_up+12) || 
                        (x==people_left+4 && y==people_up+12) || 
                        (x==people_left+5 && y==people_up+12) || 
                        (x==people_left+6 && y==people_up+12) || 
                        (x==people_left+7 && y==people_up+12) || 
                        (x==people_left+8 && y==people_up+12) || 
                        (x==people_left+9 && y==people_up+12) || 
                        (x==people_left+10 && y==people_up+12) || 
                        (x==people_left+11 && y==people_up+12) || 
                        (x==people_left+12 && y==people_up+12) || 
                        (x==people_left+13 && y==people_up+12) || 
                        (x==people_left+14 && y==people_up+12) || 
                        (x==people_left+15 && y==people_up+12) || 
                        (x==people_left+16 && y==people_up+12) || 
                        (x==people_left+17 && y==people_up+12) || 
                        (x==people_left+18 && y==people_up+12) || 
                        (x==people_left+19 && y==people_up+12) || 
                        (x==people_left+20 && y==people_up+12) || 
                        (x==people_left+21 && y==people_up+12) || 
                        (x==people_left+22 && y==people_up+12) || 
                        (x==people_left+23 && y==people_up+12) || 
                        (x==people_left+24 && y==people_up+12) || 
                        (x==people_left+25 && y==people_up+12) || 
                        (x==people_left+26 && y==people_up+12) || 
                        (x==people_left+27 && y==people_up+12) || 
                        (x==people_left+28 && y==people_up+12) || 
                        (x==people_left+29 && y==people_up+12) || 
                        (x==people_left+30 && y==people_up+12) || 
                        (x==people_left+31 && y==people_up+12) || 
                        (x==people_left+32 && y==people_up+12) || 
                        (x==people_left+33 && y==people_up+12) || 
                        (x==people_left+34 && y==people_up+12) || 
                        (x==people_left+35 && y==people_up+12) || 
                        (x==people_left+36 && y==people_up+12) || 
                        (x==people_left+37 && y==people_up+12) || 
                        (x==people_left+38 && y==people_up+12) || 
                        (x==people_left+39 && y==people_up+12) || 
                        (x==people_left+40 && y==people_up+12) || 
                        (x==people_left+41 && y==people_up+12) || 
                        (x==people_left+42 && y==people_up+12) || 
                        (x==people_left+43 && y==people_up+12) || 
                        (x==people_left+44 && y==people_up+12) || 
                        (x==people_left+45 && y==people_up+12) || 
                        (x==people_left+46 && y==people_up+12) || 
                        (x==people_left+47 && y==people_up+12) || 
                        (x==people_left+48 && y==people_up+12) || 
                        (x==people_left+49 && y==people_up+12) || 
                        (x==people_left+50 && y==people_up+12) || 
                        (x==people_left+51 && y==people_up+12) || 
                        (x==people_left+52 && y==people_up+12) || 
                        (x==people_left+53 && y==people_up+12) || 
                        (x==people_left+54 && y==people_up+12) || 
                        (x==people_left+55 && y==people_up+12) || 
                        (x==people_left+56 && y==people_up+12) || 
                        (x==people_left+57 && y==people_up+12) || 
                        (x==people_left+58 && y==people_up+12) || 
                        (x==people_left+59 && y==people_up+12) || 
                        (x==people_left+60 && y==people_up+12) || 
                        (x==people_left+61 && y==people_up+12) || 
                        (x==people_left+62 && y==people_up+12) || 
                        (x==people_left+63 && y==people_up+12) || 
                        (x==people_left+64 && y==people_up+12) || 
                        (x==people_left+65 && y==people_up+12) || 
                        (x==people_left+66 && y==people_up+12) || 
                        (x==people_left+67 && y==people_up+12) || 
                        (x==people_left+68 && y==people_up+12) || 
                        (x==people_left+69 && y==people_up+12) || 
                        (x==people_left+70 && y==people_up+12) || 
                        (x==people_left+71 && y==people_up+12) || 
                        (x==people_left+72 && y==people_up+12) || 
                        (x==people_left+73 && y==people_up+12) || 
                        (x==people_left+74 && y==people_up+12) || 
                        (x==people_left+75 && y==people_up+12) || 
                        (x==people_left+76 && y==people_up+12) || 
                        (x==people_left+77 && y==people_up+12) || 
                        (x==people_left+78 && y==people_up+12) || 
                        (x==people_left-40 && y==people_up+13) || 
                        (x==people_left-39 && y==people_up+13) || 
                        (x==people_left-38 && y==people_up+13) || 
                        (x==people_left-37 && y==people_up+13) || 
                        (x==people_left-36 && y==people_up+13) || 
                        (x==people_left-35 && y==people_up+13) || 
                        (x==people_left-34 && y==people_up+13) || 
                        (x==people_left-33 && y==people_up+13) || 
                        (x==people_left-32 && y==people_up+13) || 
                        (x==people_left-31 && y==people_up+13) || 
                        (x==people_left-30 && y==people_up+13) || 
                        (x==people_left-29 && y==people_up+13) || 
                        (x==people_left-28 && y==people_up+13) || 
                        (x==people_left-27 && y==people_up+13) || 
                        (x==people_left-26 && y==people_up+13) || 
                        (x==people_left-25 && y==people_up+13) || 
                        (x==people_left-24 && y==people_up+13) || 
                        (x==people_left-23 && y==people_up+13) || 
                        (x==people_left-22 && y==people_up+13) || 
                        (x==people_left-21 && y==people_up+13) || 
                        (x==people_left-20 && y==people_up+13) || 
                        (x==people_left-19 && y==people_up+13) || 
                        (x==people_left-18 && y==people_up+13) || 
                        (x==people_left-17 && y==people_up+13) || 
                        (x==people_left-16 && y==people_up+13) || 
                        (x==people_left-15 && y==people_up+13) || 
                        (x==people_left-14 && y==people_up+13) || 
                        (x==people_left-13 && y==people_up+13) || 
                        (x==people_left-12 && y==people_up+13) || 
                        (x==people_left-11 && y==people_up+13) || 
                        (x==people_left-10 && y==people_up+13) || 
                        (x==people_left-9 && y==people_up+13) || 
                        (x==people_left-8 && y==people_up+13) || 
                        (x==people_left-7 && y==people_up+13) || 
                        (x==people_left-6 && y==people_up+13) || 
                        (x==people_left-5 && y==people_up+13) || 
                        (x==people_left-4 && y==people_up+13) || 
                        (x==people_left-3 && y==people_up+13) || 
                        (x==people_left-2 && y==people_up+13) || 
                        (x==people_left-1 && y==people_up+13) || 
                        (x==people_left+0 && y==people_up+13) || 
                        (x==people_left+1 && y==people_up+13) || 
                        (x==people_left+2 && y==people_up+13) || 
                        (x==people_left+3 && y==people_up+13) || 
                        (x==people_left+4 && y==people_up+13) || 
                        (x==people_left+5 && y==people_up+13) || 
                        (x==people_left+6 && y==people_up+13) || 
                        (x==people_left+7 && y==people_up+13) || 
                        (x==people_left+8 && y==people_up+13) || 
                        (x==people_left+9 && y==people_up+13) || 
                        (x==people_left+10 && y==people_up+13) || 
                        (x==people_left+11 && y==people_up+13) || 
                        (x==people_left+12 && y==people_up+13) || 
                        (x==people_left+13 && y==people_up+13) || 
                        (x==people_left+14 && y==people_up+13) || 
                        (x==people_left+15 && y==people_up+13) || 
                        (x==people_left+16 && y==people_up+13) || 
                        (x==people_left+17 && y==people_up+13) || 
                        (x==people_left+18 && y==people_up+13) || 
                        (x==people_left+19 && y==people_up+13) || 
                        (x==people_left+20 && y==people_up+13) || 
                        (x==people_left+21 && y==people_up+13) || 
                        (x==people_left+22 && y==people_up+13) || 
                        (x==people_left+23 && y==people_up+13) || 
                        (x==people_left+24 && y==people_up+13) || 
                        (x==people_left+25 && y==people_up+13) || 
                        (x==people_left+26 && y==people_up+13) || 
                        (x==people_left+27 && y==people_up+13) || 
                        (x==people_left+28 && y==people_up+13) || 
                        (x==people_left+29 && y==people_up+13) || 
                        (x==people_left+30 && y==people_up+13) || 
                        (x==people_left+31 && y==people_up+13) || 
                        (x==people_left+32 && y==people_up+13) || 
                        (x==people_left+33 && y==people_up+13) || 
                        (x==people_left+34 && y==people_up+13) || 
                        (x==people_left+35 && y==people_up+13) || 
                        (x==people_left+36 && y==people_up+13) || 
                        (x==people_left+37 && y==people_up+13) || 
                        (x==people_left+38 && y==people_up+13) || 
                        (x==people_left+39 && y==people_up+13) || 
                        (x==people_left+40 && y==people_up+13) || 
                        (x==people_left+41 && y==people_up+13) || 
                        (x==people_left+42 && y==people_up+13) || 
                        (x==people_left+43 && y==people_up+13) || 
                        (x==people_left+44 && y==people_up+13) || 
                        (x==people_left+45 && y==people_up+13) || 
                        (x==people_left+46 && y==people_up+13) || 
                        (x==people_left+47 && y==people_up+13) || 
                        (x==people_left+48 && y==people_up+13) || 
                        (x==people_left+49 && y==people_up+13) || 
                        (x==people_left+50 && y==people_up+13) || 
                        (x==people_left+51 && y==people_up+13) || 
                        (x==people_left+52 && y==people_up+13) || 
                        (x==people_left+53 && y==people_up+13) || 
                        (x==people_left+54 && y==people_up+13) || 
                        (x==people_left+55 && y==people_up+13) || 
                        (x==people_left+56 && y==people_up+13) || 
                        (x==people_left+57 && y==people_up+13) || 
                        (x==people_left+58 && y==people_up+13) || 
                        (x==people_left+59 && y==people_up+13) || 
                        (x==people_left+60 && y==people_up+13) || 
                        (x==people_left+61 && y==people_up+13) || 
                        (x==people_left+62 && y==people_up+13) || 
                        (x==people_left+63 && y==people_up+13) || 
                        (x==people_left+64 && y==people_up+13) || 
                        (x==people_left+65 && y==people_up+13) || 
                        (x==people_left+66 && y==people_up+13) || 
                        (x==people_left+67 && y==people_up+13) || 
                        (x==people_left+68 && y==people_up+13) || 
                        (x==people_left+69 && y==people_up+13) || 
                        (x==people_left+70 && y==people_up+13) || 
                        (x==people_left+71 && y==people_up+13) || 
                        (x==people_left+72 && y==people_up+13) || 
                        (x==people_left+73 && y==people_up+13) || 
                        (x==people_left+74 && y==people_up+13) || 
                        (x==people_left+75 && y==people_up+13) || 
                        (x==people_left+76 && y==people_up+13) || 
                        (x==people_left+77 && y==people_up+13) || 
                        (x==people_left+78 && y==people_up+13) || 
                        (x==people_left-40 && y==people_up+14) || 
                        (x==people_left-39 && y==people_up+14) || 
                        (x==people_left-38 && y==people_up+14) || 
                        (x==people_left-37 && y==people_up+14) || 
                        (x==people_left-36 && y==people_up+14) || 
                        (x==people_left-35 && y==people_up+14) || 
                        (x==people_left-34 && y==people_up+14) || 
                        (x==people_left-33 && y==people_up+14) || 
                        (x==people_left-32 && y==people_up+14) || 
                        (x==people_left-31 && y==people_up+14) || 
                        (x==people_left-30 && y==people_up+14) || 
                        (x==people_left-29 && y==people_up+14) || 
                        (x==people_left-28 && y==people_up+14) || 
                        (x==people_left-27 && y==people_up+14) || 
                        (x==people_left-26 && y==people_up+14) || 
                        (x==people_left-25 && y==people_up+14) || 
                        (x==people_left-24 && y==people_up+14) || 
                        (x==people_left-23 && y==people_up+14) || 
                        (x==people_left-22 && y==people_up+14) || 
                        (x==people_left-21 && y==people_up+14) || 
                        (x==people_left-20 && y==people_up+14) || 
                        (x==people_left-19 && y==people_up+14) || 
                        (x==people_left-18 && y==people_up+14) || 
                        (x==people_left-17 && y==people_up+14) || 
                        (x==people_left-16 && y==people_up+14) || 
                        (x==people_left-15 && y==people_up+14) || 
                        (x==people_left-14 && y==people_up+14) || 
                        (x==people_left-13 && y==people_up+14) || 
                        (x==people_left-12 && y==people_up+14) || 
                        (x==people_left-11 && y==people_up+14) || 
                        (x==people_left-10 && y==people_up+14) || 
                        (x==people_left-9 && y==people_up+14) || 
                        (x==people_left-8 && y==people_up+14) || 
                        (x==people_left-7 && y==people_up+14) || 
                        (x==people_left-6 && y==people_up+14) || 
                        (x==people_left-5 && y==people_up+14) || 
                        (x==people_left-4 && y==people_up+14) || 
                        (x==people_left-3 && y==people_up+14) || 
                        (x==people_left-2 && y==people_up+14) || 
                        (x==people_left-1 && y==people_up+14) || 
                        (x==people_left+0 && y==people_up+14) || 
                        (x==people_left+1 && y==people_up+14) || 
                        (x==people_left+2 && y==people_up+14) || 
                        (x==people_left+3 && y==people_up+14) || 
                        (x==people_left+4 && y==people_up+14) || 
                        (x==people_left+5 && y==people_up+14) || 
                        (x==people_left+6 && y==people_up+14) || 
                        (x==people_left+7 && y==people_up+14) || 
                        (x==people_left+8 && y==people_up+14) || 
                        (x==people_left+9 && y==people_up+14) || 
                        (x==people_left+10 && y==people_up+14) || 
                        (x==people_left+11 && y==people_up+14) || 
                        (x==people_left+12 && y==people_up+14) || 
                        (x==people_left+13 && y==people_up+14) || 
                        (x==people_left+14 && y==people_up+14) || 
                        (x==people_left+15 && y==people_up+14) || 
                        (x==people_left+16 && y==people_up+14) || 
                        (x==people_left+17 && y==people_up+14) || 
                        (x==people_left+18 && y==people_up+14) || 
                        (x==people_left+19 && y==people_up+14) || 
                        (x==people_left+20 && y==people_up+14) || 
                        (x==people_left+21 && y==people_up+14) || 
                        (x==people_left+22 && y==people_up+14) || 
                        (x==people_left+23 && y==people_up+14) || 
                        (x==people_left+24 && y==people_up+14) || 
                        (x==people_left+25 && y==people_up+14) || 
                        (x==people_left+26 && y==people_up+14) || 
                        (x==people_left+27 && y==people_up+14) || 
                        (x==people_left+28 && y==people_up+14) || 
                        (x==people_left+29 && y==people_up+14) || 
                        (x==people_left+30 && y==people_up+14) || 
                        (x==people_left+31 && y==people_up+14) || 
                        (x==people_left+32 && y==people_up+14) || 
                        (x==people_left+33 && y==people_up+14) || 
                        (x==people_left+34 && y==people_up+14) || 
                        (x==people_left+35 && y==people_up+14) || 
                        (x==people_left+36 && y==people_up+14) || 
                        (x==people_left+37 && y==people_up+14) || 
                        (x==people_left+38 && y==people_up+14) || 
                        (x==people_left+39 && y==people_up+14) || 
                        (x==people_left+40 && y==people_up+14) || 
                        (x==people_left+41 && y==people_up+14) || 
                        (x==people_left+42 && y==people_up+14) || 
                        (x==people_left+43 && y==people_up+14) || 
                        (x==people_left+44 && y==people_up+14) || 
                        (x==people_left+45 && y==people_up+14) || 
                        (x==people_left+46 && y==people_up+14) || 
                        (x==people_left+47 && y==people_up+14) || 
                        (x==people_left+48 && y==people_up+14) || 
                        (x==people_left+49 && y==people_up+14) || 
                        (x==people_left+50 && y==people_up+14) || 
                        (x==people_left+51 && y==people_up+14) || 
                        (x==people_left+52 && y==people_up+14) || 
                        (x==people_left+53 && y==people_up+14) || 
                        (x==people_left+54 && y==people_up+14) || 
                        (x==people_left+55 && y==people_up+14) || 
                        (x==people_left+56 && y==people_up+14) || 
                        (x==people_left+57 && y==people_up+14) || 
                        (x==people_left+58 && y==people_up+14) || 
                        (x==people_left+59 && y==people_up+14) || 
                        (x==people_left+60 && y==people_up+14) || 
                        (x==people_left+61 && y==people_up+14) || 
                        (x==people_left+62 && y==people_up+14) || 
                        (x==people_left+63 && y==people_up+14) || 
                        (x==people_left+64 && y==people_up+14) || 
                        (x==people_left+65 && y==people_up+14) || 
                        (x==people_left+66 && y==people_up+14) || 
                        (x==people_left+67 && y==people_up+14) || 
                        (x==people_left+68 && y==people_up+14) || 
                        (x==people_left+69 && y==people_up+14) || 
                        (x==people_left+70 && y==people_up+14) || 
                        (x==people_left+71 && y==people_up+14) || 
                        (x==people_left+72 && y==people_up+14) || 
                        (x==people_left+73 && y==people_up+14) || 
                        (x==people_left+74 && y==people_up+14) || 
                        (x==people_left+75 && y==people_up+14) || 
                        (x==people_left+76 && y==people_up+14) || 
                        (x==people_left+77 && y==people_up+14) || 
                        (x==people_left+78 && y==people_up+14) || 
                        (x==people_left-40 && y==people_up+15) || 
                        (x==people_left-39 && y==people_up+15) || 
                        (x==people_left-38 && y==people_up+15) || 
                        (x==people_left-37 && y==people_up+15) || 
                        (x==people_left-36 && y==people_up+15) || 
                        (x==people_left-35 && y==people_up+15) || 
                        (x==people_left-34 && y==people_up+15) || 
                        (x==people_left-33 && y==people_up+15) || 
                        (x==people_left-32 && y==people_up+15) || 
                        (x==people_left-31 && y==people_up+15) || 
                        (x==people_left-30 && y==people_up+15) || 
                        (x==people_left-29 && y==people_up+15) || 
                        (x==people_left-28 && y==people_up+15) || 
                        (x==people_left-27 && y==people_up+15) || 
                        (x==people_left-26 && y==people_up+15) || 
                        (x==people_left-25 && y==people_up+15) || 
                        (x==people_left-24 && y==people_up+15) || 
                        (x==people_left-23 && y==people_up+15) || 
                        (x==people_left-22 && y==people_up+15) || 
                        (x==people_left-21 && y==people_up+15) || 
                        (x==people_left-20 && y==people_up+15) || 
                        (x==people_left-19 && y==people_up+15) || 
                        (x==people_left-18 && y==people_up+15) || 
                        (x==people_left-17 && y==people_up+15) || 
                        (x==people_left-16 && y==people_up+15) || 
                        (x==people_left-15 && y==people_up+15) || 
                        (x==people_left-14 && y==people_up+15) || 
                        (x==people_left-13 && y==people_up+15) || 
                        (x==people_left-12 && y==people_up+15) || 
                        (x==people_left-11 && y==people_up+15) || 
                        (x==people_left-10 && y==people_up+15) || 
                        (x==people_left-9 && y==people_up+15) || 
                        (x==people_left-8 && y==people_up+15) || 
                        (x==people_left-7 && y==people_up+15) || 
                        (x==people_left-6 && y==people_up+15) || 
                        (x==people_left-5 && y==people_up+15) || 
                        (x==people_left-4 && y==people_up+15) || 
                        (x==people_left-3 && y==people_up+15) || 
                        (x==people_left-2 && y==people_up+15) || 
                        (x==people_left-1 && y==people_up+15) || 
                        (x==people_left+0 && y==people_up+15) || 
                        (x==people_left+1 && y==people_up+15) || 
                        (x==people_left+2 && y==people_up+15) || 
                        (x==people_left+3 && y==people_up+15) || 
                        (x==people_left+4 && y==people_up+15) || 
                        (x==people_left+5 && y==people_up+15) || 
                        (x==people_left+6 && y==people_up+15) || 
                        (x==people_left+7 && y==people_up+15) || 
                        (x==people_left+8 && y==people_up+15) || 
                        (x==people_left+9 && y==people_up+15) || 
                        (x==people_left+10 && y==people_up+15) || 
                        (x==people_left+11 && y==people_up+15) || 
                        (x==people_left+12 && y==people_up+15) || 
                        (x==people_left+13 && y==people_up+15) || 
                        (x==people_left+14 && y==people_up+15) || 
                        (x==people_left+15 && y==people_up+15) || 
                        (x==people_left+16 && y==people_up+15) || 
                        (x==people_left+17 && y==people_up+15) || 
                        (x==people_left+18 && y==people_up+15) || 
                        (x==people_left+19 && y==people_up+15) || 
                        (x==people_left+20 && y==people_up+15) || 
                        (x==people_left+21 && y==people_up+15) || 
                        (x==people_left+22 && y==people_up+15) || 
                        (x==people_left+23 && y==people_up+15) || 
                        (x==people_left+24 && y==people_up+15) || 
                        (x==people_left+25 && y==people_up+15) || 
                        (x==people_left+26 && y==people_up+15) || 
                        (x==people_left+27 && y==people_up+15) || 
                        (x==people_left+28 && y==people_up+15) || 
                        (x==people_left+29 && y==people_up+15) || 
                        (x==people_left+30 && y==people_up+15) || 
                        (x==people_left+31 && y==people_up+15) || 
                        (x==people_left+32 && y==people_up+15) || 
                        (x==people_left+33 && y==people_up+15) || 
                        (x==people_left+34 && y==people_up+15) || 
                        (x==people_left+35 && y==people_up+15) || 
                        (x==people_left+36 && y==people_up+15) || 
                        (x==people_left+37 && y==people_up+15) || 
                        (x==people_left+38 && y==people_up+15) || 
                        (x==people_left+39 && y==people_up+15) || 
                        (x==people_left+40 && y==people_up+15) || 
                        (x==people_left+41 && y==people_up+15) || 
                        (x==people_left+42 && y==people_up+15) || 
                        (x==people_left+43 && y==people_up+15) || 
                        (x==people_left+44 && y==people_up+15) || 
                        (x==people_left+45 && y==people_up+15) || 
                        (x==people_left+46 && y==people_up+15) || 
                        (x==people_left+47 && y==people_up+15) || 
                        (x==people_left+48 && y==people_up+15) || 
                        (x==people_left+49 && y==people_up+15) || 
                        (x==people_left+50 && y==people_up+15) || 
                        (x==people_left+51 && y==people_up+15) || 
                        (x==people_left+52 && y==people_up+15) || 
                        (x==people_left+53 && y==people_up+15) || 
                        (x==people_left+54 && y==people_up+15) || 
                        (x==people_left+55 && y==people_up+15) || 
                        (x==people_left+56 && y==people_up+15) || 
                        (x==people_left+57 && y==people_up+15) || 
                        (x==people_left+58 && y==people_up+15) || 
                        (x==people_left+59 && y==people_up+15) || 
                        (x==people_left+60 && y==people_up+15) || 
                        (x==people_left+61 && y==people_up+15) || 
                        (x==people_left+62 && y==people_up+15) || 
                        (x==people_left+63 && y==people_up+15) || 
                        (x==people_left+64 && y==people_up+15) || 
                        (x==people_left+65 && y==people_up+15) || 
                        (x==people_left+66 && y==people_up+15) || 
                        (x==people_left+67 && y==people_up+15) || 
                        (x==people_left+68 && y==people_up+15) || 
                        (x==people_left+69 && y==people_up+15) || 
                        (x==people_left+70 && y==people_up+15) || 
                        (x==people_left+71 && y==people_up+15) || 
                        (x==people_left+72 && y==people_up+15) || 
                        (x==people_left+73 && y==people_up+15) || 
                        (x==people_left+74 && y==people_up+15) || 
                        (x==people_left+75 && y==people_up+15) || 
                        (x==people_left+76 && y==people_up+15) || 
                        (x==people_left+77 && y==people_up+15) || 
                        (x==people_left+78 && y==people_up+15) || 
                        (x==people_left-40 && y==people_up+16) || 
                        (x==people_left-39 && y==people_up+16) || 
                        (x==people_left-38 && y==people_up+16) || 
                        (x==people_left-37 && y==people_up+16) || 
                        (x==people_left-36 && y==people_up+16) || 
                        (x==people_left-35 && y==people_up+16) || 
                        (x==people_left-34 && y==people_up+16) || 
                        (x==people_left-33 && y==people_up+16) || 
                        (x==people_left-32 && y==people_up+16) || 
                        (x==people_left-31 && y==people_up+16) || 
                        (x==people_left-30 && y==people_up+16) || 
                        (x==people_left-29 && y==people_up+16) || 
                        (x==people_left-28 && y==people_up+16) || 
                        (x==people_left-27 && y==people_up+16) || 
                        (x==people_left-26 && y==people_up+16) || 
                        (x==people_left-25 && y==people_up+16) || 
                        (x==people_left-24 && y==people_up+16) || 
                        (x==people_left-23 && y==people_up+16) || 
                        (x==people_left-22 && y==people_up+16) || 
                        (x==people_left-21 && y==people_up+16) || 
                        (x==people_left-20 && y==people_up+16) || 
                        (x==people_left-19 && y==people_up+16) || 
                        (x==people_left-18 && y==people_up+16) || 
                        (x==people_left-17 && y==people_up+16) || 
                        (x==people_left-16 && y==people_up+16) || 
                        (x==people_left-15 && y==people_up+16) || 
                        (x==people_left-14 && y==people_up+16) || 
                        (x==people_left-13 && y==people_up+16) || 
                        (x==people_left-12 && y==people_up+16) || 
                        (x==people_left-11 && y==people_up+16) || 
                        (x==people_left-10 && y==people_up+16) || 
                        (x==people_left-9 && y==people_up+16) || 
                        (x==people_left-8 && y==people_up+16) || 
                        (x==people_left-7 && y==people_up+16) || 
                        (x==people_left-6 && y==people_up+16) || 
                        (x==people_left-5 && y==people_up+16) || 
                        (x==people_left-4 && y==people_up+16) || 
                        (x==people_left-3 && y==people_up+16) || 
                        (x==people_left-2 && y==people_up+16) || 
                        (x==people_left-1 && y==people_up+16) || 
                        (x==people_left+0 && y==people_up+16) || 
                        (x==people_left+1 && y==people_up+16) || 
                        (x==people_left+2 && y==people_up+16) || 
                        (x==people_left+3 && y==people_up+16) || 
                        (x==people_left+4 && y==people_up+16) || 
                        (x==people_left+5 && y==people_up+16) || 
                        (x==people_left+6 && y==people_up+16) || 
                        (x==people_left+7 && y==people_up+16) || 
                        (x==people_left+8 && y==people_up+16) || 
                        (x==people_left+9 && y==people_up+16) || 
                        (x==people_left+10 && y==people_up+16) || 
                        (x==people_left+11 && y==people_up+16) || 
                        (x==people_left+12 && y==people_up+16) || 
                        (x==people_left+13 && y==people_up+16) || 
                        (x==people_left+14 && y==people_up+16) || 
                        (x==people_left+15 && y==people_up+16) || 
                        (x==people_left+16 && y==people_up+16) || 
                        (x==people_left+17 && y==people_up+16) || 
                        (x==people_left+18 && y==people_up+16) || 
                        (x==people_left+19 && y==people_up+16) || 
                        (x==people_left+20 && y==people_up+16) || 
                        (x==people_left+21 && y==people_up+16) || 
                        (x==people_left+22 && y==people_up+16) || 
                        (x==people_left+23 && y==people_up+16) || 
                        (x==people_left+24 && y==people_up+16) || 
                        (x==people_left+25 && y==people_up+16) || 
                        (x==people_left+26 && y==people_up+16) || 
                        (x==people_left+27 && y==people_up+16) || 
                        (x==people_left+28 && y==people_up+16) || 
                        (x==people_left+29 && y==people_up+16) || 
                        (x==people_left+30 && y==people_up+16) || 
                        (x==people_left+31 && y==people_up+16) || 
                        (x==people_left+32 && y==people_up+16) || 
                        (x==people_left+33 && y==people_up+16) || 
                        (x==people_left+34 && y==people_up+16) || 
                        (x==people_left+35 && y==people_up+16) || 
                        (x==people_left+36 && y==people_up+16) || 
                        (x==people_left+37 && y==people_up+16) || 
                        (x==people_left+38 && y==people_up+16) || 
                        (x==people_left+39 && y==people_up+16) || 
                        (x==people_left+40 && y==people_up+16) || 
                        (x==people_left+41 && y==people_up+16) || 
                        (x==people_left+42 && y==people_up+16) || 
                        (x==people_left+43 && y==people_up+16) || 
                        (x==people_left+44 && y==people_up+16) || 
                        (x==people_left+45 && y==people_up+16) || 
                        (x==people_left+46 && y==people_up+16) || 
                        (x==people_left+47 && y==people_up+16) || 
                        (x==people_left+48 && y==people_up+16) || 
                        (x==people_left+49 && y==people_up+16) || 
                        (x==people_left+50 && y==people_up+16) || 
                        (x==people_left+51 && y==people_up+16) || 
                        (x==people_left+52 && y==people_up+16) || 
                        (x==people_left+53 && y==people_up+16) || 
                        (x==people_left+54 && y==people_up+16) || 
                        (x==people_left+55 && y==people_up+16) || 
                        (x==people_left+56 && y==people_up+16) || 
                        (x==people_left+57 && y==people_up+16) || 
                        (x==people_left+58 && y==people_up+16) || 
                        (x==people_left+59 && y==people_up+16) || 
                        (x==people_left+60 && y==people_up+16) || 
                        (x==people_left+61 && y==people_up+16) || 
                        (x==people_left+62 && y==people_up+16) || 
                        (x==people_left+63 && y==people_up+16) || 
                        (x==people_left+64 && y==people_up+16) || 
                        (x==people_left+65 && y==people_up+16) || 
                        (x==people_left+66 && y==people_up+16) || 
                        (x==people_left+67 && y==people_up+16) || 
                        (x==people_left+68 && y==people_up+16) || 
                        (x==people_left+69 && y==people_up+16) || 
                        (x==people_left+70 && y==people_up+16) || 
                        (x==people_left+71 && y==people_up+16) || 
                        (x==people_left+72 && y==people_up+16) || 
                        (x==people_left+73 && y==people_up+16) || 
                        (x==people_left+74 && y==people_up+16) || 
                        (x==people_left+75 && y==people_up+16) || 
                        (x==people_left+76 && y==people_up+16) || 
                        (x==people_left+77 && y==people_up+16) || 
                        (x==people_left+78 && y==people_up+16) || 
                        (x==people_left-40 && y==people_up+17) || 
                        (x==people_left-39 && y==people_up+17) || 
                        (x==people_left-38 && y==people_up+17) || 
                        (x==people_left-37 && y==people_up+17) || 
                        (x==people_left-36 && y==people_up+17) || 
                        (x==people_left-35 && y==people_up+17) || 
                        (x==people_left-34 && y==people_up+17) || 
                        (x==people_left-33 && y==people_up+17) || 
                        (x==people_left-32 && y==people_up+17) || 
                        (x==people_left-31 && y==people_up+17) || 
                        (x==people_left-30 && y==people_up+17) || 
                        (x==people_left-29 && y==people_up+17) || 
                        (x==people_left-28 && y==people_up+17) || 
                        (x==people_left-27 && y==people_up+17) || 
                        (x==people_left-26 && y==people_up+17) || 
                        (x==people_left-25 && y==people_up+17) || 
                        (x==people_left-24 && y==people_up+17) || 
                        (x==people_left-23 && y==people_up+17) || 
                        (x==people_left-22 && y==people_up+17) || 
                        (x==people_left-21 && y==people_up+17) || 
                        (x==people_left-20 && y==people_up+17) || 
                        (x==people_left-19 && y==people_up+17) || 
                        (x==people_left-18 && y==people_up+17) || 
                        (x==people_left-17 && y==people_up+17) || 
                        (x==people_left-16 && y==people_up+17) || 
                        (x==people_left-15 && y==people_up+17) || 
                        (x==people_left-14 && y==people_up+17) || 
                        (x==people_left-13 && y==people_up+17) || 
                        (x==people_left-12 && y==people_up+17) || 
                        (x==people_left-11 && y==people_up+17) || 
                        (x==people_left-10 && y==people_up+17) || 
                        (x==people_left-9 && y==people_up+17) || 
                        (x==people_left-8 && y==people_up+17) || 
                        (x==people_left-7 && y==people_up+17) || 
                        (x==people_left-6 && y==people_up+17) || 
                        (x==people_left-5 && y==people_up+17) || 
                        (x==people_left-4 && y==people_up+17) || 
                        (x==people_left-3 && y==people_up+17) || 
                        (x==people_left-2 && y==people_up+17) || 
                        (x==people_left-1 && y==people_up+17) || 
                        (x==people_left+0 && y==people_up+17) || 
                        (x==people_left+1 && y==people_up+17) || 
                        (x==people_left+2 && y==people_up+17) || 
                        (x==people_left+3 && y==people_up+17) || 
                        (x==people_left+4 && y==people_up+17) || 
                        (x==people_left+5 && y==people_up+17) || 
                        (x==people_left+6 && y==people_up+17) || 
                        (x==people_left+7 && y==people_up+17) || 
                        (x==people_left+8 && y==people_up+17) || 
                        (x==people_left+9 && y==people_up+17) || 
                        (x==people_left+10 && y==people_up+17) || 
                        (x==people_left+11 && y==people_up+17) || 
                        (x==people_left+12 && y==people_up+17) || 
                        (x==people_left+13 && y==people_up+17) || 
                        (x==people_left+14 && y==people_up+17) || 
                        (x==people_left+15 && y==people_up+17) || 
                        (x==people_left+16 && y==people_up+17) || 
                        (x==people_left+17 && y==people_up+17) || 
                        (x==people_left+18 && y==people_up+17) || 
                        (x==people_left+19 && y==people_up+17) || 
                        (x==people_left+20 && y==people_up+17) || 
                        (x==people_left+21 && y==people_up+17) || 
                        (x==people_left+22 && y==people_up+17) || 
                        (x==people_left+23 && y==people_up+17) || 
                        (x==people_left+24 && y==people_up+17) || 
                        (x==people_left+25 && y==people_up+17) || 
                        (x==people_left+26 && y==people_up+17) || 
                        (x==people_left+27 && y==people_up+17) || 
                        (x==people_left+28 && y==people_up+17) || 
                        (x==people_left+29 && y==people_up+17) || 
                        (x==people_left+30 && y==people_up+17) || 
                        (x==people_left+31 && y==people_up+17) || 
                        (x==people_left+32 && y==people_up+17) || 
                        (x==people_left+33 && y==people_up+17) || 
                        (x==people_left+34 && y==people_up+17) || 
                        (x==people_left+35 && y==people_up+17) || 
                        (x==people_left+36 && y==people_up+17) || 
                        (x==people_left+37 && y==people_up+17) || 
                        (x==people_left+38 && y==people_up+17) || 
                        (x==people_left+39 && y==people_up+17) || 
                        (x==people_left+40 && y==people_up+17) || 
                        (x==people_left+41 && y==people_up+17) || 
                        (x==people_left+42 && y==people_up+17) || 
                        (x==people_left+43 && y==people_up+17) || 
                        (x==people_left+44 && y==people_up+17) || 
                        (x==people_left+45 && y==people_up+17) || 
                        (x==people_left+46 && y==people_up+17) || 
                        (x==people_left+47 && y==people_up+17) || 
                        (x==people_left+48 && y==people_up+17) || 
                        (x==people_left+49 && y==people_up+17) || 
                        (x==people_left+50 && y==people_up+17) || 
                        (x==people_left+51 && y==people_up+17) || 
                        (x==people_left+52 && y==people_up+17) || 
                        (x==people_left+53 && y==people_up+17) || 
                        (x==people_left+54 && y==people_up+17) || 
                        (x==people_left+55 && y==people_up+17) || 
                        (x==people_left+56 && y==people_up+17) || 
                        (x==people_left+57 && y==people_up+17) || 
                        (x==people_left+58 && y==people_up+17) || 
                        (x==people_left+59 && y==people_up+17) || 
                        (x==people_left+60 && y==people_up+17) || 
                        (x==people_left+61 && y==people_up+17) || 
                        (x==people_left+62 && y==people_up+17) || 
                        (x==people_left+63 && y==people_up+17) || 
                        (x==people_left+64 && y==people_up+17) || 
                        (x==people_left+65 && y==people_up+17) || 
                        (x==people_left+66 && y==people_up+17) || 
                        (x==people_left+67 && y==people_up+17) || 
                        (x==people_left+68 && y==people_up+17) || 
                        (x==people_left+69 && y==people_up+17) || 
                        (x==people_left+70 && y==people_up+17) || 
                        (x==people_left+71 && y==people_up+17) || 
                        (x==people_left+72 && y==people_up+17) || 
                        (x==people_left+73 && y==people_up+17) || 
                        (x==people_left+74 && y==people_up+17) || 
                        (x==people_left+75 && y==people_up+17) || 
                        (x==people_left+76 && y==people_up+17) || 
                        (x==people_left+77 && y==people_up+17) || 
                        (x==people_left+78 && y==people_up+17) || 
                        (x==people_left-40 && y==people_up+18) || 
                        (x==people_left-39 && y==people_up+18) || 
                        (x==people_left-38 && y==people_up+18) || 
                        (x==people_left-37 && y==people_up+18) || 
                        (x==people_left-36 && y==people_up+18) || 
                        (x==people_left-35 && y==people_up+18) || 
                        (x==people_left-34 && y==people_up+18) || 
                        (x==people_left-33 && y==people_up+18) || 
                        (x==people_left-32 && y==people_up+18) || 
                        (x==people_left-31 && y==people_up+18) || 
                        (x==people_left-30 && y==people_up+18) || 
                        (x==people_left-29 && y==people_up+18) || 
                        (x==people_left-28 && y==people_up+18) || 
                        (x==people_left-27 && y==people_up+18) || 
                        (x==people_left-26 && y==people_up+18) || 
                        (x==people_left-25 && y==people_up+18) || 
                        (x==people_left-24 && y==people_up+18) || 
                        (x==people_left-23 && y==people_up+18) || 
                        (x==people_left-22 && y==people_up+18) || 
                        (x==people_left-21 && y==people_up+18) || 
                        (x==people_left-20 && y==people_up+18) || 
                        (x==people_left-19 && y==people_up+18) || 
                        (x==people_left-18 && y==people_up+18) || 
                        (x==people_left-17 && y==people_up+18) || 
                        (x==people_left-16 && y==people_up+18) || 
                        (x==people_left-15 && y==people_up+18) || 
                        (x==people_left-14 && y==people_up+18) || 
                        (x==people_left-13 && y==people_up+18) || 
                        (x==people_left-12 && y==people_up+18) || 
                        (x==people_left-11 && y==people_up+18) || 
                        (x==people_left-10 && y==people_up+18) || 
                        (x==people_left-9 && y==people_up+18) || 
                        (x==people_left-8 && y==people_up+18) || 
                        (x==people_left-7 && y==people_up+18) || 
                        (x==people_left-6 && y==people_up+18) || 
                        (x==people_left-5 && y==people_up+18) || 
                        (x==people_left-4 && y==people_up+18) || 
                        (x==people_left-3 && y==people_up+18) || 
                        (x==people_left-2 && y==people_up+18) || 
                        (x==people_left-1 && y==people_up+18) || 
                        (x==people_left+0 && y==people_up+18) || 
                        (x==people_left+1 && y==people_up+18) || 
                        (x==people_left+2 && y==people_up+18) || 
                        (x==people_left+3 && y==people_up+18) || 
                        (x==people_left+4 && y==people_up+18) || 
                        (x==people_left+5 && y==people_up+18) || 
                        (x==people_left+6 && y==people_up+18) || 
                        (x==people_left+7 && y==people_up+18) || 
                        (x==people_left+8 && y==people_up+18) || 
                        (x==people_left+9 && y==people_up+18) || 
                        (x==people_left+10 && y==people_up+18) || 
                        (x==people_left+11 && y==people_up+18) || 
                        (x==people_left+12 && y==people_up+18) || 
                        (x==people_left+13 && y==people_up+18) || 
                        (x==people_left+14 && y==people_up+18) || 
                        (x==people_left+15 && y==people_up+18) || 
                        (x==people_left+16 && y==people_up+18) || 
                        (x==people_left+17 && y==people_up+18) || 
                        (x==people_left+18 && y==people_up+18) || 
                        (x==people_left+19 && y==people_up+18) || 
                        (x==people_left+20 && y==people_up+18) || 
                        (x==people_left+21 && y==people_up+18) || 
                        (x==people_left+22 && y==people_up+18) || 
                        (x==people_left+23 && y==people_up+18) || 
                        (x==people_left+24 && y==people_up+18) || 
                        (x==people_left+25 && y==people_up+18) || 
                        (x==people_left+26 && y==people_up+18) || 
                        (x==people_left+27 && y==people_up+18) || 
                        (x==people_left+28 && y==people_up+18) || 
                        (x==people_left+29 && y==people_up+18) || 
                        (x==people_left+30 && y==people_up+18) || 
                        (x==people_left+31 && y==people_up+18) || 
                        (x==people_left+32 && y==people_up+18) || 
                        (x==people_left+33 && y==people_up+18) || 
                        (x==people_left+34 && y==people_up+18) || 
                        (x==people_left+35 && y==people_up+18) || 
                        (x==people_left+36 && y==people_up+18) || 
                        (x==people_left+37 && y==people_up+18) || 
                        (x==people_left+38 && y==people_up+18) || 
                        (x==people_left+39 && y==people_up+18) || 
                        (x==people_left+40 && y==people_up+18) || 
                        (x==people_left+41 && y==people_up+18) || 
                        (x==people_left+42 && y==people_up+18) || 
                        (x==people_left+43 && y==people_up+18) || 
                        (x==people_left+44 && y==people_up+18) || 
                        (x==people_left+45 && y==people_up+18) || 
                        (x==people_left+46 && y==people_up+18) || 
                        (x==people_left+47 && y==people_up+18) || 
                        (x==people_left+48 && y==people_up+18) || 
                        (x==people_left+49 && y==people_up+18) || 
                        (x==people_left+50 && y==people_up+18) || 
                        (x==people_left+51 && y==people_up+18) || 
                        (x==people_left+52 && y==people_up+18) || 
                        (x==people_left+53 && y==people_up+18) || 
                        (x==people_left+54 && y==people_up+18) || 
                        (x==people_left+55 && y==people_up+18) || 
                        (x==people_left+56 && y==people_up+18) || 
                        (x==people_left+57 && y==people_up+18) || 
                        (x==people_left+58 && y==people_up+18) || 
                        (x==people_left+59 && y==people_up+18) || 
                        (x==people_left+60 && y==people_up+18) || 
                        (x==people_left+61 && y==people_up+18) || 
                        (x==people_left+62 && y==people_up+18) || 
                        (x==people_left+63 && y==people_up+18) || 
                        (x==people_left+64 && y==people_up+18) || 
                        (x==people_left+65 && y==people_up+18) || 
                        (x==people_left+66 && y==people_up+18) || 
                        (x==people_left+67 && y==people_up+18) || 
                        (x==people_left+68 && y==people_up+18) || 
                        (x==people_left+69 && y==people_up+18) || 
                        (x==people_left+70 && y==people_up+18) || 
                        (x==people_left+71 && y==people_up+18) || 
                        (x==people_left+72 && y==people_up+18) || 
                        (x==people_left+73 && y==people_up+18) || 
                        (x==people_left+74 && y==people_up+18) || 
                        (x==people_left+75 && y==people_up+18) || 
                        (x==people_left+76 && y==people_up+18) || 
                        (x==people_left+77 && y==people_up+18) || 
                        (x==people_left+78 && y==people_up+18) || 
                        (x==people_left-40 && y==people_up+19) || 
                        (x==people_left-39 && y==people_up+19) || 
                        (x==people_left-38 && y==people_up+19) || 
                        (x==people_left-37 && y==people_up+19) || 
                        (x==people_left-36 && y==people_up+19) || 
                        (x==people_left-35 && y==people_up+19) || 
                        (x==people_left-34 && y==people_up+19) || 
                        (x==people_left-33 && y==people_up+19) || 
                        (x==people_left-32 && y==people_up+19) || 
                        (x==people_left-31 && y==people_up+19) || 
                        (x==people_left-30 && y==people_up+19) || 
                        (x==people_left-29 && y==people_up+19) || 
                        (x==people_left-28 && y==people_up+19) || 
                        (x==people_left-27 && y==people_up+19) || 
                        (x==people_left-26 && y==people_up+19) || 
                        (x==people_left-25 && y==people_up+19) || 
                        (x==people_left-24 && y==people_up+19) || 
                        (x==people_left-23 && y==people_up+19) || 
                        (x==people_left-22 && y==people_up+19) || 
                        (x==people_left-21 && y==people_up+19) || 
                        (x==people_left-20 && y==people_up+19) || 
                        (x==people_left-19 && y==people_up+19) || 
                        (x==people_left-18 && y==people_up+19) || 
                        (x==people_left-17 && y==people_up+19) || 
                        (x==people_left-16 && y==people_up+19) || 
                        (x==people_left-15 && y==people_up+19) || 
                        (x==people_left-14 && y==people_up+19) || 
                        (x==people_left-13 && y==people_up+19) || 
                        (x==people_left-12 && y==people_up+19) || 
                        (x==people_left-11 && y==people_up+19) || 
                        (x==people_left-10 && y==people_up+19) || 
                        (x==people_left-9 && y==people_up+19) || 
                        (x==people_left-8 && y==people_up+19) || 
                        (x==people_left-7 && y==people_up+19) || 
                        (x==people_left-6 && y==people_up+19) || 
                        (x==people_left-5 && y==people_up+19) || 
                        (x==people_left-4 && y==people_up+19) || 
                        (x==people_left-3 && y==people_up+19) || 
                        (x==people_left-2 && y==people_up+19) || 
                        (x==people_left-1 && y==people_up+19) || 
                        (x==people_left+0 && y==people_up+19) || 
                        (x==people_left+1 && y==people_up+19) || 
                        (x==people_left+2 && y==people_up+19) || 
                        (x==people_left+3 && y==people_up+19) || 
                        (x==people_left+4 && y==people_up+19) || 
                        (x==people_left+5 && y==people_up+19) || 
                        (x==people_left+6 && y==people_up+19) || 
                        (x==people_left+7 && y==people_up+19) || 
                        (x==people_left+8 && y==people_up+19) || 
                        (x==people_left+9 && y==people_up+19) || 
                        (x==people_left+10 && y==people_up+19) || 
                        (x==people_left+11 && y==people_up+19) || 
                        (x==people_left+12 && y==people_up+19) || 
                        (x==people_left+13 && y==people_up+19) || 
                        (x==people_left+14 && y==people_up+19) || 
                        (x==people_left+15 && y==people_up+19) || 
                        (x==people_left+16 && y==people_up+19) || 
                        (x==people_left+17 && y==people_up+19) || 
                        (x==people_left+18 && y==people_up+19) || 
                        (x==people_left+19 && y==people_up+19) || 
                        (x==people_left+20 && y==people_up+19) || 
                        (x==people_left+21 && y==people_up+19) || 
                        (x==people_left+22 && y==people_up+19) || 
                        (x==people_left+23 && y==people_up+19) || 
                        (x==people_left+24 && y==people_up+19) || 
                        (x==people_left+25 && y==people_up+19) || 
                        (x==people_left+26 && y==people_up+19) || 
                        (x==people_left+27 && y==people_up+19) || 
                        (x==people_left+28 && y==people_up+19) || 
                        (x==people_left+29 && y==people_up+19) || 
                        (x==people_left+30 && y==people_up+19) || 
                        (x==people_left+31 && y==people_up+19) || 
                        (x==people_left+32 && y==people_up+19) || 
                        (x==people_left+33 && y==people_up+19) || 
                        (x==people_left+34 && y==people_up+19) || 
                        (x==people_left+35 && y==people_up+19) || 
                        (x==people_left+36 && y==people_up+19) || 
                        (x==people_left+37 && y==people_up+19) || 
                        (x==people_left+38 && y==people_up+19) || 
                        (x==people_left+39 && y==people_up+19) || 
                        (x==people_left+40 && y==people_up+19) || 
                        (x==people_left+41 && y==people_up+19) || 
                        (x==people_left+42 && y==people_up+19) || 
                        (x==people_left+43 && y==people_up+19) || 
                        (x==people_left+44 && y==people_up+19) || 
                        (x==people_left+45 && y==people_up+19) || 
                        (x==people_left+46 && y==people_up+19) || 
                        (x==people_left+47 && y==people_up+19) || 
                        (x==people_left+48 && y==people_up+19) || 
                        (x==people_left+49 && y==people_up+19) || 
                        (x==people_left+50 && y==people_up+19) || 
                        (x==people_left+51 && y==people_up+19) || 
                        (x==people_left+52 && y==people_up+19) || 
                        (x==people_left+53 && y==people_up+19) || 
                        (x==people_left+54 && y==people_up+19) || 
                        (x==people_left+55 && y==people_up+19) || 
                        (x==people_left+56 && y==people_up+19) || 
                        (x==people_left+57 && y==people_up+19) || 
                        (x==people_left+58 && y==people_up+19) || 
                        (x==people_left+59 && y==people_up+19) || 
                        (x==people_left+60 && y==people_up+19) || 
                        (x==people_left+61 && y==people_up+19) || 
                        (x==people_left+62 && y==people_up+19) || 
                        (x==people_left+63 && y==people_up+19) || 
                        (x==people_left+64 && y==people_up+19) || 
                        (x==people_left+65 && y==people_up+19) || 
                        (x==people_left+66 && y==people_up+19) || 
                        (x==people_left+67 && y==people_up+19) || 
                        (x==people_left+68 && y==people_up+19) || 
                        (x==people_left+69 && y==people_up+19) || 
                        (x==people_left+70 && y==people_up+19) || 
                        (x==people_left+71 && y==people_up+19) || 
                        (x==people_left+72 && y==people_up+19) || 
                        (x==people_left+73 && y==people_up+19) || 
                        (x==people_left+74 && y==people_up+19) || 
                        (x==people_left+75 && y==people_up+19) || 
                        (x==people_left+76 && y==people_up+19) || 
                        (x==people_left+77 && y==people_up+19) || 
                        (x==people_left+78 && y==people_up+19) || 
                        (x==people_left-40 && y==people_up+20) || 
                        (x==people_left-39 && y==people_up+20) || 
                        (x==people_left-38 && y==people_up+20) || 
                        (x==people_left-37 && y==people_up+20) || 
                        (x==people_left-36 && y==people_up+20) || 
                        (x==people_left-35 && y==people_up+20) || 
                        (x==people_left-34 && y==people_up+20) || 
                        (x==people_left-33 && y==people_up+20) || 
                        (x==people_left-32 && y==people_up+20) || 
                        (x==people_left-31 && y==people_up+20) || 
                        (x==people_left-30 && y==people_up+20) || 
                        (x==people_left-29 && y==people_up+20) || 
                        (x==people_left-28 && y==people_up+20) || 
                        (x==people_left-27 && y==people_up+20) || 
                        (x==people_left-26 && y==people_up+20) || 
                        (x==people_left-25 && y==people_up+20) || 
                        (x==people_left-24 && y==people_up+20) || 
                        (x==people_left-23 && y==people_up+20) || 
                        (x==people_left-22 && y==people_up+20) || 
                        (x==people_left-21 && y==people_up+20) || 
                        (x==people_left-20 && y==people_up+20) || 
                        (x==people_left-19 && y==people_up+20) || 
                        (x==people_left-18 && y==people_up+20) || 
                        (x==people_left-17 && y==people_up+20) || 
                        (x==people_left-16 && y==people_up+20) || 
                        (x==people_left-15 && y==people_up+20) || 
                        (x==people_left-14 && y==people_up+20) || 
                        (x==people_left-13 && y==people_up+20) || 
                        (x==people_left-12 && y==people_up+20) || 
                        (x==people_left-11 && y==people_up+20) || 
                        (x==people_left-10 && y==people_up+20) || 
                        (x==people_left-9 && y==people_up+20) || 
                        (x==people_left-8 && y==people_up+20) || 
                        (x==people_left-7 && y==people_up+20) || 
                        (x==people_left-6 && y==people_up+20) || 
                        (x==people_left-5 && y==people_up+20) || 
                        (x==people_left-4 && y==people_up+20) || 
                        (x==people_left-3 && y==people_up+20) || 
                        (x==people_left-2 && y==people_up+20) || 
                        (x==people_left-1 && y==people_up+20) || 
                        (x==people_left+0 && y==people_up+20) || 
                        (x==people_left+1 && y==people_up+20) || 
                        (x==people_left+2 && y==people_up+20) || 
                        (x==people_left+3 && y==people_up+20) || 
                        (x==people_left+4 && y==people_up+20) || 
                        (x==people_left+5 && y==people_up+20) || 
                        (x==people_left+6 && y==people_up+20) || 
                        (x==people_left+7 && y==people_up+20) || 
                        (x==people_left+8 && y==people_up+20) || 
                        (x==people_left+9 && y==people_up+20) || 
                        (x==people_left+10 && y==people_up+20) || 
                        (x==people_left+11 && y==people_up+20) || 
                        (x==people_left+12 && y==people_up+20) || 
                        (x==people_left+13 && y==people_up+20) || 
                        (x==people_left+14 && y==people_up+20) || 
                        (x==people_left+15 && y==people_up+20) || 
                        (x==people_left+16 && y==people_up+20) || 
                        (x==people_left+17 && y==people_up+20) || 
                        (x==people_left+18 && y==people_up+20) || 
                        (x==people_left+19 && y==people_up+20) || 
                        (x==people_left+20 && y==people_up+20) || 
                        (x==people_left+21 && y==people_up+20) || 
                        (x==people_left+22 && y==people_up+20) || 
                        (x==people_left+23 && y==people_up+20) || 
                        (x==people_left+24 && y==people_up+20) || 
                        (x==people_left+25 && y==people_up+20) || 
                        (x==people_left+26 && y==people_up+20) || 
                        (x==people_left+27 && y==people_up+20) || 
                        (x==people_left+28 && y==people_up+20) || 
                        (x==people_left+29 && y==people_up+20) || 
                        (x==people_left+30 && y==people_up+20) || 
                        (x==people_left+31 && y==people_up+20) || 
                        (x==people_left+32 && y==people_up+20) || 
                        (x==people_left+33 && y==people_up+20) || 
                        (x==people_left+34 && y==people_up+20) || 
                        (x==people_left+35 && y==people_up+20) || 
                        (x==people_left+36 && y==people_up+20) || 
                        (x==people_left+37 && y==people_up+20) || 
                        (x==people_left+38 && y==people_up+20) || 
                        (x==people_left+39 && y==people_up+20) || 
                        (x==people_left+40 && y==people_up+20) || 
                        (x==people_left+41 && y==people_up+20) || 
                        (x==people_left+42 && y==people_up+20) || 
                        (x==people_left+43 && y==people_up+20) || 
                        (x==people_left+44 && y==people_up+20) || 
                        (x==people_left+45 && y==people_up+20) || 
                        (x==people_left+46 && y==people_up+20) || 
                        (x==people_left+47 && y==people_up+20) || 
                        (x==people_left+48 && y==people_up+20) || 
                        (x==people_left+49 && y==people_up+20) || 
                        (x==people_left+50 && y==people_up+20) || 
                        (x==people_left+51 && y==people_up+20) || 
                        (x==people_left+52 && y==people_up+20) || 
                        (x==people_left+53 && y==people_up+20) || 
                        (x==people_left+54 && y==people_up+20) || 
                        (x==people_left+55 && y==people_up+20) || 
                        (x==people_left+56 && y==people_up+20) || 
                        (x==people_left+57 && y==people_up+20) || 
                        (x==people_left+58 && y==people_up+20) || 
                        (x==people_left+59 && y==people_up+20) || 
                        (x==people_left+60 && y==people_up+20) || 
                        (x==people_left+61 && y==people_up+20) || 
                        (x==people_left+62 && y==people_up+20) || 
                        (x==people_left+63 && y==people_up+20) || 
                        (x==people_left+64 && y==people_up+20) || 
                        (x==people_left+65 && y==people_up+20) || 
                        (x==people_left+66 && y==people_up+20) || 
                        (x==people_left+67 && y==people_up+20) || 
                        (x==people_left+68 && y==people_up+20) || 
                        (x==people_left+69 && y==people_up+20) || 
                        (x==people_left+70 && y==people_up+20) || 
                        (x==people_left+71 && y==people_up+20) || 
                        (x==people_left+72 && y==people_up+20) || 
                        (x==people_left+73 && y==people_up+20) || 
                        (x==people_left+74 && y==people_up+20) || 
                        (x==people_left+75 && y==people_up+20) || 
                        (x==people_left+76 && y==people_up+20) || 
                        (x==people_left+77 && y==people_up+20) || 
                        (x==people_left+78 && y==people_up+20) || 
                        (x==people_left-40 && y==people_up+21) || 
                        (x==people_left-39 && y==people_up+21) || 
                        (x==people_left-38 && y==people_up+21) || 
                        (x==people_left-37 && y==people_up+21) || 
                        (x==people_left-36 && y==people_up+21) || 
                        (x==people_left-35 && y==people_up+21) || 
                        (x==people_left-34 && y==people_up+21) || 
                        (x==people_left-33 && y==people_up+21) || 
                        (x==people_left-32 && y==people_up+21) || 
                        (x==people_left-31 && y==people_up+21) || 
                        (x==people_left-30 && y==people_up+21) || 
                        (x==people_left-29 && y==people_up+21) || 
                        (x==people_left-28 && y==people_up+21) || 
                        (x==people_left-27 && y==people_up+21) || 
                        (x==people_left-26 && y==people_up+21) || 
                        (x==people_left-25 && y==people_up+21) || 
                        (x==people_left-24 && y==people_up+21) || 
                        (x==people_left-23 && y==people_up+21) || 
                        (x==people_left-22 && y==people_up+21) || 
                        (x==people_left-21 && y==people_up+21) || 
                        (x==people_left-20 && y==people_up+21) || 
                        (x==people_left-19 && y==people_up+21) || 
                        (x==people_left-18 && y==people_up+21) || 
                        (x==people_left-17 && y==people_up+21) || 
                        (x==people_left-16 && y==people_up+21) || 
                        (x==people_left-15 && y==people_up+21) || 
                        (x==people_left-14 && y==people_up+21) || 
                        (x==people_left-13 && y==people_up+21) || 
                        (x==people_left-12 && y==people_up+21) || 
                        (x==people_left-11 && y==people_up+21) || 
                        (x==people_left-10 && y==people_up+21) || 
                        (x==people_left-9 && y==people_up+21) || 
                        (x==people_left-8 && y==people_up+21) || 
                        (x==people_left-7 && y==people_up+21) || 
                        (x==people_left-6 && y==people_up+21) || 
                        (x==people_left-5 && y==people_up+21) || 
                        (x==people_left-4 && y==people_up+21) || 
                        (x==people_left-3 && y==people_up+21) || 
                        (x==people_left-2 && y==people_up+21) || 
                        (x==people_left-1 && y==people_up+21) || 
                        (x==people_left+0 && y==people_up+21) || 
                        (x==people_left+1 && y==people_up+21) || 
                        (x==people_left+2 && y==people_up+21) || 
                        (x==people_left+3 && y==people_up+21) || 
                        (x==people_left+4 && y==people_up+21) || 
                        (x==people_left+5 && y==people_up+21) || 
                        (x==people_left+6 && y==people_up+21) || 
                        (x==people_left+7 && y==people_up+21) || 
                        (x==people_left+8 && y==people_up+21) || 
                        (x==people_left+9 && y==people_up+21) || 
                        (x==people_left+10 && y==people_up+21) || 
                        (x==people_left+11 && y==people_up+21) || 
                        (x==people_left+12 && y==people_up+21) || 
                        (x==people_left+13 && y==people_up+21) || 
                        (x==people_left+14 && y==people_up+21) || 
                        (x==people_left+15 && y==people_up+21) || 
                        (x==people_left+16 && y==people_up+21) || 
                        (x==people_left+17 && y==people_up+21) || 
                        (x==people_left+18 && y==people_up+21) || 
                        (x==people_left+19 && y==people_up+21) || 
                        (x==people_left+20 && y==people_up+21) || 
                        (x==people_left+21 && y==people_up+21) || 
                        (x==people_left+22 && y==people_up+21) || 
                        (x==people_left+23 && y==people_up+21) || 
                        (x==people_left+24 && y==people_up+21) || 
                        (x==people_left+25 && y==people_up+21) || 
                        (x==people_left+26 && y==people_up+21) || 
                        (x==people_left+27 && y==people_up+21) || 
                        (x==people_left+28 && y==people_up+21) || 
                        (x==people_left+29 && y==people_up+21) || 
                        (x==people_left+30 && y==people_up+21) || 
                        (x==people_left+31 && y==people_up+21) || 
                        (x==people_left+32 && y==people_up+21) || 
                        (x==people_left+33 && y==people_up+21) || 
                        (x==people_left+34 && y==people_up+21) || 
                        (x==people_left+35 && y==people_up+21) || 
                        (x==people_left+36 && y==people_up+21) || 
                        (x==people_left+37 && y==people_up+21) || 
                        (x==people_left+38 && y==people_up+21) || 
                        (x==people_left+39 && y==people_up+21) || 
                        (x==people_left+40 && y==people_up+21) || 
                        (x==people_left+41 && y==people_up+21) || 
                        (x==people_left+42 && y==people_up+21) || 
                        (x==people_left+43 && y==people_up+21) || 
                        (x==people_left+44 && y==people_up+21) || 
                        (x==people_left+45 && y==people_up+21) || 
                        (x==people_left+46 && y==people_up+21) || 
                        (x==people_left+47 && y==people_up+21) || 
                        (x==people_left+48 && y==people_up+21) || 
                        (x==people_left+49 && y==people_up+21) || 
                        (x==people_left+50 && y==people_up+21) || 
                        (x==people_left+51 && y==people_up+21) || 
                        (x==people_left+52 && y==people_up+21) || 
                        (x==people_left+53 && y==people_up+21) || 
                        (x==people_left+54 && y==people_up+21) || 
                        (x==people_left+55 && y==people_up+21) || 
                        (x==people_left+56 && y==people_up+21) || 
                        (x==people_left+57 && y==people_up+21) || 
                        (x==people_left+58 && y==people_up+21) || 
                        (x==people_left+59 && y==people_up+21) || 
                        (x==people_left+60 && y==people_up+21) || 
                        (x==people_left+61 && y==people_up+21) || 
                        (x==people_left+62 && y==people_up+21) || 
                        (x==people_left+63 && y==people_up+21) || 
                        (x==people_left+64 && y==people_up+21) || 
                        (x==people_left+65 && y==people_up+21) || 
                        (x==people_left+66 && y==people_up+21) || 
                        (x==people_left+67 && y==people_up+21) || 
                        (x==people_left+68 && y==people_up+21) || 
                        (x==people_left+69 && y==people_up+21) || 
                        (x==people_left+70 && y==people_up+21) || 
                        (x==people_left+71 && y==people_up+21) || 
                        (x==people_left+72 && y==people_up+21) || 
                        (x==people_left+73 && y==people_up+21) || 
                        (x==people_left+74 && y==people_up+21) || 
                        (x==people_left+75 && y==people_up+21) || 
                        (x==people_left+76 && y==people_up+21) || 
                        (x==people_left+77 && y==people_up+21) || 
                        (x==people_left+78 && y==people_up+21) || 
                        (x==people_left-40 && y==people_up+22) || 
                        (x==people_left-39 && y==people_up+22) || 
                        (x==people_left-38 && y==people_up+22) || 
                        (x==people_left-37 && y==people_up+22) || 
                        (x==people_left-36 && y==people_up+22) || 
                        (x==people_left-35 && y==people_up+22) || 
                        (x==people_left-34 && y==people_up+22) || 
                        (x==people_left-33 && y==people_up+22) || 
                        (x==people_left-32 && y==people_up+22) || 
                        (x==people_left-31 && y==people_up+22) || 
                        (x==people_left-30 && y==people_up+22) || 
                        (x==people_left-29 && y==people_up+22) || 
                        (x==people_left-28 && y==people_up+22) || 
                        (x==people_left-27 && y==people_up+22) || 
                        (x==people_left-26 && y==people_up+22) || 
                        (x==people_left-25 && y==people_up+22) || 
                        (x==people_left-24 && y==people_up+22) || 
                        (x==people_left-23 && y==people_up+22) || 
                        (x==people_left-22 && y==people_up+22) || 
                        (x==people_left-21 && y==people_up+22) || 
                        (x==people_left-20 && y==people_up+22) || 
                        (x==people_left-19 && y==people_up+22) || 
                        (x==people_left-18 && y==people_up+22) || 
                        (x==people_left-17 && y==people_up+22) || 
                        (x==people_left-16 && y==people_up+22) || 
                        (x==people_left-15 && y==people_up+22) || 
                        (x==people_left-14 && y==people_up+22) || 
                        (x==people_left-13 && y==people_up+22) || 
                        (x==people_left-12 && y==people_up+22) || 
                        (x==people_left-11 && y==people_up+22) || 
                        (x==people_left-10 && y==people_up+22) || 
                        (x==people_left-9 && y==people_up+22) || 
                        (x==people_left-8 && y==people_up+22) || 
                        (x==people_left-7 && y==people_up+22) || 
                        (x==people_left-6 && y==people_up+22) || 
                        (x==people_left-5 && y==people_up+22) || 
                        (x==people_left-4 && y==people_up+22) || 
                        (x==people_left-3 && y==people_up+22) || 
                        (x==people_left-2 && y==people_up+22) || 
                        (x==people_left-1 && y==people_up+22) || 
                        (x==people_left+0 && y==people_up+22) || 
                        (x==people_left+1 && y==people_up+22) || 
                        (x==people_left+2 && y==people_up+22) || 
                        (x==people_left+3 && y==people_up+22) || 
                        (x==people_left+4 && y==people_up+22) || 
                        (x==people_left+5 && y==people_up+22) || 
                        (x==people_left+6 && y==people_up+22) || 
                        (x==people_left+7 && y==people_up+22) || 
                        (x==people_left+8 && y==people_up+22) || 
                        (x==people_left+9 && y==people_up+22) || 
                        (x==people_left+10 && y==people_up+22) || 
                        (x==people_left+11 && y==people_up+22) || 
                        (x==people_left+12 && y==people_up+22) || 
                        (x==people_left+13 && y==people_up+22) || 
                        (x==people_left+14 && y==people_up+22) || 
                        (x==people_left+15 && y==people_up+22) || 
                        (x==people_left+16 && y==people_up+22) || 
                        (x==people_left+17 && y==people_up+22) || 
                        (x==people_left+18 && y==people_up+22) || 
                        (x==people_left+19 && y==people_up+22) || 
                        (x==people_left+20 && y==people_up+22) || 
                        (x==people_left+21 && y==people_up+22) || 
                        (x==people_left+22 && y==people_up+22) || 
                        (x==people_left+23 && y==people_up+22) || 
                        (x==people_left+24 && y==people_up+22) || 
                        (x==people_left+25 && y==people_up+22) || 
                        (x==people_left+26 && y==people_up+22) || 
                        (x==people_left+27 && y==people_up+22) || 
                        (x==people_left+28 && y==people_up+22) || 
                        (x==people_left+29 && y==people_up+22) || 
                        (x==people_left+30 && y==people_up+22) || 
                        (x==people_left+31 && y==people_up+22) || 
                        (x==people_left+32 && y==people_up+22) || 
                        (x==people_left+33 && y==people_up+22) || 
                        (x==people_left+34 && y==people_up+22) || 
                        (x==people_left+35 && y==people_up+22) || 
                        (x==people_left+36 && y==people_up+22) || 
                        (x==people_left+37 && y==people_up+22) || 
                        (x==people_left+38 && y==people_up+22) || 
                        (x==people_left+39 && y==people_up+22) || 
                        (x==people_left+40 && y==people_up+22) || 
                        (x==people_left+41 && y==people_up+22) || 
                        (x==people_left+42 && y==people_up+22) || 
                        (x==people_left+43 && y==people_up+22) || 
                        (x==people_left+44 && y==people_up+22) || 
                        (x==people_left+45 && y==people_up+22) || 
                        (x==people_left+46 && y==people_up+22) || 
                        (x==people_left+47 && y==people_up+22) || 
                        (x==people_left+48 && y==people_up+22) || 
                        (x==people_left+49 && y==people_up+22) || 
                        (x==people_left+50 && y==people_up+22) || 
                        (x==people_left+51 && y==people_up+22) || 
                        (x==people_left+52 && y==people_up+22) || 
                        (x==people_left+53 && y==people_up+22) || 
                        (x==people_left+54 && y==people_up+22) || 
                        (x==people_left+55 && y==people_up+22) || 
                        (x==people_left+56 && y==people_up+22) || 
                        (x==people_left+57 && y==people_up+22) || 
                        (x==people_left+58 && y==people_up+22) || 
                        (x==people_left+59 && y==people_up+22) || 
                        (x==people_left+60 && y==people_up+22) || 
                        (x==people_left+61 && y==people_up+22) || 
                        (x==people_left+62 && y==people_up+22) || 
                        (x==people_left+63 && y==people_up+22) || 
                        (x==people_left+64 && y==people_up+22) || 
                        (x==people_left+65 && y==people_up+22) || 
                        (x==people_left+66 && y==people_up+22) || 
                        (x==people_left+67 && y==people_up+22) || 
                        (x==people_left+68 && y==people_up+22) || 
                        (x==people_left+69 && y==people_up+22) || 
                        (x==people_left+70 && y==people_up+22) || 
                        (x==people_left+71 && y==people_up+22) || 
                        (x==people_left+72 && y==people_up+22) || 
                        (x==people_left+73 && y==people_up+22) || 
                        (x==people_left+74 && y==people_up+22) || 
                        (x==people_left+75 && y==people_up+22) || 
                        (x==people_left+76 && y==people_up+22) || 
                        (x==people_left+77 && y==people_up+22) || 
                        (x==people_left+78 && y==people_up+22) || 
                        (x==people_left-40 && y==people_up+23) || 
                        (x==people_left-39 && y==people_up+23) || 
                        (x==people_left-38 && y==people_up+23) || 
                        (x==people_left-37 && y==people_up+23) || 
                        (x==people_left-36 && y==people_up+23) || 
                        (x==people_left-35 && y==people_up+23) || 
                        (x==people_left-34 && y==people_up+23) || 
                        (x==people_left-33 && y==people_up+23) || 
                        (x==people_left-32 && y==people_up+23) || 
                        (x==people_left-31 && y==people_up+23) || 
                        (x==people_left-30 && y==people_up+23) || 
                        (x==people_left-29 && y==people_up+23) || 
                        (x==people_left-28 && y==people_up+23) || 
                        (x==people_left-27 && y==people_up+23) || 
                        (x==people_left-26 && y==people_up+23) || 
                        (x==people_left-25 && y==people_up+23) || 
                        (x==people_left-24 && y==people_up+23) || 
                        (x==people_left-23 && y==people_up+23) || 
                        (x==people_left-22 && y==people_up+23) || 
                        (x==people_left-21 && y==people_up+23) || 
                        (x==people_left-20 && y==people_up+23) || 
                        (x==people_left-19 && y==people_up+23) || 
                        (x==people_left-18 && y==people_up+23) || 
                        (x==people_left-17 && y==people_up+23) || 
                        (x==people_left-16 && y==people_up+23) || 
                        (x==people_left-15 && y==people_up+23) || 
                        (x==people_left-14 && y==people_up+23) || 
                        (x==people_left-13 && y==people_up+23) || 
                        (x==people_left-12 && y==people_up+23) || 
                        (x==people_left-11 && y==people_up+23) || 
                        (x==people_left-10 && y==people_up+23) || 
                        (x==people_left-9 && y==people_up+23) || 
                        (x==people_left-8 && y==people_up+23) || 
                        (x==people_left-7 && y==people_up+23) || 
                        (x==people_left-6 && y==people_up+23) || 
                        (x==people_left-5 && y==people_up+23) || 
                        (x==people_left-4 && y==people_up+23) || 
                        (x==people_left-3 && y==people_up+23) || 
                        (x==people_left-2 && y==people_up+23) || 
                        (x==people_left-1 && y==people_up+23) || 
                        (x==people_left+0 && y==people_up+23) || 
                        (x==people_left+1 && y==people_up+23) || 
                        (x==people_left+2 && y==people_up+23) || 
                        (x==people_left+3 && y==people_up+23) || 
                        (x==people_left+4 && y==people_up+23) || 
                        (x==people_left+5 && y==people_up+23) || 
                        (x==people_left+6 && y==people_up+23) || 
                        (x==people_left+7 && y==people_up+23) || 
                        (x==people_left+8 && y==people_up+23) || 
                        (x==people_left+9 && y==people_up+23) || 
                        (x==people_left+10 && y==people_up+23) || 
                        (x==people_left+11 && y==people_up+23) || 
                        (x==people_left+12 && y==people_up+23) || 
                        (x==people_left+13 && y==people_up+23) || 
                        (x==people_left+14 && y==people_up+23) || 
                        (x==people_left+15 && y==people_up+23) || 
                        (x==people_left+16 && y==people_up+23) || 
                        (x==people_left+17 && y==people_up+23) || 
                        (x==people_left+18 && y==people_up+23) || 
                        (x==people_left+19 && y==people_up+23) || 
                        (x==people_left+20 && y==people_up+23) || 
                        (x==people_left+21 && y==people_up+23) || 
                        (x==people_left+22 && y==people_up+23) || 
                        (x==people_left+23 && y==people_up+23) || 
                        (x==people_left+24 && y==people_up+23) || 
                        (x==people_left+25 && y==people_up+23) || 
                        (x==people_left+26 && y==people_up+23) || 
                        (x==people_left+27 && y==people_up+23) || 
                        (x==people_left+28 && y==people_up+23) || 
                        (x==people_left+29 && y==people_up+23) || 
                        (x==people_left+30 && y==people_up+23) || 
                        (x==people_left+31 && y==people_up+23) || 
                        (x==people_left+32 && y==people_up+23) || 
                        (x==people_left+33 && y==people_up+23) || 
                        (x==people_left+34 && y==people_up+23) || 
                        (x==people_left+35 && y==people_up+23) || 
                        (x==people_left+36 && y==people_up+23) || 
                        (x==people_left+37 && y==people_up+23) || 
                        (x==people_left+38 && y==people_up+23) || 
                        (x==people_left+39 && y==people_up+23) || 
                        (x==people_left+40 && y==people_up+23) || 
                        (x==people_left+41 && y==people_up+23) || 
                        (x==people_left+42 && y==people_up+23) || 
                        (x==people_left+43 && y==people_up+23) || 
                        (x==people_left+44 && y==people_up+23) || 
                        (x==people_left+45 && y==people_up+23) || 
                        (x==people_left+46 && y==people_up+23) || 
                        (x==people_left+47 && y==people_up+23) || 
                        (x==people_left+48 && y==people_up+23) || 
                        (x==people_left+49 && y==people_up+23) || 
                        (x==people_left+50 && y==people_up+23) || 
                        (x==people_left+51 && y==people_up+23) || 
                        (x==people_left+52 && y==people_up+23) || 
                        (x==people_left+53 && y==people_up+23) || 
                        (x==people_left+54 && y==people_up+23) || 
                        (x==people_left+55 && y==people_up+23) || 
                        (x==people_left+56 && y==people_up+23) || 
                        (x==people_left+57 && y==people_up+23) || 
                        (x==people_left+58 && y==people_up+23) || 
                        (x==people_left+59 && y==people_up+23) || 
                        (x==people_left+60 && y==people_up+23) || 
                        (x==people_left+61 && y==people_up+23) || 
                        (x==people_left+62 && y==people_up+23) || 
                        (x==people_left+63 && y==people_up+23) || 
                        (x==people_left+64 && y==people_up+23) || 
                        (x==people_left+65 && y==people_up+23) || 
                        (x==people_left+66 && y==people_up+23) || 
                        (x==people_left+67 && y==people_up+23) || 
                        (x==people_left+68 && y==people_up+23) || 
                        (x==people_left+69 && y==people_up+23) || 
                        (x==people_left+70 && y==people_up+23) || 
                        (x==people_left+71 && y==people_up+23) || 
                        (x==people_left+72 && y==people_up+23) || 
                        (x==people_left+73 && y==people_up+23) || 
                        (x==people_left+74 && y==people_up+23) || 
                        (x==people_left+75 && y==people_up+23) || 
                        (x==people_left+76 && y==people_up+23) || 
                        (x==people_left+77 && y==people_up+23) || 
                        (x==people_left+78 && y==people_up+23) || 
                        (x==people_left-40 && y==people_up+24) || 
                        (x==people_left-39 && y==people_up+24) || 
                        (x==people_left-38 && y==people_up+24) || 
                        (x==people_left-37 && y==people_up+24) || 
                        (x==people_left-36 && y==people_up+24) || 
                        (x==people_left-35 && y==people_up+24) || 
                        (x==people_left-34 && y==people_up+24) || 
                        (x==people_left-33 && y==people_up+24) || 
                        (x==people_left-32 && y==people_up+24) || 
                        (x==people_left-31 && y==people_up+24) || 
                        (x==people_left-30 && y==people_up+24) || 
                        (x==people_left-29 && y==people_up+24) || 
                        (x==people_left-28 && y==people_up+24) || 
                        (x==people_left-27 && y==people_up+24) || 
                        (x==people_left-26 && y==people_up+24) || 
                        (x==people_left-25 && y==people_up+24) || 
                        (x==people_left-24 && y==people_up+24) || 
                        (x==people_left-23 && y==people_up+24) || 
                        (x==people_left-22 && y==people_up+24) || 
                        (x==people_left-21 && y==people_up+24) || 
                        (x==people_left-20 && y==people_up+24) || 
                        (x==people_left-19 && y==people_up+24) || 
                        (x==people_left-18 && y==people_up+24) || 
                        (x==people_left-17 && y==people_up+24) || 
                        (x==people_left-16 && y==people_up+24) || 
                        (x==people_left-15 && y==people_up+24) || 
                        (x==people_left-14 && y==people_up+24) || 
                        (x==people_left-13 && y==people_up+24) || 
                        (x==people_left-12 && y==people_up+24) || 
                        (x==people_left-11 && y==people_up+24) || 
                        (x==people_left-10 && y==people_up+24) || 
                        (x==people_left-9 && y==people_up+24) || 
                        (x==people_left-8 && y==people_up+24) || 
                        (x==people_left-7 && y==people_up+24) || 
                        (x==people_left-6 && y==people_up+24) || 
                        (x==people_left-5 && y==people_up+24) || 
                        (x==people_left-4 && y==people_up+24) || 
                        (x==people_left-3 && y==people_up+24) || 
                        (x==people_left-2 && y==people_up+24) || 
                        (x==people_left-1 && y==people_up+24) || 
                        (x==people_left+0 && y==people_up+24) || 
                        (x==people_left+1 && y==people_up+24) || 
                        (x==people_left+2 && y==people_up+24) || 
                        (x==people_left+3 && y==people_up+24) || 
                        (x==people_left+4 && y==people_up+24) || 
                        (x==people_left+5 && y==people_up+24) || 
                        (x==people_left+6 && y==people_up+24) || 
                        (x==people_left+7 && y==people_up+24) || 
                        (x==people_left+8 && y==people_up+24) || 
                        (x==people_left+9 && y==people_up+24) || 
                        (x==people_left+10 && y==people_up+24) || 
                        (x==people_left+11 && y==people_up+24) || 
                        (x==people_left+12 && y==people_up+24) || 
                        (x==people_left+13 && y==people_up+24) || 
                        (x==people_left+14 && y==people_up+24) || 
                        (x==people_left+15 && y==people_up+24) || 
                        (x==people_left+16 && y==people_up+24) || 
                        (x==people_left+17 && y==people_up+24) || 
                        (x==people_left+18 && y==people_up+24) || 
                        (x==people_left+19 && y==people_up+24) || 
                        (x==people_left+20 && y==people_up+24) || 
                        (x==people_left+21 && y==people_up+24) || 
                        (x==people_left+22 && y==people_up+24) || 
                        (x==people_left+23 && y==people_up+24) || 
                        (x==people_left+24 && y==people_up+24) || 
                        (x==people_left+25 && y==people_up+24) || 
                        (x==people_left+26 && y==people_up+24) || 
                        (x==people_left+27 && y==people_up+24) || 
                        (x==people_left+28 && y==people_up+24) || 
                        (x==people_left+29 && y==people_up+24) || 
                        (x==people_left+30 && y==people_up+24) || 
                        (x==people_left+31 && y==people_up+24) || 
                        (x==people_left+32 && y==people_up+24) || 
                        (x==people_left+33 && y==people_up+24) || 
                        (x==people_left+34 && y==people_up+24) || 
                        (x==people_left+35 && y==people_up+24) || 
                        (x==people_left+36 && y==people_up+24) || 
                        (x==people_left+37 && y==people_up+24) || 
                        (x==people_left+38 && y==people_up+24) || 
                        (x==people_left+39 && y==people_up+24) || 
                        (x==people_left+40 && y==people_up+24) || 
                        (x==people_left+41 && y==people_up+24) || 
                        (x==people_left+42 && y==people_up+24) || 
                        (x==people_left+43 && y==people_up+24) || 
                        (x==people_left+44 && y==people_up+24) || 
                        (x==people_left+45 && y==people_up+24) || 
                        (x==people_left+46 && y==people_up+24) || 
                        (x==people_left+47 && y==people_up+24) || 
                        (x==people_left+48 && y==people_up+24) || 
                        (x==people_left+49 && y==people_up+24) || 
                        (x==people_left+50 && y==people_up+24) || 
                        (x==people_left+51 && y==people_up+24) || 
                        (x==people_left+52 && y==people_up+24) || 
                        (x==people_left+53 && y==people_up+24) || 
                        (x==people_left+54 && y==people_up+24) || 
                        (x==people_left+55 && y==people_up+24) || 
                        (x==people_left+56 && y==people_up+24) || 
                        (x==people_left+57 && y==people_up+24) || 
                        (x==people_left+58 && y==people_up+24) || 
                        (x==people_left+59 && y==people_up+24) || 
                        (x==people_left+60 && y==people_up+24) || 
                        (x==people_left+61 && y==people_up+24) || 
                        (x==people_left+62 && y==people_up+24) || 
                        (x==people_left+63 && y==people_up+24) || 
                        (x==people_left+64 && y==people_up+24) || 
                        (x==people_left+65 && y==people_up+24) || 
                        (x==people_left+66 && y==people_up+24) || 
                        (x==people_left+67 && y==people_up+24) || 
                        (x==people_left+68 && y==people_up+24) || 
                        (x==people_left+69 && y==people_up+24) || 
                        (x==people_left+70 && y==people_up+24) || 
                        (x==people_left+71 && y==people_up+24) || 
                        (x==people_left+72 && y==people_up+24) || 
                        (x==people_left+73 && y==people_up+24) || 
                        (x==people_left+74 && y==people_up+24) || 
                        (x==people_left+75 && y==people_up+24) || 
                        (x==people_left+76 && y==people_up+24) || 
                        (x==people_left+77 && y==people_up+24) || 
                        (x==people_left+78 && y==people_up+24) || 
                        (x==people_left-40 && y==people_up+25) || 
                        (x==people_left-39 && y==people_up+25) || 
                        (x==people_left-38 && y==people_up+25) || 
                        (x==people_left-37 && y==people_up+25) || 
                        (x==people_left-36 && y==people_up+25) || 
                        (x==people_left-35 && y==people_up+25) || 
                        (x==people_left-34 && y==people_up+25) || 
                        (x==people_left-33 && y==people_up+25) || 
                        (x==people_left-32 && y==people_up+25) || 
                        (x==people_left-31 && y==people_up+25) || 
                        (x==people_left-30 && y==people_up+25) || 
                        (x==people_left-29 && y==people_up+25) || 
                        (x==people_left-28 && y==people_up+25) || 
                        (x==people_left-27 && y==people_up+25) || 
                        (x==people_left-26 && y==people_up+25) || 
                        (x==people_left-25 && y==people_up+25) || 
                        (x==people_left-24 && y==people_up+25) || 
                        (x==people_left-23 && y==people_up+25) || 
                        (x==people_left-22 && y==people_up+25) || 
                        (x==people_left-21 && y==people_up+25) || 
                        (x==people_left-20 && y==people_up+25) || 
                        (x==people_left-19 && y==people_up+25) || 
                        (x==people_left-18 && y==people_up+25) || 
                        (x==people_left-17 && y==people_up+25) || 
                        (x==people_left-16 && y==people_up+25) || 
                        (x==people_left-15 && y==people_up+25) || 
                        (x==people_left-14 && y==people_up+25) || 
                        (x==people_left-13 && y==people_up+25) || 
                        (x==people_left-12 && y==people_up+25) || 
                        (x==people_left-11 && y==people_up+25) || 
                        (x==people_left-10 && y==people_up+25) || 
                        (x==people_left-9 && y==people_up+25) || 
                        (x==people_left-8 && y==people_up+25) || 
                        (x==people_left-7 && y==people_up+25) || 
                        (x==people_left-6 && y==people_up+25) || 
                        (x==people_left-5 && y==people_up+25) || 
                        (x==people_left-4 && y==people_up+25) || 
                        (x==people_left-3 && y==people_up+25) || 
                        (x==people_left-2 && y==people_up+25) || 
                        (x==people_left-1 && y==people_up+25) || 
                        (x==people_left+0 && y==people_up+25) || 
                        (x==people_left+1 && y==people_up+25) || 
                        (x==people_left+2 && y==people_up+25) || 
                        (x==people_left+3 && y==people_up+25) || 
                        (x==people_left+4 && y==people_up+25) || 
                        (x==people_left+5 && y==people_up+25) || 
                        (x==people_left+6 && y==people_up+25) || 
                        (x==people_left+7 && y==people_up+25) || 
                        (x==people_left+8 && y==people_up+25) || 
                        (x==people_left+9 && y==people_up+25) || 
                        (x==people_left+10 && y==people_up+25) || 
                        (x==people_left+11 && y==people_up+25) || 
                        (x==people_left+12 && y==people_up+25) || 
                        (x==people_left+13 && y==people_up+25) || 
                        (x==people_left+14 && y==people_up+25) || 
                        (x==people_left+15 && y==people_up+25) || 
                        (x==people_left+16 && y==people_up+25) || 
                        (x==people_left+17 && y==people_up+25) || 
                        (x==people_left+18 && y==people_up+25) || 
                        (x==people_left+19 && y==people_up+25) || 
                        (x==people_left+20 && y==people_up+25) || 
                        (x==people_left+21 && y==people_up+25) || 
                        (x==people_left+22 && y==people_up+25) || 
                        (x==people_left+23 && y==people_up+25) || 
                        (x==people_left+24 && y==people_up+25) || 
                        (x==people_left+25 && y==people_up+25) || 
                        (x==people_left+26 && y==people_up+25) || 
                        (x==people_left+27 && y==people_up+25) || 
                        (x==people_left+28 && y==people_up+25) || 
                        (x==people_left+29 && y==people_up+25) || 
                        (x==people_left+30 && y==people_up+25) || 
                        (x==people_left+31 && y==people_up+25) || 
                        (x==people_left+32 && y==people_up+25) || 
                        (x==people_left+33 && y==people_up+25) || 
                        (x==people_left+34 && y==people_up+25) || 
                        (x==people_left+35 && y==people_up+25) || 
                        (x==people_left+36 && y==people_up+25) || 
                        (x==people_left+37 && y==people_up+25) || 
                        (x==people_left+38 && y==people_up+25) || 
                        (x==people_left+39 && y==people_up+25) || 
                        (x==people_left+40 && y==people_up+25) || 
                        (x==people_left+41 && y==people_up+25) || 
                        (x==people_left+42 && y==people_up+25) || 
                        (x==people_left+43 && y==people_up+25) || 
                        (x==people_left+44 && y==people_up+25) || 
                        (x==people_left+45 && y==people_up+25) || 
                        (x==people_left+46 && y==people_up+25) || 
                        (x==people_left+47 && y==people_up+25) || 
                        (x==people_left+48 && y==people_up+25) || 
                        (x==people_left+49 && y==people_up+25) || 
                        (x==people_left+50 && y==people_up+25) || 
                        (x==people_left+51 && y==people_up+25) || 
                        (x==people_left+52 && y==people_up+25) || 
                        (x==people_left+53 && y==people_up+25) || 
                        (x==people_left+54 && y==people_up+25) || 
                        (x==people_left+55 && y==people_up+25) || 
                        (x==people_left+56 && y==people_up+25) || 
                        (x==people_left+57 && y==people_up+25) || 
                        (x==people_left+58 && y==people_up+25) || 
                        (x==people_left+59 && y==people_up+25) || 
                        (x==people_left+60 && y==people_up+25) || 
                        (x==people_left+61 && y==people_up+25) || 
                        (x==people_left+62 && y==people_up+25) || 
                        (x==people_left+63 && y==people_up+25) || 
                        (x==people_left+64 && y==people_up+25) || 
                        (x==people_left+65 && y==people_up+25) || 
                        (x==people_left+66 && y==people_up+25) || 
                        (x==people_left+67 && y==people_up+25) || 
                        (x==people_left+68 && y==people_up+25) || 
                        (x==people_left+69 && y==people_up+25) || 
                        (x==people_left+70 && y==people_up+25) || 
                        (x==people_left+71 && y==people_up+25) || 
                        (x==people_left+72 && y==people_up+25) || 
                        (x==people_left+73 && y==people_up+25) || 
                        (x==people_left+74 && y==people_up+25) || 
                        (x==people_left+75 && y==people_up+25) || 
                        (x==people_left+76 && y==people_up+25) || 
                        (x==people_left+77 && y==people_up+25) || 
                        (x==people_left+78 && y==people_up+25) || 
                        (x==people_left-40 && y==people_up+26) || 
                        (x==people_left-39 && y==people_up+26) || 
                        (x==people_left-38 && y==people_up+26) || 
                        (x==people_left-37 && y==people_up+26) || 
                        (x==people_left-36 && y==people_up+26) || 
                        (x==people_left-35 && y==people_up+26) || 
                        (x==people_left-34 && y==people_up+26) || 
                        (x==people_left-33 && y==people_up+26) || 
                        (x==people_left-32 && y==people_up+26) || 
                        (x==people_left-31 && y==people_up+26) || 
                        (x==people_left-30 && y==people_up+26) || 
                        (x==people_left-29 && y==people_up+26) || 
                        (x==people_left-28 && y==people_up+26) || 
                        (x==people_left-27 && y==people_up+26) || 
                        (x==people_left-26 && y==people_up+26) || 
                        (x==people_left-25 && y==people_up+26) || 
                        (x==people_left-24 && y==people_up+26) || 
                        (x==people_left-23 && y==people_up+26) || 
                        (x==people_left-22 && y==people_up+26) || 
                        (x==people_left-21 && y==people_up+26) || 
                        (x==people_left-20 && y==people_up+26) || 
                        (x==people_left-19 && y==people_up+26) || 
                        (x==people_left-18 && y==people_up+26) || 
                        (x==people_left-17 && y==people_up+26) || 
                        (x==people_left-16 && y==people_up+26) || 
                        (x==people_left-15 && y==people_up+26) || 
                        (x==people_left-14 && y==people_up+26) || 
                        (x==people_left-13 && y==people_up+26) || 
                        (x==people_left-12 && y==people_up+26) || 
                        (x==people_left-11 && y==people_up+26) || 
                        (x==people_left-10 && y==people_up+26) || 
                        (x==people_left-9 && y==people_up+26) || 
                        (x==people_left-8 && y==people_up+26) || 
                        (x==people_left-7 && y==people_up+26) || 
                        (x==people_left-6 && y==people_up+26) || 
                        (x==people_left-5 && y==people_up+26) || 
                        (x==people_left-4 && y==people_up+26) || 
                        (x==people_left-3 && y==people_up+26) || 
                        (x==people_left-2 && y==people_up+26) || 
                        (x==people_left-1 && y==people_up+26) || 
                        (x==people_left+0 && y==people_up+26) || 
                        (x==people_left+1 && y==people_up+26) || 
                        (x==people_left+2 && y==people_up+26) || 
                        (x==people_left+3 && y==people_up+26) || 
                        (x==people_left+4 && y==people_up+26) || 
                        (x==people_left+5 && y==people_up+26) || 
                        (x==people_left+6 && y==people_up+26) || 
                        (x==people_left+7 && y==people_up+26) || 
                        (x==people_left+8 && y==people_up+26) || 
                        (x==people_left+9 && y==people_up+26) || 
                        (x==people_left+10 && y==people_up+26) || 
                        (x==people_left+11 && y==people_up+26) || 
                        (x==people_left+12 && y==people_up+26) || 
                        (x==people_left+13 && y==people_up+26) || 
                        (x==people_left+14 && y==people_up+26) || 
                        (x==people_left+15 && y==people_up+26) || 
                        (x==people_left+16 && y==people_up+26) || 
                        (x==people_left+17 && y==people_up+26) || 
                        (x==people_left+18 && y==people_up+26) || 
                        (x==people_left+19 && y==people_up+26) || 
                        (x==people_left+20 && y==people_up+26) || 
                        (x==people_left+21 && y==people_up+26) || 
                        (x==people_left+22 && y==people_up+26) || 
                        (x==people_left+23 && y==people_up+26) || 
                        (x==people_left+24 && y==people_up+26) || 
                        (x==people_left+25 && y==people_up+26) || 
                        (x==people_left+26 && y==people_up+26) || 
                        (x==people_left+27 && y==people_up+26) || 
                        (x==people_left+28 && y==people_up+26) || 
                        (x==people_left+29 && y==people_up+26) || 
                        (x==people_left+30 && y==people_up+26) || 
                        (x==people_left+31 && y==people_up+26) || 
                        (x==people_left+32 && y==people_up+26) || 
                        (x==people_left+33 && y==people_up+26) || 
                        (x==people_left+34 && y==people_up+26) || 
                        (x==people_left+35 && y==people_up+26) || 
                        (x==people_left+36 && y==people_up+26) || 
                        (x==people_left+37 && y==people_up+26) || 
                        (x==people_left+38 && y==people_up+26) || 
                        (x==people_left+39 && y==people_up+26) || 
                        (x==people_left+40 && y==people_up+26) || 
                        (x==people_left+41 && y==people_up+26) || 
                        (x==people_left+42 && y==people_up+26) || 
                        (x==people_left+43 && y==people_up+26) || 
                        (x==people_left+44 && y==people_up+26) || 
                        (x==people_left+45 && y==people_up+26) || 
                        (x==people_left+46 && y==people_up+26) || 
                        (x==people_left+47 && y==people_up+26) || 
                        (x==people_left+48 && y==people_up+26) || 
                        (x==people_left+49 && y==people_up+26) || 
                        (x==people_left+50 && y==people_up+26) || 
                        (x==people_left+51 && y==people_up+26) || 
                        (x==people_left+52 && y==people_up+26) || 
                        (x==people_left+53 && y==people_up+26) || 
                        (x==people_left+54 && y==people_up+26) || 
                        (x==people_left+55 && y==people_up+26) || 
                        (x==people_left+56 && y==people_up+26) || 
                        (x==people_left+57 && y==people_up+26) || 
                        (x==people_left+58 && y==people_up+26) || 
                        (x==people_left+59 && y==people_up+26) || 
                        (x==people_left+60 && y==people_up+26) || 
                        (x==people_left+61 && y==people_up+26) || 
                        (x==people_left+62 && y==people_up+26) || 
                        (x==people_left+63 && y==people_up+26) || 
                        (x==people_left+64 && y==people_up+26) || 
                        (x==people_left+65 && y==people_up+26) || 
                        (x==people_left+66 && y==people_up+26) || 
                        (x==people_left+67 && y==people_up+26) || 
                        (x==people_left+68 && y==people_up+26) || 
                        (x==people_left+69 && y==people_up+26) || 
                        (x==people_left+70 && y==people_up+26) || 
                        (x==people_left+71 && y==people_up+26) || 
                        (x==people_left+72 && y==people_up+26) || 
                        (x==people_left+73 && y==people_up+26) || 
                        (x==people_left+74 && y==people_up+26) || 
                        (x==people_left+75 && y==people_up+26) || 
                        (x==people_left+76 && y==people_up+26) || 
                        (x==people_left+77 && y==people_up+26) || 
                        (x==people_left+78 && y==people_up+26) || 
                        (x==people_left-40 && y==people_up+27) || 
                        (x==people_left-39 && y==people_up+27) || 
                        (x==people_left-38 && y==people_up+27) || 
                        (x==people_left-37 && y==people_up+27) || 
                        (x==people_left-36 && y==people_up+27) || 
                        (x==people_left-35 && y==people_up+27) || 
                        (x==people_left-34 && y==people_up+27) || 
                        (x==people_left-33 && y==people_up+27) || 
                        (x==people_left-32 && y==people_up+27) || 
                        (x==people_left-31 && y==people_up+27) || 
                        (x==people_left-30 && y==people_up+27) || 
                        (x==people_left-29 && y==people_up+27) || 
                        (x==people_left-28 && y==people_up+27) || 
                        (x==people_left-27 && y==people_up+27) || 
                        (x==people_left-26 && y==people_up+27) || 
                        (x==people_left-25 && y==people_up+27) || 
                        (x==people_left-24 && y==people_up+27) || 
                        (x==people_left-23 && y==people_up+27) || 
                        (x==people_left-22 && y==people_up+27) || 
                        (x==people_left-21 && y==people_up+27) || 
                        (x==people_left-20 && y==people_up+27) || 
                        (x==people_left-19 && y==people_up+27) || 
                        (x==people_left-18 && y==people_up+27) || 
                        (x==people_left-17 && y==people_up+27) || 
                        (x==people_left-16 && y==people_up+27) || 
                        (x==people_left-15 && y==people_up+27) || 
                        (x==people_left-14 && y==people_up+27) || 
                        (x==people_left-13 && y==people_up+27) || 
                        (x==people_left-12 && y==people_up+27) || 
                        (x==people_left-11 && y==people_up+27) || 
                        (x==people_left-10 && y==people_up+27) || 
                        (x==people_left-9 && y==people_up+27) || 
                        (x==people_left-8 && y==people_up+27) || 
                        (x==people_left-7 && y==people_up+27) || 
                        (x==people_left-6 && y==people_up+27) || 
                        (x==people_left-5 && y==people_up+27) || 
                        (x==people_left-4 && y==people_up+27) || 
                        (x==people_left-3 && y==people_up+27) || 
                        (x==people_left-2 && y==people_up+27) || 
                        (x==people_left-1 && y==people_up+27) || 
                        (x==people_left+0 && y==people_up+27) || 
                        (x==people_left+1 && y==people_up+27) || 
                        (x==people_left+2 && y==people_up+27) || 
                        (x==people_left+3 && y==people_up+27) || 
                        (x==people_left+4 && y==people_up+27) || 
                        (x==people_left+5 && y==people_up+27) || 
                        (x==people_left+6 && y==people_up+27) || 
                        (x==people_left+7 && y==people_up+27) || 
                        (x==people_left+8 && y==people_up+27) || 
                        (x==people_left+9 && y==people_up+27) || 
                        (x==people_left+10 && y==people_up+27) || 
                        (x==people_left+11 && y==people_up+27) || 
                        (x==people_left+12 && y==people_up+27) || 
                        (x==people_left+13 && y==people_up+27) || 
                        (x==people_left+14 && y==people_up+27) || 
                        (x==people_left+15 && y==people_up+27) || 
                        (x==people_left+16 && y==people_up+27) || 
                        (x==people_left+17 && y==people_up+27) || 
                        (x==people_left+18 && y==people_up+27) || 
                        (x==people_left+19 && y==people_up+27) || 
                        (x==people_left+20 && y==people_up+27) || 
                        (x==people_left+21 && y==people_up+27) || 
                        (x==people_left+22 && y==people_up+27) || 
                        (x==people_left+23 && y==people_up+27) || 
                        (x==people_left+24 && y==people_up+27) || 
                        (x==people_left+25 && y==people_up+27) || 
                        (x==people_left+26 && y==people_up+27) || 
                        (x==people_left+27 && y==people_up+27) || 
                        (x==people_left+28 && y==people_up+27) || 
                        (x==people_left+29 && y==people_up+27) || 
                        (x==people_left+30 && y==people_up+27) || 
                        (x==people_left+31 && y==people_up+27) || 
                        (x==people_left+32 && y==people_up+27) || 
                        (x==people_left+33 && y==people_up+27) || 
                        (x==people_left+34 && y==people_up+27) || 
                        (x==people_left+35 && y==people_up+27) || 
                        (x==people_left+36 && y==people_up+27) || 
                        (x==people_left+37 && y==people_up+27) || 
                        (x==people_left+38 && y==people_up+27) || 
                        (x==people_left+39 && y==people_up+27) || 
                        (x==people_left+40 && y==people_up+27) || 
                        (x==people_left+41 && y==people_up+27) || 
                        (x==people_left+42 && y==people_up+27) || 
                        (x==people_left+43 && y==people_up+27) || 
                        (x==people_left+44 && y==people_up+27) || 
                        (x==people_left+45 && y==people_up+27) || 
                        (x==people_left+46 && y==people_up+27) || 
                        (x==people_left+47 && y==people_up+27) || 
                        (x==people_left+48 && y==people_up+27) || 
                        (x==people_left+49 && y==people_up+27) || 
                        (x==people_left+50 && y==people_up+27) || 
                        (x==people_left+51 && y==people_up+27) || 
                        (x==people_left+52 && y==people_up+27) || 
                        (x==people_left+53 && y==people_up+27) || 
                        (x==people_left+54 && y==people_up+27) || 
                        (x==people_left+55 && y==people_up+27) || 
                        (x==people_left+56 && y==people_up+27) || 
                        (x==people_left+57 && y==people_up+27) || 
                        (x==people_left+58 && y==people_up+27) || 
                        (x==people_left+59 && y==people_up+27) || 
                        (x==people_left+60 && y==people_up+27) || 
                        (x==people_left+61 && y==people_up+27) || 
                        (x==people_left+62 && y==people_up+27) || 
                        (x==people_left+63 && y==people_up+27) || 
                        (x==people_left+64 && y==people_up+27) || 
                        (x==people_left+65 && y==people_up+27) || 
                        (x==people_left+66 && y==people_up+27) || 
                        (x==people_left+67 && y==people_up+27) || 
                        (x==people_left+68 && y==people_up+27) || 
                        (x==people_left+69 && y==people_up+27) || 
                        (x==people_left+70 && y==people_up+27) || 
                        (x==people_left+71 && y==people_up+27) || 
                        (x==people_left+72 && y==people_up+27) || 
                        (x==people_left+73 && y==people_up+27) || 
                        (x==people_left+74 && y==people_up+27) || 
                        (x==people_left+75 && y==people_up+27) || 
                        (x==people_left+76 && y==people_up+27) || 
                        (x==people_left+77 && y==people_up+27) || 
                        (x==people_left+78 && y==people_up+27) || 
                        (x==people_left-39 && y==people_up+28) || 
                        (x==people_left-38 && y==people_up+28) || 
                        (x==people_left-37 && y==people_up+28) || 
                        (x==people_left-36 && y==people_up+28) || 
                        (x==people_left-35 && y==people_up+28) || 
                        (x==people_left-34 && y==people_up+28) || 
                        (x==people_left-33 && y==people_up+28) || 
                        (x==people_left-32 && y==people_up+28) || 
                        (x==people_left-31 && y==people_up+28) || 
                        (x==people_left-30 && y==people_up+28) || 
                        (x==people_left-29 && y==people_up+28) || 
                        (x==people_left-28 && y==people_up+28) || 
                        (x==people_left-27 && y==people_up+28) || 
                        (x==people_left-26 && y==people_up+28) || 
                        (x==people_left-25 && y==people_up+28) || 
                        (x==people_left-24 && y==people_up+28) || 
                        (x==people_left-23 && y==people_up+28) || 
                        (x==people_left-22 && y==people_up+28) || 
                        (x==people_left-21 && y==people_up+28) || 
                        (x==people_left-20 && y==people_up+28) || 
                        (x==people_left-19 && y==people_up+28) || 
                        (x==people_left-18 && y==people_up+28) || 
                        (x==people_left-17 && y==people_up+28) || 
                        (x==people_left-16 && y==people_up+28) || 
                        (x==people_left-15 && y==people_up+28) || 
                        (x==people_left-14 && y==people_up+28) || 
                        (x==people_left-13 && y==people_up+28) || 
                        (x==people_left-12 && y==people_up+28) || 
                        (x==people_left-11 && y==people_up+28) || 
                        (x==people_left-10 && y==people_up+28) || 
                        (x==people_left-9 && y==people_up+28) || 
                        (x==people_left-8 && y==people_up+28) || 
                        (x==people_left-7 && y==people_up+28) || 
                        (x==people_left-6 && y==people_up+28) || 
                        (x==people_left-5 && y==people_up+28) || 
                        (x==people_left-4 && y==people_up+28) || 
                        (x==people_left-3 && y==people_up+28) || 
                        (x==people_left-2 && y==people_up+28) || 
                        (x==people_left-1 && y==people_up+28) || 
                        (x==people_left+0 && y==people_up+28) || 
                        (x==people_left+1 && y==people_up+28) || 
                        (x==people_left+2 && y==people_up+28) || 
                        (x==people_left+3 && y==people_up+28) || 
                        (x==people_left+4 && y==people_up+28) || 
                        (x==people_left+5 && y==people_up+28) || 
                        (x==people_left+6 && y==people_up+28) || 
                        (x==people_left+7 && y==people_up+28) || 
                        (x==people_left+8 && y==people_up+28) || 
                        (x==people_left+9 && y==people_up+28) || 
                        (x==people_left+10 && y==people_up+28) || 
                        (x==people_left+11 && y==people_up+28) || 
                        (x==people_left+12 && y==people_up+28) || 
                        (x==people_left+13 && y==people_up+28) || 
                        (x==people_left+14 && y==people_up+28) || 
                        (x==people_left+15 && y==people_up+28) || 
                        (x==people_left+16 && y==people_up+28) || 
                        (x==people_left+17 && y==people_up+28) || 
                        (x==people_left+18 && y==people_up+28) || 
                        (x==people_left+19 && y==people_up+28) || 
                        (x==people_left+20 && y==people_up+28) || 
                        (x==people_left+21 && y==people_up+28) || 
                        (x==people_left+22 && y==people_up+28) || 
                        (x==people_left+23 && y==people_up+28) || 
                        (x==people_left+24 && y==people_up+28) || 
                        (x==people_left+25 && y==people_up+28) || 
                        (x==people_left+26 && y==people_up+28) || 
                        (x==people_left+27 && y==people_up+28) || 
                        (x==people_left+28 && y==people_up+28) || 
                        (x==people_left+29 && y==people_up+28) || 
                        (x==people_left+30 && y==people_up+28) || 
                        (x==people_left+31 && y==people_up+28) || 
                        (x==people_left+32 && y==people_up+28) || 
                        (x==people_left+33 && y==people_up+28) || 
                        (x==people_left+34 && y==people_up+28) || 
                        (x==people_left+35 && y==people_up+28) || 
                        (x==people_left+36 && y==people_up+28) || 
                        (x==people_left+37 && y==people_up+28) || 
                        (x==people_left+38 && y==people_up+28) || 
                        (x==people_left+39 && y==people_up+28) || 
                        (x==people_left+40 && y==people_up+28) || 
                        (x==people_left+41 && y==people_up+28) || 
                        (x==people_left+42 && y==people_up+28) || 
                        (x==people_left+43 && y==people_up+28) || 
                        (x==people_left+44 && y==people_up+28) || 
                        (x==people_left+45 && y==people_up+28) || 
                        (x==people_left+46 && y==people_up+28) || 
                        (x==people_left+47 && y==people_up+28) || 
                        (x==people_left+48 && y==people_up+28) || 
                        (x==people_left+49 && y==people_up+28) || 
                        (x==people_left+50 && y==people_up+28) || 
                        (x==people_left+51 && y==people_up+28) || 
                        (x==people_left+52 && y==people_up+28) || 
                        (x==people_left+53 && y==people_up+28) || 
                        (x==people_left+54 && y==people_up+28) || 
                        (x==people_left+55 && y==people_up+28) || 
                        (x==people_left+56 && y==people_up+28) || 
                        (x==people_left+57 && y==people_up+28) || 
                        (x==people_left+58 && y==people_up+28) || 
                        (x==people_left+59 && y==people_up+28) || 
                        (x==people_left+60 && y==people_up+28) || 
                        (x==people_left+61 && y==people_up+28) || 
                        (x==people_left+62 && y==people_up+28) || 
                        (x==people_left+63 && y==people_up+28) || 
                        (x==people_left+64 && y==people_up+28) || 
                        (x==people_left+65 && y==people_up+28) || 
                        (x==people_left+66 && y==people_up+28) || 
                        (x==people_left+67 && y==people_up+28) || 
                        (x==people_left+68 && y==people_up+28) || 
                        (x==people_left+69 && y==people_up+28) || 
                        (x==people_left+70 && y==people_up+28) || 
                        (x==people_left+71 && y==people_up+28) || 
                        (x==people_left+72 && y==people_up+28) || 
                        (x==people_left+73 && y==people_up+28) || 
                        (x==people_left+74 && y==people_up+28) || 
                        (x==people_left+75 && y==people_up+28) || 
                        (x==people_left+76 && y==people_up+28) || 
                        (x==people_left+77 && y==people_up+28) || 
                        (x==people_left-39 && y==people_up+29) || 
                        (x==people_left-38 && y==people_up+29) || 
                        (x==people_left-37 && y==people_up+29) || 
                        (x==people_left-36 && y==people_up+29) || 
                        (x==people_left-35 && y==people_up+29) || 
                        (x==people_left-34 && y==people_up+29) || 
                        (x==people_left-33 && y==people_up+29) || 
                        (x==people_left-32 && y==people_up+29) || 
                        (x==people_left-31 && y==people_up+29) || 
                        (x==people_left-30 && y==people_up+29) || 
                        (x==people_left-29 && y==people_up+29) || 
                        (x==people_left-28 && y==people_up+29) || 
                        (x==people_left-27 && y==people_up+29) || 
                        (x==people_left-26 && y==people_up+29) || 
                        (x==people_left-25 && y==people_up+29) || 
                        (x==people_left-24 && y==people_up+29) || 
                        (x==people_left-23 && y==people_up+29) || 
                        (x==people_left-22 && y==people_up+29) || 
                        (x==people_left-21 && y==people_up+29) || 
                        (x==people_left-20 && y==people_up+29) || 
                        (x==people_left-19 && y==people_up+29) || 
                        (x==people_left-18 && y==people_up+29) || 
                        (x==people_left-17 && y==people_up+29) || 
                        (x==people_left-16 && y==people_up+29) || 
                        (x==people_left-15 && y==people_up+29) || 
                        (x==people_left-14 && y==people_up+29) || 
                        (x==people_left-13 && y==people_up+29) || 
                        (x==people_left-12 && y==people_up+29) || 
                        (x==people_left-11 && y==people_up+29) || 
                        (x==people_left-10 && y==people_up+29) || 
                        (x==people_left-9 && y==people_up+29) || 
                        (x==people_left-8 && y==people_up+29) || 
                        (x==people_left-7 && y==people_up+29) || 
                        (x==people_left-6 && y==people_up+29) || 
                        (x==people_left-5 && y==people_up+29) || 
                        (x==people_left-4 && y==people_up+29) || 
                        (x==people_left-3 && y==people_up+29) || 
                        (x==people_left-2 && y==people_up+29) || 
                        (x==people_left-1 && y==people_up+29) || 
                        (x==people_left+0 && y==people_up+29) || 
                        (x==people_left+1 && y==people_up+29) || 
                        (x==people_left+2 && y==people_up+29) || 
                        (x==people_left+3 && y==people_up+29) || 
                        (x==people_left+4 && y==people_up+29) || 
                        (x==people_left+5 && y==people_up+29) || 
                        (x==people_left+6 && y==people_up+29) || 
                        (x==people_left+7 && y==people_up+29) || 
                        (x==people_left+8 && y==people_up+29) || 
                        (x==people_left+9 && y==people_up+29) || 
                        (x==people_left+10 && y==people_up+29) || 
                        (x==people_left+11 && y==people_up+29) || 
                        (x==people_left+12 && y==people_up+29) || 
                        (x==people_left+13 && y==people_up+29) || 
                        (x==people_left+14 && y==people_up+29) || 
                        (x==people_left+15 && y==people_up+29) || 
                        (x==people_left+16 && y==people_up+29) || 
                        (x==people_left+17 && y==people_up+29) || 
                        (x==people_left+18 && y==people_up+29) || 
                        (x==people_left+19 && y==people_up+29) || 
                        (x==people_left+20 && y==people_up+29) || 
                        (x==people_left+21 && y==people_up+29) || 
                        (x==people_left+22 && y==people_up+29) || 
                        (x==people_left+23 && y==people_up+29) || 
                        (x==people_left+24 && y==people_up+29) || 
                        (x==people_left+25 && y==people_up+29) || 
                        (x==people_left+26 && y==people_up+29) || 
                        (x==people_left+27 && y==people_up+29) || 
                        (x==people_left+28 && y==people_up+29) || 
                        (x==people_left+29 && y==people_up+29) || 
                        (x==people_left+30 && y==people_up+29) || 
                        (x==people_left+31 && y==people_up+29) || 
                        (x==people_left+32 && y==people_up+29) || 
                        (x==people_left+33 && y==people_up+29) || 
                        (x==people_left+34 && y==people_up+29) || 
                        (x==people_left+35 && y==people_up+29) || 
                        (x==people_left+36 && y==people_up+29) || 
                        (x==people_left+37 && y==people_up+29) || 
                        (x==people_left+38 && y==people_up+29) || 
                        (x==people_left+39 && y==people_up+29) || 
                        (x==people_left+40 && y==people_up+29) || 
                        (x==people_left+41 && y==people_up+29) || 
                        (x==people_left+42 && y==people_up+29) || 
                        (x==people_left+43 && y==people_up+29) || 
                        (x==people_left+44 && y==people_up+29) || 
                        (x==people_left+45 && y==people_up+29) || 
                        (x==people_left+46 && y==people_up+29) || 
                        (x==people_left+47 && y==people_up+29) || 
                        (x==people_left+48 && y==people_up+29) || 
                        (x==people_left+49 && y==people_up+29) || 
                        (x==people_left+50 && y==people_up+29) || 
                        (x==people_left+51 && y==people_up+29) || 
                        (x==people_left+52 && y==people_up+29) || 
                        (x==people_left+53 && y==people_up+29) || 
                        (x==people_left+54 && y==people_up+29) || 
                        (x==people_left+55 && y==people_up+29) || 
                        (x==people_left+56 && y==people_up+29) || 
                        (x==people_left+57 && y==people_up+29) || 
                        (x==people_left+58 && y==people_up+29) || 
                        (x==people_left+59 && y==people_up+29) || 
                        (x==people_left+60 && y==people_up+29) || 
                        (x==people_left+61 && y==people_up+29) || 
                        (x==people_left+62 && y==people_up+29) || 
                        (x==people_left+63 && y==people_up+29) || 
                        (x==people_left+64 && y==people_up+29) || 
                        (x==people_left+65 && y==people_up+29) || 
                        (x==people_left+66 && y==people_up+29) || 
                        (x==people_left+67 && y==people_up+29) || 
                        (x==people_left+68 && y==people_up+29) || 
                        (x==people_left+69 && y==people_up+29) || 
                        (x==people_left+70 && y==people_up+29) || 
                        (x==people_left+71 && y==people_up+29) || 
                        (x==people_left+72 && y==people_up+29) || 
                        (x==people_left+73 && y==people_up+29) || 
                        (x==people_left+74 && y==people_up+29) || 
                        (x==people_left+75 && y==people_up+29) || 
                        (x==people_left+76 && y==people_up+29) || 
                        (x==people_left+77 && y==people_up+29) || 
                        (x==people_left-39 && y==people_up+30) || 
                        (x==people_left-38 && y==people_up+30) || 
                        (x==people_left-37 && y==people_up+30) || 
                        (x==people_left-36 && y==people_up+30) || 
                        (x==people_left-35 && y==people_up+30) || 
                        (x==people_left-34 && y==people_up+30) || 
                        (x==people_left-33 && y==people_up+30) || 
                        (x==people_left-32 && y==people_up+30) || 
                        (x==people_left-31 && y==people_up+30) || 
                        (x==people_left-30 && y==people_up+30) || 
                        (x==people_left-29 && y==people_up+30) || 
                        (x==people_left-28 && y==people_up+30) || 
                        (x==people_left-27 && y==people_up+30) || 
                        (x==people_left-26 && y==people_up+30) || 
                        (x==people_left-25 && y==people_up+30) || 
                        (x==people_left-24 && y==people_up+30) || 
                        (x==people_left-23 && y==people_up+30) || 
                        (x==people_left-22 && y==people_up+30) || 
                        (x==people_left-21 && y==people_up+30) || 
                        (x==people_left-20 && y==people_up+30) || 
                        (x==people_left-19 && y==people_up+30) || 
                        (x==people_left-18 && y==people_up+30) || 
                        (x==people_left-17 && y==people_up+30) || 
                        (x==people_left-16 && y==people_up+30) || 
                        (x==people_left-15 && y==people_up+30) || 
                        (x==people_left-14 && y==people_up+30) || 
                        (x==people_left-13 && y==people_up+30) || 
                        (x==people_left-12 && y==people_up+30) || 
                        (x==people_left-11 && y==people_up+30) || 
                        (x==people_left-10 && y==people_up+30) || 
                        (x==people_left-9 && y==people_up+30) || 
                        (x==people_left-8 && y==people_up+30) || 
                        (x==people_left-7 && y==people_up+30) || 
                        (x==people_left-6 && y==people_up+30) || 
                        (x==people_left-5 && y==people_up+30) || 
                        (x==people_left-4 && y==people_up+30) || 
                        (x==people_left-3 && y==people_up+30) || 
                        (x==people_left-2 && y==people_up+30) || 
                        (x==people_left-1 && y==people_up+30) || 
                        (x==people_left+0 && y==people_up+30) || 
                        (x==people_left+1 && y==people_up+30) || 
                        (x==people_left+2 && y==people_up+30) || 
                        (x==people_left+3 && y==people_up+30) || 
                        (x==people_left+4 && y==people_up+30) || 
                        (x==people_left+5 && y==people_up+30) || 
                        (x==people_left+6 && y==people_up+30) || 
                        (x==people_left+7 && y==people_up+30) || 
                        (x==people_left+8 && y==people_up+30) || 
                        (x==people_left+9 && y==people_up+30) || 
                        (x==people_left+10 && y==people_up+30) || 
                        (x==people_left+11 && y==people_up+30) || 
                        (x==people_left+12 && y==people_up+30) || 
                        (x==people_left+13 && y==people_up+30) || 
                        (x==people_left+14 && y==people_up+30) || 
                        (x==people_left+15 && y==people_up+30) || 
                        (x==people_left+16 && y==people_up+30) || 
                        (x==people_left+17 && y==people_up+30) || 
                        (x==people_left+18 && y==people_up+30) || 
                        (x==people_left+19 && y==people_up+30) || 
                        (x==people_left+20 && y==people_up+30) || 
                        (x==people_left+21 && y==people_up+30) || 
                        (x==people_left+22 && y==people_up+30) || 
                        (x==people_left+23 && y==people_up+30) || 
                        (x==people_left+24 && y==people_up+30) || 
                        (x==people_left+25 && y==people_up+30) || 
                        (x==people_left+26 && y==people_up+30) || 
                        (x==people_left+27 && y==people_up+30) || 
                        (x==people_left+28 && y==people_up+30) || 
                        (x==people_left+29 && y==people_up+30) || 
                        (x==people_left+30 && y==people_up+30) || 
                        (x==people_left+31 && y==people_up+30) || 
                        (x==people_left+32 && y==people_up+30) || 
                        (x==people_left+33 && y==people_up+30) || 
                        (x==people_left+34 && y==people_up+30) || 
                        (x==people_left+35 && y==people_up+30) || 
                        (x==people_left+36 && y==people_up+30) || 
                        (x==people_left+37 && y==people_up+30) || 
                        (x==people_left+38 && y==people_up+30) || 
                        (x==people_left+39 && y==people_up+30) || 
                        (x==people_left+40 && y==people_up+30) || 
                        (x==people_left+41 && y==people_up+30) || 
                        (x==people_left+42 && y==people_up+30) || 
                        (x==people_left+43 && y==people_up+30) || 
                        (x==people_left+44 && y==people_up+30) || 
                        (x==people_left+45 && y==people_up+30) || 
                        (x==people_left+46 && y==people_up+30) || 
                        (x==people_left+47 && y==people_up+30) || 
                        (x==people_left+48 && y==people_up+30) || 
                        (x==people_left+49 && y==people_up+30) || 
                        (x==people_left+50 && y==people_up+30) || 
                        (x==people_left+51 && y==people_up+30) || 
                        (x==people_left+52 && y==people_up+30) || 
                        (x==people_left+53 && y==people_up+30) || 
                        (x==people_left+54 && y==people_up+30) || 
                        (x==people_left+55 && y==people_up+30) || 
                        (x==people_left+56 && y==people_up+30) || 
                        (x==people_left+57 && y==people_up+30) || 
                        (x==people_left+58 && y==people_up+30) || 
                        (x==people_left+59 && y==people_up+30) || 
                        (x==people_left+60 && y==people_up+30) || 
                        (x==people_left+61 && y==people_up+30) || 
                        (x==people_left+62 && y==people_up+30) || 
                        (x==people_left+63 && y==people_up+30) || 
                        (x==people_left+64 && y==people_up+30) || 
                        (x==people_left+65 && y==people_up+30) || 
                        (x==people_left+66 && y==people_up+30) || 
                        (x==people_left+67 && y==people_up+30) || 
                        (x==people_left+68 && y==people_up+30) || 
                        (x==people_left+69 && y==people_up+30) || 
                        (x==people_left+70 && y==people_up+30) || 
                        (x==people_left+71 && y==people_up+30) || 
                        (x==people_left+72 && y==people_up+30) || 
                        (x==people_left+73 && y==people_up+30) || 
                        (x==people_left+74 && y==people_up+30) || 
                        (x==people_left+75 && y==people_up+30) || 
                        (x==people_left+76 && y==people_up+30) || 
                        (x==people_left+77 && y==people_up+30) || 
                        (x==people_left-39 && y==people_up+31) || 
                        (x==people_left-38 && y==people_up+31) || 
                        (x==people_left-37 && y==people_up+31) || 
                        (x==people_left-36 && y==people_up+31) || 
                        (x==people_left-35 && y==people_up+31) || 
                        (x==people_left-34 && y==people_up+31) || 
                        (x==people_left-33 && y==people_up+31) || 
                        (x==people_left-32 && y==people_up+31) || 
                        (x==people_left-31 && y==people_up+31) || 
                        (x==people_left-30 && y==people_up+31) || 
                        (x==people_left-29 && y==people_up+31) || 
                        (x==people_left-28 && y==people_up+31) || 
                        (x==people_left-27 && y==people_up+31) || 
                        (x==people_left-26 && y==people_up+31) || 
                        (x==people_left-25 && y==people_up+31) || 
                        (x==people_left-24 && y==people_up+31) || 
                        (x==people_left-23 && y==people_up+31) || 
                        (x==people_left-22 && y==people_up+31) || 
                        (x==people_left-21 && y==people_up+31) || 
                        (x==people_left-20 && y==people_up+31) || 
                        (x==people_left-19 && y==people_up+31) || 
                        (x==people_left-18 && y==people_up+31) || 
                        (x==people_left-17 && y==people_up+31) || 
                        (x==people_left-16 && y==people_up+31) || 
                        (x==people_left-15 && y==people_up+31) || 
                        (x==people_left-14 && y==people_up+31) || 
                        (x==people_left-13 && y==people_up+31) || 
                        (x==people_left-12 && y==people_up+31) || 
                        (x==people_left-11 && y==people_up+31) || 
                        (x==people_left-10 && y==people_up+31) || 
                        (x==people_left-9 && y==people_up+31) || 
                        (x==people_left-8 && y==people_up+31) || 
                        (x==people_left-7 && y==people_up+31) || 
                        (x==people_left-6 && y==people_up+31) || 
                        (x==people_left-5 && y==people_up+31) || 
                        (x==people_left-4 && y==people_up+31) || 
                        (x==people_left-3 && y==people_up+31) || 
                        (x==people_left-2 && y==people_up+31) || 
                        (x==people_left-1 && y==people_up+31) || 
                        (x==people_left+0 && y==people_up+31) || 
                        (x==people_left+1 && y==people_up+31) || 
                        (x==people_left+2 && y==people_up+31) || 
                        (x==people_left+3 && y==people_up+31) || 
                        (x==people_left+4 && y==people_up+31) || 
                        (x==people_left+5 && y==people_up+31) || 
                        (x==people_left+6 && y==people_up+31) || 
                        (x==people_left+7 && y==people_up+31) || 
                        (x==people_left+8 && y==people_up+31) || 
                        (x==people_left+9 && y==people_up+31) || 
                        (x==people_left+10 && y==people_up+31) || 
                        (x==people_left+11 && y==people_up+31) || 
                        (x==people_left+12 && y==people_up+31) || 
                        (x==people_left+13 && y==people_up+31) || 
                        (x==people_left+14 && y==people_up+31) || 
                        (x==people_left+15 && y==people_up+31) || 
                        (x==people_left+16 && y==people_up+31) || 
                        (x==people_left+17 && y==people_up+31) || 
                        (x==people_left+18 && y==people_up+31) || 
                        (x==people_left+19 && y==people_up+31) || 
                        (x==people_left+20 && y==people_up+31) || 
                        (x==people_left+21 && y==people_up+31) || 
                        (x==people_left+22 && y==people_up+31) || 
                        (x==people_left+23 && y==people_up+31) || 
                        (x==people_left+24 && y==people_up+31) || 
                        (x==people_left+25 && y==people_up+31) || 
                        (x==people_left+26 && y==people_up+31) || 
                        (x==people_left+27 && y==people_up+31) || 
                        (x==people_left+28 && y==people_up+31) || 
                        (x==people_left+29 && y==people_up+31) || 
                        (x==people_left+30 && y==people_up+31) || 
                        (x==people_left+31 && y==people_up+31) || 
                        (x==people_left+32 && y==people_up+31) || 
                        (x==people_left+33 && y==people_up+31) || 
                        (x==people_left+34 && y==people_up+31) || 
                        (x==people_left+35 && y==people_up+31) || 
                        (x==people_left+36 && y==people_up+31) || 
                        (x==people_left+37 && y==people_up+31) || 
                        (x==people_left+38 && y==people_up+31) || 
                        (x==people_left+39 && y==people_up+31) || 
                        (x==people_left+40 && y==people_up+31) || 
                        (x==people_left+41 && y==people_up+31) || 
                        (x==people_left+42 && y==people_up+31) || 
                        (x==people_left+43 && y==people_up+31) || 
                        (x==people_left+44 && y==people_up+31) || 
                        (x==people_left+45 && y==people_up+31) || 
                        (x==people_left+46 && y==people_up+31) || 
                        (x==people_left+47 && y==people_up+31) || 
                        (x==people_left+48 && y==people_up+31) || 
                        (x==people_left+49 && y==people_up+31) || 
                        (x==people_left+50 && y==people_up+31) || 
                        (x==people_left+51 && y==people_up+31) || 
                        (x==people_left+52 && y==people_up+31) || 
                        (x==people_left+53 && y==people_up+31) || 
                        (x==people_left+54 && y==people_up+31) || 
                        (x==people_left+55 && y==people_up+31) || 
                        (x==people_left+56 && y==people_up+31) || 
                        (x==people_left+57 && y==people_up+31) || 
                        (x==people_left+58 && y==people_up+31) || 
                        (x==people_left+59 && y==people_up+31) || 
                        (x==people_left+60 && y==people_up+31) || 
                        (x==people_left+61 && y==people_up+31) || 
                        (x==people_left+62 && y==people_up+31) || 
                        (x==people_left+63 && y==people_up+31) || 
                        (x==people_left+64 && y==people_up+31) || 
                        (x==people_left+65 && y==people_up+31) || 
                        (x==people_left+66 && y==people_up+31) || 
                        (x==people_left+67 && y==people_up+31) || 
                        (x==people_left+68 && y==people_up+31) || 
                        (x==people_left+69 && y==people_up+31) || 
                        (x==people_left+70 && y==people_up+31) || 
                        (x==people_left+71 && y==people_up+31) || 
                        (x==people_left+72 && y==people_up+31) || 
                        (x==people_left+73 && y==people_up+31) || 
                        (x==people_left+74 && y==people_up+31) || 
                        (x==people_left+75 && y==people_up+31) || 
                        (x==people_left+76 && y==people_up+31) || 
                        (x==people_left+77 && y==people_up+31) || 
                        (x==people_left-39 && y==people_up+32) || 
                        (x==people_left-38 && y==people_up+32) || 
                        (x==people_left-37 && y==people_up+32) || 
                        (x==people_left-36 && y==people_up+32) || 
                        (x==people_left-35 && y==people_up+32) || 
                        (x==people_left-34 && y==people_up+32) || 
                        (x==people_left-33 && y==people_up+32) || 
                        (x==people_left-32 && y==people_up+32) || 
                        (x==people_left-31 && y==people_up+32) || 
                        (x==people_left-30 && y==people_up+32) || 
                        (x==people_left-29 && y==people_up+32) || 
                        (x==people_left-28 && y==people_up+32) || 
                        (x==people_left-27 && y==people_up+32) || 
                        (x==people_left-26 && y==people_up+32) || 
                        (x==people_left-25 && y==people_up+32) || 
                        (x==people_left-24 && y==people_up+32) || 
                        (x==people_left-23 && y==people_up+32) || 
                        (x==people_left-22 && y==people_up+32) || 
                        (x==people_left-21 && y==people_up+32) || 
                        (x==people_left-20 && y==people_up+32) || 
                        (x==people_left-19 && y==people_up+32) || 
                        (x==people_left-18 && y==people_up+32) || 
                        (x==people_left-17 && y==people_up+32) || 
                        (x==people_left-16 && y==people_up+32) || 
                        (x==people_left-15 && y==people_up+32) || 
                        (x==people_left-14 && y==people_up+32) || 
                        (x==people_left-13 && y==people_up+32) || 
                        (x==people_left-12 && y==people_up+32) || 
                        (x==people_left-11 && y==people_up+32) || 
                        (x==people_left-10 && y==people_up+32) || 
                        (x==people_left-9 && y==people_up+32) || 
                        (x==people_left-8 && y==people_up+32) || 
                        (x==people_left-7 && y==people_up+32) || 
                        (x==people_left-6 && y==people_up+32) || 
                        (x==people_left-5 && y==people_up+32) || 
                        (x==people_left-4 && y==people_up+32) || 
                        (x==people_left-3 && y==people_up+32) || 
                        (x==people_left-2 && y==people_up+32) || 
                        (x==people_left-1 && y==people_up+32) || 
                        (x==people_left+0 && y==people_up+32) || 
                        (x==people_left+1 && y==people_up+32) || 
                        (x==people_left+2 && y==people_up+32) || 
                        (x==people_left+3 && y==people_up+32) || 
                        (x==people_left+4 && y==people_up+32) || 
                        (x==people_left+5 && y==people_up+32) || 
                        (x==people_left+6 && y==people_up+32) || 
                        (x==people_left+7 && y==people_up+32) || 
                        (x==people_left+8 && y==people_up+32) || 
                        (x==people_left+9 && y==people_up+32) || 
                        (x==people_left+10 && y==people_up+32) || 
                        (x==people_left+11 && y==people_up+32) || 
                        (x==people_left+12 && y==people_up+32) || 
                        (x==people_left+13 && y==people_up+32) || 
                        (x==people_left+14 && y==people_up+32) || 
                        (x==people_left+15 && y==people_up+32) || 
                        (x==people_left+16 && y==people_up+32) || 
                        (x==people_left+17 && y==people_up+32) || 
                        (x==people_left+18 && y==people_up+32) || 
                        (x==people_left+19 && y==people_up+32) || 
                        (x==people_left+20 && y==people_up+32) || 
                        (x==people_left+21 && y==people_up+32) || 
                        (x==people_left+22 && y==people_up+32) || 
                        (x==people_left+23 && y==people_up+32) || 
                        (x==people_left+24 && y==people_up+32) || 
                        (x==people_left+25 && y==people_up+32) || 
                        (x==people_left+26 && y==people_up+32) || 
                        (x==people_left+27 && y==people_up+32) || 
                        (x==people_left+28 && y==people_up+32) || 
                        (x==people_left+29 && y==people_up+32) || 
                        (x==people_left+30 && y==people_up+32) || 
                        (x==people_left+31 && y==people_up+32) || 
                        (x==people_left+32 && y==people_up+32) || 
                        (x==people_left+33 && y==people_up+32) || 
                        (x==people_left+34 && y==people_up+32) || 
                        (x==people_left+35 && y==people_up+32) || 
                        (x==people_left+36 && y==people_up+32) || 
                        (x==people_left+37 && y==people_up+32) || 
                        (x==people_left+38 && y==people_up+32) || 
                        (x==people_left+39 && y==people_up+32) || 
                        (x==people_left+40 && y==people_up+32) || 
                        (x==people_left+41 && y==people_up+32) || 
                        (x==people_left+42 && y==people_up+32) || 
                        (x==people_left+43 && y==people_up+32) || 
                        (x==people_left+44 && y==people_up+32) || 
                        (x==people_left+45 && y==people_up+32) || 
                        (x==people_left+46 && y==people_up+32) || 
                        (x==people_left+47 && y==people_up+32) || 
                        (x==people_left+48 && y==people_up+32) || 
                        (x==people_left+49 && y==people_up+32) || 
                        (x==people_left+50 && y==people_up+32) || 
                        (x==people_left+51 && y==people_up+32) || 
                        (x==people_left+52 && y==people_up+32) || 
                        (x==people_left+53 && y==people_up+32) || 
                        (x==people_left+54 && y==people_up+32) || 
                        (x==people_left+55 && y==people_up+32) || 
                        (x==people_left+56 && y==people_up+32) || 
                        (x==people_left+57 && y==people_up+32) || 
                        (x==people_left+58 && y==people_up+32) || 
                        (x==people_left+59 && y==people_up+32) || 
                        (x==people_left+60 && y==people_up+32) || 
                        (x==people_left+61 && y==people_up+32) || 
                        (x==people_left+62 && y==people_up+32) || 
                        (x==people_left+63 && y==people_up+32) || 
                        (x==people_left+64 && y==people_up+32) || 
                        (x==people_left+65 && y==people_up+32) || 
                        (x==people_left+66 && y==people_up+32) || 
                        (x==people_left+67 && y==people_up+32) || 
                        (x==people_left+68 && y==people_up+32) || 
                        (x==people_left+69 && y==people_up+32) || 
                        (x==people_left+70 && y==people_up+32) || 
                        (x==people_left+71 && y==people_up+32) || 
                        (x==people_left+72 && y==people_up+32) || 
                        (x==people_left+73 && y==people_up+32) || 
                        (x==people_left+74 && y==people_up+32) || 
                        (x==people_left+75 && y==people_up+32) || 
                        (x==people_left+76 && y==people_up+32) || 
                        (x==people_left+77 && y==people_up+32) || 
                        (x==people_left-38 && y==people_up+33) || 
                        (x==people_left-37 && y==people_up+33) || 
                        (x==people_left-36 && y==people_up+33) || 
                        (x==people_left-35 && y==people_up+33) || 
                        (x==people_left-34 && y==people_up+33) || 
                        (x==people_left-33 && y==people_up+33) || 
                        (x==people_left-32 && y==people_up+33) || 
                        (x==people_left-31 && y==people_up+33) || 
                        (x==people_left-30 && y==people_up+33) || 
                        (x==people_left-29 && y==people_up+33) || 
                        (x==people_left-28 && y==people_up+33) || 
                        (x==people_left-27 && y==people_up+33) || 
                        (x==people_left-26 && y==people_up+33) || 
                        (x==people_left-25 && y==people_up+33) || 
                        (x==people_left-24 && y==people_up+33) || 
                        (x==people_left-23 && y==people_up+33) || 
                        (x==people_left-22 && y==people_up+33) || 
                        (x==people_left-21 && y==people_up+33) || 
                        (x==people_left-20 && y==people_up+33) || 
                        (x==people_left-19 && y==people_up+33) || 
                        (x==people_left-18 && y==people_up+33) || 
                        (x==people_left-17 && y==people_up+33) || 
                        (x==people_left-16 && y==people_up+33) || 
                        (x==people_left-15 && y==people_up+33) || 
                        (x==people_left-14 && y==people_up+33) || 
                        (x==people_left-13 && y==people_up+33) || 
                        (x==people_left-12 && y==people_up+33) || 
                        (x==people_left-11 && y==people_up+33) || 
                        (x==people_left-10 && y==people_up+33) || 
                        (x==people_left-9 && y==people_up+33) || 
                        (x==people_left-8 && y==people_up+33) || 
                        (x==people_left-7 && y==people_up+33) || 
                        (x==people_left-6 && y==people_up+33) || 
                        (x==people_left-5 && y==people_up+33) || 
                        (x==people_left-4 && y==people_up+33) || 
                        (x==people_left-3 && y==people_up+33) || 
                        (x==people_left-2 && y==people_up+33) || 
                        (x==people_left-1 && y==people_up+33) || 
                        (x==people_left+0 && y==people_up+33) || 
                        (x==people_left+1 && y==people_up+33) || 
                        (x==people_left+2 && y==people_up+33) || 
                        (x==people_left+3 && y==people_up+33) || 
                        (x==people_left+4 && y==people_up+33) || 
                        (x==people_left+5 && y==people_up+33) || 
                        (x==people_left+6 && y==people_up+33) || 
                        (x==people_left+7 && y==people_up+33) || 
                        (x==people_left+8 && y==people_up+33) || 
                        (x==people_left+9 && y==people_up+33) || 
                        (x==people_left+10 && y==people_up+33) || 
                        (x==people_left+11 && y==people_up+33) || 
                        (x==people_left+12 && y==people_up+33) || 
                        (x==people_left+13 && y==people_up+33) || 
                        (x==people_left+14 && y==people_up+33) || 
                        (x==people_left+15 && y==people_up+33) || 
                        (x==people_left+16 && y==people_up+33) || 
                        (x==people_left+17 && y==people_up+33) || 
                        (x==people_left+18 && y==people_up+33) || 
                        (x==people_left+19 && y==people_up+33) || 
                        (x==people_left+20 && y==people_up+33) || 
                        (x==people_left+21 && y==people_up+33) || 
                        (x==people_left+22 && y==people_up+33) || 
                        (x==people_left+23 && y==people_up+33) || 
                        (x==people_left+24 && y==people_up+33) || 
                        (x==people_left+25 && y==people_up+33) || 
                        (x==people_left+26 && y==people_up+33) || 
                        (x==people_left+27 && y==people_up+33) || 
                        (x==people_left+28 && y==people_up+33) || 
                        (x==people_left+29 && y==people_up+33) || 
                        (x==people_left+30 && y==people_up+33) || 
                        (x==people_left+31 && y==people_up+33) || 
                        (x==people_left+32 && y==people_up+33) || 
                        (x==people_left+33 && y==people_up+33) || 
                        (x==people_left+34 && y==people_up+33) || 
                        (x==people_left+35 && y==people_up+33) || 
                        (x==people_left+36 && y==people_up+33) || 
                        (x==people_left+37 && y==people_up+33) || 
                        (x==people_left+38 && y==people_up+33) || 
                        (x==people_left+39 && y==people_up+33) || 
                        (x==people_left+40 && y==people_up+33) || 
                        (x==people_left+41 && y==people_up+33) || 
                        (x==people_left+42 && y==people_up+33) || 
                        (x==people_left+43 && y==people_up+33) || 
                        (x==people_left+44 && y==people_up+33) || 
                        (x==people_left+45 && y==people_up+33) || 
                        (x==people_left+46 && y==people_up+33) || 
                        (x==people_left+47 && y==people_up+33) || 
                        (x==people_left+48 && y==people_up+33) || 
                        (x==people_left+49 && y==people_up+33) || 
                        (x==people_left+50 && y==people_up+33) || 
                        (x==people_left+51 && y==people_up+33) || 
                        (x==people_left+52 && y==people_up+33) || 
                        (x==people_left+53 && y==people_up+33) || 
                        (x==people_left+54 && y==people_up+33) || 
                        (x==people_left+55 && y==people_up+33) || 
                        (x==people_left+56 && y==people_up+33) || 
                        (x==people_left+57 && y==people_up+33) || 
                        (x==people_left+58 && y==people_up+33) || 
                        (x==people_left+59 && y==people_up+33) || 
                        (x==people_left+60 && y==people_up+33) || 
                        (x==people_left+61 && y==people_up+33) || 
                        (x==people_left+62 && y==people_up+33) || 
                        (x==people_left+63 && y==people_up+33) || 
                        (x==people_left+64 && y==people_up+33) || 
                        (x==people_left+65 && y==people_up+33) || 
                        (x==people_left+66 && y==people_up+33) || 
                        (x==people_left+67 && y==people_up+33) || 
                        (x==people_left+68 && y==people_up+33) || 
                        (x==people_left+69 && y==people_up+33) || 
                        (x==people_left+70 && y==people_up+33) || 
                        (x==people_left+71 && y==people_up+33) || 
                        (x==people_left+72 && y==people_up+33) || 
                        (x==people_left+73 && y==people_up+33) || 
                        (x==people_left+74 && y==people_up+33) || 
                        (x==people_left+75 && y==people_up+33) || 
                        (x==people_left+76 && y==people_up+33) || 
                        (x==people_left-38 && y==people_up+34) || 
                        (x==people_left-37 && y==people_up+34) || 
                        (x==people_left-36 && y==people_up+34) || 
                        (x==people_left-35 && y==people_up+34) || 
                        (x==people_left-34 && y==people_up+34) || 
                        (x==people_left-33 && y==people_up+34) || 
                        (x==people_left-32 && y==people_up+34) || 
                        (x==people_left-31 && y==people_up+34) || 
                        (x==people_left-30 && y==people_up+34) || 
                        (x==people_left-29 && y==people_up+34) || 
                        (x==people_left-28 && y==people_up+34) || 
                        (x==people_left-27 && y==people_up+34) || 
                        (x==people_left-26 && y==people_up+34) || 
                        (x==people_left-25 && y==people_up+34) || 
                        (x==people_left-24 && y==people_up+34) || 
                        (x==people_left-23 && y==people_up+34) || 
                        (x==people_left-22 && y==people_up+34) || 
                        (x==people_left-21 && y==people_up+34) || 
                        (x==people_left-20 && y==people_up+34) || 
                        (x==people_left-19 && y==people_up+34) || 
                        (x==people_left-18 && y==people_up+34) || 
                        (x==people_left-17 && y==people_up+34) || 
                        (x==people_left-16 && y==people_up+34) || 
                        (x==people_left-15 && y==people_up+34) || 
                        (x==people_left-14 && y==people_up+34) || 
                        (x==people_left-13 && y==people_up+34) || 
                        (x==people_left-12 && y==people_up+34) || 
                        (x==people_left-11 && y==people_up+34) || 
                        (x==people_left-10 && y==people_up+34) || 
                        (x==people_left-9 && y==people_up+34) || 
                        (x==people_left-8 && y==people_up+34) || 
                        (x==people_left-7 && y==people_up+34) || 
                        (x==people_left-6 && y==people_up+34) || 
                        (x==people_left-5 && y==people_up+34) || 
                        (x==people_left-4 && y==people_up+34) || 
                        (x==people_left-3 && y==people_up+34) || 
                        (x==people_left-2 && y==people_up+34) || 
                        (x==people_left-1 && y==people_up+34) || 
                        (x==people_left+0 && y==people_up+34) || 
                        (x==people_left+1 && y==people_up+34) || 
                        (x==people_left+2 && y==people_up+34) || 
                        (x==people_left+3 && y==people_up+34) || 
                        (x==people_left+4 && y==people_up+34) || 
                        (x==people_left+5 && y==people_up+34) || 
                        (x==people_left+6 && y==people_up+34) || 
                        (x==people_left+7 && y==people_up+34) || 
                        (x==people_left+8 && y==people_up+34) || 
                        (x==people_left+9 && y==people_up+34) || 
                        (x==people_left+10 && y==people_up+34) || 
                        (x==people_left+11 && y==people_up+34) || 
                        (x==people_left+12 && y==people_up+34) || 
                        (x==people_left+13 && y==people_up+34) || 
                        (x==people_left+14 && y==people_up+34) || 
                        (x==people_left+15 && y==people_up+34) || 
                        (x==people_left+16 && y==people_up+34) || 
                        (x==people_left+17 && y==people_up+34) || 
                        (x==people_left+18 && y==people_up+34) || 
                        (x==people_left+19 && y==people_up+34) || 
                        (x==people_left+20 && y==people_up+34) || 
                        (x==people_left+21 && y==people_up+34) || 
                        (x==people_left+22 && y==people_up+34) || 
                        (x==people_left+23 && y==people_up+34) || 
                        (x==people_left+24 && y==people_up+34) || 
                        (x==people_left+25 && y==people_up+34) || 
                        (x==people_left+26 && y==people_up+34) || 
                        (x==people_left+27 && y==people_up+34) || 
                        (x==people_left+28 && y==people_up+34) || 
                        (x==people_left+29 && y==people_up+34) || 
                        (x==people_left+30 && y==people_up+34) || 
                        (x==people_left+31 && y==people_up+34) || 
                        (x==people_left+32 && y==people_up+34) || 
                        (x==people_left+33 && y==people_up+34) || 
                        (x==people_left+34 && y==people_up+34) || 
                        (x==people_left+35 && y==people_up+34) || 
                        (x==people_left+36 && y==people_up+34) || 
                        (x==people_left+37 && y==people_up+34) || 
                        (x==people_left+38 && y==people_up+34) || 
                        (x==people_left+39 && y==people_up+34) || 
                        (x==people_left+40 && y==people_up+34) || 
                        (x==people_left+41 && y==people_up+34) || 
                        (x==people_left+42 && y==people_up+34) || 
                        (x==people_left+43 && y==people_up+34) || 
                        (x==people_left+44 && y==people_up+34) || 
                        (x==people_left+45 && y==people_up+34) || 
                        (x==people_left+46 && y==people_up+34) || 
                        (x==people_left+47 && y==people_up+34) || 
                        (x==people_left+48 && y==people_up+34) || 
                        (x==people_left+49 && y==people_up+34) || 
                        (x==people_left+50 && y==people_up+34) || 
                        (x==people_left+51 && y==people_up+34) || 
                        (x==people_left+52 && y==people_up+34) || 
                        (x==people_left+53 && y==people_up+34) || 
                        (x==people_left+54 && y==people_up+34) || 
                        (x==people_left+55 && y==people_up+34) || 
                        (x==people_left+56 && y==people_up+34) || 
                        (x==people_left+57 && y==people_up+34) || 
                        (x==people_left+58 && y==people_up+34) || 
                        (x==people_left+59 && y==people_up+34) || 
                        (x==people_left+60 && y==people_up+34) || 
                        (x==people_left+61 && y==people_up+34) || 
                        (x==people_left+62 && y==people_up+34) || 
                        (x==people_left+63 && y==people_up+34) || 
                        (x==people_left+64 && y==people_up+34) || 
                        (x==people_left+65 && y==people_up+34) || 
                        (x==people_left+66 && y==people_up+34) || 
                        (x==people_left+67 && y==people_up+34) || 
                        (x==people_left+68 && y==people_up+34) || 
                        (x==people_left+69 && y==people_up+34) || 
                        (x==people_left+70 && y==people_up+34) || 
                        (x==people_left+71 && y==people_up+34) || 
                        (x==people_left+72 && y==people_up+34) || 
                        (x==people_left+73 && y==people_up+34) || 
                        (x==people_left+74 && y==people_up+34) || 
                        (x==people_left+75 && y==people_up+34) || 
                        (x==people_left+76 && y==people_up+34) || 
                        (x==people_left-38 && y==people_up+35) || 
                        (x==people_left-37 && y==people_up+35) || 
                        (x==people_left-36 && y==people_up+35) || 
                        (x==people_left-35 && y==people_up+35) || 
                        (x==people_left-34 && y==people_up+35) || 
                        (x==people_left-33 && y==people_up+35) || 
                        (x==people_left-32 && y==people_up+35) || 
                        (x==people_left-31 && y==people_up+35) || 
                        (x==people_left-30 && y==people_up+35) || 
                        (x==people_left-29 && y==people_up+35) || 
                        (x==people_left-28 && y==people_up+35) || 
                        (x==people_left-27 && y==people_up+35) || 
                        (x==people_left-26 && y==people_up+35) || 
                        (x==people_left-25 && y==people_up+35) || 
                        (x==people_left-24 && y==people_up+35) || 
                        (x==people_left-23 && y==people_up+35) || 
                        (x==people_left-22 && y==people_up+35) || 
                        (x==people_left-21 && y==people_up+35) || 
                        (x==people_left-20 && y==people_up+35) || 
                        (x==people_left-19 && y==people_up+35) || 
                        (x==people_left-18 && y==people_up+35) || 
                        (x==people_left-17 && y==people_up+35) || 
                        (x==people_left-16 && y==people_up+35) || 
                        (x==people_left-15 && y==people_up+35) || 
                        (x==people_left-14 && y==people_up+35) || 
                        (x==people_left-13 && y==people_up+35) || 
                        (x==people_left-12 && y==people_up+35) || 
                        (x==people_left-11 && y==people_up+35) || 
                        (x==people_left-10 && y==people_up+35) || 
                        (x==people_left-9 && y==people_up+35) || 
                        (x==people_left-8 && y==people_up+35) || 
                        (x==people_left-7 && y==people_up+35) || 
                        (x==people_left-6 && y==people_up+35) || 
                        (x==people_left-5 && y==people_up+35) || 
                        (x==people_left-4 && y==people_up+35) || 
                        (x==people_left-3 && y==people_up+35) || 
                        (x==people_left-2 && y==people_up+35) || 
                        (x==people_left-1 && y==people_up+35) || 
                        (x==people_left+0 && y==people_up+35) || 
                        (x==people_left+1 && y==people_up+35) || 
                        (x==people_left+2 && y==people_up+35) || 
                        (x==people_left+3 && y==people_up+35) || 
                        (x==people_left+4 && y==people_up+35) || 
                        (x==people_left+5 && y==people_up+35) || 
                        (x==people_left+6 && y==people_up+35) || 
                        (x==people_left+7 && y==people_up+35) || 
                        (x==people_left+8 && y==people_up+35) || 
                        (x==people_left+9 && y==people_up+35) || 
                        (x==people_left+10 && y==people_up+35) || 
                        (x==people_left+11 && y==people_up+35) || 
                        (x==people_left+12 && y==people_up+35) || 
                        (x==people_left+13 && y==people_up+35) || 
                        (x==people_left+14 && y==people_up+35) || 
                        (x==people_left+15 && y==people_up+35) || 
                        (x==people_left+16 && y==people_up+35) || 
                        (x==people_left+17 && y==people_up+35) || 
                        (x==people_left+18 && y==people_up+35) || 
                        (x==people_left+19 && y==people_up+35) || 
                        (x==people_left+20 && y==people_up+35) || 
                        (x==people_left+21 && y==people_up+35) || 
                        (x==people_left+22 && y==people_up+35) || 
                        (x==people_left+23 && y==people_up+35) || 
                        (x==people_left+24 && y==people_up+35) || 
                        (x==people_left+25 && y==people_up+35) || 
                        (x==people_left+26 && y==people_up+35) || 
                        (x==people_left+27 && y==people_up+35) || 
                        (x==people_left+28 && y==people_up+35) || 
                        (x==people_left+29 && y==people_up+35) || 
                        (x==people_left+30 && y==people_up+35) || 
                        (x==people_left+31 && y==people_up+35) || 
                        (x==people_left+32 && y==people_up+35) || 
                        (x==people_left+33 && y==people_up+35) || 
                        (x==people_left+34 && y==people_up+35) || 
                        (x==people_left+35 && y==people_up+35) || 
                        (x==people_left+36 && y==people_up+35) || 
                        (x==people_left+37 && y==people_up+35) || 
                        (x==people_left+38 && y==people_up+35) || 
                        (x==people_left+39 && y==people_up+35) || 
                        (x==people_left+40 && y==people_up+35) || 
                        (x==people_left+41 && y==people_up+35) || 
                        (x==people_left+42 && y==people_up+35) || 
                        (x==people_left+43 && y==people_up+35) || 
                        (x==people_left+44 && y==people_up+35) || 
                        (x==people_left+45 && y==people_up+35) || 
                        (x==people_left+46 && y==people_up+35) || 
                        (x==people_left+47 && y==people_up+35) || 
                        (x==people_left+48 && y==people_up+35) || 
                        (x==people_left+49 && y==people_up+35) || 
                        (x==people_left+50 && y==people_up+35) || 
                        (x==people_left+51 && y==people_up+35) || 
                        (x==people_left+52 && y==people_up+35) || 
                        (x==people_left+53 && y==people_up+35) || 
                        (x==people_left+54 && y==people_up+35) || 
                        (x==people_left+55 && y==people_up+35) || 
                        (x==people_left+56 && y==people_up+35) || 
                        (x==people_left+57 && y==people_up+35) || 
                        (x==people_left+58 && y==people_up+35) || 
                        (x==people_left+59 && y==people_up+35) || 
                        (x==people_left+60 && y==people_up+35) || 
                        (x==people_left+61 && y==people_up+35) || 
                        (x==people_left+62 && y==people_up+35) || 
                        (x==people_left+63 && y==people_up+35) || 
                        (x==people_left+64 && y==people_up+35) || 
                        (x==people_left+65 && y==people_up+35) || 
                        (x==people_left+66 && y==people_up+35) || 
                        (x==people_left+67 && y==people_up+35) || 
                        (x==people_left+68 && y==people_up+35) || 
                        (x==people_left+69 && y==people_up+35) || 
                        (x==people_left+70 && y==people_up+35) || 
                        (x==people_left+71 && y==people_up+35) || 
                        (x==people_left+72 && y==people_up+35) || 
                        (x==people_left+73 && y==people_up+35) || 
                        (x==people_left+74 && y==people_up+35) || 
                        (x==people_left+75 && y==people_up+35) || 
                        (x==people_left+76 && y==people_up+35) || 
                        (x==people_left-38 && y==people_up+36) || 
                        (x==people_left-37 && y==people_up+36) || 
                        (x==people_left-36 && y==people_up+36) || 
                        (x==people_left-35 && y==people_up+36) || 
                        (x==people_left-34 && y==people_up+36) || 
                        (x==people_left-33 && y==people_up+36) || 
                        (x==people_left-32 && y==people_up+36) || 
                        (x==people_left-31 && y==people_up+36) || 
                        (x==people_left-30 && y==people_up+36) || 
                        (x==people_left-29 && y==people_up+36) || 
                        (x==people_left-28 && y==people_up+36) || 
                        (x==people_left-27 && y==people_up+36) || 
                        (x==people_left-26 && y==people_up+36) || 
                        (x==people_left-25 && y==people_up+36) || 
                        (x==people_left-24 && y==people_up+36) || 
                        (x==people_left-23 && y==people_up+36) || 
                        (x==people_left-22 && y==people_up+36) || 
                        (x==people_left-21 && y==people_up+36) || 
                        (x==people_left-20 && y==people_up+36) || 
                        (x==people_left-19 && y==people_up+36) || 
                        (x==people_left-18 && y==people_up+36) || 
                        (x==people_left-17 && y==people_up+36) || 
                        (x==people_left-16 && y==people_up+36) || 
                        (x==people_left-15 && y==people_up+36) || 
                        (x==people_left-14 && y==people_up+36) || 
                        (x==people_left-13 && y==people_up+36) || 
                        (x==people_left-12 && y==people_up+36) || 
                        (x==people_left-11 && y==people_up+36) || 
                        (x==people_left-10 && y==people_up+36) || 
                        (x==people_left-9 && y==people_up+36) || 
                        (x==people_left-8 && y==people_up+36) || 
                        (x==people_left-7 && y==people_up+36) || 
                        (x==people_left-6 && y==people_up+36) || 
                        (x==people_left-5 && y==people_up+36) || 
                        (x==people_left-4 && y==people_up+36) || 
                        (x==people_left-3 && y==people_up+36) || 
                        (x==people_left-2 && y==people_up+36) || 
                        (x==people_left-1 && y==people_up+36) || 
                        (x==people_left+0 && y==people_up+36) || 
                        (x==people_left+1 && y==people_up+36) || 
                        (x==people_left+2 && y==people_up+36) || 
                        (x==people_left+3 && y==people_up+36) || 
                        (x==people_left+4 && y==people_up+36) || 
                        (x==people_left+5 && y==people_up+36) || 
                        (x==people_left+6 && y==people_up+36) || 
                        (x==people_left+7 && y==people_up+36) || 
                        (x==people_left+8 && y==people_up+36) || 
                        (x==people_left+9 && y==people_up+36) || 
                        (x==people_left+10 && y==people_up+36) || 
                        (x==people_left+11 && y==people_up+36) || 
                        (x==people_left+12 && y==people_up+36) || 
                        (x==people_left+13 && y==people_up+36) || 
                        (x==people_left+14 && y==people_up+36) || 
                        (x==people_left+15 && y==people_up+36) || 
                        (x==people_left+16 && y==people_up+36) || 
                        (x==people_left+17 && y==people_up+36) || 
                        (x==people_left+18 && y==people_up+36) || 
                        (x==people_left+19 && y==people_up+36) || 
                        (x==people_left+20 && y==people_up+36) || 
                        (x==people_left+21 && y==people_up+36) || 
                        (x==people_left+22 && y==people_up+36) || 
                        (x==people_left+23 && y==people_up+36) || 
                        (x==people_left+24 && y==people_up+36) || 
                        (x==people_left+25 && y==people_up+36) || 
                        (x==people_left+26 && y==people_up+36) || 
                        (x==people_left+27 && y==people_up+36) || 
                        (x==people_left+28 && y==people_up+36) || 
                        (x==people_left+29 && y==people_up+36) || 
                        (x==people_left+30 && y==people_up+36) || 
                        (x==people_left+31 && y==people_up+36) || 
                        (x==people_left+32 && y==people_up+36) || 
                        (x==people_left+33 && y==people_up+36) || 
                        (x==people_left+34 && y==people_up+36) || 
                        (x==people_left+35 && y==people_up+36) || 
                        (x==people_left+36 && y==people_up+36) || 
                        (x==people_left+37 && y==people_up+36) || 
                        (x==people_left+38 && y==people_up+36) || 
                        (x==people_left+39 && y==people_up+36) || 
                        (x==people_left+40 && y==people_up+36) || 
                        (x==people_left+41 && y==people_up+36) || 
                        (x==people_left+42 && y==people_up+36) || 
                        (x==people_left+43 && y==people_up+36) || 
                        (x==people_left+44 && y==people_up+36) || 
                        (x==people_left+45 && y==people_up+36) || 
                        (x==people_left+46 && y==people_up+36) || 
                        (x==people_left+47 && y==people_up+36) || 
                        (x==people_left+48 && y==people_up+36) || 
                        (x==people_left+49 && y==people_up+36) || 
                        (x==people_left+50 && y==people_up+36) || 
                        (x==people_left+51 && y==people_up+36) || 
                        (x==people_left+52 && y==people_up+36) || 
                        (x==people_left+53 && y==people_up+36) || 
                        (x==people_left+54 && y==people_up+36) || 
                        (x==people_left+55 && y==people_up+36) || 
                        (x==people_left+56 && y==people_up+36) || 
                        (x==people_left+57 && y==people_up+36) || 
                        (x==people_left+58 && y==people_up+36) || 
                        (x==people_left+59 && y==people_up+36) || 
                        (x==people_left+60 && y==people_up+36) || 
                        (x==people_left+61 && y==people_up+36) || 
                        (x==people_left+62 && y==people_up+36) || 
                        (x==people_left+63 && y==people_up+36) || 
                        (x==people_left+64 && y==people_up+36) || 
                        (x==people_left+65 && y==people_up+36) || 
                        (x==people_left+66 && y==people_up+36) || 
                        (x==people_left+67 && y==people_up+36) || 
                        (x==people_left+68 && y==people_up+36) || 
                        (x==people_left+69 && y==people_up+36) || 
                        (x==people_left+70 && y==people_up+36) || 
                        (x==people_left+71 && y==people_up+36) || 
                        (x==people_left+72 && y==people_up+36) || 
                        (x==people_left+73 && y==people_up+36) || 
                        (x==people_left+74 && y==people_up+36) || 
                        (x==people_left+75 && y==people_up+36) || 
                        (x==people_left+76 && y==people_up+36) || 
                        (x==people_left-37 && y==people_up+37) || 
                        (x==people_left-36 && y==people_up+37) || 
                        (x==people_left-35 && y==people_up+37) || 
                        (x==people_left-34 && y==people_up+37) || 
                        (x==people_left-33 && y==people_up+37) || 
                        (x==people_left-32 && y==people_up+37) || 
                        (x==people_left-31 && y==people_up+37) || 
                        (x==people_left-30 && y==people_up+37) || 
                        (x==people_left-29 && y==people_up+37) || 
                        (x==people_left-28 && y==people_up+37) || 
                        (x==people_left-27 && y==people_up+37) || 
                        (x==people_left-26 && y==people_up+37) || 
                        (x==people_left-25 && y==people_up+37) || 
                        (x==people_left-24 && y==people_up+37) || 
                        (x==people_left-23 && y==people_up+37) || 
                        (x==people_left-22 && y==people_up+37) || 
                        (x==people_left-21 && y==people_up+37) || 
                        (x==people_left-20 && y==people_up+37) || 
                        (x==people_left-19 && y==people_up+37) || 
                        (x==people_left-18 && y==people_up+37) || 
                        (x==people_left-17 && y==people_up+37) || 
                        (x==people_left-16 && y==people_up+37) || 
                        (x==people_left-15 && y==people_up+37) || 
                        (x==people_left-14 && y==people_up+37) || 
                        (x==people_left-13 && y==people_up+37) || 
                        (x==people_left-12 && y==people_up+37) || 
                        (x==people_left-11 && y==people_up+37) || 
                        (x==people_left-10 && y==people_up+37) || 
                        (x==people_left-9 && y==people_up+37) || 
                        (x==people_left-8 && y==people_up+37) || 
                        (x==people_left-7 && y==people_up+37) || 
                        (x==people_left-6 && y==people_up+37) || 
                        (x==people_left-5 && y==people_up+37) || 
                        (x==people_left-4 && y==people_up+37) || 
                        (x==people_left-3 && y==people_up+37) || 
                        (x==people_left-2 && y==people_up+37) || 
                        (x==people_left-1 && y==people_up+37) || 
                        (x==people_left+0 && y==people_up+37) || 
                        (x==people_left+1 && y==people_up+37) || 
                        (x==people_left+2 && y==people_up+37) || 
                        (x==people_left+3 && y==people_up+37) || 
                        (x==people_left+4 && y==people_up+37) || 
                        (x==people_left+5 && y==people_up+37) || 
                        (x==people_left+6 && y==people_up+37) || 
                        (x==people_left+7 && y==people_up+37) || 
                        (x==people_left+8 && y==people_up+37) || 
                        (x==people_left+9 && y==people_up+37) || 
                        (x==people_left+10 && y==people_up+37) || 
                        (x==people_left+11 && y==people_up+37) || 
                        (x==people_left+12 && y==people_up+37) || 
                        (x==people_left+13 && y==people_up+37) || 
                        (x==people_left+14 && y==people_up+37) || 
                        (x==people_left+15 && y==people_up+37) || 
                        (x==people_left+16 && y==people_up+37) || 
                        (x==people_left+17 && y==people_up+37) || 
                        (x==people_left+18 && y==people_up+37) || 
                        (x==people_left+19 && y==people_up+37) || 
                        (x==people_left+20 && y==people_up+37) || 
                        (x==people_left+21 && y==people_up+37) || 
                        (x==people_left+22 && y==people_up+37) || 
                        (x==people_left+23 && y==people_up+37) || 
                        (x==people_left+24 && y==people_up+37) || 
                        (x==people_left+25 && y==people_up+37) || 
                        (x==people_left+26 && y==people_up+37) || 
                        (x==people_left+27 && y==people_up+37) || 
                        (x==people_left+28 && y==people_up+37) || 
                        (x==people_left+29 && y==people_up+37) || 
                        (x==people_left+30 && y==people_up+37) || 
                        (x==people_left+31 && y==people_up+37) || 
                        (x==people_left+32 && y==people_up+37) || 
                        (x==people_left+33 && y==people_up+37) || 
                        (x==people_left+34 && y==people_up+37) || 
                        (x==people_left+35 && y==people_up+37) || 
                        (x==people_left+36 && y==people_up+37) || 
                        (x==people_left+37 && y==people_up+37) || 
                        (x==people_left+38 && y==people_up+37) || 
                        (x==people_left+39 && y==people_up+37) || 
                        (x==people_left+40 && y==people_up+37) || 
                        (x==people_left+41 && y==people_up+37) || 
                        (x==people_left+42 && y==people_up+37) || 
                        (x==people_left+43 && y==people_up+37) || 
                        (x==people_left+44 && y==people_up+37) || 
                        (x==people_left+45 && y==people_up+37) || 
                        (x==people_left+46 && y==people_up+37) || 
                        (x==people_left+47 && y==people_up+37) || 
                        (x==people_left+48 && y==people_up+37) || 
                        (x==people_left+49 && y==people_up+37) || 
                        (x==people_left+50 && y==people_up+37) || 
                        (x==people_left+51 && y==people_up+37) || 
                        (x==people_left+52 && y==people_up+37) || 
                        (x==people_left+53 && y==people_up+37) || 
                        (x==people_left+54 && y==people_up+37) || 
                        (x==people_left+55 && y==people_up+37) || 
                        (x==people_left+56 && y==people_up+37) || 
                        (x==people_left+57 && y==people_up+37) || 
                        (x==people_left+58 && y==people_up+37) || 
                        (x==people_left+59 && y==people_up+37) || 
                        (x==people_left+60 && y==people_up+37) || 
                        (x==people_left+61 && y==people_up+37) || 
                        (x==people_left+62 && y==people_up+37) || 
                        (x==people_left+63 && y==people_up+37) || 
                        (x==people_left+64 && y==people_up+37) || 
                        (x==people_left+65 && y==people_up+37) || 
                        (x==people_left+66 && y==people_up+37) || 
                        (x==people_left+67 && y==people_up+37) || 
                        (x==people_left+68 && y==people_up+37) || 
                        (x==people_left+69 && y==people_up+37) || 
                        (x==people_left+70 && y==people_up+37) || 
                        (x==people_left+71 && y==people_up+37) || 
                        (x==people_left+72 && y==people_up+37) || 
                        (x==people_left+73 && y==people_up+37) || 
                        (x==people_left+74 && y==people_up+37) || 
                        (x==people_left+75 && y==people_up+37) || 
                        (x==people_left-37 && y==people_up+38) || 
                        (x==people_left-36 && y==people_up+38) || 
                        (x==people_left-35 && y==people_up+38) || 
                        (x==people_left-34 && y==people_up+38) || 
                        (x==people_left-33 && y==people_up+38) || 
                        (x==people_left-32 && y==people_up+38) || 
                        (x==people_left-31 && y==people_up+38) || 
                        (x==people_left-30 && y==people_up+38) || 
                        (x==people_left-29 && y==people_up+38) || 
                        (x==people_left-28 && y==people_up+38) || 
                        (x==people_left-27 && y==people_up+38) || 
                        (x==people_left-26 && y==people_up+38) || 
                        (x==people_left-25 && y==people_up+38) || 
                        (x==people_left-24 && y==people_up+38) || 
                        (x==people_left-23 && y==people_up+38) || 
                        (x==people_left-22 && y==people_up+38) || 
                        (x==people_left-21 && y==people_up+38) || 
                        (x==people_left-20 && y==people_up+38) || 
                        (x==people_left-19 && y==people_up+38) || 
                        (x==people_left-18 && y==people_up+38) || 
                        (x==people_left-17 && y==people_up+38) || 
                        (x==people_left-16 && y==people_up+38) || 
                        (x==people_left-15 && y==people_up+38) || 
                        (x==people_left-14 && y==people_up+38) || 
                        (x==people_left-13 && y==people_up+38) || 
                        (x==people_left-12 && y==people_up+38) || 
                        (x==people_left-11 && y==people_up+38) || 
                        (x==people_left-10 && y==people_up+38) || 
                        (x==people_left-9 && y==people_up+38) || 
                        (x==people_left-8 && y==people_up+38) || 
                        (x==people_left-7 && y==people_up+38) || 
                        (x==people_left-6 && y==people_up+38) || 
                        (x==people_left-5 && y==people_up+38) || 
                        (x==people_left-4 && y==people_up+38) || 
                        (x==people_left-3 && y==people_up+38) || 
                        (x==people_left-2 && y==people_up+38) || 
                        (x==people_left-1 && y==people_up+38) || 
                        (x==people_left+0 && y==people_up+38) || 
                        (x==people_left+1 && y==people_up+38) || 
                        (x==people_left+2 && y==people_up+38) || 
                        (x==people_left+3 && y==people_up+38) || 
                        (x==people_left+4 && y==people_up+38) || 
                        (x==people_left+5 && y==people_up+38) || 
                        (x==people_left+6 && y==people_up+38) || 
                        (x==people_left+7 && y==people_up+38) || 
                        (x==people_left+8 && y==people_up+38) || 
                        (x==people_left+9 && y==people_up+38) || 
                        (x==people_left+10 && y==people_up+38) || 
                        (x==people_left+11 && y==people_up+38) || 
                        (x==people_left+12 && y==people_up+38) || 
                        (x==people_left+13 && y==people_up+38) || 
                        (x==people_left+14 && y==people_up+38) || 
                        (x==people_left+15 && y==people_up+38) || 
                        (x==people_left+16 && y==people_up+38) || 
                        (x==people_left+17 && y==people_up+38) || 
                        (x==people_left+18 && y==people_up+38) || 
                        (x==people_left+19 && y==people_up+38) || 
                        (x==people_left+20 && y==people_up+38) || 
                        (x==people_left+21 && y==people_up+38) || 
                        (x==people_left+22 && y==people_up+38) || 
                        (x==people_left+23 && y==people_up+38) || 
                        (x==people_left+24 && y==people_up+38) || 
                        (x==people_left+25 && y==people_up+38) || 
                        (x==people_left+26 && y==people_up+38) || 
                        (x==people_left+27 && y==people_up+38) || 
                        (x==people_left+28 && y==people_up+38) || 
                        (x==people_left+29 && y==people_up+38) || 
                        (x==people_left+30 && y==people_up+38) || 
                        (x==people_left+31 && y==people_up+38) || 
                        (x==people_left+32 && y==people_up+38) || 
                        (x==people_left+33 && y==people_up+38) || 
                        (x==people_left+34 && y==people_up+38) || 
                        (x==people_left+35 && y==people_up+38) || 
                        (x==people_left+36 && y==people_up+38) || 
                        (x==people_left+37 && y==people_up+38) || 
                        (x==people_left+38 && y==people_up+38) || 
                        (x==people_left+39 && y==people_up+38) || 
                        (x==people_left+40 && y==people_up+38) || 
                        (x==people_left+41 && y==people_up+38) || 
                        (x==people_left+42 && y==people_up+38) || 
                        (x==people_left+43 && y==people_up+38) || 
                        (x==people_left+44 && y==people_up+38) || 
                        (x==people_left+45 && y==people_up+38) || 
                        (x==people_left+46 && y==people_up+38) || 
                        (x==people_left+47 && y==people_up+38) || 
                        (x==people_left+48 && y==people_up+38) || 
                        (x==people_left+49 && y==people_up+38) || 
                        (x==people_left+50 && y==people_up+38) || 
                        (x==people_left+51 && y==people_up+38) || 
                        (x==people_left+52 && y==people_up+38) || 
                        (x==people_left+53 && y==people_up+38) || 
                        (x==people_left+54 && y==people_up+38) || 
                        (x==people_left+55 && y==people_up+38) || 
                        (x==people_left+56 && y==people_up+38) || 
                        (x==people_left+57 && y==people_up+38) || 
                        (x==people_left+58 && y==people_up+38) || 
                        (x==people_left+59 && y==people_up+38) || 
                        (x==people_left+60 && y==people_up+38) || 
                        (x==people_left+61 && y==people_up+38) || 
                        (x==people_left+62 && y==people_up+38) || 
                        (x==people_left+63 && y==people_up+38) || 
                        (x==people_left+64 && y==people_up+38) || 
                        (x==people_left+65 && y==people_up+38) || 
                        (x==people_left+66 && y==people_up+38) || 
                        (x==people_left+67 && y==people_up+38) || 
                        (x==people_left+68 && y==people_up+38) || 
                        (x==people_left+69 && y==people_up+38) || 
                        (x==people_left+70 && y==people_up+38) || 
                        (x==people_left+71 && y==people_up+38) || 
                        (x==people_left+72 && y==people_up+38) || 
                        (x==people_left+73 && y==people_up+38) || 
                        (x==people_left+74 && y==people_up+38) || 
                        (x==people_left+75 && y==people_up+38) || 
                        (x==people_left-37 && y==people_up+39) || 
                        (x==people_left-36 && y==people_up+39) || 
                        (x==people_left-35 && y==people_up+39) || 
                        (x==people_left-34 && y==people_up+39) || 
                        (x==people_left-33 && y==people_up+39) || 
                        (x==people_left-32 && y==people_up+39) || 
                        (x==people_left-31 && y==people_up+39) || 
                        (x==people_left-30 && y==people_up+39) || 
                        (x==people_left-29 && y==people_up+39) || 
                        (x==people_left-28 && y==people_up+39) || 
                        (x==people_left-27 && y==people_up+39) || 
                        (x==people_left-26 && y==people_up+39) || 
                        (x==people_left-25 && y==people_up+39) || 
                        (x==people_left-24 && y==people_up+39) || 
                        (x==people_left-23 && y==people_up+39) || 
                        (x==people_left-22 && y==people_up+39) || 
                        (x==people_left-21 && y==people_up+39) || 
                        (x==people_left-20 && y==people_up+39) || 
                        (x==people_left-19 && y==people_up+39) || 
                        (x==people_left-18 && y==people_up+39) || 
                        (x==people_left-17 && y==people_up+39) || 
                        (x==people_left-16 && y==people_up+39) || 
                        (x==people_left-15 && y==people_up+39) || 
                        (x==people_left-14 && y==people_up+39) || 
                        (x==people_left-13 && y==people_up+39) || 
                        (x==people_left-12 && y==people_up+39) || 
                        (x==people_left-11 && y==people_up+39) || 
                        (x==people_left-10 && y==people_up+39) || 
                        (x==people_left-9 && y==people_up+39) || 
                        (x==people_left-8 && y==people_up+39) || 
                        (x==people_left-7 && y==people_up+39) || 
                        (x==people_left-6 && y==people_up+39) || 
                        (x==people_left-5 && y==people_up+39) || 
                        (x==people_left-4 && y==people_up+39) || 
                        (x==people_left-3 && y==people_up+39) || 
                        (x==people_left-2 && y==people_up+39) || 
                        (x==people_left-1 && y==people_up+39) || 
                        (x==people_left+0 && y==people_up+39) || 
                        (x==people_left+1 && y==people_up+39) || 
                        (x==people_left+2 && y==people_up+39) || 
                        (x==people_left+3 && y==people_up+39) || 
                        (x==people_left+4 && y==people_up+39) || 
                        (x==people_left+5 && y==people_up+39) || 
                        (x==people_left+6 && y==people_up+39) || 
                        (x==people_left+7 && y==people_up+39) || 
                        (x==people_left+8 && y==people_up+39) || 
                        (x==people_left+9 && y==people_up+39) || 
                        (x==people_left+10 && y==people_up+39) || 
                        (x==people_left+11 && y==people_up+39) || 
                        (x==people_left+12 && y==people_up+39) || 
                        (x==people_left+13 && y==people_up+39) || 
                        (x==people_left+14 && y==people_up+39) || 
                        (x==people_left+15 && y==people_up+39) || 
                        (x==people_left+16 && y==people_up+39) || 
                        (x==people_left+17 && y==people_up+39) || 
                        (x==people_left+18 && y==people_up+39) || 
                        (x==people_left+19 && y==people_up+39) || 
                        (x==people_left+20 && y==people_up+39) || 
                        (x==people_left+21 && y==people_up+39) || 
                        (x==people_left+22 && y==people_up+39) || 
                        (x==people_left+23 && y==people_up+39) || 
                        (x==people_left+24 && y==people_up+39) || 
                        (x==people_left+25 && y==people_up+39) || 
                        (x==people_left+26 && y==people_up+39) || 
                        (x==people_left+27 && y==people_up+39) || 
                        (x==people_left+28 && y==people_up+39) || 
                        (x==people_left+29 && y==people_up+39) || 
                        (x==people_left+30 && y==people_up+39) || 
                        (x==people_left+31 && y==people_up+39) || 
                        (x==people_left+32 && y==people_up+39) || 
                        (x==people_left+33 && y==people_up+39) || 
                        (x==people_left+34 && y==people_up+39) || 
                        (x==people_left+35 && y==people_up+39) || 
                        (x==people_left+36 && y==people_up+39) || 
                        (x==people_left+37 && y==people_up+39) || 
                        (x==people_left+38 && y==people_up+39) || 
                        (x==people_left+39 && y==people_up+39) || 
                        (x==people_left+40 && y==people_up+39) || 
                        (x==people_left+41 && y==people_up+39) || 
                        (x==people_left+42 && y==people_up+39) || 
                        (x==people_left+43 && y==people_up+39) || 
                        (x==people_left+44 && y==people_up+39) || 
                        (x==people_left+45 && y==people_up+39) || 
                        (x==people_left+46 && y==people_up+39) || 
                        (x==people_left+47 && y==people_up+39) || 
                        (x==people_left+48 && y==people_up+39) || 
                        (x==people_left+49 && y==people_up+39) || 
                        (x==people_left+50 && y==people_up+39) || 
                        (x==people_left+51 && y==people_up+39) || 
                        (x==people_left+52 && y==people_up+39) || 
                        (x==people_left+53 && y==people_up+39) || 
                        (x==people_left+54 && y==people_up+39) || 
                        (x==people_left+55 && y==people_up+39) || 
                        (x==people_left+56 && y==people_up+39) || 
                        (x==people_left+57 && y==people_up+39) || 
                        (x==people_left+58 && y==people_up+39) || 
                        (x==people_left+59 && y==people_up+39) || 
                        (x==people_left+60 && y==people_up+39) || 
                        (x==people_left+61 && y==people_up+39) || 
                        (x==people_left+62 && y==people_up+39) || 
                        (x==people_left+63 && y==people_up+39) || 
                        (x==people_left+64 && y==people_up+39) || 
                        (x==people_left+65 && y==people_up+39) || 
                        (x==people_left+66 && y==people_up+39) || 
                        (x==people_left+67 && y==people_up+39) || 
                        (x==people_left+68 && y==people_up+39) || 
                        (x==people_left+69 && y==people_up+39) || 
                        (x==people_left+70 && y==people_up+39) || 
                        (x==people_left+71 && y==people_up+39) || 
                        (x==people_left+72 && y==people_up+39) || 
                        (x==people_left+73 && y==people_up+39) || 
                        (x==people_left+74 && y==people_up+39) || 
                        (x==people_left+75 && y==people_up+39) || 
                        (x==people_left-36 && y==people_up+40) || 
                        (x==people_left-35 && y==people_up+40) || 
                        (x==people_left-34 && y==people_up+40) || 
                        (x==people_left-33 && y==people_up+40) || 
                        (x==people_left-32 && y==people_up+40) || 
                        (x==people_left-31 && y==people_up+40) || 
                        (x==people_left-30 && y==people_up+40) || 
                        (x==people_left-29 && y==people_up+40) || 
                        (x==people_left-28 && y==people_up+40) || 
                        (x==people_left-27 && y==people_up+40) || 
                        (x==people_left-26 && y==people_up+40) || 
                        (x==people_left-25 && y==people_up+40) || 
                        (x==people_left-24 && y==people_up+40) || 
                        (x==people_left-23 && y==people_up+40) || 
                        (x==people_left-22 && y==people_up+40) || 
                        (x==people_left-21 && y==people_up+40) || 
                        (x==people_left-20 && y==people_up+40) || 
                        (x==people_left-19 && y==people_up+40) || 
                        (x==people_left-18 && y==people_up+40) || 
                        (x==people_left-17 && y==people_up+40) || 
                        (x==people_left-16 && y==people_up+40) || 
                        (x==people_left-15 && y==people_up+40) || 
                        (x==people_left-14 && y==people_up+40) || 
                        (x==people_left-13 && y==people_up+40) || 
                        (x==people_left-12 && y==people_up+40) || 
                        (x==people_left-11 && y==people_up+40) || 
                        (x==people_left-10 && y==people_up+40) || 
                        (x==people_left-9 && y==people_up+40) || 
                        (x==people_left-8 && y==people_up+40) || 
                        (x==people_left-7 && y==people_up+40) || 
                        (x==people_left-6 && y==people_up+40) || 
                        (x==people_left-5 && y==people_up+40) || 
                        (x==people_left-4 && y==people_up+40) || 
                        (x==people_left-3 && y==people_up+40) || 
                        (x==people_left-2 && y==people_up+40) || 
                        (x==people_left-1 && y==people_up+40) || 
                        (x==people_left+0 && y==people_up+40) || 
                        (x==people_left+1 && y==people_up+40) || 
                        (x==people_left+2 && y==people_up+40) || 
                        (x==people_left+3 && y==people_up+40) || 
                        (x==people_left+4 && y==people_up+40) || 
                        (x==people_left+5 && y==people_up+40) || 
                        (x==people_left+6 && y==people_up+40) || 
                        (x==people_left+7 && y==people_up+40) || 
                        (x==people_left+8 && y==people_up+40) || 
                        (x==people_left+9 && y==people_up+40) || 
                        (x==people_left+10 && y==people_up+40) || 
                        (x==people_left+11 && y==people_up+40) || 
                        (x==people_left+12 && y==people_up+40) || 
                        (x==people_left+13 && y==people_up+40) || 
                        (x==people_left+14 && y==people_up+40) || 
                        (x==people_left+15 && y==people_up+40) || 
                        (x==people_left+16 && y==people_up+40) || 
                        (x==people_left+17 && y==people_up+40) || 
                        (x==people_left+18 && y==people_up+40) || 
                        (x==people_left+19 && y==people_up+40) || 
                        (x==people_left+20 && y==people_up+40) || 
                        (x==people_left+21 && y==people_up+40) || 
                        (x==people_left+22 && y==people_up+40) || 
                        (x==people_left+23 && y==people_up+40) || 
                        (x==people_left+24 && y==people_up+40) || 
                        (x==people_left+25 && y==people_up+40) || 
                        (x==people_left+26 && y==people_up+40) || 
                        (x==people_left+27 && y==people_up+40) || 
                        (x==people_left+28 && y==people_up+40) || 
                        (x==people_left+29 && y==people_up+40) || 
                        (x==people_left+30 && y==people_up+40) || 
                        (x==people_left+31 && y==people_up+40) || 
                        (x==people_left+32 && y==people_up+40) || 
                        (x==people_left+33 && y==people_up+40) || 
                        (x==people_left+34 && y==people_up+40) || 
                        (x==people_left+35 && y==people_up+40) || 
                        (x==people_left+36 && y==people_up+40) || 
                        (x==people_left+37 && y==people_up+40) || 
                        (x==people_left+38 && y==people_up+40) || 
                        (x==people_left+39 && y==people_up+40) || 
                        (x==people_left+40 && y==people_up+40) || 
                        (x==people_left+41 && y==people_up+40) || 
                        (x==people_left+42 && y==people_up+40) || 
                        (x==people_left+43 && y==people_up+40) || 
                        (x==people_left+44 && y==people_up+40) || 
                        (x==people_left+45 && y==people_up+40) || 
                        (x==people_left+46 && y==people_up+40) || 
                        (x==people_left+47 && y==people_up+40) || 
                        (x==people_left+48 && y==people_up+40) || 
                        (x==people_left+49 && y==people_up+40) || 
                        (x==people_left+50 && y==people_up+40) || 
                        (x==people_left+51 && y==people_up+40) || 
                        (x==people_left+52 && y==people_up+40) || 
                        (x==people_left+53 && y==people_up+40) || 
                        (x==people_left+54 && y==people_up+40) || 
                        (x==people_left+55 && y==people_up+40) || 
                        (x==people_left+56 && y==people_up+40) || 
                        (x==people_left+57 && y==people_up+40) || 
                        (x==people_left+58 && y==people_up+40) || 
                        (x==people_left+59 && y==people_up+40) || 
                        (x==people_left+60 && y==people_up+40) || 
                        (x==people_left+61 && y==people_up+40) || 
                        (x==people_left+62 && y==people_up+40) || 
                        (x==people_left+63 && y==people_up+40) || 
                        (x==people_left+64 && y==people_up+40) || 
                        (x==people_left+65 && y==people_up+40) || 
                        (x==people_left+66 && y==people_up+40) || 
                        (x==people_left+67 && y==people_up+40) || 
                        (x==people_left+68 && y==people_up+40) || 
                        (x==people_left+69 && y==people_up+40) || 
                        (x==people_left+70 && y==people_up+40) || 
                        (x==people_left+71 && y==people_up+40) || 
                        (x==people_left+72 && y==people_up+40) || 
                        (x==people_left+73 && y==people_up+40) || 
                        (x==people_left+74 && y==people_up+40) || 
                        (x==people_left-36 && y==people_up+41) || 
                        (x==people_left-35 && y==people_up+41) || 
                        (x==people_left-34 && y==people_up+41) || 
                        (x==people_left-33 && y==people_up+41) || 
                        (x==people_left-32 && y==people_up+41) || 
                        (x==people_left-31 && y==people_up+41) || 
                        (x==people_left-30 && y==people_up+41) || 
                        (x==people_left-29 && y==people_up+41) || 
                        (x==people_left-28 && y==people_up+41) || 
                        (x==people_left-27 && y==people_up+41) || 
                        (x==people_left-26 && y==people_up+41) || 
                        (x==people_left-25 && y==people_up+41) || 
                        (x==people_left-24 && y==people_up+41) || 
                        (x==people_left-23 && y==people_up+41) || 
                        (x==people_left-22 && y==people_up+41) || 
                        (x==people_left-21 && y==people_up+41) || 
                        (x==people_left-20 && y==people_up+41) || 
                        (x==people_left-19 && y==people_up+41) || 
                        (x==people_left-18 && y==people_up+41) || 
                        (x==people_left-17 && y==people_up+41) || 
                        (x==people_left-16 && y==people_up+41) || 
                        (x==people_left-15 && y==people_up+41) || 
                        (x==people_left-14 && y==people_up+41) || 
                        (x==people_left-13 && y==people_up+41) || 
                        (x==people_left-12 && y==people_up+41) || 
                        (x==people_left-11 && y==people_up+41) || 
                        (x==people_left-10 && y==people_up+41) || 
                        (x==people_left-9 && y==people_up+41) || 
                        (x==people_left-8 && y==people_up+41) || 
                        (x==people_left-7 && y==people_up+41) || 
                        (x==people_left-6 && y==people_up+41) || 
                        (x==people_left-5 && y==people_up+41) || 
                        (x==people_left-4 && y==people_up+41) || 
                        (x==people_left-3 && y==people_up+41) || 
                        (x==people_left-2 && y==people_up+41) || 
                        (x==people_left-1 && y==people_up+41) || 
                        (x==people_left+0 && y==people_up+41) || 
                        (x==people_left+1 && y==people_up+41) || 
                        (x==people_left+2 && y==people_up+41) || 
                        (x==people_left+3 && y==people_up+41) || 
                        (x==people_left+4 && y==people_up+41) || 
                        (x==people_left+5 && y==people_up+41) || 
                        (x==people_left+6 && y==people_up+41) || 
                        (x==people_left+7 && y==people_up+41) || 
                        (x==people_left+8 && y==people_up+41) || 
                        (x==people_left+9 && y==people_up+41) || 
                        (x==people_left+10 && y==people_up+41) || 
                        (x==people_left+11 && y==people_up+41) || 
                        (x==people_left+12 && y==people_up+41) || 
                        (x==people_left+13 && y==people_up+41) || 
                        (x==people_left+14 && y==people_up+41) || 
                        (x==people_left+15 && y==people_up+41) || 
                        (x==people_left+16 && y==people_up+41) || 
                        (x==people_left+17 && y==people_up+41) || 
                        (x==people_left+18 && y==people_up+41) || 
                        (x==people_left+19 && y==people_up+41) || 
                        (x==people_left+20 && y==people_up+41) || 
                        (x==people_left+21 && y==people_up+41) || 
                        (x==people_left+22 && y==people_up+41) || 
                        (x==people_left+23 && y==people_up+41) || 
                        (x==people_left+24 && y==people_up+41) || 
                        (x==people_left+25 && y==people_up+41) || 
                        (x==people_left+26 && y==people_up+41) || 
                        (x==people_left+27 && y==people_up+41) || 
                        (x==people_left+28 && y==people_up+41) || 
                        (x==people_left+29 && y==people_up+41) || 
                        (x==people_left+30 && y==people_up+41) || 
                        (x==people_left+31 && y==people_up+41) || 
                        (x==people_left+32 && y==people_up+41) || 
                        (x==people_left+33 && y==people_up+41) || 
                        (x==people_left+34 && y==people_up+41) || 
                        (x==people_left+35 && y==people_up+41) || 
                        (x==people_left+36 && y==people_up+41) || 
                        (x==people_left+37 && y==people_up+41) || 
                        (x==people_left+38 && y==people_up+41) || 
                        (x==people_left+39 && y==people_up+41) || 
                        (x==people_left+40 && y==people_up+41) || 
                        (x==people_left+41 && y==people_up+41) || 
                        (x==people_left+42 && y==people_up+41) || 
                        (x==people_left+43 && y==people_up+41) || 
                        (x==people_left+44 && y==people_up+41) || 
                        (x==people_left+45 && y==people_up+41) || 
                        (x==people_left+46 && y==people_up+41) || 
                        (x==people_left+47 && y==people_up+41) || 
                        (x==people_left+48 && y==people_up+41) || 
                        (x==people_left+49 && y==people_up+41) || 
                        (x==people_left+50 && y==people_up+41) || 
                        (x==people_left+51 && y==people_up+41) || 
                        (x==people_left+52 && y==people_up+41) || 
                        (x==people_left+53 && y==people_up+41) || 
                        (x==people_left+54 && y==people_up+41) || 
                        (x==people_left+55 && y==people_up+41) || 
                        (x==people_left+56 && y==people_up+41) || 
                        (x==people_left+57 && y==people_up+41) || 
                        (x==people_left+58 && y==people_up+41) || 
                        (x==people_left+59 && y==people_up+41) || 
                        (x==people_left+60 && y==people_up+41) || 
                        (x==people_left+61 && y==people_up+41) || 
                        (x==people_left+62 && y==people_up+41) || 
                        (x==people_left+63 && y==people_up+41) || 
                        (x==people_left+64 && y==people_up+41) || 
                        (x==people_left+65 && y==people_up+41) || 
                        (x==people_left+66 && y==people_up+41) || 
                        (x==people_left+67 && y==people_up+41) || 
                        (x==people_left+68 && y==people_up+41) || 
                        (x==people_left+69 && y==people_up+41) || 
                        (x==people_left+70 && y==people_up+41) || 
                        (x==people_left+71 && y==people_up+41) || 
                        (x==people_left+72 && y==people_up+41) || 
                        (x==people_left+73 && y==people_up+41) || 
                        (x==people_left+74 && y==people_up+41) || 
                        (x==people_left-36 && y==people_up+42) || 
                        (x==people_left-35 && y==people_up+42) || 
                        (x==people_left-34 && y==people_up+42) || 
                        (x==people_left-33 && y==people_up+42) || 
                        (x==people_left-32 && y==people_up+42) || 
                        (x==people_left-31 && y==people_up+42) || 
                        (x==people_left-30 && y==people_up+42) || 
                        (x==people_left-29 && y==people_up+42) || 
                        (x==people_left-28 && y==people_up+42) || 
                        (x==people_left-27 && y==people_up+42) || 
                        (x==people_left-26 && y==people_up+42) || 
                        (x==people_left-25 && y==people_up+42) || 
                        (x==people_left-24 && y==people_up+42) || 
                        (x==people_left-23 && y==people_up+42) || 
                        (x==people_left-22 && y==people_up+42) || 
                        (x==people_left-21 && y==people_up+42) || 
                        (x==people_left-20 && y==people_up+42) || 
                        (x==people_left-19 && y==people_up+42) || 
                        (x==people_left-18 && y==people_up+42) || 
                        (x==people_left-17 && y==people_up+42) || 
                        (x==people_left-16 && y==people_up+42) || 
                        (x==people_left-15 && y==people_up+42) || 
                        (x==people_left-14 && y==people_up+42) || 
                        (x==people_left-13 && y==people_up+42) || 
                        (x==people_left-12 && y==people_up+42) || 
                        (x==people_left-11 && y==people_up+42) || 
                        (x==people_left-10 && y==people_up+42) || 
                        (x==people_left-9 && y==people_up+42) || 
                        (x==people_left-8 && y==people_up+42) || 
                        (x==people_left-7 && y==people_up+42) || 
                        (x==people_left-6 && y==people_up+42) || 
                        (x==people_left-5 && y==people_up+42) || 
                        (x==people_left-4 && y==people_up+42) || 
                        (x==people_left-3 && y==people_up+42) || 
                        (x==people_left-2 && y==people_up+42) || 
                        (x==people_left-1 && y==people_up+42) || 
                        (x==people_left+0 && y==people_up+42) || 
                        (x==people_left+1 && y==people_up+42) || 
                        (x==people_left+2 && y==people_up+42) || 
                        (x==people_left+3 && y==people_up+42) || 
                        (x==people_left+4 && y==people_up+42) || 
                        (x==people_left+5 && y==people_up+42) || 
                        (x==people_left+6 && y==people_up+42) || 
                        (x==people_left+7 && y==people_up+42) || 
                        (x==people_left+8 && y==people_up+42) || 
                        (x==people_left+9 && y==people_up+42) || 
                        (x==people_left+10 && y==people_up+42) || 
                        (x==people_left+11 && y==people_up+42) || 
                        (x==people_left+12 && y==people_up+42) || 
                        (x==people_left+13 && y==people_up+42) || 
                        (x==people_left+14 && y==people_up+42) || 
                        (x==people_left+15 && y==people_up+42) || 
                        (x==people_left+16 && y==people_up+42) || 
                        (x==people_left+17 && y==people_up+42) || 
                        (x==people_left+18 && y==people_up+42) || 
                        (x==people_left+19 && y==people_up+42) || 
                        (x==people_left+20 && y==people_up+42) || 
                        (x==people_left+21 && y==people_up+42) || 
                        (x==people_left+22 && y==people_up+42) || 
                        (x==people_left+23 && y==people_up+42) || 
                        (x==people_left+24 && y==people_up+42) || 
                        (x==people_left+25 && y==people_up+42) || 
                        (x==people_left+26 && y==people_up+42) || 
                        (x==people_left+27 && y==people_up+42) || 
                        (x==people_left+28 && y==people_up+42) || 
                        (x==people_left+29 && y==people_up+42) || 
                        (x==people_left+30 && y==people_up+42) || 
                        (x==people_left+31 && y==people_up+42) || 
                        (x==people_left+32 && y==people_up+42) || 
                        (x==people_left+33 && y==people_up+42) || 
                        (x==people_left+34 && y==people_up+42) || 
                        (x==people_left+35 && y==people_up+42) || 
                        (x==people_left+36 && y==people_up+42) || 
                        (x==people_left+37 && y==people_up+42) || 
                        (x==people_left+38 && y==people_up+42) || 
                        (x==people_left+39 && y==people_up+42) || 
                        (x==people_left+40 && y==people_up+42) || 
                        (x==people_left+41 && y==people_up+42) || 
                        (x==people_left+42 && y==people_up+42) || 
                        (x==people_left+43 && y==people_up+42) || 
                        (x==people_left+44 && y==people_up+42) || 
                        (x==people_left+45 && y==people_up+42) || 
                        (x==people_left+46 && y==people_up+42) || 
                        (x==people_left+47 && y==people_up+42) || 
                        (x==people_left+48 && y==people_up+42) || 
                        (x==people_left+49 && y==people_up+42) || 
                        (x==people_left+50 && y==people_up+42) || 
                        (x==people_left+51 && y==people_up+42) || 
                        (x==people_left+52 && y==people_up+42) || 
                        (x==people_left+53 && y==people_up+42) || 
                        (x==people_left+54 && y==people_up+42) || 
                        (x==people_left+55 && y==people_up+42) || 
                        (x==people_left+56 && y==people_up+42) || 
                        (x==people_left+57 && y==people_up+42) || 
                        (x==people_left+58 && y==people_up+42) || 
                        (x==people_left+59 && y==people_up+42) || 
                        (x==people_left+60 && y==people_up+42) || 
                        (x==people_left+61 && y==people_up+42) || 
                        (x==people_left+62 && y==people_up+42) || 
                        (x==people_left+63 && y==people_up+42) || 
                        (x==people_left+64 && y==people_up+42) || 
                        (x==people_left+65 && y==people_up+42) || 
                        (x==people_left+66 && y==people_up+42) || 
                        (x==people_left+67 && y==people_up+42) || 
                        (x==people_left+68 && y==people_up+42) || 
                        (x==people_left+69 && y==people_up+42) || 
                        (x==people_left+70 && y==people_up+42) || 
                        (x==people_left+71 && y==people_up+42) || 
                        (x==people_left+72 && y==people_up+42) || 
                        (x==people_left+73 && y==people_up+42) || 
                        (x==people_left+74 && y==people_up+42) || 
                        (x==people_left-35 && y==people_up+43) || 
                        (x==people_left-34 && y==people_up+43) || 
                        (x==people_left-33 && y==people_up+43) || 
                        (x==people_left-32 && y==people_up+43) || 
                        (x==people_left-31 && y==people_up+43) || 
                        (x==people_left-30 && y==people_up+43) || 
                        (x==people_left-29 && y==people_up+43) || 
                        (x==people_left-28 && y==people_up+43) || 
                        (x==people_left-27 && y==people_up+43) || 
                        (x==people_left-26 && y==people_up+43) || 
                        (x==people_left-25 && y==people_up+43) || 
                        (x==people_left-24 && y==people_up+43) || 
                        (x==people_left-23 && y==people_up+43) || 
                        (x==people_left-22 && y==people_up+43) || 
                        (x==people_left-21 && y==people_up+43) || 
                        (x==people_left-20 && y==people_up+43) || 
                        (x==people_left-19 && y==people_up+43) || 
                        (x==people_left-18 && y==people_up+43) || 
                        (x==people_left-17 && y==people_up+43) || 
                        (x==people_left-16 && y==people_up+43) || 
                        (x==people_left-15 && y==people_up+43) || 
                        (x==people_left-14 && y==people_up+43) || 
                        (x==people_left-13 && y==people_up+43) || 
                        (x==people_left-12 && y==people_up+43) || 
                        (x==people_left-11 && y==people_up+43) || 
                        (x==people_left-10 && y==people_up+43) || 
                        (x==people_left-9 && y==people_up+43) || 
                        (x==people_left-8 && y==people_up+43) || 
                        (x==people_left-7 && y==people_up+43) || 
                        (x==people_left-6 && y==people_up+43) || 
                        (x==people_left-5 && y==people_up+43) || 
                        (x==people_left-4 && y==people_up+43) || 
                        (x==people_left-3 && y==people_up+43) || 
                        (x==people_left-2 && y==people_up+43) || 
                        (x==people_left-1 && y==people_up+43) || 
                        (x==people_left+0 && y==people_up+43) || 
                        (x==people_left+1 && y==people_up+43) || 
                        (x==people_left+2 && y==people_up+43) || 
                        (x==people_left+3 && y==people_up+43) || 
                        (x==people_left+4 && y==people_up+43) || 
                        (x==people_left+5 && y==people_up+43) || 
                        (x==people_left+6 && y==people_up+43) || 
                        (x==people_left+7 && y==people_up+43) || 
                        (x==people_left+8 && y==people_up+43) || 
                        (x==people_left+9 && y==people_up+43) || 
                        (x==people_left+10 && y==people_up+43) || 
                        (x==people_left+11 && y==people_up+43) || 
                        (x==people_left+12 && y==people_up+43) || 
                        (x==people_left+13 && y==people_up+43) || 
                        (x==people_left+14 && y==people_up+43) || 
                        (x==people_left+15 && y==people_up+43) || 
                        (x==people_left+16 && y==people_up+43) || 
                        (x==people_left+17 && y==people_up+43) || 
                        (x==people_left+18 && y==people_up+43) || 
                        (x==people_left+19 && y==people_up+43) || 
                        (x==people_left+20 && y==people_up+43) || 
                        (x==people_left+21 && y==people_up+43) || 
                        (x==people_left+22 && y==people_up+43) || 
                        (x==people_left+23 && y==people_up+43) || 
                        (x==people_left+24 && y==people_up+43) || 
                        (x==people_left+25 && y==people_up+43) || 
                        (x==people_left+26 && y==people_up+43) || 
                        (x==people_left+27 && y==people_up+43) || 
                        (x==people_left+28 && y==people_up+43) || 
                        (x==people_left+29 && y==people_up+43) || 
                        (x==people_left+30 && y==people_up+43) || 
                        (x==people_left+31 && y==people_up+43) || 
                        (x==people_left+32 && y==people_up+43) || 
                        (x==people_left+33 && y==people_up+43) || 
                        (x==people_left+34 && y==people_up+43) || 
                        (x==people_left+35 && y==people_up+43) || 
                        (x==people_left+36 && y==people_up+43) || 
                        (x==people_left+37 && y==people_up+43) || 
                        (x==people_left+38 && y==people_up+43) || 
                        (x==people_left+39 && y==people_up+43) || 
                        (x==people_left+40 && y==people_up+43) || 
                        (x==people_left+41 && y==people_up+43) || 
                        (x==people_left+42 && y==people_up+43) || 
                        (x==people_left+43 && y==people_up+43) || 
                        (x==people_left+44 && y==people_up+43) || 
                        (x==people_left+45 && y==people_up+43) || 
                        (x==people_left+46 && y==people_up+43) || 
                        (x==people_left+47 && y==people_up+43) || 
                        (x==people_left+48 && y==people_up+43) || 
                        (x==people_left+49 && y==people_up+43) || 
                        (x==people_left+50 && y==people_up+43) || 
                        (x==people_left+51 && y==people_up+43) || 
                        (x==people_left+52 && y==people_up+43) || 
                        (x==people_left+53 && y==people_up+43) || 
                        (x==people_left+54 && y==people_up+43) || 
                        (x==people_left+55 && y==people_up+43) || 
                        (x==people_left+56 && y==people_up+43) || 
                        (x==people_left+57 && y==people_up+43) || 
                        (x==people_left+58 && y==people_up+43) || 
                        (x==people_left+59 && y==people_up+43) || 
                        (x==people_left+60 && y==people_up+43) || 
                        (x==people_left+61 && y==people_up+43) || 
                        (x==people_left+62 && y==people_up+43) || 
                        (x==people_left+63 && y==people_up+43) || 
                        (x==people_left+64 && y==people_up+43) || 
                        (x==people_left+65 && y==people_up+43) || 
                        (x==people_left+66 && y==people_up+43) || 
                        (x==people_left+67 && y==people_up+43) || 
                        (x==people_left+68 && y==people_up+43) || 
                        (x==people_left+69 && y==people_up+43) || 
                        (x==people_left+70 && y==people_up+43) || 
                        (x==people_left+71 && y==people_up+43) || 
                        (x==people_left+72 && y==people_up+43) || 
                        (x==people_left+73 && y==people_up+43) || 
                        (x==people_left-35 && y==people_up+44) || 
                        (x==people_left-34 && y==people_up+44) || 
                        (x==people_left-33 && y==people_up+44) || 
                        (x==people_left-32 && y==people_up+44) || 
                        (x==people_left-31 && y==people_up+44) || 
                        (x==people_left-30 && y==people_up+44) || 
                        (x==people_left-29 && y==people_up+44) || 
                        (x==people_left-28 && y==people_up+44) || 
                        (x==people_left-27 && y==people_up+44) || 
                        (x==people_left-26 && y==people_up+44) || 
                        (x==people_left-25 && y==people_up+44) || 
                        (x==people_left-24 && y==people_up+44) || 
                        (x==people_left-23 && y==people_up+44) || 
                        (x==people_left-22 && y==people_up+44) || 
                        (x==people_left-21 && y==people_up+44) || 
                        (x==people_left-20 && y==people_up+44) || 
                        (x==people_left-19 && y==people_up+44) || 
                        (x==people_left-18 && y==people_up+44) || 
                        (x==people_left-17 && y==people_up+44) || 
                        (x==people_left-16 && y==people_up+44) || 
                        (x==people_left-15 && y==people_up+44) || 
                        (x==people_left-14 && y==people_up+44) || 
                        (x==people_left-13 && y==people_up+44) || 
                        (x==people_left-12 && y==people_up+44) || 
                        (x==people_left-11 && y==people_up+44) || 
                        (x==people_left-10 && y==people_up+44) || 
                        (x==people_left-9 && y==people_up+44) || 
                        (x==people_left-8 && y==people_up+44) || 
                        (x==people_left-7 && y==people_up+44) || 
                        (x==people_left-6 && y==people_up+44) || 
                        (x==people_left-5 && y==people_up+44) || 
                        (x==people_left-4 && y==people_up+44) || 
                        (x==people_left-3 && y==people_up+44) || 
                        (x==people_left-2 && y==people_up+44) || 
                        (x==people_left-1 && y==people_up+44) || 
                        (x==people_left+0 && y==people_up+44) || 
                        (x==people_left+1 && y==people_up+44) || 
                        (x==people_left+2 && y==people_up+44) || 
                        (x==people_left+3 && y==people_up+44) || 
                        (x==people_left+4 && y==people_up+44) || 
                        (x==people_left+5 && y==people_up+44) || 
                        (x==people_left+6 && y==people_up+44) || 
                        (x==people_left+7 && y==people_up+44) || 
                        (x==people_left+8 && y==people_up+44) || 
                        (x==people_left+9 && y==people_up+44) || 
                        (x==people_left+10 && y==people_up+44) || 
                        (x==people_left+11 && y==people_up+44) || 
                        (x==people_left+12 && y==people_up+44) || 
                        (x==people_left+13 && y==people_up+44) || 
                        (x==people_left+14 && y==people_up+44) || 
                        (x==people_left+15 && y==people_up+44) || 
                        (x==people_left+16 && y==people_up+44) || 
                        (x==people_left+17 && y==people_up+44) || 
                        (x==people_left+18 && y==people_up+44) || 
                        (x==people_left+19 && y==people_up+44) || 
                        (x==people_left+20 && y==people_up+44) || 
                        (x==people_left+21 && y==people_up+44) || 
                        (x==people_left+22 && y==people_up+44) || 
                        (x==people_left+23 && y==people_up+44) || 
                        (x==people_left+24 && y==people_up+44) || 
                        (x==people_left+25 && y==people_up+44) || 
                        (x==people_left+26 && y==people_up+44) || 
                        (x==people_left+27 && y==people_up+44) || 
                        (x==people_left+28 && y==people_up+44) || 
                        (x==people_left+29 && y==people_up+44) || 
                        (x==people_left+30 && y==people_up+44) || 
                        (x==people_left+31 && y==people_up+44) || 
                        (x==people_left+32 && y==people_up+44) || 
                        (x==people_left+33 && y==people_up+44) || 
                        (x==people_left+34 && y==people_up+44) || 
                        (x==people_left+35 && y==people_up+44) || 
                        (x==people_left+36 && y==people_up+44) || 
                        (x==people_left+37 && y==people_up+44) || 
                        (x==people_left+38 && y==people_up+44) || 
                        (x==people_left+39 && y==people_up+44) || 
                        (x==people_left+40 && y==people_up+44) || 
                        (x==people_left+41 && y==people_up+44) || 
                        (x==people_left+42 && y==people_up+44) || 
                        (x==people_left+43 && y==people_up+44) || 
                        (x==people_left+44 && y==people_up+44) || 
                        (x==people_left+45 && y==people_up+44) || 
                        (x==people_left+46 && y==people_up+44) || 
                        (x==people_left+47 && y==people_up+44) || 
                        (x==people_left+48 && y==people_up+44) || 
                        (x==people_left+49 && y==people_up+44) || 
                        (x==people_left+50 && y==people_up+44) || 
                        (x==people_left+51 && y==people_up+44) || 
                        (x==people_left+52 && y==people_up+44) || 
                        (x==people_left+53 && y==people_up+44) || 
                        (x==people_left+54 && y==people_up+44) || 
                        (x==people_left+55 && y==people_up+44) || 
                        (x==people_left+56 && y==people_up+44) || 
                        (x==people_left+57 && y==people_up+44) || 
                        (x==people_left+58 && y==people_up+44) || 
                        (x==people_left+59 && y==people_up+44) || 
                        (x==people_left+60 && y==people_up+44) || 
                        (x==people_left+61 && y==people_up+44) || 
                        (x==people_left+62 && y==people_up+44) || 
                        (x==people_left+63 && y==people_up+44) || 
                        (x==people_left+64 && y==people_up+44) || 
                        (x==people_left+65 && y==people_up+44) || 
                        (x==people_left+66 && y==people_up+44) || 
                        (x==people_left+67 && y==people_up+44) || 
                        (x==people_left+68 && y==people_up+44) || 
                        (x==people_left+69 && y==people_up+44) || 
                        (x==people_left+70 && y==people_up+44) || 
                        (x==people_left+71 && y==people_up+44) || 
                        (x==people_left+72 && y==people_up+44) || 
                        (x==people_left+73 && y==people_up+44) || 
                        (x==people_left-34 && y==people_up+45) || 
                        (x==people_left-33 && y==people_up+45) || 
                        (x==people_left-32 && y==people_up+45) || 
                        (x==people_left-31 && y==people_up+45) || 
                        (x==people_left-30 && y==people_up+45) || 
                        (x==people_left-29 && y==people_up+45) || 
                        (x==people_left-28 && y==people_up+45) || 
                        (x==people_left-27 && y==people_up+45) || 
                        (x==people_left-26 && y==people_up+45) || 
                        (x==people_left-25 && y==people_up+45) || 
                        (x==people_left-24 && y==people_up+45) || 
                        (x==people_left-23 && y==people_up+45) || 
                        (x==people_left-22 && y==people_up+45) || 
                        (x==people_left-21 && y==people_up+45) || 
                        (x==people_left-20 && y==people_up+45) || 
                        (x==people_left-19 && y==people_up+45) || 
                        (x==people_left-18 && y==people_up+45) || 
                        (x==people_left-17 && y==people_up+45) || 
                        (x==people_left-16 && y==people_up+45) || 
                        (x==people_left-15 && y==people_up+45) || 
                        (x==people_left-14 && y==people_up+45) || 
                        (x==people_left-13 && y==people_up+45) || 
                        (x==people_left-12 && y==people_up+45) || 
                        (x==people_left-11 && y==people_up+45) || 
                        (x==people_left-10 && y==people_up+45) || 
                        (x==people_left-9 && y==people_up+45) || 
                        (x==people_left-8 && y==people_up+45) || 
                        (x==people_left-7 && y==people_up+45) || 
                        (x==people_left-6 && y==people_up+45) || 
                        (x==people_left-5 && y==people_up+45) || 
                        (x==people_left-4 && y==people_up+45) || 
                        (x==people_left-3 && y==people_up+45) || 
                        (x==people_left-2 && y==people_up+45) || 
                        (x==people_left-1 && y==people_up+45) || 
                        (x==people_left+0 && y==people_up+45) || 
                        (x==people_left+1 && y==people_up+45) || 
                        (x==people_left+2 && y==people_up+45) || 
                        (x==people_left+3 && y==people_up+45) || 
                        (x==people_left+4 && y==people_up+45) || 
                        (x==people_left+5 && y==people_up+45) || 
                        (x==people_left+6 && y==people_up+45) || 
                        (x==people_left+7 && y==people_up+45) || 
                        (x==people_left+8 && y==people_up+45) || 
                        (x==people_left+9 && y==people_up+45) || 
                        (x==people_left+10 && y==people_up+45) || 
                        (x==people_left+11 && y==people_up+45) || 
                        (x==people_left+12 && y==people_up+45) || 
                        (x==people_left+13 && y==people_up+45) || 
                        (x==people_left+14 && y==people_up+45) || 
                        (x==people_left+15 && y==people_up+45) || 
                        (x==people_left+16 && y==people_up+45) || 
                        (x==people_left+17 && y==people_up+45) || 
                        (x==people_left+18 && y==people_up+45) || 
                        (x==people_left+19 && y==people_up+45) || 
                        (x==people_left+20 && y==people_up+45) || 
                        (x==people_left+21 && y==people_up+45) || 
                        (x==people_left+22 && y==people_up+45) || 
                        (x==people_left+23 && y==people_up+45) || 
                        (x==people_left+24 && y==people_up+45) || 
                        (x==people_left+25 && y==people_up+45) || 
                        (x==people_left+26 && y==people_up+45) || 
                        (x==people_left+27 && y==people_up+45) || 
                        (x==people_left+28 && y==people_up+45) || 
                        (x==people_left+29 && y==people_up+45) || 
                        (x==people_left+30 && y==people_up+45) || 
                        (x==people_left+31 && y==people_up+45) || 
                        (x==people_left+32 && y==people_up+45) || 
                        (x==people_left+33 && y==people_up+45) || 
                        (x==people_left+34 && y==people_up+45) || 
                        (x==people_left+35 && y==people_up+45) || 
                        (x==people_left+36 && y==people_up+45) || 
                        (x==people_left+37 && y==people_up+45) || 
                        (x==people_left+38 && y==people_up+45) || 
                        (x==people_left+39 && y==people_up+45) || 
                        (x==people_left+40 && y==people_up+45) || 
                        (x==people_left+41 && y==people_up+45) || 
                        (x==people_left+42 && y==people_up+45) || 
                        (x==people_left+43 && y==people_up+45) || 
                        (x==people_left+44 && y==people_up+45) || 
                        (x==people_left+45 && y==people_up+45) || 
                        (x==people_left+46 && y==people_up+45) || 
                        (x==people_left+47 && y==people_up+45) || 
                        (x==people_left+48 && y==people_up+45) || 
                        (x==people_left+49 && y==people_up+45) || 
                        (x==people_left+50 && y==people_up+45) || 
                        (x==people_left+51 && y==people_up+45) || 
                        (x==people_left+52 && y==people_up+45) || 
                        (x==people_left+53 && y==people_up+45) || 
                        (x==people_left+54 && y==people_up+45) || 
                        (x==people_left+55 && y==people_up+45) || 
                        (x==people_left+56 && y==people_up+45) || 
                        (x==people_left+57 && y==people_up+45) || 
                        (x==people_left+58 && y==people_up+45) || 
                        (x==people_left+59 && y==people_up+45) || 
                        (x==people_left+60 && y==people_up+45) || 
                        (x==people_left+61 && y==people_up+45) || 
                        (x==people_left+62 && y==people_up+45) || 
                        (x==people_left+63 && y==people_up+45) || 
                        (x==people_left+64 && y==people_up+45) || 
                        (x==people_left+65 && y==people_up+45) || 
                        (x==people_left+66 && y==people_up+45) || 
                        (x==people_left+67 && y==people_up+45) || 
                        (x==people_left+68 && y==people_up+45) || 
                        (x==people_left+69 && y==people_up+45) || 
                        (x==people_left+70 && y==people_up+45) || 
                        (x==people_left+71 && y==people_up+45) || 
                        (x==people_left+72 && y==people_up+45) || 
                        (x==people_left-34 && y==people_up+46) || 
                        (x==people_left-33 && y==people_up+46) || 
                        (x==people_left-32 && y==people_up+46) || 
                        (x==people_left-31 && y==people_up+46) || 
                        (x==people_left-30 && y==people_up+46) || 
                        (x==people_left-29 && y==people_up+46) || 
                        (x==people_left-28 && y==people_up+46) || 
                        (x==people_left-27 && y==people_up+46) || 
                        (x==people_left-26 && y==people_up+46) || 
                        (x==people_left-25 && y==people_up+46) || 
                        (x==people_left-24 && y==people_up+46) || 
                        (x==people_left-23 && y==people_up+46) || 
                        (x==people_left-22 && y==people_up+46) || 
                        (x==people_left-21 && y==people_up+46) || 
                        (x==people_left-20 && y==people_up+46) || 
                        (x==people_left-19 && y==people_up+46) || 
                        (x==people_left-18 && y==people_up+46) || 
                        (x==people_left-17 && y==people_up+46) || 
                        (x==people_left-16 && y==people_up+46) || 
                        (x==people_left-15 && y==people_up+46) || 
                        (x==people_left-14 && y==people_up+46) || 
                        (x==people_left-13 && y==people_up+46) || 
                        (x==people_left-12 && y==people_up+46) || 
                        (x==people_left-11 && y==people_up+46) || 
                        (x==people_left-10 && y==people_up+46) || 
                        (x==people_left-9 && y==people_up+46) || 
                        (x==people_left-8 && y==people_up+46) || 
                        (x==people_left-7 && y==people_up+46) || 
                        (x==people_left-6 && y==people_up+46) || 
                        (x==people_left-5 && y==people_up+46) || 
                        (x==people_left-4 && y==people_up+46) || 
                        (x==people_left-3 && y==people_up+46) || 
                        (x==people_left-2 && y==people_up+46) || 
                        (x==people_left-1 && y==people_up+46) || 
                        (x==people_left+0 && y==people_up+46) || 
                        (x==people_left+1 && y==people_up+46) || 
                        (x==people_left+2 && y==people_up+46) || 
                        (x==people_left+3 && y==people_up+46) || 
                        (x==people_left+4 && y==people_up+46) || 
                        (x==people_left+5 && y==people_up+46) || 
                        (x==people_left+6 && y==people_up+46) || 
                        (x==people_left+7 && y==people_up+46) || 
                        (x==people_left+8 && y==people_up+46) || 
                        (x==people_left+9 && y==people_up+46) || 
                        (x==people_left+10 && y==people_up+46) || 
                        (x==people_left+11 && y==people_up+46) || 
                        (x==people_left+12 && y==people_up+46) || 
                        (x==people_left+13 && y==people_up+46) || 
                        (x==people_left+14 && y==people_up+46) || 
                        (x==people_left+15 && y==people_up+46) || 
                        (x==people_left+16 && y==people_up+46) || 
                        (x==people_left+17 && y==people_up+46) || 
                        (x==people_left+18 && y==people_up+46) || 
                        (x==people_left+19 && y==people_up+46) || 
                        (x==people_left+20 && y==people_up+46) || 
                        (x==people_left+21 && y==people_up+46) || 
                        (x==people_left+22 && y==people_up+46) || 
                        (x==people_left+23 && y==people_up+46) || 
                        (x==people_left+24 && y==people_up+46) || 
                        (x==people_left+25 && y==people_up+46) || 
                        (x==people_left+26 && y==people_up+46) || 
                        (x==people_left+27 && y==people_up+46) || 
                        (x==people_left+28 && y==people_up+46) || 
                        (x==people_left+29 && y==people_up+46) || 
                        (x==people_left+30 && y==people_up+46) || 
                        (x==people_left+31 && y==people_up+46) || 
                        (x==people_left+32 && y==people_up+46) || 
                        (x==people_left+33 && y==people_up+46) || 
                        (x==people_left+34 && y==people_up+46) || 
                        (x==people_left+35 && y==people_up+46) || 
                        (x==people_left+36 && y==people_up+46) || 
                        (x==people_left+37 && y==people_up+46) || 
                        (x==people_left+38 && y==people_up+46) || 
                        (x==people_left+39 && y==people_up+46) || 
                        (x==people_left+40 && y==people_up+46) || 
                        (x==people_left+41 && y==people_up+46) || 
                        (x==people_left+42 && y==people_up+46) || 
                        (x==people_left+43 && y==people_up+46) || 
                        (x==people_left+44 && y==people_up+46) || 
                        (x==people_left+45 && y==people_up+46) || 
                        (x==people_left+46 && y==people_up+46) || 
                        (x==people_left+47 && y==people_up+46) || 
                        (x==people_left+48 && y==people_up+46) || 
                        (x==people_left+49 && y==people_up+46) || 
                        (x==people_left+50 && y==people_up+46) || 
                        (x==people_left+51 && y==people_up+46) || 
                        (x==people_left+52 && y==people_up+46) || 
                        (x==people_left+53 && y==people_up+46) || 
                        (x==people_left+54 && y==people_up+46) || 
                        (x==people_left+55 && y==people_up+46) || 
                        (x==people_left+56 && y==people_up+46) || 
                        (x==people_left+57 && y==people_up+46) || 
                        (x==people_left+58 && y==people_up+46) || 
                        (x==people_left+59 && y==people_up+46) || 
                        (x==people_left+60 && y==people_up+46) || 
                        (x==people_left+61 && y==people_up+46) || 
                        (x==people_left+62 && y==people_up+46) || 
                        (x==people_left+63 && y==people_up+46) || 
                        (x==people_left+64 && y==people_up+46) || 
                        (x==people_left+65 && y==people_up+46) || 
                        (x==people_left+66 && y==people_up+46) || 
                        (x==people_left+67 && y==people_up+46) || 
                        (x==people_left+68 && y==people_up+46) || 
                        (x==people_left+69 && y==people_up+46) || 
                        (x==people_left+70 && y==people_up+46) || 
                        (x==people_left+71 && y==people_up+46) || 
                        (x==people_left+72 && y==people_up+46) || 
                        (x==people_left-33 && y==people_up+47) || 
                        (x==people_left-32 && y==people_up+47) || 
                        (x==people_left-31 && y==people_up+47) || 
                        (x==people_left-30 && y==people_up+47) || 
                        (x==people_left-29 && y==people_up+47) || 
                        (x==people_left-28 && y==people_up+47) || 
                        (x==people_left-27 && y==people_up+47) || 
                        (x==people_left-26 && y==people_up+47) || 
                        (x==people_left-25 && y==people_up+47) || 
                        (x==people_left-24 && y==people_up+47) || 
                        (x==people_left-23 && y==people_up+47) || 
                        (x==people_left-22 && y==people_up+47) || 
                        (x==people_left-21 && y==people_up+47) || 
                        (x==people_left-20 && y==people_up+47) || 
                        (x==people_left-19 && y==people_up+47) || 
                        (x==people_left-18 && y==people_up+47) || 
                        (x==people_left-17 && y==people_up+47) || 
                        (x==people_left-16 && y==people_up+47) || 
                        (x==people_left-15 && y==people_up+47) || 
                        (x==people_left-14 && y==people_up+47) || 
                        (x==people_left-13 && y==people_up+47) || 
                        (x==people_left-12 && y==people_up+47) || 
                        (x==people_left-11 && y==people_up+47) || 
                        (x==people_left-10 && y==people_up+47) || 
                        (x==people_left-9 && y==people_up+47) || 
                        (x==people_left-8 && y==people_up+47) || 
                        (x==people_left-7 && y==people_up+47) || 
                        (x==people_left-6 && y==people_up+47) || 
                        (x==people_left-5 && y==people_up+47) || 
                        (x==people_left-4 && y==people_up+47) || 
                        (x==people_left-3 && y==people_up+47) || 
                        (x==people_left-2 && y==people_up+47) || 
                        (x==people_left-1 && y==people_up+47) || 
                        (x==people_left+0 && y==people_up+47) || 
                        (x==people_left+1 && y==people_up+47) || 
                        (x==people_left+2 && y==people_up+47) || 
                        (x==people_left+3 && y==people_up+47) || 
                        (x==people_left+4 && y==people_up+47) || 
                        (x==people_left+5 && y==people_up+47) || 
                        (x==people_left+6 && y==people_up+47) || 
                        (x==people_left+7 && y==people_up+47) || 
                        (x==people_left+8 && y==people_up+47) || 
                        (x==people_left+9 && y==people_up+47) || 
                        (x==people_left+10 && y==people_up+47) || 
                        (x==people_left+11 && y==people_up+47) || 
                        (x==people_left+12 && y==people_up+47) || 
                        (x==people_left+13 && y==people_up+47) || 
                        (x==people_left+14 && y==people_up+47) || 
                        (x==people_left+15 && y==people_up+47) || 
                        (x==people_left+16 && y==people_up+47) || 
                        (x==people_left+17 && y==people_up+47) || 
                        (x==people_left+18 && y==people_up+47) || 
                        (x==people_left+19 && y==people_up+47) || 
                        (x==people_left+20 && y==people_up+47) || 
                        (x==people_left+21 && y==people_up+47) || 
                        (x==people_left+22 && y==people_up+47) || 
                        (x==people_left+23 && y==people_up+47) || 
                        (x==people_left+24 && y==people_up+47) || 
                        (x==people_left+25 && y==people_up+47) || 
                        (x==people_left+26 && y==people_up+47) || 
                        (x==people_left+27 && y==people_up+47) || 
                        (x==people_left+28 && y==people_up+47) || 
                        (x==people_left+29 && y==people_up+47) || 
                        (x==people_left+30 && y==people_up+47) || 
                        (x==people_left+31 && y==people_up+47) || 
                        (x==people_left+32 && y==people_up+47) || 
                        (x==people_left+33 && y==people_up+47) || 
                        (x==people_left+34 && y==people_up+47) || 
                        (x==people_left+35 && y==people_up+47) || 
                        (x==people_left+36 && y==people_up+47) || 
                        (x==people_left+37 && y==people_up+47) || 
                        (x==people_left+38 && y==people_up+47) || 
                        (x==people_left+39 && y==people_up+47) || 
                        (x==people_left+40 && y==people_up+47) || 
                        (x==people_left+41 && y==people_up+47) || 
                        (x==people_left+42 && y==people_up+47) || 
                        (x==people_left+43 && y==people_up+47) || 
                        (x==people_left+44 && y==people_up+47) || 
                        (x==people_left+45 && y==people_up+47) || 
                        (x==people_left+46 && y==people_up+47) || 
                        (x==people_left+47 && y==people_up+47) || 
                        (x==people_left+48 && y==people_up+47) || 
                        (x==people_left+49 && y==people_up+47) || 
                        (x==people_left+50 && y==people_up+47) || 
                        (x==people_left+51 && y==people_up+47) || 
                        (x==people_left+52 && y==people_up+47) || 
                        (x==people_left+53 && y==people_up+47) || 
                        (x==people_left+54 && y==people_up+47) || 
                        (x==people_left+55 && y==people_up+47) || 
                        (x==people_left+56 && y==people_up+47) || 
                        (x==people_left+57 && y==people_up+47) || 
                        (x==people_left+58 && y==people_up+47) || 
                        (x==people_left+59 && y==people_up+47) || 
                        (x==people_left+60 && y==people_up+47) || 
                        (x==people_left+61 && y==people_up+47) || 
                        (x==people_left+62 && y==people_up+47) || 
                        (x==people_left+63 && y==people_up+47) || 
                        (x==people_left+64 && y==people_up+47) || 
                        (x==people_left+65 && y==people_up+47) || 
                        (x==people_left+66 && y==people_up+47) || 
                        (x==people_left+67 && y==people_up+47) || 
                        (x==people_left+68 && y==people_up+47) || 
                        (x==people_left+69 && y==people_up+47) || 
                        (x==people_left+70 && y==people_up+47) || 
                        (x==people_left+71 && y==people_up+47) || 
                        (x==people_left-33 && y==people_up+48) || 
                        (x==people_left-32 && y==people_up+48) || 
                        (x==people_left-31 && y==people_up+48) || 
                        (x==people_left-30 && y==people_up+48) || 
                        (x==people_left-29 && y==people_up+48) || 
                        (x==people_left-28 && y==people_up+48) || 
                        (x==people_left-27 && y==people_up+48) || 
                        (x==people_left-26 && y==people_up+48) || 
                        (x==people_left-25 && y==people_up+48) || 
                        (x==people_left-24 && y==people_up+48) || 
                        (x==people_left-23 && y==people_up+48) || 
                        (x==people_left-22 && y==people_up+48) || 
                        (x==people_left-21 && y==people_up+48) || 
                        (x==people_left-20 && y==people_up+48) || 
                        (x==people_left-19 && y==people_up+48) || 
                        (x==people_left-18 && y==people_up+48) || 
                        (x==people_left-17 && y==people_up+48) || 
                        (x==people_left-16 && y==people_up+48) || 
                        (x==people_left-15 && y==people_up+48) || 
                        (x==people_left-14 && y==people_up+48) || 
                        (x==people_left-13 && y==people_up+48) || 
                        (x==people_left-12 && y==people_up+48) || 
                        (x==people_left-11 && y==people_up+48) || 
                        (x==people_left-10 && y==people_up+48) || 
                        (x==people_left-9 && y==people_up+48) || 
                        (x==people_left-8 && y==people_up+48) || 
                        (x==people_left-7 && y==people_up+48) || 
                        (x==people_left-6 && y==people_up+48) || 
                        (x==people_left-5 && y==people_up+48) || 
                        (x==people_left-4 && y==people_up+48) || 
                        (x==people_left-3 && y==people_up+48) || 
                        (x==people_left-2 && y==people_up+48) || 
                        (x==people_left-1 && y==people_up+48) || 
                        (x==people_left+0 && y==people_up+48) || 
                        (x==people_left+1 && y==people_up+48) || 
                        (x==people_left+2 && y==people_up+48) || 
                        (x==people_left+3 && y==people_up+48) || 
                        (x==people_left+4 && y==people_up+48) || 
                        (x==people_left+5 && y==people_up+48) || 
                        (x==people_left+6 && y==people_up+48) || 
                        (x==people_left+7 && y==people_up+48) || 
                        (x==people_left+8 && y==people_up+48) || 
                        (x==people_left+9 && y==people_up+48) || 
                        (x==people_left+10 && y==people_up+48) || 
                        (x==people_left+11 && y==people_up+48) || 
                        (x==people_left+12 && y==people_up+48) || 
                        (x==people_left+13 && y==people_up+48) || 
                        (x==people_left+14 && y==people_up+48) || 
                        (x==people_left+15 && y==people_up+48) || 
                        (x==people_left+16 && y==people_up+48) || 
                        (x==people_left+17 && y==people_up+48) || 
                        (x==people_left+18 && y==people_up+48) || 
                        (x==people_left+19 && y==people_up+48) || 
                        (x==people_left+20 && y==people_up+48) || 
                        (x==people_left+21 && y==people_up+48) || 
                        (x==people_left+22 && y==people_up+48) || 
                        (x==people_left+23 && y==people_up+48) || 
                        (x==people_left+24 && y==people_up+48) || 
                        (x==people_left+25 && y==people_up+48) || 
                        (x==people_left+26 && y==people_up+48) || 
                        (x==people_left+27 && y==people_up+48) || 
                        (x==people_left+28 && y==people_up+48) || 
                        (x==people_left+29 && y==people_up+48) || 
                        (x==people_left+30 && y==people_up+48) || 
                        (x==people_left+31 && y==people_up+48) || 
                        (x==people_left+32 && y==people_up+48) || 
                        (x==people_left+33 && y==people_up+48) || 
                        (x==people_left+34 && y==people_up+48) || 
                        (x==people_left+35 && y==people_up+48) || 
                        (x==people_left+36 && y==people_up+48) || 
                        (x==people_left+37 && y==people_up+48) || 
                        (x==people_left+38 && y==people_up+48) || 
                        (x==people_left+39 && y==people_up+48) || 
                        (x==people_left+40 && y==people_up+48) || 
                        (x==people_left+41 && y==people_up+48) || 
                        (x==people_left+42 && y==people_up+48) || 
                        (x==people_left+43 && y==people_up+48) || 
                        (x==people_left+44 && y==people_up+48) || 
                        (x==people_left+45 && y==people_up+48) || 
                        (x==people_left+46 && y==people_up+48) || 
                        (x==people_left+47 && y==people_up+48) || 
                        (x==people_left+48 && y==people_up+48) || 
                        (x==people_left+49 && y==people_up+48) || 
                        (x==people_left+50 && y==people_up+48) || 
                        (x==people_left+51 && y==people_up+48) || 
                        (x==people_left+52 && y==people_up+48) || 
                        (x==people_left+53 && y==people_up+48) || 
                        (x==people_left+54 && y==people_up+48) || 
                        (x==people_left+55 && y==people_up+48) || 
                        (x==people_left+56 && y==people_up+48) || 
                        (x==people_left+57 && y==people_up+48) || 
                        (x==people_left+58 && y==people_up+48) || 
                        (x==people_left+59 && y==people_up+48) || 
                        (x==people_left+60 && y==people_up+48) || 
                        (x==people_left+61 && y==people_up+48) || 
                        (x==people_left+62 && y==people_up+48) || 
                        (x==people_left+63 && y==people_up+48) || 
                        (x==people_left+64 && y==people_up+48) || 
                        (x==people_left+65 && y==people_up+48) || 
                        (x==people_left+66 && y==people_up+48) || 
                        (x==people_left+67 && y==people_up+48) || 
                        (x==people_left+68 && y==people_up+48) || 
                        (x==people_left+69 && y==people_up+48) || 
                        (x==people_left+70 && y==people_up+48) || 
                        (x==people_left+71 && y==people_up+48) || 
                        (x==people_left-32 && y==people_up+49) || 
                        (x==people_left-31 && y==people_up+49) || 
                        (x==people_left-30 && y==people_up+49) || 
                        (x==people_left-29 && y==people_up+49) || 
                        (x==people_left-28 && y==people_up+49) || 
                        (x==people_left-27 && y==people_up+49) || 
                        (x==people_left-26 && y==people_up+49) || 
                        (x==people_left-25 && y==people_up+49) || 
                        (x==people_left-24 && y==people_up+49) || 
                        (x==people_left-23 && y==people_up+49) || 
                        (x==people_left-22 && y==people_up+49) || 
                        (x==people_left-21 && y==people_up+49) || 
                        (x==people_left-20 && y==people_up+49) || 
                        (x==people_left-19 && y==people_up+49) || 
                        (x==people_left-18 && y==people_up+49) || 
                        (x==people_left-17 && y==people_up+49) || 
                        (x==people_left-16 && y==people_up+49) || 
                        (x==people_left-15 && y==people_up+49) || 
                        (x==people_left-14 && y==people_up+49) || 
                        (x==people_left-13 && y==people_up+49) || 
                        (x==people_left-12 && y==people_up+49) || 
                        (x==people_left-11 && y==people_up+49) || 
                        (x==people_left-10 && y==people_up+49) || 
                        (x==people_left-9 && y==people_up+49) || 
                        (x==people_left-8 && y==people_up+49) || 
                        (x==people_left-7 && y==people_up+49) || 
                        (x==people_left-6 && y==people_up+49) || 
                        (x==people_left-5 && y==people_up+49) || 
                        (x==people_left-4 && y==people_up+49) || 
                        (x==people_left-3 && y==people_up+49) || 
                        (x==people_left-2 && y==people_up+49) || 
                        (x==people_left-1 && y==people_up+49) || 
                        (x==people_left+0 && y==people_up+49) || 
                        (x==people_left+1 && y==people_up+49) || 
                        (x==people_left+2 && y==people_up+49) || 
                        (x==people_left+3 && y==people_up+49) || 
                        (x==people_left+4 && y==people_up+49) || 
                        (x==people_left+5 && y==people_up+49) || 
                        (x==people_left+6 && y==people_up+49) || 
                        (x==people_left+7 && y==people_up+49) || 
                        (x==people_left+8 && y==people_up+49) || 
                        (x==people_left+9 && y==people_up+49) || 
                        (x==people_left+10 && y==people_up+49) || 
                        (x==people_left+11 && y==people_up+49) || 
                        (x==people_left+12 && y==people_up+49) || 
                        (x==people_left+13 && y==people_up+49) || 
                        (x==people_left+14 && y==people_up+49) || 
                        (x==people_left+15 && y==people_up+49) || 
                        (x==people_left+16 && y==people_up+49) || 
                        (x==people_left+17 && y==people_up+49) || 
                        (x==people_left+18 && y==people_up+49) || 
                        (x==people_left+19 && y==people_up+49) || 
                        (x==people_left+20 && y==people_up+49) || 
                        (x==people_left+21 && y==people_up+49) || 
                        (x==people_left+22 && y==people_up+49) || 
                        (x==people_left+23 && y==people_up+49) || 
                        (x==people_left+24 && y==people_up+49) || 
                        (x==people_left+25 && y==people_up+49) || 
                        (x==people_left+26 && y==people_up+49) || 
                        (x==people_left+27 && y==people_up+49) || 
                        (x==people_left+28 && y==people_up+49) || 
                        (x==people_left+29 && y==people_up+49) || 
                        (x==people_left+30 && y==people_up+49) || 
                        (x==people_left+31 && y==people_up+49) || 
                        (x==people_left+32 && y==people_up+49) || 
                        (x==people_left+33 && y==people_up+49) || 
                        (x==people_left+34 && y==people_up+49) || 
                        (x==people_left+35 && y==people_up+49) || 
                        (x==people_left+36 && y==people_up+49) || 
                        (x==people_left+37 && y==people_up+49) || 
                        (x==people_left+38 && y==people_up+49) || 
                        (x==people_left+39 && y==people_up+49) || 
                        (x==people_left+40 && y==people_up+49) || 
                        (x==people_left+41 && y==people_up+49) || 
                        (x==people_left+42 && y==people_up+49) || 
                        (x==people_left+43 && y==people_up+49) || 
                        (x==people_left+44 && y==people_up+49) || 
                        (x==people_left+45 && y==people_up+49) || 
                        (x==people_left+46 && y==people_up+49) || 
                        (x==people_left+47 && y==people_up+49) || 
                        (x==people_left+48 && y==people_up+49) || 
                        (x==people_left+49 && y==people_up+49) || 
                        (x==people_left+50 && y==people_up+49) || 
                        (x==people_left+51 && y==people_up+49) || 
                        (x==people_left+52 && y==people_up+49) || 
                        (x==people_left+53 && y==people_up+49) || 
                        (x==people_left+54 && y==people_up+49) || 
                        (x==people_left+55 && y==people_up+49) || 
                        (x==people_left+56 && y==people_up+49) || 
                        (x==people_left+57 && y==people_up+49) || 
                        (x==people_left+58 && y==people_up+49) || 
                        (x==people_left+59 && y==people_up+49) || 
                        (x==people_left+60 && y==people_up+49) || 
                        (x==people_left+61 && y==people_up+49) || 
                        (x==people_left+62 && y==people_up+49) || 
                        (x==people_left+63 && y==people_up+49) || 
                        (x==people_left+64 && y==people_up+49) || 
                        (x==people_left+65 && y==people_up+49) || 
                        (x==people_left+66 && y==people_up+49) || 
                        (x==people_left+67 && y==people_up+49) || 
                        (x==people_left+68 && y==people_up+49) || 
                        (x==people_left+69 && y==people_up+49) || 
                        (x==people_left+70 && y==people_up+49) || 
                        (x==people_left-32 && y==people_up+50) || 
                        (x==people_left-31 && y==people_up+50) || 
                        (x==people_left-30 && y==people_up+50) || 
                        (x==people_left-29 && y==people_up+50) || 
                        (x==people_left-28 && y==people_up+50) || 
                        (x==people_left-27 && y==people_up+50) || 
                        (x==people_left-26 && y==people_up+50) || 
                        (x==people_left-25 && y==people_up+50) || 
                        (x==people_left-24 && y==people_up+50) || 
                        (x==people_left-23 && y==people_up+50) || 
                        (x==people_left-22 && y==people_up+50) || 
                        (x==people_left-21 && y==people_up+50) || 
                        (x==people_left-20 && y==people_up+50) || 
                        (x==people_left-19 && y==people_up+50) || 
                        (x==people_left-18 && y==people_up+50) || 
                        (x==people_left-17 && y==people_up+50) || 
                        (x==people_left-16 && y==people_up+50) || 
                        (x==people_left-15 && y==people_up+50) || 
                        (x==people_left-14 && y==people_up+50) || 
                        (x==people_left-13 && y==people_up+50) || 
                        (x==people_left-12 && y==people_up+50) || 
                        (x==people_left-11 && y==people_up+50) || 
                        (x==people_left-10 && y==people_up+50) || 
                        (x==people_left-9 && y==people_up+50) || 
                        (x==people_left-8 && y==people_up+50) || 
                        (x==people_left-7 && y==people_up+50) || 
                        (x==people_left-6 && y==people_up+50) || 
                        (x==people_left-5 && y==people_up+50) || 
                        (x==people_left-4 && y==people_up+50) || 
                        (x==people_left-3 && y==people_up+50) || 
                        (x==people_left-2 && y==people_up+50) || 
                        (x==people_left-1 && y==people_up+50) || 
                        (x==people_left+0 && y==people_up+50) || 
                        (x==people_left+1 && y==people_up+50) || 
                        (x==people_left+2 && y==people_up+50) || 
                        (x==people_left+3 && y==people_up+50) || 
                        (x==people_left+4 && y==people_up+50) || 
                        (x==people_left+5 && y==people_up+50) || 
                        (x==people_left+6 && y==people_up+50) || 
                        (x==people_left+7 && y==people_up+50) || 
                        (x==people_left+8 && y==people_up+50) || 
                        (x==people_left+9 && y==people_up+50) || 
                        (x==people_left+10 && y==people_up+50) || 
                        (x==people_left+11 && y==people_up+50) || 
                        (x==people_left+12 && y==people_up+50) || 
                        (x==people_left+13 && y==people_up+50) || 
                        (x==people_left+14 && y==people_up+50) || 
                        (x==people_left+15 && y==people_up+50) || 
                        (x==people_left+16 && y==people_up+50) || 
                        (x==people_left+17 && y==people_up+50) || 
                        (x==people_left+18 && y==people_up+50) || 
                        (x==people_left+19 && y==people_up+50) || 
                        (x==people_left+20 && y==people_up+50) || 
                        (x==people_left+21 && y==people_up+50) || 
                        (x==people_left+22 && y==people_up+50) || 
                        (x==people_left+23 && y==people_up+50) || 
                        (x==people_left+24 && y==people_up+50) || 
                        (x==people_left+25 && y==people_up+50) || 
                        (x==people_left+26 && y==people_up+50) || 
                        (x==people_left+27 && y==people_up+50) || 
                        (x==people_left+28 && y==people_up+50) || 
                        (x==people_left+29 && y==people_up+50) || 
                        (x==people_left+30 && y==people_up+50) || 
                        (x==people_left+31 && y==people_up+50) || 
                        (x==people_left+32 && y==people_up+50) || 
                        (x==people_left+33 && y==people_up+50) || 
                        (x==people_left+34 && y==people_up+50) || 
                        (x==people_left+35 && y==people_up+50) || 
                        (x==people_left+36 && y==people_up+50) || 
                        (x==people_left+37 && y==people_up+50) || 
                        (x==people_left+38 && y==people_up+50) || 
                        (x==people_left+39 && y==people_up+50) || 
                        (x==people_left+40 && y==people_up+50) || 
                        (x==people_left+41 && y==people_up+50) || 
                        (x==people_left+42 && y==people_up+50) || 
                        (x==people_left+43 && y==people_up+50) || 
                        (x==people_left+44 && y==people_up+50) || 
                        (x==people_left+45 && y==people_up+50) || 
                        (x==people_left+46 && y==people_up+50) || 
                        (x==people_left+47 && y==people_up+50) || 
                        (x==people_left+48 && y==people_up+50) || 
                        (x==people_left+49 && y==people_up+50) || 
                        (x==people_left+50 && y==people_up+50) || 
                        (x==people_left+51 && y==people_up+50) || 
                        (x==people_left+52 && y==people_up+50) || 
                        (x==people_left+53 && y==people_up+50) || 
                        (x==people_left+54 && y==people_up+50) || 
                        (x==people_left+55 && y==people_up+50) || 
                        (x==people_left+56 && y==people_up+50) || 
                        (x==people_left+57 && y==people_up+50) || 
                        (x==people_left+58 && y==people_up+50) || 
                        (x==people_left+59 && y==people_up+50) || 
                        (x==people_left+60 && y==people_up+50) || 
                        (x==people_left+61 && y==people_up+50) || 
                        (x==people_left+62 && y==people_up+50) || 
                        (x==people_left+63 && y==people_up+50) || 
                        (x==people_left+64 && y==people_up+50) || 
                        (x==people_left+65 && y==people_up+50) || 
                        (x==people_left+66 && y==people_up+50) || 
                        (x==people_left+67 && y==people_up+50) || 
                        (x==people_left+68 && y==people_up+50) || 
                        (x==people_left+69 && y==people_up+50) || 
                        (x==people_left+70 && y==people_up+50) || 
                        (x==people_left-31 && y==people_up+51) || 
                        (x==people_left-30 && y==people_up+51) || 
                        (x==people_left-29 && y==people_up+51) || 
                        (x==people_left-28 && y==people_up+51) || 
                        (x==people_left-27 && y==people_up+51) || 
                        (x==people_left-26 && y==people_up+51) || 
                        (x==people_left-25 && y==people_up+51) || 
                        (x==people_left-24 && y==people_up+51) || 
                        (x==people_left-23 && y==people_up+51) || 
                        (x==people_left-22 && y==people_up+51) || 
                        (x==people_left-21 && y==people_up+51) || 
                        (x==people_left-20 && y==people_up+51) || 
                        (x==people_left-19 && y==people_up+51) || 
                        (x==people_left-18 && y==people_up+51) || 
                        (x==people_left-17 && y==people_up+51) || 
                        (x==people_left-16 && y==people_up+51) || 
                        (x==people_left-15 && y==people_up+51) || 
                        (x==people_left-14 && y==people_up+51) || 
                        (x==people_left-13 && y==people_up+51) || 
                        (x==people_left-12 && y==people_up+51) || 
                        (x==people_left-11 && y==people_up+51) || 
                        (x==people_left-10 && y==people_up+51) || 
                        (x==people_left-9 && y==people_up+51) || 
                        (x==people_left-8 && y==people_up+51) || 
                        (x==people_left-7 && y==people_up+51) || 
                        (x==people_left-6 && y==people_up+51) || 
                        (x==people_left-5 && y==people_up+51) || 
                        (x==people_left-4 && y==people_up+51) || 
                        (x==people_left-3 && y==people_up+51) || 
                        (x==people_left-2 && y==people_up+51) || 
                        (x==people_left-1 && y==people_up+51) || 
                        (x==people_left+0 && y==people_up+51) || 
                        (x==people_left+1 && y==people_up+51) || 
                        (x==people_left+2 && y==people_up+51) || 
                        (x==people_left+3 && y==people_up+51) || 
                        (x==people_left+4 && y==people_up+51) || 
                        (x==people_left+5 && y==people_up+51) || 
                        (x==people_left+6 && y==people_up+51) || 
                        (x==people_left+7 && y==people_up+51) || 
                        (x==people_left+8 && y==people_up+51) || 
                        (x==people_left+9 && y==people_up+51) || 
                        (x==people_left+10 && y==people_up+51) || 
                        (x==people_left+11 && y==people_up+51) || 
                        (x==people_left+12 && y==people_up+51) || 
                        (x==people_left+13 && y==people_up+51) || 
                        (x==people_left+14 && y==people_up+51) || 
                        (x==people_left+15 && y==people_up+51) || 
                        (x==people_left+16 && y==people_up+51) || 
                        (x==people_left+17 && y==people_up+51) || 
                        (x==people_left+18 && y==people_up+51) || 
                        (x==people_left+19 && y==people_up+51) || 
                        (x==people_left+20 && y==people_up+51) || 
                        (x==people_left+21 && y==people_up+51) || 
                        (x==people_left+22 && y==people_up+51) || 
                        (x==people_left+23 && y==people_up+51) || 
                        (x==people_left+24 && y==people_up+51) || 
                        (x==people_left+25 && y==people_up+51) || 
                        (x==people_left+26 && y==people_up+51) || 
                        (x==people_left+27 && y==people_up+51) || 
                        (x==people_left+28 && y==people_up+51) || 
                        (x==people_left+29 && y==people_up+51) || 
                        (x==people_left+30 && y==people_up+51) || 
                        (x==people_left+31 && y==people_up+51) || 
                        (x==people_left+32 && y==people_up+51) || 
                        (x==people_left+33 && y==people_up+51) || 
                        (x==people_left+34 && y==people_up+51) || 
                        (x==people_left+35 && y==people_up+51) || 
                        (x==people_left+36 && y==people_up+51) || 
                        (x==people_left+37 && y==people_up+51) || 
                        (x==people_left+38 && y==people_up+51) || 
                        (x==people_left+39 && y==people_up+51) || 
                        (x==people_left+40 && y==people_up+51) || 
                        (x==people_left+41 && y==people_up+51) || 
                        (x==people_left+42 && y==people_up+51) || 
                        (x==people_left+43 && y==people_up+51) || 
                        (x==people_left+44 && y==people_up+51) || 
                        (x==people_left+45 && y==people_up+51) || 
                        (x==people_left+46 && y==people_up+51) || 
                        (x==people_left+47 && y==people_up+51) || 
                        (x==people_left+48 && y==people_up+51) || 
                        (x==people_left+49 && y==people_up+51) || 
                        (x==people_left+50 && y==people_up+51) || 
                        (x==people_left+51 && y==people_up+51) || 
                        (x==people_left+52 && y==people_up+51) || 
                        (x==people_left+53 && y==people_up+51) || 
                        (x==people_left+54 && y==people_up+51) || 
                        (x==people_left+55 && y==people_up+51) || 
                        (x==people_left+56 && y==people_up+51) || 
                        (x==people_left+57 && y==people_up+51) || 
                        (x==people_left+58 && y==people_up+51) || 
                        (x==people_left+59 && y==people_up+51) || 
                        (x==people_left+60 && y==people_up+51) || 
                        (x==people_left+61 && y==people_up+51) || 
                        (x==people_left+62 && y==people_up+51) || 
                        (x==people_left+63 && y==people_up+51) || 
                        (x==people_left+64 && y==people_up+51) || 
                        (x==people_left+65 && y==people_up+51) || 
                        (x==people_left+66 && y==people_up+51) || 
                        (x==people_left+67 && y==people_up+51) || 
                        (x==people_left+68 && y==people_up+51) || 
                        (x==people_left+69 && y==people_up+51) || 
                        (x==people_left-30 && y==people_up+52) || 
                        (x==people_left-29 && y==people_up+52) || 
                        (x==people_left-28 && y==people_up+52) || 
                        (x==people_left-27 && y==people_up+52) || 
                        (x==people_left-26 && y==people_up+52) || 
                        (x==people_left-25 && y==people_up+52) || 
                        (x==people_left-24 && y==people_up+52) || 
                        (x==people_left-23 && y==people_up+52) || 
                        (x==people_left-22 && y==people_up+52) || 
                        (x==people_left-21 && y==people_up+52) || 
                        (x==people_left-20 && y==people_up+52) || 
                        (x==people_left-19 && y==people_up+52) || 
                        (x==people_left-18 && y==people_up+52) || 
                        (x==people_left-17 && y==people_up+52) || 
                        (x==people_left-16 && y==people_up+52) || 
                        (x==people_left-15 && y==people_up+52) || 
                        (x==people_left-14 && y==people_up+52) || 
                        (x==people_left-13 && y==people_up+52) || 
                        (x==people_left-12 && y==people_up+52) || 
                        (x==people_left-11 && y==people_up+52) || 
                        (x==people_left-10 && y==people_up+52) || 
                        (x==people_left-9 && y==people_up+52) || 
                        (x==people_left-8 && y==people_up+52) || 
                        (x==people_left-7 && y==people_up+52) || 
                        (x==people_left-6 && y==people_up+52) || 
                        (x==people_left-5 && y==people_up+52) || 
                        (x==people_left-4 && y==people_up+52) || 
                        (x==people_left-3 && y==people_up+52) || 
                        (x==people_left-2 && y==people_up+52) || 
                        (x==people_left-1 && y==people_up+52) || 
                        (x==people_left+0 && y==people_up+52) || 
                        (x==people_left+1 && y==people_up+52) || 
                        (x==people_left+2 && y==people_up+52) || 
                        (x==people_left+3 && y==people_up+52) || 
                        (x==people_left+4 && y==people_up+52) || 
                        (x==people_left+5 && y==people_up+52) || 
                        (x==people_left+6 && y==people_up+52) || 
                        (x==people_left+7 && y==people_up+52) || 
                        (x==people_left+8 && y==people_up+52) || 
                        (x==people_left+9 && y==people_up+52) || 
                        (x==people_left+10 && y==people_up+52) || 
                        (x==people_left+11 && y==people_up+52) || 
                        (x==people_left+12 && y==people_up+52) || 
                        (x==people_left+13 && y==people_up+52) || 
                        (x==people_left+14 && y==people_up+52) || 
                        (x==people_left+15 && y==people_up+52) || 
                        (x==people_left+16 && y==people_up+52) || 
                        (x==people_left+17 && y==people_up+52) || 
                        (x==people_left+18 && y==people_up+52) || 
                        (x==people_left+19 && y==people_up+52) || 
                        (x==people_left+20 && y==people_up+52) || 
                        (x==people_left+21 && y==people_up+52) || 
                        (x==people_left+22 && y==people_up+52) || 
                        (x==people_left+23 && y==people_up+52) || 
                        (x==people_left+24 && y==people_up+52) || 
                        (x==people_left+25 && y==people_up+52) || 
                        (x==people_left+26 && y==people_up+52) || 
                        (x==people_left+27 && y==people_up+52) || 
                        (x==people_left+28 && y==people_up+52) || 
                        (x==people_left+29 && y==people_up+52) || 
                        (x==people_left+30 && y==people_up+52) || 
                        (x==people_left+31 && y==people_up+52) || 
                        (x==people_left+32 && y==people_up+52) || 
                        (x==people_left+33 && y==people_up+52) || 
                        (x==people_left+34 && y==people_up+52) || 
                        (x==people_left+35 && y==people_up+52) || 
                        (x==people_left+36 && y==people_up+52) || 
                        (x==people_left+37 && y==people_up+52) || 
                        (x==people_left+38 && y==people_up+52) || 
                        (x==people_left+39 && y==people_up+52) || 
                        (x==people_left+40 && y==people_up+52) || 
                        (x==people_left+41 && y==people_up+52) || 
                        (x==people_left+42 && y==people_up+52) || 
                        (x==people_left+43 && y==people_up+52) || 
                        (x==people_left+44 && y==people_up+52) || 
                        (x==people_left+45 && y==people_up+52) || 
                        (x==people_left+46 && y==people_up+52) || 
                        (x==people_left+47 && y==people_up+52) || 
                        (x==people_left+48 && y==people_up+52) || 
                        (x==people_left+49 && y==people_up+52) || 
                        (x==people_left+50 && y==people_up+52) || 
                        (x==people_left+51 && y==people_up+52) || 
                        (x==people_left+52 && y==people_up+52) || 
                        (x==people_left+53 && y==people_up+52) || 
                        (x==people_left+54 && y==people_up+52) || 
                        (x==people_left+55 && y==people_up+52) || 
                        (x==people_left+56 && y==people_up+52) || 
                        (x==people_left+57 && y==people_up+52) || 
                        (x==people_left+58 && y==people_up+52) || 
                        (x==people_left+59 && y==people_up+52) || 
                        (x==people_left+60 && y==people_up+52) || 
                        (x==people_left+61 && y==people_up+52) || 
                        (x==people_left+62 && y==people_up+52) || 
                        (x==people_left+63 && y==people_up+52) || 
                        (x==people_left+64 && y==people_up+52) || 
                        (x==people_left+65 && y==people_up+52) || 
                        (x==people_left+66 && y==people_up+52) || 
                        (x==people_left+67 && y==people_up+52) || 
                        (x==people_left+68 && y==people_up+52) || 
                        (x==people_left-30 && y==people_up+53) || 
                        (x==people_left-29 && y==people_up+53) || 
                        (x==people_left-28 && y==people_up+53) || 
                        (x==people_left-27 && y==people_up+53) || 
                        (x==people_left-26 && y==people_up+53) || 
                        (x==people_left-25 && y==people_up+53) || 
                        (x==people_left-24 && y==people_up+53) || 
                        (x==people_left-23 && y==people_up+53) || 
                        (x==people_left-22 && y==people_up+53) || 
                        (x==people_left-21 && y==people_up+53) || 
                        (x==people_left-20 && y==people_up+53) || 
                        (x==people_left-19 && y==people_up+53) || 
                        (x==people_left-18 && y==people_up+53) || 
                        (x==people_left-17 && y==people_up+53) || 
                        (x==people_left-16 && y==people_up+53) || 
                        (x==people_left-15 && y==people_up+53) || 
                        (x==people_left-14 && y==people_up+53) || 
                        (x==people_left-13 && y==people_up+53) || 
                        (x==people_left-12 && y==people_up+53) || 
                        (x==people_left-11 && y==people_up+53) || 
                        (x==people_left-10 && y==people_up+53) || 
                        (x==people_left-9 && y==people_up+53) || 
                        (x==people_left-8 && y==people_up+53) || 
                        (x==people_left-7 && y==people_up+53) || 
                        (x==people_left-6 && y==people_up+53) || 
                        (x==people_left-5 && y==people_up+53) || 
                        (x==people_left-4 && y==people_up+53) || 
                        (x==people_left-3 && y==people_up+53) || 
                        (x==people_left-2 && y==people_up+53) || 
                        (x==people_left-1 && y==people_up+53) || 
                        (x==people_left+0 && y==people_up+53) || 
                        (x==people_left+1 && y==people_up+53) || 
                        (x==people_left+2 && y==people_up+53) || 
                        (x==people_left+3 && y==people_up+53) || 
                        (x==people_left+4 && y==people_up+53) || 
                        (x==people_left+5 && y==people_up+53) || 
                        (x==people_left+6 && y==people_up+53) || 
                        (x==people_left+7 && y==people_up+53) || 
                        (x==people_left+8 && y==people_up+53) || 
                        (x==people_left+9 && y==people_up+53) || 
                        (x==people_left+10 && y==people_up+53) || 
                        (x==people_left+11 && y==people_up+53) || 
                        (x==people_left+12 && y==people_up+53) || 
                        (x==people_left+13 && y==people_up+53) || 
                        (x==people_left+14 && y==people_up+53) || 
                        (x==people_left+15 && y==people_up+53) || 
                        (x==people_left+16 && y==people_up+53) || 
                        (x==people_left+17 && y==people_up+53) || 
                        (x==people_left+18 && y==people_up+53) || 
                        (x==people_left+19 && y==people_up+53) || 
                        (x==people_left+20 && y==people_up+53) || 
                        (x==people_left+21 && y==people_up+53) || 
                        (x==people_left+22 && y==people_up+53) || 
                        (x==people_left+23 && y==people_up+53) || 
                        (x==people_left+24 && y==people_up+53) || 
                        (x==people_left+25 && y==people_up+53) || 
                        (x==people_left+26 && y==people_up+53) || 
                        (x==people_left+27 && y==people_up+53) || 
                        (x==people_left+28 && y==people_up+53) || 
                        (x==people_left+29 && y==people_up+53) || 
                        (x==people_left+30 && y==people_up+53) || 
                        (x==people_left+31 && y==people_up+53) || 
                        (x==people_left+32 && y==people_up+53) || 
                        (x==people_left+33 && y==people_up+53) || 
                        (x==people_left+34 && y==people_up+53) || 
                        (x==people_left+35 && y==people_up+53) || 
                        (x==people_left+36 && y==people_up+53) || 
                        (x==people_left+37 && y==people_up+53) || 
                        (x==people_left+38 && y==people_up+53) || 
                        (x==people_left+39 && y==people_up+53) || 
                        (x==people_left+40 && y==people_up+53) || 
                        (x==people_left+41 && y==people_up+53) || 
                        (x==people_left+42 && y==people_up+53) || 
                        (x==people_left+43 && y==people_up+53) || 
                        (x==people_left+44 && y==people_up+53) || 
                        (x==people_left+45 && y==people_up+53) || 
                        (x==people_left+46 && y==people_up+53) || 
                        (x==people_left+47 && y==people_up+53) || 
                        (x==people_left+48 && y==people_up+53) || 
                        (x==people_left+49 && y==people_up+53) || 
                        (x==people_left+50 && y==people_up+53) || 
                        (x==people_left+51 && y==people_up+53) || 
                        (x==people_left+52 && y==people_up+53) || 
                        (x==people_left+53 && y==people_up+53) || 
                        (x==people_left+54 && y==people_up+53) || 
                        (x==people_left+55 && y==people_up+53) || 
                        (x==people_left+56 && y==people_up+53) || 
                        (x==people_left+57 && y==people_up+53) || 
                        (x==people_left+58 && y==people_up+53) || 
                        (x==people_left+59 && y==people_up+53) || 
                        (x==people_left+60 && y==people_up+53) || 
                        (x==people_left+61 && y==people_up+53) || 
                        (x==people_left+62 && y==people_up+53) || 
                        (x==people_left+63 && y==people_up+53) || 
                        (x==people_left+64 && y==people_up+53) || 
                        (x==people_left+65 && y==people_up+53) || 
                        (x==people_left+66 && y==people_up+53) || 
                        (x==people_left+67 && y==people_up+53) || 
                        (x==people_left+68 && y==people_up+53) || 
                        (x==people_left-29 && y==people_up+54) || 
                        (x==people_left-28 && y==people_up+54) || 
                        (x==people_left-27 && y==people_up+54) || 
                        (x==people_left-26 && y==people_up+54) || 
                        (x==people_left-25 && y==people_up+54) || 
                        (x==people_left-24 && y==people_up+54) || 
                        (x==people_left-23 && y==people_up+54) || 
                        (x==people_left-22 && y==people_up+54) || 
                        (x==people_left-21 && y==people_up+54) || 
                        (x==people_left-20 && y==people_up+54) || 
                        (x==people_left-19 && y==people_up+54) || 
                        (x==people_left-18 && y==people_up+54) || 
                        (x==people_left-17 && y==people_up+54) || 
                        (x==people_left-16 && y==people_up+54) || 
                        (x==people_left-15 && y==people_up+54) || 
                        (x==people_left-14 && y==people_up+54) || 
                        (x==people_left-13 && y==people_up+54) || 
                        (x==people_left-12 && y==people_up+54) || 
                        (x==people_left-11 && y==people_up+54) || 
                        (x==people_left-10 && y==people_up+54) || 
                        (x==people_left-9 && y==people_up+54) || 
                        (x==people_left-8 && y==people_up+54) || 
                        (x==people_left-7 && y==people_up+54) || 
                        (x==people_left-6 && y==people_up+54) || 
                        (x==people_left-5 && y==people_up+54) || 
                        (x==people_left-4 && y==people_up+54) || 
                        (x==people_left-3 && y==people_up+54) || 
                        (x==people_left-2 && y==people_up+54) || 
                        (x==people_left-1 && y==people_up+54) || 
                        (x==people_left+0 && y==people_up+54) || 
                        (x==people_left+1 && y==people_up+54) || 
                        (x==people_left+2 && y==people_up+54) || 
                        (x==people_left+3 && y==people_up+54) || 
                        (x==people_left+4 && y==people_up+54) || 
                        (x==people_left+5 && y==people_up+54) || 
                        (x==people_left+6 && y==people_up+54) || 
                        (x==people_left+7 && y==people_up+54) || 
                        (x==people_left+8 && y==people_up+54) || 
                        (x==people_left+9 && y==people_up+54) || 
                        (x==people_left+10 && y==people_up+54) || 
                        (x==people_left+11 && y==people_up+54) || 
                        (x==people_left+12 && y==people_up+54) || 
                        (x==people_left+13 && y==people_up+54) || 
                        (x==people_left+14 && y==people_up+54) || 
                        (x==people_left+15 && y==people_up+54) || 
                        (x==people_left+16 && y==people_up+54) || 
                        (x==people_left+17 && y==people_up+54) || 
                        (x==people_left+18 && y==people_up+54) || 
                        (x==people_left+19 && y==people_up+54) || 
                        (x==people_left+20 && y==people_up+54) || 
                        (x==people_left+21 && y==people_up+54) || 
                        (x==people_left+22 && y==people_up+54) || 
                        (x==people_left+23 && y==people_up+54) || 
                        (x==people_left+24 && y==people_up+54) || 
                        (x==people_left+25 && y==people_up+54) || 
                        (x==people_left+26 && y==people_up+54) || 
                        (x==people_left+27 && y==people_up+54) || 
                        (x==people_left+28 && y==people_up+54) || 
                        (x==people_left+29 && y==people_up+54) || 
                        (x==people_left+30 && y==people_up+54) || 
                        (x==people_left+31 && y==people_up+54) || 
                        (x==people_left+32 && y==people_up+54) || 
                        (x==people_left+33 && y==people_up+54) || 
                        (x==people_left+34 && y==people_up+54) || 
                        (x==people_left+35 && y==people_up+54) || 
                        (x==people_left+36 && y==people_up+54) || 
                        (x==people_left+37 && y==people_up+54) || 
                        (x==people_left+38 && y==people_up+54) || 
                        (x==people_left+39 && y==people_up+54) || 
                        (x==people_left+40 && y==people_up+54) || 
                        (x==people_left+41 && y==people_up+54) || 
                        (x==people_left+42 && y==people_up+54) || 
                        (x==people_left+43 && y==people_up+54) || 
                        (x==people_left+44 && y==people_up+54) || 
                        (x==people_left+45 && y==people_up+54) || 
                        (x==people_left+46 && y==people_up+54) || 
                        (x==people_left+47 && y==people_up+54) || 
                        (x==people_left+48 && y==people_up+54) || 
                        (x==people_left+49 && y==people_up+54) || 
                        (x==people_left+50 && y==people_up+54) || 
                        (x==people_left+51 && y==people_up+54) || 
                        (x==people_left+52 && y==people_up+54) || 
                        (x==people_left+53 && y==people_up+54) || 
                        (x==people_left+54 && y==people_up+54) || 
                        (x==people_left+55 && y==people_up+54) || 
                        (x==people_left+56 && y==people_up+54) || 
                        (x==people_left+57 && y==people_up+54) || 
                        (x==people_left+58 && y==people_up+54) || 
                        (x==people_left+59 && y==people_up+54) || 
                        (x==people_left+60 && y==people_up+54) || 
                        (x==people_left+61 && y==people_up+54) || 
                        (x==people_left+62 && y==people_up+54) || 
                        (x==people_left+63 && y==people_up+54) || 
                        (x==people_left+64 && y==people_up+54) || 
                        (x==people_left+65 && y==people_up+54) || 
                        (x==people_left+66 && y==people_up+54) || 
                        (x==people_left+67 && y==people_up+54) || 
                        (x==people_left-28 && y==people_up+55) || 
                        (x==people_left-27 && y==people_up+55) || 
                        (x==people_left-26 && y==people_up+55) || 
                        (x==people_left-25 && y==people_up+55) || 
                        (x==people_left-24 && y==people_up+55) || 
                        (x==people_left-23 && y==people_up+55) || 
                        (x==people_left-22 && y==people_up+55) || 
                        (x==people_left-21 && y==people_up+55) || 
                        (x==people_left-20 && y==people_up+55) || 
                        (x==people_left-19 && y==people_up+55) || 
                        (x==people_left-18 && y==people_up+55) || 
                        (x==people_left-17 && y==people_up+55) || 
                        (x==people_left-16 && y==people_up+55) || 
                        (x==people_left-15 && y==people_up+55) || 
                        (x==people_left-14 && y==people_up+55) || 
                        (x==people_left-13 && y==people_up+55) || 
                        (x==people_left-12 && y==people_up+55) || 
                        (x==people_left-11 && y==people_up+55) || 
                        (x==people_left-10 && y==people_up+55) || 
                        (x==people_left-9 && y==people_up+55) || 
                        (x==people_left-8 && y==people_up+55) || 
                        (x==people_left-7 && y==people_up+55) || 
                        (x==people_left-6 && y==people_up+55) || 
                        (x==people_left-5 && y==people_up+55) || 
                        (x==people_left-4 && y==people_up+55) || 
                        (x==people_left-3 && y==people_up+55) || 
                        (x==people_left-2 && y==people_up+55) || 
                        (x==people_left-1 && y==people_up+55) || 
                        (x==people_left+0 && y==people_up+55) || 
                        (x==people_left+1 && y==people_up+55) || 
                        (x==people_left+2 && y==people_up+55) || 
                        (x==people_left+3 && y==people_up+55) || 
                        (x==people_left+4 && y==people_up+55) || 
                        (x==people_left+5 && y==people_up+55) || 
                        (x==people_left+6 && y==people_up+55) || 
                        (x==people_left+7 && y==people_up+55) || 
                        (x==people_left+8 && y==people_up+55) || 
                        (x==people_left+9 && y==people_up+55) || 
                        (x==people_left+10 && y==people_up+55) || 
                        (x==people_left+11 && y==people_up+55) || 
                        (x==people_left+12 && y==people_up+55) || 
                        (x==people_left+13 && y==people_up+55) || 
                        (x==people_left+14 && y==people_up+55) || 
                        (x==people_left+15 && y==people_up+55) || 
                        (x==people_left+16 && y==people_up+55) || 
                        (x==people_left+17 && y==people_up+55) || 
                        (x==people_left+18 && y==people_up+55) || 
                        (x==people_left+19 && y==people_up+55) || 
                        (x==people_left+20 && y==people_up+55) || 
                        (x==people_left+21 && y==people_up+55) || 
                        (x==people_left+22 && y==people_up+55) || 
                        (x==people_left+23 && y==people_up+55) || 
                        (x==people_left+24 && y==people_up+55) || 
                        (x==people_left+25 && y==people_up+55) || 
                        (x==people_left+26 && y==people_up+55) || 
                        (x==people_left+27 && y==people_up+55) || 
                        (x==people_left+28 && y==people_up+55) || 
                        (x==people_left+29 && y==people_up+55) || 
                        (x==people_left+30 && y==people_up+55) || 
                        (x==people_left+31 && y==people_up+55) || 
                        (x==people_left+32 && y==people_up+55) || 
                        (x==people_left+33 && y==people_up+55) || 
                        (x==people_left+34 && y==people_up+55) || 
                        (x==people_left+35 && y==people_up+55) || 
                        (x==people_left+36 && y==people_up+55) || 
                        (x==people_left+37 && y==people_up+55) || 
                        (x==people_left+38 && y==people_up+55) || 
                        (x==people_left+39 && y==people_up+55) || 
                        (x==people_left+40 && y==people_up+55) || 
                        (x==people_left+41 && y==people_up+55) || 
                        (x==people_left+42 && y==people_up+55) || 
                        (x==people_left+43 && y==people_up+55) || 
                        (x==people_left+44 && y==people_up+55) || 
                        (x==people_left+45 && y==people_up+55) || 
                        (x==people_left+46 && y==people_up+55) || 
                        (x==people_left+47 && y==people_up+55) || 
                        (x==people_left+48 && y==people_up+55) || 
                        (x==people_left+49 && y==people_up+55) || 
                        (x==people_left+50 && y==people_up+55) || 
                        (x==people_left+51 && y==people_up+55) || 
                        (x==people_left+52 && y==people_up+55) || 
                        (x==people_left+53 && y==people_up+55) || 
                        (x==people_left+54 && y==people_up+55) || 
                        (x==people_left+55 && y==people_up+55) || 
                        (x==people_left+56 && y==people_up+55) || 
                        (x==people_left+57 && y==people_up+55) || 
                        (x==people_left+58 && y==people_up+55) || 
                        (x==people_left+59 && y==people_up+55) || 
                        (x==people_left+60 && y==people_up+55) || 
                        (x==people_left+61 && y==people_up+55) || 
                        (x==people_left+62 && y==people_up+55) || 
                        (x==people_left+63 && y==people_up+55) || 
                        (x==people_left+64 && y==people_up+55) || 
                        (x==people_left+65 && y==people_up+55) || 
                        (x==people_left+66 && y==people_up+55) || 
                        (x==people_left-27 && y==people_up+56) || 
                        (x==people_left-26 && y==people_up+56) || 
                        (x==people_left-25 && y==people_up+56) || 
                        (x==people_left-24 && y==people_up+56) || 
                        (x==people_left-23 && y==people_up+56) || 
                        (x==people_left-22 && y==people_up+56) || 
                        (x==people_left-21 && y==people_up+56) || 
                        (x==people_left-20 && y==people_up+56) || 
                        (x==people_left-19 && y==people_up+56) || 
                        (x==people_left-18 && y==people_up+56) || 
                        (x==people_left-17 && y==people_up+56) || 
                        (x==people_left-16 && y==people_up+56) || 
                        (x==people_left-15 && y==people_up+56) || 
                        (x==people_left-14 && y==people_up+56) || 
                        (x==people_left-13 && y==people_up+56) || 
                        (x==people_left-12 && y==people_up+56) || 
                        (x==people_left-11 && y==people_up+56) || 
                        (x==people_left-10 && y==people_up+56) || 
                        (x==people_left-9 && y==people_up+56) || 
                        (x==people_left-8 && y==people_up+56) || 
                        (x==people_left-7 && y==people_up+56) || 
                        (x==people_left-6 && y==people_up+56) || 
                        (x==people_left-5 && y==people_up+56) || 
                        (x==people_left-4 && y==people_up+56) || 
                        (x==people_left-3 && y==people_up+56) || 
                        (x==people_left-2 && y==people_up+56) || 
                        (x==people_left-1 && y==people_up+56) || 
                        (x==people_left+0 && y==people_up+56) || 
                        (x==people_left+1 && y==people_up+56) || 
                        (x==people_left+2 && y==people_up+56) || 
                        (x==people_left+3 && y==people_up+56) || 
                        (x==people_left+4 && y==people_up+56) || 
                        (x==people_left+5 && y==people_up+56) || 
                        (x==people_left+6 && y==people_up+56) || 
                        (x==people_left+7 && y==people_up+56) || 
                        (x==people_left+8 && y==people_up+56) || 
                        (x==people_left+9 && y==people_up+56) || 
                        (x==people_left+10 && y==people_up+56) || 
                        (x==people_left+11 && y==people_up+56) || 
                        (x==people_left+12 && y==people_up+56) || 
                        (x==people_left+13 && y==people_up+56) || 
                        (x==people_left+14 && y==people_up+56) || 
                        (x==people_left+15 && y==people_up+56) || 
                        (x==people_left+16 && y==people_up+56) || 
                        (x==people_left+17 && y==people_up+56) || 
                        (x==people_left+18 && y==people_up+56) || 
                        (x==people_left+19 && y==people_up+56) || 
                        (x==people_left+20 && y==people_up+56) || 
                        (x==people_left+21 && y==people_up+56) || 
                        (x==people_left+22 && y==people_up+56) || 
                        (x==people_left+23 && y==people_up+56) || 
                        (x==people_left+24 && y==people_up+56) || 
                        (x==people_left+25 && y==people_up+56) || 
                        (x==people_left+26 && y==people_up+56) || 
                        (x==people_left+27 && y==people_up+56) || 
                        (x==people_left+28 && y==people_up+56) || 
                        (x==people_left+29 && y==people_up+56) || 
                        (x==people_left+30 && y==people_up+56) || 
                        (x==people_left+31 && y==people_up+56) || 
                        (x==people_left+32 && y==people_up+56) || 
                        (x==people_left+33 && y==people_up+56) || 
                        (x==people_left+34 && y==people_up+56) || 
                        (x==people_left+35 && y==people_up+56) || 
                        (x==people_left+36 && y==people_up+56) || 
                        (x==people_left+37 && y==people_up+56) || 
                        (x==people_left+38 && y==people_up+56) || 
                        (x==people_left+39 && y==people_up+56) || 
                        (x==people_left+40 && y==people_up+56) || 
                        (x==people_left+41 && y==people_up+56) || 
                        (x==people_left+42 && y==people_up+56) || 
                        (x==people_left+43 && y==people_up+56) || 
                        (x==people_left+44 && y==people_up+56) || 
                        (x==people_left+45 && y==people_up+56) || 
                        (x==people_left+46 && y==people_up+56) || 
                        (x==people_left+47 && y==people_up+56) || 
                        (x==people_left+48 && y==people_up+56) || 
                        (x==people_left+49 && y==people_up+56) || 
                        (x==people_left+50 && y==people_up+56) || 
                        (x==people_left+51 && y==people_up+56) || 
                        (x==people_left+52 && y==people_up+56) || 
                        (x==people_left+53 && y==people_up+56) || 
                        (x==people_left+54 && y==people_up+56) || 
                        (x==people_left+55 && y==people_up+56) || 
                        (x==people_left+56 && y==people_up+56) || 
                        (x==people_left+57 && y==people_up+56) || 
                        (x==people_left+58 && y==people_up+56) || 
                        (x==people_left+59 && y==people_up+56) || 
                        (x==people_left+60 && y==people_up+56) || 
                        (x==people_left+61 && y==people_up+56) || 
                        (x==people_left+62 && y==people_up+56) || 
                        (x==people_left+63 && y==people_up+56) || 
                        (x==people_left+64 && y==people_up+56) || 
                        (x==people_left+65 && y==people_up+56) || 
                        (x==people_left-27 && y==people_up+57) || 
                        (x==people_left-26 && y==people_up+57) || 
                        (x==people_left-25 && y==people_up+57) || 
                        (x==people_left-24 && y==people_up+57) || 
                        (x==people_left-23 && y==people_up+57) || 
                        (x==people_left-22 && y==people_up+57) || 
                        (x==people_left-21 && y==people_up+57) || 
                        (x==people_left-20 && y==people_up+57) || 
                        (x==people_left-19 && y==people_up+57) || 
                        (x==people_left-18 && y==people_up+57) || 
                        (x==people_left-17 && y==people_up+57) || 
                        (x==people_left-16 && y==people_up+57) || 
                        (x==people_left-15 && y==people_up+57) || 
                        (x==people_left-14 && y==people_up+57) || 
                        (x==people_left-13 && y==people_up+57) || 
                        (x==people_left-12 && y==people_up+57) || 
                        (x==people_left-11 && y==people_up+57) || 
                        (x==people_left-10 && y==people_up+57) || 
                        (x==people_left-9 && y==people_up+57) || 
                        (x==people_left-8 && y==people_up+57) || 
                        (x==people_left-7 && y==people_up+57) || 
                        (x==people_left-6 && y==people_up+57) || 
                        (x==people_left-5 && y==people_up+57) || 
                        (x==people_left-4 && y==people_up+57) || 
                        (x==people_left-3 && y==people_up+57) || 
                        (x==people_left-2 && y==people_up+57) || 
                        (x==people_left-1 && y==people_up+57) || 
                        (x==people_left+0 && y==people_up+57) || 
                        (x==people_left+1 && y==people_up+57) || 
                        (x==people_left+2 && y==people_up+57) || 
                        (x==people_left+3 && y==people_up+57) || 
                        (x==people_left+4 && y==people_up+57) || 
                        (x==people_left+5 && y==people_up+57) || 
                        (x==people_left+6 && y==people_up+57) || 
                        (x==people_left+7 && y==people_up+57) || 
                        (x==people_left+8 && y==people_up+57) || 
                        (x==people_left+9 && y==people_up+57) || 
                        (x==people_left+10 && y==people_up+57) || 
                        (x==people_left+11 && y==people_up+57) || 
                        (x==people_left+12 && y==people_up+57) || 
                        (x==people_left+13 && y==people_up+57) || 
                        (x==people_left+14 && y==people_up+57) || 
                        (x==people_left+15 && y==people_up+57) || 
                        (x==people_left+16 && y==people_up+57) || 
                        (x==people_left+17 && y==people_up+57) || 
                        (x==people_left+18 && y==people_up+57) || 
                        (x==people_left+19 && y==people_up+57) || 
                        (x==people_left+20 && y==people_up+57) || 
                        (x==people_left+21 && y==people_up+57) || 
                        (x==people_left+22 && y==people_up+57) || 
                        (x==people_left+23 && y==people_up+57) || 
                        (x==people_left+24 && y==people_up+57) || 
                        (x==people_left+25 && y==people_up+57) || 
                        (x==people_left+26 && y==people_up+57) || 
                        (x==people_left+27 && y==people_up+57) || 
                        (x==people_left+28 && y==people_up+57) || 
                        (x==people_left+29 && y==people_up+57) || 
                        (x==people_left+30 && y==people_up+57) || 
                        (x==people_left+31 && y==people_up+57) || 
                        (x==people_left+32 && y==people_up+57) || 
                        (x==people_left+33 && y==people_up+57) || 
                        (x==people_left+34 && y==people_up+57) || 
                        (x==people_left+35 && y==people_up+57) || 
                        (x==people_left+36 && y==people_up+57) || 
                        (x==people_left+37 && y==people_up+57) || 
                        (x==people_left+38 && y==people_up+57) || 
                        (x==people_left+39 && y==people_up+57) || 
                        (x==people_left+40 && y==people_up+57) || 
                        (x==people_left+41 && y==people_up+57) || 
                        (x==people_left+42 && y==people_up+57) || 
                        (x==people_left+43 && y==people_up+57) || 
                        (x==people_left+44 && y==people_up+57) || 
                        (x==people_left+45 && y==people_up+57) || 
                        (x==people_left+46 && y==people_up+57) || 
                        (x==people_left+47 && y==people_up+57) || 
                        (x==people_left+48 && y==people_up+57) || 
                        (x==people_left+49 && y==people_up+57) || 
                        (x==people_left+50 && y==people_up+57) || 
                        (x==people_left+51 && y==people_up+57) || 
                        (x==people_left+52 && y==people_up+57) || 
                        (x==people_left+53 && y==people_up+57) || 
                        (x==people_left+54 && y==people_up+57) || 
                        (x==people_left+55 && y==people_up+57) || 
                        (x==people_left+56 && y==people_up+57) || 
                        (x==people_left+57 && y==people_up+57) || 
                        (x==people_left+58 && y==people_up+57) || 
                        (x==people_left+59 && y==people_up+57) || 
                        (x==people_left+60 && y==people_up+57) || 
                        (x==people_left+61 && y==people_up+57) || 
                        (x==people_left+62 && y==people_up+57) || 
                        (x==people_left+63 && y==people_up+57) || 
                        (x==people_left+64 && y==people_up+57) || 
                        (x==people_left+65 && y==people_up+57) || 
                        (x==people_left-26 && y==people_up+58) || 
                        (x==people_left-25 && y==people_up+58) || 
                        (x==people_left-24 && y==people_up+58) || 
                        (x==people_left-23 && y==people_up+58) || 
                        (x==people_left-22 && y==people_up+58) || 
                        (x==people_left-21 && y==people_up+58) || 
                        (x==people_left-20 && y==people_up+58) || 
                        (x==people_left-19 && y==people_up+58) || 
                        (x==people_left-18 && y==people_up+58) || 
                        (x==people_left-17 && y==people_up+58) || 
                        (x==people_left-16 && y==people_up+58) || 
                        (x==people_left-15 && y==people_up+58) || 
                        (x==people_left-14 && y==people_up+58) || 
                        (x==people_left-13 && y==people_up+58) || 
                        (x==people_left-12 && y==people_up+58) || 
                        (x==people_left-11 && y==people_up+58) || 
                        (x==people_left-10 && y==people_up+58) || 
                        (x==people_left-9 && y==people_up+58) || 
                        (x==people_left-8 && y==people_up+58) || 
                        (x==people_left-7 && y==people_up+58) || 
                        (x==people_left-6 && y==people_up+58) || 
                        (x==people_left-5 && y==people_up+58) || 
                        (x==people_left-4 && y==people_up+58) || 
                        (x==people_left-3 && y==people_up+58) || 
                        (x==people_left-2 && y==people_up+58) || 
                        (x==people_left-1 && y==people_up+58) || 
                        (x==people_left+0 && y==people_up+58) || 
                        (x==people_left+1 && y==people_up+58) || 
                        (x==people_left+2 && y==people_up+58) || 
                        (x==people_left+3 && y==people_up+58) || 
                        (x==people_left+4 && y==people_up+58) || 
                        (x==people_left+5 && y==people_up+58) || 
                        (x==people_left+6 && y==people_up+58) || 
                        (x==people_left+7 && y==people_up+58) || 
                        (x==people_left+8 && y==people_up+58) || 
                        (x==people_left+9 && y==people_up+58) || 
                        (x==people_left+10 && y==people_up+58) || 
                        (x==people_left+11 && y==people_up+58) || 
                        (x==people_left+12 && y==people_up+58) || 
                        (x==people_left+13 && y==people_up+58) || 
                        (x==people_left+14 && y==people_up+58) || 
                        (x==people_left+15 && y==people_up+58) || 
                        (x==people_left+16 && y==people_up+58) || 
                        (x==people_left+17 && y==people_up+58) || 
                        (x==people_left+18 && y==people_up+58) || 
                        (x==people_left+19 && y==people_up+58) || 
                        (x==people_left+20 && y==people_up+58) || 
                        (x==people_left+21 && y==people_up+58) || 
                        (x==people_left+22 && y==people_up+58) || 
                        (x==people_left+23 && y==people_up+58) || 
                        (x==people_left+24 && y==people_up+58) || 
                        (x==people_left+25 && y==people_up+58) || 
                        (x==people_left+26 && y==people_up+58) || 
                        (x==people_left+27 && y==people_up+58) || 
                        (x==people_left+28 && y==people_up+58) || 
                        (x==people_left+29 && y==people_up+58) || 
                        (x==people_left+30 && y==people_up+58) || 
                        (x==people_left+31 && y==people_up+58) || 
                        (x==people_left+32 && y==people_up+58) || 
                        (x==people_left+33 && y==people_up+58) || 
                        (x==people_left+34 && y==people_up+58) || 
                        (x==people_left+35 && y==people_up+58) || 
                        (x==people_left+36 && y==people_up+58) || 
                        (x==people_left+37 && y==people_up+58) || 
                        (x==people_left+38 && y==people_up+58) || 
                        (x==people_left+39 && y==people_up+58) || 
                        (x==people_left+40 && y==people_up+58) || 
                        (x==people_left+41 && y==people_up+58) || 
                        (x==people_left+42 && y==people_up+58) || 
                        (x==people_left+43 && y==people_up+58) || 
                        (x==people_left+44 && y==people_up+58) || 
                        (x==people_left+45 && y==people_up+58) || 
                        (x==people_left+46 && y==people_up+58) || 
                        (x==people_left+47 && y==people_up+58) || 
                        (x==people_left+48 && y==people_up+58) || 
                        (x==people_left+49 && y==people_up+58) || 
                        (x==people_left+50 && y==people_up+58) || 
                        (x==people_left+51 && y==people_up+58) || 
                        (x==people_left+52 && y==people_up+58) || 
                        (x==people_left+53 && y==people_up+58) || 
                        (x==people_left+54 && y==people_up+58) || 
                        (x==people_left+55 && y==people_up+58) || 
                        (x==people_left+56 && y==people_up+58) || 
                        (x==people_left+57 && y==people_up+58) || 
                        (x==people_left+58 && y==people_up+58) || 
                        (x==people_left+59 && y==people_up+58) || 
                        (x==people_left+60 && y==people_up+58) || 
                        (x==people_left+61 && y==people_up+58) || 
                        (x==people_left+62 && y==people_up+58) || 
                        (x==people_left+63 && y==people_up+58) || 
                        (x==people_left+64 && y==people_up+58) || 
                        (x==people_left-25 && y==people_up+59) || 
                        (x==people_left-24 && y==people_up+59) || 
                        (x==people_left-23 && y==people_up+59) || 
                        (x==people_left-22 && y==people_up+59) || 
                        (x==people_left-21 && y==people_up+59) || 
                        (x==people_left-20 && y==people_up+59) || 
                        (x==people_left-19 && y==people_up+59) || 
                        (x==people_left-18 && y==people_up+59) || 
                        (x==people_left-17 && y==people_up+59) || 
                        (x==people_left-16 && y==people_up+59) || 
                        (x==people_left-15 && y==people_up+59) || 
                        (x==people_left-14 && y==people_up+59) || 
                        (x==people_left-13 && y==people_up+59) || 
                        (x==people_left-12 && y==people_up+59) || 
                        (x==people_left-11 && y==people_up+59) || 
                        (x==people_left-10 && y==people_up+59) || 
                        (x==people_left-9 && y==people_up+59) || 
                        (x==people_left-8 && y==people_up+59) || 
                        (x==people_left-7 && y==people_up+59) || 
                        (x==people_left-6 && y==people_up+59) || 
                        (x==people_left-5 && y==people_up+59) || 
                        (x==people_left-4 && y==people_up+59) || 
                        (x==people_left-3 && y==people_up+59) || 
                        (x==people_left-2 && y==people_up+59) || 
                        (x==people_left-1 && y==people_up+59) || 
                        (x==people_left+0 && y==people_up+59) || 
                        (x==people_left+1 && y==people_up+59) || 
                        (x==people_left+2 && y==people_up+59) || 
                        (x==people_left+3 && y==people_up+59) || 
                        (x==people_left+4 && y==people_up+59) || 
                        (x==people_left+5 && y==people_up+59) || 
                        (x==people_left+6 && y==people_up+59) || 
                        (x==people_left+7 && y==people_up+59) || 
                        (x==people_left+8 && y==people_up+59) || 
                        (x==people_left+9 && y==people_up+59) || 
                        (x==people_left+10 && y==people_up+59) || 
                        (x==people_left+11 && y==people_up+59) || 
                        (x==people_left+12 && y==people_up+59) || 
                        (x==people_left+13 && y==people_up+59) || 
                        (x==people_left+14 && y==people_up+59) || 
                        (x==people_left+15 && y==people_up+59) || 
                        (x==people_left+16 && y==people_up+59) || 
                        (x==people_left+17 && y==people_up+59) || 
                        (x==people_left+18 && y==people_up+59) || 
                        (x==people_left+19 && y==people_up+59) || 
                        (x==people_left+20 && y==people_up+59) || 
                        (x==people_left+21 && y==people_up+59) || 
                        (x==people_left+22 && y==people_up+59) || 
                        (x==people_left+23 && y==people_up+59) || 
                        (x==people_left+24 && y==people_up+59) || 
                        (x==people_left+25 && y==people_up+59) || 
                        (x==people_left+26 && y==people_up+59) || 
                        (x==people_left+27 && y==people_up+59) || 
                        (x==people_left+28 && y==people_up+59) || 
                        (x==people_left+29 && y==people_up+59) || 
                        (x==people_left+30 && y==people_up+59) || 
                        (x==people_left+31 && y==people_up+59) || 
                        (x==people_left+32 && y==people_up+59) || 
                        (x==people_left+33 && y==people_up+59) || 
                        (x==people_left+34 && y==people_up+59) || 
                        (x==people_left+35 && y==people_up+59) || 
                        (x==people_left+36 && y==people_up+59) || 
                        (x==people_left+37 && y==people_up+59) || 
                        (x==people_left+38 && y==people_up+59) || 
                        (x==people_left+39 && y==people_up+59) || 
                        (x==people_left+40 && y==people_up+59) || 
                        (x==people_left+41 && y==people_up+59) || 
                        (x==people_left+42 && y==people_up+59) || 
                        (x==people_left+43 && y==people_up+59) || 
                        (x==people_left+44 && y==people_up+59) || 
                        (x==people_left+45 && y==people_up+59) || 
                        (x==people_left+46 && y==people_up+59) || 
                        (x==people_left+47 && y==people_up+59) || 
                        (x==people_left+48 && y==people_up+59) || 
                        (x==people_left+49 && y==people_up+59) || 
                        (x==people_left+50 && y==people_up+59) || 
                        (x==people_left+51 && y==people_up+59) || 
                        (x==people_left+52 && y==people_up+59) || 
                        (x==people_left+53 && y==people_up+59) || 
                        (x==people_left+54 && y==people_up+59) || 
                        (x==people_left+55 && y==people_up+59) || 
                        (x==people_left+56 && y==people_up+59) || 
                        (x==people_left+57 && y==people_up+59) || 
                        (x==people_left+58 && y==people_up+59) || 
                        (x==people_left+59 && y==people_up+59) || 
                        (x==people_left+60 && y==people_up+59) || 
                        (x==people_left+61 && y==people_up+59) || 
                        (x==people_left+62 && y==people_up+59) || 
                        (x==people_left+63 && y==people_up+59) || 
                        (x==people_left-24 && y==people_up+60) || 
                        (x==people_left-23 && y==people_up+60) || 
                        (x==people_left-22 && y==people_up+60) || 
                        (x==people_left-21 && y==people_up+60) || 
                        (x==people_left-20 && y==people_up+60) || 
                        (x==people_left-19 && y==people_up+60) || 
                        (x==people_left-18 && y==people_up+60) || 
                        (x==people_left-17 && y==people_up+60) || 
                        (x==people_left-16 && y==people_up+60) || 
                        (x==people_left-15 && y==people_up+60) || 
                        (x==people_left-14 && y==people_up+60) || 
                        (x==people_left-13 && y==people_up+60) || 
                        (x==people_left-12 && y==people_up+60) || 
                        (x==people_left-11 && y==people_up+60) || 
                        (x==people_left-10 && y==people_up+60) || 
                        (x==people_left-9 && y==people_up+60) || 
                        (x==people_left-8 && y==people_up+60) || 
                        (x==people_left-7 && y==people_up+60) || 
                        (x==people_left-6 && y==people_up+60) || 
                        (x==people_left-5 && y==people_up+60) || 
                        (x==people_left-4 && y==people_up+60) || 
                        (x==people_left-3 && y==people_up+60) || 
                        (x==people_left-2 && y==people_up+60) || 
                        (x==people_left-1 && y==people_up+60) || 
                        (x==people_left+0 && y==people_up+60) || 
                        (x==people_left+1 && y==people_up+60) || 
                        (x==people_left+2 && y==people_up+60) || 
                        (x==people_left+3 && y==people_up+60) || 
                        (x==people_left+4 && y==people_up+60) || 
                        (x==people_left+5 && y==people_up+60) || 
                        (x==people_left+6 && y==people_up+60) || 
                        (x==people_left+7 && y==people_up+60) || 
                        (x==people_left+8 && y==people_up+60) || 
                        (x==people_left+9 && y==people_up+60) || 
                        (x==people_left+10 && y==people_up+60) || 
                        (x==people_left+11 && y==people_up+60) || 
                        (x==people_left+12 && y==people_up+60) || 
                        (x==people_left+13 && y==people_up+60) || 
                        (x==people_left+14 && y==people_up+60) || 
                        (x==people_left+15 && y==people_up+60) || 
                        (x==people_left+16 && y==people_up+60) || 
                        (x==people_left+17 && y==people_up+60) || 
                        (x==people_left+18 && y==people_up+60) || 
                        (x==people_left+19 && y==people_up+60) || 
                        (x==people_left+20 && y==people_up+60) || 
                        (x==people_left+21 && y==people_up+60) || 
                        (x==people_left+22 && y==people_up+60) || 
                        (x==people_left+23 && y==people_up+60) || 
                        (x==people_left+24 && y==people_up+60) || 
                        (x==people_left+25 && y==people_up+60) || 
                        (x==people_left+26 && y==people_up+60) || 
                        (x==people_left+27 && y==people_up+60) || 
                        (x==people_left+28 && y==people_up+60) || 
                        (x==people_left+29 && y==people_up+60) || 
                        (x==people_left+30 && y==people_up+60) || 
                        (x==people_left+31 && y==people_up+60) || 
                        (x==people_left+32 && y==people_up+60) || 
                        (x==people_left+33 && y==people_up+60) || 
                        (x==people_left+34 && y==people_up+60) || 
                        (x==people_left+35 && y==people_up+60) || 
                        (x==people_left+36 && y==people_up+60) || 
                        (x==people_left+37 && y==people_up+60) || 
                        (x==people_left+38 && y==people_up+60) || 
                        (x==people_left+39 && y==people_up+60) || 
                        (x==people_left+40 && y==people_up+60) || 
                        (x==people_left+41 && y==people_up+60) || 
                        (x==people_left+42 && y==people_up+60) || 
                        (x==people_left+43 && y==people_up+60) || 
                        (x==people_left+44 && y==people_up+60) || 
                        (x==people_left+45 && y==people_up+60) || 
                        (x==people_left+46 && y==people_up+60) || 
                        (x==people_left+47 && y==people_up+60) || 
                        (x==people_left+48 && y==people_up+60) || 
                        (x==people_left+49 && y==people_up+60) || 
                        (x==people_left+50 && y==people_up+60) || 
                        (x==people_left+51 && y==people_up+60) || 
                        (x==people_left+52 && y==people_up+60) || 
                        (x==people_left+53 && y==people_up+60) || 
                        (x==people_left+54 && y==people_up+60) || 
                        (x==people_left+55 && y==people_up+60) || 
                        (x==people_left+56 && y==people_up+60) || 
                        (x==people_left+57 && y==people_up+60) || 
                        (x==people_left+58 && y==people_up+60) || 
                        (x==people_left+59 && y==people_up+60) || 
                        (x==people_left+60 && y==people_up+60) || 
                        (x==people_left+61 && y==people_up+60) || 
                        (x==people_left+62 && y==people_up+60) || 
                        (x==people_left-23 && y==people_up+61) || 
                        (x==people_left-22 && y==people_up+61) || 
                        (x==people_left-21 && y==people_up+61) || 
                        (x==people_left-20 && y==people_up+61) || 
                        (x==people_left-19 && y==people_up+61) || 
                        (x==people_left-18 && y==people_up+61) || 
                        (x==people_left-17 && y==people_up+61) || 
                        (x==people_left-16 && y==people_up+61) || 
                        (x==people_left-15 && y==people_up+61) || 
                        (x==people_left-14 && y==people_up+61) || 
                        (x==people_left-13 && y==people_up+61) || 
                        (x==people_left-12 && y==people_up+61) || 
                        (x==people_left-11 && y==people_up+61) || 
                        (x==people_left-10 && y==people_up+61) || 
                        (x==people_left-9 && y==people_up+61) || 
                        (x==people_left-8 && y==people_up+61) || 
                        (x==people_left-7 && y==people_up+61) || 
                        (x==people_left-6 && y==people_up+61) || 
                        (x==people_left-5 && y==people_up+61) || 
                        (x==people_left-4 && y==people_up+61) || 
                        (x==people_left-3 && y==people_up+61) || 
                        (x==people_left-2 && y==people_up+61) || 
                        (x==people_left-1 && y==people_up+61) || 
                        (x==people_left+0 && y==people_up+61) || 
                        (x==people_left+1 && y==people_up+61) || 
                        (x==people_left+2 && y==people_up+61) || 
                        (x==people_left+3 && y==people_up+61) || 
                        (x==people_left+4 && y==people_up+61) || 
                        (x==people_left+5 && y==people_up+61) || 
                        (x==people_left+6 && y==people_up+61) || 
                        (x==people_left+7 && y==people_up+61) || 
                        (x==people_left+8 && y==people_up+61) || 
                        (x==people_left+9 && y==people_up+61) || 
                        (x==people_left+10 && y==people_up+61) || 
                        (x==people_left+11 && y==people_up+61) || 
                        (x==people_left+12 && y==people_up+61) || 
                        (x==people_left+13 && y==people_up+61) || 
                        (x==people_left+14 && y==people_up+61) || 
                        (x==people_left+15 && y==people_up+61) || 
                        (x==people_left+16 && y==people_up+61) || 
                        (x==people_left+17 && y==people_up+61) || 
                        (x==people_left+18 && y==people_up+61) || 
                        (x==people_left+19 && y==people_up+61) || 
                        (x==people_left+20 && y==people_up+61) || 
                        (x==people_left+21 && y==people_up+61) || 
                        (x==people_left+22 && y==people_up+61) || 
                        (x==people_left+23 && y==people_up+61) || 
                        (x==people_left+24 && y==people_up+61) || 
                        (x==people_left+25 && y==people_up+61) || 
                        (x==people_left+26 && y==people_up+61) || 
                        (x==people_left+27 && y==people_up+61) || 
                        (x==people_left+28 && y==people_up+61) || 
                        (x==people_left+29 && y==people_up+61) || 
                        (x==people_left+30 && y==people_up+61) || 
                        (x==people_left+31 && y==people_up+61) || 
                        (x==people_left+32 && y==people_up+61) || 
                        (x==people_left+33 && y==people_up+61) || 
                        (x==people_left+34 && y==people_up+61) || 
                        (x==people_left+35 && y==people_up+61) || 
                        (x==people_left+36 && y==people_up+61) || 
                        (x==people_left+37 && y==people_up+61) || 
                        (x==people_left+38 && y==people_up+61) || 
                        (x==people_left+39 && y==people_up+61) || 
                        (x==people_left+40 && y==people_up+61) || 
                        (x==people_left+41 && y==people_up+61) || 
                        (x==people_left+42 && y==people_up+61) || 
                        (x==people_left+43 && y==people_up+61) || 
                        (x==people_left+44 && y==people_up+61) || 
                        (x==people_left+45 && y==people_up+61) || 
                        (x==people_left+46 && y==people_up+61) || 
                        (x==people_left+47 && y==people_up+61) || 
                        (x==people_left+48 && y==people_up+61) || 
                        (x==people_left+49 && y==people_up+61) || 
                        (x==people_left+50 && y==people_up+61) || 
                        (x==people_left+51 && y==people_up+61) || 
                        (x==people_left+52 && y==people_up+61) || 
                        (x==people_left+53 && y==people_up+61) || 
                        (x==people_left+54 && y==people_up+61) || 
                        (x==people_left+55 && y==people_up+61) || 
                        (x==people_left+56 && y==people_up+61) || 
                        (x==people_left+57 && y==people_up+61) || 
                        (x==people_left+58 && y==people_up+61) || 
                        (x==people_left+59 && y==people_up+61) || 
                        (x==people_left+60 && y==people_up+61) || 
                        (x==people_left+61 && y==people_up+61) || 
                        (x==people_left-22 && y==people_up+62) || 
                        (x==people_left-21 && y==people_up+62) || 
                        (x==people_left-20 && y==people_up+62) || 
                        (x==people_left-19 && y==people_up+62) || 
                        (x==people_left-18 && y==people_up+62) || 
                        (x==people_left-17 && y==people_up+62) || 
                        (x==people_left-16 && y==people_up+62) || 
                        (x==people_left-15 && y==people_up+62) || 
                        (x==people_left-14 && y==people_up+62) || 
                        (x==people_left-13 && y==people_up+62) || 
                        (x==people_left-12 && y==people_up+62) || 
                        (x==people_left-11 && y==people_up+62) || 
                        (x==people_left-10 && y==people_up+62) || 
                        (x==people_left-9 && y==people_up+62) || 
                        (x==people_left-8 && y==people_up+62) || 
                        (x==people_left-7 && y==people_up+62) || 
                        (x==people_left-6 && y==people_up+62) || 
                        (x==people_left-5 && y==people_up+62) || 
                        (x==people_left-4 && y==people_up+62) || 
                        (x==people_left-3 && y==people_up+62) || 
                        (x==people_left-2 && y==people_up+62) || 
                        (x==people_left-1 && y==people_up+62) || 
                        (x==people_left+0 && y==people_up+62) || 
                        (x==people_left+1 && y==people_up+62) || 
                        (x==people_left+2 && y==people_up+62) || 
                        (x==people_left+3 && y==people_up+62) || 
                        (x==people_left+4 && y==people_up+62) || 
                        (x==people_left+5 && y==people_up+62) || 
                        (x==people_left+6 && y==people_up+62) || 
                        (x==people_left+7 && y==people_up+62) || 
                        (x==people_left+8 && y==people_up+62) || 
                        (x==people_left+9 && y==people_up+62) || 
                        (x==people_left+10 && y==people_up+62) || 
                        (x==people_left+11 && y==people_up+62) || 
                        (x==people_left+12 && y==people_up+62) || 
                        (x==people_left+13 && y==people_up+62) || 
                        (x==people_left+14 && y==people_up+62) || 
                        (x==people_left+15 && y==people_up+62) || 
                        (x==people_left+16 && y==people_up+62) || 
                        (x==people_left+17 && y==people_up+62) || 
                        (x==people_left+18 && y==people_up+62) || 
                        (x==people_left+19 && y==people_up+62) || 
                        (x==people_left+20 && y==people_up+62) || 
                        (x==people_left+21 && y==people_up+62) || 
                        (x==people_left+22 && y==people_up+62) || 
                        (x==people_left+23 && y==people_up+62) || 
                        (x==people_left+24 && y==people_up+62) || 
                        (x==people_left+25 && y==people_up+62) || 
                        (x==people_left+26 && y==people_up+62) || 
                        (x==people_left+27 && y==people_up+62) || 
                        (x==people_left+28 && y==people_up+62) || 
                        (x==people_left+29 && y==people_up+62) || 
                        (x==people_left+30 && y==people_up+62) || 
                        (x==people_left+31 && y==people_up+62) || 
                        (x==people_left+32 && y==people_up+62) || 
                        (x==people_left+33 && y==people_up+62) || 
                        (x==people_left+34 && y==people_up+62) || 
                        (x==people_left+35 && y==people_up+62) || 
                        (x==people_left+36 && y==people_up+62) || 
                        (x==people_left+37 && y==people_up+62) || 
                        (x==people_left+38 && y==people_up+62) || 
                        (x==people_left+39 && y==people_up+62) || 
                        (x==people_left+40 && y==people_up+62) || 
                        (x==people_left+41 && y==people_up+62) || 
                        (x==people_left+42 && y==people_up+62) || 
                        (x==people_left+43 && y==people_up+62) || 
                        (x==people_left+44 && y==people_up+62) || 
                        (x==people_left+45 && y==people_up+62) || 
                        (x==people_left+46 && y==people_up+62) || 
                        (x==people_left+47 && y==people_up+62) || 
                        (x==people_left+48 && y==people_up+62) || 
                        (x==people_left+49 && y==people_up+62) || 
                        (x==people_left+50 && y==people_up+62) || 
                        (x==people_left+51 && y==people_up+62) || 
                        (x==people_left+52 && y==people_up+62) || 
                        (x==people_left+53 && y==people_up+62) || 
                        (x==people_left+54 && y==people_up+62) || 
                        (x==people_left+55 && y==people_up+62) || 
                        (x==people_left+56 && y==people_up+62) || 
                        (x==people_left+57 && y==people_up+62) || 
                        (x==people_left+58 && y==people_up+62) || 
                        (x==people_left+59 && y==people_up+62) || 
                        (x==people_left+60 && y==people_up+62) || 
                        (x==people_left-21 && y==people_up+63) || 
                        (x==people_left-20 && y==people_up+63) || 
                        (x==people_left-19 && y==people_up+63) || 
                        (x==people_left-18 && y==people_up+63) || 
                        (x==people_left-17 && y==people_up+63) || 
                        (x==people_left-16 && y==people_up+63) || 
                        (x==people_left-15 && y==people_up+63) || 
                        (x==people_left-14 && y==people_up+63) || 
                        (x==people_left-13 && y==people_up+63) || 
                        (x==people_left-12 && y==people_up+63) || 
                        (x==people_left-11 && y==people_up+63) || 
                        (x==people_left-10 && y==people_up+63) || 
                        (x==people_left-9 && y==people_up+63) || 
                        (x==people_left-8 && y==people_up+63) || 
                        (x==people_left-7 && y==people_up+63) || 
                        (x==people_left-6 && y==people_up+63) || 
                        (x==people_left-5 && y==people_up+63) || 
                        (x==people_left-4 && y==people_up+63) || 
                        (x==people_left-3 && y==people_up+63) || 
                        (x==people_left-2 && y==people_up+63) || 
                        (x==people_left-1 && y==people_up+63) || 
                        (x==people_left+0 && y==people_up+63) || 
                        (x==people_left+1 && y==people_up+63) || 
                        (x==people_left+2 && y==people_up+63) || 
                        (x==people_left+3 && y==people_up+63) || 
                        (x==people_left+4 && y==people_up+63) || 
                        (x==people_left+5 && y==people_up+63) || 
                        (x==people_left+6 && y==people_up+63) || 
                        (x==people_left+7 && y==people_up+63) || 
                        (x==people_left+8 && y==people_up+63) || 
                        (x==people_left+9 && y==people_up+63) || 
                        (x==people_left+10 && y==people_up+63) || 
                        (x==people_left+11 && y==people_up+63) || 
                        (x==people_left+12 && y==people_up+63) || 
                        (x==people_left+13 && y==people_up+63) || 
                        (x==people_left+14 && y==people_up+63) || 
                        (x==people_left+15 && y==people_up+63) || 
                        (x==people_left+16 && y==people_up+63) || 
                        (x==people_left+17 && y==people_up+63) || 
                        (x==people_left+18 && y==people_up+63) || 
                        (x==people_left+19 && y==people_up+63) || 
                        (x==people_left+20 && y==people_up+63) || 
                        (x==people_left+21 && y==people_up+63) || 
                        (x==people_left+22 && y==people_up+63) || 
                        (x==people_left+23 && y==people_up+63) || 
                        (x==people_left+24 && y==people_up+63) || 
                        (x==people_left+25 && y==people_up+63) || 
                        (x==people_left+26 && y==people_up+63) || 
                        (x==people_left+27 && y==people_up+63) || 
                        (x==people_left+28 && y==people_up+63) || 
                        (x==people_left+29 && y==people_up+63) || 
                        (x==people_left+30 && y==people_up+63) || 
                        (x==people_left+31 && y==people_up+63) || 
                        (x==people_left+32 && y==people_up+63) || 
                        (x==people_left+33 && y==people_up+63) || 
                        (x==people_left+34 && y==people_up+63) || 
                        (x==people_left+35 && y==people_up+63) || 
                        (x==people_left+36 && y==people_up+63) || 
                        (x==people_left+37 && y==people_up+63) || 
                        (x==people_left+38 && y==people_up+63) || 
                        (x==people_left+39 && y==people_up+63) || 
                        (x==people_left+40 && y==people_up+63) || 
                        (x==people_left+41 && y==people_up+63) || 
                        (x==people_left+42 && y==people_up+63) || 
                        (x==people_left+43 && y==people_up+63) || 
                        (x==people_left+44 && y==people_up+63) || 
                        (x==people_left+45 && y==people_up+63) || 
                        (x==people_left+46 && y==people_up+63) || 
                        (x==people_left+47 && y==people_up+63) || 
                        (x==people_left+48 && y==people_up+63) || 
                        (x==people_left+49 && y==people_up+63) || 
                        (x==people_left+50 && y==people_up+63) || 
                        (x==people_left+51 && y==people_up+63) || 
                        (x==people_left+52 && y==people_up+63) || 
                        (x==people_left+53 && y==people_up+63) || 
                        (x==people_left+54 && y==people_up+63) || 
                        (x==people_left+55 && y==people_up+63) || 
                        (x==people_left+56 && y==people_up+63) || 
                        (x==people_left+57 && y==people_up+63) || 
                        (x==people_left+58 && y==people_up+63) || 
                        (x==people_left+59 && y==people_up+63) || 
                        (x==people_left-20 && y==people_up+64) || 
                        (x==people_left-19 && y==people_up+64) || 
                        (x==people_left-18 && y==people_up+64) || 
                        (x==people_left-17 && y==people_up+64) || 
                        (x==people_left-16 && y==people_up+64) || 
                        (x==people_left-15 && y==people_up+64) || 
                        (x==people_left-14 && y==people_up+64) || 
                        (x==people_left-13 && y==people_up+64) || 
                        (x==people_left-12 && y==people_up+64) || 
                        (x==people_left-11 && y==people_up+64) || 
                        (x==people_left-10 && y==people_up+64) || 
                        (x==people_left-9 && y==people_up+64) || 
                        (x==people_left-8 && y==people_up+64) || 
                        (x==people_left-7 && y==people_up+64) || 
                        (x==people_left-6 && y==people_up+64) || 
                        (x==people_left-5 && y==people_up+64) || 
                        (x==people_left-4 && y==people_up+64) || 
                        (x==people_left-3 && y==people_up+64) || 
                        (x==people_left-2 && y==people_up+64) || 
                        (x==people_left-1 && y==people_up+64) || 
                        (x==people_left+0 && y==people_up+64) || 
                        (x==people_left+1 && y==people_up+64) || 
                        (x==people_left+2 && y==people_up+64) || 
                        (x==people_left+3 && y==people_up+64) || 
                        (x==people_left+4 && y==people_up+64) || 
                        (x==people_left+5 && y==people_up+64) || 
                        (x==people_left+6 && y==people_up+64) || 
                        (x==people_left+7 && y==people_up+64) || 
                        (x==people_left+8 && y==people_up+64) || 
                        (x==people_left+9 && y==people_up+64) || 
                        (x==people_left+10 && y==people_up+64) || 
                        (x==people_left+11 && y==people_up+64) || 
                        (x==people_left+12 && y==people_up+64) || 
                        (x==people_left+13 && y==people_up+64) || 
                        (x==people_left+14 && y==people_up+64) || 
                        (x==people_left+15 && y==people_up+64) || 
                        (x==people_left+16 && y==people_up+64) || 
                        (x==people_left+17 && y==people_up+64) || 
                        (x==people_left+18 && y==people_up+64) || 
                        (x==people_left+19 && y==people_up+64) || 
                        (x==people_left+20 && y==people_up+64) || 
                        (x==people_left+21 && y==people_up+64) || 
                        (x==people_left+22 && y==people_up+64) || 
                        (x==people_left+23 && y==people_up+64) || 
                        (x==people_left+24 && y==people_up+64) || 
                        (x==people_left+25 && y==people_up+64) || 
                        (x==people_left+26 && y==people_up+64) || 
                        (x==people_left+27 && y==people_up+64) || 
                        (x==people_left+28 && y==people_up+64) || 
                        (x==people_left+29 && y==people_up+64) || 
                        (x==people_left+30 && y==people_up+64) || 
                        (x==people_left+31 && y==people_up+64) || 
                        (x==people_left+32 && y==people_up+64) || 
                        (x==people_left+33 && y==people_up+64) || 
                        (x==people_left+34 && y==people_up+64) || 
                        (x==people_left+35 && y==people_up+64) || 
                        (x==people_left+36 && y==people_up+64) || 
                        (x==people_left+37 && y==people_up+64) || 
                        (x==people_left+38 && y==people_up+64) || 
                        (x==people_left+39 && y==people_up+64) || 
                        (x==people_left+40 && y==people_up+64) || 
                        (x==people_left+41 && y==people_up+64) || 
                        (x==people_left+42 && y==people_up+64) || 
                        (x==people_left+43 && y==people_up+64) || 
                        (x==people_left+44 && y==people_up+64) || 
                        (x==people_left+45 && y==people_up+64) || 
                        (x==people_left+46 && y==people_up+64) || 
                        (x==people_left+47 && y==people_up+64) || 
                        (x==people_left+48 && y==people_up+64) || 
                        (x==people_left+49 && y==people_up+64) || 
                        (x==people_left+50 && y==people_up+64) || 
                        (x==people_left+51 && y==people_up+64) || 
                        (x==people_left+52 && y==people_up+64) || 
                        (x==people_left+53 && y==people_up+64) || 
                        (x==people_left+54 && y==people_up+64) || 
                        (x==people_left+55 && y==people_up+64) || 
                        (x==people_left+56 && y==people_up+64) || 
                        (x==people_left+57 && y==people_up+64) || 
                        (x==people_left+58 && y==people_up+64) || 
                        (x==people_left-19 && y==people_up+65) || 
                        (x==people_left-18 && y==people_up+65) || 
                        (x==people_left-17 && y==people_up+65) || 
                        (x==people_left-16 && y==people_up+65) || 
                        (x==people_left-15 && y==people_up+65) || 
                        (x==people_left-14 && y==people_up+65) || 
                        (x==people_left-13 && y==people_up+65) || 
                        (x==people_left-12 && y==people_up+65) || 
                        (x==people_left-11 && y==people_up+65) || 
                        (x==people_left-10 && y==people_up+65) || 
                        (x==people_left-9 && y==people_up+65) || 
                        (x==people_left-8 && y==people_up+65) || 
                        (x==people_left-7 && y==people_up+65) || 
                        (x==people_left-6 && y==people_up+65) || 
                        (x==people_left-5 && y==people_up+65) || 
                        (x==people_left-4 && y==people_up+65) || 
                        (x==people_left-3 && y==people_up+65) || 
                        (x==people_left-2 && y==people_up+65) || 
                        (x==people_left-1 && y==people_up+65) || 
                        (x==people_left+0 && y==people_up+65) || 
                        (x==people_left+1 && y==people_up+65) || 
                        (x==people_left+2 && y==people_up+65) || 
                        (x==people_left+3 && y==people_up+65) || 
                        (x==people_left+4 && y==people_up+65) || 
                        (x==people_left+5 && y==people_up+65) || 
                        (x==people_left+6 && y==people_up+65) || 
                        (x==people_left+7 && y==people_up+65) || 
                        (x==people_left+8 && y==people_up+65) || 
                        (x==people_left+9 && y==people_up+65) || 
                        (x==people_left+10 && y==people_up+65) || 
                        (x==people_left+11 && y==people_up+65) || 
                        (x==people_left+12 && y==people_up+65) || 
                        (x==people_left+13 && y==people_up+65) || 
                        (x==people_left+14 && y==people_up+65) || 
                        (x==people_left+15 && y==people_up+65) || 
                        (x==people_left+16 && y==people_up+65) || 
                        (x==people_left+17 && y==people_up+65) || 
                        (x==people_left+18 && y==people_up+65) || 
                        (x==people_left+19 && y==people_up+65) || 
                        (x==people_left+20 && y==people_up+65) || 
                        (x==people_left+21 && y==people_up+65) || 
                        (x==people_left+22 && y==people_up+65) || 
                        (x==people_left+23 && y==people_up+65) || 
                        (x==people_left+24 && y==people_up+65) || 
                        (x==people_left+25 && y==people_up+65) || 
                        (x==people_left+26 && y==people_up+65) || 
                        (x==people_left+27 && y==people_up+65) || 
                        (x==people_left+28 && y==people_up+65) || 
                        (x==people_left+29 && y==people_up+65) || 
                        (x==people_left+30 && y==people_up+65) || 
                        (x==people_left+31 && y==people_up+65) || 
                        (x==people_left+32 && y==people_up+65) || 
                        (x==people_left+33 && y==people_up+65) || 
                        (x==people_left+34 && y==people_up+65) || 
                        (x==people_left+35 && y==people_up+65) || 
                        (x==people_left+36 && y==people_up+65) || 
                        (x==people_left+37 && y==people_up+65) || 
                        (x==people_left+38 && y==people_up+65) || 
                        (x==people_left+39 && y==people_up+65) || 
                        (x==people_left+40 && y==people_up+65) || 
                        (x==people_left+41 && y==people_up+65) || 
                        (x==people_left+42 && y==people_up+65) || 
                        (x==people_left+43 && y==people_up+65) || 
                        (x==people_left+44 && y==people_up+65) || 
                        (x==people_left+45 && y==people_up+65) || 
                        (x==people_left+46 && y==people_up+65) || 
                        (x==people_left+47 && y==people_up+65) || 
                        (x==people_left+48 && y==people_up+65) || 
                        (x==people_left+49 && y==people_up+65) || 
                        (x==people_left+50 && y==people_up+65) || 
                        (x==people_left+51 && y==people_up+65) || 
                        (x==people_left+52 && y==people_up+65) || 
                        (x==people_left+53 && y==people_up+65) || 
                        (x==people_left+54 && y==people_up+65) || 
                        (x==people_left+55 && y==people_up+65) || 
                        (x==people_left+56 && y==people_up+65) || 
                        (x==people_left+57 && y==people_up+65) || 
                        (x==people_left-17 && y==people_up+66) || 
                        (x==people_left-16 && y==people_up+66) || 
                        (x==people_left-15 && y==people_up+66) || 
                        (x==people_left-14 && y==people_up+66) || 
                        (x==people_left-13 && y==people_up+66) || 
                        (x==people_left-12 && y==people_up+66) || 
                        (x==people_left-11 && y==people_up+66) || 
                        (x==people_left-10 && y==people_up+66) || 
                        (x==people_left-9 && y==people_up+66) || 
                        (x==people_left-8 && y==people_up+66) || 
                        (x==people_left-7 && y==people_up+66) || 
                        (x==people_left-6 && y==people_up+66) || 
                        (x==people_left-5 && y==people_up+66) || 
                        (x==people_left-4 && y==people_up+66) || 
                        (x==people_left-3 && y==people_up+66) || 
                        (x==people_left-2 && y==people_up+66) || 
                        (x==people_left-1 && y==people_up+66) || 
                        (x==people_left+0 && y==people_up+66) || 
                        (x==people_left+1 && y==people_up+66) || 
                        (x==people_left+2 && y==people_up+66) || 
                        (x==people_left+3 && y==people_up+66) || 
                        (x==people_left+4 && y==people_up+66) || 
                        (x==people_left+5 && y==people_up+66) || 
                        (x==people_left+6 && y==people_up+66) || 
                        (x==people_left+7 && y==people_up+66) || 
                        (x==people_left+8 && y==people_up+66) || 
                        (x==people_left+9 && y==people_up+66) || 
                        (x==people_left+10 && y==people_up+66) || 
                        (x==people_left+11 && y==people_up+66) || 
                        (x==people_left+12 && y==people_up+66) || 
                        (x==people_left+13 && y==people_up+66) || 
                        (x==people_left+14 && y==people_up+66) || 
                        (x==people_left+15 && y==people_up+66) || 
                        (x==people_left+16 && y==people_up+66) || 
                        (x==people_left+17 && y==people_up+66) || 
                        (x==people_left+18 && y==people_up+66) || 
                        (x==people_left+19 && y==people_up+66) || 
                        (x==people_left+20 && y==people_up+66) || 
                        (x==people_left+21 && y==people_up+66) || 
                        (x==people_left+22 && y==people_up+66) || 
                        (x==people_left+23 && y==people_up+66) || 
                        (x==people_left+24 && y==people_up+66) || 
                        (x==people_left+25 && y==people_up+66) || 
                        (x==people_left+26 && y==people_up+66) || 
                        (x==people_left+27 && y==people_up+66) || 
                        (x==people_left+28 && y==people_up+66) || 
                        (x==people_left+29 && y==people_up+66) || 
                        (x==people_left+30 && y==people_up+66) || 
                        (x==people_left+31 && y==people_up+66) || 
                        (x==people_left+32 && y==people_up+66) || 
                        (x==people_left+33 && y==people_up+66) || 
                        (x==people_left+34 && y==people_up+66) || 
                        (x==people_left+35 && y==people_up+66) || 
                        (x==people_left+36 && y==people_up+66) || 
                        (x==people_left+37 && y==people_up+66) || 
                        (x==people_left+38 && y==people_up+66) || 
                        (x==people_left+39 && y==people_up+66) || 
                        (x==people_left+40 && y==people_up+66) || 
                        (x==people_left+41 && y==people_up+66) || 
                        (x==people_left+42 && y==people_up+66) || 
                        (x==people_left+43 && y==people_up+66) || 
                        (x==people_left+44 && y==people_up+66) || 
                        (x==people_left+45 && y==people_up+66) || 
                        (x==people_left+46 && y==people_up+66) || 
                        (x==people_left+47 && y==people_up+66) || 
                        (x==people_left+48 && y==people_up+66) || 
                        (x==people_left+49 && y==people_up+66) || 
                        (x==people_left+50 && y==people_up+66) || 
                        (x==people_left+51 && y==people_up+66) || 
                        (x==people_left+52 && y==people_up+66) || 
                        (x==people_left+53 && y==people_up+66) || 
                        (x==people_left+54 && y==people_up+66) || 
                        (x==people_left+55 && y==people_up+66) || 
                        (x==people_left-16 && y==people_up+67) || 
                        (x==people_left-15 && y==people_up+67) || 
                        (x==people_left-14 && y==people_up+67) || 
                        (x==people_left-13 && y==people_up+67) || 
                        (x==people_left-12 && y==people_up+67) || 
                        (x==people_left-11 && y==people_up+67) || 
                        (x==people_left-10 && y==people_up+67) || 
                        (x==people_left-9 && y==people_up+67) || 
                        (x==people_left-8 && y==people_up+67) || 
                        (x==people_left-7 && y==people_up+67) || 
                        (x==people_left-6 && y==people_up+67) || 
                        (x==people_left-5 && y==people_up+67) || 
                        (x==people_left-4 && y==people_up+67) || 
                        (x==people_left-3 && y==people_up+67) || 
                        (x==people_left-2 && y==people_up+67) || 
                        (x==people_left-1 && y==people_up+67) || 
                        (x==people_left+0 && y==people_up+67) || 
                        (x==people_left+1 && y==people_up+67) || 
                        (x==people_left+2 && y==people_up+67) || 
                        (x==people_left+3 && y==people_up+67) || 
                        (x==people_left+4 && y==people_up+67) || 
                        (x==people_left+5 && y==people_up+67) || 
                        (x==people_left+6 && y==people_up+67) || 
                        (x==people_left+7 && y==people_up+67) || 
                        (x==people_left+8 && y==people_up+67) || 
                        (x==people_left+9 && y==people_up+67) || 
                        (x==people_left+10 && y==people_up+67) || 
                        (x==people_left+11 && y==people_up+67) || 
                        (x==people_left+12 && y==people_up+67) || 
                        (x==people_left+13 && y==people_up+67) || 
                        (x==people_left+14 && y==people_up+67) || 
                        (x==people_left+15 && y==people_up+67) || 
                        (x==people_left+16 && y==people_up+67) || 
                        (x==people_left+17 && y==people_up+67) || 
                        (x==people_left+18 && y==people_up+67) || 
                        (x==people_left+19 && y==people_up+67) || 
                        (x==people_left+20 && y==people_up+67) || 
                        (x==people_left+21 && y==people_up+67) || 
                        (x==people_left+22 && y==people_up+67) || 
                        (x==people_left+23 && y==people_up+67) || 
                        (x==people_left+24 && y==people_up+67) || 
                        (x==people_left+25 && y==people_up+67) || 
                        (x==people_left+26 && y==people_up+67) || 
                        (x==people_left+27 && y==people_up+67) || 
                        (x==people_left+28 && y==people_up+67) || 
                        (x==people_left+29 && y==people_up+67) || 
                        (x==people_left+30 && y==people_up+67) || 
                        (x==people_left+31 && y==people_up+67) || 
                        (x==people_left+32 && y==people_up+67) || 
                        (x==people_left+33 && y==people_up+67) || 
                        (x==people_left+34 && y==people_up+67) || 
                        (x==people_left+35 && y==people_up+67) || 
                        (x==people_left+36 && y==people_up+67) || 
                        (x==people_left+37 && y==people_up+67) || 
                        (x==people_left+38 && y==people_up+67) || 
                        (x==people_left+39 && y==people_up+67) || 
                        (x==people_left+40 && y==people_up+67) || 
                        (x==people_left+41 && y==people_up+67) || 
                        (x==people_left+42 && y==people_up+67) || 
                        (x==people_left+43 && y==people_up+67) || 
                        (x==people_left+44 && y==people_up+67) || 
                        (x==people_left+45 && y==people_up+67) || 
                        (x==people_left+46 && y==people_up+67) || 
                        (x==people_left+47 && y==people_up+67) || 
                        (x==people_left+48 && y==people_up+67) || 
                        (x==people_left+49 && y==people_up+67) || 
                        (x==people_left+50 && y==people_up+67) || 
                        (x==people_left+51 && y==people_up+67) || 
                        (x==people_left+52 && y==people_up+67) || 
                        (x==people_left+53 && y==people_up+67) || 
                        (x==people_left+54 && y==people_up+67) || 
                        (x==people_left-15 && y==people_up+68) || 
                        (x==people_left-14 && y==people_up+68) || 
                        (x==people_left-13 && y==people_up+68) || 
                        (x==people_left-12 && y==people_up+68) || 
                        (x==people_left-11 && y==people_up+68) || 
                        (x==people_left-10 && y==people_up+68) || 
                        (x==people_left-9 && y==people_up+68) || 
                        (x==people_left-8 && y==people_up+68) || 
                        (x==people_left-7 && y==people_up+68) || 
                        (x==people_left-6 && y==people_up+68) || 
                        (x==people_left-5 && y==people_up+68) || 
                        (x==people_left-4 && y==people_up+68) || 
                        (x==people_left-3 && y==people_up+68) || 
                        (x==people_left-2 && y==people_up+68) || 
                        (x==people_left-1 && y==people_up+68) || 
                        (x==people_left+0 && y==people_up+68) || 
                        (x==people_left+1 && y==people_up+68) || 
                        (x==people_left+2 && y==people_up+68) || 
                        (x==people_left+3 && y==people_up+68) || 
                        (x==people_left+4 && y==people_up+68) || 
                        (x==people_left+5 && y==people_up+68) || 
                        (x==people_left+6 && y==people_up+68) || 
                        (x==people_left+7 && y==people_up+68) || 
                        (x==people_left+8 && y==people_up+68) || 
                        (x==people_left+9 && y==people_up+68) || 
                        (x==people_left+10 && y==people_up+68) || 
                        (x==people_left+11 && y==people_up+68) || 
                        (x==people_left+12 && y==people_up+68) || 
                        (x==people_left+13 && y==people_up+68) || 
                        (x==people_left+14 && y==people_up+68) || 
                        (x==people_left+15 && y==people_up+68) || 
                        (x==people_left+16 && y==people_up+68) || 
                        (x==people_left+17 && y==people_up+68) || 
                        (x==people_left+18 && y==people_up+68) || 
                        (x==people_left+19 && y==people_up+68) || 
                        (x==people_left+20 && y==people_up+68) || 
                        (x==people_left+21 && y==people_up+68) || 
                        (x==people_left+22 && y==people_up+68) || 
                        (x==people_left+23 && y==people_up+68) || 
                        (x==people_left+24 && y==people_up+68) || 
                        (x==people_left+25 && y==people_up+68) || 
                        (x==people_left+26 && y==people_up+68) || 
                        (x==people_left+27 && y==people_up+68) || 
                        (x==people_left+28 && y==people_up+68) || 
                        (x==people_left+29 && y==people_up+68) || 
                        (x==people_left+30 && y==people_up+68) || 
                        (x==people_left+31 && y==people_up+68) || 
                        (x==people_left+32 && y==people_up+68) || 
                        (x==people_left+33 && y==people_up+68) || 
                        (x==people_left+34 && y==people_up+68) || 
                        (x==people_left+35 && y==people_up+68) || 
                        (x==people_left+36 && y==people_up+68) || 
                        (x==people_left+37 && y==people_up+68) || 
                        (x==people_left+38 && y==people_up+68) || 
                        (x==people_left+39 && y==people_up+68) || 
                        (x==people_left+40 && y==people_up+68) || 
                        (x==people_left+41 && y==people_up+68) || 
                        (x==people_left+42 && y==people_up+68) || 
                        (x==people_left+43 && y==people_up+68) || 
                        (x==people_left+44 && y==people_up+68) || 
                        (x==people_left+45 && y==people_up+68) || 
                        (x==people_left+46 && y==people_up+68) || 
                        (x==people_left+47 && y==people_up+68) || 
                        (x==people_left+48 && y==people_up+68) || 
                        (x==people_left+49 && y==people_up+68) || 
                        (x==people_left+50 && y==people_up+68) || 
                        (x==people_left+51 && y==people_up+68) || 
                        (x==people_left+52 && y==people_up+68) || 
                        (x==people_left+53 && y==people_up+68) || 
                        (x==people_left-13 && y==people_up+69) || 
                        (x==people_left-12 && y==people_up+69) || 
                        (x==people_left-11 && y==people_up+69) || 
                        (x==people_left-10 && y==people_up+69) || 
                        (x==people_left-9 && y==people_up+69) || 
                        (x==people_left-8 && y==people_up+69) || 
                        (x==people_left-7 && y==people_up+69) || 
                        (x==people_left-6 && y==people_up+69) || 
                        (x==people_left-5 && y==people_up+69) || 
                        (x==people_left-4 && y==people_up+69) || 
                        (x==people_left-3 && y==people_up+69) || 
                        (x==people_left-2 && y==people_up+69) || 
                        (x==people_left-1 && y==people_up+69) || 
                        (x==people_left+0 && y==people_up+69) || 
                        (x==people_left+1 && y==people_up+69) || 
                        (x==people_left+2 && y==people_up+69) || 
                        (x==people_left+3 && y==people_up+69) || 
                        (x==people_left+4 && y==people_up+69) || 
                        (x==people_left+5 && y==people_up+69) || 
                        (x==people_left+6 && y==people_up+69) || 
                        (x==people_left+7 && y==people_up+69) || 
                        (x==people_left+8 && y==people_up+69) || 
                        (x==people_left+9 && y==people_up+69) || 
                        (x==people_left+10 && y==people_up+69) || 
                        (x==people_left+11 && y==people_up+69) || 
                        (x==people_left+12 && y==people_up+69) || 
                        (x==people_left+13 && y==people_up+69) || 
                        (x==people_left+14 && y==people_up+69) || 
                        (x==people_left+15 && y==people_up+69) || 
                        (x==people_left+16 && y==people_up+69) || 
                        (x==people_left+17 && y==people_up+69) || 
                        (x==people_left+18 && y==people_up+69) || 
                        (x==people_left+19 && y==people_up+69) || 
                        (x==people_left+20 && y==people_up+69) || 
                        (x==people_left+21 && y==people_up+69) || 
                        (x==people_left+22 && y==people_up+69) || 
                        (x==people_left+23 && y==people_up+69) || 
                        (x==people_left+24 && y==people_up+69) || 
                        (x==people_left+25 && y==people_up+69) || 
                        (x==people_left+26 && y==people_up+69) || 
                        (x==people_left+27 && y==people_up+69) || 
                        (x==people_left+28 && y==people_up+69) || 
                        (x==people_left+29 && y==people_up+69) || 
                        (x==people_left+30 && y==people_up+69) || 
                        (x==people_left+31 && y==people_up+69) || 
                        (x==people_left+32 && y==people_up+69) || 
                        (x==people_left+33 && y==people_up+69) || 
                        (x==people_left+34 && y==people_up+69) || 
                        (x==people_left+35 && y==people_up+69) || 
                        (x==people_left+36 && y==people_up+69) || 
                        (x==people_left+37 && y==people_up+69) || 
                        (x==people_left+38 && y==people_up+69) || 
                        (x==people_left+39 && y==people_up+69) || 
                        (x==people_left+40 && y==people_up+69) || 
                        (x==people_left+41 && y==people_up+69) || 
                        (x==people_left+42 && y==people_up+69) || 
                        (x==people_left+43 && y==people_up+69) || 
                        (x==people_left+44 && y==people_up+69) || 
                        (x==people_left+45 && y==people_up+69) || 
                        (x==people_left+46 && y==people_up+69) || 
                        (x==people_left+47 && y==people_up+69) || 
                        (x==people_left+48 && y==people_up+69) || 
                        (x==people_left+49 && y==people_up+69) || 
                        (x==people_left+50 && y==people_up+69) || 
                        (x==people_left+51 && y==people_up+69) || 
                        (x==people_left-12 && y==people_up+70) || 
                        (x==people_left-11 && y==people_up+70) || 
                        (x==people_left-10 && y==people_up+70) || 
                        (x==people_left-9 && y==people_up+70) || 
                        (x==people_left-8 && y==people_up+70) || 
                        (x==people_left-7 && y==people_up+70) || 
                        (x==people_left-6 && y==people_up+70) || 
                        (x==people_left-5 && y==people_up+70) || 
                        (x==people_left-4 && y==people_up+70) || 
                        (x==people_left-3 && y==people_up+70) || 
                        (x==people_left-2 && y==people_up+70) || 
                        (x==people_left-1 && y==people_up+70) || 
                        (x==people_left+0 && y==people_up+70) || 
                        (x==people_left+1 && y==people_up+70) || 
                        (x==people_left+2 && y==people_up+70) || 
                        (x==people_left+3 && y==people_up+70) || 
                        (x==people_left+4 && y==people_up+70) || 
                        (x==people_left+5 && y==people_up+70) || 
                        (x==people_left+6 && y==people_up+70) || 
                        (x==people_left+7 && y==people_up+70) || 
                        (x==people_left+8 && y==people_up+70) || 
                        (x==people_left+9 && y==people_up+70) || 
                        (x==people_left+10 && y==people_up+70) || 
                        (x==people_left+11 && y==people_up+70) || 
                        (x==people_left+12 && y==people_up+70) || 
                        (x==people_left+13 && y==people_up+70) || 
                        (x==people_left+14 && y==people_up+70) || 
                        (x==people_left+15 && y==people_up+70) || 
                        (x==people_left+16 && y==people_up+70) || 
                        (x==people_left+17 && y==people_up+70) || 
                        (x==people_left+18 && y==people_up+70) || 
                        (x==people_left+19 && y==people_up+70) || 
                        (x==people_left+20 && y==people_up+70) || 
                        (x==people_left+21 && y==people_up+70) || 
                        (x==people_left+22 && y==people_up+70) || 
                        (x==people_left+23 && y==people_up+70) || 
                        (x==people_left+24 && y==people_up+70) || 
                        (x==people_left+25 && y==people_up+70) || 
                        (x==people_left+26 && y==people_up+70) || 
                        (x==people_left+27 && y==people_up+70) || 
                        (x==people_left+28 && y==people_up+70) || 
                        (x==people_left+29 && y==people_up+70) || 
                        (x==people_left+30 && y==people_up+70) || 
                        (x==people_left+31 && y==people_up+70) || 
                        (x==people_left+32 && y==people_up+70) || 
                        (x==people_left+33 && y==people_up+70) || 
                        (x==people_left+34 && y==people_up+70) || 
                        (x==people_left+35 && y==people_up+70) || 
                        (x==people_left+36 && y==people_up+70) || 
                        (x==people_left+37 && y==people_up+70) || 
                        (x==people_left+38 && y==people_up+70) || 
                        (x==people_left+39 && y==people_up+70) || 
                        (x==people_left+40 && y==people_up+70) || 
                        (x==people_left+41 && y==people_up+70) || 
                        (x==people_left+42 && y==people_up+70) || 
                        (x==people_left+43 && y==people_up+70) || 
                        (x==people_left+44 && y==people_up+70) || 
                        (x==people_left+45 && y==people_up+70) || 
                        (x==people_left+46 && y==people_up+70) || 
                        (x==people_left+47 && y==people_up+70) || 
                        (x==people_left+48 && y==people_up+70) || 
                        (x==people_left+49 && y==people_up+70) || 
                        (x==people_left+50 && y==people_up+70) || 
                        (x==people_left-10 && y==people_up+71) || 
                        (x==people_left-9 && y==people_up+71) || 
                        (x==people_left-8 && y==people_up+71) || 
                        (x==people_left-7 && y==people_up+71) || 
                        (x==people_left-6 && y==people_up+71) || 
                        (x==people_left-5 && y==people_up+71) || 
                        (x==people_left-4 && y==people_up+71) || 
                        (x==people_left-3 && y==people_up+71) || 
                        (x==people_left-2 && y==people_up+71) || 
                        (x==people_left-1 && y==people_up+71) || 
                        (x==people_left+0 && y==people_up+71) || 
                        (x==people_left+1 && y==people_up+71) || 
                        (x==people_left+2 && y==people_up+71) || 
                        (x==people_left+3 && y==people_up+71) || 
                        (x==people_left+4 && y==people_up+71) || 
                        (x==people_left+5 && y==people_up+71) || 
                        (x==people_left+6 && y==people_up+71) || 
                        (x==people_left+7 && y==people_up+71) || 
                        (x==people_left+8 && y==people_up+71) || 
                        (x==people_left+9 && y==people_up+71) || 
                        (x==people_left+10 && y==people_up+71) || 
                        (x==people_left+11 && y==people_up+71) || 
                        (x==people_left+12 && y==people_up+71) || 
                        (x==people_left+13 && y==people_up+71) || 
                        (x==people_left+14 && y==people_up+71) || 
                        (x==people_left+15 && y==people_up+71) || 
                        (x==people_left+16 && y==people_up+71) || 
                        (x==people_left+17 && y==people_up+71) || 
                        (x==people_left+18 && y==people_up+71) || 
                        (x==people_left+19 && y==people_up+71) || 
                        (x==people_left+20 && y==people_up+71) || 
                        (x==people_left+21 && y==people_up+71) || 
                        (x==people_left+22 && y==people_up+71) || 
                        (x==people_left+23 && y==people_up+71) || 
                        (x==people_left+24 && y==people_up+71) || 
                        (x==people_left+25 && y==people_up+71) || 
                        (x==people_left+26 && y==people_up+71) || 
                        (x==people_left+27 && y==people_up+71) || 
                        (x==people_left+28 && y==people_up+71) || 
                        (x==people_left+29 && y==people_up+71) || 
                        (x==people_left+30 && y==people_up+71) || 
                        (x==people_left+31 && y==people_up+71) || 
                        (x==people_left+32 && y==people_up+71) || 
                        (x==people_left+33 && y==people_up+71) || 
                        (x==people_left+34 && y==people_up+71) || 
                        (x==people_left+35 && y==people_up+71) || 
                        (x==people_left+36 && y==people_up+71) || 
                        (x==people_left+37 && y==people_up+71) || 
                        (x==people_left+38 && y==people_up+71) || 
                        (x==people_left+39 && y==people_up+71) || 
                        (x==people_left+40 && y==people_up+71) || 
                        (x==people_left+41 && y==people_up+71) || 
                        (x==people_left+42 && y==people_up+71) || 
                        (x==people_left+43 && y==people_up+71) || 
                        (x==people_left+44 && y==people_up+71) || 
                        (x==people_left+45 && y==people_up+71) || 
                        (x==people_left+46 && y==people_up+71) || 
                        (x==people_left+47 && y==people_up+71) || 
                        (x==people_left+48 && y==people_up+71) || 
                        (x==people_left-8 && y==people_up+72) || 
                        (x==people_left-7 && y==people_up+72) || 
                        (x==people_left-6 && y==people_up+72) || 
                        (x==people_left-5 && y==people_up+72) || 
                        (x==people_left-4 && y==people_up+72) || 
                        (x==people_left-3 && y==people_up+72) || 
                        (x==people_left-2 && y==people_up+72) || 
                        (x==people_left-1 && y==people_up+72) || 
                        (x==people_left+0 && y==people_up+72) || 
                        (x==people_left+1 && y==people_up+72) || 
                        (x==people_left+2 && y==people_up+72) || 
                        (x==people_left+3 && y==people_up+72) || 
                        (x==people_left+4 && y==people_up+72) || 
                        (x==people_left+5 && y==people_up+72) || 
                        (x==people_left+6 && y==people_up+72) || 
                        (x==people_left+7 && y==people_up+72) || 
                        (x==people_left+8 && y==people_up+72) || 
                        (x==people_left+9 && y==people_up+72) || 
                        (x==people_left+10 && y==people_up+72) || 
                        (x==people_left+11 && y==people_up+72) || 
                        (x==people_left+12 && y==people_up+72) || 
                        (x==people_left+13 && y==people_up+72) || 
                        (x==people_left+14 && y==people_up+72) || 
                        (x==people_left+15 && y==people_up+72) || 
                        (x==people_left+16 && y==people_up+72) || 
                        (x==people_left+17 && y==people_up+72) || 
                        (x==people_left+18 && y==people_up+72) || 
                        (x==people_left+19 && y==people_up+72) || 
                        (x==people_left+20 && y==people_up+72) || 
                        (x==people_left+21 && y==people_up+72) || 
                        (x==people_left+22 && y==people_up+72) || 
                        (x==people_left+23 && y==people_up+72) || 
                        (x==people_left+24 && y==people_up+72) || 
                        (x==people_left+25 && y==people_up+72) || 
                        (x==people_left+26 && y==people_up+72) || 
                        (x==people_left+27 && y==people_up+72) || 
                        (x==people_left+28 && y==people_up+72) || 
                        (x==people_left+29 && y==people_up+72) || 
                        (x==people_left+30 && y==people_up+72) || 
                        (x==people_left+31 && y==people_up+72) || 
                        (x==people_left+32 && y==people_up+72) || 
                        (x==people_left+33 && y==people_up+72) || 
                        (x==people_left+34 && y==people_up+72) || 
                        (x==people_left+35 && y==people_up+72) || 
                        (x==people_left+36 && y==people_up+72) || 
                        (x==people_left+37 && y==people_up+72) || 
                        (x==people_left+38 && y==people_up+72) || 
                        (x==people_left+39 && y==people_up+72) || 
                        (x==people_left+40 && y==people_up+72) || 
                        (x==people_left+41 && y==people_up+72) || 
                        (x==people_left+42 && y==people_up+72) || 
                        (x==people_left+43 && y==people_up+72) || 
                        (x==people_left+44 && y==people_up+72) || 
                        (x==people_left+45 && y==people_up+72) || 
                        (x==people_left+46 && y==people_up+72) || 
                        (x==people_left-6 && y==people_up+73) || 
                        (x==people_left-5 && y==people_up+73) || 
                        (x==people_left-4 && y==people_up+73) || 
                        (x==people_left-3 && y==people_up+73) || 
                        (x==people_left-2 && y==people_up+73) || 
                        (x==people_left-1 && y==people_up+73) || 
                        (x==people_left+0 && y==people_up+73) || 
                        (x==people_left+1 && y==people_up+73) || 
                        (x==people_left+2 && y==people_up+73) || 
                        (x==people_left+3 && y==people_up+73) || 
                        (x==people_left+4 && y==people_up+73) || 
                        (x==people_left+5 && y==people_up+73) || 
                        (x==people_left+6 && y==people_up+73) || 
                        (x==people_left+7 && y==people_up+73) || 
                        (x==people_left+8 && y==people_up+73) || 
                        (x==people_left+9 && y==people_up+73) || 
                        (x==people_left+10 && y==people_up+73) || 
                        (x==people_left+11 && y==people_up+73) || 
                        (x==people_left+12 && y==people_up+73) || 
                        (x==people_left+13 && y==people_up+73) || 
                        (x==people_left+14 && y==people_up+73) || 
                        (x==people_left+15 && y==people_up+73) || 
                        (x==people_left+16 && y==people_up+73) || 
                        (x==people_left+17 && y==people_up+73) || 
                        (x==people_left+18 && y==people_up+73) || 
                        (x==people_left+19 && y==people_up+73) || 
                        (x==people_left+20 && y==people_up+73) || 
                        (x==people_left+21 && y==people_up+73) || 
                        (x==people_left+22 && y==people_up+73) || 
                        (x==people_left+23 && y==people_up+73) || 
                        (x==people_left+24 && y==people_up+73) || 
                        (x==people_left+25 && y==people_up+73) || 
                        (x==people_left+26 && y==people_up+73) || 
                        (x==people_left+27 && y==people_up+73) || 
                        (x==people_left+28 && y==people_up+73) || 
                        (x==people_left+29 && y==people_up+73) || 
                        (x==people_left+30 && y==people_up+73) || 
                        (x==people_left+31 && y==people_up+73) || 
                        (x==people_left+32 && y==people_up+73) || 
                        (x==people_left+33 && y==people_up+73) || 
                        (x==people_left+34 && y==people_up+73) || 
                        (x==people_left+35 && y==people_up+73) || 
                        (x==people_left+36 && y==people_up+73) || 
                        (x==people_left+37 && y==people_up+73) || 
                        (x==people_left+38 && y==people_up+73) || 
                        (x==people_left+39 && y==people_up+73) || 
                        (x==people_left+40 && y==people_up+73) || 
                        (x==people_left+41 && y==people_up+73) || 
                        (x==people_left+42 && y==people_up+73) || 
                        (x==people_left+43 && y==people_up+73) || 
                        (x==people_left+44 && y==people_up+73) || 
                        (x==people_left-4 && y==people_up+74) || 
                        (x==people_left-3 && y==people_up+74) || 
                        (x==people_left-2 && y==people_up+74) || 
                        (x==people_left-1 && y==people_up+74) || 
                        (x==people_left+0 && y==people_up+74) || 
                        (x==people_left+1 && y==people_up+74) || 
                        (x==people_left+2 && y==people_up+74) || 
                        (x==people_left+3 && y==people_up+74) || 
                        (x==people_left+4 && y==people_up+74) || 
                        (x==people_left+5 && y==people_up+74) || 
                        (x==people_left+6 && y==people_up+74) || 
                        (x==people_left+7 && y==people_up+74) || 
                        (x==people_left+8 && y==people_up+74) || 
                        (x==people_left+9 && y==people_up+74) || 
                        (x==people_left+10 && y==people_up+74) || 
                        (x==people_left+11 && y==people_up+74) || 
                        (x==people_left+12 && y==people_up+74) || 
                        (x==people_left+13 && y==people_up+74) || 
                        (x==people_left+14 && y==people_up+74) || 
                        (x==people_left+15 && y==people_up+74) || 
                        (x==people_left+16 && y==people_up+74) || 
                        (x==people_left+17 && y==people_up+74) || 
                        (x==people_left+18 && y==people_up+74) || 
                        (x==people_left+19 && y==people_up+74) || 
                        (x==people_left+20 && y==people_up+74) || 
                        (x==people_left+21 && y==people_up+74) || 
                        (x==people_left+22 && y==people_up+74) || 
                        (x==people_left+23 && y==people_up+74) || 
                        (x==people_left+24 && y==people_up+74) || 
                        (x==people_left+25 && y==people_up+74) || 
                        (x==people_left+26 && y==people_up+74) || 
                        (x==people_left+27 && y==people_up+74) || 
                        (x==people_left+28 && y==people_up+74) || 
                        (x==people_left+29 && y==people_up+74) || 
                        (x==people_left+30 && y==people_up+74) || 
                        (x==people_left+31 && y==people_up+74) || 
                        (x==people_left+32 && y==people_up+74) || 
                        (x==people_left+33 && y==people_up+74) || 
                        (x==people_left+34 && y==people_up+74) || 
                        (x==people_left+35 && y==people_up+74) || 
                        (x==people_left+36 && y==people_up+74) || 
                        (x==people_left+37 && y==people_up+74) || 
                        (x==people_left+38 && y==people_up+74) || 
                        (x==people_left+39 && y==people_up+74) || 
                        (x==people_left+40 && y==people_up+74) || 
                        (x==people_left+41 && y==people_up+74) || 
                        (x==people_left+42 && y==people_up+74) || 
                        (x==people_left-1 && y==people_up+75) || 
                        (x==people_left+0 && y==people_up+75) || 
                        (x==people_left+1 && y==people_up+75) || 
                        (x==people_left+2 && y==people_up+75) || 
                        (x==people_left+3 && y==people_up+75) || 
                        (x==people_left+4 && y==people_up+75) || 
                        (x==people_left+5 && y==people_up+75) || 
                        (x==people_left+6 && y==people_up+75) || 
                        (x==people_left+7 && y==people_up+75) || 
                        (x==people_left+8 && y==people_up+75) || 
                        (x==people_left+9 && y==people_up+75) || 
                        (x==people_left+10 && y==people_up+75) || 
                        (x==people_left+11 && y==people_up+75) || 
                        (x==people_left+12 && y==people_up+75) || 
                        (x==people_left+13 && y==people_up+75) || 
                        (x==people_left+14 && y==people_up+75) || 
                        (x==people_left+15 && y==people_up+75) || 
                        (x==people_left+16 && y==people_up+75) || 
                        (x==people_left+17 && y==people_up+75) || 
                        (x==people_left+18 && y==people_up+75) || 
                        (x==people_left+19 && y==people_up+75) || 
                        (x==people_left+20 && y==people_up+75) || 
                        (x==people_left+21 && y==people_up+75) || 
                        (x==people_left+22 && y==people_up+75) || 
                        (x==people_left+23 && y==people_up+75) || 
                        (x==people_left+24 && y==people_up+75) || 
                        (x==people_left+25 && y==people_up+75) || 
                        (x==people_left+26 && y==people_up+75) || 
                        (x==people_left+27 && y==people_up+75) || 
                        (x==people_left+28 && y==people_up+75) || 
                        (x==people_left+29 && y==people_up+75) || 
                        (x==people_left+30 && y==people_up+75) || 
                        (x==people_left+31 && y==people_up+75) || 
                        (x==people_left+32 && y==people_up+75) || 
                        (x==people_left+33 && y==people_up+75) || 
                        (x==people_left+34 && y==people_up+75) || 
                        (x==people_left+35 && y==people_up+75) || 
                        (x==people_left+36 && y==people_up+75) || 
                        (x==people_left+37 && y==people_up+75) || 
                        (x==people_left+38 && y==people_up+75) || 
                        (x==people_left+39 && y==people_up+75) || 
                        (x==people_left+2 && y==people_up+76) || 
                        (x==people_left+3 && y==people_up+76) || 
                        (x==people_left+4 && y==people_up+76) || 
                        (x==people_left+5 && y==people_up+76) || 
                        (x==people_left+6 && y==people_up+76) || 
                        (x==people_left+7 && y==people_up+76) || 
                        (x==people_left+8 && y==people_up+76) || 
                        (x==people_left+9 && y==people_up+76) || 
                        (x==people_left+10 && y==people_up+76) || 
                        (x==people_left+11 && y==people_up+76) || 
                        (x==people_left+12 && y==people_up+76) || 
                        (x==people_left+13 && y==people_up+76) || 
                        (x==people_left+14 && y==people_up+76) || 
                        (x==people_left+15 && y==people_up+76) || 
                        (x==people_left+16 && y==people_up+76) || 
                        (x==people_left+17 && y==people_up+76) || 
                        (x==people_left+18 && y==people_up+76) || 
                        (x==people_left+19 && y==people_up+76) || 
                        (x==people_left+20 && y==people_up+76) || 
                        (x==people_left+21 && y==people_up+76) || 
                        (x==people_left+22 && y==people_up+76) || 
                        (x==people_left+23 && y==people_up+76) || 
                        (x==people_left+24 && y==people_up+76) || 
                        (x==people_left+25 && y==people_up+76) || 
                        (x==people_left+26 && y==people_up+76) || 
                        (x==people_left+27 && y==people_up+76) || 
                        (x==people_left+28 && y==people_up+76) || 
                        (x==people_left+29 && y==people_up+76) || 
                        (x==people_left+30 && y==people_up+76) || 
                        (x==people_left+31 && y==people_up+76) || 
                        (x==people_left+32 && y==people_up+76) || 
                        (x==people_left+33 && y==people_up+76) || 
                        (x==people_left+34 && y==people_up+76) || 
                        (x==people_left+35 && y==people_up+76) || 
                        (x==people_left+36 && y==people_up+76) || 
                        (x==people_left+6 && y==people_up+77) || 
                        (x==people_left+7 && y==people_up+77) || 
                        (x==people_left+8 && y==people_up+77) || 
                        (x==people_left+9 && y==people_up+77) || 
                        (x==people_left+10 && y==people_up+77) || 
                        (x==people_left+11 && y==people_up+77) || 
                        (x==people_left+12 && y==people_up+77) || 
                        (x==people_left+13 && y==people_up+77) || 
                        (x==people_left+14 && y==people_up+77) || 
                        (x==people_left+15 && y==people_up+77) || 
                        (x==people_left+16 && y==people_up+77) || 
                        (x==people_left+17 && y==people_up+77) || 
                        (x==people_left+18 && y==people_up+77) || 
                        (x==people_left+19 && y==people_up+77) || 
                        (x==people_left+20 && y==people_up+77) || 
                        (x==people_left+21 && y==people_up+77) || 
                        (x==people_left+22 && y==people_up+77) || 
                        (x==people_left+23 && y==people_up+77) || 
                        (x==people_left+24 && y==people_up+77) || 
                        (x==people_left+25 && y==people_up+77) || 
                        (x==people_left+26 && y==people_up+77) || 
                        (x==people_left+27 && y==people_up+77) || 
                        (x==people_left+28 && y==people_up+77) || 
                        (x==people_left+29 && y==people_up+77) || 
                        (x==people_left+30 && y==people_up+77) || 
                        (x==people_left+31 && y==people_up+77) || 
                        (x==people_left+32 && y==people_up+77) || 
                        (x==people_left+11 && y==people_up+78) || 
                        (x==people_left+12 && y==people_up+78) || 
                        (x==people_left+13 && y==people_up+78) || 
                        (x==people_left+14 && y==people_up+78) || 
                        (x==people_left+15 && y==people_up+78) || 
                        (x==people_left+16 && y==people_up+78) || 
                        (x==people_left+17 && y==people_up+78) || 
                        (x==people_left+18 && y==people_up+78) || 
                        (x==people_left+19 && y==people_up+78) || 
                        (x==people_left+20 && y==people_up+78) || 
                        (x==people_left+21 && y==people_up+78) || 
                        (x==people_left+22 && y==people_up+78) || 
                        (x==people_left+23 && y==people_up+78) || 
                        (x==people_left+24 && y==people_up+78) || 
                        (x==people_left+25 && y==people_up+78) || 
                        (x==people_left+26 && y==people_up+78) || 
                        (x==people_left+27 && y==people_up+78)) && APPLE_OUT) begin
                    

                    // if(APPLE_OUT && people_left-40<=x && x<=people_left+79 && people_up-40<=y && y<=people_up+79) begin
                        
                        {vgaR, vgaG, vgaB} = 12'h000;
                        // floor
                        if(270<=x && x<=420 && 30<=y && y<=470) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;


                      
                        if(270<=x && x<=420) if(y==30) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==40) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==50) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==60) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==70) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==80) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==90) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==100) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==110) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==120) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==130) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==140) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==150) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==160) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==170) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==180) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==190) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==200) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==210) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==220) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==230) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==240) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==250) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==260) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==270) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==280) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==290) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==300) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==310) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==320) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==330) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==340) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==350) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==360) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==370) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==380) {vgaR, vgaG, vgaB} = 12'h767;

                        if(270<=x && x<=420) if(y==390) {vgaR, vgaG, vgaB} = 12'h767;

                        if(30<=y && y<=30+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(30+10<y && y<=30+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(60<=y && y<=60+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(60+10<y && y<=60+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(90<=y && y<=90+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(90+10<y && y<=90+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(120<=y && y<=120+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(120+10<y && y<=120+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(150<=y && y<=150+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(150+10<y && y<=150+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(180<=y && y<=180+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(180+10<y && y<=180+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(210<=y && y<=210+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(210+10<y && y<=210+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(240<=y && y<=240+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(240+10<y && y<=240+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(270<=y && y<=270+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(270+10<y && y<=270+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(300<=y && y<=300+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(300+10<y && y<=300+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(330<=y && y<=330+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(330+10<y && y<=330+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(360<=y && y<=360+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end
                        if(360+10<y && y<=360+20) begin
                            if(x==280) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==300) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==320) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==340) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==360) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==380) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==400) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==420) {vgaR, vgaG, vgaB} = 12'h767;
                        end

                        if(390<=y && y<=390+10) begin
                            if(x==270) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==290) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==310) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==330) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==350) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==370) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==390) {vgaR, vgaG, vgaB} = 12'h767;
                            if(x==410) {vgaR, vgaG, vgaB} = 12'h767;
                        end


                        // black block
                        if(340<=x && x<=420 && 280<=y && y<=350) {vgaR, vgaG, vgaB} = 12'h000;
                        if(270<=x && x<=340 && 30<=y && y<=120) {vgaR, vgaG, vgaB} = 12'h000;

                        // input SEVEN_SEGMENT field
                        if(370<=x && x<=420 && 85<=y && y<=135) {vgaR, vgaG, vgaB} = 12'hE47;

                        if(x==380 && 95<=y && y<=125) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==410 && 95<=y && y<=125) {vgaR, vgaG, vgaB} = 12'h767;
                        if(380<=x && x<=410 && y==95) {vgaR, vgaG, vgaB} = 12'h767;
                        if(380<=x && x<=410 && y==125){vgaR, vgaG, vgaB} = 12'h767;

                        if(x==390 && 105<=y && y<=115) {vgaR, vgaG, vgaB} = 12'h767;
                        if(x==400 && 105<=y && y<=115) {vgaR, vgaG, vgaB} = 12'h767;
                        if(390<=x && x<=400 && y==105) {vgaR, vgaG, vgaB} = 12'h767;
                        if(390<=x && x<=400 && y==115) {vgaR, vgaG, vgaB} = 12'h767;

                        // wall
                        if(340<=x && x<=420 && 35<=y && y<=85)   {vgaR, vgaG, vgaB} = `WALL_COLOR;
                        // wall
                        if(270<=x && x<=340 && 120<=y && y<=160)   {vgaR, vgaG, vgaB} = `WALL_COLOR;
                        
                        // arrow 6 to 0
                        if(308<=x && x<=332 && 380<=y && y<=420 && arrow_6to0!=12'hFFF) {vgaR, vgaG, vgaB} = arrow_6to0;


                        // people
                        if( people_left+1 < x && x < people_left + 40 - 1 && 
                            people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
                            {vgaR, vgaG, vgaB} = people_pixel;
                        end
                    end
                end
                7: begin

                    {vgaR, vgaG, vgaB} = `WALL_COLOR;

                    // 門框                    
                    if(220<=x && x<= 520 && 100<=y && y<=380) {vgaR, vgaG, vgaB} = 12'h000;
                    
                    // 門把
                    if(230<=x && x<= 235 && 230<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h989;

                    // red
                    if(290<=x && x<= 310 && 290<=y && y<=310) {vgaR, vgaG, vgaB} = 12'hF00;
                    
                    // green
                    if(330<=x && x<= 350 && 290<=y && y<=310) {vgaR, vgaG, vgaB} = 12'h0F0;
                    
                    // white
                    if(370<=x && x<= 390 && 290<=y && y<=310) {vgaR, vgaG, vgaB} = 12'h0FFF;
                    
                    // blue
                    if(410<=x && x<= 430 && 290<=y && y<=310) {vgaR, vgaG, vgaB} = 12'h00F;


                end
                8: begin
                    {vgaR, vgaG, vgaB} = 12'h000;
                    if(240<=x && x<=400 && 40<=y && y<=440) {vgaR, vgaG, vgaB} = big_card_pixel;
                end
            endcase
        end

    end
    /* -------------------------------------------------------------------------- */

endmodule

