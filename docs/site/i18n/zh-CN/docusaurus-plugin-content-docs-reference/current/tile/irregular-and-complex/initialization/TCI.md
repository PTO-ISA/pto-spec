<!-- GENERATED FROM: asl/tile/irregular-and-complex/initialization/TCI.asl -->
# TCI

**Normative ASL source:** `asl/tile/irregular-and-complex/initialization/TCI.asl`

Generate a typed integer sequence in a new Local Tile, retaining RowMajor and adding explicit CUBE_M16/CUBE_M32 forms.

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
| scalar0 | typed sequence start from RowMajor/CUBE RegSrc0 |
| flag0 | RowMajor direction or CUBE packed Step2D from RegSrc1 |

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
B.DATR RowMajor all-zero (optional), or explicit CUBE_M32/CUBE_M16 tuple
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (RowMajor optional, default 1; when present must equal 1; CUBE required positive)
B.DIM LB2=Col (RowMajor optional, default ValidCol; CUBE optional; omitted aligns ValidCol to the cell-column quantum)
RowMajor: B.IOR Start, Direction (optional; omission selects 0 and ascending)
CUBE: exactly one B.IOR StartGPR, Step2DGPR, zero, ->zero
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

- RowMajor retains the existing defaults: LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.
- CUBE is selected only by explicit B.DATR Layout=CUBE_M32 (29) or CUBE_M16 (31); its present B.DATR must use DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, and Canonicalize=0.
- CUBE omitted LB2 selects Col=align_up(ValidCol, TileCubeCellColumns(Layout, DataType)); explicit Col is never rounded. CUBE requires one canonical B.IOR with StartGPR, packed Step2DGPR, zero, and ->zero. Physical padding is always Null.

## Legality

- TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.
- The selected DataType is exactly S32, S16, U32, or U16. The existing RowMajor form remains one-row with ValidRow one, ValidCol nonzero, and Col at least ValidCol.
- The CUBE form is selected only by explicit Layout CUBE_M32 (29) or CUBE_M16 (31), uses a Matrix-location Local numeric destination, and retains one exact TileInfo.columns physical Col independently of ValidCol.
- CUBE M16 requires ValidRow>0 and ValidRow<=16; CUBE M32 accepts every positive ValidRow. Both forms require ValidCol<=Col and a cell-column-aligned explicit Col.
- CUBE B.DATR is exactly {Layout=CUBE_M32/CUBE_M16, DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, Canonicalize=0}.
- CUBE B.IOR is exactly StartGPR, packed Step2DGPR with signed s32 RowStep in bits [63:32] and signed s32 ColStep in bits [31:0], then zero and ->zero. Each step is exactly -1, 0, or +1.
- For every logical [0,ValidRow) x [0,ValidCol), CUBE writes trunc_W(Start + r*RowStep + c*ColStep) through the physical CELL mapping. TCI.COL and TCI.ROW spellings are reader-only aliases for the four unit-step tuples and do not add an opcode, selector, or catalog identity.
- PE_MASK zero is a strict no-op before GPR reads, validation, allocation, faults, or payload effects.

## State effects

- For RowMajor logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.
- RowMajor sequence arithmetic wraps modulo the selected element width; only its ValidRow=1 row participates.
- For CUBE, sequence arithmetic wraps modulo the selected element width over the logical rectangle [0,ValidRow) x [0,ValidCol).
- For RowMajor, every physical destination coordinate outside the one-row valid region is undefined Null padding.
- For CUBE, every physical destination coordinate outside the valid rectangle is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, form/type, dimensions, exact CUBE Col, TSize, step/selector, mask, destination-name, and capacity preflight precedes private-GPR snapshots.
- The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- RowMajor keeps the existing Fault_TileLegality rules for malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, and nonzero inapplicable B.DATR fields.
- CUBE malformed command/B.IOR structure raises Fault_BundleControl; invalid selectors, tuple, dimensions, steps, alignment, or representability raise Fault_TileLegality; a legal CUBE geometry with insufficient explicit TSize or exhausted Tile capacity raises Fault_TileAllocation. All reject before allocation/publication.
- PE_MASK zero completes as a strict no-op before every validation, GPR read, descriptor check, allocation, fault, and payload effect.

## Examples

- BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
- BSTART.SFU TCI, U16; B.DATR CUBE_M16, DTYPE_NONE, 0, 0, 0, 0, 0; B.DIM LB0=3; B.DIM LB1=2; B.DIM LB2=4; B.IOR StartGPR, Step2DGPR, zero, ->zero; B.IOT mask=1111, <last>, ->T0<1>; BSTOP
