# TMATMUL_MX_BIAS

Execute the TMATMUL_MX_BIAS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/matrix/matrix-matrix/TMATMUL_MX_BIAS.asl -->

## Assembly

```asm
TMATMUL_MX_BIAS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX_BIAS() => TileOperation
begin
    return TileOperation_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TMATMULMX.BIAS AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractHandler_TMATMUL_MX_BIAS() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
