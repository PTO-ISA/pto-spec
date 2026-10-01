<!-- GENERATED FROM: asl/scalar/agu/LHI.U.asl -->
# LHI.U

**Normative ASL source:** `asl/scalar/agu/LHI.U.asl`

LHI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhi-u-purpose role=purpose -->
## `LHI.U` 的作用

`LHI.U` 在距基址寄存器的、不带比例的立即数位移处加载一个有符号 `2` 字节半字。`.u` 后缀标记不带比例的寻址形式，因此 `simm12` 以字节计数。

规范汇编是 `lhi.u [SrcL, simm], ->{t, u, Rd}`。

设计要点：该字段仍为带符号数，因此窗口是基址下方 `2048` 字节、上方 `2047` 字节。两个半窗大小并不相同。

<!-- PTO-READER-BLOCK: scalar-lhi-u-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `simm12`，不经过移位直接与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。每个编码单位对应 `1` 字节地址。

预检依次检查 `2` 字节对齐、转换、权限与有界内存。成功后小端读取 `2` 字节并记录一个 relaxed 加载事件。

该半字被符号扩展并通过 `RegDst` 发布；没有基址回写。

设计要点：由于位移不按比例缩放，它可以改变和的最低位。奇数基址加奇数位移仍然满足 `2` 字节对齐，而按比例缩放的 `LHI` 无法做到这一点。

<!-- PTO-READER-BLOCK: scalar-lhi-u-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm12` 为带符号数，覆盖 `-2048`..`2047`，且不加比例使用。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：本形式没有 `SrcRType` 也没有 `shamt`；除基址之外，它改变地址的唯一手段就是 `12` 位位移本身。

<!-- PTO-READER-BLOCK: scalar-lhi-u-effects role=effects -->
## 效果、顺序与完成

基址在内存操作与发布之前取快照，因此读到的值从不依赖本指令执行的写入。

成功时记录一个 relaxed 加载事件，内存与保留保持不变，发布符号扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：目的值只取决于访问宽度与该加载的符号性，而不取决于寻址形式，因此 `LHI` 与 `LHI.U` 对相同字节发布相同的位模式。

<!-- PTO-READER-BLOCK: scalar-lhi-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或 `SrcL` 选择子指向不可用的 `T`/`U` 条目，会在读取任何源值之前引发 `Fault_IllegalInstruction`。
- 奇数之和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上，使重发时重新计算同一地址。
- 设计要点：与按比例缩放的形式相比，唯一区别是比例，因此故障集合相同；奇数之和仍被报告为 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-lhi-u-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x1001`、`simm12` = `1` 时，地址是 `0x1002`，它满足 `2` 字节对齐，因为不带比例的位移补上了缺失的最低位。
- 同一基址配 `simm12` = `2` 时地址是 `0x1003`，即奇数，因此引发 `Fault_DataAlignment`。
- 在 `0x1002` 读取的带符号半字会符号扩展到 `RegDst`，与 `LHI` 完全一致。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhi_u_32_bb0c81c6e61d | L32 | 32 | 0x00001029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhi_u_32_bb0c81c6e61d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhi_u_32_bb0c81c6e61d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhi_u_32_bb0c81c6e61d | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhi_u_32_bb0c81c6e61d | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhi_u_32_bb0c81c6e61d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhi_u_32_bb0c81c6e61d | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractOperation_LHI_U() => ScalarOperation
begin
    return ScalarOperation_LHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractHandler_LHI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LHI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHI_U()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHI_U()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhi.u [SrcL, simm], ->{t, u, Rd}
