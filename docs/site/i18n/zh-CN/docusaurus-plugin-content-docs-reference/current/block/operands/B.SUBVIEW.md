<!-- GENERATED FROM: asl/block/operands/B.SUBVIEW.asl -->
# B.SUBVIEW

**Normative ASL source:** `asl/block/operands/B.SUBVIEW.asl`

Decodes one source-range subview modifier and retains its XLEN-wrapped derived offset in the immediately preceding binder group.

## Normative identity {#PTO-INST-BLOCK-B-SUBVIEW}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-subview-purpose role=purpose -->
## B.SUBVIEW 的作用

`B.SUBVIEW` 是一条 32 位 Block header 命令，用来把一个源 subview 修饰符附加到已打开的 Local 或 Shared 绑定组。它修改待处理 Block 元数据，不会立即执行 Tile body 操作。

<!-- PTO-READER-BLOCK: block-b-subview-mechanism role=mechanism -->
## 位置与机制

该修饰符必须与打开其 carrier 的 `B.IOT` 或 `B.IOS` 绑定组保持连续。若中间插入其他命令、顺序反转或重复使用，会在 carrier 状态变化前被拒绝。

该命令把原始选择与范围字段以及派生的 XLEN 偏移记录到已打开的 binder carrier。若 binder 解码后的 PE mask 为零，则只保留一个随后丢弃的语法组，不读取源，也不产生角色影响。

<!-- PTO-READER-BLOCK: block-b-subview-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `SrcSelect` 选择源 carrier 0 或 1；其确切分配域仍以下方生成契约为准。
- `RegSrc` 选择具名的绝对 GPR 角色；其确切分配域仍以下方生成契约为准。
- `uimm11` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。
- `SubviewSizeCode` 提供 subview 范围大小编码；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-b-subview-effects role=effects -->
## 待处理状态与完成

被接受的 header 命令只改变自己的待处理记录或 carrier。除非本所有者明确指出即时 header 状态更新，否则架构 Tile、Shared、GPR、内存和完成影响都推迟到完整 Block。

<!-- PTO-READER-BLOCK: block-b-subview-constraints role=constraints -->
## 合法性与故障边界

保留编码会在读取或待处理状态变化前被拒绝。位置、重复、角色或完成后 schema 不匹配，会在 body 影响前失败。

<!-- PTO-READER-BLOCK: block-b-subview-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>
B.SUBVIEW 0, RegSrc, uimm11, SubviewSizeCode
```

源形式的 `B.IOT` 打开一个具有确切 source-zero carrier 的组。紧随其后的 `B.SUBVIEW 0` 只修饰该源 carrier；它不能与 binder 分离，也不能改为作用于目的 carrier。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.SUBVIEW SrcSelect, RegSrc, uimm11, SubviewSizeCode
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_subview_32_122000000001 | L32 | 32 | 0x00000053 / 0x0000787f | [{"field":"SrcSelect","operator":"one-of","values":[0,1]},{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SubviewSizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10,11,12]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_subview_32_122000000001 | SrcSelect | 1 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":1}] |
| b_subview_32_122000000001 | uimm11 | 11 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":11}] |
| b_subview_32_122000000001 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_subview_32_122000000001 | SubviewSizeCode | 4 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_subview_32_122000000001 | SrcSelect | 1 | 0–1 | none | none | selects source0 or source1 carrier | Zero selects source role zero. |
| b_subview_32_122000000001 | uimm11 | 11 | 0–2047 | none | none | unsigned XLEN addend | Zero is a real zero displacement. |
| b_subview_32_122000000001 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR selector | Zero names the architectural zero GPR. |
| b_subview_32_122000000001 | SubviewSizeCode | 4 | 1–12 | none | 0, 13–15 | decoded source tile range size | Zero is reserved. |

- `b_subview_32_122000000001.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_subview_32_122000000001.SubviewSizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcSelect | selects source0 or source1 carrier |
| RegSrc | absolute GPR selector |
| uimm11 | unsigned XLEN addend |
| SubviewSizeCode | decoded source tile range size |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.SUBVIEW.asl -->
```asl
readonly func InstructionContractMatches_B_SUBVIEW(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_b_subview_32_122000000001;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Immediately follows B.IOT or B.IOS and is contiguous with the associated modifier group.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.SUBVIEW.asl -->
```asl
pure func InstructionContractSubviewSizeCodeIsAssigned_B_SUBVIEW(code: integer {0..15}) => boolean
begin
    return 1 <= code && code <= 12;
end;

readonly func InstructionContractHandler_B_SUBVIEW() => CommandSemanticHandler
begin
    return CommandHandler_ApplyBundleSubview;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- uimm11 is unsigned and zero-extended. RegSrc zero names the architectural zero GPR.

## Legality

- RegSrc accepts only absolute GPR selectors 0..23.
- SubviewSizeCode raw values 1..12 are decoded; Local-associated groups require 1..10 and Shared-associated groups accept 1..12.
- A modifier is legal only in the contiguous immediately preceding B.IOT/B.IOS group and follows source0, source1, destination role order.

## State effects

- Store raw RegSrc/uimm11/size and the derived XLEN offset in the source carrier of the open binder group.
- PEMode=000 on the binder opens a discarded syntactic group; every raw-legal contiguous modifier advances TPC without reads, state, role, or fault effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode fixed/reserved fields and raw ranges before any GPR read; compute GPR[RegSrc]+ZeroExtend(uimm11) modulo 2^XLEN after group legality.

## Exceptions

- Reserved funct3/bit11/opcode, RegSrc24..31, and SubviewSizeCode0/13..15 raise Fault_IllegalInstruction before GPR reads, carrier updates, or TPC advance.
- Missing, reversed, duplicate, intervening, or role-incompatible groups raise Fault_BundleControl before carrier updates.

## Examples

- B.IOT T0, mask=1111; B.SUBVIEW 0, a0, 0, 1
