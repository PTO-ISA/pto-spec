<!-- GENERATED FROM: asl/scalar/alu/MULUW.asl -->
# MULUW

**Normative ASL source:** `asl/scalar/alu/MULUW.asl`

Execute the MULUW scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-MULUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
muluw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | L32 | 32 | 0x00003047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| muluw_32_8f52b3d45e53 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| muluw_32_8f52b3d45e53 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractOperation_MULUW() => ScalarOperation
begin
    return ScalarOperation_MULUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULUW.asl -->
```asl
readonly func InstructionContractHandler_MULUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
