<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
# TADD

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TADD.asl`

Add corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TADD | TEPL | 0x000 | 0 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered left Local source |
| source1 | ordered right Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
readonly func InstructionContractOperation_TADD() => TileOperation
begin
    return TileOperation_TADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TADD, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol; an explicitly present zero dimension is illegal.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null respectively.
- The destination physical Rows are derived from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TADD is selected only by BSTART.VEC Mode 0 Function 0 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination. B.IOR and B.IOS are not accepted; all participating Tiles use one PE_MASK and zero mask is a strict no-op.
- The selected DataType is exactly S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Both source valid regions are completely defined and source/destination physical shape, valid shape, row-major layout, and DataType match.
- B.DATR applicability allows only PadValueOrByteId as PadValue.

## State effects

- After complete preflight, add corresponding source elements and atomically publish the valid destination region.
- Physical destination elements outside ValidRow x ValidCol receive the selected PadValue; Null padding remains undefined while Zero, Max, and Min padding are defined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted before the first destination write, so source/destination aliasing is read-before-write.

## Exceptions

- A missing LB0, malformed Local B.IOT, B.IOR or B.IOS presence, source shape or type mismatch, undefined source element, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before destination effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TADD, U64; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
