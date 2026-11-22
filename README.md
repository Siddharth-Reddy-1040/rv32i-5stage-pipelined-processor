# 32-Bit RISC-V (RV32I) 5-Stage Pipelined Processor

A complete, synthesizable 32-bit RISC-V (`RV32I` Base Integer Instruction Set) processor designed in Verilog HDL, progressing from a single-cycle datapath (`riscv_top.v`) to a 5-stage pipelined architecture (`riscv_pipeline_top.v`) with full data and control hazard resolution.

## Pipeline Stages

1. **IF (Instruction Fetch):** Program Counter (`pc_reg.v`) and asynchronous instruction ROM (`instr_mem.v`).
2. **ID (Instruction Decode):** Main control decoder (`control_unit.v`), 32x32-bit register file (`reg_file.v`) with internal `WB`-to-`ID` bypass, and immediate generator (`imm_gen.v`).
3. **EX (Execute):** Secondary ALU decoder (`alu_control.v`), 32-bit ALU (`alu.v`), branch condition comparator (`branch_unit.v`), and `EX/MEM` + `MEM/WB` forwarding multiplexers.
4. **MEM (Memory Access):** Byte-addressable data RAM (`data_mem.v`) supporting `LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, and `SW`.
5. **WB (Writeback):** Writeback multiplexer selecting between ALU result, loaded memory data, and `PC + 4` return addresses.

## Hazard Management

* **Data Hazards (`forwarding_unit.v`):** Resolves Read-After-Write (RAW) dependencies by forwarding fresh results from `EX/MEM` and `MEM/WB` directly back to the ALU inputs (`forward_a`, `forward_b`), alongside `WB`-stage bypass in `ID`.
* **Load-Use Hazards (`hazard_unit.v`):** Detects when a load in `EX` (`ex_mem_read`) targets a source register (`id_rs1_addr` or `id_rs2_addr`) needed in `ID`, stalling `pc_reg` and `if_id_reg` for 1 cycle while flushing `id_ex_reg` with a NOP bubble.
* **Control Hazards (`hazard_unit.v`):** Resolves conditional branches (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) and jumps (`JAL`, `JALR`) in `EX`, flushing `if_id_reg` and `id_ex_reg` when taken.

## Module Inventory

* **Datapath & Decode (9):** `pc_reg.v`, `instr_mem.v`, `reg_file.v`, `imm_gen.v`, `control_unit.v`, `alu_control.v`, `alu.v`, `branch_unit.v`, `data_mem.v`
* **Pipeline Registers (4):** `if_id_reg.v`, `id_ex_reg.v`, `ex_mem_reg.v`, `mem_wb_reg.v`
* **Hazard Units (2):** `forwarding_unit.v`, `hazard_unit.v`
* **Top-Level Cores (2):** `riscv_top.v` (Single-Cycle), `riscv_pipeline_top.v` (5-Stage Pipelined)
* **Testbenches (2):** `tb_riscv_top.v`, `tb_riscv_pipeline_top.v`

## Running Simulations (Icarus Verilog)

```bash
# Simulate 5-stage pipelined core
iverilog -o pipeline_sim.vvp pc_reg.v instr_mem.v reg_file.v imm_gen.v control_unit.v alu_control.v alu.v branch_unit.v data_mem.v if_id_reg.v id_ex_reg.v ex_mem_reg.v mem_wb_reg.v forwarding_unit.v hazard_unit.v riscv_pipeline_top.v tb_riscv_pipeline_top.v
vvp pipeline_sim.vvp

# Simulate single-cycle core
iverilog -o single_cycle_sim.vvp pc_reg.v instr_mem.v reg_file.v imm_gen.v control_unit.v alu_control.v alu.v branch_unit.v data_mem.v riscv_top.v tb_riscv_top.v
vvp single_cycle_sim.vvp
```
