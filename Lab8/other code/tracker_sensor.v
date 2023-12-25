module tracker_sensor(
    input clk,
    input reset, 
    input left_track, 
    input right_track, 
    input mid_track, 
    output reg [2:0] state
);
    
    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.

    /* -------------------------------- dir,state ------------------------------- */
    
    // state
    parameter car_forward = 2'd0;
    parameter car_stop    = 2'd1;
    parameter car_left    = 2'd2;
    parameter car_right   = 2'd3;
    
    //dir
    parameter dir_straight     = 2'd0;
    parameter dir_stop         = 2'd1;
    parameter dir_left         = 2'd2;
    parameter dir_right        = 2'd3;

    reg [1:0] dir,next_dir; 
    reg [2:0] next_state;
    always@(posedge clk) begin
        if(reset) begin
            state <= car_forward;
            dir <= dir_straight;
        end
        else begin
            state <= next_state;
            dir <= next_dir;
        end
    end
    /* -------------------------------------------------------------------------- */


  
    always@(*) begin
        case({left_track,mid_track,right_track})

            3'b000: begin
                next_dir = dir;
                if(dir==dir_left) begin
                    next_state = car_left;
                    next_dir   = dir_left;
                end
                else if(dir==dir_right) begin
                    next_state = car_right;
                    next_dir   = dir_right;
                end
                else next_state = state;
            end
            
            /* ---------------------------------- right --------------------------------- */
            3'b001: begin
                next_state = car_right;
                next_dir = dir_right;
            end
            3'b011: begin
                next_state = car_forward;
                next_dir = dir_right;
            end
            /* -------------------------------------------------------------------------- */


            /* ---------------------------------- left ---------------------------------- */
            3'b100: begin
               next_state = car_left;
                next_dir = dir_left;
            end
            3'b110: begin
                next_state = car_forward;
                next_dir = dir_left;
            end
            /* -------------------------------------------------------------------------- */



            /* ---------------------------------- 直角轉彎 ---------------------------------- */
            3'b111: begin
                next_dir = dir;
                if(dir==dir_right) begin
                    next_state = car_left;
                    next_dir   = dir_left;
                end
                else if(dir==dir_left) begin
                    next_state = car_right;
                    next_dir   = dir_right;
                end
                else next_state = state;
            end
            /* -------------------------------------------------------------------------- */

            default begin
                if(dir==dir_left) begin
                    next_state = car_left;
                    next_dir = dir_left;
                end
                
                else if(dir==dir_right) begin
                    next_state = car_right;
                    next_dir = dir_right;
                end
                else begin
                    next_state = state;
                    next_dir = dir;
                end
            end
        endcase
    end

endmodule

