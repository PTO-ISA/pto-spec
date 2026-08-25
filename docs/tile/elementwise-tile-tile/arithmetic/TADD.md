<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
# TADD

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TADD.asl`

Add corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tadd-purpose role=purpose -->
## What TADD does

`TADD` is a selector-encoded Tile operation executed by `VEC`. It adds corresponding valid elements from the ordered left and right Local sources; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tadd-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler adds corresponding valid elements from the ordered left and right Local sources. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tadd-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new Local destination**.
- `source0` has the exact contract role **ordered left Local source**.
- `source1` has the exact contract role **ordered right Local source**.

Participating source and destination descriptors use the row-major and shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tadd-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tadd-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tadd-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TADD` example, valid rows `[1, 2]` and `[3, 4]` produce `[4, 6]`.
<!-- SUPPLEMENTARY-END -->

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
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
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
