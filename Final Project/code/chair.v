
`define F5 9'b0_0000_0011 // space 03 => 3  

module chair_top_control(
    input clk,
    input rst,
    input [2:0] stage_state,

    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,
    
    input [9:0] people_up,
    input [9:0] people_left,

    output reg [9:0] chair_up,
    output reg [9:0] chair_left,
    output reg [2:0] chair_state
);


    reg [9:0] next_chair_left;
    reg [9:0] next_chair_up;
    reg chair_IL1;
    reg chair_IL2;

    always@(posedge clk) begin
        if(rst) begin
            chair_left  <= 430;
            chair_up    <= 250;
            chair_IL1 <= 1;
            chair_IL2 <= 1;
            chair_state <= 0;
        end
        else begin

            // 0 -> 1
            if(chair_IL1 && 350<=chair_left+20 && chair_left+20<=420 && 10<=chair_up+20 && chair_up+20<=30) begin
                chair_left <= 190;
                chair_up <= 330;                    
                chair_state <= 1;
                chair_IL1 <= 0;
            end
            
            // 1 -> 2
            else if(chair_IL2 && 80<=chair_left+20 && chair_left+20<=100 && 330<=chair_up+20 && chair_up+20 <=400) begin
                chair_left <= 330;
                chair_up <= 280;
                chair_state <= 2;
                chair_IL2 <= 0;
            end

            else begin
                chair_left  <= next_chair_left;
                chair_up    <= next_chair_up;
            end

            if(chair_IL1!=1) chair_IL1 <= 1;
            if(chair_IL2!=1) chair_IL2 <= 1;

        end
    end


    always@(*) begin

        if(been_ready && key_down[`F5]) begin
            
            if(stage_state==2 && chair_up+20<=115) begin
                next_chair_left = chair_left;
                next_chair_up = chair_up;
            end
            else begin
                
                // push up
                if(people_up+19-35<chair_up+39 && people_up+19>chair_up+39 && chair_left<people_left+19 && people_left+19<chair_left+39) next_chair_up = chair_up-5;
                // push down 
                else if(people_up+39+5 > chair_up && people_up<chair_up && chair_left<people_left+19 && people_left+19<chair_left+39) next_chair_up = chair_up+5;
                else next_chair_up = chair_up;

                // push left
                if(people_left-5 < chair_left+39 && people_left + 40 - 1>chair_left+39 && chair_up<people_up+19 && people_up+19<chair_up+39) next_chair_left = chair_left-5;
                // push right
                else if(people_left + 40 - 1+5 > chair_left && people_left<chair_left && chair_up<people_up+19&& people_up+19<chair_up+39) next_chair_left = chair_left+5;
                else next_chair_left = chair_left;


            end

        end
        else begin
            next_chair_left = chair_left;
            next_chair_up = chair_up;
        end
    end

endmodule