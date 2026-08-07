# TTRANS

Execute the TTRANS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/layout/TTRANS.asl -->

## Assembly

```asm
TTRANS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TTRANS.asl -->
```asl
readonly func InstructionContractOperation_TTRANS() => TileOperation
begin
    return TileOperation_TTRANS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TTRANS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TTRANS.asl -->
```asl
readonly func InstructionContractHandler_TTRANS() => TileSemanticHandler
begin
    return TileHandler_TTRANS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
