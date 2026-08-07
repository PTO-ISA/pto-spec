# TMOV

Execute the TMOV Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/layout/TMOV.asl -->

## Assembly

```asm
TMOV <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/layout/TMOV.asl -->
```asl
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TLSU TMOV, DataType
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/layout/TMOV.asl -->
```asl
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
