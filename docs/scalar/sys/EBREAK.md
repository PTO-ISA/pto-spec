<!-- GENERATED FROM: asl/scalar/sys/EBREAK.asl -->
# EBREAK

**Normative ASL source:** `asl/scalar/sys/EBREAK.asl`

EBREAK - Raise the software breakpoint exception.

## Normative identity {#PTO-INST-SCALAR-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ebreak imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | L32 | 32 | 0x0010102b / 0xf0ffffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm4 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractOperation_EBREAK() => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractHandler_EBREAK() => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `EBREAK - Raise the software breakpoint exception.`
- **Semantic handler:** `SoftwareBreakpoint`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
