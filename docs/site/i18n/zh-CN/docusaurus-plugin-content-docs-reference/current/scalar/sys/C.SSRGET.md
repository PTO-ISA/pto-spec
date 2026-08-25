<!-- GENERATED FROM: asl/scalar/sys/C.SSRGET.asl -->
# C.SSRGET

**Normative ASL source:** `asl/scalar/sys/C.SSRGET.asl`

C.SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-C-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ssrget-purpose role=purpose -->
## C.SSRGET 的作用

`C.SSRGET` 读取一个已分配的短系统寄存器 ID，并把完整 XLEN 值压入 T。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-mechanism role=mechanism -->
## 系统机制

ASL DOC 区域选择 `ScalarHandler_ExecuteCompressedSystemRegisterGet`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 SYS 块体中的一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SSRID` 承载短系统寄存器标识符。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-effects role=effects -->
## 架构效果

直接 ID `0`、`1` 和 `16` 分别读取 `THREAD_PTR`、`GLOBAL_PTR` 或 `TIME`，并把完整 XLEN 值压入 T。

读取被拒绝时，除普通陷阱进入外，不会改变所选目的地或临时队列顺序。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-constraints role=constraints -->
## 位置与拒绝边界

其他所有 5 位 ID 都是保留值；拒绝访问时，除普通陷阱进入外，访问与队列状态保持不变。

无效的 SYS 块位置会在字段检查之前被拒绝。保留编码或访问拒绝除普通陷阱包络外，不产生目的地、队列、系统状态或 `TPC` 效果。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `c.ssrget SSR-ID, ->t` 开始，先沿编码字段完成预检，再继续查看所选系统效果。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.ssrget SSR-ID, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | C16 | 16 | 0x802c / 0xf83f | [{"field":"SSRID","operator":"one-of","values":[0,1,16]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | SSRID | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ssrget_16_9d83a6f2749a | SSRID | 5 | 0–1, 16 | none | 2–15, 17–31 | short system-register identifier | Encoded zero selects value zero of the short system-register identifier. |

- `c_ssrget_16_9d83a6f2749a.SSRID` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSRID | short system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_C_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
C.SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_C_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_C_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_C_SSRGET()
    => integer {5,12,24}
begin
    return 5;
end;

pure func InstructionContractPushesTemporaryT_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDirectSystemIDLegal_C_SSRGET(
    identifier: bits(5)) => boolean
begin
    return identifier == '00000' ||
           identifier == '00001' ||
           identifier == '10000';
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.
- Only direct IDs 0, 1, and 16 are assigned; every other five-bit ID is reserved.

## State effects

- Read THREAD_PTR, GLOBAL_PTR, or TIME for direct IDs 0, 1, or 16 and push the complete XLEN value to T.
- A rejected access preserves T queue order and contents except for ordinary trap entry.

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

- c.ssrget SSR-ID, ->t
