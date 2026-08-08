<!-- GENERATED FROM: asl/scalar/sys/DC.IALL.asl -->
# DC.IALL

**Normative ASL source:** `asl/scalar/sys/DC.IALL.asl`

DC.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation.

## Normative identity {#PTO-INST-SCALAR-DC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iall_32_3d61563dd077 | L32 | 32 | 0x0010602b / 0xffffffff | [] |

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractOperation_DC_IALL() => ScalarOperation
begin
    return ScalarOperation_DC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractHandler_DC_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `DC.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation.`
- **Semantic handler:** `ExecuteMaintenance`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
