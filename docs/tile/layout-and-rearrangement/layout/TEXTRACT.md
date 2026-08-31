<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
# TEXTRACT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl`

Extract a rectangular source region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TEXTRACT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-textract-purpose role=purpose -->
## What TEXTRACT does

`TEXTRACT` is a selector-encoded Tile operation executed by `SFU`. It copies the rectangle beginning at the encoded row and column offsets into the destination; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-textract-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler copies the rectangle beginning at the encoded row and column offsets into the destination. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-textract-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **destination**.
- `source0` has the exact contract role **source**.
- `natural0` has the exact contract role **row-offset**.
- `natural1` has the exact contract role **column-offset**.

The assembled bundle schema fixes descriptor, shape, layout, and applicability checks before the handler runs.

<!-- PTO-READER-BLOCK: tile-textract-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

No padding behavior beyond the current handler contract is implied.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-textract-constraints role=constraints -->
## Type, layout, and fault boundary

The exact accepted type or type-pair set is owned by the generated legality section below; this guide does not widen it.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-textract-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TEXTRACT` example, a one-by-one destination at row offset `1` and column offset `1` receives source element `[1,1]`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXTRACT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXTRACT | TEPL | 0x062 | 2 | 3 | TEXTRACT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| natural0 | row-offset |
| natural1 | column-offset |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXTRACT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM LB1 (optional)
B.DIM LB2 (optional)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
```asl
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;

pure func InstructionContractDataTypeLegal_TEXTRACT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
end;

func InstructionContractExecute_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
    TEXTRACT(destination, source, row_offset, column_offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TEXTRACT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TEXTRACT.

## Legality

- TEXTRACT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TEXTRACT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].
- The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType.

## State effects

- Extract a rectangular source region at the encoded row and column offsets.
- After complete preflight, execute TEXTRACT with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TEXTRACT, DataType; B.DATR (optional); B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; B.IOR; BSTOP
