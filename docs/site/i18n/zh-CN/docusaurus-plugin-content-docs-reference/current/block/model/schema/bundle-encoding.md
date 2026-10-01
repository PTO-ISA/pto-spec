<!-- GENERATED FROM: asl/block/model/schema/bundle-encoding.asl -->
# Bundle Encoding

**Normative ASL source:** `asl/block/model/schema/bundle-encoding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-purpose role=purpose-scope -->
## 用途与范围

本单元定义指令束种类和转移规则的数值编码、`B.IOT` 与 `B.IOS` 使用的 PE 模式到 PE 掩码表，以及已保存 `EBARG0` 控制字的合法性检查。

其元数据还列出了命令形式目录中经过评审的编码重叠。

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-concepts role=concepts-state -->
## 概念与可见状态

| 种类 | 编码 | 转移 | 编码 |
| --- | --- | --- | --- |
| Standard | `0000` | Fallthrough | `000` |
| Floating | `0001` | Direct | `001` |
| System | `0010` | Conditional | `010` |
| TileElement | `0101` | Call | `011` |
| TileMemory | `0110` | Return | `100` |
| TileMatrix | `0111` | Indirect | `101` |
| FrameTemplate | `1000` | IndirectCall | `110` |

3 位 PE 模式选择一个 4 位 PE 掩码：`000` 给出 `0000`，`001` 到 `100` 选择单个 PE（`1000`、`0100`、`0010`、`0001`），`101` 给出 `1100`，`110` 给出 `1110`，`111` 给出 `1111`。

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-rules role=rules-interactions -->
## 规则与交互

`BundleKindOf` 和 `BundleTransferOf` 对编码进行译码。任何未列出的编码都译码为 `Standard` 或 `Fallthrough`。

`EBARGControlLegal` 只在以下条件全部满足时接受已保存的控制字：bits `63:15` 为零，bits `10:7` 中的种类编码是所列种类之一，bits `13:11` 中的转移编码至多为 6，并且 bit 6（主体活动）蕴含 bit 5（指令束活动）。陷阱上下文恢复使用此检查。

设计要点：恢复会检查已保存的控制字，而不是直接信任它。带有未分配种类、未分配转移，或在没有活动指令束时声明主体的控制字会被拒绝。否则，对其译码会把错误编码静默映射为 `Standard` 或 `Fallthrough`。

设计要点：PE 模式 `000` 映射到掩码 `0000`。在 SizeCode 检查之后，带有该掩码的绑定在命令分派器中是严格的空操作：它跳过放置、流、模式、分配和描述符检查；在头部中，它只记录已看到零参与并打开其范围组。因此模式 `000` 无需单独的标志即可编码“没有参与的 PE”。

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-boundaries role=boundaries -->
## 架构边界

元数据记录了三处经过评审的重叠。其中两处涉及 `B.IOT` 的仅源形式和目标形式：前者把 `SizeCode` 固定为零，后者要求 `SizeCode` 为 1 到 12。第三处是 `C.BSTOP`，它使用了 `C.BSTART.STD` 所排除的 `BrType` 值 0。

编码 `0011`、`0100` 以及 `1001` 到 `1111` 未分配给任何种类。

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对于一个转移为 `Fallthrough` 的活动 `TileElement` 主体，其已保存控制字置位 bit 4，置位 bits 5 和 6，bits `10:7` 中为种类 `0101`，bits `13:11` 中为 `000`。它通过 `EBARGControlLegal`。同一控制字若清除 bit 5 则不通过，因为 bit 6 在没有活动指令束时声明了主体。

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-related role=related-owners-navigation -->
## 相关所有者

- [状态类型](../state/types.md)声明这些枚举。
- [BARG 辅助函数](../state/barg.md)把这些编码打包进 `LSRGET` 控制字。
- [陷阱上下文](../../../arch/state/trap-context.md)写入并检查 `EBARG0` 控制字。
- [B.IOT](../../operands/B.IOT.md) 和 [B.IOS](../../operands/B.IOS.md) 使用 PE 模式表。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/bundle-encoding.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING","surface":"block","classification":["model","schema","bundle-encoding"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"],"catalog_projection":{"catalog":"command-forms","isa":"PTO Instruction Set Architecture","reviewed_encoding_overlaps":[{"broad_form_id":"b_iot_32_10db6db84f5d","narrow_form_id":"b_iot_32_c11eb189dd83","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"b_iot_32_8b8bce6bffe8","narrow_form_id":"b_iot_32_2c07e7177fad","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"c_bstart_std_16_8b40f078c14a","narrow_form_id":"c_bstop_16_ca4743d8a95e","reason":"C.BSTOP fixes the broad C.BSTART.STD BrType field to excluded value 0"}],"schema_version":2,"surface":"command-and-boundary"}}
pure func BundleKindCode(kind: BundleKind) => bits(4)
begin
    case kind of
        when BundleKind_Standard => return '0000';
        when BundleKind_Floating => return '0001';
        when BundleKind_System => return '0010';
        when BundleKind_TileElement => return '0101';
        when BundleKind_TileMemory => return '0110';
        when BundleKind_TileMatrix => return '0111';
        when BundleKind_FrameTemplate => return '1000';
    end;
end;

pure func BundleKindOf(code: bits(4)) => BundleKind
begin
    if code == '0001' then return BundleKind_Floating;
    elsif code == '0010' then return BundleKind_System;
    elsif code == '0101' then return BundleKind_TileElement;
    elsif code == '0110' then return BundleKind_TileMemory;
    elsif code == '0111' then return BundleKind_TileMatrix;
    elsif code == '1000' then return BundleKind_FrameTemplate;
    else return BundleKind_Standard;
    end;
end;

pure func PEMaskOfPEMode(mode: bits(3)) => bits(4)
begin
    case mode of
        when '000' => return '0000';
        when '001' => return '1000';
        when '010' => return '0100';
        when '011' => return '0010';
        when '100' => return '0001';
        when '101' => return '1100';
        when '110' => return '1110';
        when '111' => return '1111';
    end;
end;

pure func BundleTransferCode(transfer: BundleTransfer) => bits(3)
begin
    case transfer of
        when BundleTransfer_Fallthrough => return '000';
        when BundleTransfer_Direct => return '001';
        when BundleTransfer_Conditional => return '010';
        when BundleTransfer_Call => return '011';
        when BundleTransfer_Return => return '100';
        when BundleTransfer_Indirect => return '101';
        when BundleTransfer_IndirectCall => return '110';
    end;
end;

pure func BundleTransferOf(code: bits(3)) => BundleTransfer
begin
    if code == '001' then return BundleTransfer_Direct;
    elsif code == '010' then return BundleTransfer_Conditional;
    elsif code == '011' then return BundleTransfer_Call;
    elsif code == '100' then return BundleTransfer_Return;
    elsif code == '101' then return BundleTransfer_Indirect;
    elsif code == '110' then return BundleTransfer_IndirectCall;
    else return BundleTransfer_Fallthrough;
    end;
end;

pure func EBARGControlLegal(control: Word) => boolean
begin
    let kind_code = UInt(control[10:7]);
    return control[63:15] == Zeros{49} &&
           (kind_code <= 2 || (kind_code >= 5 && kind_code <= 8)) &&
           UInt(control[13:11]) <= 6 &&
           (control[6] == '0' || control[5] == '1');
end;
```
<!-- GENERATED-ASL-END: unit -->
