<!-- GENERATED FROM: asl/tile/model/state/descriptors.asl -->
# Descriptors

**Normative ASL source:** `asl/tile/model/state/descriptors.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-DESCRIPTORS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-descriptors-purpose role=purpose-scope -->
## 用途与范围

本单元汇集了每个 Tile 操作都依赖的小型描述符辅助函数。它涵盖三个主题：

- 64 个 Local Tile 寄存器的 hand 结构与相对命名。
- Local 和 Shared 对象的容量与 SizeCode 合法性。
- 元素宽度以及字节预算对应的逻辑元素容量。

它自身不拥有任何状态。它读取并更新 `_TileRelativeOrder` 和 `_TileRelativeValid`，这两者由 Local 寄存器单元声明。

<!-- PTO-READER-BLOCK: tile-model-state-descriptors-concepts role=concepts-state -->
## 概念与可见状态

64 个绝对 Local 寄存器组成四个各含 16 个寄存器的 hand：索引 0 到 15 是 hand T，16 到 31 是 U，32 到 47 是 M，48 到 63 是 N。`TileHandOf` 返回所属 hand，`TileIndexWithinHand` 返回其在 hand 内从 1 开始（1-based）的位置。

相对选择子指明一个 hand 和一个距离。`RelativeTileHandIndex` 是选择子除以 16，`RelativeTileDistance` 是选择子对 16 取模。距离 0 即 `#1`，即该 hand 最新发布的代次。

每个 hand 维护一个 16 项顺序列表和一个 16 位有效性向量。`ResolveRelativeTileSource` 在断言所选条目有效且仍已分配之后，返回存放在所选距离处的绝对寄存器。

SizeCode 是一个选择字节预算的四位字段。`TileSizeCodeBytes` 把编码 1 到 12 映射为 128 B 到 256 KiB，每一步翻倍。

<!-- PTO-READER-BLOCK: tile-model-state-descriptors-rules role=rules-interactions -->
## 规则与交互

`PublishRelativeTileDestination` 把新目标推入其 hand 的距离 0，并把较旧的条目朝距离 15 方向移动一步。位于距离 15 的条目被移出。

设计要点：发布一个已经在其 hand 列表中的寄存器是空操作。被重复使用的目标不会出现两次，其他代次的顺序保持不变。

`RemoveRelativeTileMapping` 从每个 hand 中删除一个寄存器，并把剩余条目向距离 0 压紧。`ReleaseTile` 会调用它，因此已释放的寄存器不能被解析为源。

`TileCapacityIsLegal` 要求至少 128 字节、为 128 的倍数、至多 65536 字节，且不超过 `TILE_CAPACITY` 限制。`SharedTileCapacityIsLegal` 采用相同的粒度规则，但允许达到 256 KiB 的 Shared 上限。

设计要点：SizeCode 表是共用的，但合法范围取决于角色。`LocalTileSizeCodeIsLegal` 只接受编码 1 到 10，而 `TileSizeCodeIsLegal` 接受 1 到 12。单个 Local 对象上限为 64 KiB，而单个 Shared 父级可以占用整个 256 KiB Shared 池。

`TileLogicalElementCapacity` 为 `capacity_bytes x 8 / TileElementBits`。`TileElementBits` 对 X2 打包格式返回 4，其他情况下返回 8、16、32 或 64。

<!-- PTO-READER-BLOCK: tile-model-state-descriptors-boundaries role=boundaries -->
## 架构边界

这些都是纯函数或只读辅助函数。非法 SizeCode 或不可用相对源的故障由调用它们的指令束绑定器引发，例如 Tile 绑定、命令、范围修饰符和 Shared TLSU 所有者。

`InstallRelativeTileFixture` 把寄存器放到任意距离。`ConfigureTile`、`ConfigurePredicateTile` 和 `ConfigureCubeTile` 在移除该寄存器的其他条目之后，以寄存器自身的索引作为选择子调用它；它不是发布规则。

<!-- PTO-READER-BLOCK: tile-model-state-descriptors-example role=example-usage -->
## 非规范阅读示例

从空的 hand T 开始。一个指令束发布寄存器 3，随后另一个指令束发布寄存器 7。

- 第一次发布之后，hand T 的距离 0 保存 3。
- 第二次发布之后，距离 0 保存 7，距离 1 保存 3。
- 此时选择子 0 解析为寄存器 7，选择子 1 解析为寄存器 3。

如果随后释放寄存器 3，`RemoveRelativeTileMapping` 会压紧列表，因此距离 0 仍保存 7，距离 1 变为无效。

Local SizeCode 10 给出 65536 字节。对于 FP16，即 65536 x 8 / 16 = 32768 个逻辑元素。

<!-- PTO-READER-BLOCK: tile-model-state-descriptors-related role=related-owners-navigation -->
## 相关所有者

- [Local 寄存器](local-registers.md)声明相对顺序状态和发布要求。
- [Local 容量](../capacity/local.md)提供 `TileCapacityLimitBytes`。
- [Tile 绑定](../../../block/model/operands/tile-bindings.md)为指令束解析并发布相对 Tile。
- [Tile 分配功能](../../../arch/features/tile-allocation.md)说明架构上的池和对象限制。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/descriptors.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-DESCRIPTORS","surface":"tile","classification":["model","state","descriptors"],"depends_on":["PTO-TILE-MODEL-CAPACITY-SHARED"]}
pure func TileHandOf(index: TileIndex) => TileHand
begin
    if index < 16 then return TileHand_T;
    elsif index < 32 then return TileHand_U;
    elsif index < 48 then return TileHand_M;
    else return TileHand_N;
    end;
end;

pure func TileIndexWithinHand(index: TileIndex) => integer {1..16}
begin
    return ((index MOD 16) + 1) as integer {1..16};
end;

pure func RelativeTileHandIndex(selector: TileIndex) => integer {0..3}
begin
    return (selector DIVRM 16) as integer {0..3};
end;

pure func RelativeTileDistance(selector: TileIndex) => integer {0..15}
begin
    return (selector MOD 16) as integer {0..15};
end;

readonly func RelativeTileSourceAvailable(selector: TileIndex) => boolean
begin
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    if _TileRelativeValid[[hand]][distance] == '0' then return FALSE; end;
    return _Tiles[[_TileRelativeOrder[[hand]][[distance]]]].allocated;
end;

readonly func ResolveRelativeTileSource(selector: TileIndex) => TileIndex
begin
    assert RelativeTileSourceAvailable(selector);
    return _TileRelativeOrder[[RelativeTileHandIndex(selector)]]
        [[RelativeTileDistance(selector)]];
end;

func RemoveRelativeTileMapping(index: TileIndex)
begin
    for hand = 0 to 3 do
        var compact: RelativeTileHandSnapshot;
        var valid = Zeros{16};
        var next: integer {0..16} = 0;
        for distance = 0 to 15 do
            if _TileRelativeValid[[hand]][distance] == '1' &&
               _TileRelativeOrder[[hand]][[distance]] != index then
                compact[[next as integer {0..15}]] =
                    _TileRelativeOrder[[hand]][[distance]];
                valid[next as integer {0..15}] = '1';
                next = (next + 1) as integer {0..16};
            end;
        end;
        _TileRelativeOrder[[hand]] = compact;
        _TileRelativeValid[[hand]] = valid;
    end;
end;

readonly func RelativeTileDestinationPublished(index: TileIndex) => boolean
begin
    let hand = RelativeTileHandIndex(index);
    for distance = 0 to 15 do
        if _TileRelativeValid[[hand]][distance] == '1' &&
           _TileRelativeOrder[[hand]][[distance]] == index then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func PublishRelativeTileDestination(index: TileIndex)
begin
    if RelativeTileDestinationPublished(index) then return; end;
    let hand = RelativeTileHandIndex(index);
    for offset = 0 to 14 do
        let distance = 15 - offset;
        _TileRelativeOrder[[hand]][[distance]] =
            _TileRelativeOrder[[hand]][[distance - 1]];
        _TileRelativeValid[[hand]][distance] =
            _TileRelativeValid[[hand]][distance - 1];
    end;
    _TileRelativeOrder[[hand]][[0]] = index;
    _TileRelativeValid[[hand]][0] = '1';
end;

func InstallRelativeTileFixture(selector: TileIndex, index: TileIndex)
begin
    for hand_index = 0 to 3 do
        for relative_index = 0 to 15 do
            if _TileRelativeValid[[hand_index]][relative_index] == '1' &&
               _TileRelativeOrder[[hand_index]][[relative_index]] == index then
                _TileRelativeValid[[hand_index]][relative_index] = '0';
            end;
        end;
    end;
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    _TileRelativeOrder[[hand]][[distance]] = index;
    _TileRelativeValid[[hand]][distance] = '1';
end;

readonly func TileCapacityIsLegal(capacity_bytes: integer {0..262144}) => boolean
begin
    return capacity_bytes >= PTO_TILE_CELL_BYTES &&
           capacity_bytes MOD PTO_TILE_CELL_BYTES == 0 &&
           capacity_bytes <= PTO_TILE_MAX_ALLOCATION_BYTES &&
           capacity_bytes <= TileCapacityLimitBytes();
end;

readonly func SharedTileCapacityIsLegal(
    capacity_bytes: integer {0..262144}) => boolean
begin
    return capacity_bytes >= PTO_TILE_CELL_BYTES &&
           capacity_bytes MOD PTO_TILE_CELL_BYTES == 0 &&
           capacity_bytes <= SharedTileCapacityLimitBytes();
end;

pure func TileSizeCodeIsLegal(size_code: integer {0..15}) => boolean
begin
    return 1 <= size_code && size_code <= 12;
end;

pure func LocalTileSizeCodeIsLegal(size_code: integer {0..15}) => boolean
begin
    return 1 <= size_code && size_code <= 10;
end;

pure func TileSizeCodeBytes(size_code: integer {1..12})
    => integer {128,256,512,1024,2048,4096,8192,16384,32768,65536,
                131072,262144}
begin
    case size_code of
        when 1 => return 128;
        when 2 => return 256;
        when 3 => return 512;
        when 4 => return 1024;
        when 5 => return 2048;
        when 6 => return 4096;
        when 7 => return 8192;
        when 8 => return 16384;
        when 9 => return 32768;
        when 10 => return 65536;
        when 11 => return 131072;
        when 12 => return 262144;
    end;
end;

pure func TileElementBits(data_type: TileDataType) => integer {4,8,16,32,64}
begin
    case data_type of
        when TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_HiF4X2, TileDataType_S4X2,
             TileDataType_U4X2 => return 4;
        when TileDataType_S8, TileDataType_U8, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E3M2,
             TileDataType_E2M3, TileDataType_E8M0,
             TileDataType_E6M2, TileDataType_RCPE6M2 => return 8;
        when TileDataType_S16, TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16 => return 16;
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 => return 32;
        when TileDataType_S64, TileDataType_U64,
             TileDataType_FP64 => return 64;
    end;
end;

pure func TileDataTypeIsFourBit(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2 ||
           data_type == TileDataType_S4X2 ||
           data_type == TileDataType_U4X2;
end;

// The executable payload remains bounded by PTO_MODEL_TILE_ELEMENTS. Large
// descriptors retain their architectural logical-element capacity through
// width-aware Word carriers, so a 256 KiB Shared shape and the full common
// SizeCode map remain representable without allocating a maximum Word per
// logical element. Local object legality is capped separately at 64 KiB.
readonly func TileLogicalElementCapacity(
    capacity_bytes: integer {0..262144}, data_type: TileDataType)
    => integer {1..524288}
begin
    assert capacity_bytes > 0;
    return ((capacity_bytes * 8) DIVRM TileElementBits(data_type))
        as integer {1..524288};
end;
```
<!-- GENERATED-ASL-END: unit -->
