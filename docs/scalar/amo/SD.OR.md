<!-- GENERATED FROM: asl/scalar/amo/SD.OR.asl -->
# SD.OR

**Normative ASL source:** `asl/scalar/amo/SD.OR.asl`

SD.OR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.

## Normative identity {#PTO-INST-SCALAR-SD-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sd.or<.{rl, f, rlf}> [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_or_32_2a65eedfae0f | L32 | 32 | 0x2000500b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_or_32_2a65eedfae0f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_or_32_2a65eedfae0f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_or_32_2a65eedfae0f | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sd_or_32_2a65eedfae0f | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.OR.asl -->
```asl
readonly func InstructionContractOperation_SD_OR() => ScalarOperation
begin
    return ScalarOperation_SD_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.OR.asl -->
```asl
readonly func InstructionContractHandler_SD_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SD.OR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.`
- **Semantic handler:** `AtomicReadModifyWrite`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
