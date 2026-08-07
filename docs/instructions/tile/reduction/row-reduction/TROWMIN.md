# TROWMIN

Execute the TROWMIN Tile operation contract.

<!-- ASL-SOURCE: asl/tile/reduction/row-reduction/TROWMIN.asl -->

## Normative identity {#PTO-INST-TILE-TROWMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWMIN <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWMIN | TEPL | 0x042 | 2 | 2 | ExecuteTileReduction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/row-reduction/TROWMIN.asl -->
```asl
readonly func InstructionContractOperation_TROWMIN() => TileOperation
begin
    return TileOperation_TROWMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWMIN, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/row-reduction/TROWMIN.asl -->
```asl
readonly func InstructionContractHandler_TROWMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
