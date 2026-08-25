<!-- GENERATED FROM: asl/scalar/sys/ASSERT.asl -->
# ASSERT

**Normative ASL source:** `asl/scalar/sys/ASSERT.asl`

ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.

## Normative identity {#PTO-INST-SCALAR-ASSERT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-assert-purpose role=purpose -->
## ASSERT 的作用

`ASSERT` 检查快照得到的标量条件，并在条件为零时触发架构断言陷阱。

<!-- PTO-READER-BLOCK: scalar-assert-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ArchitectureAssert`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-assert-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-assert-effects role=effects -->
## 架构效果

先对标量条件取快照；零会在故障 PC 触发 `Fault_Assert`，非零则退役且不产生其他架构效果。

只有位置与解码检查完成后才读取条件，并且只有无故障路径会让 `TPC` 前进。

<!-- PTO-READER-BLOCK: scalar-assert-constraints role=constraints -->
## 位置与拒绝边界

每个可用的 Reg5 源选择器都已分配。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-assert-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `assert SrcL` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
assert SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | L32 | 32 | 0x0000102b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractOperation_ASSERT()
    => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ASSERT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractHandler_ASSERT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;

pure func InstructionContractRequiresSystemBlock_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFaultsWhenZero_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPreservesSource_ASSERT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every available Reg5 source selector is assigned.

## State effects

- Snapshot SrcL; zero raises Fault_Assert at the faulting PC and nonzero performs no effect other than successful retirement.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- assert SrcL
