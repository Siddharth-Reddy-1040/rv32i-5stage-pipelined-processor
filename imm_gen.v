module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instr[6:0];

    // RISC-V Base Opcodes
    localparam OP_LOAD   = 7'b0000011; 
    localparam OP_IMM    = 7'b0010011; 
    localparam OP_STORE  = 7'b0100011; 
    localparam OP_BRANCH = 7'b1100011; 
    localparam OP_LUI    = 7'b0110111; 
    localparam OP_AUIPC  = 7'b0010111; 
    localparam OP_JAL    = 7'b1101111; 
    localparam OP_JALR   = 7'b1100111;

    always @(*) begin
        case (opcode)
            OP_LOAD,
            OP_IMM,
            OP_JALR: begin
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end
            OP_STORE: begin
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            OP_BRANCH: begin
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            OP_LUI,
            OP_AUIPC: begin
                imm_out = {instr[31:12], 12'd0};
            end
            OP_JAL: begin
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            default: begin
                imm_out = 32'd0;
            end
        endcase
    end

endmodule
