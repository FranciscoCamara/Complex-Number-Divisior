//-------------------------------------------------------------------------------
//  FEUP / MEEC - Digital Systems Design 2023/2024
//
// Sequential 32 / 16 bit divider (signed dividend, unsigned divisor)
//
//  This is the controller for the sequential divider
//
//	This Verilog code is property of University of Porto
//	Its utilization beyond the scope of the course Digital Systems Design
//	(Projeto de Sistemas Digitais) of the Master in Electrical 
//	and Computer Engineering requires explicit authorization from the author.
//	
//	jca@fe.up.pt, Oct 2017 - 2023
//
//-------------------------------------------------------------------------------

// The controller for the sequential divider
//
//-----

module psddivide_ctrl
   (
	input         clock,		//master clock
	input         reset,		//synch reset, active high
    input         run,          //set to 1 during one clock to start a division
	output        start,		//start a new division
	output        stop,			//load output registers
	output        busy          //divider is busy not accepting new divisions
	); 


//-------------------------------------------------------------
// Finite state machine:
reg       state;
reg [5:0] counter;

// State encoding:
parameter IDLE = 0,
          RUN  = 1;

always @(posedge clock)
begin
  if ( reset )  // Synchronous reset, active high
  begin
    state <= IDLE;
	counter <= 6'd0;
  end
  else
  begin
    case ( state )
	  IDLE: if ( run )
	        begin
			  state <= RUN;
			  counter <= 6'd1;  // this is the start value show in the timing diagram
			end
	  RUN:  if ( counter == 6'd33 )  // last clock cycle
	        begin
			  counter <= 6'd0;
			  state <= IDLE;
			end
			else
			begin
			  counter <= counter + 1; // Keep in this state
			end
	endcase
  end
end

// Combinational outputs:
assign start = run;
assign busy = ( counter >= 6'd1 && counter <= 6'd33 );
assign stop = ( counter == 6'd33 );
endmodule
