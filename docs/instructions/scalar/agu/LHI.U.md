# LHI.U

Execute the LHI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LHI.U.asl -->

## Normative identity {#PTO-INST-SCALAR-LHI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lhi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhi_u_32_bb0c81c6e61d | L32 | 32 | 0x00001029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhi_u_32_bb0c81c6e61d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhi_u_32_bb0c81c6e61d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhi_u_32_bb0c81c6e61d | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractOperation_LHI_U() => ScalarOperation
begin
    return ScalarOperation_LHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractHandler_LHI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
