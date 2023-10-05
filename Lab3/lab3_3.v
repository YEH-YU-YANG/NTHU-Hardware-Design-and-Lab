`timescale 1ns / 1ps
module clock_divider(clk,clk_div);
    input clk;
    output clk_div;
    parameter n = 25;
    reg[n-1:0]num;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_3 (
    input clk,
    input rst,
    input en,
    output [15:0] led
);


parameter LOCK = 2'b00;
parameter MOVE_RIGHT = 2'b01;
parameter MOVE_LEFT = 2'b10;

parameter LEFT_BOARDER = 4'd15;
parameter RIGHT_BOARDER = 4'd0;

//directly use three clock in  mudule
wire clk_div24 , clk_div25 , clk_div26;
clock_divider #(24) (.clk(clk), .clk_div(clk_div24));
clock_divider #(25) (.clk(clk), .clk_div(clk_div25));
clock_divider #(26) (.clk(clk), .clk_div(clk_div26));


/* snake_111 */
reg [1:0] snake_111_state , next_snake_111_state;
reg [15:0] snake_111_led , next_snake_111_led;
////////////////////////////////////////////////

/* snake_11 */
reg [1:0] snake_11_state , next_snake_11_state;
reg [15:0] snake_11_led , next_snake_11_led;
////////////////////////////////////////////////


// /* snake_1 */
reg [1:0] snake_1_state , next_snake_1_state;
reg [15:0] snake_1_led , next_snake_1_led;
// ////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*                                                    snake_1                                                     */

reg [1:0] snake_1_lock_dir , next_snake_1_lock_dir;
always@(posedge clk_div24,posedge rst) begin
    if(rst) begin
        snake_1_state <= LOCK;
        snake_1_led <= 16'b1000000000000000;
        snake_1_lock_dir <= MOVE_RIGHT;
    end

    else begin

        if(en) begin
            snake_1_state <= next_snake_1_state;
            snake_1_led <= next_snake_1_led;
            snake_1_lock_dir <= next_snake_1_lock_dir;
        end
    end
end

always@(*) begin
        
    if(en) begin
        case(snake_1_state)
            LOCK:begin
                next_snake_1_state = MOVE_RIGHT;
            end

            MOVE_RIGHT:begin
                next_snake_1_lock_dir = MOVE_RIGHT;

                next_snake_1_state = ((snake_1_led == {1'b1,15'b0}) && ((snake_1_led >> 1) & snake_11_led)) ? LOCK : //左邊是牆,右邊是蛇 -> LOCK
                                     (snake_1_led == {15'b0,1'b1})        ? MOVE_LEFT : // 右邊是牆 -> MOVE_LEFT
                                     ((snake_1_led >> 1) & snake_11_led ) ? MOVE_LEFT : // 右邊是蛇 -> MOVE_LEFT
                                                                            MOVE_RIGHT ;
            end
            MOVE_LEFT:begin
                next_snake_1_lock_dir = MOVE_LEFT;
                next_snake_1_state = ((snake_1_led == {1'b1,15'b0}) && ((snake_1_led >> 1) & snake_11_led)) ? LOCK : //左邊是牆,右邊是蛇 -> LOCK
                                     (snake_1_led == {1'b1,15'b0}) ? MOVE_RIGHT : // 左邊是牆 -> MOVE_RIGHT
                                                                     MOVE_LEFT ;
            end

            default:begin
                next_snake_1_state = LOCK;
            end
        endcase
    end 
    
    else begin
        next_snake_1_state = snake_1_state; 
    end

end


always@(*) begin
    if(en) begin
        /* snake 1 */ 
        next_snake_1_led = (next_snake_1_state == MOVE_RIGHT) ? snake_1_led >> 1 :
                           (next_snake_1_state == MOVE_LEFT)  ? snake_1_led << 1 :
                                                                snake_1_led;
    end
    else begin
        /* snake 1 */ 
        next_snake_1_led = snake_1_led;
    
    end
end
/*                                                    snake_1                                                     */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*                                                    snake_11                                                    */

reg [1:0] snake_11_lock_dir , next_snake_11_lock_dir;
always@(posedge clk_div25,posedge rst) begin
    if(rst) begin
        snake_11_state <= LOCK;
        snake_11_led <= 16'b0000110000000000;
        snake_11_lock_dir <= MOVE_RIGHT;
    end

    else begin
        if(en) begin
            snake_11_state <= next_snake_11_state;
            snake_11_led <= next_snake_11_led;
            snake_11_lock_dir <= next_snake_11_lock_dir;
        end
    end
end

always@(*) begin
    
    if(en) begin
        case(snake_11_state)
            LOCK:begin
                next_snake_11_state = snake_11_lock_dir;
            end

            /* collision with snake_111 */
            MOVE_RIGHT:begin
                next_snake_11_lock_dir = MOVE_RIGHT;
                next_snake_11_state = (((snake_11_led >> 1) & snake_111_led) && ((snake_11_led << 1) & snake_1_led)) ? LOCK :
                                      (snake_11_led == {14'b0,2'b11})       ? MOVE_LEFT :
                                      ((snake_11_led >> 1) & snake_111_led) ? MOVE_LEFT :
                                                                              MOVE_RIGHT ;
            end

            /* collision with snake_1 */
            MOVE_LEFT:begin
                next_snake_11_lock_dir = MOVE_LEFT;
                next_snake_11_state = (((snake_11_led >> 1) & snake_111_led) && ((snake_11_led << 1) & snake_1_led)) ? LOCK :
                                      (snake_11_led == {2'b11,14'b0})     ? MOVE_RIGHT : 
                                      ((snake_11_led << 1) & snake_1_led) ? MOVE_RIGHT : 
                                                                            MOVE_LEFT ;
            end

            default:begin
                next_snake_11_state = LOCK;
            end
        endcase
    end 

    else begin
        next_snake_11_state = snake_11_state;
    end

end


always@(*) begin
    if(en) begin
        /* snake 1 */ 
        next_snake_11_led = (next_snake_11_state == MOVE_RIGHT) ? snake_11_led >> 1 :
                            (next_snake_11_state == MOVE_LEFT)  ? snake_11_led << 1 :
                                                                  snake_11_led;
    end
    else begin
        /* snake 1 */ 
        next_snake_11_led = snake_11_led;
    
    end
end
/*                                                    snake_11                                                    */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*                                                    snake_111                                                   */

reg [1:0] snake_111_lock_dir , next_snake_111_lock_dir;
always@(posedge clk_div26,posedge rst) begin
    if(rst) begin
        snake_111_state <= LOCK;
        snake_111_led <= 16'b00000000000111;
        snake_111_lock_dir <= MOVE_LEFT;
    end

    else begin
        if(en) begin
            snake_111_state <= next_snake_111_state;
            snake_111_led <= next_snake_111_led;
            snake_111_lock_dir <= next_snake_111_lock_dir;
        end
    end
end

always@(*) begin
        
    if(en) begin
        case(snake_111_state)
            LOCK:begin
                next_snake_111_state = MOVE_LEFT;
            end

            MOVE_RIGHT:begin
                
                next_snake_111_lock_dir = MOVE_RIGHT;

                next_snake_111_state =  ((snake_111_led == {13'b0,3'b111}) && ((snake_111_led<<1) & snake_11_led)) ? LOCK : // 右邊是牆,左邊是蛇 -> LOCK
                                        (snake_111_led == {13'b0,3'b111}) ? MOVE_LEFT : // 右邊是牆,左邊不是蛇 -> MOVE_LEFT
                                                                            MOVE_RIGHT; 

            end
            MOVE_LEFT:begin

                next_snake_111_lock_dir = MOVE_LEFT;
                
                next_snake_111_state = ((snake_111_led == {13'b0,3'b111}) && ((snake_111_led<<1) & snake_11_led)) ? LOCK : // 右邊是牆,左邊是蛇 -> LOCK
                                       (snake_111_led == {3'b111,13'b0})   ? MOVE_RIGHT : 
                                       ((snake_111_led<<1) & snake_11_led) ? MOVE_RIGHT : 
                                                                             MOVE_LEFT ;
            end

            default:begin
                next_snake_111_state = LOCK;
            end

        endcase
    end 
    
    else begin
        next_snake_111_state = snake_111_state;
    end

end


always@(*) begin
    if(en) begin
        /* snake 1 */ 
        next_snake_111_led = (next_snake_111_state == MOVE_RIGHT) ? snake_111_led >> 1 :
                             (next_snake_111_state == MOVE_LEFT)  ? snake_111_led << 1 :
                                                                    snake_111_led;
    end
    else begin
        /* snake 1 */ 
        next_snake_111_led = snake_111_led;
    
    end
end

/*                                                    snake_111                                                   */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


assign led = snake_1_led + snake_11_led + snake_111_led;


endmodule