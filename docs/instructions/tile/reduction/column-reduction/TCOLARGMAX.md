# TCOLARGMAX

Execute the TCOLARGMAX Tile operation contract.

<!-- ASL-SOURCE: asl/tile/reduction/column-reduction/TCOLARGMAX.asl -->

## Normative identity {#PTO-INST-TILE-TCOLARGMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCOLARGMAX <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLARGMAX | TEPL | 0x05C | 28 | 2 | ExecuteTileReduction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/column-reduction/TCOLARGMAX.asl -->
```asl
readonly func InstructionContractOperation_TCOLARGMAX() => TileOperation
begin
    return TileOperation_TCOLARGMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TCOLARGMAX, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/column-reduction/TCOLARGMAX.asl -->
```asl
readonly func InstructionContractHandler_TCOLARGMAX() => TileSemanticHandler
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
