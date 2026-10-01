<!-- GENERATED FROM: asl/scalar/agu/LD.asl -->
# LD

**Normative ASL source:** `asl/scalar/agu/LD.asl`

LD snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ld-purpose role=purpose -->
## `LD` 的作用

`LD` 通过索引地址加载一个完整的 `8` 字节小端单元，并发布加载到的全部 `64` 位。它是寄存器索引加载族中宽度最大的一员。

规范汇编是 `ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：传输宽度是 `8` 字节，而移位是可编程的 `5` 位字段，因此同一条指令既能以 `shamt` `0` 做按字节步进，也能以 `shamt` `3` 做 `8` 字节步进的表遍历。

<!-- PTO-READER-BLOCK: scalar-ld-mechanism role=mechanism -->
## 地址与传输如何形成

索引是 `SrcR` 经 `SrcRType` 转换后按 `shamt` 左移的值，再与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。移位作用于转换后的 `64` 位值，因此 `.sw` 与 `.uw` 在移位之前就已确定。

预检先检查 `8` 字节对齐，再转换，然后检查权限与有界内存。成功后小端读取 `8` 字节并记录一个 relaxed 加载事件。

该值不需要扩展：加载到的每一位都成为目的字。本形式不做基址回写。

设计要点：`shamt` 可以使本来对齐的基址离开 `8` 字节边界，因为对齐规则作用于和而不是基址。`shamt` 为 `1`、索引为 `3` 时得到偏移量 `6`。

<!-- PTO-READER-BLOCK: scalar-ld-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 是索引选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcRType` 选择不变、`.sw` 或 `.uw`；`3` 保留。`shamt` 覆盖 `0`..`31`。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：`.uw` 索引是 `SrcR` 低 `32` 位的零扩展，因此 `32` 位负索引会变成很大的正偏移，只由加法的 `64` 位回绕来约简。

<!-- PTO-READER-BLOCK: scalar-ld-effects role=effects -->
## 效果、顺序与完成

所有源都在内存访问与目的端写入之前取快照，因此与基址或索引同名的目的端只会在地址依据旧值计算完毕后才收到加载值。

成功时记录一个 relaxed 加载事件，不改变任何内存字节，保留保持不变，发布完整的 `64` 位值，并使 `TPC` 前进 `4` 字节。

设计要点：加载不触碰保留状态，因此读取被守护的字不会破坏在同一地址上取得的保留。

<!-- PTO-READER-BLOCK: scalar-ld-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配、`SrcRType` 取保留值或所选 `T`/`U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。
- 不是 `8` 的倍数的和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录加载事件，不向 `RegDst` 发布任何结果，并让 `TPC` 停留在引发故障的指令上，使尝试可以完整重发。
- 设计要点：对齐依据和来判定，因此仅有对齐的基址还不够；移位后的索引也会影响低三位。

<!-- PTO-READER-BLOCK: scalar-ld-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x2000`、`SrcR` = `3`、`shamt` 为 `1`、`SrcRType` 为 `0` 时，偏移量是 `6`，和 `0x2006` 不是 `8` 字节对齐，因此引发 `Fault_DataAlignment`。
- 同样的寄存器配 `shamt` `3` 时，偏移量是 `24`，地址是 `0x2018`；从该处加载 `8` 字节。
- 若这些字节按内存顺序是 `01 02 03 04 05 06 07 08`，则 `RegDst` 收到 `0x0807060504030201`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_32_7c48838bc4e6 | L32 | 32 | 0x00003009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_32_7c48838bc4e6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ld_32_7c48838bc4e6 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| ld_32_7c48838bc4e6 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ld_32_7c48838bc4e6 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ld_32_7c48838bc4e6 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ld_32_7c48838bc4e6 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| ld_32_7c48838bc4e6 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| ld_32_7c48838bc4e6 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `ld_32_7c48838bc4e6.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LD.asl -->
```asl
readonly func InstructionContractOperation_LD() => ScalarOperation
begin
    return ScalarOperation_LD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LD.asl -->
```asl
readonly func InstructionContractHandler_LD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LD()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LD()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LD()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LD()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LD()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- ld [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
