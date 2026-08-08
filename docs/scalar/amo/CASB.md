<!-- GENERATED FROM: asl/scalar/amo/CASB.asl -->
# CASB

**Normative ASL source:** `asl/scalar/amo/CASB.asl`

CASB - Atomically compare the scalar memory value and conditionally store the replacement.

## Normative identity {#PTO-INST-SCALAR-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
casb<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | L32 | 32 | 0x0000001b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| casb_32_7e529b871832 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| casb_32_7e529b871832 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| casb_32_7e529b871832 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| aq | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractOperation_CASB() => ScalarOperation
begin
    return ScalarOperation_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/CASB.asl -->
```asl
readonly func InstructionContractHandler_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `CASB - Atomically compare the scalar memory value and conditionally store the replacement.`
- **Semantic handler:** `CompareAndSwap`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
