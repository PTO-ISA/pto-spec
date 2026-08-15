<!-- GENERATED FROM: asl/scalar/alu/C.MOVI.asl -->
# C.MOVI

**Normative ASL source:** `asl/scalar/alu/C.MOVI.asl`

C.MOVI sign-extends its encoded five-bit immediate to XLEN and publishes it through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.movi simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | C16 | 16 | 0x0016 / 0x003f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | 0–9, 11–31 | none | 10 | Reg5 destination or discard | Encoded zero discards the result. |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | 0–31 | none | none | signed five-bit immediate | Encoded zero materializes numeric zero. |

- `c_movi_16_2c84faf1bc72.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| simm5 | signed five-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractOperation_C_MOVI() => ScalarOperation
begin
    return ScalarOperation_C_MOVI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractHandler_C_MOVI() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVI(
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return MoveScalarValue(immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend simm5[4] through the complete XLEN result.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.movi simm, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
