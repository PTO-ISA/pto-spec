<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.asl -->
# HL.LBUI

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.asl`

HL.LBUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-purpose role=purpose -->
## `HL.LBUI` 做什么

`HL.LBUI` 是一条 `48` 位字节加载指令，使用有符号 `22` 位立即数位移并返回零扩展结果。它把立即数加到 `SrcL` 基址上，在该处读取一个字节，清零结果中第 `7` 位以上的一切，并把该字节发布到 `RegDst`。

规范汇编形式是 `hl.lbui [SrcL, simm], ->{t, u, Rd}`。

设计要点：地址来自加到 `SrcL` 上的符号扩展立即数，因此地址形成是有符号的，尽管结果不是。零扩展是唯一把加载字节当作无符号处理的步骤：这里发布的字节 `80` 是 `128`，而地址或访问的任何部分都不依赖读取到的值。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-mechanism role=mechanism -->
## 地址与传输如何形成

立即数被符号扩展，以缩放因子 `1` 使用，并按 `2^PTO_XLEN` 取模加到 `SrcL` 的快照上。更新模式为无，因此这个和用于访问后即被丢弃；没有任何基址寄存器改变。

编码检查与地址预检通过后，处理程序执行一次 `1` 字节小端序加载，把字节零扩展到 `PTO_XLEN`，并发布到 `RegDst`。

设计要点：窗口跨越 `-2097152` 至 `2097151` 字节且不做缩放，因此本形式能到达该窗口内的每一个字节地址。由于 `1` 字节访问没有对齐要求，这些地址都不可能被预检拒绝；该阶段剩下的唯一拒绝就是权限与有界内存检查。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-inputs role=inputs-outputs -->
## 编码字段与结果

- `SrcL` 是 `5` 位 Reg5 选择子，覆盖绝对 GPR、`T#1`..`T#4` 与 `U#1`..`U#4`。
- `simm22` 是有符号 `22` 位立即数，覆盖 `-2097152` 到 `2097151`，按 `1` 缩放。
- `RegDst` 是 `5` 位选择子：编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24`..`29` 只丢弃该值。

设计要点：由于结果是完整宽度的值，消费者永远不必屏蔽加载到的字节。该字节之上的 `56` 位始终为零，因此发布的值可以直接当作无符号下标或长度使用。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-effects role=effects -->
## 影响、顺序与完成

`SrcL` 在任何内存或目的位置影响之前被读取，因此基址与目的位置之间的别名使用指令执行前的值。

执行成功时记录一个 relaxed 的 `1` 字节加载事件，内存与保留状态保持不变。发布之后 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

设计要点：只有当加载报告无故障时才写入目的位置，因此发生故障的访问会让 `RegDst` 指定的寄存器或队列槽位保持原样。重试之前没有任何部分状态需要撤销。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-constraints role=constraints -->
## 合法性、故障与重启

固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`；`SrcL` 指向不可用的 `T` 或 `U` 槽位会在执行之前引发同样的故障。

预检施加 `1` 字节对齐要求，而任何地址都满足它，因此本形式没有任何地址会引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不写入目的位置，`TPC` 停留在引发故障的指令上。恢复会再次对立即数做符号扩展，并从同一组快照重复求和与加载。

<!-- PTO-READER-BLOCK: scalar-hl-lbui-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.lbui [4, 1], ->t`，GPR4 = `0xB000`。立即数是 `1`，因此有效地址是 `0xB001`。
- 该指令读取 `0xB001` 处的字节。若为 `FF`，压入成为新 `T#1` 的值是 `255`，第 `63`:`8` 位全为零。
- 压入还会把较旧的队列条目整体挪动一个槽位，因此原来的 `T#1` 变成 `T#2`。
- GPR4 仍持有 `0xB000`，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_48_50579e3558f4 | HL48 | 48 | 0x00004019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_48_50579e3558f4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_48_50579e3558f4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_48_50579e3558f4 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_48_50579e3558f4 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_48_50579e3558f4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_48_50579e3558f4 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lbui [SrcL, simm], ->{t, u, Rd}
