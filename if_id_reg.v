module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] instr_out
);

    localparam NOP_INSTR = 32'h0000_0013;

    always @(posedge clk) begin
        if (!rst_n || flush) begin
            pc_out        <= 32'd0;
            pc_plus_4_out <= 32'd0;
            instr_out     <= NOP_INSTR;
        end
        else if (!stall) begin
            pc_out        <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            instr_out     <= instr_in;
        end
    end

endmodule
