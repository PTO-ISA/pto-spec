# TMATMUL_MX

Execute the TMATMUL_MX Tile operation contract.

<!-- ASL-SOURCE: asl/tile/matrix/matrix-matrix/TMATMUL_MX.asl -->

## Assembly

```asm
TMATMUL_MX <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-matrix/TMATMUL_MX.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX() => TileOperation
begin
    return TileOperation_TMATMUL_MX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TMATMULMX AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 M
B.DIM LB1 N
B.DIM LB2 K
B.IOS Shared operand binder (optional)
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-matrix/TMATMUL_MX.asl -->
```asl
readonly func InstructionContractHandler_TMATMUL_MX() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
