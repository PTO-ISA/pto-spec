<!-- GENERATED FROM: asl/scalar/fsu/FDIV.asl -->
# FDIV

**Normative ASL source:** `asl/scalar/fsu/FDIV.asl`

FDIV - Compute this mnemonic's binary floating-point operation.

## Normative identity {#PTO-INST-SCALAR-FDIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fdiv.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | L32 | 32 | 0x0000304b / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractOperation_FDIV() => ScalarOperation
begin
    return ScalarOperation_FDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractHandler_FDIV() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `FDIV - Compute this mnemonic's binary floating-point operation.`
- **Semantic handler:** `FloatingBinary`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
