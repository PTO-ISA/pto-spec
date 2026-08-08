<!-- GENERATED FROM: asl/scalar/amo/SW.UMAX.asl -->
# SW.UMAX

**Normative ASL source:** `asl/scalar/amo/SW.UMAX.asl`

SW.UMAX - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.

## Normative identity {#PTO-INST-SCALAR-SW-UMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sw.umax<.{rl, f, rlf}> [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_umax_32_5530dfa23323 | L32 | 32 | 0x6000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_umax_32_5530dfa23323 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_umax_32_5530dfa23323 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_umax_32_5530dfa23323 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_umax_32_5530dfa23323 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.UMAX.asl -->
```asl
readonly func InstructionContractOperation_SW_UMAX() => ScalarOperation
begin
    return ScalarOperation_SW_UMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.UMAX.asl -->
```asl
readonly func InstructionContractHandler_SW_UMAX() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SW.UMAX - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.`
- **Semantic handler:** `AtomicReadModifyWrite`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
