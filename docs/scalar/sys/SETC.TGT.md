<!-- GENERATED FROM: asl/scalar/sys/SETC.TGT.asl -->
# SETC.TGT

**Normative ASL source:** `asl/scalar/sys/SETC.TGT.asl`

SETC.TGT - Write the bundle commit target.

## Normative identity {#PTO-INST-SCALAR-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.tgt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | L32 | 32 | 0x0000403b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SETC.TGT - Write the bundle commit target.`
- **Semantic handler:** `SetCommitTarget`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
