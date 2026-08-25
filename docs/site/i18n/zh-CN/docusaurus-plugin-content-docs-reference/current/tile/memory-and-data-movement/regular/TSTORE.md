<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
# TSTORE

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TSTORE.asl`

Store one ordinary Local or Shared rectangle, or explicitly convert persistent Local CUBE storage into one GM rectangle.

## Normative identity {#PTO-INST-TILE-TSTORE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tstore-purpose role=purpose -->
## TSTORE 的作用

`TSTORE` 把一个有效 Local 或 Shared 矩形存储到 GM，并保持源 Tile 不变。

<!-- PTO-READER-BLOCK: tile-c-tstore-mechanism role=mechanism -->
## 操作机制

完整的选定 PE GM 访问范围会在第一次存储前完成地址转换与权限检查。

预检成功后，每个有效源元素都按解析后的字节行步幅存储；打包四位元素按列奇偶性选择字节半区。

<!-- PTO-READER-BLOCK: tile-c-tstore-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 提供持久源 Tile。

- `address` 提供逐 PE GM 基地址。

- `scalar0` 提供字节行步长。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tstore-effects role=effects -->
## 已定义性、填充与发布

源载荷与描述符保持不变；完整访问范围预检成功后，只有 GM 与内存事件状态改变。

故障不会留下部分 GM 写入或内存事件前缀。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tstore-constraints role=constraints -->
## 合法性、故障与顺序边界

绑定模式、维度、DataType、布局、源描述符或临时 Shared 描述符，以及每个选定 GM 访问都会在效果前预检。

合法性或 GM 访问故障不会留下部分 GM 或内存-事件效果；TSTORE 不执行目标分配或目标发布。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、描述符检查、故障、GM 写入或内存事件效果之前。

重叠的选定 PE GM 区域没有架构定义的存储拍顺序；软件必须避免重叠或另行建立顺序。

<!-- PTO-READER-BLOCK: tile-c-tstore-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TSTORE <bundle operands>` 会在存储有效矩形前完成全部形状、描述符与 GM 访问检查；源 Tile 保持不变。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TSTORE <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSTORE | TLSU |  | 1 |  | TSTORE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| source0 | Local Tile or absolute Shared S0..S63 source |
| address | per-PE private-GPR GM base address |
| scalar0 | per-PE private-GPR byte row stride |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
```asl
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
The Local form uses TLSU Function 1, exactly one terminating source B.IOT, at most one B.IOR, and no B.IOS.
The Shared full form uses TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and PE_MASK=1111 for every nonzero access.
The Shared partial form uses TLSU Function 14 (TSTORE.SPART), exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero PE subset.
The Local CUBE form uses Function 1, explicit B.DATR M322ND, M162ND, or N82ND with DTYPE_NONE, explicit LB0/LB1, absent LB2, and one persistent source B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TSTORE.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSTORE(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word,
    row: integer {0..65535},
    column: integer {0..65535},
    row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TSTORE(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;

pure func InstructionContractZeroMaskNoEffect_TSTORE(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractCubeDimensionsLegal_TSTORE(
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

- DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects ordinary NORM layout. Ordinary and Shared forms require PadValue zero; Local CUBE codes 24 through 26 require DTYPE_NONE, accept all four PadValue encodings, and ignore physical padding while storing only valid elements.
- For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For an unallocated Shared source they default to 1, 1, and ValidCol.
- An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity containing the completed shape. The temporary descriptor supplies undefined-register values and is never written back.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows.

## Legality

- TSTORE is selected only by BSTART.TSTORE/TLSU Function 1 or the Function 14 TSTORE.SPART variant and has no standalone opcode.
- DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Function 14 accepts only one Shared B.IOS. Source/destination role mismatches and mixed domains are illegal.
- A nonzero Function 1 Shared store requires PE_MASK=1111. Function 14 accepts every nonzero subset. PE_MASK=0000 is a strict no-op.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor or the derived temporary Shared descriptor.
- Ordinary forms require nonzero ValidCol and ValidRow, ValidCol not greater than physical Col, and a valid rectangle fitting the source descriptor. Local CUBE forms require explicit nonzero LB0/LB1, absent LB2, and an exact persistent Matrix descriptor matching code, dtype, and shape.
- Ordinary and Shared forms require PadValue zero. Local CUBE codes 24 through 26 accept all four PadValue encodings, require DTYPE_NONE, and ignore physical padding while storing the valid rectangle only.

## State effects

- Read one Local or Shared source without modifying its payload, descriptor, allocation mask, initialized mask, or lifetime.
- A Shared undefined-source read remains non-allocating and non-mutating. On success only GM and memory-event state change; normal block completion consumes the source binding, not the Tile value.
- A successful CUBE form stores raw valid values through CUBE storage indices and never writes or changes physical padding, payload, descriptor, allocation mask, or definedness.

## Memory effects and ordering

### Memory effects

- For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.
- The complete selected-PE footprint is translated and permission-checked before the first GM write. A fault therefore produces no partial GM or memory-event effect.

### Ordering

- Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and preflight every selected GM access before storing any element.
- After successful preflight, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately.

## Exceptions

- Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, or GM translation, permission, or alignment fault raises Illegal Block Exception or the applicable data fault before the first GM write.
- An unallocated or selected-quarter-uninitialized Shared source is not an exception; it reads as an undefined register through a non-mutating operation-derived descriptor.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP
- BSTART.TSTORE FP16 using Function 14; B.IOS S7, mask=0011; BSTOP
- BSTART.TSTORE FP16; B.DATR {M162ND, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=M; B.IOT M#1, mask=1111, <last>; BSTOP
