<!-- GENERATED FROM: asl/scalar/agu/HL.SH.UPR.asl -->
# HL.SH.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SH.UPR.asl`

HL.SH.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SH-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-purpose role=purpose -->
## `HL.SH.UPR` 存储什么

`HL.SH.UPR` 是一条独立的 `48` 位标量 AGU 指令，在 `SrcL` 与未移位寄存器位移之和处存储来自 `SrcD` 的一个小端 `2` 字节单元。

规范汇编是 `hl.sh.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}`。

设计要点：位移就是原始字节数，因此混合了 `2` 字节与其它字节步长的遍历可以用同一个寄存器作为字节游标，而不必事先做除法。

<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-mechanism role=mechanism -->
## 地址如何形成

位移是经 `SrcRType` 选择后的 `SrcR` 快照，不做移位，再按 `2^PTO_XLEN` 取模加到 `SrcL` 快照上，得到计算出的地址。

标度为 `0`，因此位移就是经变换的 `SrcR` 值本身，访问地址是 `SrcL` 加上该字节数。

更新模式为前索引：访问使用 `SrcL` 与位移之和，并且同一个和会在存储成功之后发布给 `RegDst`。

预检在存储之前进行，`SrcD` 在该预检之前读取；成功时执行一次 `2` 字节小端存储并记录一个 relaxed 存储事件。

设计要点：奇数字节位移可以编码，因此地址可能是奇数；当 `SrcL` 为 `0x1000`、位移为 `5` 时访问地址是 `0x1005`，对齐预检会在地址转换之前以 `Fault_DataAlignment` 拒绝它。

<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-inputs role=inputs-outputs -->
## 操作数

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `SrcRType` 是 `2` 位，在移位之前作用于 `SrcR`：`00` 保持整个寄存器值，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。

- `RegDst` 是 `5` 位目的选择子：编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制存储。

设计要点：发布的值恰好就是访问地址，因此前索引形式绝不会发布一个与刚刚访问过的范围不同的基址。

<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-effects role=effects -->
## 影响与顺序

`SrcL`、`SrcR` 与 `SrcD` 都在存储之前读取，因此即使 `RegDst` 指定其中之一，也不会改变基址、位移或存储数据。

执行成功时记录一个 relaxed 存储事件，只改变该单元的 `2` 字节。

当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

更新后的基址在存储之后发布，随后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：对齐的存储写入 `SrcD` 的低 `2` 字节，然后发布该和；未对齐的存储什么也不写，也不发布任何值。

<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-constraints role=constraints -->
## 对齐、故障与重启

- 有效地址必须是 `2` 的倍数。未对齐的地址会在地址转换或权限检查之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- `SrcRType` 的原始值 `11` 为保留值：它会在读取任何源之前于 `PC` 处引发 `Fault_IllegalInstruction`，因此地址修饰符解码只定义 `00`、`01` 与 `10`。

- 发生故障时不记录存储事件也不发布基址：内存、`SrcD`、`RegDst` 与 `TPC` 保持原值，恢复时重新计算快照、地址、预检与存储。

设计要点：对齐测试在权限检查之前针对计算出的和运行，因此即使该范围也会失败于有界内存检查，奇数地址仍会以 `Fault_DataAlignment` 报告。

<!-- PTO-READER-BLOCK: scalar-hl-sh-upr-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.sh.upr 20, [2, 7], ->4`，其中 `SrcRType` 为 `01`，GPR2 = `0x1000`，GPR7 = `0x4` 与 GPR20 = `0xbeef`。

- 索引 `0x4` 直接作为字节位移使用，得到 `4`，因此有效地址是 `0x1004`，同一个值也发布给 `RegDst` `4`。

- 该存储按地址递增顺序把 `0xef`、`0xbe` 写到 `0x1004` 到 `0x1005`。

- `SrcD` 与 `SrcL` 保持指令执行前的值，`RegDst` `4` 收到 `0x1004` 之后 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sh.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sh_upr_48_719102d66e45 | HL48 | 48 | 0x00005049002e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sh_upr_48_719102d66e45 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sh_upr_48_719102d66e45 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sh_upr_48_719102d66e45 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sh_upr_48_719102d66e45 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sh_upr_48_719102d66e45 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sh_upr_48_719102d66e45 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sh_upr_48_719102d66e45 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sh_upr_48_719102d66e45 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sh_upr_48_719102d66e45 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sh_upr_48_719102d66e45 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sh_upr_48_719102d66e45.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SH.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SH_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SH_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SH.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SH_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SH_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SH_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SH_UPR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SH_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SH_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SH_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SH_UPR()
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

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sh.upr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
