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
The Shared form uses canonical TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero consumer PE_MASK; optional B.SUBVIEW supplies the only partial-source range.
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
- For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For a pending Shared source they default to 1, 1, and ValidCol.
- An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows.

## Legality

- TSTORE is selected by TLSU Function 1 and has no standalone opcode.
- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Shared source access requires whole-parent readiness and publication.
- Shared PE_MASK selects participating consumer PEs and never infers quarter selection. B.SUBVIEW is the explicit source range mechanism.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle fits the persistent source descriptor.

## State effects

- Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.
- On success only GM and memory-event state change; the source binding is consumed by normal block completion.

## Memory effects and ordering

### Memory effects

- For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.
- The complete selected-PE footprint is translated and permission-checked before the first GM write. A fault therefore produces no partial GM or memory-event effect.

### Ordering

- Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and preflight every selected GM access before storing any element.
- After successful preflight, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately.

## Exceptions

- A malformed binding stream, missing dimensions, unsupported DataType, non-row-major source, undefined Local source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects. An unpublished or not-whole-ready Shared source waits without fault or effect.
- A memory translation, permission, or alignment fault is detected before the first GM write.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
