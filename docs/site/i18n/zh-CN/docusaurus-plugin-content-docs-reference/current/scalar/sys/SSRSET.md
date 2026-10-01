<!-- GENERATED FROM: asl/scalar/sys/SSRSET.asl -->
# SSRSET

**Normative ASL source:** `asl/scalar/sys/SSRSET.asl`

SSRSET writes the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRSET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrset-purpose role=purpose -->
## SSRSET 的作用

`SSRSET` 写一个系统寄存器。它从 Reg5 源 `SrcL` 取得要存储的值，从 12 位地址 `SSR_ID` 取得目标，并把完整的 XLEN 值写入被寻址的寄存器。

<!-- PTO-READER-BLOCK: scalar-ssrset-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_SSRSET` 选择 `ScalarHandler_ExecuteSystemRegisterSet`（`asl/scalar/sys/SSRSET.asl:18`），`InstructionContractSystemAddressWidth_SSRSET` 把地址宽度固定为 12（`asl/scalar/sys/SSRSET.asl:36`）。派发器把 `SrcL` 解码为 Reg5 选择器、把 `SSR_ID` 解码为系统寄存器地址（`asl/scalar/model/dispatch/sys.asl:111`）。

该辅助函数先检查后读取：当 `SystemRegisterWritePermitted` 为假时 `ExecuteSystemRegisterSet` 拒绝该次尝试，之后才读取源寄存器（`asl/scalar/model/sys/registers.asl:157`）。

<!-- PTO-READER-BLOCK: scalar-ssrset-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 接受 Reg5 源编码 R0..R23、T#1..T#4 和 U#1..U#4，并提供要存储的值。`SSR_ID` 是 12 位系统寄存器标识符（`asl/scalar/sys/SSRSET.asl:1`）。

`SSRSET` 没有目的地操作数，因此没有寄存器或队列接收结果。`SrcL` 中的编码零命名架构零 GPR，这是写零的合法方式；`SSR_ID` 中的编码零是地址 0 处的基寄存器。

<!-- PTO-READER-BLOCK: scalar-ssrset-effects role=effects -->
## 架构效果

成功的尝试把完整的源值写入被寻址寄存器，随后把 `TPC` 推进 4 字节。某些地址在写入路径内部还有副作用，地址 0x0020 是最清楚的例子：存入 `CORE_STATE` 还会用所存值的第 3:0 位设置当前访问环（`asl/scalar/model/sys/semantics.asl:63`）。

设计要点：写权限检查在读取源之前运行，因此将被拒绝的尝试既不消耗源值，也不改变系统寄存器。被拒绝的 `SSRSET` 因此让其源操作数与目标寄存器都保持不变；读取 Reg5 源从不消耗临时队列项。

该指令不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-ssrset-constraints role=constraints -->
## 位置与拒绝边界

位置最先检查：在活动 SYS 块体之外，该次尝试在任何地址或操作数处理之前引发 `Fault_BundleControl`。随后写入路径在当前环对该地址缺少权限，或访问类别为未知或只读时以 `Fault_IllegalInstruction` 拒绝（`asl/scalar/model/sys/registers.asl:105`）。

设计要点：像 0x0021 这样的地址在每个环都可读，但永远不可写，因为它的访问类别是只读。因此同一地址对 `ssrget` 成功而对 `ssrset` 出错，这就是为什么决定一次写入的是访问类别而不只是环。

<!-- PTO-READER-BLOCK: scalar-ssrset-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

`ssrset SrcL, SSR_ID` 在 `SSR_ID` 为 0x0020 且源持有值 2 时存入 `CORE_STATE`；由于所存值的第 3:0 位为 2，后续尝试的当前访问环变为 ACR2。改用 `SSR_ID` 0x0021 会被 `Fault_IllegalInstruction` 拒绝，因为该地址只读，且源寄存器从不被读取。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrset SrcL, SSR_ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrset_32_4dd3b71802c6 | L32 | 32 | 0x0000103b / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrset_32_4dd3b71802c6 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| ssrset_32_4dd3b71802c6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrset_32_4dd3b71802c6 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| ssrset_32_4dd3b71802c6 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractOperation_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRSET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractHandler_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_SSRSET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSET()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Write the complete XLEN source to the selected writable system register.
- A rejected write preserves the source and target register except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight the complete address, current-ACR permission, and writable access class before reading SrcL.
- Snapshot SrcL, perform the register write, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ssrset SrcL, SSR_ID
