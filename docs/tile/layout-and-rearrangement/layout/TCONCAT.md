<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
# TCONCAT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TCONCAT.asl`

Concatenate two source Tiles along columns.

## Normative identity {#PTO-INST-TILE-TCONCAT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TCONCAT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCONCAT | TEPL | 0x060 | 0 | 3 | TCONCAT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractOperation_TCONCAT() => TileOperation
begin
    return TileOperation_TCONCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCONCAT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TCONCAT.asl -->
```asl
readonly func InstructionContractHandler_TCONCAT() => TileSemanticHandler
begin
    return TileHandler_TCONCAT;
end;

pure func InstructionContractDataTypeLegal_TCONCAT(
    data_type: TileDataType) => boolean
begin
    return TileMove24DataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
end;

func InstructionContractExecute_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
    TCONCAT(destination, source_left, source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TCONCAT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TCONCAT.

## Legality

- TCONCAT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TCONCAT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].

## State effects

- Concatenate two source Tiles along columns.
- After complete preflight, execute TCONCAT with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TCONCAT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
