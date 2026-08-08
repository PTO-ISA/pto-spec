<!-- GENERATED FROM: asl/scalar/sys/C.EBREAK.asl -->
# C.EBREAK

**Normative ASL source:** `asl/scalar/sys/C.EBREAK.asl`

C.EBREAK - Raise the software breakpoint exception.

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm5 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractOperation_C_EBREAK() => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

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

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `C.EBREAK - Raise the software breakpoint exception.`
- **Semantic handler:** `SoftwareBreakpoint`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
