<!-- GENERATED FROM: asl/tile/memory/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory/irregular/MGATHER_CAS.asl`

Atomically compare and conditionally replace GM elements at Tile-provided indices.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | MGATHER_CAS |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | indices |
| source1 | expected |
| source2 | replacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.IOT
B.IOR base_address
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_MGATHER_CAS`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["Layout"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `MGATHER_CAS`
- **Effect contract:** `MGATHER_CAS`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:address:base-address", "operand:source0:indices", "operand:source1:expected", "operand:source2:replacement"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
