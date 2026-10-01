<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PO.asl -->
# HL.LD.PO

**Normative ASL source:** `asl/scalar/agu/HL.LD.PO.asl`

HL.LD.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-po-purpose role=purpose -->
## `HL.LD.PO` 做什么

`HL.LD.PO` 是一条 `48` 位的后变址加载指令，读取一个小端序 `8` 字节值。它在 `SrcL` 基址处读取八个字节，把完整的 `64` 位模式发布到 `Dst0`，把更新后的基址 `SrcL + offset` 发布到 `Dst1`。

规范汇编形式是 `hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`。位移是 `SrcR` 经过可选的 `32` 位变换后再左移 `shamt` 位的结果。

设计要点：后变址模式下访问地址只是 `SrcL` 的快照，因此位移不影响访问是否合法。对 `8` 字节加载来说，奇数增量完全可以是合法的后变址步长；它只是让 `Dst1` 落在一个同类访问将会因未对齐而拒绝的地址上。

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-mechanism role=mechanism -->
## 位移与地址如何形成

`SrcR` 经 `SrcRType` 变换后左移编码字段 `shamt` 位；位移按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。

有效地址就是基址本身，`SrcL` 从不被写入。更新后的基址只作为送到 `Dst1` 的值存在。

编码检查与地址预检通过后，执行一次 `8` 字节小端序加载，把 `64` 位原样发布到 `Dst0`，随后把更新后的基址发布到 `Dst1`。

设计要点：位移通过移位施加，因此它的编码形式是寄存器值加移位量，而不是有符号位移字段。负步长通过在 `SrcR` 中放入负值并使用 `.sw` 变换产生，该变换在移位之前对 `SrcR[31:0]` 做符号扩展。

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，`SrcR` 是位移来源；两者都是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `SrcRType` 为 `0` 表示 `SrcR` 不变，`1` 表示对 `SrcR[31:0]` 施加 `.sw`，`2` 表示对 `SrcR[31:0]` 施加 `.uw`；`3` 被保留。
- `shamt` 是变换之后施加的 `5` 位左移量，使步长为变换后值的 `1` 到 `2^31` 倍。
- `Dst0` 收到加载到的模式，`Dst1` 收到更新后的基址。编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：两个目的位置按固定顺序发布，`Dst0` 在前。若两者指定同一个寄存器，更新后的基址会保留下来，而加载到的八个字节在同一条指令内被覆盖，因此这种情况下调用者不能依赖加载值。

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-effects role=effects -->
## 影响、顺序与完成

两个源都在任何内存或目的位置影响之前被读取，因此它们与目的位置之间的别名贡献的是指令执行前的值。

执行成功时记录一个 relaxed 的 `8` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：地址由在任何影响之前取得的 `SrcL` 快照形成，而目的位置在加载完成之后才写入。不存在 `Dst1` 已持有新基址而加载尚未完成的窗口，这正是加载发生故障时基址寄存器与目的位置都保持原样的原因。

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcRType` 为 `3` 会在读取任何源之前被形式约束拒绝；`SrcL` 或 `SrcR` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检检查有效地址的低 `3` 位——在这里就是基址——并在翻译之前、权限检查之前引发 `Fault_DataAlignment`。`8` 字节对齐但未通过权限或有界内存检查的地址会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会从快照重建变换、移位、基址与加载。

<!-- PTO-READER-BLOCK: scalar-hl-ld-po-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ld.po [6, 7<<<0], ->8, 6`，`SrcRType` 选择不变变换，GPR6 = `0x4000`，GPR7 = `3`。
- 位移是 `3`，没有移位。访问地址是旧基址 `0x4000`，因此奇位移在这里不会引发对齐故障。
- GPR8 收到 `0x4000` 至 `0x4007` 的 `8` 字节，GPR6 收到 `0x4000` 加 `3`，即 `0x4003`。
- 之后若用 `0x4003` 作为同类加载的基址，会引发 `Fault_DataAlignment`，因为 `0x4003` 不是 `8` 字节对齐的。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_po_48_870e30995d10 | HL48 | 48 | 0x00003009003e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_po_48_870e30995d10 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ld_po_48_870e30995d10 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ld_po_48_870e30995d10 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_po_48_870e30995d10 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_po_48_870e30995d10 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_po_48_870e30995d10 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ld_po_48_870e30995d10 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ld_po_48_870e30995d10 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ld_po_48_870e30995d10 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ld_po_48_870e30995d10.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PO()
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
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.ld.po [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
