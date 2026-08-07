# TGEMV_MX_BIAS

Execute the TGEMV_MX_BIAS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/matrix/matrix-vector/TGEMV_MX_BIAS.asl -->

## Normative identity {#PTO-INST-TILE-TGEMV-MX-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TGEMV_MX_BIAS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX_BIAS | CUBE |  | 21 |  | TGEMV_MX_BIAS |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-vector/TGEMV_MX_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX_BIAS() => TileOperation
begin
    return TileOperation_TGEMV_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TGEMVMX.BIAS AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-vector/TGEMV_MX_BIAS.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX_BIAS() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
