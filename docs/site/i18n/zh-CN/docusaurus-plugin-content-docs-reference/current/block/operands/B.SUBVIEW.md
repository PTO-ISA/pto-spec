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

`B.SUBVIEW` 是一条 32 位头部命令，把紧邻其前的绑定命令的一个源缩小为一段连续范围。绑定命令是 `B.IOT` 或 `B.IOS`。该命令是范围修饰符：它附着于该绑定命令，不分配任何内容，执行时也不查询操作模式。参见[范围修饰符](../model/operands/range-modifiers.md)。

<!-- PTO-READER-BLOCK: block-b-subview-mechanism role=mechanism -->
## 放置与机制

`B.SUBVIEW` 必须紧跟其绑定命令，或紧跟同一绑定命令的另一个范围修饰符。每条不是范围修饰符的头部命令都会关闭打开的范围组，因此修饰符无法越过中间的 `B.DIM` 或 `B.DATR`。

处理程序先检查原始字段。然后检查范围组已打开、所选源角色存在于绑定命令上，并且角色按源 0、源 1、目标的顺序出现且各至多一次。之后它才读取 `GPR[RegSrc]`，加上零扩展的 `uimm11`（模 2^XLEN），并把原始字段与派生偏移存入该源的范围记录。

设计要点：零参与的绑定命令（`PEMode = 000`）会打开零模式范围组。在该组中，每条 `B.SUBVIEW` 只经过范围组已打开的检查，不读取 GPR，也不记录任何内容。因此没有参与 PE 的绑定命令仍使其后的修饰符在语法上合法，而不产生任何效果。

<!-- PTO-READER-BLOCK: block-b-subview-inputs role=inputs-outputs -->
## 字段与编码值

- `SrcSelect`（位 31）为 0 时选择源 0，为 1 时选择源 1。Shared 范围组没有源 1。
- `uimm11`（位 30:20）是无符号加数，零扩展。零是真实的零加数。
- `RegSrc`（位 19:15）指定绝对 GPR 0 至 23。编码零指零 GPR，读出 0。
- `SubviewSizeCode`（位 10:7）是请求的范围大小，1 至 12，对应 128 B 至 256 KiB。编码 0 保留。
- 位 14:11 固定；该形式在掩码 `0x0000787f` 下低位匹配 `0x53`。

设计要点：偏移在修饰符执行时计算一次，结果存入范围记录。之后写 `RegSrc` 的主体指令不会改变已记录的偏移。对于 Local CUBE 源，派生偏移以父 Tile 的 128 字节 CELL 计数。

<!-- PTO-READER-BLOCK: block-b-subview-effects role=effects -->
## 记录的状态与后续使用

被接受的 `B.SUBVIEW` 只改变绑定上该源的范围记录。它不读取 Tile 载荷。

在阶段 2 准备期间，Local 子视图成为 CUBE 布局父 Tile 上从偏移开始、覆盖 `min(requested, remaining)` 个 CELL 的描述符。所选 CELL 被复制到一个临时 Tile 中，该 Tile 使用父 Tile 的布局、数据类型与 PE 掩码，操作读取这份副本。无论成功还是失败路径，副本都在操作之后释放。参见[子视图描述符](../model/operands/subview-descriptor.md)。

设计要点：父 Tile 保持不变，父 Tile 中未定义的元素在视图中仍未定义。子视图选择同一对象的一个范围；它不是重新布局，也不能使未定义的数据变得可读。

<!-- PTO-READER-BLOCK: block-b-subview-constraints role=constraints -->
## 合法性与故障边界

- `RegSrc` 编码为 24 至 31、`SubviewSizeCode` 为 0 或 13 至 15，或固定位非零时，在读取任何 GPR 之前引发 `Fault_IllegalInstruction`。
- 附着于参与的 Local 范围组的 `SubviewSizeCode` 11 或 12 引发 `Fault_TileLegality`，因为 Local 大小编码止于 10，即每 PE 64 KiB。Shared 范围组接受 1 至 12。
- 没有打开的范围组、绑定命令没有所选源角色、角色重复或角色顺序错误时，引发 `Fault_BundleControl`。
- 在阶段 2 准备期间，若 Local 子视图的父 Tile 不是已分配的 CUBE Tile，或偏移不小于父 Tile 的 CELL 数，则在操作之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-b-subview-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOT T#1, mask=1111, <last>, ->T<2KB>
B.SUBVIEW 0, a0, 2, 2
```

假设 `T#1` 是有效形状为 16 x 32 的 `CUBE_M16` `FP16` Tile，即 8 个 16 行 x 4 列的 CELL，且 `a0` 保存 0。派生偏移为 0 + 2 = 2 个 CELL，大小编码 2 请求 256 B，即 2 个 CELL。剩余 4 个 CELL，因此视图覆盖所请求的 2 个 CELL：父 Tile 的第 8 至 15 列，即 16 x 8 的视图。该修饰符编码为 `0x00210153`。其后再出现 `B.SUBVIEW 0` 会引发 `Fault_BundleControl`，因为源 0 已被修饰。
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
