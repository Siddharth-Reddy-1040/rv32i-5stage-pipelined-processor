module reg_file(clk,rst_n,reg_write,rs1_addr,rs2_addr,rd_addr,rd_data,rs1_data,rs2_data);
input clk,rst_n,reg_write;
input [4:0]rs1_addr,rs2_addr,rd_addr;
input [31:0] rd_data;
output reg [31:0] rs1_data,rs2_data;
reg [31:0]regs[1:31];
integer i;
always@(posedge clk)begin
	if(!rst_n)begin
		for(i=1;i<32;i=i+1)begin
			regs[i]<=32'd0;
			end
		end
	else if(reg_write && (rd_addr != 5'd0))begin
		regs[rd_addr]<=rd_data;
		end
	end
always@(*)begin
	if(rs1_addr == 5'd0)begin
		rs1_data=32'd0;
		end
	else if(reg_write && (rd_addr ==rs1_addr))begin
		rs1_data=rd_data;
		end
	else begin
		rs1_data=regs[rs1_addr];
		end
	end
always@(*)begin
	if(rs2_addr == 5'd0)begin
		rs2_data=32'd0;
		end
	else if(reg_write && (rd_addr ==rs2_addr))begin
		rs2_data=rd_data;
		end
	else begin
		rs2_data=regs[rs2_addr];
		end
	end
endmodule
		
	
	
