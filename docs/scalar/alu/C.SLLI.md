<!-- GENERATED FROM: asl/scalar/alu/C.SLLI.asl -->
# C.SLLI

**Normative ASL source:** `asl/scalar/alu/C.SLLI.asl`

C.SLLI snapshots the pre-instruction T#1 value, logically shifts it left by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.slli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | C16 | 16 | 0x102c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_slli_16_958a14dc4058 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_slli_16_958a14dc4058 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit logical left-shift amount | Encoded zero republishes the unchanged pre-instruction T#1 value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit logical left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractOperation_C_SLLI() => ScalarOperation
begin
    return ScalarOperation_C_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SLLI.asl -->
```asl
readonly func InstructionContractHandler_C_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SLLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SLL,
        old_t1,
        ZeroExtend{PTO_XLEN}(encoded_amount));
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- T#1 is the fixed source and T is the fixed destination; neither is encoded or omittable in canonical assembly.
- uimm5 is required and directly encodes a shift amount from 0 through 31.

## Legality

- Every uimm5 value 0..31 is assigned. Fixed encoding bits must match the canonical form.
- The fixed T#1 source must be initialized before execution.

## State effects

- Logically shift the complete XLEN old T#1 value left by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices and the former T#4 is discarded.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot old T#1 before the destination push, so the instruction cannot read its own result.
- Push the shifted result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- The logical shift is total and raises no arithmetic exception.
- If T#1 is unavailable, Fault_IllegalInstruction is raised before the T push, before TPC advances, and before any other effect.

## Examples

- c.slli t#1, 31, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
