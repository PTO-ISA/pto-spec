<!-- GENERATED FROM: asl/scalar/sys/ASSERT.asl -->
# ASSERT

**Normative ASL source:** `asl/scalar/sys/ASSERT.asl`

ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.

## Normative identity {#PTO-INST-SCALAR-ASSERT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-assert-purpose role=purpose -->
## What ASSERT does

`ASSERT` is an architectural assertion check. It reads one scalar value and raises the assertion trap when that value is exactly zero. A non-zero value is accepted silently.

It has no destination: the only two possible outcomes are a normal retirement and the assertion trap.

<!-- PTO-READER-BLOCK: scalar-assert-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The handler reads `SrcL` once and tests it for zero. Zero raises `Fault_Assert` with the request site as the fault address. Any non-zero value, including a value whose low bits are zero but whose high bits are set, passes the test.

Design point: the check is placed on the snapshot of the source rather than on a flag or a condition register. That keeps the assertion self-contained: the value that decides the outcome is exactly the value the program computed into that register, with no hidden state between the computation and the check.

<!-- PTO-READER-BLOCK: scalar-assert-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` is the source selector. Encoded zero names the architectural zero GPR, whose read value is always XLEN zero, so a zero selector always raises the assertion trap.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`.

<!-- PTO-READER-BLOCK: scalar-assert-effects role=effects -->
## Architectural effects

On a zero source the instruction raises `Fault_Assert`, does not advance `TPC`, and retires nothing; the trap entry records the fault address as the request site. On a non-zero source the only effect is a successful retirement, and `TPC` advances by `4` bytes.

The source register and any queue entry it names are unchanged in both outcomes: the instruction reads, it never writes.

The instruction has no memory effect and leaves no reservation behind, so it cannot be the reason a later atomic or load-linked operation fails.

<!-- PTO-READER-BLOCK: scalar-assert-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

Every available Reg5 source selector is assigned, so no source selector is reserved. A selector that names an unavailable `T` or `U` slot is rejected with `Fault_IllegalInstruction` before the zero test runs, which keeps the fault order stable: an unavailable source is never reported as an assertion failure.

<!-- PTO-READER-BLOCK: scalar-assert-example role=example -->
## Non-normative example

`assert a0` retires normally when `a0` holds any non-zero value. When `a0` holds XLEN zero, the instruction raises `Fault_Assert` at its own site and `TPC` stays where it was.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
assert SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | L32 | 32 | 0x0000102b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractOperation_ASSERT()
    => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ASSERT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractHandler_ASSERT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;

pure func InstructionContractRequiresSystemBlock_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFaultsWhenZero_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPreservesSource_ASSERT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every available Reg5 source selector is assigned.

## State effects

- Snapshot SrcL; zero raises Fault_Assert at the faulting PC and nonzero performs no effect other than successful retirement.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- assert SrcL
