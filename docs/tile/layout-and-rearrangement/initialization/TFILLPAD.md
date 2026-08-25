<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
# TFILLPAD

**Normative ASL source:** `asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl`

Copy the source and fill destination padding elements with the bound scalar.

## Normative identity {#PTO-INST-TILE-TFILLPAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tfillpad-purpose role=purpose -->
## What TFILLPAD does

`TFILLPAD` is a selector-encoded Tile operation executed by `SFU`. It copies the valid source region and writes the bound scalar into physical destination padding; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tfillpad-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler copies the valid source region and writes the bound scalar into physical destination padding. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tfillpad-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **destination**.
- `source0` has the exact contract role **source**.
- `scalar0` has the exact contract role **padding**.

The assembled bundle schema fixes descriptor, shape, layout, and applicability checks before the handler runs.

<!-- PTO-READER-BLOCK: tile-tfillpad-effects role=effects -->
## Publication, definedness, and padding

After source and scalar snapshots, valid coordinates copy the source and every non-valid physical coordinate receives the bound scalar.

On success the full physical destination is marked defined and `contents_defined=TRUE`; payload, definedness, and descriptor publish together.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tfillpad-constraints role=constraints -->
## Type, layout, and fault boundary

The exact accepted type or type-pair set is owned by the generated legality section below; this guide does not widen it.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tfillpad-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TFILLPAD` example, a valid source value `5` remains `5`, while physical padding receives bound scalar `9`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TFILLPAD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFILLPAD | TEPL | 0x065 | 5 | 3 | TFILLPAD |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | padding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TFILLPAD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/initialization/TFILLPAD.asl -->
```asl
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;

pure func InstructionContractDataTypeLegal_TFILLPAD(
    data_type: TileDataType) => boolean
begin
    return TileFillPadDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word) => boolean
begin
    return TileOperandsLegal_TFILLPAD(destination, source, padding);
end;

func InstructionContractExecute_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word)
begin
    assert InstructionContractOperandsLegal_TFILLPAD(
        destination,
        source,
        padding);
    TFILLPAD(destination, source, padding);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TFILLPAD schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TFILLPAD.
- B.IOR.RegSrc0 supplies the padding scalar; omitted B.IOR selects zero and only the low selected-element-width bits participate.

## Legality

- TFILLPAD is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TFILLPAD validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"}].

## State effects

- Snapshot the source and bound scalar, copy every valid source coordinate, and write the bound scalar to every non-valid physical destination coordinate.
- Mark the full physical destination defined, set contents_defined=TRUE, and publish payload, definedness, and descriptor atomically after complete preflight.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TFILLPAD, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP
