<!-- GENERATED FROM: asl/scalar/agu/HL.PRFI.U.asl -->
# HL.PRFI.U

**Normative ASL source:** `asl/scalar/agu/HL.PRFI.U.asl`

HL.PRFI.U - Issue a scalar prefetch using this mnemonic's addressing form.

## Normative identity {#PTO-INST-SCALAR-HL-PRFI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prfi_u_48_be73891e376e | HL48 | 48 | 0x00007029000e / 0x00007fff003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prfi_u_48_be73891e376e | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prfi_u_48_be73891e376e | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prfi_u_48_be73891e376e | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| model | encoded operand or control |
| simm17 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_PRFI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.PRFI.U - Issue a scalar prefetch using this mnemonic's addressing form.`
- **Semantic handler:** `ScalarPrefetch`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
