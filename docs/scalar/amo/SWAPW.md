<!-- GENERATED FROM: asl/scalar/amo/SWAPW.asl -->
# SWAPW

**Normative ASL source:** `asl/scalar/amo/SWAPW.asl`

SWAPW - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.

## Normative identity {#PTO-INST-SCALAR-SWAPW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
swapw<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | L32 | 32 | 0x2000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapw_32_ef15c3ebac33 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapw_32_ef15c3ebac33 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapw_32_ef15c3ebac33 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| aq | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractOperation_SWAPW() => ScalarOperation
begin
    return ScalarOperation_SWAPW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPW.asl -->
```asl
readonly func InstructionContractHandler_SWAPW() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SWAPW - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.`
- **Semantic handler:** `AtomicReadModifyWrite`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
