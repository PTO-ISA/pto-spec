<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.PR.asl -->
# HL.LBUI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.PR.asl`

HL.LBUI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-purpose role=purpose -->
## `HL.LBUI.PR` 做什么

`HL.LBUI.PR` 是一条 `48` 位的前变址字节加载指令，使用有符号 `17` 位立即数位移并返回零扩展结果。它把位移加到 `SrcL` 基址上，在该和处读取一个字节，清零结果中第 `7` 位以上的一切，把字节发布到 `Dst0`，并把同一个和发布到 `Dst1`。

规范汇编形式是 `hl.lbui.pr [SrcL, simm], ->Dst0, Dst1`。

设计要点：立即数是编码中的一个字段，因此它总是存在。立即数 `0` 就是位移零：访问发生在基址本身，而 `Dst1` 原样重新发布该基址。本形式没有任何方式让程序省略位移、改而得到一个由寄存器导出的不同地址。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-mechanism role=mechanism -->
## 地址与传输如何形成

`17` 位立即数被符号扩展，以缩放因子 `1` 使用，并按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。该和既是有效地址，也是送到 `Dst1` 的值。

`SrcL` 只被读取；基址寄存器从不被本指令修改。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，对字节做零扩展，并按 `Dst0` 然后 `Dst1` 的顺序发布。

设计要点：由于位移是立即数，同一条编码的两次执行总会从同一个基址算出同一个地址。它们之间不存在可能变化的寄存器，也不存在能让位移依赖数据的变换字段。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-inputs role=inputs-outputs -->
## 编码字段与两个结果

- `SrcL` 是基址，也是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm17` 是有符号 `17` 位立即数，覆盖 `-65536` 到 `65535`，缩放因子为 `1`，因此可达窗口在基址周围跨越 `131072` 字节。
- `Dst0` 收到零扩展后的字节，`Dst1` 收到更新后的基址；编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该结果。

设计要点：可达窗口足够大，基于立即数的访问可以覆盖一个结构而不需要任何指针运算，代价是每条编码对应一个固定位移。步长在运行时才改变的遍历根本无法用本形式表达。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前被读取，因此指定 `SrcL` 的目的位置仍然贡献指令执行前的基址。

执行成功时记录一个 relaxed 的 `1` 字节加载事件，内存字节与保留状态保持不变。两次发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：写入顺序是 `Dst0` 然后 `Dst1`，因此当两个字段指定同一个寄存器时，存活下来的是更新后的基址。加载到的字节并没有从内存中丢失，只是没有留在该寄存器里。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。该编码除固定位之外没有保留字段。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式没有任何地址会引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，两个结果都不发布，`TPC` 停留在引发故障的指令上。恢复会再次对立即数做符号扩展，并从同一组快照重复求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbui.pr [18, 0], ->19, 18`，GPR18 = `0x6100`。立即数是 `0`，因此有效地址就是 `0x6100` 本身。
- 若 `0x6100` 处的字节为 `01`，GPR19 收到 `1`。
- GPR18 再次收到 `0x6100`，因为 `Dst1` 指定的就是基址寄存器，而这个和等于基址。
- `TPC` 变为该指令地址加 `6`，基址寄存器除此之外未被改动。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | HL48 | 48 | 0x00004019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_pr_48_78a81538a7fa | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_pr_48_78a81538a7fa | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_pr_48_78a81538a7fa | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI_PR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.lbui.pr [SrcL, simm], ->Dst0, Dst1
