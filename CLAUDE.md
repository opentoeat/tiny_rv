# tiny_rv — RISC-V FPGA SoC（项目说明 / 接续指南）

> 本文件被 Claude Code 自动加载。开新对话时读它即可接续项目，无需翻历史。

## 项目概况
- **tiny_rv**：Xilinx Vivado 2020.2 工程，5 级流水线 RV32I 子集 CPU（`rv_top`）+ SoC 顶层（`top`：VGA/按键/DRAM/ROM/PLL）。
- **器件**：`xc7a35tcpg236-1`（Artix-7 35T，Basys3）。CPU 50MHz，VGA 25MHz（1bpp 黑白）。
- **Git**：`github.com/opentoeat/tiny_rv`（master）。**不是从远古就 git，2026-06 才 init**。

## 环境 / 工具
- **Vivado**：`F:/vivado/Vivado/2020.2/`。从本机 bash 驱动：
  `/c/Windows/System32/cmd.exe //c 'F:\vivado\Vivado\2020.2\bin\vivado.bat -mode batch -nojournal -nolog -source <tcl>'`
  （`cmd.exe` 不在 PATH，用全路径；`-notracejournal` 是无效参数别用。`.xpr` 用 `$PSRCDIR/$PPRDIR` 变量，目录迁移不影响。）
- **riscv 工具链**：**未装**。WSL Ubuntu-24.04 在，但 `sudo` 要密码 + apt 源连不上（网络）。装了才能做 C→coe（任务 #5）。
- **仿真**：⚠️ **不要用 `launch_simulation`**（Vivado 2020.2 batch 有 compile.bat spawn fail / webtalk JVM 崩）。用手动 xvlog/xelab/xsim，见 [[tiny-rv-vivado-sim-howto]] 或本会话记录。

## 当前状态（2026-07-01）
**已完成（每项都做过 review）：**
- ✅ **总线 latch 清零**（bus_top/CTRL，104→0）；bus_top 显存写路径时序化
- ✅ **ISA 补全**：BLT/BLTU、SRLI/SRAI、AUIPC（CTRL.v 改 5 处，ALU.v 未动）
- ✅ **VGA 1bpp 链路诚实化**（bus_top/top/vga_dram 全改 1 位）
- ✅ **DRAM 换 BRAM + load freeze**：dist_mem_gen IP → inferred BRAM（`dram_bram.v` + `dram_init.mem`）；load 进 MEM 冻结流水线 1 拍（EXCEPTION_CTRL 驱动 stop_MEM/hold_EX）。**LUT 42.77%→9.38%**，CPU 仿真 PC 正常。
- ✅ 16-19.coe 格式修复；GitHub repo 建好并推送。

**待办：**
- ⏳ **#5 C 工具链**：WSL 装 `gcc-riscv64-unknown-elf` 后，写 linker script + Makefile + elf2coe（裸机，`.text`@IROM 0x0，`.data`@DRAM）。注意 `-march=rv32i -mabi=ilp32 -mno-rvc`，无 mul/div。
- ⚠️ **IROM 换 BRAM**：未做（极高风险——要重设计 IF 取指流水线）。做了才能清掉剩余分布式 RAM（指令 ROM）。
- 🐛 **ALU_SLTU bug**：[ALU.v:30](tiny_rv/tiny_rv.srcs/sources_1/new/ALU.v#L30) `MUXA_out < MUXB_out[4:0]` 应为 `MUXA_out < MUXB_out`。
- 可选：精确 load 值自检（当前只做了 PC 行为级 smoke test）。

## 关键文件
- `tiny_rv.srcs/sources_1/new/`：所有 Verilog 源（CPU 流水线 + 外设）
- `dram_bram.v`：DRAM 的 inferred BRAM（替代 dist_mem_gen IP）
- `EXCEPTION_CTRL.v`：load freeze 逻辑（stalled 标志）
- `bus_top_tb.v` / `ctrl_tb.v`：自检 testbench（xsim 手动跑）
- `coe/`：测试程序 + DRAM 预载（`dram_init.mem`）
- `_claude_verify*.tcl` / `_claude_sim*.tcl`：综合/仿真脚本（参考用）

## Claude 持久记忆
另有跨会话 memory 在 `C:\Users\22917\.claude\projects\e--vibe-coding\memory\`（本文件之外，Claude 自动加载）：项目概况、已知问题状态、xsim 手动流程、早期总线工作记录。
