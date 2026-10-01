<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
# TLOAD

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TLOAD.asl`

Load one ordinary Local or Shared rectangle, or explicitly convert one GM rectangle into persistent Local CUBE storage.

## Normative identity {#PTO-INST-TILE-TLOAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tload-purpose role=purpose -->
## TLOAD 的作用

`TLOAD` 把全局内存（GM）中一个带类型的矩形读入 Tile。它是 TLSU Function 0，写作 `BSTART.TLOAD DataType`，并且没有独立 opcode。

指令束模式在四个目标域中选择一个：普通 Local Tile、Shared 父对象、Local CUBE Tile，或 Shared 卷积权重视图。它们共享同一个带步幅的 GM 矩形，只在目标表示与填充规则上不同。

<!-- PTO-READER-BLOCK: tile-tload-mechanism role=mechanism -->
## 寻址与访问顺序

每个被选中的 PE 与每个有效坐标使用由 `TileMemoryStridedByteAddress` 构造的地址 `base + row * row_stride_bytes + column * element_size`。对打包四位类型，列贡献 `floor(column / 2)` 字节，半字节由列奇偶性选择。

`B.IOR.RegSrc0` 提供每 PE 的 GM 基址，`B.IOR.RegSrc1` 提供字节行步幅。省略 `B.IOR` 时基址为零，步幅为紧密宽度 `TileDenseRowStrideBytes(physical Col, data_type)`，即 `ceil(columns * element_bits / 8)`。

设计要点：紧密默认值只在省略时生效。显式编码的零选择子读取零 GPR，因此它是真正的零步幅，每一行都别名到 GM 的第 0 行。

模型 `TLOAD` 按行主序对每个元素探测、载入并记录一个带类型的 load 事件，并在首个故障处停止。一旦所有访问成功，有效区域被标记为已定义，随后 CUBE 目标在其物理 CELL 尾部接收 `CurrentBundlePadValue()`。

设计要点：与 `MGATHER` 和 `MSCATTER` 不同，`TLOAD` 不会在首次载入之前预检整个矩形（NDF `PTO-TLOAD-MEMORY-001`），因此故障会留下部分定义的目标，而该目标不会被发布为完整结果。

<!-- PTO-READER-BLOCK: tile-tload-inputs-outputs role=inputs-outputs -->
## 操作数角色与绑定

- `destination0` 是新的 Local 目标或绝对 Shared 目标。
- `address` 是每 PE 私有 GPR 的 GM 基址。
- `scalar0` 在普通形式与 CUBE 形式中是每 PE 私有 GPR 的字节行步幅，在权重模式中是打包的 ShapeGPR。
- `scalar1` 是权重模式打包的 StartGPR，不适用于其他形式。

完成的指令束恰好有一个目标域：Local 目标对应一条终止目标 `B.IOT`，Shared 目标对应一个目标 `B.IOS`。它没有 Tile 源，并且最多消费一个 `B.IOR`。

设计要点：目标域由绑定种类而不是数据属性选择，因此一个指令束不能同时发布 Local Tile 与 Shared 父对象。

<!-- PTO-READER-BLOCK: tile-tload-effects role=effects -->
## 发布与部分结果

成功的 Local 形式分配或重命名一个目标 Tile，安装推导出的描述符，并把有效区域标记为已定义。单发布者 Shared 形式发布完整的父对象；多个发布者必须使用带显式写入者范围的 `B.ASSEMBLE`。

CUBE 形式通过 CUBE 存储索引写入原始有效值，并把 `Zero`、`Max`、`Min` 或未定义的 `Null` 施加到物理尾部，这些尾部不计为有效元素。故障时请求在首个失败的转换、权限或对齐检查处停止，已完成的读取可能留在部分定义的目标中。

设计要点：NDF `PTO-TLOAD-CUBE-001` 只在所有有效 GM 读取无故障完成后才施加编码的 `PadValue`，因此发生故障的 CUBE 载入会使其物理尾部保持未定义，而不是被填充。

<!-- PTO-READER-BLOCK: tile-tload-constraints role=constraints -->
## 类型、形状与故障

`InstructionContractDataTypeLegal_TLOAD` 接受 `TileRegularTLSUDataTypeSupported` 允许的编码，即 `0` 到 `14`、`16` 到 `20`，以及 `24` 到 `28`；编码 `15`、`21` 到 `23` 与 `29` 到 `31` 在任何效果之前被拒绝。

`ValidCol` 与 `ValidRow` 非零，`ValidCol` 不得超过物理 `Col`，并且推导出的 `Rows` 与 `Col` 是 2 的幂且大到足以包含有效矩形。普通形式与 Shared 形式只允许 `Layout` 作为非零属性，并要求 `PadValue` 为零；Local CUBE 布局还要求 `DTYPE_NONE`，并接受全部四种 `PadValue` 编码。权重模式仅限显式使用，并在一个 `B.IOR` 中携带 GMBase、ShapeGPR 与 StartGPR。

`PE_MASK=0000` 在 Local 路径上是严格空操作，它在操作数模式、GPR 读取、目标分配与 GM 访问之前返回；在 Shared 路径上，共享绑定掩码为零时立即返回。

设计要点：CUBE 形式要求显式非零的 `LB0` 与 `LB1`，并且 `LB2` 必须缺省（`InstructionContractCubeDimensionsLegal_TLOAD`），因为 CELL 几何来自布局、数据类型与有效形状，而不是来自物理列数。

<!-- PTO-READER-BLOCK: tile-tload-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

取 `U8`、`Col=64`、`ValidCol=64` 与 `ValidRow=8`，其中 `a0` 保存 GM 基址，`a1` 保存字节行步幅 `64`。

- 规范宏写法是 `TLOAD <Row=8, Col=64, U8>, [base=a0, stride=a1], ->T<512B>`，即一个 512 字节、8 行 64 列元素的目标。
- 省略 `B.IOR` 会推导出紧密步幅 `64`；若把 `a1` 编码为零，则每一行都读取相同的 64 个 GM 字节。
- 只有当全部 `512` 个元素载入及其 load 事件无故障完成时，目标才会被发布。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TLOAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOAD | TLSU |  | 0 |  | TLOAD |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination or absolute Shared destination |
| address | per-PE private-GPR GM base address |
| scalar0 | ordinary per-PE private-GPR byte row stride or weight-mode packed ShapeGPR |
| scalar1 | weight-mode packed StartGPR; inapplicable to ordinary and CUBE forms |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Local: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM defines ValidCol, ValidRow, and physical Col; optional B.IOR defines the per-PE GM base and byte row stride; one terminating destination B.IOT allocates the result; BSTOP commits.
Shared: replace B.IOT with one destination B.IOS carrying absolute S0..S63, SizeCode, and PE_MASK. One issuer loads the complete parent; multiple issuers require B.ASSEMBLE with explicit writer ranges.
Weight Shared: B.DATR OHWI2NK/OIHW2NK selects the convolution-weight transformation; LB0/LB1/LB2 are ValidK/ValidN/TotalK and one B.IOR carries GMBase, ShapeGPR, StartGPR.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TLOAD(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..12}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;

readonly func InstructionContractGMAddress_TLOAD(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TLOAD(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
end;

pure func InstructionContractZeroMaskNoEffect_TLOAD(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractCubeDimensionsLegal_TLOAD(
    lb0_present: boolean, lb0: integer {0..65535},
    lb1_present: boolean, lb1: integer {0..65535},
    lb2_present: boolean) => boolean
begin
    return lb0_present && lb0 != 0 &&
           lb1_present && lb1 != 0 && !lb2_present;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit in BSTART.TLOAD. Omitted B.DATR selects ordinary NORM layout. Explicit CUBE Layout 21 through 23 requires DTYPE_NONE and consumes PadValue for physical CELL tails.
- LB0/ValidCol and LB1/ValidRow default through the common destination-shape rules. Omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must contain ValidRow.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero GPR selector is present and reads zero, so an explicitly encoded zero stride aliases rows rather than selecting the omission default.
- Weight mode is explicit-only and uses DTYPE_NONE with Zero/EQ/Default/0/0 controls; the destination view is row-major NK with K contiguous.

## Legality

- TLOAD is selected only by TLSU Function 0 through BSTART.TLOAD; it has no standalone opcode.
- The completed block has exactly one destination domain: one terminating destination B.IOT for Local or one destination B.IOS for Shared. It has no Tile source and consumes at most one B.IOR.
- The BSTART DataType accepts every assigned Tile DataType code and rejects 15, 21..23, and 29..31 before effects. Ordinary and Shared forms permit only Layout and require PadValue zero; Local CUBE codes 21 through 23 additionally permit all four PadValue encodings and require DTYPE_NONE while CMode, RMode, Sat, and Canonicalize retain zero meanings.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the derived Rows and Col are powers of two large enough for the valid rectangle.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, load events, descriptor changes, or payload changes.
- Ordinary forms require nonzero ValidCol and ValidRow, ValidCol not greater than physical Col, and power-of-two physical Rows and Col. CUBE forms require explicit nonzero LB0/LB1, absent LB2, and derive CELL geometry from Layout, dtype, and valid shape.
- Weight layouts 10 and 11 are accepted only by the specialized BSTART.TLOAD weight Shared schema; reserved KN codes 12 and 13 are not implemented. The exact three-source B.IOR, packed-field reservations, K/C0 alignment, row-major NK shape, and selected-PE equality checks are mandatory.

## State effects

- A successful Local form allocates or renames exactly one destination Tile, installs the derived descriptor, loads every selected valid element, and marks the valid region defined.
- A successful singleton Shared form loads and publishes the complete parent from that issuer PE. A multi-PE Shared form uses B.ASSEMBLE explicit ranges; TLOAD never modifies source GPRs or GM.
- A successful CUBE form writes raw valid values through CUBE storage indices and applies Zero, Max, Min, or undefined Null to physical tail positions without counting tails as valid elements.
- Weight mode reuses the existing Shared row-major descriptor and B.ASSEMBLE generation protocol; ordinary TLOAD semantics are unchanged.

## Memory effects and ordering

### Memory effects

- For each selected PE and each element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size. Packed four-bit types add floor(column / 2) to each byte-strided row base and select the nibble from column parity.
- The accesses participate in PTO-RC using the block aq/rl attributes; the request reports the first fault and may retain effects completed before it.
- Weight mode reads dense OHWI/OIHW source elements in canonical [kh][kw][c1][c0] order, supplies defined raw-zero Cin padding, and atomically publishes the Shared generation after complete preflight.

### Ordering

- Resolve the complete schema, selected PE mask, per-PE GPR inputs, dimensions, and destination capacity before the first architectural load effect; translate and access each element until the first fault.
- On success publish the complete Local destination or complete Shared parent at block commit. A fault may leave a partially defined Local destination or Shared generation, which is not advertised as complete or whole-parent-ready.

## Exceptions

- Reserved DataType, unsupported or wrong-direction Layout, operation-inapplicable PadValue, malformed B.IOR/B.IOT/B.IOS schema, invalid dimensions, capacity or shape overflow, allocation failure, or GM translation, permission, or alignment fault rejects before destination publication.
- The request stops at the first memory fault; reads and load events completed before that fault may remain in a partially defined Local destination or Shared generation. A partial result is not complete or whole-parent-ready.

## Examples

- BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP
- BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0001, ->S7<1>; BSTOP
- BSTART.TLOAD FP16; B.DATR {ND2N8, DTYPE_NONE, Max, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=K; B.IOT mask=1111, <last>, ->N<3>; BSTOP
- BSTART.TLOAD FP16; B.DATR {OIHW2NK, DTYPE_NONE, Zero, EQ, Default, 0, 0}; B.DIM LB0=ValidK; B.DIM LB1=ValidN; B.DIM LB2=TotalK; B.IOR GMBase, ShapeGPR, StartGPR, ->zero; B.IOS mask, ->S0<SizeCode>; BSTOP
