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

`TSTORE` 把一个 Tile 矩形写入全局内存（GM）。它是 TLSU Function 1，写作 `BSTART.TSTORE DataType`，并且没有独立 opcode。

完成的指令束恰好有一个源域。Local 源通过一条终止源 `B.IOT` 到达；Shared 源通过一个源 `B.IOS` 到达，并且必须已经发布且达到 whole-parent-ready。Local CUBE 形式通过 `M322ND`、`M162ND` 或 `N82ND` 存储持久 CUBE 描述符。

<!-- PTO-READER-BLOCK: tile-c-tstore-mechanism role=mechanism -->
## 寻址与访问顺序

每个被选中的 PE 与每个活动的有效坐标都通过 `TileMemoryStridedByteAddress` 写入 `base + row * row_stride_bytes + column * element_size`。对打包四位类型，列贡献 `floor(column / 2)` 字节，低半字节或高半字节由列奇偶性选择。

`B.IOR.RegSrc0` 提供每 PE 的 GM 基址，`B.IOR.RegSrc1` 提供字节行步幅。省略 `B.IOR` 时基址为零，步幅为从解析的物理 `Col` 与数据类型推导出的紧密步幅，即 `ceil(columns * element_bits / 8)`；显式编码的零选择子是真正的零步幅。

设计要点：紧密默认值只在省略时生效。由于编码零读取零 GPR，把步幅编码为零的程序会让每一行都别名到 GM 的第 0 行，而不是得到紧密布局。

模型 `TSTORE` 按行主序对每个活动元素探测、存储并记录一个带类型的 store 事件，并在首个内存故障处停止。在谓词 Tile ExecutionMask 下只有活动坐标被存储，因此非活动坐标不产生探测也不产生事件。

设计要点：四位存储是对所在 GM 字节的读-改-写。ASL 载入该字节，只替换被选中的半字节，再写回，因此相邻的半字节总是得以保留。

<!-- PTO-READER-BLOCK: tile-c-tstore-inputs-outputs role=inputs-outputs -->
## 操作数角色、形状与类型

- `source0` 是 Local Tile 或绝对 Shared 源 S0 到 S63。它的 payload、描述符、生产者掩码、就绪状态与生命周期保持不变，其绑定由常规的指令束完成过程消费。
- `address` 是每 PE 私有 GPR 的 GM 基址。
- `scalar0` 是每 PE 私有 GPR 的字节行步幅。

`LB0`、`LB1` 与 `LB2` 在省略时有效值均为 1，解析出的维度会与源描述符核对，而不是从源描述符继承。Shared 源通过非零 `PE_MASK` 选择其消费者 PE，而 `B.SUBVIEW` 是唯一的部分源范围机制。

设计要点：未发布、挂起或未完成的 Shared 源会让指令束等待，既不引发故障，也不产生任何 GM、绑定消费或描述符效果，因此消费者无法观察到写了一半的 Shared 父对象。

<!-- PTO-READER-BLOCK: tile-c-tstore-effects role=effects -->
## 已定义性、填充与发布

源 payload 与描述符在成功之后以及被拒绝之后都持续存在；`TSTORE` 不分配目标，也不发布任何 Tile 状态。改变的只有 GM 与内存事件流。

内存转换、权限或对齐故障会在首个故障处停止请求，在此之前完成的 GM 写入与内存事件可能仍留在 GM 与事件流中可见。

设计要点：一旦所有请求的存储无故障完成，存储拍就没有架构定义的相对顺序。因此两个写同一段 GM 字节的被选中 PE 需要软件避免重叠，或另行建立顺序。

<!-- PTO-READER-BLOCK: tile-c-tstore-constraints role=constraints -->
## 合法性、故障与顺序边界

`InstructionContractDataTypeLegal_TSTORE` 接受 `TileRegularTLSUDataTypeSupported` 允许的编码，即 `0` 到 `14`、`16` 到 `20`，以及 `24` 到 `28`；其余编码为保留值，在任何效果之前被拒绝。

`ValidCol` 与 `ValidRow` 非零，`ValidCol` 不得超过物理 `Col`，并且解析出的有效矩形必须适配持久源描述符。普通形式与 Shared 形式要求 `PadValue` 为零；Local CUBE 编码 `24` 到 `26` 要求 `DTYPE_NONE`，接受全部四种 `PadValue` 编码，并只存储有效元素而忽略物理填充。

绑定流错误、维度缺失、`DataType` 不受支持、源不是行主序、Local 源元素未定义、源编码非法或源几何不匹配，都会在任何效果之前引发 `Fault_TileLegality`。

`PE_MASK=0000` 在两个目标域中都是严格空操作：零 `B.IOT` 掩码使指令束不产生效果，零 `B.IOS` 掩码则在模式、描述符、GPR、内存、故障与源消费效果之前返回。

设计要点：`SharedStorePEMaskLegal` 对 Function 1 接受任意非零掩码，并对其他所有 Function 拒绝非零掩码，因此 `B.IOS` 存储永远不会从掩码中悄悄推断出四分之一选择。

<!-- PTO-READER-BLOCK: tile-c-tstore-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

取 `U8`，Local 源 `T#1` 具有 `Col=64`、`ValidCol=64` 与 `ValidRow=8`，`a1` 中为每 PE 的字节行步幅 `64`，GM 基址在 `a0` 中。

- 规范宏写法是 `TSTORE <Row=8, Col=64, ValidRow=8, ValidCol=64, U8>, T#1, [base=a0, stride=a1]`，它对每个被选中的 PE 写入 `8 * 64 = 512` 个 GM 字节。
- 若 `a1` 保存 `0`，八行都会写入相同的 64 个 GM 字节，而这些字节的最终内容没有架构定义。
- 若第三行发生故障，前两行已经存储并可见；源 Tile 保持不变。
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
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
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
- Omitted LB0, LB1, and LB2 each have effective value one. The resolved dimensions are checked against the source descriptor; omission does not inherit its shape.
- An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.
- Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows.

## Legality

- TSTORE is selected by TLSU Function 1 and has no standalone opcode.
- DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.
- The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Shared source access requires whole-parent readiness and publication.
- Shared PE_MASK selects participating consumer PEs and never infers quarter selection. B.SUBVIEW is the explicit source range mechanism.
- ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle fits the persistent source descriptor.
- The existing explicit ND2M32/M322ND Local conversion forms admit FP64, S64 and U64 with 256 physical bytes per column under issue #371; ordinary and Shared form layout rules remain owned separately.

## State effects

- Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.
- On success only GM and memory-event state change; the source binding is consumed by normal block completion.

## Memory effects and ordering

### Memory effects

- For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.
- The selected-PE footprint is accessed element by element until the first fault. Stores and memory events completed before that fault may remain visible.

### Ordering

- Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and access each selected GM element until the first fault.
- After all requested stores complete without a fault, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately.

## Exceptions

- A malformed binding stream, missing dimensions, unsupported DataType, non-row-major source, undefined Local source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects. An unpublished or not-whole-ready Shared source waits without fault or effect.
- A memory translation, permission, or alignment fault stops the request at the first fault; prior GM writes and memory events may remain visible.

## Examples

- BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP
- BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP
