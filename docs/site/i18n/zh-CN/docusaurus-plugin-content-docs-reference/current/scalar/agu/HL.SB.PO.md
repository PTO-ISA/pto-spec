<!-- GENERATED FROM: asl/scalar/agu/HL.SB.PO.asl -->
# HL.SB.PO

**Normative ASL source:** `asl/scalar/agu/HL.SB.PO.asl`

HL.SB.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SB-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sb-po-purpose role=purpose -->
## HL.SB.PO 的作用

`HL.SB.PO` 是一条独立的 `48` 位标量 AGU 指令，使用 `Register` 寻址，按小端序存储一个 `1` 字节值。

<!-- PTO-READER-BLOCK: scalar-hl-sb-po-mechanism role=mechanism -->
## 地址与传输机制

寄存器偏移路径先按 `SrcRType` 对 `SrcR` 做编码指定的变换，再把变换后的偏移与快照中的 `SrcL` 相加，结果按 `2^PTO_XLEN` 取模。缩放因子固定为 `1`，并且不编码 `shamt` 字段。

完整预检通过后，在所选地址提交一次对齐的小端序 `1` 字节存储。

后索引模式访问原始基址，并且只在内存操作成功后发布“基址加偏移”的结果。

<!-- PTO-READER-BLOCK: scalar-hl-sb-po-inputs role=inputs-outputs -->
## 编码输入与输出

- `RegDst` 是一个 `5` 位字段，用来选择更新后基址结果。
- `SrcD` 是一个 `5` 位字段，用来选择第一个存储数据值。
- `SrcL` 是一个 `5` 位字段，用来选择地址基址。
- `SrcR` 是一个 `5` 位字段，用来选择寄存器偏移。
- `SrcRType` 是一个 `2` 位字段，用来选择寄存器偏移变换。

<!-- PTO-READER-BLOCK: scalar-hl-sb-po-effects role=effects -->
## 影响与完成顺序

所有显式和隐式标量源都会在任何内存或目的位置影响之前完成快照，因此别名读取指令执行前的值。

执行成功时记录一个 relaxed 存储事件；只有完整预检通过后，重叠的保留状态才会失效。

所有结果或回写发布完成后，`HL.SB.PO` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

<!-- PTO-READER-BLOCK: scalar-hl-sb-po-constraints role=constraints -->
## 合法性、故障与重启

每个访问地址都按 `1` 字节传输单元对齐。未对齐会在翻译前选择 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址选择 `Fault_DataPage`。

固定位不匹配、字段取保留值或选中的 T/U 源不可用，会在指令影响之前选择 `Fault_IllegalInstruction`。

发生故障时不记录成功内存事件，也不提交部分内存、结果或回写影响。重新执行会从头重新计算源快照、地址、预检、传输和发布。

<!-- PTO-READER-BLOCK: scalar-hl-sb-po-example role=example -->
## 非规范阅读步骤

下面只说明如何使用本页，不增加指令行为。

- 从规范汇编形式 `hl.sb.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}` 开始，找出已编码的地址字段。
- 然后把上面的寻址模式、传输动作、完成影响和故障边界，与下方确切的生成 ASL 契约逐项对照。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sb.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sb_po_48_c21837f2c14d | HL48 | 48 | 0x00000049003e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sb_po_48_c21837f2c14d | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sb_po_48_c21837f2c14d | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sb_po_48_c21837f2c14d | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sb_po_48_c21837f2c14d | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sb_po_48_c21837f2c14d | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sb_po_48_c21837f2c14d | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sb_po_48_c21837f2c14d | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sb_po_48_c21837f2c14d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sb_po_48_c21837f2c14d | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sb_po_48_c21837f2c14d | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SB_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SB_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SB_PO()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SB_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SB_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SB_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SB_PO()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. The register offset uses a fixed scale factor of 1; no shamt field is encoded.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- All four SrcRType values are assigned; apply the selected modifier with the fixed scale factor of 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sb.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}
