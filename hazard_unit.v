module hazard_unit (
    input  wire [4:0] id_rs1_addr,
    input  wire [4:0] id_rs2_addr,
    input  wire       ex_mem_read,
    input  wire [4:0] ex_rd_addr,
    input  wire       ex_pc_src,
    output wire       pc_write,
    output wire       if_id_stall,
    output wire       if_id_flush,
    output wire       id_ex_flush
);

    wire load_use_hazard;

    assign load_use_hazard = ex_mem_read &&
                             (ex_rd_addr != 5'd0) &&
                             ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr));

    assign pc_write    = ~load_use_hazard;
    assign if_id_stall = load_use_hazard;
    assign if_id_flush = ex_pc_src;
    assign id_ex_flush = load_use_hazard | ex_pc_src;

endmodule
