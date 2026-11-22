module pc_reg(clk,rst_n,pc_write,pc_src,branch_target,pc,pc_plus_4);
input clk,rst_n,pc_write,pc_src;
input [31:0]branch_target;
output reg [31:0] pc;
output [31:0] pc_plus_4;
assign pc_plus_4 = pc + 32'd4;
always@(posedge clk)begin
	if(!rst_n)begin
		pc<=32'd0;
		end
	else if(pc_write)begin
		if(pc_src)begin
			pc<=branch_target;
			end
		else begin
			pc<=pc_plus_4;
			end
		end
	else begin
		pc<=pc;
		end
	end
endmodule
	
