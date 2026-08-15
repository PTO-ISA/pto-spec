<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl -->
# TEXTRACT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl`

Extract a rectangular source region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TEXTRACT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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
B.DIM (LB1/LB2 for 2D)
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
    return TileMove24DataTypeSupported(data_type);
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

- BSTART.SFU TEXTRACT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; B.IOR; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
