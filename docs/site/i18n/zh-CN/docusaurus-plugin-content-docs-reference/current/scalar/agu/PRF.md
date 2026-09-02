<!-- GENERATED FROM: asl/scalar/agu/PRF.asl -->
# PRF

**Normative ASL source:** `asl/scalar/agu/PRF.asl`

PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-prf-purpose role=purpose -->
## PRF 的作用

`PRF` 是一条独立的 `32` 位 AGU 指令；它形成寄存器偏移地址，并发出一条不产生目的端效果的非约束性预取提示。

<!-- PTO-READER-BLOCK: scalar-prf-mechanism role=mechanism -->
## 地址与内存机制

`PRF` 先按 `SrcRType` 转换 `SrcR`，再按编码的 `shamt` 左移，并将结果按 `2^PTO_XLEN` 取模后加到快照中的 `SrcL` 基址。

形成的地址只是一条非约束性、粒度为一字节的预取提示；合法执行不产生架构地址转换、内存访问、内存事件、保留更新、排序边或缓存放置保证。

任何编码目的端都不会发布提示地址，该指令也不更新基址寄存器。

<!-- PTO-READER-BLOCK: scalar-prf-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供基址；`SrcR` 提供寄存器偏移量；`SrcRType` 提供偏移量转换方式。其中的 Reg5 源 `SrcL`、`SrcR` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `RegDst` 是忽略别名；所有 `RegDst` 编码都是已分配且不写入的别名。
- `SrcRType` 的 `0..3` 和 `shamt` 的 `0..31` 均已分配；先执行转换，再执行编码移位。

<!-- PTO-READER-BLOCK: scalar-prf-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

合法提示不产生内存事件、保留变化或目的端写入，并将 `TPC` 前移 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-prf-constraints role=constraints -->
## 对齐、故障与重启

合法预取不执行数据对齐、地址转换、权限或有界内存检查，因此不会引发数据访问故障。

保留的预取模型会在读取源和任何可选地址发布之前拒绝。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-prf-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、偏移源为不经转换的 `2`，并采用 `shamt=1`，形成的提示地址就是 `0x104`；该地址只作为非约束性提示发出，不产生架构内存或目的端效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | L32 | 32 | 0x00007009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| prf_32_30e6dfe4e3ce | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | 0–31 | none | none | ignored encoded alias field | Encoded zero is the canonical ignored alias value and names no destination. |
| prf_32_30e6dfe4e3ce | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| prf_32_30e6dfe4e3ce | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `prf_32_30e6dfe4e3ce.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | ignored encoded alias field |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractHandler_PRF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRF()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRF()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_PRF()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRF()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRF()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRF()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRF()
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
- Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- prf [SrcL, SrcR<{.sw,.uw}><<<shamt>]
