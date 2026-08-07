# TPARTMUL

Execute the TPARTMUL Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/union/TPARTMUL.asl -->

## Assembly

```asm
TPARTMUL <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/union/TPARTMUL.asl -->
```asl
readonly func InstructionContractOperation_TPARTMUL() => TileOperation
begin
    return TileOperation_TPARTMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TPARTMUL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/union/TPARTMUL.asl -->
```asl
readonly func InstructionContractHandler_TPARTMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
