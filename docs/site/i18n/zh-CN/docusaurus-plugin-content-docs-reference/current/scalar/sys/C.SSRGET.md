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

`C.SSRGET` 读取一个系统寄存器，并把读到的值压入 `T` 队列。它是压缩形式的系统寄存器读取：目的位置是隐式的，寄存器由短标识符指名。

只分配了三个标识符，因此该指令只能到达三个寄存器：`THREAD_PTR`、`GLOBAL_PTR` 和 `TIME`。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

5 位标识符被当作系统寄存器地址的低位，因此标识符 `0`、`1` 和 `16` 指名地址 `0x0000`、`0x0001` 和 `0x0010`。它们分别是 `THREAD_PTR`、`GLOBAL_PTR` 和 `TIME` 的地址。其他每个五位标识符都是保留的。

随后读取走通用系统寄存器读取规则，该规则按顺序施加两项检查。第一项是环检查：低十二位小于 `0x0f00` 的地址在每个环上都可读，其他任何地址都要求根环。三个已分配地址都属于小于 `0x0f00` 的那一组，因此它们都不需要根环。第二项检查拒绝访问类别为未知或只写的地址；三个已分配地址都可读，因此它们也都不在这里被拒绝。

如果两项检查都通过，读到的值作为完整 XLEN 字被压入 `T` 队列。如果任一项检查失败，处理程序引发 `Fault_IllegalInstruction` 并且不压入，因此 `T` 队列保持其顺序与内容。

设计要点：目的位置是 `T` 队列而不是 GPR 选择器。这正是压缩形式能够去掉目的字段的原因；它也意味着只要在压入之前而不是之后做测试，被拒绝的读取就可以做到对队列无副作用。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SSRID` 是唯一的编码操作数：5 位短系统寄存器标识符。已分配取值是 `0`、`1` 和 `16`；其他每个取值都是保留的。编码零是已分配取值并指名 `THREAD_PTR`，不是被省略的操作数。
- 目的位置是隐式的：完整 XLEN 值被压入 `T` 队列，成为最新表项；队列满时会丢弃最旧的表项。
- 不写任何 GPR 和 `U` 队列表项，也不读取任何标量寄存器。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-effects role=effects -->
## 架构效果

成功时发生一次 `T` 压入，`TPC` 前进 `2` 字节。队列压入会把已有表项整体移动一个位置，因此在 `T#1`..`T#4` 中保留早先结果的程序必须考虑这种移动。

读取本身没有内存效果，也不获取保留状态。`TIME` 返回架构时间值，模型对每次已解码执行尝试推进该值一次，因此读 `TIME` 观察到的是源被读取那一刻的尝试计数。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

保留的标识符会在隐式 `T` 目的效果之前引发 `Fault_IllegalInstruction`，因此被拒绝的 `C.SSRGET` 除普通陷阱进入之外不会改动 `T` 队列的顺序与内容。访问规则拒绝的读取也由同一拒绝覆盖。

访问规则看到的是完整编码地址，而不只是五位标识符，因此环检查与访问类别检查都作用于该标识符指名的地址。

<!-- PTO-READER-BLOCK: scalar-c-ssrget-example role=example -->
## 非规范示例

`c.ssrget SSR-ID, ->t` 在 `SSRID=16` 时读取 `TIME`，并把完整的 XLEN 时间值压入 `T` 队列。在 `SSRID=2` 时该标识符是保留的：指令引发 `Fault_IllegalInstruction`，不压入任何值，已有的 `T` 表项保持各自位置。
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
