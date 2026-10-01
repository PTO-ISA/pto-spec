<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PCR.asl -->
# HL.LD.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PCR.asl`

HL.LD.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-purpose role=purpose -->
## `HL.LD.PCR` 做什么

`HL.LD.PCR` 是一条 `48` 位的 PC 相对加载指令，读取一个小端序 `8` 字节值。它用当前程序计数器导出基址，加上按比例缩放的有符号位移，读取八个字节，并通过 `RegDst` 发布完整的 `64` 位模式。

规范汇编形式是 `hl.ld.pcr [<symbol>], ->{t, u, Rd}`。

设计要点：这里记录的不是有符号加载；而对 `8` 字节传输来说这个区分本来就是空的，因为归一化步骤在有符号与无符号两条路径上都原样返回 `8` 字节值。在本宽度上，一种扩展行为覆盖全部编码。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-mechanism role=mechanism -->
## 地址与传输如何形成

基址是当前 `TPC` 把第 `1`:`0` 位清零后的值。位移是有符号 `29` 位字段左移 `2` 位的结果，两者之和按 `2^PTO_XLEN` 取模。

除通过发布的目的位置之外，通用寄存器文件既不被读取也不被写入；本形式没有基址寄存器，也没有回写。

编码检查与地址预检通过后，处理程序执行一次 `8` 字节小端序加载，并把这些字节原样发布到 `RegDst`。

设计要点：基址只是 `4` 字节对齐，而访问需要 `8` 字节对齐，因此有效地址的低 `3` 位很关键。某个位移是否合法，既取决于对齐后 `TPC` 的第 `2` 位，也取决于编码位移的最低位：第 `2` 位为零的对齐基址只接受偶数个字位移。可编码窗口中大约一半会在翻译之前被拒绝。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-inputs role=inputs-outputs -->
## 编码字段与字节去向

- `RegDst` 是 `5` 位选择子：编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 只丢弃加载值。
- 有符号 `29` 位位移按 `4` 缩放。组装出的字节取值从 `-1073741824` 到 `1073741820`，步长为 `4`。
- 基址是隐式的：对齐后的 `TPC`。

设计要点：丢弃编码仍然会执行完整的加载并记录其事件，因此 `RegDst` 等于 `0` 的 `->Rd` 是一次受检查的内存引用，而不是空操作。抑制这次访问的唯一办法是不执行该指令。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-effects role=effects -->
## 影响、顺序与完成

执行成功时记录一个 relaxed 的 `8` 字节加载事件。内存字节与任何保留状态都不改变，因为加载既不写内存也不打扰保留。

只有当加载报告无故障时才发布目的位置。发布之后，`TPC` 从基址所依据的那条指令地址前进 `6` 字节。

设计要点：这八个字节是作为一个地址上的一次访问被读取的，而不是两个 `4` 字节半段，因此跨越 `4` 字节边界的窗口仍然是一个事件，其唯一的对齐要求由第一个字节的地址决定。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-constraints role=constraints -->
## 合法性、故障与重启

`48` 位编码中的固定位不匹配会在任何影响之前引发 `Fault_IllegalInstruction`。本形式不编码任何源选择子，因此没有不可用的 `T` 或 `U` 槽位能拒绝它。

预检检查有效地址的低 `3` 位，并在翻译之前、权限检查之前引发 `Fault_DataAlignment`，这正是 `4` 字节对齐但非 `8` 字节对齐的地址所产生的结果。`8` 字节对齐但未通过权限或有界内存检查的地址会在原始地址引发 `Fault_DataPage`。

发生故障时不记录加载事件，不发布任何目的值，`TPC` 停留在引发故障的指令上。恢复会重新导出基址与位移，并重复预检与加载。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.ld.pcr [<symbol>], ->6`，在 `TPC` = `0x2004` 处执行。清掉低 `2` 位得到基址 `0x2004`，它 `4` 字节对齐但不是 `8` 字节对齐，因此第 `2` 位为 1，只有奇数个字位移能让地址保持对齐。
- 编码位移为 `5` 时，组装出的位移是 `20`，有效地址是 `0x2004` 加 `20`，即 `0x2018`。
- 该指令读取 `0x2018` 至 `0x201F` 的 `8` 字节，并把整个 `64` 位模式发布到 GPR6。
- 若编码位移改为 `6`，地址将是 `0x201C`，它不是 `8` 字节对齐的，指令会在翻译之前引发 `Fault_DataAlignment`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | HL48 | 48 | 0x00003039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pcr_48_703673c266da | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pcr_48_703673c266da | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- hl.ld.pcr [<symbol>], ->{t, u, Rd}
