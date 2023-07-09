module fir ( clk, coefs, in, out );

parameter IWIDTH = 16;	//input data (signal) width
parameter CWIDTH = 16;	//tap coef data width (should be less then 32 bit)
parameter TAPS   = 2;	//number of filter taps
localparam MWIDTH = (IWIDTH+CWIDTH); //multiplied width
localparam RWIDTH = (MWIDTH+TAPS-1); //filter result width

input  wire clk;
input  wire [IWIDTH-1:0]in;
input  wire [TAPS*32-1:0]coefs; //all input coefficient concatineted
output wire [RWIDTH-1:0]out; //output takes only top bits part of result

genvar i;
generate
	for( i=0; i<TAPS; i=i+1 )
	begin:tap
		//make tap register chain
		reg [IWIDTH-1:0]r=0;
		if(i==0)
		begin
			//1st tap takes signal from input
			always @(posedge clk)
				r <= in;
		end
		else
		begin
			//tap reg takes signal from prev tap reg
			always @(posedge clk)
				tap[i].r <= tap[i-1].r;
		end

		//get tap multiplication constant coef
		wire [CWIDTH-1:0]c;
		assign c = coefs[((TAPS-1-i)*32+CWIDTH-1):(TAPS-1-i)*32];

		//calculate multiplication and fix result in register
		reg [MWIDTH-1:0]m;
		always @(posedge clk)
			m <= $signed(r) * $signed( c );
			
		//make combinatorial adders
		reg [MWIDTH-1+i:0]a;
		if(i==0)
		begin
			always @*
				tap[i].a = $signed(tap[i].m);
		end
		else
		begin
			always @*
				tap[i].a = $signed(tap[i].m)+$signed(tap[i-1].a);
		end
	end
endgenerate

//fix calculated taps summa in register
reg [RWIDTH-1:0]result;
always @(posedge clk)
	result <= tap[TAPS-1].a;

//deliver output
assign out = result;

endmodule

/*
fir #( .TAPS(27) ) fir_lp_inst(
  .clk(tb_clk),
  .coefs( {
    -32'd510,
    -32'd520,
    .......
     32'd575,
     32'd625,
    -32'd520,
    -32'd510
    } ),
  .in(),
  .out()
);
*/
