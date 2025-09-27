/* 
PSD 2023/2024

Assessment project 1 - Design and verification of a sequential multipler

	This Verilog code is property of University of Porto
	Its utilization beyond the scope of the course Digital Systems Design
	(Projeto de Sistemas Digitais) of the Master in Electrical 
	and Computer Engineering requires explicit authorization from the author.
	
	jca@fe.up.pt, Oct 2023
	
*/
`timescale 1ns / 1ns

module psddiv_tb;
 
// general parameters 
parameter CLOCK_PERIOD = 10;                // Clock period in ns
parameter MAX_SIM_TIME = 1_000_000_000;     // Set the maximum simulation time (time units=ns)
parameter N_RAND_DIV  = 100_000;
 
// Registers for driving the inputs:
reg  clock, reset;
reg  run;
wire busy;
reg  [31:0] A, B;

// Wires to connect to the outputs:
wire [31:0] Q;
wire [15:0] R;


// Instantiate the module under verification:
psddivide_top psddivide_1
      ( 
	    .clock(clock), // master clock, active in the positive edge
        .reset(reset), // master reset, synchronous and active high
		
        .run(run),     // set to 1 during one clock cycle to start a sqrt
        .busy(busy),   // set to 1 during one clock cycle to load the output registers
		
        .dividend( A ),      // the operand A
        .divisor( B[15:0] ), // the operand B
        .quotient( Q ),      // The result Q = A / B
        .rest( R )           // The result R = A % B
        ); 

// UNCOMMENT THIS INITIAL PROCESS
// IF USING IVERILOG
//initial
//begin
//  $dumpfile("mysimdata.vcd");
//  $dumpvars(0, psddiv_tb );
//end	 
        
//---------------------------------------------------
// Setup initial signals
initial
begin
  clock = 1'b0;
  reset = 1'b0;
  A = 0;
  B = 0;
  run = 1'b0;
end

//---------------------------------------------------
// generate a 50% duty-cycle clock signal
initial
begin  
  forever
    # (CLOCK_PERIOD / 2 ) clock = ~clock;
end

//---------------------------------------------------
// Apply the initial reset for 2 clock cycles:
initial
begin
  # (CLOCK_PERIOD/3) // wait a fraction of the clock period to 
                     // misalign the reset pulse with the clock edges:
  reset = 1;
  # (2 * CLOCK_PERIOD ) // apply the reset for 2 clock periods
  reset = 0;
end

//---------------------------------------------------
// Set the maximum simulation time:
initial
begin
  # ( MAX_SIM_TIME )
  $stop;
end



//---------------------------------------------------
// The verifications:
integer errors;
integer grade;
integer i;

integer errval0, errval1, errval2, errval3;


initial
begin
  // Initialize error counter and grade
  grade = 0;
  errors = 0;
  
  #( 100*CLOCK_PERIOD );
  
  // Verify master synchronous reset:
  $write("-----------------------------------------------------------------\n");
  $write("Functional verification of psddiv              Pass/Fail     Grade\n" );
  
  //-------------------------------------------------------------------------
  $write("1 - Check a single operation, random operand:   " );
  
  execdiv( 1000, 10 );
  // $stop;

  execdiv( -1000, 10 );
  execdiv( -542656, 728 );
  execdiv( 542445, 100 );
  execdiv( -10022112, 273 );
  //$stop;
  
  execdiv( $random, $random & 32'h0000_7FFF ); // Divisor must be 16-bit positive only !
  if ( errors > 0 )
    $write("      Fail    %3d (%d errors)\n", grade, errors );
  else
  begin
    grade = grade + 40;
    $write(" Pass         %3d\n", grade );
  end

  // $stop;
  
  //-------------------------------------------------------------------------
  $write("2 - Check the outputs after applying reset :    " );
  @(posedge clock)
  #3
  reset = 1;
  # (1 * CLOCK_PERIOD ) // pulse reset for 1 clock period
  reset = 0;
  
  if ( Q !== 0 && R !== 0 )
    $write("      Fail    %3d\n", grade );
  else
  begin
    grade = grade + 10;
    $write(" Pass         %3d\n", grade );
  end
  
  // Execute another operation with a known input to gen a non-zero result
  //-------------------------------------------------------------------------
  $write("3 - Check the outputs after a non-synch reset:  " );
  execdiv( 132345, 5678 );
  @(posedge clock)
  #2
  reset = 1;
  #4          // pulse reset for less than 1 clock period
  reset = 0;
  
  // This pulse on reset should not set the output to zero
  if ( Q === 0 || R === 0)
    $write("      Fail    %3d\n", grade );
  else
  begin
    grade = grade + 20;
    $write(" Pass         %3d\n", grade );
  end

  //-------------------------------------------------------------------------
  $write("4 - Check %9d random divisions      ", N_RAND_DIV );
  #( 10*CLOCK_PERIOD );
  // Verify N_RAND_DIV random division:
  errors = 0;
  for(i=0; i<N_RAND_DIV; i=i+1)
  begin
    # ( 2*CLOCK_PERIOD )
    execdiv( $random, $random & 32'h0000_7FFF );
  end

  if ( errors > 0 )
    $write("      Fail    %3d (%d errors)\n", grade, errors );
  else
  begin
    grade = grade + 20;
    $write(" Pass         %3d\n", grade );
  end
  
  #( 10*CLOCK_PERIOD );
  // Verify some corner cases
  //-------------------------------------------------------------------------
  $write("5 - Check operands with extreme values:         " );
  errors = 0;
  execdiv( 32'h00000000, 16'd12345678 );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'd12345678, 16'h00000000 );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'h00000001, 16'hffffffff );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'hffffffff, 16'h00000001 );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'hffffffff, 16'd12345678 );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'hffffffff, 16'hffffffff );
  # ( 2*CLOCK_PERIOD )
  execdiv( 32'd98765432, 16'hffffffff );
  
  # ( 2*CLOCK_PERIOD )
  if ( errors > 0 )
    $write("      Fail    %3d ((%d errors)\n", grade, errors );
  else
  begin
    grade = grade + 10;
    $write(" Pass         %3d\n", grade );
  end


  //-------------------------------------------------------------------------    
  $write("Final grade:                                    " );
  $write("              %3d\n", grade );

  $write("-----------------------------------------------------------------\n");
  			
 
  #1000
  $stop;
end

  
 


//---------------------------------------------------
// Simulate the controller to perform a division.
task execdiv;
input [31:0] Ain;
input [15:0] Bin;
begin
  A = Ain;   // Apply operands
  B = Bin;
  @(negedge clock);
  run = 1'b1;       // Assert start
  repeat (1)
    @(negedge clock );
  run = 1'b0;
  @(negedge busy);

  @(negedge clock );
  
  //	  $write("\n%d / %d = %d  rest: %d", $signed(Ain), Bin[15:0], $signed(Q), R );

  // Check results
  if ( $signed(Q) !== $signed( $signed(Ain) / $signed(Bin[15:0]) ) ) // || R !== $signed(Ain) % Bin[15:0] )
  begin
    if ( Bin[15:0] != 0 )
    begin
      errors = errors + 1;
      $write("\nERROR: %d / %d = %d  rest: %d", $signed(Ain), Bin[15:0], $signed(Q), R );
    end
    else
      $write("\nDivision by zero! Ignoring result");
  end
  end  
endtask


endmodule
			   
