
`define LEFT_DIR 0
`define RIGHT_DIR 1
`define UP_DIR 2
`define DOWN_DIR 3




module ghost1_top_control(
    input clk,
    input rst,
    input [3:0] stage_state,

    input [9:0] people_up,
    input [9:0] people_left,

    input [9:0] chair_up,
    input [9:0] chair_left,
    input [2:0] chair_state,
    output reg [9:0] ghost_up,
    output reg [9:0] ghost_left,

    output reg fail,
    output reg [1:0] dir
);
    
    reg [23:0] count; // 24bit counter -> 1e7
    reg trigger;

    reg [9:0] next_ghost_up;
    reg [9:0]  next_ghost_left;

    reg [1:0] next_dir;

    always@(posedge clk) begin
        if(rst) begin
            ghost_left <= 250;
            ghost_up <= 330;
            dir <= `RIGHT_DIR;
        end
        else begin 
            ghost_left <= next_ghost_left;
            ghost_up <= next_ghost_up;
            dir <= next_dir;
        end

    end


    always@(*) begin
        if(dir==`RIGHT_DIR && ghost_left>=370 ) next_dir=`UP_DIR;
        else if(dir==`UP_DIR && ghost_up<=165) next_dir=`DOWN_DIR;
        else if(dir==`DOWN_DIR && ghost_up>=330) next_dir=`LEFT_DIR;
        else if(dir==`LEFT_DIR && ghost_left<=250) next_dir=`RIGHT_DIR;

        else if(chair_state==5 && dir==`RIGHT_DIR && ghost_left+30>=chair_left && ghost_left<=chair_left && chair_up<=ghost_up+15 && ghost_up+15<=chair_up+40) next_dir=`LEFT_DIR;
        else if(chair_state==5 && dir==`DOWN_DIR && ghost_up+30 >=chair_up && ghost_up<=chair_up && chair_left<=ghost_left+15 && ghost_left+15<=chair_left+40) next_dir=`UP_DIR;

        else next_dir = dir;
    end



    always@(*) begin
        next_ghost_up = ghost_up;
        next_ghost_left = ghost_left;
        if(trigger) begin
            case(dir)
                `LEFT_DIR: next_ghost_left = ghost_left - 7;
                `RIGHT_DIR:next_ghost_left = ghost_left + 7;
                `UP_DIR:   next_ghost_up = ghost_up - 7;
                `DOWN_DIR: next_ghost_up = ghost_up + 7;
            endcase
        end
    end


    always @(posedge clk) begin
        if (count == 24'd1000_0000 - 1) begin
            count <= 0;
            trigger <= 1;
        end else begin
            count <= count + 1;
            trigger <= 0;
        end
    end

    /* ---------------------------------- fail ---------------------------------- */
    reg next_fail;
    always@(posedge clk) begin
        if(rst) fail <= 0;
        else fail <= next_fail;
    end
    
    always@(*) begin
        if(stage_state==5 || stage_state==8) begin
            if(ghost_up<=people_up+19 && people_up+19<=ghost_up+29 && dir==`LEFT_DIR && ghost_left<people_left+39 && ghost_left+29>people_left+39) begin
                next_fail = 1;
            end
            else if(ghost_up<=people_up+19 && people_up+19<=ghost_up+29 && dir==`RIGHT_DIR && ghost_left+29>people_left && ghost_left<people_left) begin
                next_fail = 1;
            end
            else if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`UP_DIR && ghost_up<people_up+39 && ghost_up+29>people_up+39) begin
                next_fail = 1;
            end
            else if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`DOWN_DIR && ghost_up+29>people_up && ghost_up<people_up) begin
                next_fail = 1;
            end
            else begin
                next_fail = fail;
            end
        end
        else begin
            next_fail = fail;
        end
    end
    /* -------------------------------------------------------------------------- */

endmodule

module ghost2_top_control(
    input clk,
    input rst,
    input [3:0] stage_state,

    input [9:0] people_up,
    input [9:0] people_left,
    
    output reg [9:0] ghost_up,
    output reg [9:0] ghost_left,

    output reg fail
);

    reg [23:0] count; // 24bit counter -> 1e7
    reg trigger;

    reg [9:0] next_ghost_up;
    reg [9:0]  next_ghost_left;
    reg [1:0] dir, next_dir;

    always@(posedge clk) begin
        if(rst) begin
            ghost_left <= 260;
            ghost_up <= 75;
            dir <= `DOWN_DIR;
        end
        else begin
            ghost_left <= next_ghost_left;
            ghost_up <= next_ghost_up;
            dir <= next_dir;
        end
    end


    always@(*) begin
        if(dir==`DOWN_DIR && ghost_up>=220) next_dir=`UP_DIR;
        else if(dir==`UP_DIR && ghost_up<=65) next_dir=`DOWN_DIR;
        else next_dir = dir;
    end


    always@(*) begin
        next_ghost_left = ghost_left;
        if(trigger) begin
            case(dir)
                `UP_DIR:   next_ghost_up = ghost_up - 3;
                `DOWN_DIR: next_ghost_up = ghost_up + 3;
            endcase    
        end
        else begin
            next_ghost_up = ghost_up ;
        end  
    end

    always @(posedge clk) begin
        if (count == 24'd1000_0000 - 1) begin
            count <= 0;
            trigger <= 1;
        end else begin
            count <= count + 1;
            trigger <= 0;
        end
    end
    /* ---------------------------------- fail ---------------------------------- */
    reg next_fail;
    always@(posedge clk) begin
        if(rst) fail <= 0;
        else fail <= next_fail;
    end
    
    always@(*) begin
        if(stage_state==5) begin
            if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`UP_DIR && ghost_up<people_up+39 && ghost_up+29>people_up+39) begin
                next_fail = 1;
            end
            else if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`DOWN_DIR && ghost_up+29>people_up && ghost_up<people_up) begin
                next_fail = 1;
            end
            else begin
                next_fail = fail;
            end
        end
        else begin
            next_fail = fail;
        end
    end
    /* -------------------------------------------------------------------------- */

endmodule