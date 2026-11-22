module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src_a,
    output reg        alu_src_b,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg        jump,
    output reg  [1:0] wb_sel,
    output reg  [1:0] alu_op
);

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_IMM    = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;

    always @(*) begin
        reg_write = 1'b0;
        alu_src_a = 1'b0;
        alu_src_b = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        wb_sel    = 2'b00;
        alu_op    = 2'b00;

        case (opcode)
            OP_RTYPE: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end

            OP_IMM: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                alu_op    = 2'b10;
            end

            OP_LOAD: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                mem_read  = 1'b1;
                wb_sel    = 2'b01;
            end

            OP_STORE: begin
                alu_src_b = 1'b1;
                mem_write = 1'b1;
            end

            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end

            OP_JAL: begin
                reg_write = 1'b1;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
                jump      = 1'b1;
                wb_sel    = 2'b10;
            end

            OP_JALR: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                jump      = 1'b1;
                wb_sel    = 2'b10;
            end

            OP_LUI: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                alu_op    = 2'b11;
            end

            OP_AUIPC: begin
                reg_write = 1'b1;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule
