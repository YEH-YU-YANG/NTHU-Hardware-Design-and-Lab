module lab6_1(
    input clk,
    input rst,
    input en,
    input dir,
    input vmir,
    input hmir,
    input enlarge,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync
);

    wire clk_25MHz;  
    clock_divider #(2) cd25(.clk(clk),.clk_div(clk_25MHz));

    wire clk_17;
    clock_divider #(17) cd17(.clk(clk),.clk_div(clk_17));
    
    wire clk_22;
    clock_divider #(22) cd22(.clk(clk),.clk_div(clk_22));

    wire [11:0] data;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480


    /* rst button */
    wire rst_debounce,rst_one_pulse;
    debounce drst(.clk(clk_17) ,.pb(rst), .pb_debounced(rst_debounce));
    one_pulse orst(.clk(clk_17),.pb_in(rst_debounce),.pb_out(rst_one_pulse));
    
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    mem_addr_gen m(
        .clk(clk_22),
        .rst(rst_one_pulse),
        .en(en),
        .dir(dir),
        .vmir(vmir),
        .hmir(hmir),
        .enlarge(enlarge),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );

    blk_mem_gen_0 blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel)
    ); 

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst_one_pulse),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );

endmodule

module mem_addr_gen(
    input clk,
    input rst,
    input en,
    input dir,
    input enlarge,
    input vmir,
    input hmir,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output reg [16:0] pixel_addr
);
    
    wire [16:0] modulor;
    assign modulor = 76800;

    reg [8:0] position, next_position;
    always@(*) begin
        if(!enlarge) begin
            if(hmir && vmir) pixel_addr = ((320-((h_cnt>>1)+position)%320) + 320*(240-(v_cnt>>1)))% modulor;
            else if(hmir) pixel_addr = ((320-((h_cnt>>1) + position)%320) + 320*(v_cnt>>1))% modulor;
            else if(vmir) pixel_addr = (((h_cnt>>1) + position)%320 + 320*(240-(v_cnt>>1)))% modulor;
            else pixel_addr = (((h_cnt>>1) + position)%320 + 320*(v_cnt>>1))% modulor;  //640*480 --> 320*240 
        end
        else begin
            if(hmir && vmir) pixel_addr = ((320-((h_cnt>>2)+80+position)%320) + 320*(240-(((v_cnt>>1)+120)>>1)))% modulor;
            else if(hmir) pixel_addr = ((320-((h_cnt>>2)+80+position)%320) + 320*(((v_cnt>>1)+120)>>1))% modulor;
            else if(vmir) pixel_addr = (((h_cnt>>2) + position)%320 + 320*(240-(((v_cnt>>1)+120)>>1)))% modulor;
            else pixel_addr = ( ((h_cnt>>2)+80+position) %320 + 320*( ((v_cnt>>1)+120)>>1 ))% modulor;  // 0~640 -> (>>1) 0~320 -> (+160) 160~480 -> (>>2) 80~240
                                                                                                        // 0~480 -> 120~360
        end
    end

    always @ (posedge clk or posedge rst) begin
        if(rst)
            position <= 0;
        else
            position <= next_position;
    end

    always@(*) begin
        if(en) begin
            if(dir) next_position = (position==9'd0) ? 9'd319 : position - 9'd1;
            else next_position = (position==9'd319) ? 9'd0 : position + 9'd1;
        end
        else begin
            next_position = position;
        end
    end
    
endmodule

