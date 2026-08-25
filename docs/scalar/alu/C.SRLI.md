<!-- GENERATED FROM: asl/scalar/alu/C.SRLI.asl -->
# C.SRLI

**Normative ASL source:** `asl/scalar/alu/C.SRLI.asl`

C.SRLI snapshots the pre-instruction T#1 value, logically shifts it right by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-srli-purpose role=purpose -->
## What C.SRLI does

`C.SRLI` is a 16-bit scalar ALU instruction. It logically shifts the source right under the complete XLEN value shift rules; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-c-srli-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then logically shifts the source right under the complete XLEN value shift rules, and only afterward performs the destination effects.

- The immediate width and extension rule come from the encoded field shown below; encoded zero supplies numeric zero unless the generated contract states another zero meaning.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-c-srli-inputs role=inputs-outputs -->
## Inputs and destinations

- The unsigned 5-bit `uimm5` field carries the unsigned five-bit logical-right shift amount.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-c-srli-effects role=effects -->
## Effects and ordering

Any scalar source is snapshotted before publication, and the completed instruction pushes exactly one result to T.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 2 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-c-srli-constraints role=constraints -->
## Legality and fault boundary

All 6 encoded shift bits are assigned, giving amounts `0..63`; fixed-width shifting is total and raises no arithmetic exception.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-c-srli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `C.SRLI` example, source `16` shifted logically right by `2` produces `4`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.srli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | C16 | 16 | 0x182c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit logical right-shift amount | Encoded zero republishes the unchanged pre-instruction T#1 value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit logical right-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SRLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SRL,
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

- Logically shift the complete XLEN old T#1 value right by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.
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

- c.srli t#1, 31, ->t
