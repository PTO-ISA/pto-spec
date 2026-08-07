# THISTOGRAM

Execute the THISTOGRAM Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/initialization/THISTOGRAM.asl -->

## Assembly

```asm
THISTOGRAM <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL THISTOGRAM, DataType
B.DATR selected_byte
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/initialization/THISTOGRAM.asl -->
```asl
readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
