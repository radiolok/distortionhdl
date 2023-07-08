`timescale 1ns / 1ps

/*
inst example: 
hard_clip #( .DATA_WIDTH(16) ) hard_clip_inst(
	.clk(clk),
	.data_i(in),
	.gain(6'd2),
	.data_o(out)
	);
  */

module hard_clip #(
  parameter int DATA_WIDTH = 16,
  parameter int CLIP_LEVEL  = 1000
) (
  input  wire                   clk,

  input wire [5:0] gain,
  input  wire  [DATA_WIDTH-1:0] data_i,
  output logic [DATA_WIDTH-1:0] data_o
);


  localparam STAGES = 3; //TODO GENERATE 


  logic signed [DATA_WIDTH-1:0] data_pipe [STAGES]; // = '{default:'0}; --not supported in g2012 


  always_ff @ (posedge clk) begin
     begin
      data_pipe[0] <= data_i;
      data_pipe[1] <= data_pipe[0] * gain; //in * GAIN

      if (data_pipe[1] > CLIP_LEVEL)
        data_pipe[2] <= CLIP_LEVEL;
      else if (data_pipe[1] < -1*CLIP_LEVEL)
        data_pipe[2] <= -1*CLIP_LEVEL;
      else
        data_pipe[2] <= data_pipe[1];
    end
  end

  always_comb data_o = data_pipe[STAGES-1];


endmodule
