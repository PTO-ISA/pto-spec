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

`C.ADD` is a compact 16-bit scalar instruction that adds two complete XLEN Reg5 sources modulo `2^PTO_XLEN` and always pushes one result to the T queue.

<!-- PTO-READER-BLOCK: scalar-c-add-mechanism role=mechanism -->
## Mechanism

The instruction snapshots `SrcL` and `SrcR`, performs fixed-width addition on the two saved values, and publishes the wrapping result as the newest T entry.

The destination is implicit rather than encoded: every successful `C.ADD` pushes exactly one value to T.

<!-- PTO-READER-BLOCK: scalar-c-add-inputs role=inputs-outputs -->
## Inputs and output

- Each source uses the full Reg5 domain: `0..23` select GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`.
- Both encoded source fields are required. Encoded source `0` reads the architectural zero GPR.

Duplicate sources and every absolute-relative or relative-relative pairing are legal; reading a temporary source does not consume it.

<!-- PTO-READER-BLOCK: scalar-c-add-effects role=effects -->
## Effects and ordering

Source snapshotting precedes the implicit T push, so reading T and then pushing T uses the pre-instruction queue contents.

The new result becomes `T#1`, older T entries shift toward `T#4`, and the former `T#4` is discarded. The U queue remains unchanged, and reading a source does not consume an entry.

Successful execution advances `TPC` by `2` bytes and does not change GPR, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state.

<!-- PTO-READER-BLOCK: scalar-c-add-constraints role=constraints -->
## Fault boundary

Addition itself is total and non-trapping. An unavailable selected T/U source raises `Fault_IllegalInstruction` before the T push, before `TPC` advances, and before any unrelated state changes.

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
