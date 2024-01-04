`define RIGHT 0
`define LEFT 1
`define UP 0
`define DOWN 1


module ghost1_top_control(
    input clk,
    input rst,
    input [2:0] stage_state,

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
    reg dir, next_dir;

    reg IL;

    always@(posedge clk) begin
        if(rst) begin
            ghost_left <= 300;
            ghost_up <= 335;
            dir <= `RIGHT;
        end
        else if(IL) begin
            ghost_left <= 300;
            ghost_up <= 335;
            dir <= `RIGHT;
        end
        else begin 
            ghost_left <= next_ghost_left;
            ghost_up <= next_ghost_up;
            dir <= next_dir;
        end

        if(rst) IL <= 1;
        else if(stage_state!=5) IL <= 1;
        else IL <= 0;
    end


    always@(*) begin
        if(dir==`RIGHT && ghost_left<=400) next_dir=`RIGHT;
        else if(dir==`LEFT && ghost_left>=310) next_dir=`LEFT;
        else next_dir = ~dir;
    end



    always@(*) begin
        next_ghost_up = ghost_up;
        if(trigger && stage_state==5) begin
            case(dir)
                `LEFT:  next_ghost_left = ghost_left - 1;
                `RIGHT: next_ghost_left = ghost_left + 1;
            endcase
        end
        else begin
            next_ghost_left = ghost_left;
        end
    end


    always @(posedge clk) begin
        if(stage_state==5) begin
            if (count == 24'd1000_0000 - 1) begin
                count <= 0;
                trigger <= 1;
            end else begin
                count <= count + 1;
                trigger <= 0;
            end
        end
        else begin
            count <= 0;
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
            if(ghost_up<=people_up+19 && people_up+19<=ghost_up+29 && dir==`LEFT && ghost_left+20<people_left+39) begin
                next_fail = 1;
            end
            else if(ghost_up<=people_up+19 && people_up+19<=ghost_up+29 && dir==`RIGHT && ghost_left+30>people_left+20) begin
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
    input [2:0] stage_state,

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
    reg dir, next_dir;

    reg IL;
    always@(posedge clk) begin
        if(rst) begin
            ghost_left <= 260;
            ghost_up <= 65;
            dir <= `DOWN;
        end
        else begin
            ghost_left <= next_ghost_left;
            ghost_up <= next_ghost_up;
            dir <= next_dir;
        end

        if(rst) IL <= 1;
        else if(stage_state!=5) IL <= 1;
        else IL <= 0;
    end


    always@(*) begin
        if(dir==`DOWN && ghost_up<=191) next_dir=`DOWN;
        else if(dir==`UP && ghost_up>=75) next_dir=`UP;
        else next_dir = ~dir;
    end


    always@(*) begin
        next_ghost_left = ghost_left;
        if(trigger && stage_state==5) begin
            case(dir)
                `UP:   next_ghost_up = ghost_up - 1;
                `DOWN: next_ghost_up = ghost_up + 1;
            endcase    
        end
        else begin
            next_ghost_up = ghost_up ;
        end  
    end

    always @(posedge clk) begin
        if(stage_state==5) begin
            if (count == 24'd1000_0000 - 1) begin
                count <= 0;
                trigger <= 1;
            end else begin
                count <= count + 1;
                trigger <= 0;
            end
        end
        else begin
            count <= 0;
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
            if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`UP && ghost_up<people_up+19) begin
                next_fail = 1;
            end
            else if(ghost_left<=people_left+19 && people_left+19<=ghost_left+29 && dir==`DOWN && ghost_up+29>people_up+20) begin
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