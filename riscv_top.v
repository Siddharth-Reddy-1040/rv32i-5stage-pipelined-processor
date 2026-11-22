module riscv_top #(
    parameter IMEM_FILE = ""
) (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result
);

    wire [31:0] pc;
    wire [31:0] pc_plus_4;
    wire [31:0] instr;

    wire [6:0] opcode      = instr[6:0];
    wire [4:0] rd          = instr[11:7];
    wire [2:0] funct3      = instr[14:12];
    wire [4:0] rs1         = instr[19:15];
    wire [4:0] rs2         = instr[24:20];
    wire       funct7_bit5 = instr[30];
    wire       is_rtype    = opcode[5];

    wire        reg_write;
    wire        alu_src_a;
    wire        alu_src_b;
    wire        mem_read;
    wire        mem_write;
    wire        branch;
    wire        jump;
    wire [1:0]  wb_sel;
    wire [1:0]  alu_op;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] imm_out;

    wire [3:0]  alu_ctrl;
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        zero_flag;

    wire        branch_taken;
    wire        pc_src;
    wire [31:0] branch_target;

    wire [31:0] mem_read_data;
    reg  [31:0] wb_data;

    assign pc_src        = jump | branch_taken;
    assign branch_target = (opcode == 7'b1100111) ? {alu_result[31:1], 1'b0} : (pc + imm_out);

    assign alu_operand_a = alu_src_a ? pc      : rs1_data;
    assign alu_operand_b = alu_src_b ? imm_out : rs2_data;

    always @(*) begin
        case (wb_sel)
            2'b00:   wb_data = alu_result;
            2'b01:   wb_data = mem_read_data;
            2'b10:   wb_data = pc_plus_4;
            default: wb_data = 32'd0;
        endcase
    end

    pc_reg u_pc_reg (
        .clk           (clk),
        .rst_n         (rst_n),
        .pc_write      (1'b1),
        .pc_src        (pc_src),
        .branch_target (branch_target),
        .pc            (pc),
        .pc_plus_4     (pc_plus_4)
    );

    instr_mem #(
        .INIT_FILE (IMEM_FILE)
    ) u_instr_mem (
        .addr  (pc),
        .instr (instr)
    );

    control_unit u_control_unit (
        .opcode    (opcode),
        .reg_write (reg_write),
        .alu_src_a (alu_src_a),
        .alu_src_b (alu_src_b),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .branch    (branch),
        .jump      (jump),
        .wb_sel    (wb_sel),
        .alu_op    (alu_op)
    );

    reg_file u_reg_file (
        .clk        (clk),
        .rst_n      (rst_n),
        .reg_write  (reg_write),
        .rs1_addr   (rs1),
        .rs2_addr   (rs2),
        .rd_addr    (rd),
        .rd_data    (wb_data),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data)
    );

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_out (imm_out)
    );

    alu_control u_alu_control (
        .alu_op      (alu_op),
        .funct3      (funct3),
        .funct7_bit5 (funct7_bit5),
        .is_rtype    (is_rtype),
        .alu_ctrl    (alu_ctrl)
    );

    alu u_alu (
        .operand_a  (alu_operand_a),
        .operand_b  (alu_operand_b),
        .alu_ctrl   (alu_ctrl),
        .alu_result (alu_result),
        .zero_flag  (zero_flag)
    );

    branch_unit u_branch_unit (
        .branch       (branch),
        .funct3       (funct3),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .branch_taken (branch_taken)
    );

    data_mem u_data_mem (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .funct3     (funct3),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    assign debug_pc         = pc;
    assign debug_alu_result = alu_result;

endmodule
