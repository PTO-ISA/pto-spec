<!-- GENERATED FROM: asl/tile/memory/regular/TSTORE.asl -->
# TSTORE

**Normative ASL source:** `asl/tile/memory/regular/TSTORE.asl`

Store the valid Tile rectangle to GM using the encoded base and logical row stride.

## Normative identity {#PTO-INST-TILE-TSTORE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSTORE <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSTORE | TLSU |  | 1 |  | TSTORE |

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| scalar0 | row-stride-elements |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/regular/TSTORE.asl -->
```asl
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
# Local form
BSTART.TLSU TSTORE
B.DATR/B.DIM
B.IOT
B.IOR
BSTOP
# Shared full form
BSTART.TLSU Function 1
B.IOS
B.IOR
BSTOP
# Shared pe_scope form
BSTART.TLSU Function 14
B.IOS
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/regular/TSTORE.asl -->
```asl
readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryIndexedAddress(base_address,
        TileMemoryStridedIndex(row, column, row_stride_elements), data_type);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TSTORE`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TSTORE`
- **Effect contract:** `TSTORE`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:address:base-address", "operand:scalar0:row-stride-elements", "operand:source0:source"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
