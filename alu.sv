module lab7alu ( input [9:0] SW,
					  output [7:0] HEX0,
					  output [7:0] HEX1,
					  output [7:0] HEX2,
					  output [7:0] HEX3,
					  output [7:0] HEX4,
					  output [7:0] HEX5,
					  output [9:0] LEDR
					  );
					  
	logic [1:0] ALUop; // 2 bit input to control ALU operation
	assign ALUop[1:0] = SW[5:4];
	
	logic [3:0] inputA; // 4 bit input from switches 9-6
	logic [3:0] inputB; // 4 bit input from switches 3-0
	
	assign inputA[3:0] = SW[9:6];
	assign inputB[3:0] = SW[3:0];
	
	logic [7:0] a; // 8 bit sign extended value for A
	logic [7:0] b; // 8 bit sign extended value for B
	logic [7:0] r; // 8 bit result
	
	assign a[3:0] = inputA[3:0];
	assign b[3:0] = inputB[3:0];

	assign a[7:4] = {4{inputA[3]}};
	assign b[7:4] = {4{inputB[3]}};

	
	logic n, z, c, br, vp, vn; // z = negative, z = zero, c = carryout, b = borrow, vp = addition overflow, vn = subtraction overflow
	logic [3:0] seg5, seg4, seg3, seg2, seg1, seg0; // 4 bit hex values to send to the instantiated hex modules

	assign LEDR[5:0] = {z, n, vn, vp, br, c};
	
	always_comb begin
		// ALU operations
		if (ALUop == 2'b00) begin // AND 
			r[7:0] = a[7:0] & b[7:0]; 
		end else if (ALUop == 2'b01) begin // SUB 
			r[7:0] = a[7:0] - b[7:0];  
		end else if (ALUop == 2'b10) begin // ADD 
			r[7:0] = a[7:0] + b[7:0]; 
		end else if (ALUop == 2'b11) begin // MUL 
			r[7:0] = a[7:0] * b[7:0]; end 
		else begin 
			r[7:0] = 8'b00000000; 
		end
		
		// condition code logic
		c = (a[7] & b[7]) | (a[7] & ~r[7]) | (b[7] & ~r[7]);
		br = (~a[7] & b[7]) | (b[7] & r[7]) | (~a[7] & r[7]);
		vp = (~a[7] & ~b[7] & r[7]) | (a[7] & b[7] & ~r[7]);
		vn = (a[7] & ~b[7] & ~r[7]) | (~a[7] & b[7] & r[7]);
		n = r[7];
		z = ~r[7] & ~r[6] & ~r[5] & ~r[4] & ~r[3] & ~r[2] & ~r[1] & ~r[0];
		
		// hex readout		
		if(a[7] == 1) begin
			seg5 = 4'hF;
		end
		else seg5 = 4'h0;
		if(b[7] == 1) begin
			seg3 = 4'hF;
		end
		else seg3 = 4'h0;
		if(r[7] == 1) begin
			seg1 = 4'hF;
		end
		else seg1 = 4'h0;
		
		seg4 = a[3:0];
		seg2 = b[3:0];
		seg0 = r[3:0];
	end
	
	sevenseg segment5 (.data(seg5),
						.segments(HEX5));
	sevenseg segment4 (.data(seg4),
						.segments(HEX4));
	sevenseg segment3 (.data(seg3),
						.segments(HEX3));
	sevenseg segment2 (.data(seg2),
						.segments(HEX2));
	sevenseg segment1 (.data(seg1),
						.segments(HEX1));
	sevenseg segment0 (.data(seg0),
						.segments(HEX0));

endmodule

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
	
	
