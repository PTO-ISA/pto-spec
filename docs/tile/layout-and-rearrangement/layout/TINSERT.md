<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TINSERT.asl -->
# TINSERT

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TINSERT.asl`

Insert a source Tile into a snapshotted old destination region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TINSERT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tinsert-purpose role=purpose -->
## Purpose

`TINSERT` inserts a source Tile into a snapshotted old destination at encoded offsets.

<!-- PTO-READER-BLOCK: tile-tinsert-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_TINSERT` through the instruction's selector-encoded block carrier.

Dimensions, descriptors, layouts, DataTypes, source definedness, consumed encodings, destination capacity, masks, and operation-specific indices or offsets are checked before any source snapshot.

<!-- PTO-READER-BLOCK: tile-tinsert-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the destination; `source0` is the persistent old destination; `source1` is the persistent insertion source; `natural0` is the row-offset; `natural1` is the column-offset.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tinsert-effects role=effects -->
## Publication and ordering

Sources are snapshotted before construction, so allowed aliases observe complete pre-operation payload and definedness.

The complete destination payload, definedness, padding policy, and descriptor publish together; rejection publishes no partial destination.

<!-- PTO-READER-BLOCK: tile-tinsert-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tinsert-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.SFU TINSERT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; B.IOR; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

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
B.DIM LB1 (optional)
B.DIM LB2 (optional)
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

- BSTART.SFU TINSERT, DataType; B.DATR (optional); B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; B.IOR; BSTOP
