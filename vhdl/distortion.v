module distortion #(
    parameter WIDTH=32//float size
)(
    input wire rst_n,
    input wire clk,
    input wire [WIDTH-1:0] IN,
    output reg [WIDTH-1:0] OUT
);

reg [WIDTH-1:0] in;

//Input flip-flop
always @(posedge clk, negedge rst_n) begin
    in <= (!rst_n) ? {(WIDTH){1'b0}} : IN;
end

wire [WIDTH-1:0] out;

assign out = in;

//output flip-flop
always @(posedge clk, negedge rst_n) begin
    OUT <= (!rst_n) ? {(WIDTH){1'b0}} : out;
end

endmodule
