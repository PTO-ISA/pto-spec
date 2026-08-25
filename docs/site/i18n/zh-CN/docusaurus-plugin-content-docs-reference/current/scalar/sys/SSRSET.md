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

`SSRSET` 把完整 XLEN 值写入已分配的可写系统寄存器。

<!-- PTO-READER-BLOCK: scalar-ssrset-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteSystemRegisterSet`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-ssrset-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SSR_ID` 承载系统寄存器标识符；`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-ssrset-effects role=effects -->
## 架构效果

可写访问预检完成后，完整 XLEN 源值替换所选系统寄存器，随后 `TPC` 前进。

写入被拒绝时，除普通陷阱进入外，源值与目标寄存器都保持不变。

<!-- PTO-READER-BLOCK: scalar-ssrset-constraints role=constraints -->
## 位置与拒绝边界

读取 `SrcL` 之前，必须先检查地址、当前 ACR 权限和可写访问类别。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-ssrset-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `ssrset SrcL, SSR_ID` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
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
