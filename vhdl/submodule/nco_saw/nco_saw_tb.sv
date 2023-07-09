`timescale 1ns / 1ps

module nco_saw_tb;
  parameter WAVE_SQ = 8 ;


  logic clk = 0;

  logic nxt = 1;

  wire [WAVE_SQ-1:0] wave;


  nco_saw #(
    .N (WAVE_SQ)
  ) dut (
    .clk (clk),
    .next (nxt),
    .wave (wave)
  );


  always_latch clk <= #1 ~clk;

  initial begin
  $dumpfile("out.vcd");
	$dumpvars(0,nco_saw_tb);
  end


  initial begin
    repeat (100) @ (posedge clk);
    nxt <= 1;
  end

endmodule
