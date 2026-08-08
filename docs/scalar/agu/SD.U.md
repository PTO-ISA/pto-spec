<!-- GENERATED FROM: asl/scalar/agu/SD.U.asl -->
# SD.U

**Normative ASL source:** `asl/scalar/agu/SD.U.asl`

SD.U - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-SD-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | L32 | 32 | 0x00007049 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractHandler_SD_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SD.U - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
