<!-- GENERATED FROM: asl/tile/memory/pe-movement/GMOV.asl -->
# GMOV

**Normative ASL source:** `asl/tile/memory/pe-movement/GMOV.asl`

Copy the resolved peer-PE Tile fragment selected by the bound peer TID.

## Normative identity {#PTO-INST-TILE-GMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
GMOV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| GMOV | TLSU |  | 13 |  | GMOV |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | resolved-peer-source |
| scalar0 | peer-tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TLSU GMOV, DataType
B.IOT source, destination, PE_MASK, TSize
B.IOR peer_tid
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_GMOV`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `GMOV`
- **Effect contract:** `GMOV`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:resolved-peer-source", "operand:scalar0:peer-tid"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
