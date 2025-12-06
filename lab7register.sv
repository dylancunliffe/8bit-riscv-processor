module lab7register ( input logic [9:0] SW,
							 input logic [1:0] KEY,
							 input logic MAX10_CLK1_50,
							 output logic [7:0] HEX0,
							 output logic [7:0] HEX1,
							 output logic [7:0] HEX2,
							 output logic [7:0] HEX3,
							 output logic [7:0] HEX4,
							 output logic [7:0] HEX5
							 );
							 
		logic clk, writeEnable, reset;
		logic [7:0] dataA, dataB, dataW;
		logic [7:0] R0, R1, R2, R3; // 8 bit registers to hold values
		assign clk = MAX10_CLK1_50; 
		assign writeEnable = ~KEY[1]; // active high button signal to write to registers
		assign reset = ~KEY[0]; // active high button signal to reset all registers 
		
		logic [1:0] selA, selB, selW;
		assign selW = SW[9:8]; // 2 switches to select which register to write to
		assign selA = SW[7:6]; // 2 switches to select which register to pull the value of a from
		assign selB = SW[5:4]; // 2 switches to select which register to pull the value of b from
		assign dataW = {4'b0000, SW[3:0]}; // 8 bit (4 bit for now) input signal that gets written on the registers
		
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
			else if (writeEnable) begin // write to registers on button press
				case (selW) // based on the register selected for writing
					2'b00: R0 <= dataW;
					2'b01: R1 <= dataW;
					2'b10: R2 <= dataW;
					2'b11: R3 <= dataW;
				endcase
			end
		end
			
		// sevensegs to display dataA
		sevenseg segment5 (.data(dataA[7:4]),
								 .blank(0),
								 .segments(HEX5));
		sevenseg segment4 (.data(dataA[3:0]),
								 .blank(0),
								 .segments(HEX4));
		
		// instantiate 3 and 2 as blank
		sevenseg segment3 (.data(),
								 .blank(1),
								 .segments(HEX3));
		sevenseg segment2 (.data(),
								 .blank(1),
								 .segments(HEX2));
		
		// sevensegs to display dataB
		sevenseg segment1 (.data(dataB[7:4]),
								 .blank(0),
								 .segments(HEX1));
		sevenseg segment0 (.data(dataB[3:0]),
								 .blank(0),
								 .segments(HEX0));
			
endmodule

module sevenseg (
    input  logic [3:0] data,     // 4-bit input
	 input  logic blank,
    output logic [7:0] segments  // 7-seg outputs
);
    // segment order: {a, b, c, d, e, f, g}
    // 0 = segment on, 1 = segment off
    always_comb begin
		if (blank) begin
			segments = 8'b11111111;
		end
		else begin
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
	end
endmodule
	