<!-- GENERATED FROM: asl/scalar/sys/ACRE.asl -->
# ACRE

**Normative ASL source:** `asl/scalar/sys/ACRE.asl`

ACRE - Request architecture context entry.

## Normative identity {#PTO-INST-SCALAR-ACRE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
acre rra_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | L32 | 32 | 0x0100302b / 0xff0fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | RRA_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RRA_Type | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractOperation_ACRE() => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractHandler_ACRE() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `ACRE - Request architecture context entry.`
- **Semantic handler:** `ArchitectureEnterRequest`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
