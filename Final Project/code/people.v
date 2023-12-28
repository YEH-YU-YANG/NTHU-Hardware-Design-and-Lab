`define LEFT_DIR 0
`define RIGHT_DIR 1

module people_top_control(
    input clk,
    input clk_25MHz,
    input rst,
    input [50:0] key_down,
    input [8:0] last_change,
    input been_ready,
    input [9:0] x,
    input [9:0] y,

    output reg [9:0] people_left_border,
    output reg [9:0] people_right_border,
    output reg [9:0] people_up_border,
    output reg [9:0] people_down_border,
    output wire [11:0] people_pixel
);

    reg [8:0] key_w = 9'b0_0001_1101; // w => 1D
    reg [8:0] key_a = 9'b0_0001_1100; // a => 1C
    reg [8:0] key_s = 9'b0_0001_1011; // s => 1B
    reg [8:0] key_d = 9'b0_0010_0011; // d => 23

    reg [9:0] next_people_x;
    reg [9:0] next_people_y;
    reg [9:0] next_people_left_border;
    reg [9:0] next_people_up_border;

    /* -------------------------------------------------------------------------- */
    /*                                  movement                                  */
    /* -------------------------------------------------------------------------- */
    reg dir,next_dir;
    always@(posedge clk) begin
        if(rst) begin
            people_left_border <= 320;
            people_up_border <= 240;
            dir <= `LEFT_DIR;
        end
        else begin
            people_left_border <= next_people_left_border;
            people_up_border <= next_people_up_border;
            dir <= next_dir;
        end
    end

    always@(*) begin
        
        if(been_ready && key_down[last_change] == 1'b1) begin
            
            next_people_left_border = people_left_border;
            next_people_up_border = people_up_border;
            next_dir = dir;

            if(key_down[key_w]) next_people_up_border = people_up_border - 2;
            if(key_down[key_s]) next_people_up_border = people_up_border + 2;

            if(key_down[key_a]) begin
                next_people_left_border = people_left_border - 2;
                next_dir = `LEFT_DIR;
            end
            if(key_down[key_d]) begin
                next_people_left_border = people_left_border + 2;
                next_dir = `RIGHT_DIR;
            end

        end
        else begin
            next_people_left_border = people_left_border;
            next_people_up_border = people_up_border;
            next_dir = dir;
        end
    end


    /* -------------------------------------------------------------------------- */
    /*                                   border                                   */
    /* -------------------------------------------------------------------------- */

    
    //people right2 => width:30 , height:40
    reg [9:0] width  = 40;
    reg [9:0] height = 40;
    
    always@(posedge clk) begin
        people_right_border <= people_left_border + width - 1;
        people_down_border  <= people_up_border + height -1;
    end
    
    wire [11:0] people_addr;
    assign people_addr = (x - people_left_border) + width*(y - people_up_border);


    /* -------------------------------------------------------------------------- */
    /*                                people_pixel                                */
    /* -------------------------------------------------------------------------- */

    wire [11:0] people_right_pixel;
    wire [11:0] people_left_pixel;
    wire [11:0] garbage;
    
    people_right_w40h40 p2 (.clka(clk_25MHz),.wea(0),.addra(people_addr),.dina(garbage),.douta(people_right_pixel));
    people_left_w40h40  p3 (.clka(clk_25MHz),.wea(0),.addra(people_addr),.dina(garbage),.douta(people_left_pixel));

    assign people_pixel = (dir==`LEFT_DIR) ? people_left_pixel : people_right_pixel;

endmodule

 
