<!-- GENERATED FROM: asl/tile/matrix/matrix-matrix/TMATMUL_ACC.asl -->
# TMATMUL_ACC

**Normative ASL source:** `asl/tile/matrix/matrix-matrix/TMATMUL_ACC.asl`

Execute the TMATMUL_ACC Tile operation contract.

## Normative identity {#PTO-INST-TILE-TMATMUL-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TMATMUL_ACC <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_ACC | CUBE |  | 2 |  | TMATMUL_ACC |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TMATMUL.ACC AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOS Shared operand binder (optional)
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
