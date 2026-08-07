# TSEL

Execute the TSEL Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-tile-elementwise/logical/TSEL.asl -->

## Normative identity {#PTO-INST-TILE-TSEL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TSEL <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSEL | TEPL | 0x01A | 26 | 0 | ExecuteTileSelect |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-tile-elementwise/logical/TSEL.asl -->
```asl
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSEL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-tile-elementwise/logical/TSEL.asl -->
```asl
readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
