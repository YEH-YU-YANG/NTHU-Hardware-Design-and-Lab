`define WALL_COLOR 12'hDCD 
`define FLOOR_COLOR 12'h656
`define DOOR_COLOR 12'h000
`define BLUE_COLOR 12'h548
`define PRISON_COLOR 12'h112

`define F1 9'b0_0000_0101 // left  05 => 5  
`define F2 9'b0_0000_0110 // right 06 => 6  
`define F3 9'b0_0000_0100 // up    04 => 4  
`define F4 9'b0_0000_1100 // down  0C => 12 
`define F5 9'b0_0000_0011 // space 03 => 3 
`define F6 9'b0_0000_1011 // 0B => 11 
`define F9 9'b0_0000_0001 // 01 => 1 

`define LEFT_DIR 0
`define RIGHT_DIR 1
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

    input [9:0] banana1_up,
    input [9:0] banana1_left,

    input [9:0] banana2_up,
    input [9:0] banana2_left,

    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,

    output reg [2:0] stage_state,
    input [2:0] chair_state,

    input fail,
    input success,


    output reg apple,
    output reg key,
    output reg pass,
    output reg [15:0] password,
    output reg cin,

    output reg [3:0] vgaR,
    output reg [3:0] vgaG,
    output reg [3:0] vgaB
);

    wire [11:0] hint_pixel;
    // wire [11:0] carbinet_pixel;
    wire [11:0] key_pixel;
    wire [11:0] chair_pixel;
    wire [11:0] banana1_pixel;
    wire [11:0] banana2_pixel;
    wire [11:0] apple_pixel;
    wire [11:0] people_pixel;
    wire [11:0] people_right_pixel;
    wire [11:0] people_left_pixel;


    wire [11:0] garbage;
    hint_w80h40 p2 (.clka(clk_25MHz), .wea(0), .addra( (x-130)+80*(y-60) ), .dina(garbage), .douta(hint_pixel) );
    // carbinet_w35h35 p3 (.clka(clk_25MHz), .wea(0), .addra( carbinet_addr  ), .dina(garbage), .douta(carbinet_pixel));
    // key_w20h20      p4 (.clka(clk_25MHz), .wea(0), .addra( key_addr       ), .dina(garbage), .douta(key_pixel      ));
    chair_w20h20    p5 (.clka(clk_25MHz), .wea(0), .addra( ((x-chair_left)>>1)+20*((y-chair_up)>>1)  ), .dina(garbage), .douta( chair_pixel ));
    // banana_w30h30   p6 (.clka(clk_25MHz), .wea(0), .addra( banana1_addr   ), .dina(garbage), .douta(banana1_pixel  ));
    // banana_w30h30   p7 (.clka(clk_25MHz), .wea(0), .addra( banana2_addr   ), .dina(garbage), .douta(banana2_pixel  ));
	apple_w20h20    p8 (.clka(clk_25MHz), .wea(0), .addra( (x-380)+20*(y-70)     ), .dina(garbage), .douta(apple_pixel    ));   
    people_right_w40h40 p9  (.clka(clk_25MHz),.wea(0),.addra( (x - people_left) + 40*(y - people_up) ), .dina(garbage), .douta( people_right_pixel ));
    people_left_w40h40  p10 (.clka(clk_25MHz),.wea(0),.addra( (x - people_left) + 40*(y - people_up) ), .dina(garbage), .douta( people_left_pixel ));
    assign people_pixel = (people_dir==`LEFT_DIR) ? people_left_pixel : people_right_pixel;  

    /* ---------------------------- state transition ---------------------------- */
    reg [3:0] next_stage_state;
    always@(posedge clk) begin
        if(rst) begin
            stage_state <= 1;
        end
        else begin
            stage_state <= next_stage_state;
        end
    end

    always@(*) begin
        if(stage_state==0) begin
            if(331<=people_left+19 && people_left<=401 && 10<=people_up+19 && people_up<=11) next_stage_state = 1;
            // else if(apple && key && 250<=people_left+19 && people_left+19<=290 && 10<=people_up+19 && people_up+19<=80 && key_down[`F5]) next_stage_state = 6;
            else if(231<=people_left && people_left<=271 && 10<=people_up+19 && people_up<=61 && key_down[`F5]) next_stage_state = 6;
            else next_stage_state = 0;
        end

        else if(stage_state==1) begin
            if(211<=people_left && people_left<=261 && 401<=people_up && people_up<=421) next_stage_state = 0;
            else if(61<=people_left && people_left<=81 && 311<=people_up && people_up <=381) next_stage_state = 2;
            // else if(111<=people_left && people_left<=191 && 81<=people_up && people_up <=121 && been_ready && key_down[`F5]) next_stage_state = 3;
            else if(130<=people_left+19 && people_left+19<=210 && 250<=people_up+19 && people_up+19 <=290 && been_ready && key_down[`F5]) next_stage_state = 4;
            // else if(key_down[`F5]) next_stage_state = 4;
            else next_stage_state = 1;
        end

        else if(stage_state==2) begin
            if(381<=people_left && people_left<=391 && 306<=people_up && people_up<=346) next_stage_state = 1;
            else if(201<=people_left && people_left<=221 && 221<=people_up && people_up<=261) next_stage_state = 5;
            else next_stage_state = 2;
        end
        

        else if(stage_state==3) begin
            if(130<=people_left+19 && people_left+19<=210 && 100<=people_up+19 && people_up+19 <=140 && been_ready && key_down[`F5]) next_stage_state = 1;
            else next_stage_state = 3;
        end

        else if(stage_state==4) begin
            if(130<=people_left+19 && people_left+19<=210 && 250<=people_up+19 && people_up+19 <=290 && been_ready && key_down[`F5]) next_stage_state = 1;
            else next_stage_state = 4;
        end

        else if(stage_state==5) begin
            if(461<=people_left && people_left<=481 && 281<=people_up && people_up<=346) next_stage_state = 2;
            else next_stage_state = 5;
        end
        else if(stage_state==6) begin
            if(201<=people_left && people_left<=301 && 421<=people_up && people_up<=441) next_stage_state = 0;
            else next_stage_state = 6;
        end

        else begin
            next_stage_state = stage_state;
        end
    end
    /* -------------------------------------------------------------------------- */


    /* ----------------------------------- key ---------------------------------- */
    reg next_key;
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
        if(stage_state==2 && stage_state==chair_state && key_down[`F5] && 
        people_up < chair_up && chair_up<people_up+39 && people_up+39<=chair_up+39 && chair_left<=people_left+19 && people_left+19<=chair_left+39) next_key = 1;
        else next_key = 0;
    end
    /* -------------------------------------------------------------------------- */

    /* ---------------------------------- apple --------------------------------- */
    reg next_apple;
    always@(posedge clk) begin
        if(rst) apple <= 0;
        else if(apple) apple <= 1;
        else apple <= next_apple;
    end

    always@(*) begin
        if(stage_state==5) begin
            if(360<=people_left+19 && people_left+19<=400 && 65<=people_up+19 && people_up+19<=95 && key_down[`F5]) begin
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

    /* -------------------------------- pass -------------------------------- */

    // always@(posedge clk) begin
    //     if(!pass && password[15:12]==4'd5 && password[11:8]==4'd3 && password[7:4]==4'd4 && password[3:0]==4'd6) pass <= 1;
    //     else pass <= 0;
    // end

    reg next_cin;
    always@(posedge clk) begin
        if(rst) cin <= 0;
        else cin <= 0;
    end
    // always@(*) begin
    //     if(!cin && key_down[`F9] && stage_state==6 && 370<=people_left && people_left<=420 && 50<=people_up && people_up<=135) next_cin = 1;
    //     else if(cin && key_down[`F9] && stage_state==6 && 370<=people_left && people_left<=420 && 50<=people_up && people_up<=135) next_cin = 0;
    // end

    // reg [3:0] key_num;
    // always@(posedge clk) begin
    //     if(rst) begin
    //         password <= 0;
    //     end
    //     else if (cin && stage_state==6 && 370<=people_left && people_left<=420 && 50<=people_up && people_up<=135) begin
    //         password <= {password[11:0],key_num};
    //     end
    //     else begin
    //         password <= 0;
    //     end
    // end

    // always@(*) begin
    //     case (last_change)
    //         `F1 : key_num = 4'b0001;
    //         `F2 : key_num = 4'b0010;
    //         `F3 : key_num = 4'b0011;
    //         `F4 : key_num = 4'b0100;
    //         `F5 : key_num = 4'b0101;
    //         `F6 : key_num = 4'b0110;
    //         default : key_num = 4'b0000;
    //     endcase
    // end
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
                    if(220<=x && x<=420 && 380<=y && y<=440) {vgaR, vgaG, vgaB} = 12'h853;
                    if(310<=x && x<=340 && 440<=y && y<=460) {vgaR, vgaG, vgaB} = 12'h853;

                    
                    
                    if(220<=x && x<=520) if(y==10) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==20) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==30) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==40) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==50) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==60) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==70) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==80) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==90) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==100) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==110) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==120) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==130) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==140) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==150) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==160) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==170) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==180) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==190) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==200) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==210) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==220) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==230) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==240) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==250) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==260) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==270) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==280) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==290) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==300) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==310) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==320) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==330) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==340) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==350) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==360) {vgaR, vgaG, vgaB} = 12'h767;

                    if(220<=x && x<=520) if(y==370) {vgaR, vgaG, vgaB} = 12'h767;

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

                    // black block
                    if(320<=x && x<=350 && 10<=y && y<=145)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(420<=x && x<=520 && 10<=y && y<=150)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(420<=x && x<=520 && 350<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(340<=x && x<=420 && 440<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;
                    if(220<=x && x<=310 && 440<=y && y<=460)   {vgaR, vgaG, vgaB} = 12'h000;

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

                    // chair
                    // if(stage_state==chair_state && chair_left<x && x<chair_left+39 && chair_up<=y && y<=chair_up+39 && chair_pixel!=12'h000) {vgaR, vgaG, vgaB} = chair_pixel;
                    if(stage_state==chair_state && chair_left<=x && x<=chair_left+40-1 && chair_up<=y && y<=chair_up+40-1 && chair_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = 12'h000;
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

                    // /* ------------------------------------ 5 ----------------------------------- */
                    // if (150<=x && x<=160) begin
                    //    if(y==70) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    //    if(y==80) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    //    if(y==90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // end 
                    // if(x==150 && 80<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==155 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==160 && 80<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // /* -------------------------------------------------------------------------- */

                    // /* ------------------------------------ 3 ----------------------------------- */
                    // if (165<=x && x<=175) begin
                    //    if(y==70)  {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    //    if(y==90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // end 
                    // if (168<=x && x<=175 && y==80) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
    
                    // if(x==165 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==172 && 80<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==175 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
    
                    // /* -------------------------------------------------------------------------- */

                    // /* ------------------------------------ 4 ----------------------------------- */
                    // if (180<=x && x<=190) begin
                    //    if(y==80) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // end 
                    // if(x==180 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==187 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==190 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // /* -------------------------------------------------------------------------- */

                    // /* ------------------------------------ 6 ----------------------------------- */
                    // if (195<=x && x<=205) begin
                    //    if(y==80) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    //    if(y==90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // end 
                    // if(x==195 && 70<=y && y<=90) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // if(x==205 && 70<=y && y<=80) {vgaR, vgaG, vgaB} = `BLUE_COLOR;
                    // /* -------------------------------------------------------------------------- */



                    if(people_up+39 < 260) begin
                        if( people_left+1 < x && x < people_left + 40 - 1 && 
                            people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
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
                

                    // black block
                    if(220<=x && x<=260 && 10<=y && y<=175) {vgaR, vgaG, vgaB} = 12'h000;
                    if(220<=x && x<=260 && 280<=y && y<=365) {vgaR, vgaG, vgaB} = 12'h000;
                    if(400<=x && x<=410 && 10<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;

                    // carpet
                    // if(260<x && x<=400 && 116<=y && y<=197) {vgaR, vgaG, vgaB} = carpet_pixel;

                    // wall
                    if(260<=x && x<=400 && 15<=y && y<=85) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(220<=x && x<=260 && 170<=y && y<=240) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    if(400<=x && x<=410 && 255<=y && y<=325) {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    
                    // LINE
                    if(260<=x && x<=400 && (y==85 || y==86)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(400<=x && x<=410 && (y==325 || y==326)) {vgaR, vgaG, vgaB} = 12'h545;

                    // carbinet  
                    // if(330<=x && x<=400 && 45<=y && y<115) {vgaR, vgaG, vgaB} = carbinet_pixel;  

                    
                    // key
                    if(!key && 360<=x && x<=380 && 35<=y && y<=55 && key_pixel!=12'h000) {vgaR, vgaG, vgaB} = key_pixel;  

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
                    if(350<=x && x<=500 && 250<=y && y<=365)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                    if(380<=x && x<=470 && 365<=y && y<=420)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                
                    

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
                    if(350<=x && x<=500 && 255<=y && y<=325)  {vgaR, vgaG, vgaB} = `WALL_COLOR;
                    
                    // LINE
                    if(200<=x && x<=250 && (y==120||y==121)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(250<=x && x<=400 && (y==65||y==66))  {vgaR, vgaG, vgaB} = 12'h545;
                    if(300<=x && x<=350 && (y==210||y==211)) {vgaR, vgaG, vgaB} = 12'h545;
                    if(350<=x && x<=500 && (y==325||y==326)) {vgaR, vgaG, vgaB} = 12'h545;

                    // black block 
                    if(200<=x && x<=250 && 10<=y && y<=85) {vgaR, vgaG, vgaB} = 12'h000;
                    if(200<=x && x<=250 && 220<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(250<=x && x<=300 && 250<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(300<=x && x<=380 && 365<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;
                    if(470<=x && x<=500 && 365<=y && y<=420) {vgaR, vgaG, vgaB} = 12'h000;

                    if(300<=x && x<=350 && 95<=y && y<=155) {vgaR, vgaG, vgaB} = 12'h000;
                    if(350<=x && x<=400 && 95<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;
                    if(400<=x && x<=500 && 10<=y && y<=250) {vgaR, vgaG, vgaB} = 12'h000;


                    // banana1
                    if(banana1_left<=x && x<=banana1_left+30-1 && banana1_up<=y && y<=banana1_up+30-1 && banana1_pixel!=12'h000) {vgaR, vgaG, vgaB} = banana1_pixel;

                    // banana2
                    if(banana2_left<=x && x<=banana2_left+30-1 && banana2_up<=y && y<=banana2_up+30-1 && banana2_pixel!=12'h000) {vgaR, vgaG, vgaB} = banana2_pixel;

                    //apple
                    if(!apple && 380<=x && x<=400 && 70<=y && y<=90 && apple_pixel!=12'h000) {vgaR, vgaG, vgaB} = apple_pixel;

                    // people
                    if( people_left+1 < x && x < people_left+39 && people_up<y && y<people_up+39  && people_pixel!=12'h000) begin
                        {vgaR, vgaG, vgaB} = people_pixel;
                    end
                end
                6:  begin
                    {vgaR, vgaG, vgaB} = 12'h000;

                    if(people_left-20<=x && x<=people_left+59 && people_up-20<=y && y<=people_up+59) begin
                        // floor
                        if(220<=x && x<=320 && 30<=y && y<=460) {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                        if(320<=x && x<=420 && 30<=y && y<=280)  {vgaR, vgaG, vgaB} = `FLOOR_COLOR;
                        


                        if(220<=x && x<=420) if(y==30) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==40) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==50) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==60) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==70) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==80) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==90) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==100) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==110) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==120) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==130) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==140) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==150) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==160) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==170) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==180) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==190) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==200) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==210) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==220) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==230) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==240) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==250) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==260) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==270) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==280) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==290) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==300) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==310) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==320) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==330) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==340) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==350) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==360) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==370) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==380) {vgaR, vgaG, vgaB} = 12'h767;

                        if(220<=x && x<=420) if(y==390) {vgaR, vgaG, vgaB} = 12'h767;

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
                        end

                    
                        // black block
                        if(320<=x && x<=420 && 280<=y && y<=400) {vgaR, vgaG, vgaB} = 12'h000;

                        // pass
                        if(370<=x && x<=420 && 85<=y && y<=135) {vgaR, vgaG, vgaB} = 12'hB06;

                        // wall
                        if(220<=x && x<=420 && 35<=y && y<=85)   {vgaR, vgaG, vgaB} = `WALL_COLOR;
                        
                        // people
                        if( people_left+1 < x && x < people_left + 40 - 1 && 
                            people_up   < y && y < people_up+39  && people_pixel!=12'h000) begin
                            {vgaR, vgaG, vgaB} = people_pixel;
                        end

                    end
                    else begin
                        {vgaR, vgaG, vgaB} = 12'h000;
                    end
                end
            endcase
        end

        // if(fail) begin
        // end

        // if(success) begin
        // end
    end
    /* -------------------------------------------------------------------------- */

endmodule
