`timescale 1ns / 1ps

module nco_saw #(
  parameter int N = 8
) (
  input  wire          clk,
  input  wire          next,

  output logic [N-1:0] wave = '0
);


  logic dir = 0;

  always_ff @ (posedge clk) begin
    if (wave == {N{1'b1}} - 1)      dir <= 1;
    else if (wave == 1)             dir <= 0;
  end

  always_ff @ (posedge clk) begin
      wave <= (dir) ? wave - next : wave + next;
  end

endmodule
