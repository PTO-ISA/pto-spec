<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
# TSUB

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl`

Subtract corresponding right-source elements from left-source elements.

## Normative identity {#PTO-INST-TILE-TSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSUB <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSUB | TEPL | 0x001 | 1 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | minuend |
| source1 | subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractOperation_TSUB() => TileOperation
begin
    return TileOperation_TSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSUB, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSUB is BSTART.VEC Mode 0 Function 1 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.
- Only B.DATR PadValueOrByteId is applicable.

## State effects

- Publish source-left minus source-right for each valid coordinate after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TSUB, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
