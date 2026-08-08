<!-- GENERATED FROM: asl/scalar/agu/HL.PRF.asl -->
# HL.PRF

**Normative ASL source:** `asl/scalar/agu/HL.PRF.asl`

HL.PRF - Issue a scalar prefetch using this mnemonic's addressing form.

## Normative identity {#PTO-INST-SCALAR-HL-PRF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.prf{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prf_48_39641863bb21 | HL48 | 48 | 0x00007009000e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prf_48_39641863bb21 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_prf_48_39641863bb21 | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prf_48_39641863bb21 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| model | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractOperation_HL_PRF() => ScalarOperation
begin
    return ScalarOperation_HL_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractHandler_HL_PRF() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.PRF - Issue a scalar prefetch using this mnemonic's addressing form.`
- **Semantic handler:** `ScalarPrefetch`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
