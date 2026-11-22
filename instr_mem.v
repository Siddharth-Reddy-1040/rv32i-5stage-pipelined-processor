module instr_mem #(
    parameter MEM_DEPTH = 256,
    parameter INIT_FILE = ""
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] rom [0:MEM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            rom[i] = 32'h0000_0013;
        end
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom);
        end
    end

    assign instr = rom[addr[9:2]];

endmodule
