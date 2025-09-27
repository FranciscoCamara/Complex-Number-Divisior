// DDS testbench
`timescale 1ns/100ps

module  cpxdiv_tbmine;

parameter CLOCK_PERIOD    = 5; // ns
parameter MAX_SIM_TIME	  = 400; //ns

// Signals to connect to your cpxdiv module:
reg clock;
reg reset;
reg run;
reg [15:0] ReA;
reg [15:0] ImA;
reg [15:0] ReB;
reg [15:0] ImB;
wire [31:0] ReY;
wire [31:0] ImY;
wire busy;

// Instantiation of the module under verification:
cpxdiv cpxdiv(
           .clock( clock ),
	   	.reset( reset ),
		.run ( run ),
	   	.ReA ( ReA ),
	   	.ImA ( ImA ),
		.ReB ( ReB ),
		.ImB ( ImB ),
		.ReY ( ReY ),
		.ImY ( ImY ),
		.busy ( busy )
		   );
		    



// Initialize inputs, generate the clock:
initial
begin
	clock = 0;
	reset = 0;
	run = 0;
	ReA = 0;
	ImA = 0;
	ReB = 0;
	ImB = 0;
#20
	forever #(CLOCK_PERIOD / 2.0) clock = ~clock;
end

// Reset signal
initial
begin
	#20
	reset = 1;
	#(CLOCK_PERIOD * 2)
	reset = 0;
end	
//MAXIMUM SIMULATION TIME
initial
begin
  # ( MAX_SIM_TIME )
  $stop;
end
////////////////////////
initial
begin

#(CLOCK_PERIOD * 10)
execcpxdiv(-5.5*256.0, -9.3*256.0, 1*256.0, 0*256.0);

end
////////////
task execcpxdiv;
input [15:0] ReaA, ImgA, ReaB, ImgB;
begin
  ReA = ReaA;   // Apply operands
  ImA = ImgA;
  ReB = ReaB;
  ImB = ImgB;
  
  @(negedge clock);   // wait for the next negative edge of the clock
  run = 1'b1;       // Assert start
  @(negedge clock );
  run = 1'b0;  
  while ( busy == 1 ) @(negedge clock);	
  $stop;
end
endtask	
			
endmodule			
