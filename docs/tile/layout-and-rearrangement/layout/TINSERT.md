<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TINSERT.asl -->
# TINSERT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TINSERT.asl`

Insert a source Tile into a snapshotted old destination region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TINSERT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TINSERT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TINSERT | TEPL | 0x063 | 3 | 3 | TINSERT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | persistent old destination |
| source1 | persistent insertion source |
| natural0 | row-offset |
| natural1 | column-offset |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TINSERT.asl -->
```asl
readonly func InstructionContractOperation_TINSERT() => TileOperation
begin
    return TileOperation_TINSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TINSERT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TINSERT.asl -->
```asl
readonly func InstructionContractHandler_TINSERT() => TileSemanticHandler
begin
    return TileHandler_TINSERT;
end;

pure func InstructionContractDataTypeLegal_TINSERT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
end;

func InstructionContractExecute_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
    TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.
- The TileOperandsLegal_TINSERT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TINSERT.

## Legality

- TINSERT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.
- Before effects, TileOperandsLegal_TINSERT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.
- B.DATR applicability is exactly [{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}].

## State effects

- Insert a source Tile into a snapshotted old destination region at the encoded row and column offsets.
- After complete preflight, execute TINSERT with the operand bindings listed above; destination definedness changes only as specified by that handler.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.SFU TINSERT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; B.IOR; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
