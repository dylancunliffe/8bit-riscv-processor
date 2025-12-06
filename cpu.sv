module lab7cpu (input logic [9:0] SW,
					 input logic [1:0] KEY,
					 output logic [9:0] LEDR,
					 output logic [7:0] HEX0,
					 output logic [7:0] HEX1,
					 output logic [7:0] HEX2,
					 output logic [7:0] HEX3,
					 output logic [7:0] HEX4,
					 output logic [7:0] HEX5
					 );
					 
					 
		logic [1:0] selA, selB, aluOp, selR;
		logic writeEnable, Imm;
		logic clk, reset;
		
		logic [7:0] dataA, dataB, immValue, aluOutput, result;
		logic [7:0] outReg;
		logic [6:0] addr;
		logic [7:0] mem [0:127];
		
		assign writeEnable = SW[9];
		assign selA = SW[8:7];
		assign selB = SW[6:5];
		assign aluOp = SW[4:3];
		assign Imm = SW[2];
		assign selR = SW[1:0];
		assign clk = ~KEY[1];
		assign reset = ~KEY[0];
		
		assign addr = dataB[6:0];
		assign dataR = mem[addr];	
		
		always_comb begin
			if(Imm)
				immValue = 8'b1111_1111;
			else
				immValue = 8'b0000_0001;
							
			case (selR)
				2'b00: result = dataR;
				2'b01: result = aluOutput;
				2'b10: result = dataB;
				2'b11: result = immValue;
			endcase
			
		end
		
		always_ff @(posedge clk) begin
			if(reset)
				outReg <= 8'b0;
			else if(~writeEnable && dataB[7]) 
				outReg <= dataA;
		
			if(~writeEnable && ~dataB[7]) 
				mem[addr] <= dataA;
		end
		
		// instantiate alu module
		alu alu1 (.aluOp(aluOp),
						 .dataA(dataA),
						 .dataB(dataB),
						 .LEDR(LEDR[5:0]),
						 .result(aluOutput));
		
		register reg1 (.writeEnable(writeEnable),
							.selA(selA),
							.selB(selB),
							.dataW(result),
							.clk(clk),
							.reset(reset),
							.dataA(dataA),
							.dataB(dataB));
							
		sevenseg seg0 (.data(result[3:0]),
						   .segments(HEX0));
							
		sevenseg seg1 (.data(result[7:4]),
						   .segments(HEX1));
							
		sevenseg seg2 (.data(outReg[3:0]),
						   .segments(HEX2));
							
		sevenseg seg3 (.data(outReg[7:4]),
						   .segments(HEX3));
							
		sevenseg seg4 (.data(dataA[3:0]),
						   .segments(HEX4));
							
		sevenseg seg5 (.data(dataA[7:4]),
						   .segments(HEX5));
							
endmodule
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module alu ( input logic  [1:0] aluOp,
				 input logic  [7:0] dataA,
				 input logic  [7:0] dataB,
				 output logic [9:0] LEDR,
				 output logic [7:0] result
				);
	
	logic [7:0] a, b, r;
	
	assign a[7:0] = dataA[7:0];
	assign b[7:0] = dataB[7:0];
	assign r[7:0] = result[7:0];
	
	logic n, z, c, br, vp, vn; // z = negative, z = zero, c = carryout, b = borrow, vp = addition overflow, vn = subtraction overflow
	assign LEDR[5:0] = {z, n, vn, vp, br, c};
	
	always_comb begin
		// ALU operations
		if (aluOp == 2'b00) begin // AND 
			result[7:0] = a[7:0] + b[7:0]; 
		end else if (aluOp == 2'b01) begin // SUB 
			result[7:0] = a[7:0] - b[7:0];  
		end else if (aluOp == 2'b10) begin // ADD 
			result[7:0] = a[7:0] * b[7:0]; 
		end else if (aluOp == 2'b11) begin // MUL 
			result[7:0] = a[7:0] & b[7:0]; end 
		else begin 
			result[7:0] = 8'b00000000; 
		end
		
		// condition code logic
		c = (a[7] & b[7]) | (a[7] & ~r[7]) | (b[7] & ~r[7]);
		br = (~a[7] & b[7]) | (b[7] & r[7]) | (~a[7] & r[7]);
		vp = (~a[7] & ~b[7] & r[7]) | (a[7] & b[7] & ~r[7]);
		vn = (a[7] & ~b[7] & ~r[7]) | (~a[7] & b[7] & r[7]);
		n = r[7];
		z = ~r[7] & ~r[6] & ~r[5] & ~r[4] & ~r[3] & ~r[2] & ~r[1] & ~r[0];
	end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module register ( input logic writeEnable,
						input logic [1:0] selA,
						input logic [1:0] selB,
						input logic [7:0] dataW,
						input logic clk,
						input logic reset,
						output logic [7:0] dataA,
						output logic [7:0] dataB
						);
							 
		logic [7:0] R0, R1, R2, R3; // 8 bit registers to hold values
		
		// output select combinational logic
		always_comb begin
			case (selA) // choosing which register to display in a
				2'b00: dataA = R0;
				2'b01: dataA = R1;
				2'b10: dataA = R2;
				2'b11: dataA = R3;
			endcase
		
			case (selB) // choosing which register to display in b
				2'b00: dataB = R0;
				2'b01: dataB = R1;
				2'b10: dataB = R2;
				2'b11: dataB = R3;
			endcase
		end
		
		// register ffs
		always_ff @(posedge clk) begin
			if (reset) begin // reset all registers on reset
				R0 <= 8'b0;
				R1 <= 8'b0;
				R2 <= 8'b0;
				R3 <= 8'b0;
			end
			else begin // write to registers on button press
				if(writeEnable) begin
					case (selA) // based on the register selected for writing
						2'b00: R0 <= dataW;
						2'b01: R1 <= dataW;
						2'b10: R2 <= dataW;
						2'b11: R3 <= dataW;
					endcase
				end
			end
		end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sevenseg (
    input  logic [3:0] data,     // 4-bit input
    output logic [7:0] segments  // 7-seg outputs
);
    // segment order: {a, b, c, d, e, f, g}
    // 0 = segment on, 1 = segment off
    always_comb begin
			  case (data)
				4'h0: segments = 8'b11000000; // 0
            4'h1: segments = 8'b11111001; // 1
            4'h2: segments = 8'b10100100; // 2
            4'h3: segments = 8'b10110000; // 3
            4'h4: segments = 8'b10011001; // 4
            4'h5: segments = 8'b10010010; // 5
            4'h6: segments = 8'b10000010; // 6
            4'h7: segments = 8'b11111000; // 7
            4'h8: segments = 8'b10000000; // 8
            4'h9: segments = 8'b10011000; // 9
            4'hA: segments = 8'b10001000; // A
            4'hB: segments = 8'b10000011; // b
            4'hC: segments = 8'b10100111; // C
            4'hD: segments = 8'b10100001; // d
            4'hE: segments = 8'b10000110; // E
            4'hF: segments = 8'b10001110; // F
				default: segments = 8'b11111111; // all off
			  endcase
       end
endmodule
	
	
