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

`define WALL_COLOR   12'hDCD 
`define FLOOR_COLOR  12'h656
`define DOOR_COLOR   12'h000
`define BLUE_COLOR   12'h548
`define PRISON_COLOR 12'h112
`define TP_COLOR 12'h545
`define PASSWORD_COLOR 12'h437

`define F1  9'b0_0000_0101 // LEFT_DIR  05 => 5  
`define F2  9'b0_0000_0110 // RIGHT_DIR 06 => 6  
`define F3  9'b0_0000_0100 // UP_DIR    04 => 4  
`define F4  9'b0_0000_1100 // DOWN_DIR  0C => 12 
`define F5  9'b0_0000_0011 // space 03 => 3 
`define F6  9'b0_0000_1011 // 0B => 11 
`define F9  9'b0_0000_0001 // 01 => 1 
`define F10 9'b0_0000_1001 // 09 => 9

`define KEY_W 9'b0_0001_1101  // 1D ->
`define KEY_A 9'b0_0001_1100  // 1C ->
`define KEY_S 9'b0_0001_1011  // 1B ->
`define KEY_D 9'b0_0010_0011  // 23 ->

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

module people_top_control(
    input clk,
    input rst,
    
    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,

    input [9:0] x,
    input [9:0] y,

    input [3:0] stage_state,
    input [2:0] chair_state,

    input [9:0] chair_up,
    input [9:0] chair_left,
    
    input FAIL,
    input SUCCESS,
    input CIN,
    input TP,

    output reg [9:0] people_left,
    output reg [9:0] people_up,
    output reg dir
);


    reg [9:0] next_people_left;
    reg [9:0] next_people_up;

    /* -------------------------------------------------------------------------- */
    /*                                  movement                                  */
    /* -------------------------------------------------------------------------- */
    reg next_dir;
 
    reg stage0_IL;
    reg stage1_IL;
    reg stage2_IL;
    reg stage3_IL;
    reg stage4_IL;
    reg stage5_IL;
    reg stage6_IL;
    reg stage7_IL;
    reg stage8_IL;

    always@(posedge clk) begin
        if(rst) begin
            people_left <= 320;
            people_up <= 240;
            dir <= `LEFT_DIR;
            
            stage0_IL <= 1;
            stage1_IL <= 1;
            stage2_IL <= 1;
            stage3_IL <= 1;
            stage4_IL <= 1;
            stage5_IL <= 1;
            stage6_IL <= 1;
            stage7_IL <= 1;
            stage8_IL <= 1;
        end
        else begin
            
            if(stage_state==0 && stage0_IL) begin
                // tp
                if(TP) begin
                    people_left <= 320;
                    people_up <= 220;
                end
                // 1 -> 0
                else if( 211<=people_left && people_left<=261 && 
                         401<=people_up && people_up<=421) begin
                    people_left <= 360;
                    people_up <= 70;
                end

                // 6-> 0
                else if( 270<=people_left && people_left<=301 && 
                         421<=people_up && people_up<=441) begin
                    people_left <= 250;
                    people_up <= 60;
                end

                // 7-> 0
                else if( 310<=people_left+19 && people_left+19<=340 && 
                         340<=people_up+19 && people_up+19<=370) begin
                    people_left <= next_people_left;
                    people_up <= next_people_up;
                end

                dir <= next_dir;
                stage0_IL <= 0;
            end
            
            else if(stage_state==1 && stage1_IL) begin
                // tp
                if(TP) begin
                    people_left <= 140;
                    people_up <= 300;    
                end
                // 0 -> 1
                else if(331<=people_left+19 && people_left<=401 && 10<=people_up && people_up<=40) begin
                    people_left <= 230;
                    people_up <= 400;    
                end
                
                // 2 -> 1
                
                else if(381<=people_left && people_left<=391 && 306<=people_up && people_up<=346) begin
                    people_left <= 90;
                    people_up <= 350;
                end
                
                // 3 -> 1
                else if(130<=people_left+19 && people_left+19<=210 && 100<=people_up+19 && people_up+19 <=140)  begin
                    people_left <= next_people_left;
                    people_up <= next_people_up;
                end 

                // 4 -> 1
                else if(130<=people_left+19 && people_left+19<=210 && 250<=people_up+19 && people_up+19 <=290)  begin
                    people_left <= next_people_left;
                    people_up <= next_people_up;    
                end 
                else if(220<=people_left+19 && people_left+19<=320 && 440<=people_up+19 && people_up+19<=460) begin
                    people_left <= 250;
                    people_up <= 90;
                end
                
                dir <= next_dir;
                stage1_IL <= 0;
            end

            else if(stage_state==2 && stage2_IL) begin
                if(TP) begin
                    people_left <= 320;
                    people_up <= 240;
                end
                // 1 -> 2
                else if(61<=people_left && people_left<=81 && 311<=people_up && people_up <=381) begin
                    people_left <= 370;
                    people_up <= 300;
                end

                // 5 -> 2
                else if(485<=people_left && people_left<=500 && 255<=people_up && people_up<=365) begin
                    people_left <= 240;
                    people_up <= 230;
                end
                
                dir <= next_dir;
                stage2_IL <= 0;
            end

            else if(stage_state==3 && stage3_IL) begin
                // 1 -> 3
                people_left <= next_people_left;
                people_up <= next_people_up;
                dir <= next_dir;
                stage3_IL <= 0;
            end

            else if(stage_state==4 && stage4_IL) begin
                // 1 -> 4 
                people_left <= next_people_left;
                people_up <= next_people_up;
                dir <= next_dir;
                stage4_IL <= 0;
            end
            
            else if(stage_state==5 && stage5_IL) begin
                if(TP) begin
                    people_left <= 425;
                    people_up <= 325;
                end
                // 2 -> 5 
                else if(201<=people_left && people_left<=221 && 221<=people_up && people_up<=261) begin
                    people_left <= 440;
                    people_up <= 325;
                end
                dir <= next_dir;
                stage5_IL <= 0;
            end

            else if(stage_state==6 && stage6_IL) begin
                if(TP) begin
                    people_left <= 300;
                    people_up <= 360;   
                end
                // 0 -> 6 
                else begin
                    people_left <= 300;
                    people_up <= 360;
                end           
                dir <= next_dir;
                stage6_IL <= 0;
            end
            else if(stage_state==7 && stage7_IL) begin
                // 0 -> 7 
                people_left <= next_people_left;
                people_up <= next_people_up;
                dir <= next_dir;
                stage7_IL <= 0;
            end
            else if(stage_state==8 && stage8_IL) begin
                // 5 -> 8 
                people_left <= next_people_left;
                people_up <= next_people_up;
                dir <= next_dir;
                stage8_IL <= 0;
            end

            else begin
                people_left <= next_people_left;
                people_up <= next_people_up;
                dir <= next_dir;
            end

            if(stage_state!=0) stage0_IL <= 1;
            if(stage_state!=1) stage1_IL <= 1;
            if(stage_state!=2) stage2_IL <= 1;
            if(stage_state!=3) stage3_IL <= 1;
            if(stage_state!=4) stage4_IL <= 1;
            if(stage_state!=5) stage5_IL <= 1;
            if(stage_state!=6) stage6_IL <= 1;
            if(stage_state!=7) stage7_IL <= 1;
            if(stage_state!=8) stage8_IL <= 1;
        end
    end

    always@(*) begin
        if(CIN || TP ||  FAIL || SUCCESS || stage_state==3 || stage_state==4 || stage_state==7 || stage_state==8) begin
            next_people_left = people_left;
            next_people_up = people_up;
            next_dir = dir;
        end
        else if(been_ready && key_down[last_change] == 1'b1) begin

            next_people_left = people_left;
            next_people_up = people_up;
            next_dir = dir;

            // 往上
            if(key_down[`F3]) begin
                next_people_up = people_up-2;
                next_dir = dir;
            end

            // 往下
            if(key_down[`F4]) begin
                next_people_up = people_up+2;
                next_dir = dir;
            end

            // 往左
            if(key_down[`F1]) begin
                next_people_left = people_left-2;
                next_people_up = people_up;
                next_dir = `LEFT_DIR;
            end

            // 往右
            if(key_down[`F2]) begin
                next_people_left = people_left+2;  
                next_people_up = people_up;
                next_dir = `RIGHT_DIR;
            end

            if(stage_state==2 && chair_state==2 && chair_up+20<=115) begin
                if(key_down[`F5] && people_up+10 < chair_up+39 && people_up+39>=chair_up+39 && chair_left<=people_left+19 && people_left+19<=chair_left+39) next_people_up = people_up-40;
            end
        end
        else begin
            next_people_left = people_left;
            next_people_up = people_up;
            next_dir = dir;
        end
    end

endmodule