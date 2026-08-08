<!-- GENERATED FROM: asl/tile/complex-layout/layout/TINSERT.asl -->
# TINSERT

**Normative ASL source:** `asl/tile/complex-layout/layout/TINSERT.asl`

Insert the source Tile into the destination region at the encoded row and column offsets.

## Normative identity {#PTO-INST-TILE-TINSERT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TINSERT <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TINSERT | TEPL | 0x063 | 3 | 3 | TINSERT |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| natural0 | row-offset |
| natural1 | column-offset |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TINSERT.asl -->
```asl
readonly func InstructionContractOperation_TINSERT() => TileOperation
begin
    return TileOperation_TINSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TINSERT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TINSERT.asl -->
```asl
readonly func InstructionContractHandler_TINSERT() => TileSemanticHandler
begin
    return TileHandler_TINSERT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TINSERT`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TINSERT`
- **Effect contract:** `TINSERT`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:natural0:row-offset", "operand:natural1:column-offset"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
