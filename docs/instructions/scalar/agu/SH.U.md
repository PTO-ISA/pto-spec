# SH.U

Execute the SH.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SH.U.asl -->

## Normative identity {#PTO-INST-SCALAR-SH-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sh.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | L32 | 32 | 0x00005049 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractOperation_SH_U() => ScalarOperation
begin
    return ScalarOperation_SH_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractHandler_SH_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
