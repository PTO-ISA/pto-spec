<!-- GENERATED FROM: asl/scalar/agu/HL.LDP.asl -->
# HL.LDP

**Normative ASL source:** `asl/scalar/agu/HL.LDP.asl`

HL.LDP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 8-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LDP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldp-purpose role=purpose -->
## HL.LDP 的作用

`HL.LDP` 是一条独立的 `48` 位标量 AGU 指令，使用 `Register` 寻址，按小端序加载两个相邻的 `8` 字节值；当结果窄于 `PTO_XLEN` 时，分别对两个传输值进行零扩展。

<!-- PTO-READER-BLOCK: scalar-hl-ldp-mechanism role=mechanism -->
## 地址与传输机制

寄存器偏移路径先按 `SrcRType` 对 `SrcR` 做编码指定的变换，再左移 `shamt` 位，并与快照中的 `SrcL` 相加，结果按 `2^PTO_XLEN` 取模。

两个相邻地址会在任一次对齐的小端序 `8` 字节加载发生前全部完成预检。每个结果都会保留完整 64 位模式；两次加载按地址递增顺序提交。

该形式不发布地址基址回写。

<!-- PTO-READER-BLOCK: scalar-hl-ldp-inputs role=inputs-outputs -->
## 编码输入与输出

- `RegDst0` 是一个 `5` 位字段，用来选择第一个加载值结果。
- `RegDst1` 是一个 `5` 位字段，用来选择第二个加载值结果。
- `SrcL` 是一个 `5` 位字段，用来选择地址基址。
- `SrcR` 是一个 `5` 位字段，用来选择寄存器偏移。
- `SrcRType` 是一个 `2` 位字段，用来选择寄存器偏移变换。
- `shamt` 是一个 `5` 位字段，用来选择变换后的左移量。

<!-- PTO-READER-BLOCK: scalar-hl-ldp-effects role=effects -->
## 影响与完成顺序

所有显式和隐式标量源都会在任何内存或目的位置影响之前完成快照，因此别名读取指令执行前的值。

执行成功时记录两个按地址顺序排列的 relaxed 加载事件；内存和保留状态保持不变。

所有结果或回写发布完成后，`HL.LDP` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

<!-- PTO-READER-BLOCK: scalar-hl-ldp-constraints role=constraints -->
## 合法性、故障与重启

每个访问地址都按 `8` 字节传输单元对齐。未对齐会在翻译前选择 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址选择 `Fault_DataPage`。

固定位不匹配、字段取保留值或选中的 T/U 源不可用，会在指令影响之前选择 `Fault_IllegalInstruction`。

发生故障时不记录成功内存事件，也不提交部分内存、结果或回写影响。重新执行会从头重新计算源快照、地址、预检、传输和发布。

<!-- PTO-READER-BLOCK: scalar-hl-ldp-example role=example -->
## 非规范阅读步骤

下面只说明如何使用本页，不增加指令行为。

- 从规范汇编形式 `hl.ldp [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1` 开始，找出已编码的地址字段。
- 然后把上面的寻址模式、传输动作、完成影响和故障边界，与下方确切的生成 ASL 契约逐项对照。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldp_48_a7a45a43dff9 | HL48 | 48 | 0x00003009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldp_48_a7a45a43dff9 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ldp_48_a7a45a43dff9 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldp_48_a7a45a43dff9 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldp_48_a7a45a43dff9 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldp_48_a7a45a43dff9 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldp_48_a7a45a43dff9 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ldp_48_a7a45a43dff9 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ldp_48_a7a45a43dff9 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ldp_48_a7a45a43dff9.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDP.asl -->
```asl
readonly func InstructionContractOperation_HL_LDP() => ScalarOperation
begin
    return ScalarOperation_HL_LDP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDP.asl -->
```asl
readonly func InstructionContractHandler_HL_LDP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LDP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LDP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LDP()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDP()
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
- The pair addresses are address and address plus 8; the instruction performs no base writeback.
- After both 8-byte probes succeed, preserve each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 8-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ldp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
