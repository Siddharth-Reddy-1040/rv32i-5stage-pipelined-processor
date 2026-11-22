module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    input  wire        reg_write_in,
    input  wire        alu_src_a_in,
    input  wire        alu_src_b_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input  wire [1:0]  wb_sel_in,
    input  wire [1:0]  alu_op_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm_in,
    input  wire [6:0]  opcode_in,
    input  wire [2:0]  funct3_in,
    input  wire        funct7_bit5_in,
    input  wire [4:0]  rs1_addr_in,
    input  wire [4:0]  rs2_addr_in,
    input  wire [4:0]  rd_addr_in,
    output reg         reg_write_out,
    output reg         alu_src_a_out,
    output reg         alu_src_b_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg  [1:0]  wb_sel_out,
    output reg  [1:0]  alu_op_out,
    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm_out,
    output reg  [6:0]  opcode_out,
    output reg  [2:0]  funct3_out,
    output reg         funct7_bit5_out,
    output reg  [4:0]  rs1_addr_out,
    output reg  [4:0]  rs2_addr_out,
    output reg  [4:0]  rd_addr_out
);

    always @(posedge clk) begin
        if (!rst_n || flush) begin
            reg_write_out   <= 1'b0;
            alu_src_a_out   <= 1'b0;
            alu_src_b_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
            wb_sel_out      <= 2'b00;
            alu_op_out      <= 2'b00;
            pc_out          <= 32'd0;
            pc_plus_4_out   <= 32'd0;
            rs1_data_out    <= 32'd0;
            rs2_data_out    <= 32'd0;
            imm_out         <= 32'd0;
            opcode_out      <= 7'd0;
            funct3_out      <= 3'd0;
            funct7_bit5_out <= 1'b0;
            rs1_addr_out    <= 5'd0;
            rs2_addr_out    <= 5'd0;
            rd_addr_out     <= 5'd0;
        end
        else begin
            reg_write_out   <= reg_write_in;
            alu_src_a_out   <= alu_src_a_in;
            alu_src_b_out   <= alu_src_b_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            wb_sel_out      <= wb_sel_in;
            alu_op_out      <= alu_op_in;
            pc_out          <= pc_in;
            pc_plus_4_out   <= pc_plus_4_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            imm_out         <= imm_in;
            opcode_out      <= opcode_in;
            funct3_out      <= funct3_in;
            funct7_bit5_out <= funct7_bit5_in;
            rs1_addr_out    <= rs1_addr_in;
            rs2_addr_out    <= rs2_addr_in;
            rd_addr_out     <= rd_addr_in;
        end
    end

endmodule
