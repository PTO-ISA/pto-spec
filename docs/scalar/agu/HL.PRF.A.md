<!-- GENERATED FROM: asl/scalar/agu/HL.PRF.A.asl -->
# HL.PRF.A

**Normative ASL source:** `asl/scalar/agu/HL.PRF.A.asl`

HL.PRF.A - Issue a scalar prefetch using this mnemonic's addressing form.

## Normative identity {#PTO-INST-SCALAR-HL-PRF-A}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prf_a_48_267dc57d14f4 | HL48 | 48 | 0x00007009001e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prf_a_48_267dc57d14f4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_prf_a_48_267dc57d14f4 | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prf_a_48_267dc57d14f4 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| SrcRType | encoded operand or control |
| model | encoded operand or control |
| shamt | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRF.A.asl -->
```asl
readonly func InstructionContractOperation_HL_PRF_A() => ScalarOperation
begin
    return ScalarOperation_HL_PRF_A;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRF.A.asl -->
```asl
readonly func InstructionContractHandler_HL_PRF_A() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.PRF.A - Issue a scalar prefetch using this mnemonic's addressing form.`
- **Semantic handler:** `ScalarPrefetch`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
