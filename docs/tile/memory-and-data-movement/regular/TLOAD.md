<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
# TLOAD

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TLOAD.asl`

Load the valid GM rectangle into a Tile using the encoded base and logical row stride.

## Normative identity {#PTO-INST-TILE-TLOAD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TLOAD <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOAD | TLSU |  | 0 |  | TLOAD |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| scalar0 | row-stride-elements |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
# Local form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOT
B.IOR
BSTOP
# Shared form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOS
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TLOAD.asl -->
```asl
pure func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..7}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;

readonly func InstructionContractGMAddress_TLOAD(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryIndexedAddress(base_address,
        TileMemoryStridedIndex(row, column, row_stride_elements), data_type);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TLOAD`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TLOAD`
- **Effect contract:** `TLOAD`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:address:base-address", "operand:scalar0:row-stride-elements"]`

<!-- SUPPLEMENTARY-BEGIN -->
Both Local (`B.IOT`) and Shared (`B.IOS`) destination forms use LB0 as valid
columns, LB1 as valid rows, and LB2 as physical Col. The embedded shape helper
checks the same per-PE TSize/Col/dtype derivation for both forms before memory
probing. An explicit B.IOR supplies base and row stride; omission uses base zero
and LB2 as the dense row stride, while an encoded zero stride remains zero.
<!-- SUPPLEMENTARY-END -->
