module distortion #(
    parameter WIDTH=16//INT16 size
)(
    input wire rst_n,
    input wire clk,
    input wire [WIDTH-1:0] IN,
    output reg [WIDTH-1:0] OUT
);
/* verilator lint_off UNUSEDSIGNAL */
reg [WIDTH-1:0] in;
/* verilator lint_on UNUSEDSIGNAL */

//Input flip-flop
always @(posedge clk, negedge rst_n) begin
    in <= (!rst_n) ? {(WIDTH){1'b0}} : IN;
end

wire [WIDTH-1:0] out;


assign out = {in[15],in[14:0]}; //In => Out

//assign out = {in[15],in[15:1]}; //Val -

//Dummy distortion
//assign out = {in[15],1'b0 ,in[13:0]};


//output flip-flop
always @(posedge clk, negedge rst_n) begin
    OUT <= (!rst_n) ? {(WIDTH){1'b0}} : out;
end

endmodule
