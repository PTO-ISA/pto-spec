<!-- GENERATED FROM: asl/scalar/agu/LBU.asl -->
# LBU

**Normative ASL source:** `asl/scalar/agu/LBU.asl`

LBU snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbu-purpose role=purpose -->
## `LBU` 的作用

`LBU` 是索引族的无符号字节读取：它形成与 `LB` 相同的 `SrcL` 基址加移位后的 `SrcR` 偏移，但加载的字节做零扩展而不是符号扩展。

规范汇编是 `lbu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：`LBU` 与 `LB` 从相同字段译出相同地址。唯一区别是作用于所加载字节的扩展方式，因此两者互换不会改变所访问的地址，也不会改变可能出现的故障。

<!-- PTO-READER-BLOCK: scalar-lbu-mechanism role=mechanism -->
## 地址与传输如何形成

偏移量是 `SrcR` 经 `SrcRType` 转换、按 `shamt` 左移后的值，并与基址按模 `2^PTO_XLEN` 相加。转换后的索引是完整的 `64` 位字，因此移位消耗的正是按 `.sw` 或 `.uw` 读取低 `32` 位的结果。

地址先按 `1` 字节对齐预检，再转换，然后检查权限与有界内存。成功后指令小端读取 `1` 字节，记录一个 relaxed 加载事件，并发布零扩展后的字节。

本形式不做基址回写，只发布加载到的值。

设计要点：`LBU` 之后 `RegDst` 的第 `8` 位及以上始终为 `0`，因为零扩展会替换整个目的字。因此存储的 `0xFF` 读回来是 `255`，绝不会是 `-1`。

<!-- PTO-READER-BLOCK: scalar-lbu-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 是索引选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcRType` 的 `0`、`1`、`2` 分别选择不变、`.sw` 与 `.uw`；原始值 `3` 保留。`shamt` 覆盖 `0`..`31`，并在转换之后应用。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：目的端编码 `30` 或 `31` 会把加载到的字节压入 `U` 或 `T` 队列而不是 GPR，原先位于 `U#4` 或 `T#4` 的条目被挤出队列。

<!-- PTO-READER-BLOCK: scalar-lbu-effects role=effects -->
## 效果、顺序与完成

所有源都在内存访问之前取快照，因此与基址或索引同名的目的端不会改变本次加载使用的地址。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，发布零扩展后的字节，并使 `TPC` 前进 `4` 字节。

设计要点：加载事件记录转换后的地址、`1` 字节宽度、加载值以及 relaxed 顺序，因此该记录精确描述被读取的内容，别不多记。

<!-- PTO-READER-BLOCK: scalar-lbu-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配、`SrcRType` 取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。
- 访问必须先满足 `1` 字节对齐，之后才检查转换与权限；权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 任何故障都不会发布结果、不记录事件，`TPC` 停留在引发故障的指令上，使整个尝试可以完整重发。
- 设计要点：由于传输只有一字节，对齐阶段不可能失败，生成的对齐措辞描述的是一项任何 `LBU` 编码都无法触发的检查。

<!-- PTO-READER-BLOCK: scalar-lbu-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x100`、`SrcR` = `2`、`SrcRType` 为 `0`、`shamt` 为 `0` 时，有效地址是 `0x102`。
- 该地址处的字节 `0x80` 发布为 `0x80`，而同一个字节经 `LB` 会发布为 `0xFFFFFFFFFFFFFF80`。
- 基址 `0x1000` 配索引 `-1` 与 `shamt` `0` 时读取 `0xFFF`，因为偏移量按模 `2^PTO_XLEN` 相加。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbu_32_a9a58ab4ea22 | L32 | 32 | 0x00004009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbu_32_a9a58ab4ea22 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbu_32_a9a58ab4ea22 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lbu_32_a9a58ab4ea22 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lbu_32_a9a58ab4ea22 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lbu_32_a9a58ab4ea22 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbu_32_a9a58ab4ea22 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbu_32_a9a58ab4ea22 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lbu_32_a9a58ab4ea22 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lbu_32_a9a58ab4ea22 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lbu_32_a9a58ab4ea22 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lbu_32_a9a58ab4ea22.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBU.asl -->
```asl
readonly func InstructionContractOperation_LBU() => ScalarOperation
begin
    return ScalarOperation_LBU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBU.asl -->
```asl
readonly func InstructionContractHandler_LBU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBU()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBU()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LBU()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBU()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBU()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBU()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBU()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lbu [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
