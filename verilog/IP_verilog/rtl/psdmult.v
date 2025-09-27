//-------------------------------------------------------------------------------
//  FEUP / MEEC - Digital Systems Design 2023/2024
//
// Sequential 16 x 16 bit signed multiplier
//
//	This Verilog code is property of University of Porto
//	Its utilization beyond the scope of the course Digital Systems Design
//	(Projeto de Sistemas Digitais) of the Master in Electrical 
//	and Computer Engineering requires explicit authorization from the author.
//	
//	jca@fe.up.pt, Oct 2017 - 2023
//
//-------------------------------------------------------------------------------

module psdmult(
			input clock,           // master clock, active on the posedge
			input reset,           // synch reset, active high
			input start,           // set high for one clock to start a new sqrt
			input stop,	           // set high for one clock load output register
			input      [15:0] A,   // Operand A, unsigned
			input      [15:0] B,   // Operand B, unsigned
			output     [31:0] P    // result P = A * B, unsigned
				);


reg [15:0] Areg;
reg [31:0] accprod;
reg [31:0] Preg;

// Sign fo result:
reg        Psign;

wire [16:0] pprod;
wire [15:0] AandLSB;

wire [15:0] muxH, muxL;

assign AandLSB = {16{accprod[0]}} & Areg;
assign pprod   = accprod[31:16] + AandLSB;
assign muxH    = start ? 16'h0 : pprod[16:1];
assign muxL    = start ? ( B[15] ? -B : B ) : { pprod[0], accprod[15:1]};

always @(posedge clock )
begin
  if ( reset )
  begin
    Areg <= 16'd0;
	accprod <= 32'd0;
	Preg <= 32'd0;
  end
  else
  begin
    if ( start )
	begin
	  Areg <= A[15] ? -A : A;
	  Psign <= A[15] ^ B[15];
	end
	  
	if ( stop )
	  Preg <= Psign ? -accprod : accprod;
	  
	accprod <= { muxH, muxL };
  end
end

assign P = Preg;

endmodule



