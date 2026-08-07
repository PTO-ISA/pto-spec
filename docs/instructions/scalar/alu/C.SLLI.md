# C.SLLI

Execute the C.SLLI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/C.SLLI.asl -->

## Normative identity {#PTO-INST-SCALAR-C-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.slli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | C16 | 16 | 0x102c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractOperation_C_SLLI() => ScalarOperation
begin
    return ScalarOperation_C_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractHandler_C_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
