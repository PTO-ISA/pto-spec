<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TCI.asl`

Generate one ascending or descending typed integer sequence in a new single-row Local Tile.

## Normative identity {#PTO-INST-TILE-TCI}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tci-purpose role=purpose -->
## TCI 的作用

`TCI` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它从绑定起始值形成一行有类型序列，并按逻辑列递增或递减；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tci-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数从绑定起始值形成一行有类型序列，并按逻辑列递增或递减。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tci-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“采用 S32、S16、U32 或 U16 的新 Local 目标”。
- `scalar0` 的精确契约角色是“有类型序列起点”。
- `flag0` 的精确契约角色是“递增或递减方向”。

参与操作的源与目标描述符采用当前契约规定的行优先布局和形状关系。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tci-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tci-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `S32`, `S16`, `U32`, `U16`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tci-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCI` 示例说明：起点 `2` 在递增模式下覆盖三个有效列时产生 `[2, 3, 4]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TCI <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCI | TEPL | 0x066 | 6 | 3 | TCI |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local S32, S16, U32, or U16 destination |
| scalar0 | typed sequence start |
| flag0 | ascending or descending direction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCI, S32|S16|U32|U16
B.DATR all-zero (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1; when present must equal 1)
B.DIM LB2=Col (optional, default ValidCol)
B.IOR Start, Direction (optional; omission selects 0 and ascending)
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/initialization/TCI.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCI(
    data_type: TileDataType) => boolean
begin
    return TileTCIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultStart_TCI() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractDefaultDescending_TCI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TCI(
        destination,
        start,
        descending);
end;

readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;

func InstructionContractExecute_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TCI(
        destination,
        start,
        descending);
    TCI(
        destination,
        start,
        descending);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is always Null.

## Legality

- TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly S32, S16, U32, or U16. The destination is row-major, ValidRow is one, ValidCol is nonzero, and Col is at least ValidCol.
- A present B.IOR consumes RegSrc0 as the raw start value and RegSrc1 as an exact zero or one direction. Bits above the selected start width are ignored. RegSrc2 and RegDst are zero.
- Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects.

## State effects

- For logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.
- Sequence arithmetic wraps modulo the selected element width. Only ValidRow zero participates.
- Every physical destination coordinate outside the one-row valid region is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, dimensions, TSize, direction, mask, destination-name, and allocation preflight precedes the private-GPR snapshots.
- The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, or a nonzero inapplicable B.DATR field raises Fault_TileLegality before allocation.
- An unrepresentable shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.
- PE_MASK zero completes as a strict no-op before every validation or effect.

## Examples

- BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
