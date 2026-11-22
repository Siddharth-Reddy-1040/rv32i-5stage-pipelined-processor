module branch_unit (
    input  wire        branch,
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    output reg         branch_taken
);

    localparam FUNCT3_BEQ  = 3'b000;
    localparam FUNCT3_BNE  = 3'b001;
    localparam FUNCT3_BLT  = 3'b100;
    localparam FUNCT3_BGE  = 3'b101;
    localparam FUNCT3_BLTU = 3'b110;
    localparam FUNCT3_BGEU = 3'b111;

    always @(*) begin
        if (branch) begin
            case (funct3)
                FUNCT3_BEQ:  branch_taken = (rs1_data == rs2_data);
                FUNCT3_BNE:  branch_taken = (rs1_data != rs2_data);
                FUNCT3_BLT:  branch_taken = ($signed(rs1_data) <  $signed(rs2_data));
                FUNCT3_BGE:  branch_taken = ($signed(rs1_data) >= $signed(rs2_data));
                FUNCT3_BLTU: branch_taken = (rs1_data <  rs2_data);
                FUNCT3_BGEU: branch_taken = (rs1_data >= rs2_data);
                default:     branch_taken = 1'b0;
            endcase
        end
        else begin
            branch_taken = 1'b0;
        end
    end

endmodule
