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
        // 撞牆反彈
        if(dir==`RIGHT_DIR && ghost_left>=370 ) next_dir=`UP_DIR;
        else if(dir==`UP_DIR && ghost_up<=165) next_dir=`DOWN_DIR;
        else if(dir==`DOWN_DIR && ghost_up>=330) next_dir=`LEFT_DIR;
        else if(dir==`LEFT_DIR && ghost_left<=250) next_dir=`RIGHT_DIR;
        //撞椅子反彈
        else if(chair_state==5 && dir==`RIGHT_DIR && ghost_left+30>=chair_left && ghost_left<=chair_left && chair_up<=ghost_up+15     && ghost_up+15<=chair_up+40) next_dir=`LEFT_DIR;
        else if(chair_state==5 && dir==`DOWN_DIR  && ghost_up+30 >=chair_up    && ghost_up<=chair_up     && chair_left<=ghost_left+15 && ghost_left+15<=chair_left+40) next_dir=`UP_DIR;
        else if(chair_state==5 && dir==`LEFT_DIR  && ghost_left<=chair_left+40 && ghost_left>=chair_left && chair_up<=ghost_up+15     && ghost_up+15<=chair_up+40) next_dir=`RIGHT_DIR;
        else if(chair_state==5 && dir==`UP_DIR    && ghost_up<=chair_up+40     && ghost_up>=chair_up     && chair_left<=ghost_left+15 && ghost_left+15<=chair_left+40) next_dir=`DOWN_DIR;
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