<!-- GENERATED FROM: asl/scalar/agu/LH.asl -->
# LH

**Normative ASL source:** `asl/scalar/agu/LH.asl`

LH snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LH}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lh-purpose role=purpose -->
## `LH` 的作用

`LH` 从基址寄存器加上经转换、移位的索引处加载一个有符号 `2` 字节小端半字，并将其符号扩展到完整的目的宽度。

规范汇编是 `lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`。

设计要点：`LH` 是该族的带符号半字读取，因此存储的 `0x8000` 读回来是负的 `64` 位值。其无符号孪生形式 `LHU` 共用同一套寻址，只在扩展方式上不同。

<!-- PTO-READER-BLOCK: scalar-lh-mechanism role=mechanism -->
## 地址与传输如何形成

偏移量是 `SrcR` 索引经 `SrcRType` 转换后按编码 `shamt` 左移的值，再与 `SrcL` 快照按模 `2^PTO_XLEN` 相加。

预检依次检查 `2` 字节对齐、转换、权限与有界内存。成功后小端读取 `2` 字节（低地址字节成为最低有效字节），并记录一个 relaxed 加载事件。

该半字被符号扩展到 `PTO_XLEN` 并通过 `RegDst` 发布。没有基址寄存器被更新。

设计要点：当 `shamt` 至少为 `1` 时偏移量为偶数，因此有效地址的奇偶性就是基址的奇偶性。只有 `shamt` 为 `0` 时奇数索引才可能产生奇数之和，而对齐阶段判定的正是这个和。

<!-- PTO-READER-BLOCK: scalar-lh-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcL` 是基址选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 是索引选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcRType` 选择不变、`.sw` 或 `.uw`，并保留 `3`；`shamt` 覆盖 `0`..`31`，在转换之后应用。
- `RegDst` 是目的端选择子。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：`SrcRType` 是带一个保留取值的 `2` 位字段，该保留取值在合法性阶段被拒绝，而不是被当作第四种转换。

<!-- PTO-READER-BLOCK: scalar-lh-effects role=effects -->
## 效果、顺序与完成

所有源在内存访问之前取快照，因此目的端同时作为基址的编码仍按指令执行前的基址计算地址。

成功时记录一个 relaxed 加载事件，内存与保留保持不变，发布符号扩展后的半字，并使 `TPC` 前进 `4` 字节。

设计要点：只有在预检通过之后才发布结果，因此发生故障的 `LH` 会让 `RegDst` 保持原值，即使目的端就是基址寄存器。

<!-- PTO-READER-BLOCK: scalar-lh-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配、`SrcRType` 取保留值或所选 `T`/`U` 源不可用，都会在任何指令效果之前于指令地址处引发 `Fault_IllegalInstruction`。
- 不是 `2` 的倍数的和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不发布结果，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：未对齐的半字地址在转换与权限之前就被报告，因此同时也会违反权限检查的地址会被报告为 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-lh-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 `SrcL` = `0x100`、`SrcR` = `1`、`shamt` 为 `1`、`SrcRType` 为 `0` 时，偏移量是 `2`，地址是 `0x102`。
- `0x102` 处的字节 `00 80` 是小端半字 `0x8000`，在 `RegDst` 中符号扩展为 `0xFFFFFFFFFFFF8000`。
- 把 `shamt` 改为 `0` 并使用奇数索引会把访问移到奇数地址并引发 `Fault_DataAlignment`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lh_32_d0f04d7d7696 | L32 | 32 | 0x00001009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lh_32_d0f04d7d7696 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lh_32_d0f04d7d7696 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lh_32_d0f04d7d7696 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lh_32_d0f04d7d7696 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lh_32_d0f04d7d7696 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lh_32_d0f04d7d7696 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lh_32_d0f04d7d7696 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lh_32_d0f04d7d7696 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lh_32_d0f04d7d7696.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LH.asl -->
```asl
readonly func InstructionContractOperation_LH() => ScalarOperation
begin
    return ScalarOperation_LH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LH.asl -->
```asl
readonly func InstructionContractHandler_LH()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LH()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LH()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LH()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LH()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LH()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LH()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lh [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
