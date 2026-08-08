<!-- GENERATED FROM: asl/tile/matrix/matrix-matrix/TMATMUL.asl -->
# TMATMUL

**Normative ASL source:** `asl/tile/matrix/matrix-matrix/TMATMUL.asl`

Execute the TMATMUL Tile operation contract.

## Normative identity {#PTO-INST-TILE-TMATMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TMATMUL <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL | CUBE |  | 0 |  | TMATMUL |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL() => TileOperation
begin
    return TileOperation_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.CUBE TMATMUL AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-matrix/TMATMUL.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL() => TileSemanticHandler
begin
    return TileHandler_TMATMUL;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->
The block uses `LB0=N`, `LB1=M`, and `LB2=Col`, where Col is the physical
power-of-two column count of the result Tile. K is the equal logical inner
dimension of the two source descriptors. M, N, and K must each be nonzero
powers of two before any destination allocation or operand effect.
<!-- SUPPLEMENTARY-END -->
