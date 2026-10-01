<!-- GENERATED FROM: asl/scalar/agu/LWI.asl -->
# LWI

**Normative ASL source:** `asl/scalar/agu/LWI.asl`

LWI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwi-purpose role=purpose -->
## `LWI` 做什么

`LWI` 从 `SrcL` 加一个按 `4` 缩放的有符号立即数处加载小端 `4` 字节字，再把加载到的 `32` 位符号扩展到 `PTO_XLEN`。其规范汇编是 `lwi [SrcL, simm], ->{t, u, Rd}`。

设计要点：`simm12` 字段以 `4` 字节为单位计数，因此可编码的位移是 `-2048` 到 `2047` 个单位，即 `-8192` 到 `8188` 字节。缩放等于访问宽度，这正是对齐基址保持对齐的原因。

<!-- PTO-READER-BLOCK: scalar-lwi-mechanism role=mechanism -->
## `LWI` 如何形成地址并完成访问

`simm12` 从 `12` 位符号扩展到 `PTO_XLEN`，再左移 `2` 位，即乘以 `4`。缩放后的位移与 `SrcL` 基址按 `2^PTO_XLEN` 取模相加。

该和被一次小端 `4` 字节加载使用。此形式没有基址回写，也没有第二个目的端。只有在加载报告无故障时，加载字的位 `31`:`0` 才被符号扩展并通过 `RegDst` 写入。

设计要点：移位发生在符号扩展之后，因此范围的负端保持为负。编码 `-1` 产生的位移是 `-4`，而把同样的 `12` 位当作无符号数则会加上 `16380`。

<!-- PTO-READER-BLOCK: scalar-lwi-inputs role=inputs-outputs -->
## 编码字段与值的去向

- `SrcL` 是 `5` 位 Reg5 源。编码 `0`..`23` 命名绝对 GPR，`24`..`27` 命名 `T#1`..`T#4`，`28`..`31` 命名 `U#1`..`U#4`。读取 `T` 或 `U` 槽位既不消费也不重排它，编码 `0` 提供恒为零的 GPR。
- `simm12` 是有符号 `12` 位字段，因此全部 `4096` 个编码都是取值，编码为零提供零位移，并不表示省略。
- `RegDst` 是 `5` 位目的端：编码 `1`..`23` 写绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 与 `24`..`29` 丢弃加载值。

设计要点：乘数 `4` 由编码固定，且没有可覆盖它的移位字段。不是 `4` 的倍数的字节位移根本无法用本形式表达，这正是 `LWI.U` 存在的原因。

<!-- PTO-READER-BLOCK: scalar-lwi-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的端效果之前被读取，因此与基址同名的目的端仍使用指令执行前的值：`lwi [1, 2], ->1` 用旧的 `1` 加 `8` 加载，之后才覆盖 `1`。

成功执行会完成一次 relaxed `4` 字节加载并记录一个加载事件。内存字节不变，保留状态得以保持。随后 `TPC` 前移 `4` 字节。

设计要点：加载事件与目的端写入是仅有的效果，因此指令退休后，基址寄存器、内存内容或顺序状态都不会残留任何东西。

<!-- PTO-READER-BLOCK: scalar-lwi-constraints role=constraints -->
## 合法性、故障与重启

当固定编码比特不匹配，或所选 `T`/`U` 源槽位因从未被压入而不可用时，分派会在任何效果之前以 `Fault_IllegalInstruction` 拒绝该指令。

预检检查有效地址的低 `2` 位，非零值会在翻译之前、权限测试之前引发 `Fault_DataAlignment`。对齐但未通过权限或有界内存测试的地址会在原始地址引发 `Fault_DataPage`；PTO v0 的翻译是恒等函数，因此不存在单独的翻译故障。

故障不记录加载事件、不写目的端，并把 `TPC` 留在故障指令上。恢复会重发整个操作：每一次源读取、地址运算、预检、加载以及发布。

设计要点：本形式能产生的每个位移都是 `4` 的倍数，因此只有 `SrcL` 本身不满足 `4` 字节对齐时对齐才会失败。对齐结果因此取决于程序的数据布局，而不是编码的立即数。

<!-- PTO-READER-BLOCK: scalar-lwi-example role=example -->
## 完整读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 取 `lwi [3, -1], ->5`，设 GPR3 = `0x1000`。
- `simm12=-1` 符号扩展为 `-1`，再乘以 `4`，因此位移是 `-4`。
- 有效地址是 `0x1000` 减 `4`，即 `0x0FFC`。
- `0x0FFC` 满足 `4` 字节对齐，预检通过；`0x0FFC` 到 `0x0FFF` 的 `4` 字节被符号扩展写入 GPR5，`TPC` 前移 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | L32 | 32 | 0x00002019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwi_32_7085c98058fa | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwi_32_7085c98058fa | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lwi_32_7085c98058fa | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractOperation_LWI() => ScalarOperation
begin
    return ScalarOperation_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractHandler_LWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lwi [SrcL, simm], ->{t, u, Rd}
