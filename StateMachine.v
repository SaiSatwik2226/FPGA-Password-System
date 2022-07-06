`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2022 01:18:24 PM
// Design Name: 
// Module Name: SM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module StateMachine(
    input clk,
    input reset,
    input data_valid,
    input [3:0] digit,
    input lock,
    output unlocked,
    output locked,
    output [31:0] inp_out,
    output [3:0] count_out,
    output permlocked,
    input new
    );
    
reg [3:0] state;
reg [1:0] fail_count;
reg [3:0] count;
reg [31:0] inp;

//reg [31:0] pwd = 'h12345678;
reg [31:0] pwd;
reg change;

initial begin
    pwd <= 'h12345678;
end

localparam CHECKDIGIT = 'd0;
localparam COMPARE = 'd1;
localparam UNLOCKED = 'd2;
localparam PERMLOCK = 'd3;

assign unlocked = (state == UNLOCKED);
assign locked = ~unlocked;

assign permlocked = (state == PERMLOCK);

assign inp_out = (change==0)?inp:pwd;
assign count_out = count;



always @(posedge clk) begin
    if (reset == 1'b1) begin
        state <= CHECKDIGIT;
        fail_count <= 0;
        count <= 0;
        inp <= 32'b0;
    end
    else begin   
//        if ( data_valid == 1'b1 ) begin
            case (state)
                CHECKDIGIT: begin
                    if ( count < 8 && fail_count!=3) begin
                        if ( data_valid == 1'b1 ) begin
                            if(change==1'b1)
                                pwd <= {pwd[27:0], digit};
                            else
                                inp <= {inp[27:0], digit};
                            count <= count + 1; 
                        end
                        
                    end
                    else begin
                        if(change == 1'b1)begin
                            state <= CHECKDIGIT;
                            change <= 0;
                        end
                        else
                            state = COMPARE;
                    end
                end
                
                COMPARE: begin
                    if ( fail_count < 3 ) begin
                        if ( inp == pwd ) begin
                            state <= UNLOCKED;
                         end
                         else begin
                            fail_count <= fail_count + 1;
                            count <= 0;
                            inp <= 32'b0;
                            state <= CHECKDIGIT;
                        end
                    end
                    else begin
                            state <= PERMLOCK; 
                    end
                end
                
                UNLOCKED: begin
                    state <= UNLOCKED;
                    count <=8;
                    if(new==1'b1) begin
                        state <= CHECKDIGIT;
                        change <= 1'b1;
                        fail_count <= 0;
                        count <= 0;
                        inp <= 32'b0;
                    end
                    if(lock==1'b1) begin
                        state <= CHECKDIGIT;
                        fail_count <= 0;
                        count <= 0;
                        inp <= 32'b0;
                    end
                    
                end
                
                PERMLOCK: begin
                    state <= PERMLOCK;
                end
            endcase
        end
//    end
end


//vio_0 vio(clk, state, inp,count);
endmodule
