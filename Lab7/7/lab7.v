`define silence   32'd50000000

`define lc  32'd131   
`define ld  32'd147   
`define le  32'd165   
`define lf  32'd174   
`define lg  32'd196
`define la  32'd220   
`define lb  32'd247   

`define c   32'd262   
`define d   32'd294   
`define e   32'd330   
`define f   32'd349   
`define g   32'd392
`define a   32'd440   
`define b   32'd494   

`define hc  32'd524   
`define hd  32'd588   
`define he  32'd660   
`define hf  32'd698   
`define hg  32'd784   
`define ha  32'd880   
`define hb  32'd988


`define seven_segment_0    5'd0
`define seven_segment_1    5'd1
`define seven_segment_2    5'd2
`define seven_segment_3    5'd3
`define seven_segment_4    5'd4
`define seven_segment_5    5'd5
`define seven_segment_6    5'd6
`define seven_segment_7    5'd7
`define seven_segment_8    5'd8
`define seven_segment_9    5'd9

`define seven_segment_C    5'd10
`define seven_segment_D    5'd11  
`define seven_segment_E    5'd12
`define seven_segment_F    5'd13
`define seven_segment_G    5'd14
`define seven_segment_A    5'd15
`define seven_segment_B    5'd16
`define seven_segment_DASH 5'd17


module lab7(
    input clk,
    input rst,        // BTNC: active high reset
    input _play,      // SW0: Play/Pause
    input _start,     // SW1: Start/Exit
    input _mute,      // SW14: Mute
    input _mode,      // SW15: Mode
    input _volUP,     // BTNU: Vol up
    input _volDOWN,   // BTND: Vol down
    inout PS2_DATA,   // Keyboard I/O
    inout PS2_CLK,    // Keyboard I/O
    output wire [15:0] _led,       // LED: [15:9] key & [4:0] volume
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin, // serial audio data input
    output [6:0] DISPLAY,    
    output [3:0] DIGIT
    );        
    
    parameter DEMONSTRATE_MODE = 1'b1;
    parameter PLAY_MODE        = 1'b0;

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;
    wire [11:0] ibeatNum;               // Beat counter
    wire [31:0] freqL, freqR;           // Raw frequency, produced by music module
    wire [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    /* -------------------------------------------------------------------------- */
    /*                                  clkDiv22                                  */
    /* -------------------------------------------------------------------------- */
    wire clkDiv22;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for audio


    /* -------------------------------------------------------------------------- */
    /*                                  clkDiv17                                  */
    /* -------------------------------------------------------------------------- */
    wire clkDiv17;
    clock_divider #(.n(17)) clock_17(.clk(clk), .clk_div(clkDiv17));    


    /* -------------------------------------------------------------------------- */
    /*                                     rst                                    */
    /* -------------------------------------------------------------------------- */
    wire rst_debounce,rst_one_pulse;
    debounce drst(.clk(clkDiv17) ,.pb(rst), .pb_debounced(rst_debounce));
    onepulse orst(.clk(clkDiv17),.signal(rst_debounce),.op(rst_one_pulse));


    /* -------------------------------------------------------------------------- */
    /*                                   _volup                                   */
    /* -------------------------------------------------------------------------- */
    wire volup_debounce,volup_one_pulse;
    debounce dvolup(.clk(clkDiv17) ,.pb(_volUP), .pb_debounced(volup_debounce));
    onepulse ovolup(.clk(clkDiv17),.signal(volup_debounce),.op(volup_one_pulse));


    /* -------------------------------------------------------------------------- */
    /*                                  _voldown                                  */
    /* -------------------------------------------------------------------------- */
    wire voldown_debounce,voldown_one_pulse;
    debounce dvoldown(.clk(clkDiv17) ,.pb(_volDOWN), .pb_debounced(voldown_debounce));
    onepulse ovoldown(.clk(clkDiv17),.signal(voldown_debounce),.op(voldown_one_pulse));
    
   /* -------------------------------------------------------------------------- */
   /*                                  demo beat                                 */
   /* -------------------------------------------------------------------------- */
    wire [11:0] demo_ibeat;
    demo_beat_control #(.LEN(511)) playerCtrl_00 ( 
        .clkDiv22(clkDiv22),
        .rst(rst_one_pulse),
        .mode(_mode),         
        .play(_play), 
        .demo_ibeat(demo_ibeat)
    );
    

    /* -------------------------------------------------------------------------- */
    /*                                 helper beat                                */
    /* -------------------------------------------------------------------------- */
    wire [11:0] helper_ibeat;
    wire HELPER_END;
    helper_beat_control #(.LEN(511)) playerCtrl_01 ( 
        .clkDiv22(clkDiv22),
        .rst(rst_one_pulse),
        .mode(_mode),         
        .start( _start),
        .helper_ibeat(helper_ibeat),
        .HELPER_END(HELPER_END)
    );
    
    /* -------------------------------------------------------------------------- */
    /*                                 lightly_row                                 */
    /* -------------------------------------------------------------------------- */
    wire [31:0] music_freqL;
    wire [31:0] music_freqR;
    lightly_row music(
        .demo_ibeat(demo_ibeat),
        .helper_ibeat(helper_ibeat),
        .MODE(_mode),
        .PLAY(_play),
        .START(_start),
        .HELPER_END(HELPER_END),
        .toneL(music_freqL),
        .toneR(music_freqR)
    ); 
    

    /* -------------------------------------------------------------------------- */
    /*                            freq_outL, freq_outR                            */
    /* -------------------------------------------------------------------------- */
    // Note gen makes no sound, if freq_out = 50000000 / `silenceence = 1
    assign freq_outL = 50000000 / freqL;
    assign freq_outR = 50000000 / freqR;


    /* -------------------------------------------------------------------------- */
    /*                                   volume                                   */
    /* -------------------------------------------------------------------------- */
    wire [2:0] volume;
    volume_gen vg(
        .clk(clkDiv17),
        .rst(rst_one_pulse),
        .volup(volup_one_pulse),
        .voldown(voldown_one_pulse),
        .isMute(_mute),
        .volume(volume)
    );

    /* -------------------------------------------------------------------------- */
    /*                               Note generation                              */
    /* -------------------------------------------------------------------------- */
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst_one_pulse), 
        .volume(volume),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(rst_one_pulse), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );

    /* -------------------------------------------------------------------------- */
    /*                                  keyboard                                  */
    /* -------------------------------------------------------------------------- */
    wire [64:0] key_down;
    wire [8:0] last_change;
    wire been_ready;
    KeyboardDecoder kd(
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );
    
    wire [19:0] seven_segment_nums;
    keyboard_input_top_control kitc(
        .HELPER_END(HELPER_END),
        .clk(clk),
        .clkDiv17(clkDiv17),
        .rst(rst_one_pulse),
        .key_down(key_down),
        .last_change(last_change),
        .been_ready(been_ready),
        .MODE(_mode),
        .PLAY(_play),
        .START(_start),
        .music_freqR(music_freqR),
        .music_freqL(music_freqL),
        .freqL(freqL),
        .freqR(freqR),
        .seven_segment_nums(seven_segment_nums)
    );

    

    /* -------------------------------------------------------------------------- */
    /*                                seven segment                               */
    /* -------------------------------------------------------------------------- */
    seven_segment ss(
        .clk(clkDiv17),
        .nums(seven_segment_nums),
        .DISPLAY(DISPLAY),
        .DIGIT(DIGIT)
    );


    /* -------------------------------------------------------------------------- */
    /*                                     led                                    */
    /* -------------------------------------------------------------------------- */
    led_control lc(
        .clk(clkDiv22),
        .MODE(_mode),
        .START(_start),
        .music_freqR(music_freqR),
        .helper_ibeat(helper_ibeat),
        .volume(volume),
        .led(_led)
    );


endmodule

module keyboard_input_top_control(
    input clk,
    input clkDiv17,
    input rst,
    input [64:0] key_down,
    input [8:0] last_change,
    input  been_ready,
    input MODE,
    input PLAY,
    input START,
    input [31:0] music_freqR,
    input [31:0] music_freqL,
    input HELPER_END,
    output reg [31:0] freqL,
    output reg [31:0] freqR,
    output reg [19:0] seven_segment_nums
    );

    parameter DEMONSTRATE_MODE = 1'b1;
    parameter PLAY_MODE        = 1'b0;

    parameter KEY_CODES_Q = 9'b0_0001_0101; // q => 15
    parameter KEY_CODES_W = 9'b0_0001_1101; // w => 1D
    parameter KEY_CODES_E = 9'b0_0010_0100; // e => 24
    parameter KEY_CODES_R = 9'b0_0010_1101; // r => 2D
    parameter KEY_CODES_T = 9'b0_0010_1100; // t => 2C
    parameter KEY_CODES_Y = 9'b0_0011_0101; // y => 35
    parameter KEY_CODES_U = 9'b0_0011_1100; // u => 3C

    parameter KEY_CODES_A = 9'b0_0001_1100; // a => 1C 
    parameter KEY_CODES_S = 9'b0_0001_1011; // s => 1B
    parameter KEY_CODES_D = 9'b0_0010_0011; // d => 23
    parameter KEY_CODES_F = 9'b0_0010_1011; // f => 2B
    parameter KEY_CODES_G = 9'b0_0011_0100; // g => 34
    parameter KEY_CODES_H = 9'b0_0011_0011; // h => 33
    parameter KEY_CODES_J = 9'b0_0011_1011; // j => 3B

    parameter KEY_CODES_Z = 9'b0_0001_1010; // z => 1A
    parameter KEY_CODES_X = 9'b0_0010_0010; // x => 22
    parameter KEY_CODES_C = 9'b0_0010_0001; // c => 21
    parameter KEY_CODES_V = 9'b0_0010_1010; // v => 2A
    parameter KEY_CODES_B = 9'b0_0011_0010; // b => 32
    parameter KEY_CODES_N = 9'b0_0011_0001; // n => 31
    parameter KEY_CODES_M = 9'b0_0011_1010; // m => 3A
    parameter noInput = 9'b11111;

    
    /* ---------------- key_num、isKeyInput、key_num_2、isKeyInput_2 --------------- */
	reg isKeyInput;
	reg isKeyInput_2;
	reg [9:0] key_num;
	reg [9:0] key_num_2;
	reg [9:0] temp;
    integer i;

    reg [6:0] input_nums;
    reg [6:0] next_input_nums;
        
	always@(posedge clk) begin
		isKeyInput   = 0;
		isKeyInput_2 = 0;
		key_num    = noInput;
		key_num_2  = noInput;

		for(i=0;i<=64;i=i+1) begin
			if( (key_num==noInput) && key_down[i] ) begin
				key_num = i;
				isKeyInput = 1;
			end
			if( (key_num!=noInput) && i!=key_num && key_down[i]) begin
                key_num_2 = i;
				isKeyInput_2 = 1;
            end
		end

        if(isKeyInput && isKeyInput_2) begin
            if(key_num==last_change) begin
                temp = key_num;
                key_num = key_num_2;
                key_num_2 = temp;
            end

        end
	end
    /* -------------------------------------------------------------------------- */

    

    
    /* ------------------------------ freqL , freqR ----------------------------- */
    reg [31:0] next_freqL;
    reg [31:0] next_freqR;
    always@(posedge clk,posedge rst) begin
        if(rst) begin
            freqL <= `silence;
            freqL <= `silence;
        end

        else begin
            freqL <= next_freqL;
            freqR <= next_freqR;
        end
    end
    /* -------------------------------------------------------------------------- */
    


    /* --------------------------- seven_segement_nums -------------------------- */
    reg [19:0] next_seven_segment_nums;
    always@(posedge clkDiv17,posedge rst) begin
        if(rst) seven_segment_nums <= {`seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH};
        else    seven_segment_nums <= next_seven_segment_nums;
    end
    /* -------------------------------------------------------------------------- */




    /* ---------------------------------- score --------------------------------- */
    reg [6:0] score,next_score;
    reg initialized;
    always@(posedge clkDiv17) begin
        if(rst) begin
            score <= 7'd0;
            initialized <= 0;
        end
        else begin
            if(!initialized) begin
                score <= 7'd0;
                initialized <= 1;
            end
            else begin
                score <= next_score;
                initialized <= 1;
            end

            if(!(MODE==PLAY_MODE && START)) initialized <= 0;
        end

    end
    /* -------------------------------------------------------------------------- */



   
    /* ---------- next_seven_segment_nums, next_freqL, next_freqR , inc --------- */
    reg inc;
    always@(*) begin
        case(MODE)
            DEMONSTRATE_MODE:begin
                next_freqL = music_freqL;
                next_freqR = music_freqR;
                next_seven_segment_nums[19:0] = {`seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH};
                if(PLAY) begin
                    case(music_freqR)
                        `lc:     next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_3 };
                        `ld:     next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_3 };
                        `le:     next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_3 };
                        `lf:     next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_3 };
                        `lg:     next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_3 };
                        `la:     next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_3 };
                        `lb:     next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_3 };
                        
                        `c:      next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_4 };
                        `d:      next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_4 }; 
                        `e:      next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_4 };
                        `f:      next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_4 };
                        `g:      next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_4 };
                        `a:      next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_4 };
                        `b:      next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_4 };

                        `hc:     next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_5 };
                        `hd:     next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_5 };
                        `he:     next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_5 };
                        `hf:     next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_5 };
                        `hg:     next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_5 };
                        `ha:     next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_5 };
                        `hb:     next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_5 };
                        default: next_seven_segment_nums[9:0] = seven_segment_nums[9:0];
                    endcase
                end
                else begin
                    next_seven_segment_nums[9:0] = { `seven_segment_DASH, `seven_segment_DASH };
                end
            end
            PLAY_MODE:begin
                next_freqL = `silence;
                next_freqR = `silence;
                next_seven_segment_nums[19:0] = {`seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH, `seven_segment_DASH};
                if(!HELPER_END) begin
                    case(key_num)
                        KEY_CODES_Q: begin
                            next_freqL = `hc;
                            next_freqR = `hc;
                            next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_5 };
                        end

                        KEY_CODES_W: begin
                            next_freqL = `hd;
                            next_freqR = `hd;
                            next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_5 };
                        end

                        KEY_CODES_E: begin
                            next_freqL = `he;
                            next_freqR = `he;
                            next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_5 };
                        end

                        KEY_CODES_R: begin
                            next_freqL = `hf;
                            next_freqR = `hf;
                            next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_5 };
                        end

                        KEY_CODES_T: begin
                            next_freqL = `hg;
                            next_freqR = `hg;
                            next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_5 };
                        end

                        KEY_CODES_Y: begin
                            next_freqL = `ha;
                            next_freqR = `ha;
                            next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_5 };
                        end

                        KEY_CODES_U: begin
                            next_freqL = `hb;
                            next_freqR = `hb;
                            next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_5 };
                        end

                        KEY_CODES_A: begin
                            next_freqL = `c;
                            next_freqR = `c;
                            next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_4 };
                        end

                        KEY_CODES_S: begin
                            next_freqL = `d;
                            next_freqR = `d;
                            next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_4 };
                        end

                        KEY_CODES_D: begin
                            next_freqL = `e;
                            next_freqR = `e;
                            next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_4 };
                        end

                        KEY_CODES_F: begin
                            next_freqL = `f;
                            next_freqR = `f;
                            next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_4 };
                        end

                        KEY_CODES_G: begin
                            next_freqL = `g;
                            next_freqR = `g;
                            next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_4 };
                        end

                        KEY_CODES_H: begin                            
                            next_freqL = `a;
                            next_freqR = `a;
                            next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_4 };
                        end

                        KEY_CODES_J: begin
                               
                            next_freqL = `b;
                            next_freqR = `b;
                            next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_4 };
                        end

                        KEY_CODES_Z: begin                              
                            next_freqL = `lc;
                            next_freqR = `lc;
                            next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_3 };                             
                        end

                        KEY_CODES_X: begin                             
                            next_freqL = `ld;
                            next_freqR = `ld;
                            next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_3 };       
                        end

                        KEY_CODES_C: begin    
                            next_freqL = `le;
                            next_freqR = `le;
                            next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_3 };
                        end

                        KEY_CODES_V: begin
                            next_freqL = `lf;
                            next_freqR = `lf;
                            next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_3 };
                        end

                        KEY_CODES_B: begin
                            next_freqL = `lg;
                            next_freqR = `lg;
                            next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_3 };
                        end

                        KEY_CODES_N:begin
                            next_freqL = `la;
                            next_freqR = `la;
                            next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_3 }; 
                        end

                        KEY_CODES_M: begin
                            next_freqL = `lb;
                            next_freqR = `lb;
                            next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_3 };
                        end
                        
                    endcase

                end
                /* -------------------------------------------------------------------------- */
                /*                                helper 七段顯示器                            */
                /* -------------------------------------------------------------------------- */
                if(START) begin
                    next_seven_segment_nums[19:10] = seven_segment_nums[19:10]; 
                    case(music_freqR)
                        `lc: next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_3 };
                        `ld: next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_3 };
                        `le: next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_3 };
                        `lf: next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_3 };
                        `lg: next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_3 };
                        `la: next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_3 };
                        `lb: next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_3 };
                        
                        `c: next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_4 };
                        `d: next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_4 }; 
                        `e: next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_4 };
                        `f: next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_4 };
                        `g: next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_4 };
                        `a: next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_4 };
                        `b: next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_4 };

                        `hc: next_seven_segment_nums[9:0] = { `seven_segment_C, `seven_segment_5 };
                        `hd: next_seven_segment_nums[9:0] = { `seven_segment_D, `seven_segment_5 };
                        `he: next_seven_segment_nums[9:0] = { `seven_segment_E, `seven_segment_5 };
                        `hf: next_seven_segment_nums[9:0] = { `seven_segment_F, `seven_segment_5 };
                        `hg: next_seven_segment_nums[9:0] = { `seven_segment_G, `seven_segment_5 };
                        `ha: next_seven_segment_nums[9:0] = { `seven_segment_A, `seven_segment_5 };
                        `hb: next_seven_segment_nums[9:0] = { `seven_segment_B, `seven_segment_5 };
                        default: next_seven_segment_nums[9:0] = seven_segment_nums[9:0];
                    endcase
                
                    if(!HELPER_END && !inc) begin
                        case(music_freqR)
                            `lc,`c,`hc: begin
                                if(isKeyInput &&(key_num==KEY_CODES_Q||key_num==KEY_CODES_A||key_num==KEY_CODES_Z)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end
                            
                            `ld,`d,`hd:begin
                                if(isKeyInput && (key_num==KEY_CODES_W||key_num==KEY_CODES_S||key_num==KEY_CODES_X)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end  
                            
                            `le,`e,`he:begin
                                if(isKeyInput && (key_num==KEY_CODES_E||key_num==KEY_CODES_D||key_num==KEY_CODES_C)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end

                            `lf,`f,`hf:begin
                                if(isKeyInput && (key_num==KEY_CODES_R||key_num==KEY_CODES_F||key_num==KEY_CODES_V)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end

                            `lg,`g,`hg:begin
                                if(isKeyInput && (key_num==KEY_CODES_T||key_num==KEY_CODES_G||key_num==KEY_CODES_B)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end

                            `la,`a,`ha:begin
                                if(isKeyInput && (key_num==KEY_CODES_Y||key_num==KEY_CODES_H||key_num==KEY_CODES_N)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end

                            `lb,`b,`hb:begin
                                if(isKeyInput && (key_num==KEY_CODES_U||key_num==KEY_CODES_J||key_num==KEY_CODES_M)) begin
                                    next_score = score + 1;
                                    inc = 1;
                                end
                                else next_score = score;
                            end
                        endcase
                        
                    end
                    if(next_score > 7'd99) next_score = 7'd99;
                    next_seven_segment_nums[19:15] = next_score / 10;
                    next_seven_segment_nums[14:10] = next_score % 10;

                    if(!isKeyInput) inc = 0;
                end     
            end
        endcase        
    end
    /* -------------------------------------------------------------------------- */


endmodule


module demo_beat_control (
    input clkDiv22,
	input rst,  
    input play,      // SW0: Play/Pause
    input mode,      // SW15: Mode
    output reg [11:0] demo_ibeat
);
    
    parameter DEMONSTRATE_MODE = 1'b1;
    parameter PLAY_MODE        = 1'b0;
    parameter LEN = 4095;

    /* -------------------------------------------------------------------------- */
    /*                                 demo_ibeat                                 */
    /* -------------------------------------------------------------------------- */
    reg [8:0] next_demo_ibeat;

	always @(posedge clkDiv22, posedge rst) begin
		if (rst) begin
			demo_ibeat <= 0;
		end else begin
            demo_ibeat <= next_demo_ibeat;
		end
	end

    // next_beat
    always @* begin
        if(mode==DEMONSTRATE_MODE && play) next_demo_ibeat = (demo_ibeat + 1 < LEN) ? (demo_ibeat + 1) : 0;
        else next_demo_ibeat = demo_ibeat; 
    end

endmodule

module helper_beat_control (
    input clkDiv22,
	input rst,  
    input mode,      // SW15: Mode
    input start,
    output reg [11:0] helper_ibeat,
    output reg HELPER_END
);
    
    parameter DEMONSTRATE_MODE = 1'b1;
    parameter PLAY_MODE        = 1'b0;
    parameter LEN = 4095;

    /* -------------------------------------------------------------------------- */
    /*                                helper_ibeat                                */
    /* -------------------------------------------------------------------------- */
    reg initialized;
    reg [8:0] next_helper_ibeat;
    
	always @(posedge clkDiv22, posedge rst) begin
		if (rst) begin
			helper_ibeat <= 0;
            initialized <= 0;
		end 
        else begin
            if (!initialized) begin
                helper_ibeat <= 0;
                initialized <= 1; // 
            end
            else begin
                helper_ibeat <= next_helper_ibeat;
                initialized <= 1;
            end

            if(!(mode==PLAY_MODE && start)) initialized <= 0;
		end
	end

    // next_helper_beat
    always @* begin
        if(mode == PLAY_MODE && start == 1 && !HELPER_END) begin
            if(helper_ibeat < LEN) next_helper_ibeat = helper_ibeat + 1; 
            else next_helper_ibeat = LEN;
        end
        else next_helper_ibeat = helper_ibeat;
    end


    /* -------------------------------------------------------------------------- */
    /*                                  HELPER_END                                  */
    /* -------------------------------------------------------------------------- */
    always@(*) begin
        if(rst) HELPER_END = 0;
        else if(helper_ibeat==LEN) HELPER_END = 1;
        else HELPER_END = 0;
    end
    
endmodule

module note_gen(
    input clk, // clock from crystal
    input rst, // active high reset
    input [2:0] volume, 
    input [21:0] note_div_left, // div for note generation
    input [21:0] note_div_right,
    output reg [15:0] audio_left,
    output reg [15:0] audio_right
    );

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
    
    // clk_cnt_next, b_clk_next
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    // clk_cnt_next_2, c_clk_next
    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end


    // Assign the amplitude of the note
    // Volume is controlled here
    /* -------------------------------------------------------------------------- */
    /*                                 audio_left                                 */
    /* -------------------------------------------------------------------------- */
    always@(*) begin
        if(note_div_left == 22'd1) audio_left = 16'h0000;
        else begin
            case(volume)
                0: audio_left = 16'h0000;
                1: audio_left = (b_clk == 1'b0) ? 16'h00C8 : 16'hFF38; //  -200  < volume < 200 
                2: audio_left = (b_clk == 1'b0) ? 16'h03E8 : 16'hFC18; //  -1000 < volume < 1000
                3: audio_left = (b_clk == 1'b0) ? 16'h0BB8 : 16'hF448; //  -3000 < volume < 3000
                4: audio_left = (b_clk == 1'b0) ? 16'h1388 : 16'hEC78; //  -5000 < volume < 5000
                5: audio_left = (b_clk == 1'b0) ? 16'h2710 : 16'hD8F0; // -10000 < volume < 10000
            endcase
        end
    end

    /* -------------------------------------------------------------------------- */
    /*                                 audio_right                                */
    /* -------------------------------------------------------------------------- */
    always@(*) begin
        if(note_div_right == 22'd1) audio_right = 16'h0000;
        else begin
            case(volume)
                0: audio_right = 16'h0000;
                1: audio_right = (c_clk == 1'b0) ? 16'h00C8 : 16'hFF38; //  -200  < volume < 200 
                2: audio_right = (c_clk == 1'b0) ? 16'h03E8 : 16'hFC18; //  -1000 < volume < 1000
                3: audio_right = (c_clk == 1'b0) ? 16'h0BB8 : 16'hF448; //  -3000 < volume < 3000
                4: audio_right = (c_clk == 1'b0) ? 16'h1388 : 16'hEC78; //  -5000 < volume < 5000
                5: audio_right = (c_clk == 1'b0) ? 16'h2710 : 16'hD8F0; // -10000 < volume < 10000
            endcase
        end
    end
    
endmodule


module volume_gen(
    input clk,
    input rst,
    input volup,
    input voldown,
    input isMute,
    output reg [2:0]volume
    );

    reg [2:0] v;
    reg [2:0] next_v;
    
    /* -------------------------------------------------------------------------- */
    /*                                   volume                                   */
    /* -------------------------------------------------------------------------- */
    always@(*) begin
        if(isMute) volume = 3'd0;
        else volume = v;
    end

    /* -------------------------------------------------------------------------- */
    /*                                      v                                     */
    /* -------------------------------------------------------------------------- */
    always@(posedge clk,posedge rst) begin
        if(rst) v <= 3'd3;
        else  v <= next_v;
    end

    always@(*) begin
        if(volup && v < 3'd5) next_v = v + 1; 
        else if(voldown && v > 3'd1) next_v = v - 1; 
        else next_v = v;
    end
endmodule


module lightly_row (
    input [11:0] demo_ibeat,
    input [11:0] helper_ibeat,
    input MODE,
    input PLAY,
    input START,
    input HELPER_END,
	output reg [31:0] toneL,
    output reg [31:0] toneR
    );

    /* -------------------------------------------------------------------------- */
    /*                                     en                                     */
    /* -------------------------------------------------------------------------- */
    reg en;
    always@(*) begin
        if(MODE==1'b1 && PLAY==1'b1) en = 1;
        else if (MODE==1'b0 && START==1'b1) en = 1;
        else en = 0;
    end

    /* -------------------------------------------------------------------------- */
    /*                                  ibeatNum                                  */
    /* -------------------------------------------------------------------------- */
    reg [11:0] ibeatNum;
    always@(*) begin
        if(MODE==1'b1 && PLAY==1'b1) ibeatNum = demo_ibeat;
        else if(MODE==1'b0 && START==1'b1) ibeatNum = helper_ibeat;
    end

    /* -------------------------------------------------------------------------- */
    /*                                    toneR                                   */
    /* -------------------------------------------------------------------------- */
    always @* begin
        if(en == 1) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneR = `hg;      12'd1: toneR = `hg; // HG (half-beat)
                12'd2: toneR = `hg;      12'd3: toneR = `hg;
                12'd4: toneR = `hg;      12'd5: toneR = `hg;
                12'd6: toneR = `hg;      12'd7: toneR = `hg;
                12'd8: toneR = `he;      12'd9: toneR = `he; // HE (half-beat)
                12'd10: toneR = `he;     12'd11: toneR = `he;
                12'd12: toneR = `he;     12'd13: toneR = `he;
                12'd14: toneR = `he;     12'd15: toneR = `silence; // (Short break for repetitive notes: high E)

                12'd16: toneR = `he;     12'd17: toneR = `he; // HE (one-beat)
                12'd18: toneR = `he;     12'd19: toneR = `he;
                12'd20: toneR = `he;     12'd21: toneR = `he;
                12'd22: toneR = `he;     12'd23: toneR = `he;
                12'd24: toneR = `he;     12'd25: toneR = `he;
                12'd26: toneR = `he;     12'd27: toneR = `he;
                12'd28: toneR = `he;     12'd29: toneR = `he;
                12'd30: toneR = `he;     12'd31: toneR = `he;

                12'd32: toneR = `hf;     12'd33: toneR = `hf; // HF (half-beat)
                12'd34: toneR = `hf;     12'd35: toneR = `hf;
                12'd36: toneR = `hf;     12'd37: toneR = `hf;
                12'd38: toneR = `hf;     12'd39: toneR = `hf;
                12'd40: toneR = `hd;     12'd41: toneR = `hd; // HD (half-beat)
                12'd42: toneR = `hd;     12'd43: toneR = `hd;
                12'd44: toneR = `hd;     12'd45: toneR = `hd;
                12'd46: toneR = `hd;     12'd47: toneR = `silence; // (Short break for repetitive notes: high D)

                12'd48: toneR = `hd;     12'd49: toneR = `hd; // HD (one-beat)
                12'd50: toneR = `hd;     12'd51: toneR = `hd;
                12'd52: toneR = `hd;     12'd53: toneR = `hd;
                12'd54: toneR = `hd;     12'd55: toneR = `hd;
                12'd56: toneR = `hd;     12'd57: toneR = `hd;
                12'd58: toneR = `hd;     12'd59: toneR = `hd;
                12'd60: toneR = `hd;     12'd61: toneR = `hd;
                12'd62: toneR = `hd;     12'd63: toneR = `hd;

                // --- Measure 2 ---
                12'd64: toneR = `hc;     12'd65: toneR = `hc; // HC (half-beat)
                12'd66: toneR = `hc;     12'd67: toneR = `hc;
                12'd68: toneR = `hc;     12'd69: toneR = `hc;
                12'd70: toneR = `hc;     12'd71: toneR = `hc;
                12'd72: toneR = `hd;     12'd73: toneR = `hd; // HD (half-beat)
                12'd74: toneR = `hd;     12'd75: toneR = `hd;
                12'd76: toneR = `hd;     12'd77: toneR = `hd;
                12'd78: toneR = `hd;     12'd79: toneR = `hd;

                12'd80: toneR = `he;     12'd81: toneR = `he; // HE (half-beat)
                12'd82: toneR = `he;     12'd83: toneR = `he;
                12'd84: toneR = `he;     12'd85: toneR = `he;
                12'd86: toneR = `he;     12'd87: toneR = `he;
                12'd88: toneR = `hf;     12'd89: toneR = `hf; // HF (half-beat)
                12'd90: toneR = `hf;     12'd91: toneR = `hf;
                12'd92: toneR = `hf;     12'd93: toneR = `hf;
                12'd94: toneR = `hf;     12'd95: toneR = `hf;

                12'd96: toneR = `hg;     12'd97: toneR = `hg; // HG (half-beat)
                12'd98: toneR = `hg;     12'd99: toneR = `hg;
                12'd100: toneR = `hg;    12'd101: toneR = `hg;
                12'd102: toneR = `hg;    12'd103: toneR = `silence; // (Short break for repetitive notes: high D)
                12'd104: toneR = `hg;    12'd105: toneR = `hg; // HG (half-beat)
                12'd106: toneR = `hg;    12'd107: toneR = `hg;
                12'd108: toneR = `hg;    12'd109: toneR = `hg;
                12'd110: toneR = `hg;    12'd111: toneR = `silence; // (Short break for repetitive notes: high D)

                12'd112: toneR = `hg;    12'd113: toneR = `hg; // HG (one-beat)
                12'd114: toneR = `hg;    12'd115: toneR = `hg;
                12'd116: toneR = `hg;    12'd117: toneR = `hg;
                12'd118: toneR = `hg;    12'd119: toneR = `hg;
                12'd120: toneR = `hg;    12'd121: toneR = `hg;
                12'd122: toneR = `hg;    12'd123: toneR = `hg;
                12'd124: toneR = `hg;    12'd125: toneR = `hg;
                12'd126: toneR = `hg;    12'd127: toneR = `hg;

                // ----Measure 3---- //
                12'd128: toneR = `hg;    12'd129: toneR = `hg;
                12'd130: toneR = `hg;    12'd131: toneR = `hg;
                12'd132: toneR = `hg;    12'd133: toneR = `hg;
                12'd134: toneR = `hg;    12'd135: toneR = `hg;
                12'd136: toneR = `he;    12'd137: toneR = `he;
                12'd138: toneR = `he;    12'd139: toneR = `he;
                12'd140: toneR = `he;    12'd141: toneR = `he;
                12'd142: toneR = `he;    12'd143: toneR = `silence;

                12'd144: toneR = `he;    12'd145: toneR = `he;
                12'd146: toneR = `he;    12'd147: toneR = `he;
                12'd148: toneR = `he;    12'd149: toneR = `he;
                12'd150: toneR = `he;    12'd151: toneR = `he;
                12'd152: toneR = `he;    12'd153: toneR = `he;
                12'd154: toneR = `he;    12'd155: toneR = `he;
                12'd156: toneR = `he;    12'd157: toneR = `he;
                12'd158: toneR = `he;    12'd159: toneR = `he;

                12'd160: toneR = `hf;    12'd161: toneR = `hf;
                12'd162: toneR = `hf;    12'd163: toneR = `hf;
                12'd164: toneR = `hf;    12'd165: toneR = `hf;
                12'd166: toneR = `hf;    12'd167: toneR = `hf;
                12'd168: toneR = `hd;    12'd169: toneR = `hd;
                12'd170: toneR = `hd;    12'd171: toneR = `hd;
                12'd172: toneR = `hd;    12'd173: toneR = `hd;
                12'd174: toneR = `hd;    12'd175: toneR = `silence;

                12'd176: toneR = `hd;    12'd177: toneR = `hd;
                12'd178: toneR = `hd;    12'd179: toneR = `hd;
                12'd180: toneR = `hd;    12'd181: toneR = `hd;
                12'd182: toneR = `hd;    12'd183: toneR = `hd;
                12'd184: toneR = `hd;    12'd185: toneR = `hd;
                12'd186: toneR = `hd;    12'd187: toneR = `hd;
                12'd188: toneR = `hd;    12'd189: toneR = `hd;
                12'd190: toneR = `hd;    12'd191: toneR = `hd;

                // ----Measure 4---- //
                12'd192: toneR = `hc;    12'd193: toneR = `hc;
                12'd194: toneR = `hc;    12'd195: toneR = `hc;
                12'd196: toneR = `hc;    12'd197: toneR = `hc;
                12'd198: toneR = `hc;    12'd199: toneR = `hc;
                12'd200: toneR = `he;    12'd201: toneR = `he;
                12'd202: toneR = `he;    12'd203: toneR = `he;
                12'd204: toneR = `he;    12'd205: toneR = `he;
                12'd206: toneR = `he;    12'd207: toneR = `he;

                12'd208: toneR = `hg;    12'd209: toneR = `hg;
                12'd210: toneR = `hg;    12'd211: toneR = `hg;
                12'd212: toneR = `hg;    12'd213: toneR = `hg;
                12'd214: toneR = `hg;    12'd215: toneR = `silence;
                12'd216: toneR = `hg;    12'd217: toneR = `hg;
                12'd218: toneR = `hg;    12'd219: toneR = `hg;
                12'd220: toneR = `hg;    12'd221: toneR = `hg;
                12'd222: toneR = `hg;    12'd223: toneR = `hg;

                12'd224: toneR = `he;    12'd225: toneR = `he;
                12'd226: toneR = `he;    12'd227: toneR = `he;
                12'd228: toneR = `he;    12'd229: toneR = `he;
                12'd230: toneR = `he;    12'd231: toneR = `silence;
                12'd232: toneR = `he;    12'd233: toneR = `he;
                12'd234: toneR = `he;    12'd235: toneR = `he;
                12'd236: toneR = `he;    12'd237: toneR = `he;
                12'd238: toneR = `he;    12'd239: toneR = `silence;

                12'd240: toneR = `he;    12'd241: toneR = `he;
                12'd242: toneR = `he;    12'd243: toneR = `he;
                12'd244: toneR = `he;    12'd245: toneR = `he;
                12'd246: toneR = `he;    12'd247: toneR = `he;
                12'd248: toneR = `he;    12'd249: toneR = `he;
                12'd250: toneR = `he;    12'd251: toneR = `he;
                12'd252: toneR = `he;    12'd253: toneR = `he;
                12'd254: toneR = `he;    12'd255: toneR = `he;

                // ----Measure 5---- //
                12'd256: toneR = `hd;    12'd257: toneR = `hd;
                12'd258: toneR = `hd;    12'd259: toneR = `hd;
                12'd260: toneR = `hd;    12'd261: toneR = `hd;
                12'd262: toneR = `hd;    12'd263: toneR = `silence;
                12'd264: toneR = `hd;    12'd265: toneR = `hd;
                12'd266: toneR = `hd;    12'd267: toneR = `hd;
                12'd268: toneR = `hd;    12'd269: toneR = `hd;
                12'd270: toneR = `hd;    12'd271: toneR = `silence;

                12'd272: toneR = `hd;    12'd273: toneR = `hd;
                12'd274: toneR = `hd;    12'd275: toneR = `hd;
                12'd276: toneR = `hd;    12'd277: toneR = `hd;
                12'd278: toneR = `hd;    12'd279: toneR = `silence;
                12'd280: toneR = `hd;    12'd281: toneR = `hd;
                12'd282: toneR = `hd;    12'd283: toneR = `hd;
                12'd284: toneR = `hd;    12'd285: toneR = `hd;
                12'd286: toneR = `hd;    12'd287: toneR = `silence;

                12'd288: toneR = `hd;    12'd289: toneR = `hd;
                12'd290: toneR = `hd;    12'd291: toneR = `hd;
                12'd292: toneR = `hd;    12'd293: toneR = `hd;
                12'd294: toneR = `hd;    12'd295: toneR = `hd;
                12'd296: toneR = `he;    12'd297: toneR = `he;
                12'd298: toneR = `he;    12'd299: toneR = `he;
                12'd300: toneR = `he;    12'd301: toneR = `he;
                12'd302: toneR = `he;    12'd303: toneR = `he;

                12'd304: toneR = `hf;    12'd305: toneR = `hf;
                12'd306: toneR = `hf;    12'd307: toneR = `hf;
                12'd308: toneR = `hf;    12'd309: toneR = `hf;
                12'd310: toneR = `hf;    12'd311: toneR = `hf;
                12'd312: toneR = `hf;    12'd313: toneR = `hf;
                12'd314: toneR = `hf;    12'd315: toneR = `hf;
                12'd316: toneR = `hf;    12'd317: toneR = `hf;
                12'd318: toneR = `hf;    12'd319: toneR = `hf;

                // ----Measure 6---- //
                12'd320: toneR = `he;    12'd321: toneR = `he;
                12'd322: toneR = `he;    12'd323: toneR = `he;
                12'd324: toneR = `he;    12'd325: toneR = `he;
                12'd326: toneR = `he;    12'd327: toneR = `silence;
                12'd328: toneR = `he;    12'd329: toneR = `he;
                12'd330: toneR = `he;    12'd331: toneR = `he;
                12'd332: toneR = `he;    12'd333: toneR = `he;
                12'd334: toneR = `he;    12'd335: toneR = `silence;

                12'd336: toneR = `he;    12'd337: toneR = `he;
                12'd338: toneR = `he;    12'd339: toneR = `he;
                12'd340: toneR = `he;    12'd341: toneR = `he;
                12'd342: toneR = `he;    12'd343: toneR = `silence;
                12'd344: toneR = `he;    12'd345: toneR = `he;
                12'd346: toneR = `he;    12'd347: toneR = `he;
                12'd348: toneR = `he;    12'd349: toneR = `he;
                12'd350: toneR = `he;    12'd351: toneR = `silence;

                12'd352: toneR = `he;    12'd353: toneR = `he;
                12'd354: toneR = `he;    12'd355: toneR = `he;
                12'd356: toneR = `he;    12'd357: toneR = `he;
                12'd358: toneR = `he;    12'd359: toneR = `he;
                12'd360: toneR = `hf;    12'd361: toneR = `hf;
                12'd362: toneR = `hf;    12'd363: toneR = `hf;
                12'd364: toneR = `hf;    12'd365: toneR = `hf;
                12'd366: toneR = `hf;    12'd367: toneR = `hf;

                12'd368: toneR = `hg;    12'd369: toneR = `hg;
                12'd370: toneR = `hg;    12'd371: toneR = `hg;
                12'd372: toneR = `hg;    12'd373: toneR = `hg;
                12'd374: toneR = `hg;    12'd375: toneR = `hg;
                12'd376: toneR = `hg;    12'd377: toneR = `hg;
                12'd378: toneR = `hg;    12'd379: toneR = `hg;
                12'd380: toneR = `hg;    12'd381: toneR = `hg;
                12'd382: toneR = `hg;    12'd383: toneR = `hg;

                // ----Measure 7---- //
                12'd384: toneR = `hg;    12'd385: toneR = `hg;
                12'd386: toneR = `hg;    12'd387: toneR = `hg;
                12'd388: toneR = `hg;    12'd389: toneR = `hg;
                12'd390: toneR = `hg;    12'd391: toneR = `hg;
                12'd392: toneR = `he;    12'd393: toneR = `he;
                12'd394: toneR = `he;    12'd395: toneR = `he;
                12'd396: toneR = `he;    12'd397: toneR = `he;
                12'd398: toneR = `he;    12'd399: toneR = `silence;

                12'd400: toneR = `he;    12'd401: toneR = `he;
                12'd402: toneR = `he;    12'd403: toneR = `he;
                12'd404: toneR = `he;    12'd405: toneR = `he;
                12'd406: toneR = `he;    12'd407: toneR = `he;
                12'd408: toneR = `he;    12'd409: toneR = `he;
                12'd410: toneR = `he;    12'd411: toneR = `he;
                12'd412: toneR = `he;    12'd413: toneR = `he;
                12'd414: toneR = `he;    12'd415: toneR = `he;

                12'd416: toneR = `hf;    12'd417: toneR = `hf;
                12'd418: toneR = `hf;    12'd419: toneR = `hf;
                12'd420: toneR = `hf;    12'd421: toneR = `hf;
                12'd422: toneR = `hf;    12'd423: toneR = `hf;
                12'd424: toneR = `hd;    12'd425: toneR = `hd;
                12'd426: toneR = `hd;    12'd427: toneR = `hd;
                12'd428: toneR = `hd;    12'd429: toneR = `hd;
                12'd430: toneR = `hd;    12'd431: toneR = `silence;

                12'd432: toneR = `hd;    12'd433: toneR = `hd;
                12'd434: toneR = `hd;    12'd435: toneR = `hd;
                12'd436: toneR = `hd;    12'd437: toneR = `hd;
                12'd438: toneR = `hd;    12'd439: toneR = `hd;
                12'd440: toneR = `hd;    12'd441: toneR = `hd;
                12'd442: toneR = `hd;    12'd443: toneR = `hd;
                12'd444: toneR = `hd;    12'd445: toneR = `hd;
                12'd446: toneR = `hd;    12'd447: toneR = `hd;

                // ----Measure 8---- //
                12'd448: toneR = `hc;    12'd449: toneR = `hc;
                12'd450: toneR = `hc;    12'd451: toneR = `hc;
                12'd452: toneR = `hc;    12'd453: toneR = `hc;
                12'd454: toneR = `hc;    12'd455: toneR = `hc;
                12'd456: toneR = `he;    12'd457: toneR = `he;
                12'd458: toneR = `he;    12'd459: toneR = `he;
                12'd460: toneR = `he;    12'd461: toneR = `he;
                12'd462: toneR = `he;    12'd463: toneR = `he;

                12'd464: toneR = `hg;    12'd465: toneR = `hg;
                12'd466: toneR = `hg;    12'd467: toneR = `hg;
                12'd468: toneR = `hg;    12'd469: toneR = `hg;
                12'd470: toneR = `hg;    12'd471: toneR = `silence;
                12'd472: toneR = `hg;    12'd473: toneR = `hg;
                12'd474: toneR = `hg;    12'd475: toneR = `hg;
                12'd476: toneR = `hg;    12'd477: toneR = `hg;
                12'd478: toneR = `hg;    12'd479: toneR = `hg;

                12'd480: toneR = `hc;    12'd481: toneR = `hc;
                12'd482: toneR = `hc;    12'd483: toneR = `hc;
                12'd484: toneR = `hc;    12'd485: toneR = `hc;
                12'd486: toneR = `hc;    12'd487: toneR = `hc;
                12'd488: toneR = `hc;    12'd489: toneR = `hc;
                12'd490: toneR = `hc;    12'd491: toneR = `hc;
                12'd492: toneR = `hc;    12'd493: toneR = `hc;
                12'd494: toneR = `hc;    12'd495: toneR = `hc;

                12'd496: toneR = `hc;    12'd497: toneR = `hc;
                12'd498: toneR = `hc;    12'd499: toneR = `hc;
                12'd500: toneR = `hc;    12'd501: toneR = `hc;
                12'd502: toneR = `hc;    12'd503: toneR = `hc;
                12'd504: toneR = `hc;    12'd505: toneR = `hc;
                12'd506: toneR = `hc;    12'd507: toneR = `hc;
                12'd508: toneR = `hc;    12'd509: toneR = `hc;
                12'd510: toneR = `hc;    12'd511: toneR = `hc;
                default: toneR = `silence;
            endcase
        end else begin
            toneR = `silence;
        end
    end

    /* -------------------------------------------------------------------------- */
    /*                                    toneL                                   */
    /* -------------------------------------------------------------------------- */
    always @(*) begin
        if(en == 1)begin
            case(ibeatNum)
            
                // Measure 1 //
                12'd0: toneL = `hc;  	12'd1: toneL = `hc; // HC (two-beat)
                12'd2: toneL = `hc;  	12'd3: toneL = `hc;
                12'd4: toneL = `hc;	    12'd5: toneL = `hc;
                12'd6: toneL = `hc;  	12'd7: toneL = `hc;
                12'd8: toneL = `hc;	    12'd9: toneL = `hc;
                12'd10: toneL = `hc;	12'd11: toneL = `hc;
                12'd12: toneL = `hc;	12'd13: toneL = `hc;
                12'd14: toneL = `hc;	12'd15: toneL = `hc;

                12'd16: toneL = `hc;	12'd17: toneL = `hc;
                12'd18: toneL = `hc;	12'd19: toneL = `hc;
                12'd20: toneL = `hc;	12'd21: toneL = `hc;
                12'd22: toneL = `hc;	12'd23: toneL = `hc;
                12'd24: toneL = `hc;	12'd25: toneL = `hc;
                12'd26: toneL = `hc;	12'd27: toneL = `hc;
                12'd28: toneL = `hc;	12'd29: toneL = `hc;
                12'd30: toneL = `hc;	12'd31: toneL = `hc;

                12'd32: toneL = `g;	    12'd33: toneL = `g; // G (one-beat)
                12'd34: toneL = `g;	    12'd35: toneL = `g;
                12'd36: toneL = `g;	    12'd37: toneL = `g;
                12'd38: toneL = `g;	    12'd39: toneL = `g;
                12'd40: toneL = `g;	    12'd41: toneL = `g;
                12'd42: toneL = `g;	    12'd43: toneL = `g;
                12'd44: toneL = `g;	    12'd45: toneL = `g;
                12'd46: toneL = `g;	    12'd47: toneL = `g;

                12'd48: toneL = `b;	    12'd49: toneL = `b; // B (one-beat)
                12'd50: toneL = `b;	    12'd51: toneL = `b;
                12'd52: toneL = `b;	    12'd53: toneL = `b;
                12'd54: toneL = `b;	    12'd55: toneL = `b;
                12'd56: toneL = `b;	    12'd57: toneL = `b;
                12'd58: toneL = `b;	    12'd59: toneL = `b;
                12'd60: toneL = `b;	    12'd61: toneL = `b;
                12'd62: toneL = `b;	    12'd63: toneL = `b;

                // Measure 2 //
                12'd64: toneL = `hc;	12'd65: toneL = `hc; // HC (two-beat)
                12'd66: toneL = `hc;    12'd67: toneL = `hc;
                12'd68: toneL = `hc;	12'd69: toneL = `hc;
                12'd70: toneL = `hc;	12'd71: toneL = `hc;
                12'd72: toneL = `hc;	12'd73: toneL = `hc;
                12'd74: toneL = `hc;	12'd75: toneL = `hc;
                12'd76: toneL = `hc;	12'd77: toneL = `hc;
                12'd78: toneL = `hc;	12'd79: toneL = `hc;

                12'd80: toneL = `hc;	12'd81: toneL = `hc;
                12'd82: toneL = `hc;    12'd83: toneL = `hc;
                12'd84: toneL = `hc;    12'd85: toneL = `hc;
                12'd86: toneL = `hc;    12'd87: toneL = `hc;
                12'd88: toneL = `hc;    12'd89: toneL = `hc;
                12'd90: toneL = `hc;    12'd91: toneL = `hc;
                12'd92: toneL = `hc;    12'd93: toneL = `hc;
                12'd94: toneL = `hc;    12'd95: toneL = `hc;

                12'd96: toneL = `g;	    12'd97: toneL = `g; // G (one-beat)
                12'd98: toneL = `g; 	12'd99: toneL = `g;
                12'd100: toneL = `g;	12'd101: toneL = `g;
                12'd102: toneL = `g;	12'd103: toneL = `g;
                12'd104: toneL = `g;	12'd105: toneL = `g;
                12'd106: toneL = `g;	12'd107: toneL = `g;
                12'd108: toneL = `g;	12'd109: toneL = `g;
                12'd110: toneL = `g;	12'd111: toneL = `g;

                12'd112: toneL = `b;	12'd113: toneL = `b; // B (one-beat)
                12'd114: toneL = `b;	12'd115: toneL = `b;
                12'd116: toneL = `b;	12'd117: toneL = `b;
                12'd118: toneL = `b;	12'd119: toneL = `b;
                12'd120: toneL = `b;	12'd121: toneL = `b;
                12'd122: toneL = `b;	12'd123: toneL = `b;
                12'd124: toneL = `b;	12'd125: toneL = `b;
                12'd126: toneL = `b;	12'd127: toneL = `b;

                // ----Measure 3---- // 
                12'd128: toneL = `hc;    12'd129: toneL = `hc;
                12'd130: toneL = `hc;    12'd131: toneL = `hc;
                12'd132: toneL = `hc;    12'd133: toneL = `hc;
                12'd134: toneL = `hc;    12'd135: toneL = `hc;

                12'd136: toneL = `hc;    12'd137: toneL = `hc;
                12'd138: toneL = `hc;    12'd139: toneL = `hc;
                12'd140: toneL = `hc;    12'd141: toneL = `hc;
                12'd142: toneL = `hc;    12'd143: toneL = `hc;

                12'd144: toneL = `hc;    12'd145: toneL = `hc;
                12'd146: toneL = `hc;    12'd147: toneL = `hc;
                12'd148: toneL = `hc;    12'd149: toneL = `hc;
                12'd150: toneL = `hc;    12'd151: toneL = `hc;

                12'd152: toneL = `hc;    12'd153: toneL = `hc;
                12'd154: toneL = `hc;    12'd155: toneL = `hc;
                12'd156: toneL = `hc;    12'd157: toneL = `hc;
                12'd158: toneL = `hc;    12'd159: toneL = `hc;

                12'd160: toneL = `g;    12'd161: toneL = `g;
                12'd162: toneL = `g;    12'd163: toneL = `g;
                12'd164: toneL = `g;    12'd165: toneL = `g;
                12'd166: toneL = `g;    12'd167: toneL = `g;

                12'd168: toneL = `g;    12'd169: toneL = `g;
                12'd170: toneL = `g;    12'd171: toneL = `g;
                12'd172: toneL = `g;    12'd173: toneL = `g;
                12'd174: toneL = `g;    12'd175: toneL = `g;

                12'd176: toneL = `b;    12'd177: toneL = `b;
                12'd178: toneL = `b;    12'd179: toneL = `b;
                12'd180: toneL = `b;    12'd181: toneL = `b;
                12'd182: toneL = `b;    12'd183: toneL = `b;

                12'd184: toneL = `b;    12'd185: toneL = `b;
                12'd186: toneL = `b;    12'd187: toneL = `b;
                12'd188: toneL = `b;    12'd189: toneL = `b;
                12'd190: toneL = `b;    12'd191: toneL = `b;

                // ----Measure 4----
                12'd192: toneL = `hc;    12'd193: toneL = `hc;
                12'd194: toneL = `hc;    12'd195: toneL = `hc;
                12'd196: toneL = `hc;    12'd197: toneL = `hc;
                12'd198: toneL = `hc;    12'd199: toneL = `hc;

                12'd200: toneL = `hc;    12'd201: toneL = `hc;
                12'd202: toneL = `hc;    12'd203: toneL = `hc;
                12'd204: toneL = `hc;    12'd205: toneL = `hc;
                12'd206: toneL = `hc;    12'd207: toneL = `hc;

                12'd208: toneL = `g;    12'd209: toneL = `g;
                12'd210: toneL = `g;    12'd211: toneL = `g;
                12'd212: toneL = `g;    12'd213: toneL = `g;
                12'd214: toneL = `g;    12'd215: toneL = `g;

                12'd216: toneL = `g;    12'd217: toneL = `g;
                12'd218: toneL = `g;    12'd219: toneL = `g;
                12'd220: toneL = `g;    12'd221: toneL = `g;
                12'd222: toneL = `g;    12'd223: toneL = `g;

                12'd224: toneL = `e;    12'd225: toneL = `e;
                12'd226: toneL = `e;    12'd227: toneL = `e;
                12'd228: toneL = `e;    12'd229: toneL = `e;
                12'd230: toneL = `e;    12'd231: toneL = `e;

                12'd232: toneL = `e;    12'd233: toneL = `e;
                12'd234: toneL = `e;    12'd235: toneL = `e;
                12'd236: toneL = `e;    12'd237: toneL = `e;
                12'd238: toneL = `e;    12'd239: toneL = `e;

                12'd240: toneL = `c;    12'd241: toneL = `c;
                12'd242: toneL = `c;    12'd243: toneL = `c;
                12'd244: toneL = `c;    12'd245: toneL = `c;
                12'd246: toneL = `c;    12'd247: toneL = `c;

                12'd248: toneL = `c;    12'd249: toneL = `c;
                12'd250: toneL = `c;    12'd251: toneL = `c;
                12'd252: toneL = `c;    12'd253: toneL = `c;
                12'd254: toneL = `c;    12'd255: toneL = `c;

                // ----Measure 5----
                12'd256: toneL = `g;    12'd257: toneL = `g;
                12'd258: toneL = `g;    12'd259: toneL = `g;
                12'd260: toneL = `g;    12'd261: toneL = `g;
                12'd262: toneL = `g;    12'd263: toneL = `g;

                12'd264: toneL = `g;    12'd265: toneL = `g;
                12'd266: toneL = `g;    12'd267: toneL = `g;
                12'd268: toneL = `g;    12'd269: toneL = `g;
                12'd270: toneL = `g;    12'd271: toneL = `g;

                12'd272: toneL = `g;    12'd273: toneL = `g;
                12'd274: toneL = `g;    12'd275: toneL = `g;
                12'd276: toneL = `g;    12'd277: toneL = `g;
                12'd278: toneL = `g;    12'd279: toneL = `g;

                12'd280: toneL = `g;    12'd281: toneL = `g;
                12'd282: toneL = `g;    12'd283: toneL = `g;
                12'd284: toneL = `g;    12'd285: toneL = `g;
                12'd286: toneL = `g;    12'd287: toneL = `g;

                12'd288: toneL = `f;    12'd289: toneL = `f;
                12'd290: toneL = `f;    12'd291: toneL = `f;
                12'd292: toneL = `f;    12'd293: toneL = `f;
                12'd294: toneL = `f;    12'd295: toneL = `f;

                12'd296: toneL = `f;    12'd297: toneL = `f;
                12'd298: toneL = `f;    12'd299: toneL = `f;
                12'd300: toneL = `f;    12'd301: toneL = `f;
                12'd302: toneL = `f;    12'd303: toneL = `f;

                12'd304: toneL = `d;    12'd305: toneL = `d;
                12'd306: toneL = `d;    12'd307: toneL = `d;
                12'd308: toneL = `d;    12'd309: toneL = `d;
                12'd310: toneL = `d;    12'd311: toneL = `d;

                12'd312: toneL = `d;    12'd313: toneL = `d;
                12'd314: toneL = `d;    12'd315: toneL = `d;
                12'd316: toneL = `d;    12'd317: toneL = `d;
                12'd318: toneL = `d;    12'd319: toneL = `d;

                // ----Measure 6----
                12'd320: toneL = `e;    12'd321: toneL = `e;
                12'd322: toneL = `e;    12'd323: toneL = `e;
                12'd324: toneL = `e;    12'd325: toneL = `e;
                12'd326: toneL = `e;    12'd327: toneL = `e;

                12'd328: toneL = `e;    12'd329: toneL = `e;
                12'd330: toneL = `e;    12'd331: toneL = `e;
                12'd332: toneL = `e;    12'd333: toneL = `e;
                12'd334: toneL = `e;    12'd335: toneL = `e;

                12'd336: toneL = `e;    12'd337: toneL = `e;
                12'd338: toneL = `e;    12'd339: toneL = `e;
                12'd340: toneL = `e;    12'd341: toneL = `e;
                12'd342: toneL = `e;    12'd343: toneL = `e;

                12'd344: toneL = `e;    12'd345: toneL = `e;
                12'd346: toneL = `e;    12'd347: toneL = `e;
                12'd348: toneL = `e;    12'd349: toneL = `e;
                12'd350: toneL = `e;    12'd351: toneL = `e;

                12'd352: toneL = `g;    12'd353: toneL = `g;
                12'd354: toneL = `g;    12'd355: toneL = `g;
                12'd356: toneL = `g;    12'd357: toneL = `g;
                12'd358: toneL = `g;    12'd359: toneL = `g;

                12'd360: toneL = `g;    12'd361: toneL = `g;
                12'd362: toneL = `g;    12'd363: toneL = `g;
                12'd364: toneL = `g;    12'd365: toneL = `g;
                12'd366: toneL = `g;    12'd367: toneL = `g;

                12'd368: toneL = `b;    12'd369: toneL = `b;
                12'd370: toneL = `b;    12'd371: toneL = `b;
                12'd372: toneL = `b;    12'd373: toneL = `b;
                12'd374: toneL = `b;    12'd375: toneL = `b;

                12'd376: toneL = `b;    12'd377: toneL = `b;
                12'd378: toneL = `b;    12'd379: toneL = `b;
                12'd380: toneL = `b;    12'd381: toneL = `b;
                12'd382: toneL = `b;    12'd383: toneL = `b;

                // ----Measure 7----
                12'd384: toneL = `hc;    12'd385: toneL = `hc;
                12'd386: toneL = `hc;    12'd387: toneL = `hc;
                12'd388: toneL = `hc;    12'd389: toneL = `hc;
                12'd390: toneL = `hc;    12'd391: toneL = `hc;

                12'd392: toneL = `hc;    12'd393: toneL = `hc;
                12'd394: toneL = `hc;    12'd395: toneL = `hc;
                12'd396: toneL = `hc;    12'd397: toneL = `hc;
                12'd398: toneL = `hc;    12'd399: toneL = `hc;

                12'd400: toneL = `hc;    12'd401: toneL = `hc;
                12'd402: toneL = `hc;    12'd403: toneL = `hc;
                12'd404: toneL = `hc;    12'd405: toneL = `hc;
                12'd406: toneL = `hc;    12'd407: toneL = `hc;

                12'd408: toneL = `hc;    12'd409: toneL = `hc;
                12'd410: toneL = `hc;    12'd411: toneL = `hc;
                12'd412: toneL = `hc;    12'd413: toneL = `hc;
                12'd414: toneL = `hc;    12'd415: toneL = `hc;

                12'd416: toneL = `g;    12'd417: toneL = `g;
                12'd418: toneL = `g;    12'd419: toneL = `g;
                12'd420: toneL = `g;    12'd421: toneL = `g;
                12'd422: toneL = `g;    12'd423: toneL = `g;

                12'd424: toneL = `g;    12'd425: toneL = `g;
                12'd426: toneL = `g;    12'd427: toneL = `g;
                12'd428: toneL = `g;    12'd429: toneL = `g;
                12'd430: toneL = `g;    12'd431: toneL = `g;

                12'd432: toneL = `b;    12'd433: toneL = `b;
                12'd434: toneL = `b;    12'd435: toneL = `b;
                12'd436: toneL = `b;    12'd437: toneL = `b;
                12'd438: toneL = `b;    12'd439: toneL = `b;

                12'd440: toneL = `b;    12'd441: toneL = `b;
                12'd442: toneL = `b;    12'd443: toneL = `b;
                12'd444: toneL = `b;    12'd445: toneL = `b;
                12'd446: toneL = `b;    12'd447: toneL = `b;

                // ----Measure 8----
                12'd448: toneL = `hc;    12'd449: toneL = `hc;
                12'd450: toneL = `hc;    12'd451: toneL = `hc;
                12'd452: toneL = `hc;    12'd453: toneL = `hc;
                12'd454: toneL = `hc;    12'd455: toneL = `hc;

                12'd456: toneL = `hc;    12'd457: toneL = `hc;
                12'd458: toneL = `hc;    12'd459: toneL = `hc;
                12'd460: toneL = `hc;    12'd461: toneL = `hc;
                12'd462: toneL = `hc;    12'd463: toneL = `hc;

                12'd464: toneL = `g;    12'd465: toneL = `g;
                12'd466: toneL = `g;    12'd467: toneL = `g;
                12'd468: toneL = `g;    12'd469: toneL = `g;
                12'd470: toneL = `g;    12'd471: toneL = `g;

                12'd472: toneL = `g;    12'd473: toneL = `g;
                12'd474: toneL = `g;    12'd475: toneL = `g;
                12'd476: toneL = `g;    12'd477: toneL = `g;
                12'd478: toneL = `g;    12'd479: toneL = `g;

                12'd480: toneL = `c;    12'd481: toneL = `c;
                12'd482: toneL = `c;    12'd483: toneL = `c;
                12'd484: toneL = `c;    12'd485: toneL = `c;
                12'd486: toneL = `c;    12'd487: toneL = `c;

                12'd488: toneL = `c;    12'd489: toneL = `c;
                12'd490: toneL = `c;    12'd491: toneL = `c;
                12'd492: toneL = `c;    12'd493: toneL = `c;
                12'd494: toneL = `c;    12'd495: toneL = `c;

                12'd496: toneL = `c;    12'd497: toneL = `c;
                12'd498: toneL = `c;    12'd499: toneL = `c;
                12'd500: toneL = `c;    12'd501: toneL = `c;
                12'd502: toneL = `c;    12'd503: toneL = `c;

                12'd504: toneL = `c;    12'd505: toneL = `c;
                12'd506: toneL = `c;    12'd507: toneL = `c;
                12'd508: toneL = `c;    12'd509: toneL = `c;
                12'd510: toneL = `c;    12'd511: toneL = `c;

                default : toneL = `silence;
            endcase
        end
        else begin
            toneL = `silence;
        end
    end
endmodule

module KeyboardDecoder(
	output reg [64:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [64:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	onepulse op (
		.op(pulse_been_ready),
		.signal(been_ready),
		.clk(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule


module seven_segment(
	input clk,
	input [19:0] nums,
    output reg [6:0] DISPLAY,
	output reg [3:0] DIGIT
    );

   reg [4:0] value, next_value, next_DIGIT;
    
    always@(posedge clk) begin
        value <= next_value;
        DIGIT <= next_DIGIT;
    end
    
    always@(*) begin
        case (DIGIT)
            4'b1110: begin
                next_value = nums[9:5];
                next_DIGIT = 4'b1101;
            end
            4'b1101: begin
                next_value = nums[14:10];
                next_DIGIT = 4'b1011;
            end
            4'b1011: begin
                next_value = nums[19:15];
                next_DIGIT = 4'b0111;
            end
            4'b0111: begin
                next_value = nums[4:0];
                next_DIGIT = 4'b1110;
            end
            default: begin
                next_value = nums[4:0];
                next_DIGIT = 4'b1110;
            end
        endcase
    end
    
    always @(*) begin
        case (value)        

            `seven_segment_0    : DISPLAY = 7'b100_0000;
            `seven_segment_1    : DISPLAY = 7'b111_1001;
            `seven_segment_2    : DISPLAY = 7'b010_0100;
            `seven_segment_3    : DISPLAY = 7'b011_0000;
            `seven_segment_4    : DISPLAY = 7'b001_1001;
            `seven_segment_5    : DISPLAY = 7'b001_0010;
            `seven_segment_6    : DISPLAY = 7'b000_0010;
            `seven_segment_7    : DISPLAY = 7'b111_1000;
            `seven_segment_8    : DISPLAY = 7'b000_0000;
            `seven_segment_9    : DISPLAY = 7'b001_0000;

            `seven_segment_C    : DISPLAY = 7'b100_0110;
            `seven_segment_D    : DISPLAY = 7'b010_0001;
            `seven_segment_E    : DISPLAY = 7'b000_0110;
            `seven_segment_F    : DISPLAY = 7'b000_1110;
            `seven_segment_G    : DISPLAY = 7'b001_0000;
            `seven_segment_A    : DISPLAY = 7'b000_1000;
            `seven_segment_B    : DISPLAY = 7'b000_0011;
            `seven_segment_DASH : DISPLAY = 7'b011_1111;

            default: DISPLAY = 7'b111_1111;
        endcase
    end
endmodule

module led_control(
        input clk,
        input MODE,
        input START,
        input [31:0] music_freqR,
        input [11:0] helper_ibeat,
        input [2:0] volume,
        output reg [15:0] led
);

    /* -------------------------------------------------------------------------- */
    /*                                 led control                                */
    /* -------------------------------------------------------------------------- */
    always@(*) begin
        led = 16'b0;

        /* ---------------------------- Play mode helper ---------------------------- */
        if(MODE == 1'b0 && START) begin
            case(music_freqR)
                `lc,`c,`hc: led[15]=1;
                `ld,`d,`hd: led[14]=1;
                `le,`e,`he: led[13]=1;
                `lf,`f,`hf: led[12]=1;
                `lg,`g,`hg: led[11]=1;
                `la,`a,`ha: led[10]=1;
                `lb,`b,`hb: led[9] =1;
            endcase
            if(helper_ibeat==11'd511) led[15:9] = 7'b111_1111;
        end
        /* -------------------------------------------------------------------------- */


        /* ------------------------------- volume led ------------------------------- */
        case(volume)
            0: led[4:0] = 5'b0;  
            1: led[4:0] = {4'b0000,1'b1};  
            2: led[4:0] = {3'b000,2'b11};  
            3: led[4:0] = {2'b00,3'b111};  
            4: led[4:0] = {1'b0,4'b1111};  
            5: led[4:0] = {5'b1_1111};  
        endcase
        /* -------------------------------------------------------------------------- */
    end

endmodule
