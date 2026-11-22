module data_mem #(
    parameter MEM_DEPTH = 256
) (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    localparam FUNCT3_LB  = 3'b000;
    localparam FUNCT3_LH  = 3'b001;
    localparam FUNCT3_LW  = 3'b010;
    localparam FUNCT3_LBU = 3'b100;
    localparam FUNCT3_LHU = 3'b101;

    localparam FUNCT3_SB  = 3'b000;
    localparam FUNCT3_SH  = 3'b001;
    localparam FUNCT3_SW  = 3'b010;

    reg [31:0] ram [0:MEM_DEPTH-1];
    integer i;

    wire [7:0]  word_addr = addr[9:2];
    wire [1:0]  byte_off  = addr[1:0];
    wire [31:0] raw_word  = ram[word_addr];

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            ram[i] = 32'd0;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                FUNCT3_SB: begin
                    case (byte_off)
                        2'b00: ram[word_addr][7:0]   <= write_data[7:0];
                        2'b01: ram[word_addr][15:8]  <= write_data[7:0];
                        2'b10: ram[word_addr][23:16] <= write_data[7:0];
                        2'b11: ram[word_addr][31:24] <= write_data[7:0];
                    endcase
                end
                FUNCT3_SH: begin
                    if (byte_off[1] == 1'b0)
                        ram[word_addr][15:0]  <= write_data[15:0];
                    else
                        ram[word_addr][31:16] <= write_data[15:0];
                end
                FUNCT3_SW: begin
                    ram[word_addr] <= write_data;
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        if (mem_read) begin
            case (funct3)
                FUNCT3_LB: begin
                    case (byte_off)
                        2'b00: read_data = {{24{raw_word[7]}},  raw_word[7:0]};
                        2'b01: read_data = {{24{raw_word[15]}}, raw_word[15:8]};
                        2'b10: read_data = {{24{raw_word[23]}}, raw_word[23:16]};
                        2'b11: read_data = {{24{raw_word[31]}}, raw_word[31:24]};
                    endcase
                end
                FUNCT3_LH: begin
                    if (byte_off[1] == 1'b0)
                        read_data = {{16{raw_word[15]}}, raw_word[15:0]};
                    else
                        read_data = {{16{raw_word[31]}}, raw_word[31:16]};
                end
                FUNCT3_LW: begin
                    read_data = raw_word;
                end
                FUNCT3_LBU: begin
                    case (byte_off)
                        2'b00: read_data = {24'd0, raw_word[7:0]};
                        2'b01: read_data = {24'd0, raw_word[15:8]};
                        2'b10: read_data = {24'd0, raw_word[23:16]};
                        2'b11: read_data = {24'd0, raw_word[31:24]};
                    endcase
                end
                FUNCT3_LHU: begin
                    if (byte_off[1] == 1'b0)
                        read_data = {16'd0, raw_word[15:0]};
                    else
                        read_data = {16'd0, raw_word[31:16]};
                end
                default: read_data = 32'd0;
            endcase
        end
        else begin
            read_data = 32'd0;
        end
    end

endmodule
