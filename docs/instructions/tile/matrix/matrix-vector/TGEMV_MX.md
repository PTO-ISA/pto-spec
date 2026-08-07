# TGEMV_MX

Execute the TGEMV_MX Tile operation contract.

<!-- ASL-SOURCE: asl/tile/matrix/matrix-vector/TGEMV_MX.asl -->

## Assembly

```asm
TGEMV_MX <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX() => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TGEMVMX AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 M
B.DIM LB1 N
B.DIM LB2 K
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractHandler_TGEMV_MX() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
