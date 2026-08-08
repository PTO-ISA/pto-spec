<!-- GENERATED FROM: asl/tile/memory/regular/TPREFETCH.asl -->
# TPREFETCH

**Normative ASL source:** `asl/tile/memory/regular/TPREFETCH.asl`

Prefetch the requested GM byte range without producing a Tile destination.

## Normative identity {#PTO-INST-TILE-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TPREFETCH <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPREFETCH | TLSU |  | 3 |  | TPREFETCH |

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| byte_count | byte-count |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/regular/TPREFETCH.asl -->
```asl
readonly func InstructionContractOperation_TPREFETCH() => TileOperation
begin
    return TileOperation_TPREFETCH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TLSU TPREFETCH, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/regular/TPREFETCH.asl -->
```asl
readonly func InstructionContractHandler_TPREFETCH() => TileSemanticHandler
begin
    return TileHandler_TPREFETCH;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TPREFETCH`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TPREFETCH`
- **Effect contract:** `TPREFETCH`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:address:base-address", "operand:byte_count:byte-count"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
