`timescale 1ns / 1ns

module testbench();

reg tb_clk;
initial tb_clk=0;
always
	#25 tb_clk = ~tb_clk;

real PI=3.14159265358979323846;
real last_time=0; //Sec
real current_time=0; //Sec
real angle=0;	//Rad
real frequency=100; //Hz
integer freq_x100kHz=0; //*100kHz
reg signed [15:0]sin16;

//function which calculates Sinus(x)
function real sin;
input x;
real x;
real x1,y,y2,y3,y5,y7,sum,sign;
 begin
  sign = 1.0;
  x1 = x;
  if (x1<0)
  begin
   x1 = -x1;
   sign = -1.0;
  end
  while (x1 > PI/2.0)
  begin
   x1 = x1 - PI;
   sign = -1.0*sign;
  end  
  y = x1*2/PI;
  y2 = y*y;
  y3 = y*y2;
  y5 = y3*y2;
  y7 = y5*y2;
  sum = 1.570794*y - 0.645962*y3 +
      0.079692*y5 - 0.004681712*y7;
  sin = sign*sum;
 end
endfunction

task set_freq;
input f;
real f;
begin
	frequency = f;
	freq_x100kHz = f/100000.0;
end
endtask

always @(posedge tb_clk)
begin
	current_time = $realtime;
	angle = angle+(current_time-last_time)*2*PI*frequency/1000000000.0;
	//$display("%f %f",current_time,angle);
	while ( angle > PI*2.0 )
	begin
		angle = angle-PI*2.0;
	end 
	sin16 = 32000*sin(angle);
	last_time = current_time;
end

//low-pass filter
wire [57:0]out_lowpass;
fir #( .TAPS(27) ) fir_lp_inst(
	.clk(tb_clk),
	.coefs( { 
		-32'd510,
		-32'd520,
		-32'd625,
		-32'd575,
		-32'd287,
		 32'd306,
		 32'd1232,
		 32'd2467,
		 32'd3927,
		 32'd5477,
		 32'd6948,
		 32'd8162,
		 32'd8962,
		 32'd9241,
		 32'd8962,
		 32'd8162,
		 32'd6948,
		 32'd5477,
		 32'd3927,
		 32'd2467,
		 32'd1232,
		 32'd306,
		-32'd287,
		-32'd575,
		-32'd625,
		-32'd520,
		-32'd510
		} ),
	.in(sin16),
	.out(out_lowpass)
	);

//band-pass
wire [55:0]out_bandpass;
fir #( .TAPS(25) ) fir_bp_inst(
	.clk(tb_clk),
	.coefs( { 
		-32'd801,
		-32'd1026,
		-32'd210,
		 32'd1914,
		 32'd4029,
		 32'd3905,
		 32'd330,
		-32'd5174,
		-32'd8760,
		-32'd7040,
		-32'd152,
		 32'd7700,
		 32'd11130,
		 32'd7700,
		-32'd152,
		-32'd7040,
		-32'd8760,
		-32'd5174,
		 32'd330,
		 32'd3905,
		 32'd4029,
		 32'd1914,
		-32'd210,
		-32'd1026,
		-32'd801
		} ),
	.in(sin16),
	.out(out_bandpass)
	);

integer i;
real f;

initial
begin
	$dumpfile("out.vcd");
	$dumpvars(0,testbench);
	f=100000;
	for(i=0; i<4000; i=i+1)
	begin
		set_freq(f);
		#1000;
		f=f+1000;
	end
	$finish;
end

endmodule