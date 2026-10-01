<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.PR.asl -->
# HL.LDI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LDI.PR.asl`

HL.LDI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-purpose role=purpose -->
## `HL.LDI.PR` 做什么

`HL.LDI.PR` 是一条 `48` 位的前变址加载指令，读取一个小端序 `8` 字节值并使用立即数位移。它把立即数按 `8` 缩放，加到 `SrcL` 基址上，在该和处读取八个字节，把 `64` 位模式发布到 `Dst0`，并把同一个和发布到 `Dst1`。

规范汇编形式是 `hl.ldi.pr [SrcL, simm], ->Dst0, Dst1`。

设计要点：由于位移永远是 `8` 的倍数，`8` 字节对齐的基址在更新之后仍然 `8` 字节对齐。因此把 `Dst1` 回送给 `SrcL` 的循环能让每次访问都保持对齐；只要第一个基址是对齐的，就不会有迭代因未对齐被拒绝。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-mechanism role=mechanism -->
## 地址与传输如何形成

有符号 `17` 位立即数被符号扩展并左移 `3` 位，然后按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。该和既是访问地址，也是送到 `Dst1` 的值。

`SrcL` 只被读取。寄存器文件只通过目的字段改变，而基址变化只有在 `Dst1` 指定寄存器时才会到达寄存器文件。

编码检查与地址预检通过后，处理程序执行一次 `8` 字节小端序加载，并按 `Dst0` 在 `Dst1` 之前的顺序发布。

设计要点：缩放因子使立即数成为元素下标而不是字节数。立即数 `1` 表示一个元素，也就是 `8` 字节，因此这里无法表达单字节步长：每个可达位移都是 `8` 的倍数。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，也是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535` 个元素；按 `8` 缩放后即 `-524288` 到 `524280` 字节。
- `Dst0` 收到加载到的模式，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：立即数 `0` 让 `SrcL` 保持不变、访问发生在基址处，于是 `Dst1` 重新发布该基址。这个零是元素计数，而不是缺失的位移；本形式也没有别的地址来源可以回退。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前被读取，因此与任一目的位置别名的 `SrcL` 仍然为地址提供指令执行前的基址。

成功时记录一个 relaxed 的 `8` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节，被拒绝或发生故障的尝试不会退休。

设计要点：加载到的字节原样发布，因此目的位置持有的就是这八个字节在内存中的确切映像；在本宽度上没有任何归一化步骤能改变该值。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码没有变换或移位字段，因此没有其他取值可以被保留。

预检检查有效地址的低 `3` 位——在这里就是那个和——并在翻译之前、权限检查之前引发 `Fault_DataAlignment`。`8` 字节对齐但未通过权限或有界内存检查的地址会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会重新缩放立即数并重算整个和，因为 `SrcL` 从未前进。

<!-- PTO-READER-BLOCK: scalar-hl-ldi-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ldi.pr [13, 2], ->14, 13`，GPR13 = `0x9000`。立即数是 `2` 个元素，乘以 `8` 得 `16`。
- 有效地址是 `0x9000` 加 `16`，即 `0x9010`，它是 `8` 字节对齐的。
- GPR14 收到 `0x9010` 至 `0x9017` 的 `8` 字节，GPR13 收到 `0x9010`，因为 `Dst1` 指定的就是基址寄存器。
- `TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | HL48 | 48 | 0x00003019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_pr_48_d07cced5a281 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_pr_48_d07cced5a281 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_pr_48_d07cced5a281 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_pr_48_d07cced5a281 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_pr_48_d07cced5a281 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_PR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_PR()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_PR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.ldi.pr [SrcL, simm], ->Dst0, Dst1
