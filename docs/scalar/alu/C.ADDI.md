<!-- GENERATED FROM: asl/scalar/alu/C.ADDI.asl -->
# C.ADDI

**Normative ASL source:** `asl/scalar/alu/C.ADDI.asl`

C.ADDI snapshots one complete Reg5 source, sign-extends simm5, adds modulo 2^XLEN, and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-addi-purpose role=purpose -->
## What C.ADDI does

`C.ADDI` adds a sign-extended 5-bit immediate to one Reg5 source and pushes the XLEN sum to `T`.

Design point: the immediate is signed and narrow, while the 32-bit `ADDI` spends twelve bits on an unsigned value. The compressed form has room for five immediate bits, and sign extension lets those five bits express both small positive and small negative increments.

<!-- PTO-READER-BLOCK: scalar-c-addi-mechanism role=mechanism -->
## How the result is formed

`simm5` is sign-extended to `PTO_XLEN`, giving an addend from `-16` through `15`, and that value is added to the snapshotted source modulo `2^PTO_XLEN`. The sum is pushed as the newest `T` entry.

Design point: sign extension happens before the addition, so `c.addi a0, -1, ->t` subtracts one. There is no subtract mnemonic in this compressed family; a negative immediate is how the encoding expresses it.

Design point: encoded zero is numeric zero, not omission, so `c.addi a0, 0, ->t` republishes the unchanged source as a new `T` entry rather than performing nothing.

Fixed-width addition is total: it wraps and raises no arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-c-addi-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- `simm5` is the signed 5-bit addend.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so `c.addi zero, 5, ->t` is a pure constant push with no register dependency.

<!-- PTO-READER-BLOCK: scalar-c-addi-effects role=effects -->
## Effects and ordering

`SrcL` and the immediate are resolved before the `T` push, so the source cannot observe the value the instruction is about to push. The push shifts the queue: the new value becomes `T#1`, and the previous `T#4` is discarded.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-addi-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes and every `simm5` value from `-16` through `15`. No immediate is illegal.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: because the immediate is signed and fully assigned, a caller never needs a second mnemonic to subtract a small constant, and no encoding of `C.ADDI` is reserved for a future subtract form.

<!-- PTO-READER-BLOCK: scalar-c-addi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `5` and `simm5=-2`, `c.addi t#1, -2, ->t` pushes `3` to `T#1` and moves the old value `5` to `T#2`. With `SrcL` naming the architectural zero GPR and `simm5=15`, the pushed value is `15`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.addi srcL, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | C16 | 16 | 0x000c / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_addi_16_3050744f2322 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | 0–31 | none | none | Reg5 addend | Encoded zero reads the architectural zero GPR. |
| c_addi_16_3050744f2322 | simm5 | 5 | 0–31 | none | none | signed five-bit addend | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 addend |
| simm5 | signed five-bit addend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractOperation_C_ADDI() => ScalarOperation
begin
    return ScalarOperation_C_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractHandler_C_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADDI(
    left: Word,
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and signed simm5 are required encoded fields; neither can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Every simm5 encoding is assigned and denotes a signed integer from -16 through +15.

## State effects

- Sign-extend simm5 to XLEN and add it to SrcL modulo 2^PTO_XLEN.
- Push exactly one XLEN result to T without consuming the source. Existing T entries shift toward older indices.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL and sign-extend simm5 before pushing the destination.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Fixed-width addition is total and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.addi t#1, -1, ->t
