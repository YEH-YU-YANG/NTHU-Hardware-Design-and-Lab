module Encoder (
    input clk, 
    input rst_n, 
    input [3:0] max, 
    input [3:0] min, 
    input in_valid, 
    input [1:0] mode, 
    input [7:0] in_data, 
    output reg [11:0] out_data, 
    output reg [2:0] state, 
    output wire [3:0] counter_out, /* use wire to connect two module*/
    output wire direction
);

reg [2:0] next_state;
reg [7:0] output_tmp [7:0], next_output_tmp [7:0] ;
reg [7:0] encrypt_data [7:0];
reg [12:0] hamming_code [7:0];

parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter ENCRYPT_DATA = 3'd2;
parameter OUTPUT_DATA = 3'd3;

parameter FALSE = 1'b0;
parameter TRUE = 1'b1;

//
reg [3:0] offset,next_offset;

/* using mode signal to process the flip and enable signal */
wire flip, enable;

/* fill in the following blanks (e.g.: a = (b == 2'b01) ? 1'b1 : 1'b0) */
assign flip = (mode == 2'b00) ? FALSE : TRUE;
assign enable = (mode == 2'b10) ? FALSE : TRUE;

/* instantiate the Parameterized_Ping_Pong_Counter module */
Parameterized_Ping_Pong_Counter pppc(
    .clk(clk), 
    .rst_n(rst_n), 
    .enable(enable), 
    .flip(flip), 
    .max(max), 
    .min(min), 
    .direction(direction), 
    .out(counter_out)
);

////////// state transition //////////
always@(posedge clk) begin
    if(!rst_n) 
        state <= INIT;
    else
        state <= next_state;
end

////////// state transition //////////

always@(*) begin
    case(state)
        INIT: begin
            if(in_valid) next_state = GET_DATA;
            else next_state = INIT;
        end
        GET_DATA: begin
            if(!in_valid && (mode==2'b10)) next_state = ENCRYPT_DATA;
            else next_state = GET_DATA;
        end
        ENCRYPT_DATA: begin
            if(offset == 3'd7) next_state = OUTPUT_DATA;
            else next_state = ENCRYPT_DATA;
        end
        OUTPUT_DATA: begin
            if(offset == 3'd7) next_state = INIT;
            else next_state = OUTPUT_DATA;
        end
        default: begin
            next_state = state;
        end
    endcase
end
////////////////////////////////////////


/* counter (this is the offset_cnt in the Practice_2) */
always@(posedge clk) begin
    if(!rst_n) 
        offset <= 3'd0;
    else
        offset <= next_offset;
end

/* counter (this is the offset_cnt in the Practice_2) */

always@(*) begin
    case(state)
        INIT:begin
            next_offset = 3'd0;
        end
        
        GET_DATA:begin
            if(in_valid) next_offset = (offset==3'd7) ? 3'd0 : offset + 3'd1;
        end
        
        ENCRYPT_DATA , OUTPUT_DATA : begin
            next_offset = (offset==3'd7) ? 3'd0 : offset + 3'd1;
        end
        
        default:begin
            next_offset = offset;
        end
    endcase
end

/* output_tmp */
always@(posedge clk) begin
    if(!rst_n) begin
        output_tmp[0] <= 8'b0;
    end
    else begin
        output_tmp[offset] <= next_output_tmp[offset];
    end
end


/* determine the next_output_tmp value base on the current state */
/* You can store the in_data in the next_output_tmp (by using the value of offset_cnt reg)
    and then process these data in the PROCESS_DATA state */
always@(*) begin
    case(state)
        INIT: begin
            if(in_valid) next_output_tmp[offset] = in_data;
            else next_output_tmp[offset] = 8'd0;
        end
        GET_DATA: begin  
            if(in_valid) next_output_tmp[offset+1] = in_data;
        end
        ENCRYPT_DATA: begin
            if(!in_valid && mode==2'b10) begin
                encrypt_data[offset] = (next_output_tmp[offset] + counter_out) % 256;

                /* hamming code encoding rules */
                hamming_code[offset][1]  = encrypt_data[offset][0] ^ encrypt_data[offset][1] ^ encrypt_data[offset][3] ^ encrypt_data[offset][4] ^ encrypt_data[offset][6];
                hamming_code[offset][2]  = encrypt_data[offset][0] ^ encrypt_data[offset][2] ^ encrypt_data[offset][3] ^ encrypt_data[offset][5] ^ encrypt_data[offset][6];
                hamming_code[offset][4]  = encrypt_data[offset][1] ^ encrypt_data[offset][2] ^ encrypt_data[offset][3] ^ encrypt_data[offset][7];
                hamming_code[offset][8]  = encrypt_data[offset][4] ^ encrypt_data[offset][5] ^ encrypt_data[offset][6] ^ encrypt_data[offset][7];

                hamming_code[offset][3]  = encrypt_data[offset][0];
                hamming_code[offset][5]  = encrypt_data[offset][1];
                hamming_code[offset][6]  = encrypt_data[offset][2];
                hamming_code[offset][7]  = encrypt_data[offset][3];
                hamming_code[offset][9]  = encrypt_data[offset][4];
                hamming_code[offset][10] = encrypt_data[offset][5];
                hamming_code[offset][11] = encrypt_data[offset][6];
                hamming_code[offset][12] = encrypt_data[offset][7];

            end
        end
        // OUTPUT_DATA: begin
        //     next_output_tmp[offset] = hamming_code[offset];
        // end
        default:begin
            next_output_tmp[offset] = output_tmp[offset];
        end
    endcase
end

/* data processing  */

/* output data */
always @(posedge clk) begin
    if (!rst_n) begin
        out_data <= 12'b0;
    end
    else begin
        /* determine the value of out_data under different circumstances */
        case(state)
            INIT: begin
                out_data <= 12'b0; 
            end
            GET_DATA: begin
                out_data <= 12'b0; 
            end
            ENCRYPT_DATA: begin
                if(offset == 3'd7) out_data <= hamming_code[0][12:1];
                else out_data <= 12'b0;
            end
            OUTPUT_DATA: begin
                if(offset == 3'd7) out_data <= 12'b0;
                else out_data <= hamming_code[offset+1][12:1]; 
            end
            default: begin
                out_data <= 12'b0;
            end
        endcase
    end
end

endmodule
