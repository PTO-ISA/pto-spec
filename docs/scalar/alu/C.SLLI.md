<!-- GENERATED FROM: asl/scalar/alu/C.SLLI.asl -->
# C.SLLI

**Normative ASL source:** `asl/scalar/alu/C.SLLI.asl`

C.SLLI snapshots the pre-instruction T#1 value, logically shifts it left by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-slli-purpose role=purpose -->
## What C.SLLI does

`C.SLLI` shifts the current `T#1` value logically left by an encoded amount and pushes the result to `T` as the newest temporary value.

Design point: neither operand is encoded. The source is fixed to `T#1` and the destination to `T`, so the five payload bits of this 16-bit form can all be spent on the shift amount. That is what makes a two-byte shift instruction possible.

<!-- PTO-READER-BLOCK: scalar-c-slli-mechanism role=mechanism -->
## How the result is formed

- `uimm5` is zero-extended and used as a logical left-shift amount from `0` through `31`.
- The pre-instruction `T#1` value is the shifted operand. Bits shifted past bit `63` are discarded and the vacated low bits are zero.

The shifted value is pushed as the newest `T` entry.

Design point: the read happens before the push, so the instruction cannot shift its own result. `c.slli t#1, 1, ->t` doubles the old `T#1` and moves the original to `T#2`.

Design point: an encoded amount of `0` republishes the unchanged value as a fresh entry. It is a real shift by zero, not a no-op, so it still produces one new `T` entry and still advances `TPC`.

<!-- PTO-READER-BLOCK: scalar-c-slli-inputs role=inputs-outputs -->
## Inputs and destinations

- `uimm5` is the only encoded operand: an unsigned shift amount from `0` through `31`.
- The source is implicitly `T#1` and the destination is implicitly `T`, so exactly one XLEN result is pushed per successful execution.

Design point: the fixed `T#1` source must already hold a value. That requirement is checked before the shift, so a `C.SLLI` executed with an empty `T` queue raises a fault instead of shifting stale bits.

Design point: the source is not consumed by the read; only the push changes the queue, moving the previous `T#1` to `T#2` and discarding the previous `T#4`.

<!-- PTO-READER-BLOCK: scalar-c-slli-effects role=effects -->
## Effects and ordering

`T#1` is read before the push, so the value that is shifted is the pre-instruction `T#1`.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-slli-constraints role=constraints -->
## Legality and fault boundary

Every `uimm5` value from `0` through `31` is assigned, so `C.SLLI` has no reserved shift amount.

If `T#1` is unavailable, `Fault_IllegalInstruction` is raised before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: a logical shift is total for every amount in its encoded range, so `C.SLLI` has no value-dependent fault. Bits that leave the top of the register are simply dropped; nothing records them.

<!-- PTO-READER-BLOCK: scalar-c-slli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `3` and `uimm5=2`, `c.slli t#1, 2, ->t` pushes `12` to `T#1` and moves the old value `3` to `T#2`. With `T#1` holding `1` and `uimm5=31`, the pushed value is `2147483648`. With `uimm5=0`, the pushed value is the unchanged old `T#1`.
<!-- SUPPLEMENTARY-END -->

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
