`timescale 1ns / 1ps
module clock_divider #(parameter n = 25) (clk,clk_div);
    input clk;
    output clk_div;
    
    reg[n-1:0]num;
    wire[n-1:0]next_num;
    always@(posedge clk)begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_2 (
    input clk,
    input rst,
    input en,
    input speed,
    input dir,
    output reg [15:0] led
);

    parameter REGULAR = 3'b001;
    parameter ESCAPE  = 3'b010;
    parameter SHINING = 3'b100;
    parameter ALL_LED_SHINING = 16'b1111111111111111;

    reg [3:0] state=REGULAR , next_state;
    reg [2:0] regular_inner_state = 0, next_regular_inner_state ;
    reg [2:0] regular_round = 0 , next_regular_round ;

    reg shining_inner_state = 0 , next_shining_inner_state ;
    reg [3:0] shining_round = 0 , next_shining_round ;
    reg [15:0] next_led;
    reg [15:0] i , j;
    reg [17:0] next_i , next_j;

    assign first_in_escape_mode = (regular_round == 3'd3) ? 1 : 0;

    //directly use two clock in our mudule
    wire clk_div24,clk_div26;
	clock_divider #(24) div1(.clk(clk), .clk_div(clk_div24));
    clock_divider #(26) div2(.clk(clk), .clk_div(clk_div26));
    
    //change speed by switch    
    assign current_clk = (speed) ? clk_div24 : clk_div26;

    always@(posedge current_clk , posedge rst) begin
        if(rst) begin
        
            led <= ~ALL_LED_SHINING;

            state <= REGULAR;
        
            regular_round <= 0;
            regular_inner_state <= 0;

            shining_round <= 0;
            shining_inner_state <= 0;

            i <= 4'd15;
            j <= 4'd14;

        end

        else begin
            
            led <= next_led;
            state <= next_state;
            
            regular_inner_state <= next_regular_inner_state;
            regular_round <= next_regular_round;

            shining_inner_state <= next_shining_inner_state;
            shining_round <= next_shining_round;

            i <= next_i;
            j <= next_j;
        end
    end
    
    /* next_led */
    always@(*) begin
        next_led = led;
        if(en) begin
        
            case(state) 
                REGULAR: begin
                    case(regular_inner_state) 
                        0: begin
                            next_led = ~ALL_LED_SHINING;
                        end
                        1: begin
                            next_led[15] = 1; next_led[11] = 1; next_led[7] = 1; next_led[3] = 1;
                        end
                        2: begin
                            next_led[14] = 1; next_led[10] = 1; next_led[6] = 1; next_led[2] = 1;
                        end
                        3: begin
                            next_led[13] = 1; next_led[9] = 1; next_led[5] = 1; next_led[1] = 1;
                        end
                        4: begin
                            next_led[12] = 1; next_led[8] = 1; next_led[4] = 1; next_led[0] = 1;
                        end
                    endcase
                    if(first_in_escape_mode) begin
                        next_led = ALL_LED_SHINING;
                    end
                end

                ESCAPE: begin
                    case(dir)
                        0:begin
                            next_led[i] = 0; next_led[j] = 0;
                        end
                        1:begin
                            next_led[i] = 1; next_led[j] = 1;
                        end
                    endcase
                end

                SHINING: begin
                    case(shining_inner_state)
                        0: next_led = ALL_LED_SHINING;
                        1: next_led = ~ALL_LED_SHINING;    
                    endcase
                end

            endcase
        end
    end

    /* state inner round */
    always@(*) begin
        if(en) begin
            case(state) 
                REGULAR: begin
                    
                    next_shining_round = 0;
                    
                    if(regular_inner_state == 3'd4) next_regular_round = regular_round + 1;
                    else next_regular_round = regular_round;
                end

                ESCAPE: begin
                
                    next_regular_round = 0;
                    next_shining_round = 0;

                end

                SHINING: begin

                    next_regular_round = 0;

                    if(shining_inner_state == 1) next_shining_round = shining_round + 1;
                    else next_shining_round = shining_round;
                end

            endcase
        end
    end

    /* main state transition */
    always@(*) begin
        next_state = state;
        if(en) begin
            case(state)
                REGULAR: begin
                    if(regular_round == 3'd3) next_state = ESCAPE;
                    else next_state = REGULAR;
                end

                ESCAPE: begin
                    if((dir==0) && (led == ~ALL_LED_SHINING)) next_state = SHINING;
                    else if((dir==1) && (led ==  ALL_LED_SHINING)) next_state = REGULAR;
                    else next_state = ESCAPE;
                end

                SHINING: begin
                    if(shining_round == 4'd4) next_state = REGULAR;
                    else next_state = SHINING;
                end
            endcase
        end
    end
    
    /* state inner_state */
    always@(*)begin
        case(state)
            REGULAR: begin

                if(en) next_regular_inner_state = (regular_inner_state==3'b100) ? 3'b000 : regular_inner_state + 3'b001;
                else   next_regular_inner_state = regular_inner_state;

                next_shining_inner_state = 0;
                next_i = 4'd15;
                next_j = 4'd14;
            end

            ESCAPE: begin
                
                if(en) begin
                    case(dir) 
                        0:begin
                            if(next_j != 0) begin
                                next_i = i - 2;
                                next_j = j - 2;
                            end
                        end
                        1:begin
                            next_i = i + 2;
                            next_j = j + 2;
                        end
                    endcase
                end
                else begin
                    next_i = i;
                    next_j = j;
                end 

                next_regular_inner_state = 0;
                next_shining_inner_state = 0;

            end

            SHINING: begin

                if(en) next_shining_inner_state = ~shining_inner_state;
                else   next_shining_inner_state = shining_inner_state;
            
                next_regular_inner_state = 0;
                next_i = 4'd15;
                next_j = 4'd14;
            end
        endcase
    end

endmodule