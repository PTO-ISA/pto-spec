# TROWPROD

Execute the TROWPROD Tile operation contract.

<!-- ASL-SOURCE: asl/tile/reduction/row-reduction/TROWPROD.asl -->

## Normative identity {#PTO-INST-TILE-TROWPROD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWPROD <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWPROD | TEPL | 0x043 | 3 | 2 | ExecuteTileReduction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/row-reduction/TROWPROD.asl -->
```asl
readonly func InstructionContractOperation_TROWPROD() => TileOperation
begin
    return TileOperation_TROWPROD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWPROD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/row-reduction/TROWPROD.asl -->
```asl
readonly func InstructionContractHandler_TROWPROD() => TileSemanticHandler
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
