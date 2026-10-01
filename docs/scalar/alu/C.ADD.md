<!-- GENERATED FROM: asl/scalar/alu/C.ADD.asl -->
# C.ADD

**Normative ASL source:** `asl/scalar/alu/C.ADD.asl`

C.ADD snapshots two complete Reg5 sources, adds SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-add-purpose role=purpose -->
## What C.ADD does

`C.ADD` reads two Reg5 sources, adds them modulo `2^PTO_XLEN`, and pushes the XLEN result to `T` as the newest temporary value. It is the 16-bit form of the same addition that `ADD` performs with an encoded destination.

Design point: the destination is not encoded at all. The 16-bit form spends its payload on two 5-bit source selectors, so every successful `C.ADD` pushes exactly one `T` value. A result reaches a GPR only through a later instruction that reads a temporary source, for example `c.movr t#1, ->a0`.

<!-- PTO-READER-BLOCK: scalar-c-add-mechanism role=mechanism -->
## Mechanism

Both source codes are resolved, the two complete XLEN values are added modulo `2^PTO_XLEN`, and the wrapping sum is pushed as the newest `T` entry.

Design point: the push shifts the queue rather than overwriting a slot. The new value becomes `T#1`, the previous `T#1` becomes `T#2`, and the previous `T#4` is discarded, so a temporary value survives exactly four pushes.

Design point: both sources are read before the push, so the result of `c.add t#1, t#1, ->t` is twice the old `T#1`. The instruction can never read the value it is about to create.

Fixed-width addition is total: it wraps and raises no arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-c-add-inputs role=inputs-outputs -->
## Inputs and output

- `SrcL` and `SrcR` are Reg5 sources: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: every source code is assigned, and duplicate, absolute-relative and relative-relative source pairs are all legal. `c.add t#1, u#1, ->t` and `c.add t#1, t#1, ->t` therefore encode cleanly; only an unavailable selected temporary faults.

Design point: encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, so `c.add zero, zero, ->t` pushes `0` and is the compressed way to push an explicit zero.

<!-- PTO-READER-BLOCK: scalar-c-add-effects role=effects -->
## Effects and ordering

The two sources are snapshotted before the `T` push, so aliases between the sources and the queue observe the pre-instruction queue state. The push itself is the only state change: the former `T#4` is dropped and all other entries move one index toward older values.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-add-constraints role=constraints -->
## Fault boundary

Every encoded source value is assigned, so `C.ADD` has no reserved source code. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect.

An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`. Both precede the push as well.

Design point: addition itself never faults, so every value-dependent trap of `C.ADD` comes from source availability, not from the operands. Values that wrap or that look negative to a programmer are ordinary results.

<!-- PTO-READER-BLOCK: scalar-c-add-example role=example -->
## Non-normative walkthrough

This walkthrough illustrates the current owner; it is not another instruction definition.

If `T#1` contains `5` and `U#1` contains `3`, `c.add t#1, u#1, ->t` pushes `8` to `T#1`, moves the old value `5` to `T#2`, leaves `U#1` equal to `3`, and advances `TPC` by `2` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.add srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_add_16_85136d1e4904 | C16 | 16 | 0x0008 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_add_16_85136d1e4904 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_add_16_85136d1e4904 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_add_16_85136d1e4904 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_add_16_85136d1e4904 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractOperation_C_ADD() => ScalarOperation
begin
    return ScalarOperation_C_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADD.asl -->
```asl
readonly func InstructionContractHandler_C_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADD(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required encoded fields; neither source can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- Each source code 0..23 selects an absolute GPR, 24..27 selects T#1..T#4, and 28..31 selects U#1..U#4 without consumption.
- Duplicate, absolute-relative, and relative-relative source pairs are legal. Every encoded source value is assigned.

## State effects

- Compute addition on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Addition is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.add t#1, u#1, ->t
