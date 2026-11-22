module mem_wb_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        reg_write_in,
    input  wire [1:0]  wb_sel_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_read_data_in,
    input  wire [4:0]  rd_addr_in,
    output reg         reg_write_out,
    output reg  [1:0]  wb_sel_out,
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_read_data_out,
    output reg  [4:0]  rd_addr_out
);

    always @(posedge clk) begin
        if (!rst_n) begin
            reg_write_out     <= 1'b0;
            wb_sel_out        <= 2'b00;
            pc_plus_4_out     <= 32'd0;
            alu_result_out    <= 32'd0;
            mem_read_data_out <= 32'd0;
            rd_addr_out       <= 5'd0;
        end
        else begin
            reg_write_out     <= reg_write_in;
            wb_sel_out        <= wb_sel_in;
            pc_plus_4_out     <= pc_plus_4_in;
            alu_result_out    <= alu_result_in;
            mem_read_data_out <= mem_read_data_in;
            rd_addr_out       <= rd_addr_in;
        end
    end

endmodule
