module modulo(
	input logic CLK,
	input logic ADD_SUB,
	output logic[0:6] OUT0,
	output logic[0:6] OUT1
);

wire	  SCLK;
wire[3:0] COUNT;

zegar_verilog zegar_verilog0(
	.CLK(CLK),
	.CLK_OUT(SCLK)
);

counter_verilog counter_verilog0(
	.CLK(SCLK),
	.ADD_SUB(ADD_SUB),
	.COUNT(COUNT)
);

encoder_verilog encoder_verilog0(
	.NUM(COUNT),
	.OUT0(OUT0),
	.OUT1(OUT1)
);

endmodule

module counter_verilog(
	input logic CLK,
	input logic ADD_SUB,
	inout logic[3:0] COUNT
);

always_ff @(posedge CLK)
if (ADD_SUB)
	COUNT++;
else
	COUNT--;

endmodule

module encoder_verilog(
	input logic[3:0] NUM,
	output logic[0:6] OUT0,
	output logic[0:6] OUT1
);

always_comb
begin
	OUT0 = 7'b0000001;
	OUT1 = 7'b0000001;
	case (NUM)
		4'h1:
			begin
				OUT0 = 7'b1001111;
				OUT1 = 7'b0000001;
			end
		4'h2:
			begin
				OUT0 = 7'b0010010;
				OUT1 = 7'b0000001;
			end
		4'h3:
			begin
				OUT0 = 7'b0000110;
				OUT1 = 7'b0000001;
			end
		4'h4:
			begin
				OUT0 = 7'b1001100;
				OUT1 = 7'b0000001;
			end
		4'h5:
			begin
				OUT0 = 7'b0100100;
				OUT1 = 7'b0000001;
			end
		4'h6:
			begin
				OUT0 = 7'b0100000;
				OUT1 = 7'b0000001;
			end
		4'h7:
			begin
				OUT0 = 7'b0001111;
				OUT1 = 7'b0000001;
			end
		4'h8:
			begin
				OUT0 = 7'b0000000;
				OUT1 = 7'b0000001;
			end
		4'h9:
			begin
				OUT0 = 7'b0000100;
				OUT1 = 7'b0000001;
			end
		4'hA:
			begin
				OUT0 = 7'b0000001;
				OUT1 = 7'b1001111;
			end
		4'hB:
			begin
				OUT0 = 7'b1001111;
				OUT1 = 7'b1001111;
			end
		4'hC:
			begin
				OUT0 = 7'b0010010;
				OUT1 = 7'b1001111;
			end
		4'hD:
			begin
				OUT0 = 7'b0000110;
				OUT1 = 7'b1001111;
			end
		4'hE:
			begin
				OUT0 = 7'b1001100;
				OUT1 = 7'b1001111;
			end
		4'hF:
			begin
				OUT0 = 7'b0100100;
				OUT1 = 7'b1001111;
			end
	endcase
end

endmodule

module zegar_verilog (
	input logic CLK,
	output logic CLK_OUT
);

integer COUNT;
logic SIG;

always_ff @(posedge CLK)
begin
	COUNT++;
	if (COUNT == 12587500)
	begin
		SIG = !SIG;
		COUNT = 0;
	end
end

assign CLK_OUT = SIG;

endmodule