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

module chair_top_control(
    input clk,
    input rst,
    input [3:0] stage_state,

    input [12:0] key_down,
    input [8:0] last_change,
    input been_ready,
    
    input [10:0] people_up,
    input [10:0] people_left,

    output reg [9:0] chair_up,
    output reg [9:0] chair_left,
    output reg [2:0] chair_state
);


    reg [9:0] next_chair_left;
    reg [9:0] next_chair_up;
    reg chair_IL1;
    reg chair_IL2;
    reg chair_IL5;

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
                chair_up <= 350;                    
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
            
            // 2 -> 5
            else if(chair_IL5 && 220<=chair_left && chair_left<=240 && 240<=chair_up && chair_up<=280) begin
                chair_left <= 410;
                chair_up <= 325;

                chair_state <= 5;
                chair_IL5 <= 0;
            end
            else begin
                chair_left  <= next_chair_left;
                chair_up    <= next_chair_up;
            end
            
            if(chair_IL1!=1) chair_IL1 <= 1;
            if(chair_IL2!=1) chair_IL2 <= 1;
            if(chair_IL5!=1) chair_IL5 <= 1;
        end
    end


    always@(*) begin
        next_chair_left = chair_left;
        next_chair_up = chair_up;
        if(been_ready && key_down[`F5]) begin    
            // push UP_DIR to carbinet
            if( stage_state==2 && chair_state==2 && chair_up+20<=115 &&
                people_up+19-35<chair_up+39 && people_up+19>chair_up+39 && chair_left<people_left+19 && people_left+19<chair_left+39) begin
                next_chair_up = chair_up;
            end
            else begin
                // push UP_DIR
                if(people_up+19-35<chair_up+39 && people_up+19>chair_up+39 && chair_left<people_left+19 && people_left+19<chair_left+39) next_chair_up = chair_up-5;
                // push DOWN_DIR 
                else if(people_up+39+5 > chair_up && people_up<chair_up && chair_left<people_left+19 && people_left+19<chair_left+39) next_chair_up = chair_up+5;
                else next_chair_up = chair_up;

                // push LEFT_DIR
                if(people_left-5 < chair_left+39 && people_left + 40 - 1>chair_left+39 && chair_up<people_up+19 && people_up+19<chair_up+39) next_chair_left = chair_left-5;
                // push RIGHT_DIR
                else if(people_left + 40 - 1+5 > chair_left && people_left<chair_left && chair_up<people_up+19&& people_up+19<chair_up+39) next_chair_left = chair_left+5;
                else next_chair_left = chair_left;
            end
        end
    end

endmodule