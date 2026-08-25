<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
# TSCATTER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TSCATTER.asl`

Scatter values to distinct destination rows selected independently at each source coordinate.

## Normative identity {#PTO-INST-TILE-TSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tscatter-purpose role=purpose -->
## TSCATTER 的作用

`TSCATTER` 按索引 Tile 选择的目标行写入源值。

<!-- PTO-READER-BLOCK: tile-c-tscatter-mechanism role=mechanism -->
## 操作机制

每个物理目标坐标会先初始化为带类型的零。

对源坐标 `[r,c]`，索引值 `k` 把精确源位s 写到目标 `[k,c]`；重复目标坐标非法。

<!-- PTO-READER-BLOCK: tile-c-tscatter-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 提供持久源 Tile。

- `source1` 提供索引 Tile。

- 值 Tile 接受 non-打包类型：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`HiF8`、`E4M3`、`E5M2`、`E3M2`、`E2M3`、`E8M0`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

- 索引 Tile 只接受：`S16`、`U16`、`S32`、`U32`、`S64`、`U64`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tscatter-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tscatter-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-tscatter-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TSCATTER <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSCATTER | TEPL | 0x070 | 16 | 3 | TSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new zero-initialized Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperation_TSCATTER() => TileOperation
begin
    return TileOperation_TSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSCATTER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TSCATTER(destination, source, indices);
end;

readonly func InstructionContractHandler_TSCATTER() => TileSemanticHandler
begin
    return TileHandler_TSCATTER;
end;

func InstructionContractExecute_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSCATTER(
        destination,
        source,
        indices);
    TSCATTER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId is encoded zero and means typed positive or integer zero for this operation; every other B.DATR field remains zero.
- Before scatter writes, every physical destination element is initialized to the selected value DataType's positive or integer zero and is defined.

## Legality

- TSCATTER uses the TEPL encoding carrier Mode 3 Function 16, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Every non-packed B8-NP, B16, B32, or B64 value pairs with every S16, U16, S32, U32, S64, or U64 index.
- The two sources have the same nonzero valid shape. Destination ValidCol equals source ValidCol and destination ValidRow is nonzero.
- Every signed index is nonnegative and every index is less than destination ValidRow. No two source coordinates may select the same destination coordinate [index[r,c],c].
- Both source valid rectangles are fully defined and validly encoded. All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- Initialize every physical destination coordinate to typed positive or integer zero.
- For every source coordinate [r,c], read k=index[r,c] and write source[r,c] bit-for-bit to destination[k,c].
- Both sources persist, no previous destination value is read, and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type-pair, dimension, layout, capacity, index-range, duplicate-coordinate, and source-definedness preflight precedes source snapshots.
- Both sources are snapshotted before zero initialization and scatter evaluation; complete destination payload, physical definedness, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value/index pair, zero or mismatched source shape, destination-column mismatch, negative or out-of-range index, duplicate destination coordinate, undefined source, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index and duplicate checks, allocation, faults, zero initialization, or payload effects.

## Examples

- BSTART.SFU TSCATTER, U16; B.DIM LB0=2; B.DIM LB1=4; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
