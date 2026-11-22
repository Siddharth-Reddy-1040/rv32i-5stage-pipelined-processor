`timescale 1ns / 1ps

module tb_riscv_top;

    reg         clk;
    reg         rst_n;
    wire [31:0] debug_pc;
    wire [31:0] debug_alu_result;

    integer error_count;

    riscv_top dut (
        .clk              (clk),
        .rst_n            (rst_n),
        .debug_pc         (debug_pc),
        .debug_alu_result (debug_alu_result)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        error_count = 0;

        dut.u_instr_mem.rom[0]  = 32'h00a00093;
        dut.u_instr_mem.rom[1]  = 32'h01400113;
        dut.u_instr_mem.rom[2]  = 32'h002081b3;
        dut.u_instr_mem.rom[3]  = 32'h40110233;
        dut.u_instr_mem.rom[4]  = 32'h00302223;
        dut.u_instr_mem.rom[5]  = 32'h00402283;
        dut.u_instr_mem.rom[6]  = 32'h00518463;
        dut.u_instr_mem.rom[7]  = 32'h06300313;
        dut.u_instr_mem.rom[8]  = 32'h02a00393;
        dut.u_instr_mem.rom[9]  = 32'h0080046f;
        dut.u_instr_mem.rom[10] = 32'h04d00493;
        dut.u_instr_mem.rom[11] = 32'h12345537;
        dut.u_instr_mem.rom[12] = 32'h00000063;

        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        #1 rst_n = 1'b1;

        repeat (15) @(posedge clk);
        #1;

        check_reg(5'd1,  32'd10);
        check_reg(5'd2,  32'd20);
        check_reg(5'd3,  32'd30);
        check_reg(5'd4,  32'd10);
        check_reg(5'd5,  32'd30);
        check_reg(5'd6,  32'd0);
        check_reg(5'd7,  32'd42);
        check_reg(5'd8,  32'h0000_0028);
        check_reg(5'd9,  32'd0);
        check_reg(5'd10, 32'h1234_5000);

        if (dut.u_data_mem.ram[1] !== 32'd30) begin
            $display("FAIL: Mem[4] expected 30, got %0d", dut.u_data_mem.ram[1]);
            error_count = error_count + 1;
        end

        if (error_count == 0)
            $display("PASS: All RV32I Single-Cycle checks passed!");
        else
            $display("FAIL: %0d error(s) detected.", error_count);

        $finish;
    end

    task check_reg;
        input [4:0]  reg_num;
        input [31:0] expected;
        begin
            if (dut.u_reg_file.regs[reg_num] !== expected) begin
                $display("FAIL: x%0d expected 0x%08h, got 0x%08h",
                         reg_num, expected, dut.u_reg_file.regs[reg_num]);
                error_count = error_count + 1;
            end
        end
    endtask

endmodule
