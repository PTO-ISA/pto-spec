<!-- GENERATED FROM: asl/tile/matrix/matrix-matrix/TMATMUL_BIAS.asl -->
# TMATMUL_BIAS

**Normative ASL source:** `asl/tile/matrix/matrix-matrix/TMATMUL_BIAS.asl`

Execute the TMATMUL_BIAS Tile operation contract.

## Normative identity {#PTO-INST-TILE-TMATMUL-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TMATMUL_BIAS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_BIAS | CUBE |  | 1 |  | TMATMUL_BIAS |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-matrix/TMATMUL_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_BIAS() => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TMATMUL.BIAS AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-matrix/TMATMUL_BIAS.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_BIAS() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
