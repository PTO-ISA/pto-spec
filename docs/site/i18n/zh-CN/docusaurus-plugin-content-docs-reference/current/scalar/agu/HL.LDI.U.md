<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.U.asl -->
# HL.LDI.U

**Normative ASL source:** `asl/scalar/agu/HL.LDI.U.asl`

HL.LDI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-purpose role=purpose -->
## `HL.LDI.U` 做什么

`HL.LDI.U` 是一条 `48` 位加载指令，读取一个小端序 `8` 字节值，使用未缩放的 `22` 位立即数位移且不更新基址。它把立即数逐字节地加到 `SrcL` 基址上，在该和处读取八个字节，并把完整的 `64` 位模式发布到 `RegDst`。

规范汇编形式是 `hl.ldi.u [SrcL, simm], ->{t, u, Rd}`。

设计要点：立即数不做缩放，因此它计的是字节，而访问覆盖其中八个字节。对齐预检要求和是 `8` 的倍数，这意味着在 `8` 字节对齐的基址下，只有本身是 `8` 的倍数的立即数才会产生合法访问。因此本形式能到达 `4194304` 字节窗口内的任何字节，但其中只有八分之一的地址能承载 `8` 字节加载。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-mechanism role=mechanism -->
## 地址与传输如何形成

有符号 `22` 位立即数被符号扩展，并按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。更新模式为无，因此这个和就是有效地址，除加载值之外不发布任何东西。

`SrcL` 只被读取，处理程序根本不计算用于发布的更新基址。

编码检查与地址预检通过后，处理程序执行一次 `8` 字节小端序加载，并把字节原样发布到 `RegDst`。

设计要点：缩放因子与访问大小不匹配的立即数加载，把对齐的责任转移到了编码字段上。由于立即数是编译期常量，是 `8` 的倍数的那部分取值可以在汇编时选定，无需运行期检查把它们与其他取值区分开。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm22` 是有符号 `22` 位立即数，覆盖 `-2097152` 到 `2097151` 字节，不做缩放。
- `RegDst` 是 `5` 位选择子：编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该值。

设计要点：加载到的 `64` 位经过发布时没有扩展步骤，因此目的位置持有的就是内存中的确切映像。在本宽度上记录的符号性没有效果，因为 `8` 字节值的归一化在两个方向上都是恒等。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前取快照，因此指定基址的目的位置仍然为地址提供指令执行前的值。

执行成功时记录一个 relaxed 的 `8` 字节加载事件，内存字节与保留状态保持不变。发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：由于故障不发布任何东西，而基址从不被本指令推进，重试会重复完全相同的访问。没有任何状态需要回退，两次尝试之间也不存在跳过某个字节的可能。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码中不存在变换或移位字段。

预检检查有效地址的低 `3` 位，并在翻译之前、权限检查之前引发 `Fault_DataAlignment`；当基址 `8` 字节对齐时，任何不是 `8` 的倍数的立即数都会得到这个结果。对齐但未通过权限或有界内存检查的地址会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会重复符号扩展、求和与预检。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ldi.u [6, 8], ->5`，GPR6 = `0xC000`。立即数是 `8`，是 `8` 的倍数，因此有效地址是 `0xC008`，并且 `8` 字节对齐。
- 该指令读取 `0xC008` 至 `0xC00F` 的 `8` 字节，并把整个 `64` 位模式发布到 GPR5。
- 若立即数改为 `1`，地址将是 `0xC001`，指令会在翻译之前引发 `Fault_DataAlignment`。
- GPR6 仍持有 `0xC000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_u_48_894d02c12dcc | HL48 | 48 | 0x00003029000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_u_48_894d02c12dcc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_u_48_894d02c12dcc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_u_48_894d02c12dcc | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_u_48_894d02c12dcc | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_u_48_894d02c12dcc | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_u_48_894d02c12dcc | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_U()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.ldi.u [SrcL, simm], ->{t, u, Rd}
