//-------------------------------------------------------------------------------
//  FEUP / MEEC - Digital Systems Design 2023/2024
//
// Sequential 16 x 16 bit signed multiplier - toplevel: datapath + controller
//
//	This Verilog code is property of University of Porto
//	Its utilization beyond the scope of the course Digital Systems Design
//	(Projeto de Sistemas Digitais) of the Master in Electrical 
//	and Computer Engineering requires explicit authorization from the author.
//	
//	jca@fe.up.pt, Oct 2017 - 2023
//
//-------------------------------------------------------------------------------

`timescale 1ns/1ns

module psdmult_top (
                   input          clock,
				   input          reset,
				   input          run,
				   output         busy,
				   input  [15:0]   A,
				   input  [15:0]   B,
				   output [31:0]   P
				     );
				   
// Internal wires:
wire start, stop;

// Instantiate the divider datapath:
psdmult
       psdmult_1
      ( 
	    .clock( clock ), // master clock, active in the positive edge
        .reset( reset ), // master reset, synchronous and active high
		
        .start( start ), // set to 1 during one clock cycle to start a division
        .stop( stop ),   // set to 1 during one clock cycle to load the output registers
		
        .A( A ),  // the operands
        .B( B ), 
		
        .P( P )  // the results
        
		); 
      
// Instantiate the controller:
psdmult_ctrl
        psdmult_ctrl_1
		(
	      .clock( clock ), // master clock, active in the positive edge
          .reset( reset ), // master reset, synchronous and active high
		
		  .run( run ),     // set to 1 during one clock cycle to start a multiplication
          .start( start ), // set to 1 during one clock cycle to start a multiplication
          .stop( stop ),   // set to 1 during one clock cycle to load the output registers
          .busy( busy )
		);
		
endmodule
			   
