`define RIGHT 0
`define LEFT 1
`define UP 0
`define DOWN 1


module banana1_top_control(
    input clk,
    input rst,
    input [2:0] stage_state,

    input [9:0] people_up,
    input [9:0] people_left,

    output reg [9:0] banana_up,
    output reg [9:0] banana_left,

    output reg fail
);

    reg [9:0] next_banana_up;
    reg [9:0]  next_banana_left;
    reg dir, next_dir;

    reg IL;

    always@(posedge clk) begin
        if(rst) begin
            banana_left <= 300;
            banana_up <= 335;
            dir <= `RIGHT;
        end
        else if(IL) begin
            banana_left <= 300;
            banana_up <= 335;
            dir <= `RIGHT;
        end
        else begin 
            banana_left <= next_banana_left;
            banana_up <= next_banana_up;
            dir <= next_dir;
        end

        if(rst) IL <= 1;
        else if(stage_state!=5) IL <= 1;
        else IL <= 0;
    end


    always@(*) begin
        if(dir==`RIGHT && banana_left<=400) next_dir=`RIGHT;
        else if(dir==`LEFT && banana_left>=310) next_dir=`LEFT;
        else next_dir = ~dir;
    end



    always@(*) begin
        next_banana_up = banana_up;
        if(stage_state==5) begin
            case(dir)
                `LEFT:  next_banana_left = banana_left - 1;
                `RIGHT: next_banana_left = banana_left + 1;
            endcase
        end
        else begin
            next_banana_left = banana_left;
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
            if(banana_up<=people_up+19 && people_up+19<=banana_up+29 && 
                dir==`LEFT && banana_left+20<people_left+39) begin
                next_fail = 1;
            end
            else if(banana_up<=people_up+19 && people_up+19<=banana_up+29 && 
                dir==`RIGHT && banana_left+30>people_left+20) begin
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

module banana2_top_control(
    input clk,
    input rst,
    input [2:0] stage_state,

    input [9:0] people_up,
    input [9:0] people_left,
    
    output reg [9:0] banana_up,
    output reg [9:0] banana_left,

    output reg fail
);

    reg [9:0] next_banana_up;
    reg [9:0]  next_banana_left;
    reg dir, next_dir;

    reg IL;
    always@(posedge clk) begin
        if(rst) begin
            banana_left <= 260;
            banana_up <= 65;
            dir <= `DOWN;
        end
        else begin
            banana_left <= next_banana_left;
            banana_up <= next_banana_up;
            dir <= next_dir;
        end

        if(rst) IL <= 1;
        else if(stage_state!=5) IL <= 1;
        else IL <= 0;
    end


    always@(*) begin
        if(dir==`DOWN && banana_up<=191) next_dir=`DOWN;
        else if(dir==`UP && banana_up>=75) next_dir=`UP;
        else next_dir = ~dir;
    end


    always@(*) begin
        next_banana_left = banana_left;
        if(stage_state==5) begin
            case(dir)
                `UP:   next_banana_up = banana_up - 1;
                `DOWN: next_banana_up = banana_up + 1;
            endcase    
        end
        else begin
            next_banana_up = banana_up ;
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
            if(banana_left<=people_left+19 && people_left+19<=banana_left+29 && 
                dir==`UP && banana_up<people_up+19) begin
                next_fail = 1;
            end
            else if(banana_left<=people_left+19 && people_left+19<=banana_left+29 && 
                dir==`DOWN && banana_up+29>people_up+20) begin
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