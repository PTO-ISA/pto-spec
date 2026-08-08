<!-- GENERATED FROM: asl/scalar/agu/PRF.asl -->
# PRF

**Normative ASL source:** `asl/scalar/agu/PRF.asl`

PRF - Issue a scalar prefetch using this mnemonic's addressing form.

## Normative identity {#PTO-INST-SCALAR-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | L32 | 32 | 0x00007009 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| prf_32_30e6dfe4e3ce | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| prf_32_30e6dfe4e3ce | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| prf_32_30e6dfe4e3ce | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/PRF.asl -->
```asl
readonly func InstructionContractHandler_PRF() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `PRF - Issue a scalar prefetch using this mnemonic's addressing form.`
- **Semantic handler:** `ScalarPrefetch`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
