# TRELU

Execute the TRELU Tile operation contract.

<!-- ASL-SOURCE: asl/tile/unary-tile-elementwise/logical/TRELU.asl -->

## Normative identity {#PTO-INST-TILE-TRELU}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TRELU <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRELU | TEPL | 0x017 | 23 | 0 | ExecuteTileUnary |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/logical/TRELU.asl -->
```asl
readonly func InstructionContractOperation_TRELU() => TileOperation
begin
    return TileOperation_TRELU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TRELU, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/logical/TRELU.asl -->
```asl
readonly func InstructionContractHandler_TRELU() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
