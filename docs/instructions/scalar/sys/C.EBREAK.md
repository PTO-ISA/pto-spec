# C.EBREAK

Execute the C.EBREAK scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/C.EBREAK.asl -->

## Normative identity {#PTO-INST-SCALAR-C-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.break imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | C16 | 16 | 0xc02c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | imm5 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractOperation_C_EBREAK() => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractHandler_C_EBREAK() => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
