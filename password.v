// TOP OF THE DESIGN

module password
 (input  clk,       // Main Clock 
  // Switch Input (Used to reset the internal state machine)
  input reset,
  input lock,
  inout [7:0] JA,
  input new,
  // LED Outputs
  output [3:0] decode,
  output unlocked,
  output locked,
  output permlocked,
  //oled interface
  output oled_spi_clk,
  output oled_spi_data,
  output oled_vdd,
  output oled_vbat,
  output oled_reset_n,
  output oled_dc_n);

reg [3:0] digit;
reg data_valid;
wire [3:0] Decoder_out;

wire [63:0] inp;
wire [3:0] count;

reg [511:0] text;


always @(posedge clk)
begin
  digit <= Decoder_out;

  if (digit != Decoder_out)
  begin
    data_valid <= 1'b1;
  end
  else 
  begin
    data_valid <= 1'b0;
  end

end


// Decoder communicates with the KEYPAD to pull in decoded digit
Keypad keypad1
 (.clk(clk),
  .Row(JA[7:4]),   // input
  .Col(JA[3:0]),   // output
  .DecodeOut(Decoder_out));


StateMachine sm1(clk,reset,data_valid,digit,lock,unlocked,locked, inp, count, permlocked,new);
  
assign decode = digit;
integer i;

always @(count) begin
    text = {{(64){8'd32}}};
    for ( i = 0; i < count; i = i+1) begin
//    for ( i = 7; i >= 7-count; i = i-1) begin
        text[(i+1)*8-1-:8] = {4'b0011, inp[(i+1)*4-1-:4]};
//        text[(16-i)*8-1-:8] = {4'b0011, inp[(7-i)*4-1-:4]};
    end
end

top_oled oled(clk, data_valid, text, oled_spi_clk, oled_spi_data, oled_vdd, oled_vbat, oled_reset_n, oled_dc_n);
endmodule