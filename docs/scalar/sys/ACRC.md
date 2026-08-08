<!-- GENERATED FROM: asl/scalar/sys/ACRC.asl -->
# ACRC

**Normative ASL source:** `asl/scalar/sys/ACRC.asl`

ACRC - Request architecture context close.

## Normative identity {#PTO-INST-SCALAR-ACRC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
acrc rst_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | L32 | 32 | 0x0000302b / 0xff0fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RST_Type | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractOperation_ACRC() => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractHandler_ACRC() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `ACRC - Request architecture context close.`
- **Semantic handler:** `ArchitectureCloseRequest`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
