//-------------------------------------------------------------------------------
//  FEUP / MEEC - Digital Systems Design 2023/2024
// 
// Complex number divider
//-------------------------------------------------------------------------------

//Francisco Bessa Lopes Câmara - 202006727
//Francisco Gonçalves Vilarinho - 202005500

`timescale 1ns/100ps

module cpxdiv2(
         input        clock,
         input        reset,
         input        run,
         input [15:0] ReA,
         input [15:0] ImA,
         input [15:0] ReB,
         input [15:0] ImB,
         output[31:0] ReY,
         output[31:0] ImY,
         output       busy
             );



// ADD YOUR CODE HERE; DO NOT MODIFY THE INPUT/OUTPUT PORT NAMES
	reg [6:0] i;
	reg bsy;
	reg rundiv;
	reg [32-1:0] out1;
	reg [32-1:0] out2;
	wire [32-1:0] quo;


	reg signed [32-1:0] divd;
	reg signed[16-1:0] c2d2;

	reg signed[16-1:0] multA;
	reg signed[16-1:0] multB;
	wire signed[32-1:0] multC;
		
	reg [32-1:0] sumA;
	reg [32-1:0] sumB;
	wire [32-1:0] sumC;

// DIVIDE MODULE //////
psddivide_top psddivide_top1(
               .clock(clock),
				   .reset(reset),
				   .run(rundiv),
				   .busy(),
				   .dividend(divd),
				   .divisor(c2d2),
				   .quotient(quo),
				   .rest()
				     );


assign busy = bsy;	//busy wire connected to the bsy reg
assign ReY = out1;
assign ImY = out2;
//COMBINATIONAL MULTIPLIER
assign #7 multC = multA * multB;				
	
//COMBINATIONAL SUM OPERATION
assign #2 sumC = sumA + sumB;

always @(posedge clock)
begin
	if(reset == 1) begin	//set all registers to 0 when reset is 1
		i <= 0;

		rundiv <= 0;

		bsy <= 0;
	end

///////////////////////////////////////----------------------------STATE MACHINE-------------------------///////////////////////////////////////////////////
	
	if(run) begin		//output busy is 1 when run is 1
		bsy <= 1;
	end

	//STATE MACHINE COUNTER
	if(busy == 1)
		i <= i+1;	//only starts when busy == 1

	
///////////////////////////////////////----------------------------MULTIPLICATION-------------------------/////////////////////////////////////////////////

	//multiplication is only captured 2 clock cycles after its start in order to enable the circuit o run at 200MHz

	if (i == 1) begin	//a*c
		multA <= ReA; 	
		multB <= ReB;
	end

	if(i == 3)		
		sumA <= multC;	//capture ac
	
	if (i == 3) begin	//d*b
		multA <= ImB;
		multB <= ImA;
	end

	if(i == 5)
		sumB <= multC;	//capture db				

	if (i == 5) begin	//c²					//	a + jb	     a*c + d*b     b*c - a*d
		multA <= ReB;						//	------  ==  ----------- + -----------
		multB <= ReB;						//	c + jd	      c² + d²  	    c² + d²							
	end

	if(i == 7)
		sumA <= multC;	//capture c2

	if (i == 7)begin	//d²
		multA <= ImB;
		multB <= ImB;
	end

	if(i == 9)
		sumB <= multC;	//capture d2

	if (i == 9)begin	//-a*d
		multA <= -ReA;
		multB <= ImB;
	end

	if(i == 11)
		sumA <= multC;	//capture -ad
	
	if (i == 11)begin	//b*c
		multA <= ImA;
		multB <= ReB;
	end

	if(i == 13)
		sumB <= multC;	//capture bc

///////////////////////////////////////----------------------------SUM-------------------------///////////////////////////////////////////////////////////
	
	//given that sums can run at over 200MHz, it is only needed 1 clock cycle to have the result ready
	
	/*if (i == 6) begin	//ac + db
		sumA <= ac;
		sumB <= db;
	end*/

	if(i == 7)
		divd <= sumC;	//capture ac + db		//	a + jb	     a*c + d*b     b*c - a*d
												//	------  ==  ----------- + -----------
												//	c + jd	      c² + d²  	    c² + d²

	if(i == 11)
		c2d2 <= sumC[31:16];	//capture integer part (16 most significant bits) (16 most significant bits)of c² + d²


//////////////////////////////////////---------------------------DIVIDE-----------------------////////////////////////////////////////////////////////////

	//in order to have divisor run correctly rundiv has to be 1 for 1 clock cycle	

	//division 1

	if(i == 12)
		rundiv <= 1;	

	if(i == 13)
		rundiv <= 0;

	if(i == 47)
		out1 <= quo;	//put in rey the result from the 1st division

	//start division 2
	if(i == 15)
		divd <= sumC;	//dividend of divison is bc + (-ad)

	if(i == 49)
		rundiv <= 1;

	if(i == 50)
		rundiv <= 0;

	if(i == 84)
		out2 <= quo;
	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//set busy to 0 => opperation finished
	if (i == 85)	
		bsy <= 0;		

end
endmodule
