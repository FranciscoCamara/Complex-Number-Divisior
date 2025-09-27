//-------------------------------------------------------------------------------
//  FEUP / MEEC - Digital Systems Design 2023/2024
// 
// Complex number divider
//-------------------------------------------------------------------------------


/*Project Report for PSD 2023/2024

Francisco Bessa Lopes Câmara - 202006727
Francisco Gonçalves Vilarinho - 202005500

----------------------------------------------------------------------------------------------Preliminary Analysis-------------------------------------------------------------------------------------------------

	a + jb	     a*c + d*b     b*c - a*d
	------  ==  ----------- + -----------
	c + jd	      c² + d²  	    c² + d²


For this project, we decided to design and test 3 circuits:
    • One using 1 combinational multiplier and 2 sequential dividers (cpxdiv1);
    • One using 1 combinational multiplier and 1 sequential divider (cpxdiv2);
    • And one using 2 sequential multipliers and 2 sequential dividers (cpxdiv3).
The first implementation was considered because the combinational multiplier had a similar size to 2 sequentials and had the advantage of needing only 1 clock cycle at 100MHz (or 2 at 200MHz) to complete the operation,
making the circuit faster without causing significant impacts on its area. We decided to use 2 sequential dividers because it was not possible to meet the requirements using a combinational divider.
We also chose to use 2 sequential dividers because there was theoretically enough space, increasing the operation speed.
Calculating the time required for the operation, there was the possibility of using only one sequential divider, compromising the speed of the operation a bit, but ensuring a larger margin in terms of circuit area. 
We decided to explore this option. It is important to note that for the circuit to function with these modules, it would be necessary to ensure a frequency of 200 MHz; otherwise, it would not meet the temporal constraint threshold.
As a last option, we chose to build a circuit that would use 2 sequential dividers and 2 sequential multipliers, as all constraints, in terms of area, time, and maximum frequency, would be ensured. 
This would be our safest circuit in case the others encountered problems.

We decided to use a clock frequency of 200 MHz, even in circuits using combinational multipliers.

The circuit we studied the most, tested, and improved was cpxdiv3.

----------------------------------------------------------------------------------------Datapath Design-----------------------------------------------------------------------------------------------------

          ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                                                                                                     │
          │                                                              ┌─────────┐                                         ┌───────────┐      │
          │                                                              │         │                                    ┌────┤           │      │
          │ ┌────────────────────────────────────────────────────────────┤         │                           ┌──────┐ │    │ psddivide │      │
          │ │                                                            │         │                           │divd1 ├─┘    │   _top1   ├──────┼─ ReY
          │ │                                                            │ psdmult │                    /|─────┤      │      │           │      │
          │ │     ┌────┐                                                 │  _top2  │                   / |     └──────┘      │           │      │
     ReA──┼─┼─┬───┤ -x ├─|\                 ┌────────────────────────────┤         │         ┌───┐    /  |              ┌────┤           │      │
          │ │ │   └────┘ | \                │                            │         ├─────────┤   │   | d |     ┌──────┐ │    └─────┬─────┘      │
          │ │ │          |m \               │                            │         │         │ + ├───| m |─────┤divd2 ├─┼─┐        │            │
     ReB──┼─┼─┼─┬────────|u  | ┌────┐       │                            └────┬────┘    ┌────┤   │   | u |     │      │ │ │        └────────┐   │
          │ │ │ │        |x  |─┤    ├───────┘                                 │         │    └───┘   | x |     └──────┘ │ │                 │   │
     ImA──┼─┼─┼─┼─┬──────|1  | │mult│                ┌─────────┐              │         │             \  |              │ │                 │   │
          │ │ │ │ │      |   | │ A2 │                │         │              │         │             │\ |   / ┌──────┐ │ │   ┌──────────┐  │   │
     ImB──┼─┴─┼─┼─┼─┬────|  /  └─┬──┘                │         │              │         │             │ \|──16─┤c2d2  │ │ └───┤          │  │   │
          │   │ │ │ │    | /│    │         ┌─────────┤ psdmult │              │         │             │    /   │      ├─┤     │psddivide │  │   │
          │   │ │ │ │    |/ │    └───────┐ │         │  _top1  │              │         │             │        └──────┘ │     │  _top2   ├──┼───┼─ ImY
          │   │ │ │ │       └┐           │ │  ┌──────┤         ├──────────────┼─────────┘             │                 │     │          │  │   │
          │   │ │ │ │ |\     │           │ │  │      │         │              │                       │                 └─────┤          │  │   │
          │   │ │ │ ├─| \    │           │ │  │      │         │              │                       │                       └────┬─────┘  │   │
          │   │ │ │ │ |m \   │ ┌────┐    │ │  │      └────┬────┘              │                       │                            │        │   │
          │   │ │ ├─┼─|u  |  │ │    │    │ │  │           │                   │                       │                            │        │   │
          │   │ │ │ │ |x  |──┼─┤mult├────┼─┘  │           │                   │                       │                            │        │   │
          │   │ ├─┼─┼─|2  |  │ │ A1 │    │    │           └───────────────┬───┘                       │                  ┌─────────┴────────┘   │
          │   │ │ │ │ |   |  │ └─┬──┘    │    │                           │                           │                  │                      │
          │   ├─┼─┼─┼─|  /   │   │       │    │                           │                           │                  │                      │
          │   │ │ │ │ | /─┐  │   │       │    │    |\                     │        |\                 │                  │                      │
          │   │ │ │ │ |/  │  │   └───────┤    │    | \                    │        | \                │                  │                      │
          │   │ │ │ │     │  │           │    │1 ──|m \   ┌────┐          │     1──|m \   ┌────┐      │                  │                      │
          │   │ │ │ │ |\  └─┬┘           │    │    |u  |  │ run│          │        |u  |  │run │      │                  │                      │
          │   │ │ │ └─| \   │            │    │    |x  |──┤mult├──────────┘        |x  ───┤div ├──────┼──────────────────┘                      │
          │   │ │ │   |m \  │  ┌────┐    │    │0 ──|4  |  │    │                   |5  |  │    │      │                                         │
          │   │ │ └───|u  | │  │    │    │    │    |   |  └┬──┬┘                0──|   |  └─┬─┬┘      │                                         │
          │   │ │     |x  |─┼──┤mult├────┼────┘    |  /    │  │                    |  /     │ │       │                                         │
          │   │ └─────|3  | │  │ B1 │    │         | /│    │  │                    | /│     │ │       │                                         │
          │   │       |   | │  └──┬─┘    │         |/ │    │  │                    |/ │     │ │       │                                         │
          │   └───────|  /  │     │      │            │    │  │                       │     │ │       │                                         │
          │           | /│  │     │      │            │    │  │                       │     │ │       │                                         │
          │           |/ │  │     │      │            │    ├──┼───────────────────────┼─────┘ │       │                                         │
          │              │  │     │      │            │    │  │                       │       │       │                                         │
          │ ┌─────────┐  │  │     │      │            │    │  ├───────────────────────┴───────┘       │                                         │
          │ │         │  │  │     │      │            │    │  │                                       │                                         │
          │ │┌─────┐  │  │  │     │      │            │    │  │                                       │                                         │
          │ ││     │ ┌┴┐ │  │     │      │            │    │  │                                       │                                         │
          │ └│	i  ├─┤+├─┴──┴─────┼──────┼────────────┼────┼──┼───────────────────────────────────────┘                                         │
          │  │     │ └─┘          │      │            │    │  │                                                                                 │
          │  └┬─┬──┘              │      │            │    │  │                                                                                 │
          │   │ │                 │      │            │    │  │                                                                                 │
          │   │ └─────────────────┼──────┼────────────┴────┼──┴───────────────┬──────────────────────────────────────────┐                      │
          │   │                   │      │                 │                  │                                          │                      │
          │   │                   │      │                 │                  │                                          │                      │
          │   │                   │      │                 │                  │                                          │                      │
          │   │                   │      │                 │                  │                    ┌────┐                │                      │
          │   │                   │      │                 │                  │               1────┤bsy │                │                      │
          │   │                   │      │                 │                  │                    │    ├────────────────┴──────┐               │
clock ────┼───┼───────────────────┴──────┘                 │                  │                    └┬─┬─┘                       │               │
          │   │                                            │                  │                     │ │                         │               │
reset ────┼───┴────────────────────────────────────────────┴──────────────────┴─────────────────────┘ │                         │               │
          │                                                                                           │                         └───────────────┼─ Busy
  run ────┼───────────────────────────────────────────────────────────────────────────────────────────┘                                         │
          │                                                                                                                                     │
          └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

-----------------------------------------------------------------------------------------------Controller Design---------------------------------------------------------------------------------------------------

                    ┌───────┬───────┬───────┬──────┬──────────────┬───────────────┐
                    │       │       │       │  i   │     Start    │   Operation   │
                    │  run  │ busy  │ reset │ state│   operation  │  control and  │
                    │       │       │       │      │              │ register load │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   0   │   1   │  0   │      x       │  control regs │
                    │       │       │       │      │              │    set to 0   │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   1   │   1   │   0   │  1   │  a*c &  b*d  │set multipliers│
                    │       │       │       │      │              │   run to 1    │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  2   │      x       │set multipliers│
                    │       │       │       │      │              │   run to 0    │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  20  │  b*c & -a*d  │set multipliers│
                    │       │       │       │      │              │   run to 1    │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  21  │      x       │set multipliers│
                    │       │       │       │      │              │   run to 0    │
                    │       │       │       │      │              │Load a*c + b*d │
                    │       │       │       │      │              │  as dividend1 │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  38  │  c^2 & d^2   │set multipliers│
                    │       │       │       │      │              │   run to 1    │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  39  │      x       │set multipliers│
                    │       │       │       │      │              │   run to 0    │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  40  │      x       │Load b*c - a*d │
                    │       │       │       │      │              │as the second  │
                    │       │       │       │      │              │    dividend   │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  58  │ac+bd   bc-ad │Load c^2+d^2 as│
                    │       │       │       │      │----- & ----- │ the divisor   │
                    │       │       │       │      │c2+d2   c2+d2 │Set division   │
                    │       │       │       │      │              │ run to 1      │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   1   │   0   │  59  │      x       │ Set division  │
                    │       │       │       │      │              │    run to 0   │
                    ├───────┼───────┼───────┼──────┼──────────────┼───────────────┤
                    │   0   │   0   │   0   │  93  │      x       │Set busy signal│
                    │       │       │       │      │              │to 0 (finished)│
                    └───────┴───────┴───────┴──────┴──────────────┴───────────────┘

-------------------------------------------------------------------------------Results of the functional verification-----------------------------------------------------------------------------------------

All circuits worked correctly with the provided testbench (with a 200MHz clock), as well as, with a simpler testebench developed by ourselves.
    • cpxdiv1
        Frequency: 200 MHz
        Clocks with active busy: 52
        Time with active busy: 260 ns
    • cpxdiv2
        Frequency: 200 MHz
        Clocks with active busy: 85
        Time with active busy: 425 ns
    • cpxdiv3
        Frequency: 200 MHz
        Clocks with active busy: 93
        Time with active busy: 465 ns

It can be concluded that all circuits operate within the required time to avoid penalties ( < 500ns).

----------------------------------------------------------------------------------------Synthesis Results---------------------------------------------------------------------------------------------------

After synthesizing the cpxdiv3 circuit, the following values for the number of LUTs and frequency were obtained:
    Optimization goal: Speed
        Optimization effort: High
            • LUTs: 894
            • Frequency: 219.276 MHz
        Optimization effort: Fast
            • LUTs: 864
            • Frequency: 161.208 MHz
        Optimization effort: Normal
            • LUTs: 864
            • Frequency: 197.522 MHz
    Optimization goal: Area
        Optimization effort: High
            • LUTs: 862
            • Frequency: 161.960 MHz
        Optimization effort: Fast
            • LUTs: 863
            • Frequency: 161.205 MHz
        Optimization effort: Normal
            • LUTs: 862
            • Frequency: 161.960 MHz
Given this, the chosen optimization was Speed/High.

For the remaining circuits, practically all possible optimizations did not change the number of LUTs or frequency significantly:
    • cpxdiv1
        -> LUTs: 924
        -> Frequency: 130.765 MHz
    • cpxdiv2:
        -> LUTs: 722
        -> Frequency: 130.756 MHz
In cpxdiv1, the number of LUTs slightly exceeds the maximum value for no project discounts (900 LUTs). 
In both cpxdiv1 and cpxdiv2, the synthesis frequency is lower than projected because, as explained earlier, the combinational multiplier limits this value, an expected result.

-----------------------------------------------------------------------------------Final Implementation Results---------------------------------------------------------------------------------------------

All circuits were tested in "Post-Translate" simulations with the provided testbench and function as intended.
Finally, all Verilog circuits were translated into programming files and ran on the FPGA, and after various inputs, no incorrect results were obtained.


*/


`timescale 1ns/100ps

module cpxdiv3(
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
	reg [7:0] i; 	//control register used to control the circuit by counting the number of clock cycles
	reg bsy; 	// Register used to assign the proper value to the busy output 
	reg rundiv; 	// Register used to start the division blocks
	reg runmult; 	// Register used to start the multiplication blocks

	reg signed [32-1:0] divd1; 	// Register used to store the dividend of the real part of the division
	reg signed [32-1:0] divd2;	// Register used to store the dividend of the imaginary part of the division
	reg signed[16-1:0] c2d2; 	//Register used to store the divisor 

	reg signed[16-1:0] multA1; 	// Register used to store a multiplier operand of the first module
	reg signed[16-1:0] multB1; 	// Register used to store a multiplier operand of the first module
	reg signed[16-1:0] multA2; 	// Register used to store the variable operand of the second module 
				   	// (there is no register for the second operand because it is always the same)
	
		
	wire [32-1:0] sumA;	// Wire connected to the output of the first multiplier (first operand of the sum)
	wire [32-1:0] sumB;	// Wire connected to the output of the second multiplier (second operand of the sum)
	wire [32-1:0] sumC;	// Wire connected to the output of the sum 

// DIVIDE MODULE //////
psddivide_top psddivide_top1(				
           .clock(clock),
				   .reset(reset),
				   .run(rundiv),	//Rundiv has to be 1 for a total of 1 clock cycle and 1 clock cycle only  	
				   .busy(),
				   .dividend(divd1),
				   .divisor(c2d2),
				   .quotient(ReY),	//ReY is the output of th real part of the final result
				   .rest()
				     );

psddivide_top psddivide_top2(
			 .clock(clock),
				   .reset(reset),
				   .run(rundiv),	//Rundiv has to be 1 for a total of 1 clock cycle and 1 clock cycle only  
				   .busy(),
				   .dividend(divd2),
				   .divisor(c2d2),
				   .quotient(ImY),	//ImY is the output of th imaginary part of the final result
				   .rest()
				     );
// MULTIPLICATION MODULE //////
psdmult_top psdmult_top1( 
	    	.clock(clock), 
				.reset(reset), 
				.run(runmult),   //Runmult has to be 1 for a total of 1 clock cycle and 1 clock cycle only  
				.busy(),   
				.A(multA1),       
				.B(multB1), 
				.P(sumA) 	//SumA wire is used as the output of the operation and as an input of the sum block     
				);

psdmult_top psdmult_top2( 
	    	.clock(clock), 
				.reset(reset), 
				.run(runmult),	//Runmult has to be 1 for a total of 1 clock cycle and 1 clock cycle only  
				.busy(),   
				.A(multA2),       
				.B(ImB), 	//ImB operand is constant and used in all operations of this module
				.P(sumB)        //SumB wire is used as the output of the operation and as an input of the sum block 
				); 


assign busy = bsy;	//busy wire connected to the bsy reg			
	
//COMBINATIONAL SUM OPERATION
assign #2 sumC = sumA + sumB;	//sumC outputs the sum of both operands

always @(posedge clock)
begin
	if(reset == 1) begin	//set all control registers to 0 when reset is 1
		i <= 0;

		runmult <= 0;	
		rundiv <= 0;

		bsy <= 0;
	end
///////////////////////////////////////----------------------------STATE MACHINE-------------------------///////////////////////////////////////////////////
	
	if(run) begin		//output busy is 1 when run is 1
		bsy <= 1;
	end

	//STATE MACHINE COUNTER
	if(busy == 1)
		i <= i+1;	//counter only starts when busy == 1

	
	if(i == 1) begin	//a*c , b*d	
		multA1 <= ReA;			
		multB1 <= ReB;		
		multA2 <= ImA;
		runmult<= 1;	// Start up multiplication modules
	end		

	if (i == 2)		
		runmult <= 0;	// Runmult has been 1 for the mandatory 1 clock cycle so we reset its value

	if(i == 20)begin	//b*c , -a*d	
		multA1 <= ReB;
		multB1 <= ImA;
		multA2 <= -ReA;
		runmult<= 1;	// Start up multiplication modules
	end

	if(i == 21)begin
		divd1 <= sumC;	//Store in divd1 the result of the sum (a*c + d*b)
		runmult<= 0;	// Runmult has been 1 for the mandatory 1 clock cycle so we reset its value		//	a + jb	     a*c + d*b     b*c - a*d
	end														//	------  ==  ----------- + -----------
															//	c + jd	      c² + d²  	    c² + d²
	if(i == 38)begin	//c² , d²			
		multA1 <= ReB;
		multB1 <= ReB;
		multA2 <= ImB;
		runmult<= 1;	// Start up multiplication modules
	end
	
	if(i == 39)begin
		runmult<= 0;	// Runmult has been 1 for the mandatory 1 clock cycle so we reset its value
	end
	
	if(i == 40)
		divd2 <= sumC;	//Store in divd2 the result of the sum (b*c + -a*d)

	
	if(i == 58)begin		//Start divisions divid1/c2d2 and divid2/c2d2
		c2d2 <= sumC[31:16];	//Store in c2d2 the value of the divisors (c2+d2)
		rundiv <= 1;		//Start up division modules
	end
	
	if(i == 59)
		rundiv <= 0;	//Rundiv has been 1 for the mandatory 1 clock cycle so we rest its value

	if(i == 93)begin
		bsy <= 0;	//All operations are finished so the busy signal has to be turned off
	end

end		
endmodule
