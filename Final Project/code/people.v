`define LEFT_DIR 0
`define RIGHT_DIR 1

`define F1  9'b0_0000_0101 // left  05 => 5  
`define F2  9'b0_0000_0110 // right 06 => 6  
`define F3  9'b0_0000_0100 // up    04 => 4  
`define F4  9'b0_0000_1100 // down  0C => 12 
`define F5  9'b0_0000_0011 // space 03 => 3 
`define F6  9'b0_0000_1011 // 0B => 11 
`define F9  9'b0_0000_0001 // 01 => 1 
`define F10 9'b0_0000_1001 // 09 => 9

module people_top_control(
    input clk,
    input rst,
    
    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,

    input [9:0] x,
    input [9:0] y,

    input [2:0] stage_state,
    input [2:0] chair_state,

    input [9:0] chair_up,
    input [9:0] chair_left,
    
    input FAIL,
    input SUCCESS,
    input CIN,

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

        end
        else begin
            
            if(stage_state==0 && stage0_IL) begin
                // 1 -> 0
                if(211<=people_left && people_left<=261 && 401<=people_up && people_up<=421) begin
                    people_left <= 360;
                    people_up <= 70;
                end

                // 6-> 0
                else if(270<=people_left && people_left<=301 && 421<=people_up && people_up<=441) begin
                    people_left <= 250;
                    people_up <= 80;
                end
                dir <= next_dir;
                stage0_IL <= 0;
            end
            
            else if(stage_state==1 && stage1_IL) begin
                
                // 0 -> 1
                if(331<=people_left+19 && people_left<=401 && 10<=people_up+19 && people_up<=11) begin
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
                // 1 -> 2
                if(61<=people_left && people_left<=81 && 311<=people_up && people_up <=381) begin
                    people_left <= 370;
                    people_up <= 300;
                end

                // 5 -> 2
                else if(461<=people_left && people_left<=481 && 281<=people_up && people_up<=346) begin
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
                // 2 -> 5 
                people_left <= 460;
                people_up <= 325;
            

                dir <= next_dir;
                stage5_IL <= 0;
            end

            else if(stage_state==6 && stage6_IL) begin
                // 0 -> 6 
                people_left <= 300;
                people_up <= 410;
            
                dir <= next_dir;
                stage6_IL <= 0;
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

        end
    end

    always@(*) begin
        if(CIN || FAIL || SUCCESS || stage_state==3 || stage_state==4) begin
            next_people_left = people_left;
            next_people_up = people_up;
            next_dir = dir;
        end
        else if(been_ready && key_down[last_change] == 1'b1) begin

            next_people_left = people_left;
            next_people_up = people_up;
            next_dir = dir;

            if(key_down[`F3]) begin
                next_people_up = people_up-1;
                next_dir = dir;
            end
            if(key_down[`F4]) begin
                next_people_up = people_up+1;
                next_dir = dir;
            end

          
            if(key_down[`F1]) begin
                next_people_left = people_left-1;
                next_people_up = people_up;
                next_dir = `LEFT_DIR;
            end

            if(key_down[`F2]) begin
                next_people_left = people_left+1;  
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


    


 
