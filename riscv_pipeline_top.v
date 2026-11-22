module riscv_pipeline_top #(
    parameter IMEM_FILE = ""
) (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result
);

    wire [31:0] if_pc;
    wire [31:0] if_pc_plus_4;
    wire [31:0] if_instr;

    wire        pc_write;
    wire        if_id_stall;
    wire        if_id_flush;
    wire        id_ex_flush;

    wire [31:0] id_pc;
    wire [31:0] id_pc_plus_4;
    wire [31:0] id_instr;

    wire [6:0]  id_opcode      = id_instr[6:0];
    wire [4:0]  id_rd          = id_instr[11:7];
    wire [2:0]  id_funct3      = id_instr[14:12];
    wire [4:0]  id_rs1         = id_instr[19:15];
    wire [4:0]  id_rs2         = id_instr[24:20];
    wire        id_funct7_bit5 = id_instr[30];

    wire        id_reg_write;
    wire        id_alu_src_a;
    wire        id_alu_src_b;
    wire        id_mem_read;
    wire        id_mem_write;
    wire        id_branch;
    wire        id_jump;
    wire [1:0]  id_wb_sel;
    wire [1:0]  id_alu_op;

    wire [31:0] id_rs1_raw;
    wire [31:0] id_rs2_raw;
    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;
    wire [31:0] id_imm;

    wire        ex_reg_write;
    wire        ex_alu_src_a;
    wire        ex_alu_src_b;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire        ex_branch;
    wire        ex_jump;
    wire [1:0]  ex_wb_sel;
    wire [1:0]  ex_alu_op;
    wire [31:0] ex_pc;
    wire [31:0] ex_pc_plus_4;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm;
    wire [6:0]  ex_opcode;
    wire [2:0]  ex_funct3;
    wire        ex_funct7_bit5;
    wire [4:0]  ex_rs1_addr;
    wire [4:0]  ex_rs2_addr;
    wire [4:0]  ex_rd_addr;

    wire [1:0]  forward_a;
    wire [1:0]  forward_b;
    reg  [31:0] ex_fwd_rs1;
    reg  [31:0] ex_fwd_rs2;
    wire [31:0] ex_alu_in_a;
    wire [31:0] ex_alu_in_b;
    wire [3:0]  ex_alu_ctrl;
    wire [31:0] ex_alu_result;
    wire        ex_zero_flag;
    wire        ex_branch_taken;
    wire        ex_pc_src;
    wire [31:0] ex_branch_target;

    wire        mem_reg_write;
    wire        mem_mem_read;
    wire        mem_mem_write;
    wire [1:0]  mem_wb_sel;
    wire [31:0] mem_pc_plus_4;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_rs2_data;
    wire [2:0]  mem_funct3;
    wire [4:0]  mem_rd_addr;
    wire [31:0] mem_read_data;
    wire [31:0] mem_fwd_data;

    wire        wb_reg_write;
    wire [1:0]  wb_sel;
    wire [31:0] wb_pc_plus_4;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_mem_read_data;
    wire [4:0]  wb_rd_addr;
    reg  [31:0] wb_data;

    assign id_rs1_data = (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == id_rs1)) ? wb_data : id_rs1_raw;
    assign id_rs2_data = (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == id_rs2)) ? wb_data : id_rs2_raw;

    assign mem_fwd_data = (mem_wb_sel == 2'b10) ? mem_pc_plus_4 : mem_alu_result;

    always @(*) begin
        case (forward_a)
            2'b00:   ex_fwd_rs1 = ex_rs1_data;
            2'b01:   ex_fwd_rs1 = wb_data;
            2'b10:   ex_fwd_rs1 = mem_fwd_data;
            default: ex_fwd_rs1 = ex_rs1_data;
        endcase

        case (forward_b)
            2'b00:   ex_fwd_rs2 = ex_rs2_data;
            2'b01:   ex_fwd_rs2 = wb_data;
            2'b10:   ex_fwd_rs2 = mem_fwd_data;
            default: ex_fwd_rs2 = ex_rs2_data;
        endcase
    end

    assign ex_alu_in_a = ex_alu_src_a ? ex_pc  : ex_fwd_rs1;
    assign ex_alu_in_b = ex_alu_src_b ? ex_imm : ex_fwd_rs2;

    assign ex_pc_src        = ex_jump | ex_branch_taken;
    assign ex_branch_target = (ex_opcode == 7'b1100111) ? {ex_alu_result[31:1], 1'b0} : (ex_pc + ex_imm);

    always @(*) begin
        case (wb_sel)
            2'b00:   wb_data = wb_alu_result;
            2'b01:   wb_data = wb_mem_read_data;
            2'b10:   wb_data = wb_pc_plus_4;
            default: wb_data = 32'd0;
        endcase
    end

    pc_reg u_pc_reg (
        .clk           (clk),
        .rst_n         (rst_n),
        .pc_write      (pc_write),
        .pc_src        (ex_pc_src),
        .branch_target (ex_branch_target),
        .pc            (if_pc),
        .pc_plus_4     (if_pc_plus_4)
    );

    instr_mem #(
        .INIT_FILE (IMEM_FILE)
    ) u_instr_mem (
        .addr  (if_pc),
        .instr (if_instr)
    );

    if_id_reg u_if_id_reg (
        .clk           (clk),
        .rst_n         (rst_n),
        .stall         (if_id_stall),
        .flush         (if_id_flush),
        .pc_in         (if_pc),
        .pc_plus_4_in  (if_pc_plus_4),
        .instr_in      (if_instr),
        .pc_out        (id_pc),
        .pc_plus_4_out (id_pc_plus_4),
        .instr_out     (id_instr)
    );

    control_unit u_control_unit (
        .opcode    (id_opcode),
        .reg_write (id_reg_write),
        .alu_src_a (id_alu_src_a),
        .alu_src_b (id_alu_src_b),
        .mem_read  (id_mem_read),
        .mem_write (id_mem_write),
        .branch    (id_branch),
        .jump      (id_jump),
        .wb_sel    (id_wb_sel),
        .alu_op    (id_alu_op)
    );

    reg_file u_reg_file (
        .clk       (clk),
        .rst_n     (rst_n),
        .reg_write (wb_reg_write),
        .rs1_addr  (id_rs1),
        .rs2_addr  (id_rs2),
        .rd_addr   (wb_rd_addr),
        .rd_data   (wb_data),
        .rs1_data  (id_rs1_raw),
        .rs2_data  (id_rs2_raw)
    );

    imm_gen u_imm_gen (
        .instr   (id_instr),
        .imm_out (id_imm)
    );

    id_ex_reg u_id_ex_reg (
        .clk             (clk),
        .rst_n           (rst_n),
        .flush           (id_ex_flush),
        .reg_write_in    (id_reg_write),
        .alu_src_a_in    (id_alu_src_a),
        .alu_src_b_in    (id_alu_src_b),
        .mem_read_in     (id_mem_read),
        .mem_write_in    (id_mem_write),
        .branch_in       (id_branch),
        .jump_in         (id_jump),
        .wb_sel_in       (id_wb_sel),
        .alu_op_in       (id_alu_op),
        .pc_in           (id_pc),
        .pc_plus_4_in    (id_pc_plus_4),
        .rs1_data_in     (id_rs1_data),
        .rs2_data_in     (id_rs2_data),
        .imm_in          (id_imm),
        .opcode_in       (id_opcode),
        .funct3_in       (id_funct3),
        .funct7_bit5_in  (id_funct7_bit5),
        .rs1_addr_in     (id_rs1),
        .rs2_addr_in     (id_rs2),
        .rd_addr_in      (id_rd),
        .reg_write_out   (ex_reg_write),
        .alu_src_a_out   (ex_alu_src_a),
        .alu_src_b_out   (ex_alu_src_b),
        .mem_read_out    (ex_mem_read),
        .mem_write_out   (ex_mem_write),
        .branch_out      (ex_branch),
        .jump_out        (ex_jump),
        .wb_sel_out      (ex_wb_sel),
        .alu_op_out      (ex_alu_op),
        .pc_out          (ex_pc),
        .pc_plus_4_out   (ex_pc_plus_4),
        .rs1_data_out    (ex_rs1_data),
        .rs2_data_out    (ex_rs2_data),
        .imm_out         (ex_imm),
        .opcode_out      (ex_opcode),
        .funct3_out      (ex_funct3),
        .funct7_bit5_out (ex_funct7_bit5),
        .rs1_addr_out    (ex_rs1_addr),
        .rs2_addr_out    (ex_rs2_addr),
        .rd_addr_out     (ex_rd_addr)
    );

    alu_control u_alu_control (
        .alu_op      (ex_alu_op),
        .funct3      (ex_funct3),
        .funct7_bit5 (ex_funct7_bit5),
        .is_rtype    (ex_opcode[5]),
        .alu_ctrl    (ex_alu_ctrl)
    );

    alu u_alu (
        .operand_a  (ex_alu_in_a),
        .operand_b  (ex_alu_in_b),
        .alu_ctrl   (ex_alu_ctrl),
        .alu_result (ex_alu_result),
        .zero_flag  (ex_zero_flag)
    );

    branch_unit u_branch_unit (
        .branch       (ex_branch),
        .funct3       (ex_funct3),
        .rs1_data     (ex_fwd_rs1),
        .rs2_data     (ex_fwd_rs2),
        .branch_taken (ex_branch_taken)
    );

    forwarding_unit u_forwarding_unit (
        .ex_rs1_addr   (ex_rs1_addr),
        .ex_rs2_addr   (ex_rs2_addr),
        .mem_reg_write (mem_reg_write),
        .mem_rd_addr   (mem_rd_addr),
        .wb_reg_write  (wb_reg_write),
        .wb_rd_addr    (wb_rd_addr),
        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );

    hazard_unit u_hazard_unit (
        .id_rs1_addr (id_rs1),
        .id_rs2_addr (id_rs2),
        .ex_mem_read (ex_mem_read),
        .ex_rd_addr  (ex_rd_addr),
        .ex_pc_src   (ex_pc_src),
        .pc_write    (pc_write),
        .if_id_stall (if_id_stall),
        .if_id_flush (if_id_flush),
        .id_ex_flush (id_ex_flush)
    );

    ex_mem_reg u_ex_mem_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .reg_write_in   (ex_reg_write),
        .mem_read_in    (ex_mem_read),
        .mem_write_in   (ex_mem_write),
        .wb_sel_in      (ex_wb_sel),
        .pc_plus_4_in   (ex_pc_plus_4),
        .alu_result_in  (ex_alu_result),
        .rs2_data_in    (ex_fwd_rs2),
        .funct3_in      (ex_funct3),
        .rd_addr_in     (ex_rd_addr),
        .reg_write_out  (mem_reg_write),
        .mem_read_out   (mem_mem_read),
        .mem_write_out  (mem_mem_write),
        .wb_sel_out     (mem_wb_sel),
        .pc_plus_4_out  (mem_pc_plus_4),
        .alu_result_out (mem_alu_result),
        .rs2_data_out   (mem_rs2_data),
        .funct3_out     (mem_funct3),
        .rd_addr_out    (mem_rd_addr)
    );

    data_mem u_data_mem (
        .clk        (clk),
        .mem_read   (mem_mem_read),
        .mem_write  (mem_mem_write),
        .funct3     (mem_funct3),
        .addr       (mem_alu_result),
        .write_data (mem_rs2_data),
        .read_data  (mem_read_data)
    );

    mem_wb_reg u_mem_wb_reg (
        .clk               (clk),
        .rst_n             (rst_n),
        .reg_write_in      (mem_reg_write),
        .wb_sel_in         (mem_wb_sel),
        .pc_plus_4_in      (mem_pc_plus_4),
        .alu_result_in     (mem_alu_result),
        .mem_read_data_in  (mem_read_data),
        .rd_addr_in        (mem_rd_addr),
        .reg_write_out     (wb_reg_write),
        .wb_sel_out        (wb_sel),
        .pc_plus_4_out     (wb_pc_plus_4),
        .alu_result_out    (wb_alu_result),
        .mem_read_data_out (wb_mem_read_data),
        .rd_addr_out       (wb_rd_addr)
    );

    assign debug_pc         = if_pc;
    assign debug_alu_result = ex_alu_result;

endmodule
