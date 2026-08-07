# TLOAD

Execute the TLOAD Tile operation contract.

<!-- ASL-SOURCE: asl/tile/memory/regular/TLOAD.asl -->

## Assembly

```asm
TLOAD <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory/regular/TLOAD.asl -->
```asl
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
# Local form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOT
B.IOR
BSTOP
# Shared form
BSTART.TLSU TLOAD
B.DATR/B.DIM
B.IOS
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory/regular/TLOAD.asl -->
```asl
readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
