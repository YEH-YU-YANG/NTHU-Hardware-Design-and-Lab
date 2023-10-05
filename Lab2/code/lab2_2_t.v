module Encoder_t; 

reg clk=1'b0;
reg rst_n=1'b0; 
reg in_valid=1'b0;

reg [3:0] max; 
reg [3:0] min; 
reg [1:0] mode; 
reg [7:0] in_data; 

wire [11:0] out_data; 
wire [2:0] state;
wire [3:0] counter_out; /* use wire to connect two module*/
wire direction;

parameter STATE_DELAY = 170;

/* INIT STATE*/
`define GIVE_INIT_INPUT(in_data_signal,mode_signal) \
    @(negedge clk) begin \
        in_valid = 1'b1; \
        in_data = ``in_data_signal``; \
        mode = ``mode_signal``; \
    end\

/* GET DATA STATE*/
`define DATA_INCREMENT(increment_value) \
    repeat(7) begin \
        #10; \
        in_data = in_data + ``increment_value``; \
        if(in_data == 8'd0) in_data = 1; \
    end  #10
    
/* ENCRYPT_DATA STATE*/
`define ENCRYPT_DATA \
    @(negedge clk) begin \
        in_valid = 1'b0; \
        mode = 2'b10; \
    end

Encoder encoder_t(
    .clk(clk),
    .rst_n(rst_n),
    .max(max),
    .min(min),
    .in_valid(in_valid),
    .mode(mode),
    .in_data(in_data),
    .out_data(out_data),
    .state(state),
    .counter_out(counter_out),
    .direction(direction)
);

always begin 
    #5 clk = ~clk;
end

initial begin
    
    /* Time = 0ns */
    {min,max} = {4'd0,4'd4};   
    mode = 2'b00;
    @(negedge clk) rst_n = 1'b1;
    

    /* INIT STATE */
    `GIVE_INIT_INPUT(8'd2,2'b00)

    /* GET DATA STATE */
    `DATA_INCREMENT(8'd2)

    /* ENCRYPT STATE*/
    `ENCRYPT_DATA

    /* OUTPUT DATA . Just wait for output*/    
    #STATE_DELAY;

    /* INIT STATE */
    `GIVE_INIT_INPUT(8'd230,2'b00)

    /* GET DATA STATE*/
    repeat(7) begin
        #10;
        in_data = in_data + 8'd1;
        {min,max} = {4'd2,4'd15};   
    end
    #10

    /* ENCRYPT STATE*/  
    `ENCRYPT_DATA
    
    /* OUTPUT DATA . Just wait for output*/
    #STATE_DELAY;


    /*************************************************************************************************************************
        
      The code written above is emulating the waveform specified in the "lab2 spec" to ensure it matches the TA's answer.  

    **************************************************************************************************************************/

    /********** It takes 250ns to process four state **********/

    /**********            Time = 520ns              **********/
    
   

    /**********             min < max                  ********/
    
    @(negedge clk) {min,max} = {4'd0,4'd15};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b00)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end
    
    @(negedge clk) {min,max} = {4'd0,4'd15};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b01)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end

    /**********************************************************/




    /**********             min = max                **********/
    @(negedge clk) {min,max} = {4'd0,4'd0};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b00)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end

    @(negedge clk) {min,max} = {4'd15,4'd15};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b01)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end
    /**********************************************************/




    /**********             min > max                **********/
    @(negedge clk) {min,max} = {4'd15,4'd0};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b00)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end
    
    @(negedge clk) {min,max} = {4'd15,4'd0};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b01)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end
    /**********************************************************/


    /**********             min < max  again               ********/
    
    @(negedge clk) {min,max} = {4'd4,4'd13};
    repeat(10) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b00)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end
    
    @(negedge clk) {min,max} = {4'd0,4'd15};
    repeat(5) begin
        `GIVE_INIT_INPUT( ($urandom%255)+1 , 2'b01)
        `DATA_INCREMENT(($urandom % 100) +1);
        `ENCRYPT_DATA
        /* OUTPUT DATA . Just wait for output*/
        #STATE_DELAY;
    end

    /**********************************************************/



    #180
    $stop;
end




endmodule