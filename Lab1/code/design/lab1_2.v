`timescale 1ns/100ps
module lab1_2 (
    input wire [3:0] source_0,
    input wire [3:0] source_1,
    input wire [3:0] source_2,
    input wire [3:0] source_3,
    input wire [1:0] op_0,
    input wire [1:0] op_1,
    input wire [1:0] request,
    output reg [3:0] result
); 
    /* Note that result can be either reg or wire. 
    * It depends on how you design your module. */
    // add your design here 
    
    wire [3:0] m0_result;
    wire [3:0] m1_result;
    
    // Connect modules //

    lab1_1 m0(
        .op(op_0),
        .a(source_0),
        .b(source_1),
        .d(m0_result)
    );
    lab1_1 m1(
        .op(op_1),
        .a(source_2),
        .b(source_3),
        .d(m1_result)
    );

    /////////////////////

    always@* begin
        result = 4'b0;
        case(request)
            2'b00: result = 4'b0;
            2'b01: result = m0_result;
            2'b10: result = m1_result;
            2'b11: result = m0_result;
            default: result = 4'b0;
        endcase
    end

    

    // always@* begin
    //     result = 4'b0;
    //     case(request)
    //         2'b00: result = 4'b0;
    //         2'b01: result = m0_result;
    //         2'b10: result = m1_result;
    //         2'b11: result = (op_0 <= op_1) ? m0_result : m1_result;
    //         default: result = 4'b0;
    //     endcase
    // end   

endmodule


  












